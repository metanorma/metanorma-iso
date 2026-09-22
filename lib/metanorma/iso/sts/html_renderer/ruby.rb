# frozen_string_literal: true

require "cgi"
require "liquid"

module Metanorma
  module Iso
    module Sts
      module HtmlRenderer
        # ISO STS XML → HTML renderer. Parses the input once into the
        # sts-ruby typed model and emits HTML through Liquid templates —
        # no DOM library, no XSLT engine.
        #
        # Architecture:
        #
        #   render
        #     ├── coerce_model       (XML string → Sts::NisoSts::Standard)
        #     ├── render_node        (model tree → fragment, via DISPATCH)
        #     └── assemble_document  (fragment → full page via
        #                            templates/document.html.liquid with
        #                            assets/theme.css and the ISO wordmark)
        #
        # Element markup lives in templates/ and the dispatch table; new
        # NisoSts element types are a new DISPATCH entry, not a code branch.
        class Ruby
          TEMPLATES_DIR = File.expand_path("templates", __dir__)
          ASSETS_DIR = File.expand_path("assets", __dir__)

          include Handlers

          def initialize(templates_dir: nil, assets_dir: nil,
                         publisher_name: nil, publisher_address: nil,
                         license_text: nil)
            @templates_dir = templates_dir || TEMPLATES_DIR
            @assets_dir = assets_dir || ASSETS_DIR
            @publisher_name = publisher_name
            @publisher_address = publisher_address
            @license_text = license_text || "All rights reserved"
            @liquid_env = Liquid::Environment.new
            @liquid_env.file_system = Liquid::LocalFileSystem.new(@templates_dir)
            @template_cache = {}
            @mapping_cache = Hash.new { |h, klass| h[klass] = build_mapping(klass) }
            @toc = []
            @deferred_footnotes = []
            @depth = 0
          end

          def render(model_or_xml, full_document: true)
            model = coerce_model(model_or_xml)
            @assemble = full_document
            @toc = []
            @depth = 0
            @suppressed_labels = nil
            body = render_node(model)
            return body unless full_document

            assemble_document(body, model)
          end

          private

          attr_reader :templates_dir, :assets_dir

          def coerce_model(input)
            return input if input.is_a?(Lutaml::Model::Serializable)

            NISO::Standard.from_xml(input.to_s)
          end

          # ---- Walking (document-order traversal of the typed model) ----

          def render_children(node, skip: [])
            return render_inline(node) if mixed_model?(node)

            mapping = @mapping_cache[node.class][:elements]
            indices = Hash.new(0)
            node.element_order.filter_map do |entry|
              case entry.node_type
              when :text
                escape(entry.text_content.to_s)
              when :element
                next if skip.include?(entry.name.to_s)

                attr = mapping[entry.name.to_s]
                next unless attr

                item = collection_item_at(node, attr, indices)
                next unless item

                rendered = render_node(item)
                rendered unless rendered.empty?
              end
            end.join
          end

          def render_inline(node)
            return render_children(node) unless mixed_model?(node)

            node.each_mixed_content.filter_map do |child|
              if child.is_a?(String)
                escape(child)
              elsif child.is_a?(Mml::V3::Math)
                mathml_to_html(child)
              else
                rendered = render_node(child)
                rendered unless rendered.empty?
              end
            end.join
          end

          def mixed_model?(node)
            @mapping_cache[node.class][:mixed]
          end

          def build_mapping(klass)
            return { elements: {}, mixed: false } unless lutaml_model?(klass)

            instance = klass.allocate
            xml_mapping = klass.mappings_for(:xml, instance.lutaml_register)
            elements = {}
            xml_mapping.mapping_elements_hash.each_value do |rule_or_array|
              Array(rule_or_array).each { |rule| elements[rule.name.to_s] = rule.to }
            end
            { elements: elements, mixed: xml_mapping.mixed_content? }
          rescue Lutaml::Model::Error
            { elements: {}, mixed: false }
          end

          def lutaml_model?(klass)
            klass.is_a?(Class) && klass <= Lutaml::Model::Serializable
          end

          def collection_item_at(node, attr, indices)
            value = node.public_send(attr)
            return value unless value.is_a?(Array)

            item = value[indices[attr]]
            indices[attr] += 1
            item
          end

          # ---- Document assembly (full page) ----

          def assemble_document(body, model)
            meta = meta_info(model)
            footnotes = deferred_footnotes_html
            render_liquid("document.html.liquid", {
                            "lang" => "en",
                            "title" => meta[:title],
                            "css" => stylesheet,
                            "docid" => meta[:docid],
                            "toc" => toc_html,
                            "hero" => hero_html(meta),
                            "content" => body + footnotes,
                            "footer" => footer_html(meta),
                            "js" => javascript,
                          })
          end

          def deferred_footnotes_html
            return "" if @deferred_footnotes.empty?

            parts = @deferred_footnotes.map do |fn|
              render_element("p", escape(fn["body"]), css: "footnote")
            end
            parts.join("\n")
          end

          def hero_html(meta)
            return "" if meta[:title].empty?

            chips = []
            chips << meta[:docid] unless meta[:docid].empty?
            chips << meta[:year] unless meta[:year].empty?
            chips << "EN"
            render_liquid("_hero.html.liquid", {
                            "eyebrow" => @publisher_name || PUBLISHER_NAME,
                            "title" => meta[:title],
                            "chips" => chips,
                          })
          end

          def footer_html(meta)
            render_liquid("_footer.html.liquid", {
                            "copyright" => meta[:copyright],
                            "holder" => meta[:holder],
                            "year" => meta[:year],
                            "docid" => meta[:docid],
                            "series" => meta[:series],
                            "publisher_name" => @publisher_name || PUBLISHER_NAME,
                            "publisher_address" => @publisher_address || PUBLISHER_ADDRESS,
                            "license" => @license_text,
                            "version" => Metanorma::Iso::VERSION,
                            "mn_icon_light" => metanorma_icon_light,
                            "mn_icon_dark" => metanorma_icon_dark,
                          })
          end

          def metanorma_icon_light
            @mn_icon_light ||= File.read(File.join(assets_dir, "metanorma-icon-light.svg"))
              .sub(/\A<\?xml[^?]*\?>\s*/, "")
          end

          def metanorma_icon_dark
            @mn_icon_dark ||= File.read(File.join(assets_dir, "metanorma-icon-dark.svg"))
              .sub(/\A<\?xml[^?]*\?>\s*/, "")
          end

          def toc_html
            return "" if @toc.empty?

            items = @toc.map do |entry|
              %(<li><a class="toc-link toc-link-d#{entry[:depth]}" href="##{entry[:id]}">#{escape(entry[:title])}</a></li>)
            end.join
            %(<nav id="toc" class="toc-panel sticky top-[68px] self-start max-h-[calc(100vh-5rem)] overflow-y-auto py-4 pr-3 text-sm [scrollbar-width:thin]" aria-label="Contents"><h2 class="toc-heading m-0 mb-2 ml-4 text-xs font-bold tracking-[0.14em] uppercase text-ink-faint">Contents</h2><ol class="toc-list list-none m-0 p-0">#{items}</ol></nav>)
          end

          def meta_info(model)
            meta_node = find_meta_node(model)
            return { title: "", docid: "" } unless meta_node

            { title: title_text(meta_node),
              docid: doc_id(meta_node),
              year: find_text(meta_node, %w[ReleaseDate MetaDate PubDate]),
              series: "",
              copyright: copyright_statement_text(meta_node),
              holder: find_text(meta_node, %w[CopyrightHolder]) }
          end

          # NisoSts TitleWrap stores intro/main as STRINGS, full/compl as
          # typed TitleFull/TitleCompl. Prefer main, fall back to full /
          # intro / compl.
          def title_text(meta_node)
            wrap = find_model(meta_node, "TitleWrap")
            return find_text(meta_node, ["Title"]) unless wrap

            %i[main full compl intro].each do |attr|
              next unless wrap.class.method_defined?(attr)
              val = wrap.public_send(attr)
              next unless val
              text = val.is_a?(String) ? val.strip : plain_text(val).gsub(/\s+/, " ").strip
              return text unless text.empty?
            end
            find_text(meta_node, ["Title"])
          end

          # Display form of the document identifier: prefer the doc-ref
          # string field on MetadataIso (already formatted); fall back to
          # StandardIdentification's string parts; last resort, raw text.
          def doc_id(meta_node)
            if meta_node.class.method_defined?(:doc_ref) && meta_node.doc_ref
              text = meta_node.doc_ref.to_s.strip
              return text unless text.empty?
            end

            std_ident = find_model(meta_node, "StandardIdentification")
            return find_text(meta_node, META_ID_NAMES) unless std_ident

            parts = %i[originator doc_type doc_number].filter_map do |attr|
              next unless std_ident.class.method_defined?(attr)

              val = std_ident.public_send(attr)
              val ? val.to_s.strip : nil
            end
            id = parts.reject(&:empty?).join(" ")
            return id unless id.empty?

            find_text(meta_node, META_ID_NAMES)
          end

          def copyright_statement_text(meta_node)
            perm = find_model(meta_node, "Permissions")
            return "" unless perm

            cs = perm.copyright_statement
            cs ? cs.to_s.strip : ""
          end

          def walk_models(node, &block)
            return unless node.is_a?(Lutaml::Model::Serializable)

            yield node
            node.class.attributes.each_value do |attr_def|
              Array(node.public_send(attr_def.name)).compact.each do |child|
                walk_models(child, &block) if child.is_a?(Lutaml::Model::Serializable)
              end
            end
          end

          def find_meta_node(node)
            return node if meta_node?(node)
            return nil unless node.is_a?(Lutaml::Model::Serializable)

            node.class.attributes.each_value do |attr_def|
              value = node.public_send(attr_def.name)
              Array(value).compact.each do |child|
                next unless child.is_a?(Lutaml::Model::Serializable)

                found = find_meta_node(child)
                return found if found
              end
            end
            nil
          end

          def meta_node?(node)
            node.is_a?(NISO::MetadataIso) ||
              node.is_a?(NISO::MetadataStd) ||
              node.is_a?(NISO::RegMeta) ||
              node.is_a?(NISO::NatMeta)
          end

          def stylesheet
            @stylesheet ||= File.read(File.join(assets_dir, "theme.css"))
          end

          def javascript
            @javascript ||= File.read(File.join(assets_dir, "page.js"))
          end

          # ---- Text extraction ----

          def find_text(node, names)
            if names.include?(node.class.name.split("::").last)
              text = plain_text(node).gsub(/\s+/, " ").strip
              return text unless text.empty?
            end

            node.class.attributes.each_value do |attr_def|
              value = node.public_send(attr_def.name)
              Array(value).compact.each do |child|
                next unless child.is_a?(Lutaml::Model::Serializable)

                found = find_text(child, names)
                return found unless found.empty?
              end
            end
            ""
          end

          def plain_text(node)
            return node.to_s unless node.is_a?(Lutaml::Model::Serializable)

            children = mixed_model?(node) ? node.each_mixed_content.to_a : ordered_content_parts(node)
            children.map do |child|
              child.is_a?(String) ? child : plain_text(child)
            end.join
          end

          def ordered_content_parts(node)
            mapping = @mapping_cache[node.class][:elements]
            indices = Hash.new(0)
            node.element_order.filter_map do |entry|
              if entry.node_type == :text
                entry.text_content.to_s
              else
                attr = mapping[entry.name.to_s]
                next unless attr

                collection_item_at(node, attr, indices)
              end
            end
          end

          def inline_or_content(node)
            rendered = render_inline(node)
            rendered.empty? ? node.content.to_s : rendered
          end

          # ---- Liquid emitters ----

          def render_element(tag, content, id: nil, css: nil)
            render_liquid("_element.html.liquid", {
                            "tag" => tag, "id" => id,
                            "css" => css, "content" => content
                          })
          end

          def render_link(href:, text:)
            render_liquid("_link.html.liquid", {
                            "href" => href.to_s, "text" => text
                          })
          end

          def render_liquid(template_name, assigns)
            template = @template_cache[template_name] ||= begin
              path = File.join(templates_dir, template_name)
              Liquid::Template.parse(File.read(path).chomp, environment: @liquid_env)
            end
            template.render(assigns)
          end

          def escape(text)
            CGI.escapeHTML(text.to_s)
          end
        end
      end
    end
  end
end
