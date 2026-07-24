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

          NISO = ::Sts::NisoSts
          TBX = ::Sts::TbxIsoTml

          # Demodulized model class name → handler method. Anything not
          # listed renders its children transparently (see #render_children).
          DISPATCH = {
            "MetadataIso" => :meta, "MetadataStd" => :meta,
            "RegMeta" => :meta, "NatMeta" => :meta,
            "Body" => :children,
            "Section" => :section, "App" => :section, "TermSection" => :section,
            "Label" => :label,
            "Title" => :title,
            "Standard" => :standard,
            "Paragraph" => :paragraph,
            "List" => :list, "ListItem" => :list_item,
            "DefList" => :def_list, "Term" => :term, "Def" => :def_item,
            "TableWrap" => :table_wrap, "Table" => :table,
            "Thead" => :thead, "Tbody" => :tbody, "Tr" => :tr,
            "Td" => :td, "Th" => :th,
            "Figure" => :figure, "Caption" => :caption, "Graphic" => :graphic,
            "DisplayFormula" => :disp_formula,
            "InlineFormula" => :inline_formula,
            "Preformat" => :preformat,
            "NonNormativeNote" => :note,
            "NonNormativeExample" => :example,
            "DispQuote" => :quote,
            "ReferenceList" => :ref_list, "Reference" => :ref,
            "MixedCitation" => :citation, "ElementCitation" => :citation,
            "ReferenceStandard" => :std, "StandardRef" => :std_ref,
            "StandardIdentification" => :std_ident,
            "DocumentIdentification" => :doc_ident,
            "Originator" => :originator,
            "Fn" => :fn, "Xref" => :xref,
            "ExtLink" => :ext_link, "Uri" => :ext_link,
            "Break" => :brk, "ProcessingMeta" => :skip,
          }.freeze

          # Inline phrase-level elements → HTML tag (constant-keyed).
          # NisoSts owns Sub/Sup/Monospace/Sc/Strike/Underline; TbxIsoTml
          # owns Bold/Italic (terminology namespace is the canonical home
          # for phrase-level emphasis in NISO STS v1.2).
          INLINE_TAGS = {
            TBX::Bold => "strong",
            TBX::Italic => "em",
            NISO::Monospace => "code",
            NISO::Sub => "sub",
            NISO::Sup => "sup",
            NISO::Sc => "span",
            NISO::Strike => "s",
            NISO::Underline => "u",
          }.freeze

          META_ID_NAMES = %w[DocumentIdentification StandardIdentification].freeze

          PUBLISHER_NAME = "International Organization for Standardization"
          PUBLISHER_ADDRESS = "ISO Central Secretariat · CP 401 · Ch. de Blandonnet 8, 1214 Vernier, Geneva, Switzerland"

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

          # The dispatch handlers below are the renderer's extension API:
          # the DISPATCH table maps IsoSts class names to these methods by
          # symbol, and flavors can override individual handlers without
          # touching the dispatch logic. Keep them public so the table
          # can resolve via #public_send without bypassing access rules.

          # ---- Dispatch -------------------------------------------------------

          def render_node(node)
            case node
            when String then escape(node)
            when *INLINE_TAGS.keys then render_inline_tag(node)
            else
              handler = DISPATCH[node.class.name.split("::").last]
              handler ? public_send(handler, node) : render_children(node)
            end
          end

          def mathml_to_html(node)
            node.to_xml.to_s
              .gsub(/<(\/?)mml:/, '<\1')
              .gsub(/\s+xmlns:mml="[^"]*"/, "")
              .gsub(/\s+xmlns:xlink="[^"]*"/, "")
              .gsub(/></, ">\n<")
          end

          # ---- Handlers -------------------------------------------------------

          def children(node) = render_children(node)

          # Renders the document: front matter first, then ONE <main>
          # wrapping body AND back matter (annexes, bibliography), so
          # back content stays in the main flow instead of becoming
          # grid items behind the TOC.
          def standard(node)
            front = document_child(node, "Front")
            body = document_child(node, "Body")
            back = document_child(node, "Back")

            parts = []
            parts << render_children(front) if front
            main_content = []
            main_content << render_children(body) if body
            main_content << render_children(back) if back
            parts << render_element("main", main_content.join)
            parts.join
          end

          def document_child(node, demodulized)
            order = node.element_order
            return nil unless order

            mapping = @mapping_cache[node.class][:elements]
            order.each do |entry|
              next unless entry.node_type == :element

              attr = mapping[entry.name.to_s]
              next unless attr

              item = node.public_send(attr)
              item = item.first if item.is_a?(Array)
              return item if item && item.class.name.split("::").last == demodulized
            end
            nil
          end

          def section(node)
            sec_id = section_id(node)
            title_text = extract_title(node)
            register_toc(node, sec_id, title_text)
            previous_section_id = @current_section_id
            previous_label = @current_label
            label_node = own_label(node)
            suppress_label(label_node) if label_node
            raw_label = label_node ? plain_text(label_node).gsub(/\s+/, " ").strip : nil
            @current_label = display_label(node, raw_label)
            frontmatter = frontmatter_section?(sec_id, title_text)
            @depth += 1
            @current_section_id = sec_id
            inner = render_children(node)
            render_element("section", inner,
                           id: sec_id,
                           css: frontmatter ? "frontmatter" : nil)
          ensure
            @depth -= 1
            @current_section_id = previous_section_id
            @current_label = previous_label
          end

          def frontmatter_section?(sec_id, title_text)
            return false unless @depth.zero? && @current_label.nil?
            return true if sec_id && %w[sec_foreword sec_intro sec_abstract].include?(sec_id.downcase)
            return true if title_text.to_s.match?(/\Aforeword\z/i)
            return true if title_text.to_s.match?(/\Aintroduction\z/i)

            false
          end

          def own_label(node)
            return nil unless node.class.method_defined?(:label)

            label = node.label
            label if label.is_a?(Lutaml::Model::Serializable)
          end

          def suppress_label(node)
            suppressed_labels[node] = true
          end

          def suppressed_labels
            @suppressed_labels ||= {}.compare_by_identity
          end

          def extract_title(node)
            title_node = find_child(node, "Title")
            return nil unless title_node

            text = plain_text(title_node).gsub(/\s+/, " ").strip
            text.empty? ? nil : text
          end

          def section_id(node)
            return node.id if node.class.method_defined?(:id) && node.id

            title_node = find_child(node, "Title")
            return nil unless title_node

            plain_text(title_node).gsub(/\s+/, " ").strip
              .downcase.gsub(/[^a-z0-9]+/, "-")
              .gsub(/\A-|-\z/, "")
          end

          def display_label(node, label_text)
            return nil if label_text.nil? || label_text.empty?

            label_text.start_with?("Annex") ? label_text : label_text
          end

          def register_toc(node, sec_id, title_text = nil)
            title_node = find_child(node, "Title")
            return unless sec_id && title_node

            label_node = own_label(node)
            label_text = label_node ? plain_text(label_node).gsub(/\s+/, " ").strip : nil
            title_text ||= plain_text(title_node).gsub(/\s+/, " ").strip
            title_text = "#{label_text} #{title_text}" if label_text
            register_toc_entry(id: sec_id, title: title_text, depth: @depth)
          end

          def register_toc_entry(id:, title:, depth:)
            @toc << { id: id, title: title, depth: depth }
          end

          def find_child(node, demodulized_name)
            return nil unless node.is_a?(Lutaml::Model::Serializable)

            mapping = @mapping_cache[node.class][:elements]
            node.element_order.each do |entry|
              next unless entry.node_type == :element

              attr = mapping[entry.name.to_s]
              next unless attr

              value = node.public_send(attr)
              value = value.first if value.is_a?(Array)
              return value if value && value.class.name.split("::").last == demodulized_name
            end
            nil
          end

          def label(node)
            return "" if suppressed_labels.key?(node)

            render_element("span", render_inline(node), css: "label")
          end

          def title(node)
            level = (1 + @depth).clamp(2, 4)
            anchor = if @current_section_id
                       %(<a class="h-anchor" href="##{@current_section_id}" aria-label="Link to this section">§</a>)
                     else
                       ""
                     end
            prefix = ""
            if @current_label && !@current_label.empty?
              prefix = %(<span class="sec-label">#{escape(@current_label)}</span> )
              @current_label = nil
            end
            render_element("h#{level}", prefix + render_inline(node) + anchor)
          end

          def paragraph(node)
            render_element("p", render_inline(node),
                           id: node.class.method_defined?(:id) ? node.id : nil)
          end

          def list(node)
            tag = node.list_type == "order" ? "ol" : "ul"
            css = labeled_list?(node) ? "mn-labeled-list" : nil
            render_element(tag, render_children(node), css: css)
          end

          def labeled_list?(node)
            return false unless node.class.method_defined?(:list_item)

            Array(node.list_item).any? { |item| own_label(item) }
          end

          def list_item(node)
            label_node = own_label(node)
            suppress_label(label_node) if label_node
            inner = render_children(node)
            if label_node
              marker = render_element("span", escape(plain_text(label_node).strip), css: "li-label")
              inner = marker + inner
            end
            render_element("li", inner)
          end

          def def_list(node) = render_element("dl", render_children(node))

          def term(node) = render_element("dt", render_element("p", render_children(node)))

          def def_item(node) = render_element("dd", render_children(node))

          def table_wrap(node)
            inner = render_children(node, skip: %w[label caption])
            render_element("div", table_caption_line(node) + inner, css: "table-wrap")
          end

          def table_caption_line(node)
            label_text = node.class.method_defined?(:label) ? plain_text(node.label).strip : ""
            caption_node = node.caption if node.class.method_defined?(:caption)
            title_node = caption_node.title if caption_node&.class&.method_defined?(:title)
            title_html = title_node ? render_inline(title_node) : ""
            return "" if label_text.empty? && title_html.empty?

            parts = []
            parts << %(<span class="tc-label">#{escape(label_text)}</span>) unless label_text.empty?
            parts << title_html unless title_html.empty?
            %(<p class="tbl-caption">#{parts.join('<span class="tc-delim"> — </span>')}</p>)
          end

          def table(node)
            @table_fns ||= []
            @table_fns.push([])
            body = render_children(node)
            collected = @table_fns.pop
            parts = [body]
            unless collected.empty?
              tfoot_cells = collected.map do |fn_body|
                cell = render_element("p", escape(fn_body))
                inner_div = %(<div class="TableFootnote">#{cell}</div>)
                %(<td colspan="4">#{inner_div}</td>)
              end.join
              parts << "<tfoot><tr>#{tfoot_cells}</tr></tfoot>"
            end
            render_element("table", parts.join)
          end

          def thead(node) = render_element("thead", render_children(node))
          def tbody(node) = render_element("tbody", render_children(node))
          def tr(node) = render_element("tr", render_children(node))
          def td(node) = render_element("td", render_children(node))
          def th(node) = render_element("th", render_children(node))

          def figure(node) = render_element("figure", render_children(node))
          def caption(node) = render_element("figcaption", render_children(node))

          def graphic(node)
            href = node.class.method_defined?(:xlink_href) ? node.xlink_href : node.href
            alttext = node.class.method_defined?(:alttext) ? node.alttext : nil
            render_liquid("_img.html.liquid", {
                            "src" => href.to_s,
                            "alt" => alttext.to_s,
                          })
          end

          def disp_formula(node) = render_element("div", render_inline(node), css: "formula")
          def inline_formula(node) = render_element("span", render_inline(node), css: "formula")
          def preformat(node) = render_element("pre", render_inline(node))

          def note(node)
            label_node = own_label(node)
            suppress_label(label_node) if label_node
            inner = render_children(node)
            label_text = label_node ? plain_text(label_node).strip : "NOTE"
            label_html = %(<span class="note-label">#{escape(label_text)}</span> )
            inner = inner.sub(/<p(?:\s[^>]*)?>/, "\\0#{label_html}")
            render_element("div", inner, css: "note")
          end

          def example(node)
            label_node = own_label(node)
            suppress_label(label_node) if label_node
            inner = render_children(node)
            if label_node
              label_html = %(<span class="example-label">#{escape(plain_text(label_node).strip)}</span> )
              inner = inner.sub(/<p(?:\s[^>]*)?>/, "\\0#{label_html}")
            else
              inner = kind_label("EXAMPLE") + inner
            end
            render_element("div", inner, css: "example")
          end

          def kind_label(text)
            %(<span class="note-label">#{text}</span> )
          end

          def quote(node) = render_element("blockquote", render_children(node))

          def ref_list(node)
            title_node = find_child(node, "Title")
            title_text = title_node ? plain_text(title_node).gsub(/\s+/, " ").strip : nil
            sec_id = title_text ? title_text.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "") : nil
            sec_id = nil if sec_id && sec_id.empty?
            register_toc_entry(id: sec_id, title: title_text, depth: @depth) if sec_id
            previous_section_id = @current_section_id
            @current_section_id = sec_id
            render_element("div", render_children(node), id: sec_id, css: "ref-list")
          ensure
            @current_section_id = previous_section_id
          end

          def ref(node)
            std_node = find_model(node, "Std")
            content = std_node ? render_node(std_node) : render_children(node, skip: %w[label])
            body = render_element("p", ref_label(node) + content, css: "ref-body")
            render_element("div", body, css: "ref")
          end

          def ref_label(node)
            label_node = find_model(node, "Label")
            return "" unless label_node

            render_element("span", render_inline(label_node), css: "label") + " "
          end

          def find_model(node, demodulized)
            found = nil
            walk_models(node) do |model|
              found ||= model if model.class.name.split("::").last == demodulized
            end
            found
          end

          def citation(node) = render_element("span", render_inline(node), css: "citation")

          # <std> (ReferenceStandard) inside a bibliography ref: render
          # standard-ref and title inline, joined by the NISO STS citation
          # idiom ", ".
          def std(node)
            @in_std = true
            parts = []
            ref_node = find_model(node, "StandardRef")
            parts << render_element("span", render_inline(ref_node), css: "std-ref") if ref_node
            title_node = find_model(node, "Title")
            parts << render_element("em", render_inline(title_node)) if title_node
            render_element("span", parts.join(", "), css: "std")
          ensure
            @in_std = false
          end

          def std_ref(node) = render_element("span", render_inline(node), css: "std-ref")
          def std_ident(node) = render_element("span", render_inline(node), css: "std-ident")
          def doc_ident(node) = render_element("span", render_inline(node), css: "doc-id")

          def ics(node)
            code = node.class.method_defined?(:content) ? node.content : nil
            render_element("span", escape(code.to_s), css: "ics")
          end

          # Permissions in NisoSts has string fields (copyright_statement,
          # copyright_year) + a string collection (copyright_holder).
          def permissions(node)
            parts = []
            if node.class.method_defined?(:copyright_statement) && node.copyright_statement
              parts << render_element("span", escape(node.copyright_statement.to_s),
                                      css: "copyright-statement")
            end
            if node.class.method_defined?(:copyright_year) && node.copyright_year
              parts << render_element("span", escape(node.copyright_year.to_s),
                                      css: "copyright-year")
            end
            if node.class.method_defined?(:copyright_holder)
              Array(node.copyright_holder).each do |ch|
                parts << render_element("span", escape(ch.to_s), css: "copyright-holder")
              end
            end
            render_element("span", parts.join(" "), css: "permissions")
          end

          def originator(node) = render_element("span", render_inline(node), css: "originator")

          def fn(node)
            label_node = own_label(node)
            suppress_label(label_node) if label_node
            label_text = label_node ? plain_text(label_node).strip : ""
            display_label = label_text.match?(/\A\d+\z/) ? "#{label_text})" : label_text
            # NisoSts::Fn uses :paragraph (not :p) for the <p> collection.
            body_parts = Array(node.paragraph).map { |para| plain_text(para) }
            body_text = body_parts.join(" ")
            unless body_text.empty?
              if @table_fns&.last
                @table_fns.last.push(body_text)
              else
                @deferred_footnotes << { "label" => display_label, "body" => body_text }
              end
            end
            render_element("sup", escape(display_label), css: "fn-label")
          end

          def ext_link(node)
            href = node.class.method_defined?(:xlink_href) ? node.xlink_href : node.href
            render_link(href: href, text: inline_or_content(node))
          end

          def xref(node)
            rid = node.rid.to_s
            text = render_inline(node).strip
            text = "[#{rid}]" if text.empty?

            render_link(href: "##{rid}", text: text)
          end

          def brk(_node) = "<br/>"

          def skip(_node) = ""

          def meta(node)
            return "" if @assemble

            title = find_text(node, ["TitleWrap"])
            docid = find_text(node, META_ID_NAMES)
            return "" if title.empty? && docid.empty?

            render_liquid("_meta_header.html.liquid", {
                            "docid" => docid, "title" => title
                          })
          end

          def render_inline_tag(node)
            tag = INLINE_TAGS[node.class]
            inner = render_inline(node)
            return render_element("span", inner, css: "small-caps") if tag == "span"

            render_element(tag, inner)
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
