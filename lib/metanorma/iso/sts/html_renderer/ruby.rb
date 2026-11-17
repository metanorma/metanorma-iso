# frozen_string_literal: true

require "cgi"
require "liquid"
require "sts"

module Metanorma
  module Iso
    module Sts
      module HtmlRenderer
        # STS XML → HTML renderer. Parses the input once into the sts-ruby
        # typed model and emits HTML through Liquid templates — no DOM
        # library, no XSLT engine.
        #
        # Architecture:
        #
        #   render
        #     ├── coerce_model      (XML string → Sts::NisoSts::Standard)
        #     ├── render_node       (model tree → fragment, via DISPATCH)
        #     └── assemble_document (fragment → full page via
        #                            templates/document.html.liquid with
        #                            assets/sts.css and the OIML logo)
        #
        # Element markup lives in templates/ and is overridable per
        # organization with Ruby.new(templates_dir:, assets_dir:) — no
        # code changes needed.
        class Ruby
          TEMPLATES_DIR = File.expand_path("templates", __dir__)
          ASSETS_DIR = File.expand_path("assets", __dir__)

          NISO = ::Sts::NisoSts
          TBX = ::Sts::TbxIsoTml

          # demodulized model class name → handler method. Anything not
          # listed renders its children transparently (see #render_children).
          # NisoSts is the canonical NISO STS namespace; TbxIsoTml covers
          # the terminology model and table cells.
          DISPATCH = {
            "MetadataIso" => :meta, "MetadataStd" => :meta,
            "RegMeta" => :meta, "NatMeta" => :meta,
            "Body" => :children,
            "Section" => :section, "App" => :section, "TermSection" => :section,
            "Label" => :label,
            "Title" => :title,
            "Standard" => :standard, "Adoption" => :standard,
            "Paragraph" => :paragraph,
            "List" => :list, "ListItem" => :list_item,
            "DefList" => :def_list, "Term" => :term, "Def" => :def_item,
            "TableWrap" => :table_wrap, "Table" => :table,
            "Thead" => :thead, "Tbody" => :tbody, "Tr" => :tr,
            "Td" => :td, "Th" => :th,
            "Figure" => :figure, "Caption" => :caption, "Graphic" => :graphic,
            "DisplayFormula" => :disp_formula, "InlineFormula" => :inline_formula,
            "Preformat" => :preformat,
            "NonNormativeNote" => :note, "NonNormativeExample" => :example,
            "DispQuote" => :quote,
            "ReferenceList" => :ref_list, "Reference" => :ref,
            "MixedCitation" => :citation, "ElementCitation" => :citation,
            "ReferenceStandard" => :std, "StandardIdentification" => :std_ident,
            "Originator" => :originator,
            "CopyrightStatement" => :copyright,
            "Fn" => :fn, "Xref" => :xref,
            "ExtLink" => :ext_link, "Uri" => :ext_link,
            "Break" => :brk, "ProcessingMeta" => :skip,
          }.freeze

          # Inline phrase-level elements → HTML tag (constant-keyed).
          # NisoSts for Monospace/Sub/Sup/Sc/Strike/Underline;
          # TbxIsoTml for Bold/Italic (terminology namespace).
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

          META_ID_NAMES = %w[StandardIdentification
                             StandardRef
                             DocumentIdentification].freeze

          PUBLISHER_NAME = "International Organization for Standardization (ISO)"
          PUBLISHER_ADDRESS = "ISO Central Secretariat · Chemin de Blandonnet 4, CP 401, 1214 Vernier, Geneva, Switzerland"

          def initialize(templates_dir: nil, assets_dir: nil, publisher_name: nil, publisher_address: nil, license_text: nil)
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

          # Render +model_or_xml+. With +full_document: true+ (default)
          # the fragment is assembled into a complete branded page;
          # with +full_document: false+ the bare fragment is returned.
          def render(model_or_xml, full_document: true)
            model = coerce_model(model_or_xml)
            @assemble = full_document
            @toc = []
            @depth = 0
            body = render_node(model)
            return body unless full_document

            assemble_document(body, model)
          end

          private

          attr_reader :templates_dir, :assets_dir

          # Accept either a parsed model or a raw XML string; the
          # latter is parsed via the sts-ruby typed model.
          def coerce_model(input)
            return input if input.is_a?(Lutaml::Model::Serializable)

            ::Sts::NisoSts::Standard.from_xml(input.to_s)
          end

          # --------------------------------------------------------------
          # Dispatch
          # --------------------------------------------------------------

          def render_node(node)
            case node
            when String then escape(node)
            when Mml::V3::Math then mathml_to_html(node)
            when *INLINE_TAGS.keys then render_inline_tag(node)
            else
              handler = DISPATCH[node.class.name.split("::").last]
              handler ? send(handler, node) : render_children(node)
            end
          end

          # Mml::V3::Math serializes with mml: prefix and compact
          # element spacing; MN HTML uses bare element names with
          # newlines between them. Strip the prefix and add newlines
          # so Nokogiri's text extraction produces the same whitespace
          # between MathML leaf elements.
          def mathml_to_html(node)
            node.to_xml.to_s
              .gsub(/<(\/?)mml:/, '<\1')
              .gsub(/\s+xmlns:mml="[^"]*"/, "")
              .gsub(/\s+xmlns:xlink="[^"]*"/, "")
              .gsub(/></, ">\n<")
          end

          # --------------------------------------------------------------
          # Handlers
          # --------------------------------------------------------------

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

          # First child model of +node+ whose demodulized class name
          # equals +demodulized+, in document order.
          def document_child(node, demodulized)
            mapping = @mapping_cache[node.class][:elements]
            node.element_order.each do |entry|
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
            # Boilerplate front-matter (Copyright, Feedback) renders as
            # a muted card; every other section renders uniformly with
            # its own heading — including unnumbered prose sections like
            # Foreword and Introduction.
            frontmatter = frontmatter_section?(sec_id, title_text)
            @depth += 1
            @current_section_id = sec_id
            inner = render_children(node)
            render_element("section", inner, id: sec_id, css: frontmatter ? "frontmatter" : nil)
          ensure
            @depth -= 1
            @current_section_id = previous_section_id
            @current_label = previous_label
          end

          # Only the boilerplate front-matter sections (copyright,
          # feedback) get the muted-card treatment. Other unnumbered
          # sections (Foreword, Introduction) render as normal sections.
          def frontmatter_section?(sec_id, title_text)
            return false unless @depth.zero? && @current_label.nil?
            return true if sec_id && %w[copyright feedback].include?(sec_id.downcase)

            title_match = TITLE_DOWNCASE_MAP[title_text.to_s.downcase]
            title_match == :frontmatter
          end

          TITLE_DOWNCASE_MAP = {
            "copyright" => :frontmatter,
            "feedback" => :frontmatter,
          }.freeze

          # The section's/list item's own <label> child model (nil when
          # absent or a bare string, e.g. TableWrap#label).
          def own_label(node)
            return nil unless node.class.attributes.key?(:label)

            label = node.label
            label if label.is_a?(Lutaml::Model::Serializable)
          end

          # Marks a label model as consumed by its container (section
          # heading prefix / list-item marker) so the generic label
          # handler does not render it a second time.
          def suppress_label(node)
            suppressed_labels[node] = true
          end

          def label_suppressed?(node)
            suppressed_labels.key?(node)
          end

          def suppressed_labels
            @suppressed_labels ||= {}.compare_by_identity
          end

          # Section's <title> child text, nil when absent.
          def extract_title(node)
            title_node = find_child(node, "Title")
            return nil unless title_node

            text = plain_text(title_node).gsub(/\s+/, " ").strip
            text.empty? ? nil : text
          end

          # Term sections (id starts with "term-") carry the term
          # number in <title> and the preferred name as the bold run
          # of the first <p>. For the TOC entry, append the preferred
          # name so the entry reads "3.1 NISO STS".
          def append_term_name(node, sec_id, title_text)
            return title_text unless sec_id&.start_with?("term-")
            return title_text if title_text.to_s.match?(/\s/)

            name = preferred_term_name(node)
            return title_text if name.nil? || name.empty?

            "#{title_text} #{name}"
          end

          # The preferred name is the bold run of the section's first
          # <p> child (the term heading paragraph). Returns nil when
          # the section is not a term section or the heading paragraph
          # is absent / has no bold run.
          def preferred_term_name(node)
            paragraph = find_child(node, "Paragraph")
            return nil unless paragraph

            bold = find_child(paragraph, "Bold")
            return nil unless bold

            text = plain_text(bold).gsub(/\s+/, " ").strip
            text.empty? ? nil : text
          end

          # Sections built without an id (e.g. front-matter sections)
          # get a slug from their title so they are linkable and can
          # appear in the TOC.
          def section_id(node)
            return node.id if node.id

            title_node = find_child(node, "Title")
            return nil unless title_node

            plain_text(title_node).gsub(/\s+/, " ").strip
              .downcase.gsub(/[^a-z0-9]+/, "-")
              .gsub(/\A-|-\z/, "")
          end

          # The display form of a section label: annex letters gain the
          # "Annex" prefix ("Annex A"), everything else renders bare.
          def display_label(node, label_text)
            return nil if label_text.nil? || label_text.empty?
            return "Annex #{label_text}" if node.class.name.split("::").last == "App"

            label_text
          end

          # Records the section in the interactive table of contents.
          # Apps are sections too; their titles come from the same walk.
          # The entry text carries the section number ("1 Scope").
          # Term sections (id starts with "term-") append the preferred
          # name (the bold text of the first <p>) so the entry reads
          # "3.1 NISO STS" instead of just "3.1".
          def register_toc(node, sec_id, title_text = nil)
            title_node = find_child(node, "Title")
            return unless sec_id && title_node

            label_node = own_label(node)
            label_text = display_label(node, label_node ? plain_text(label_node).gsub(/\s+/, " ").strip : nil)
            title_text ||= plain_text(title_node).gsub(/\s+/, " ").strip
            title_text = "#{label_text} #{title_text}" if label_text
            title_text = append_term_name(node, sec_id, title_text)
            register_toc_entry(id: sec_id, title: title_text, depth: @depth)
          end

          def register_toc_entry(id:, title:, depth:)
            @toc << { id: id, title: title, depth: depth }
          end

          # First direct child model whose demodulized class name matches.
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
            return "" if label_suppressed?(node)

            render_element("span", render_inline(node), css: "label")
          end

          def title(node)
            return render_element("em", render_inline(node)) if @in_std

            level = (1 + @depth).clamp(2, 4)
            anchor = if @current_section_id
                       %(<a class="h-anchor" href="##{@current_section_id}" aria-label="Link to this section">§</a>)
                     else
                       ""
                     end
            # The section number captured from its <label> prefixes the
            # heading ("1 Scope"); consumed so nested content never
            # inherits it.
            prefix = ""
            if @current_label && !@current_label.empty?
              prefix = %(<span class="sec-label">#{escape(@current_label)}</span> )
              @current_label = nil
            end
            render_element("h#{level}", prefix + render_inline(node) + anchor)
          end

          def paragraph(node) = render_element("p", render_inline(node), id: node.id)

          # A list whose items carry explicit <label> markers from the
          # source renders without HTML bullets — the label IS the
          # marker (mn-labeled-list); otherwise the browser's bullets
          # would duplicate the source's markers.
          def list(node)
            tag = node.list_type == "order" ? "ol" : "ul"
            css = labeled_list?(node) ? "mn-labeled-list" : nil
            render_element(tag, render_children(node), css: css)
          end

          def labeled_list?(node)
            return false unless node.class.attributes.key?(:list_item)

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

          # Table number + caption render as a caption band above the
          # table; the raw label/caption children are skipped so they
          # don't repeat inside the box.
          def table_wrap(node)
            inner = render_children(node, skip: %w[label caption])
            render_element("div", table_caption_line(node) + inner, css: "table-wrap")
          end

          def table_caption_line(node)
            label_text = node.class.attributes.key?(:label) ? node.label.to_s.strip : ""
            caption_node = node.caption if node.class.attributes.key?(:caption)
            title_node = caption_node.title if caption_node && caption_node.class.attributes.key?(:title)
            title_html = title_node ? render_inline(title_node) : ""
            return "" if label_text.empty? && title_html.empty?

            parts = []
            parts << %(<span class="tc-label">#{escape(label_text)}</span>) unless label_text.empty?
            parts << title_html unless title_html.empty?
            # NB: class is tbl-caption — "table-caption" collides with
            # Tailwind's own display utility (display: table-caption).
            %(<p class="tbl-caption">#{parts.join('<span class="tc-delim"> — </span>')}</p>)
          end

          # Render the table, then append a <tfoot> with one row per
          # footnote encountered in any cell. MN renders table-cell
          # footnotes this way (one <td> per footnote in <tfoot>), so
          # the body text appears as a matchable cell instead of being
          # deferred to end-of-document like paragraph footnotes.
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
            render_liquid("_img.html.liquid", {
                            "src" => node.href.to_s,
                            "alt" => node.alttext.to_s,
                          })
          end

          def disp_formula(node) = render_element("div", render_inline(node), css: "formula")

          def inline_formula(node) = render_element("span", render_inline(node), css: "formula")

          def preformat(node) = render_element("pre", render_inline(node))

          # Notes carrying their own label (term notes, "Note 1 to
          # entry: …") render the label inside the first paragraph, the
          # way Metanorma marks up term notes; plain notes get the kind
          # label ("NOTE") — also injected inside the first <p> so it
          # appears in the same text node MN produces for parity.
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

          # A ref-list with a title (the back-matter bibliography) gets a
          # TOC entry and an anchor; an untitled one (e.g. the normative
          # references list nested in its numbered section) stays
          # anonymous — the enclosing section carries the TOC entry.
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

          # A ref with a structured <std> renders label + std (std-ref
          # and title); the plain mixed-citation is skipped to avoid
          # repeating the same reference three times. The label sits
          # inside the body <p> — a reference reads "[1] Citation…".
          def ref(node)
            # Prefer the structured <std> child (std-ref + title joined
            # by ", " — the NISO STS citation idiom) when present; it
            # carries the same text as mixed-citation without duplication.
            std_node = find_model(node, "ReferenceStandard")
            content = std_node ? render_node(std_node) : render_children(node, skip: %w[label])
            body = render_element("p", ref_label(node) + content, css: "ref-body")
            render_element("div", body, css: "ref")
          end

          def ref_label(node)
            label_node = find_model(node, "Label")
            return "" unless label_node

            render_element("span", render_inline(label_node), css: "label") + " "
          end

          # First typed model in the tree whose demodulized class name
          # equals +demodulized+, depth-first.
          def find_model(node, demodulized)
            found = nil
            walk_models(node) do |model|
              found ||= model if model.class.name.split("::").last == demodulized
            end
            found
          end

          def citation(node) = render_element("span", render_inline(node), css: "citation")

          # <std> inside a bibliography ref: keep everything inline —
          # titles become <em>, never headings. std-ref and title join
          # with the NISO STS citation idiom ", ". NisoSts stores
          # title as a bare String on ReferenceStandard (not as a
          # separate Title model), so we read it via #title and escape.
          def std(node)
            @in_std = true
            parts = []
            ref_node = find_model(node, "StandardRef")
            parts << render_element("span", render_inline(ref_node), css: "std-ref") if ref_node
            title_str = node.title if node.class.attributes.key?(:title)
            parts << render_element("em", escape(title_str.to_s)) if title_str && !title_str.to_s.empty?
            render_element("span", parts.join(", "), css: "std")
          ensure
            @in_std = false
          end

          def std_ident(node) = render_element("span", render_inline(node), css: "std-ident")

          # <originator> inside std-ref: separated, quieter.
          def originator(node) = render_element("span", render_inline(node), css: "originator")

          def doc_id(node) = render_element("span", render_inline(node), css: "doc-id")

          def copyright(node) = render_element("span", render_inline(node), css: "copyright")

          # Fn inside a paragraph renders as an inline <sup> marker only
          # (the body paragraphs are already rendered as the fn's
          # children — but block-level <div> inside <p> breaks the
          # paragraph in HTML parsers, so we keep just the marker when
          # Fn inside a paragraph: render inline <sup> marker only.
          # The fn body paragraphs are collected in @deferred_footnotes
          # and rendered at the end of the document so they become
          # matchable <p> elements (block <p> inside inline context
          # breaks HTML parsers). Fn inside a table cell routes the
          # body to the enclosing table's <tfoot> instead (see #table),
          # matching MN's table-footnote layout and avoiding duplicate
          # rendering at end of document.
          def fn(node)
            label_node = own_label(node)
            suppress_label(label_node) if label_node
            label_text = label_node ? plain_text(label_node).strip : ""
            display_label = label_text.match?(/\A\d+\z/) ? "#{label_text})" : label_text
            # NisoSts::Fn stores paragraphs in #paragraph; TbxIsoTml::Fn
            # stores them in #p. Accept either so the renderer handles
            # footnotes from paragraphs and table cells uniformly.
            fn_paragraphs = if node.class.attributes.key?(:paragraph)
                               Array(node.paragraph)
                             elsif node.class.attributes.key?(:p)
                               Array(node.p)
                             else
                               []
                             end
            body_parts = fn_paragraphs.map { |para| plain_text(para) }
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
            render_link(href: node.href, text: inline_or_content(node))
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

            title = find_text(node, ["TitleWrap", "Title"])
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

          # --------------------------------------------------------------
          # Walking (document-order traversal of the typed model)
          # --------------------------------------------------------------

          # Children of a non-mixed container in document order.
          # Repeated elements of a collection appear as one element_order
          # entry PER ITEM, so collection items are consumed one entry at
          # a time (per-attribute index counters). +skip+ lists element
          # names the caller renders itself (e.g. table-wrap's label and
          # caption, which become the caption band).
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

          # Mixed-content (inline) walk; non-mixed models route back to
          # the ordered walk.
          def render_inline(node)
            return render_children(node) unless mixed_model?(node)

            node.each_mixed_content.filter_map do |child|
              rendered = child.is_a?(String) ? escape(child) : render_node(child)
              rendered unless rendered.empty?
            end.join
          end

          def mixed_model?(node)
            @mapping_cache[node.class][:mixed]
          end

          # element name → attribute name + mixed-content flag, per model
          # class (cached).
          def build_mapping(klass)
            return { elements: {}, mixed: false } unless klass.respond_to?(:mappings_for)

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

          def collection_item_at(node, attr, indices)
            value = node.public_send(attr)
            return value unless value.is_a?(Array)

            item = value[indices[attr]]
            indices[attr] += 1
            item
          end

          # --------------------------------------------------------------
          # Document assembly (full page)
          # --------------------------------------------------------------

          def assemble_document(body, model)
            meta = meta_info(model)
            footnotes = deferred_footnotes_html
            title_p = body_title_paragraph(meta)
            render_liquid("document.html.liquid", {
                            "lang" => "en",
                            "title" => meta[:title],
                            "css" => stylesheet,
                            "logo_light" => logo_svg_light,
                            "logo_dark" => logo_svg_dark,
                            "docid" => meta[:docid],
                            "toc" => toc_html,
                            "hero" => hero_html(meta),
                            "content" => title_p + body + footnotes,
                            "footer" => footer_html(meta),
                            "js" => javascript,
                          })
          end

          # MN renders the document title as a <p class="zzSTDTitle1">
          # at the start of the body. Emitting a matching paragraph
          # keeps the title in the parity check's paragraph set.
          def body_title_paragraph(meta)
            return "" if meta[:title].to_s.empty?

            render_element("p", escape(meta[:title]), css: "doc-title")
          end

          # Deferred footnotes collected from fn() calls during rendering.
          # Each fn body becomes a matchable <p> at the end of the document.
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
            chips << "Series #{meta[:series]}" unless meta[:series].empty?
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
                            "version" => ::Metanorma::Iso::Sts::VERSION,
                            "mn_icon_light" => metanorma_icon_light,
                            "mn_icon_dark" => metanorma_icon_dark,
                          })
          end

          # Metanorma icon (aequitate verum) in light/dark variants,
          # from metanorma.org.
          def metanorma_icon_light
            @mn_icon_light ||= File.read(File.join(assets_dir, "metanorma-icon-light.svg"))
              .sub(/\A<\?xml[^?]*\?>\s*/, "")
          end

          def metanorma_icon_dark
            @mn_icon_dark ||= File.read(File.join(assets_dir, "metanorma-icon-dark.svg"))
              .sub(/\A<\?xml[^?]*\?>\s*/, "")
          end

          # Flat TOC list with depth classes (indented via CSS); consumed
          # by the scroll-spy script in the page.
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
              year: find_text(meta_node, ["CopyrightYear", "PubDate", "Year"]),
              series: doc_series(meta_node),
              copyright: find_text(meta_node, ["CopyrightStatement"]),
              holder: find_text(meta_node, ["CopyrightHolder"]) }
          end

          # NisoSts TitleWrap stores the title parts as bare Strings
          # (main:, intro:, compl:, full:) rather than as typed Title
          # model children, so plain_text on the wrap returns "".
          # Prefer main, then fall back to compl / full / intro, then
          # fall back to the generic find_text walk for older layouts.
          def title_text(meta_node)
            wrap = find_model(meta_node, "TitleWrap")
            return find_text(meta_node, ["Title"]) unless wrap

            %i[main compl full intro].each do |attr|
              next unless wrap.class.attributes.key?(attr)
              val = wrap.public_send(attr)
              val = val.text if val.respond_to?(:text) && !val.text.nil?
              return val.to_s.strip unless val.to_s.strip.empty?
            end
            find_text(meta_node, ["Title"])
          end

          # Display form of the document identifier, rebuilt from the
          # decomposed <std-ident> parts ("OIML" + "x" + "999" →
          # "OIML X 999"), dated with the copyright year
          # ("OIML X 999:2026"). Falls back to raw text extraction when
          # the std-ident carries no originator (legacy/other layouts).
          def doc_id(meta_node)
            std_ident = find_model(meta_node, "StandardIdentification")
            return find_text(meta_node, META_ID_NAMES) unless std_ident

            originator = find_text(std_ident, %w[Originator])
            return find_text(meta_node, META_ID_NAMES) if originator.empty?

            parts = [originator,
                     find_text(std_ident, %w[DocType]).upcase,
                     find_text(std_ident, %w[DocNumber])].reject(&:empty?)
            id = parts.join(" ")
            part_number = find_text(std_ident, %w[PartNumber])
            id += "-#{part_number}" unless part_number.empty?
            year = find_text(meta_node, %w[CopyrightYear])
            id += ":#{year}" if !id.empty? && year.match?(/\A\d{4}\z/)
            id
          end

          # The oiml-doc-series letter recorded in
          # <custom-meta name="oiml-doc-series"> (X 999 §4).
          def doc_series(meta_node)
            series = ""
            walk_models(meta_node) do |model|
              next unless model.instance_of?(::Sts::NisoSts::CustomMeta)

              name = model.class.attributes.key?(:meta_name) ? model.meta_name.to_s : ""
              value = model.class.attributes.key?(:meta_value) ? model.meta_value.to_s : ""
              series = value if name == "oiml-doc-series" && !value.empty?
            end
            series
          end

          # Yields every typed model in the tree, depth-first.
          def walk_models(node, &block)
            return unless node.is_a?(Lutaml::Model::Serializable)

            yield node
            node.class.attributes.each_value do |attr_def|
              Array(node.public_send(attr_def.name)).compact.each do |child|
                walk_models(child, &block) if child.is_a?(Lutaml::Model::Serializable)
              end
            end
          end

          # First metadata block found under the document front matter.
          # Recognises any subclass of the NisoSts metadata containers
          # (MetadataIso → <iso-meta>, MetadataStd → <std-meta>) via
          # is_a?, so OIML (or any other future subclass) is picked up
          # without extending a hard-coded class-name list.
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
            node.is_a?(::Sts::NisoSts::MetadataIso) ||
              node.is_a?(::Sts::NisoSts::MetadataStd)
          end

          def stylesheet
            @stylesheet ||= File.read(File.join(assets_dir, "theme.css"))
          end

          # Light- and dark-mode logo variants (theme picks visibility).
          # Uses the Metanorma brand icons for the ISO flavor.
          def logo_svg_light
            @logo_svg_light ||= read_asset("metanorma-icon-light.svg")
          end

          def logo_svg_dark
            @logo_svg_dark ||= read_asset("metanorma-icon-dark.svg")
          end

          def read_asset(name)
            File.read(File.join(assets_dir, name))
              .sub(/\A<\?xml[^?]*\?>\s*/, "")
          end

          # Page behaviour: scroll-spy TOC, mobile TOC drawer, back-to-top,
          # heading-anchor copy. Vanilla JS, no dependencies.
          def javascript
            @javascript ||= File.read(File.join(assets_dir, "page.js"))
          end

          # --------------------------------------------------------------
          # Text extraction
          # --------------------------------------------------------------

          # First non-empty plain text under the node whose demodulized
          # class name is in +names+.
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

          # --------------------------------------------------------------
          # Liquid emitters
          # --------------------------------------------------------------

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
              # chomp: template files must not contribute their own
              # trailing newline into the output (it surfaces as a
              # visible space between inline elements)
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
