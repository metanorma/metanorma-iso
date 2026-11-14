# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Shared layout helpers for renderers that present a labelled
      # block (Note, Example, Admonition).
      #
      # Two layout contracts live here:
      #
      # [Era C box] (+with_box+) — Box-begin / Box-title / Box-end
      #   paragraphs draw a grey box around the content. Admonitions
      #   (caution, warning, important) keep this look.
      #
      # [XSL inline label] (+with_inline_label+) — mirrors the
      #   iso.international-standard.xsl NOTE/EXAMPLE contract: the
      #   label ("NOTE 1", "EXAMPLE") runs inline at the head of the
      #   first body paragraph — no border, no shading, no separate
      #   title paragraph. When the first child is not a plain
      #   paragraph (table, definition list, sourcecode first, ...),
      #   the label gets its own keep-with-next paragraph, mirroring
      #   the XSL "block" mode where the name is displayed as a
      #   separate block (example-name-style keep-with-next="always").
      module BoxWrapper
        include ModelUtils

        # Gap between the label and the body. The XSL reserves
        # padding-right on the label inline (6mm for notes, 5mm for
        # examples); a single space keeps the ragged inline flow —
        # wrapped lines return to the left margin, as in the PDF.
        LABEL_GAP = " "

        # Model classes whose presence anywhere in a block forces the
        # XSL "block" mode for EXAMPLES (.//table or .//dl) and makes a
        # paragraph unsuitable for inline-label merging. Sourcecode as
        # the FIRST child triggers block mode in the XSL as well.
        BLOCK_CHILD_CLASSES = [
          Metanorma::Document::Components::Tables::TableBlock,
          Metanorma::Document::Components::Lists::DefinitionList,
        ].freeze

        PLAIN_PARAGRAPH_CLASS =
          Metanorma::Document::Components::Paragraphs::ParagraphBlock

        # Attributes carrying the rendered label ("NOTE 1", "EXAMPLE")
        # and its cross-reference label. The XSL treats these specially
        # (label inline / name block), so they are never part of the
        # block-child walk.
        LABEL_ATTRS = %i[fmt_name fmt_xref_label name].freeze

        # Yield a block that appends body paragraphs to +doc+.
        # Wraps the block's output with Box-begin before and Box-end after.
        # If +title_text+ is provided, inserts a Box-title paragraph
        # before the body.
        def with_box(doc, title_text: nil)
          doc << box_paragraph(:box_begin)
          append_box_title(doc, title_text)
          yield
          doc << box_paragraph(:box_end)
        end

        # Inline-label layout for the XSL note/example contract.
        #
        # +style_key+ is the paragraph style for the label-carrying
        # first paragraph (full width — the XSL renders the first
        # body element inline after the label at the container margin).
        def with_inline_label(node, doc, style_key)
          children = block_children(node)
          first = children.first

          if inline_label_paragraph?(children)
            para = build_paragraph(style_key)
            append_label(para, label_text(node))
            @inline_renderer.render(first, para)
            @context.mark_zone_paragraph
            doc << para
            children.drop(1).each { |child| @walker.dispatch(child, doc) }
          else
            # XSL block mode: name in its own keep-with-next block,
            # body content follows (indented via the zone body styles).
            label_para = build_paragraph(style_key)
            append_label(label_para, label_text(node))
            label_para.keep_next
            doc << label_para
            children.each { |child| @walker.dispatch(child, doc) }
          end
        end

        # Extract a title from +node+'s fmt-name attribute and render
        # it as a Box-title paragraph. No-op when the node has no
        # fmt-name or its text is empty.
        def append_title_from_fmt_name(node, doc)
          fmt = attribute_value(node, :fmt_name)
          return unless fmt

          text = collect_all_text(fmt).to_s.strip
          append_box_title(doc, text)
        end

        private

        # True when the label can run inline into the first child:
        # the first child must be a plain paragraph (no embedded block
        # children — OOXML cannot nest a block inside a paragraph, and
        # ParagraphRenderer's split path must stay in charge there),
        # and the note/example must not force XSL block mode via a
        # nested table or definition list.
        def inline_label_paragraph?(children)
          first = children.first
          return false unless first.is_a?(PLAIN_PARAGRAPH_CLASS)
          return false if embedded_block_child?(first)
          return false if block_forcing_child?(children)

          true
        end

        def block_forcing_child?(children)
          children.any? do |child|
            BLOCK_CHILD_CLASSES.any? { |klass| child.is_a?(klass) }
          end
        end

        def embedded_block_child?(paragraph)
          return false unless ordered?(paragraph)

          mapping = build_element_mapping(paragraph)
          paragraph.element_order.any? do |el|
            next false unless el.element?

            attr = mapping[el.name]
            next false unless attr

            Array(paragraph.public_send(attr)).any? do |value|
              Renderers::ParagraphRenderer::BLOCK_ELEMENT_CLASSES
                .any? { |klass| value.is_a?(klass) }
            end
          end
        end

        def label_text(node)
          fmt = attribute_value(node, :fmt_name)
          text = fmt ? collect_all_text(fmt).to_s.strip : ""
          text.empty? ? nil : text
        end

        def append_label(para, text)
          return unless text

          para << (text + LABEL_GAP)
        end

        # Element children of +node+ in document order (text nodes and
        # label attributes skipped — this is a block-level walk). Mirrors
        # ModelUtils#each_ordered_element's collection indexing, and adds
        # the label-attribute exclusion the shared walk does not need.
        def block_children(node)
          return [] unless ordered?(node)

          mapping = build_element_mapping(node)
          indices = Hash.new(0)
          children = []
          node.element_order.each do |el|
            next unless el.element?

            attr = mapping[el.name]
            next unless attr
            next if LABEL_ATTRS.include?(attr.to_sym)

            coll = node.public_send(attr)
            obj = if coll.is_a?(Array)
                    idx = indices[attr]
                    indices[attr] += 1
                    coll[idx]
                  else
                    coll
                  end
            children << obj if obj
          end
          children
        end

        def append_box_title(doc, title_text)
          return if title_text.nil? || title_text.to_s.empty?

          title_para = box_paragraph(:box_title)
          title_para << title_text.to_s
          doc << title_para
        end

        def box_paragraph(key)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(key)
          para
        end
      end
    end
  end
end
