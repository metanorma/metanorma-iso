# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a ParagraphBlock: applies style resolution, context-aware
        # body styling, and inline content.
        #
        # Skips body-level title paragraphs (class "zzSTDTitle" /
        # "zzSTDTitle1") because the presentation XML may inject them as
        # duplicates of the cover-page title. The adapter emits the
        # canonical middle-title paragraph itself (Adapter#render_middle_title).
        #
        # When a paragraph carries block-level children (e.g. <note>
        # embedded mid-paragraph, as the presentation XML does for notes
        # attached to a sentence), the renderer splits the paragraph at
        # each block boundary: inline content before the block becomes a
        # paragraph; the block is dispatched as a sibling through the
        # Adapter's walker; inline content after the block becomes a new
        # paragraph with the same style. This is required because OOXML
        # cannot nest a block inside a paragraph.
        class ParagraphRenderer
          include Base
          include ModelUtils

          # Class attribute pattern matching body-level title paragraphs
          # that the presentation XML injects as duplicates of the cover
          # title. The adapter emits its own zzSTDTitle paragraph from
          # bibdata; any XML-injected copy must be suppressed.
          BODY_TITLE_CLASS_PATTERN = /\AzzSTDTitle\d?\z/

          # Block element classes that may appear inside a <p> in the
          # presentation XML. When encountered, the renderer splits the
          # paragraph and dispatches the block as a sibling. Adding a
          # new embeddable block type = adding its class here (OCP).
          BLOCK_ELEMENT_CLASSES = [
            Metanorma::Document::Components::Blocks::NoteBlock,
          ].freeze

          def render(paragraph, doc)
            return if body_title_paragraph?(paragraph)

            if block_child?(paragraph)
              render_split(paragraph, doc)
            else
              render_simple(paragraph, doc)
            end
          end

          private

          def render_simple(paragraph, doc)
            para = build_unstyled_paragraph
            apply_style(para, paragraph)
            apply_alignment(para, paragraph)
            @inline_renderer.render(paragraph, para)
            @context.mark_zone_paragraph
            doc << para
          end

          # Walk +paragraph+'s element_order, accumulating inline content
          # into the current paragraph. When a block element is hit,
          # flush the current paragraph (if non-empty) and dispatch the
          # block as a sibling. Each contiguous inline run picks up the
          # same paragraph style and alignment as the original <p>.
          def render_split(paragraph, doc)
            state = { current: nil, paragraph: paragraph }
            each_ordered_element(paragraph) do |type, obj|
              dispatch_split_element(type, obj, state, doc)
            end
            flush_split(state, doc)
          end

          def dispatch_split_element(type, obj, state, doc)
            case type
            when :text then append_split_text(obj, state)
            when :element then dispatch_split_element_node(obj, state, doc)
            end
          end

          def append_split_text(text, state)
            return if text.nil? || text.empty?

            state[:current] ||= new_paragraph(state[:paragraph])
            @inline_renderer.add_text(state[:current], text)
          end

          def dispatch_split_element_node(element, state, doc)
            if block_element?(element)
              flush_split(state, doc)
              @walker.dispatch(element, doc)
            else
              state[:current] ||= new_paragraph(state[:paragraph])
              @inline_renderer.dispatch_inline(element, state[:current])
            end
          end

          def flush_split(state, doc)
            return unless state[:current]

            flush_paragraph(state[:current], doc)
            state[:current] = nil
          end

          def new_paragraph(paragraph)
            para = build_unstyled_paragraph
            apply_style(para, paragraph)
            apply_alignment(para, paragraph)
            para
          end

          def flush_paragraph(para, doc)
            @context.mark_zone_paragraph
            doc << para
          end

          def block_child?(paragraph)
            return false unless ordered?(paragraph)

            paragraph.element_order.any? do |node|
              node.element? && element_is_block?(paragraph, node)
            end
          end

          def element_is_block?(paragraph, element_node)
            attr_name = attribute_name_for_element(paragraph, element_node.name)
            return false unless attr_name

            value = paragraph.public_send(attr_name)
            return false unless value

            values = Array(value)
            values.any? { |v| block_element?(v) }
          end

          def block_element?(obj)
            BLOCK_ELEMENT_CLASSES.any? { |klass| obj.is_a?(klass) }
          end

          def attribute_name_for_element(node, element_name)
            mapping = build_element_mapping(node)
            mapping&.[](element_name)
          end

          def apply_style(para, paragraph)
            explicit = resolve_paragraph_style(paragraph)
            para.style = explicit if explicit
            return if explicit

            context_style = @resolver.context_body_style
            para.style = context_style if context_style
          end

          def apply_alignment(para, paragraph)
            return unless paragraph.class.attributes.key?(:alignment)
            return unless paragraph.alignment

            para.align = paragraph.alignment
          end

          def resolve_paragraph_style(node)
            cls = node.class_attr
            return @resolver.paragraph_style(cls.to_sym) if cls

            return nil unless node.class.attributes.key?(:type)

            type = node.type
            return nil unless type == "floating-title"

            depth = (node.depth || 1).to_i
            @resolver.heading_style(depth)
          end

          def body_title_paragraph?(node)
            return false unless node.class.attributes.key?(:class_attr)

            cls = node.class_attr
            return false if cls.nil?

            BODY_TITLE_CLASS_PATTERN.match?(cls.to_s)
          end
        end
      end
    end
  end
end
