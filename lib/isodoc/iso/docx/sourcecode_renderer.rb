# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders sourcecode blocks, preserving code text, syntax-highlight
      # spans, and callout markers in their original document order.
      #
      # Each sourcecode block becomes one Code-styled paragraph with line
      # breaks (w:br) between lines. Callouts inside the code are rendered
      # as superscript "(N)" runs. Callout annotations are emitted as
      # separate paragraphs after the code paragraph.
      #
      # The renderer prefers the structured `fmt_sourcecode` element over
      # `body` (which captures raw XML including callout markup as text).
      class SourcecodeRenderer
        include ModelUtils

        # Inline-level element types to skip when walking fmt_sourcecode.
        # These are block elements that have their own rendering paths
        # (e.g., the callout key dl).
        BLOCK_ELEMENT_TYPES = [
          Metanorma::Document::Components::Lists::DefinitionList,
          Metanorma::Document::Components::Paragraphs::ParagraphBlock,
        ].freeze

        def initialize(resolver, inline_renderer)
          @resolver = resolver
          @inline = inline_renderer
        end

        def render(sourcecode, doc)
          render_code_paragraph(sourcecode, doc)
          render_callout_annotations(sourcecode, doc)
        end

        private

        def render_code_paragraph(sourcecode, doc)
          source = preferred_source(sourcecode)
          return unless source

          para = Uniword::Builder::ParagraphBuilder.new
          style = @resolver.paragraph_style(:sourcecode)
          para.style = style if style

          @inline.preserve_whitespace = true
          render_code_content(source, para)
          @inline.preserve_whitespace = false

          doc << para
        end

        # Prefer the structured fmt_sourcecode (which exposes spans and
        # callouts as model objects) over body (which captures everything
        # as a raw XML string, including escaped callout markup).
        def preferred_source(sourcecode)
          if sourcecode.class.attributes.key?(:fmt_sourcecode) && sourcecode.fmt_sourcecode
            return sourcecode.fmt_sourcecode
          end
          if sourcecode.class.attributes.key?(:body) && sourcecode.body
            return sourcecode.body
          end
          sourcecode if sourcecode.class.attributes.key?(:content)
        end

        def render_code_content(source, para)
          if ordered?(source)
            render_ordered_code(source, para)
          else
            render_plain_code(source, para)
          end
        end

        def render_ordered_code(source, para)
          each_ordered_element(source) do |type, obj|
            case type
            when :text then @inline.add_text(para, obj)
            when :element then render_code_element(obj, para)
            end
          end
        end

        def render_plain_code(source, para)
          text = source.text if source.class.attributes.key?(:text)
          text ||= source.content if source.class.attributes.key?(:content)
          @inline.add_text(para, text.to_s) if text && !text.to_s.empty?
        end

        def render_code_element(element, para)
          return if block_element?(element)

          @inline.render_inline_element(element, para)
        end

        def block_element?(element)
          BLOCK_ELEMENT_TYPES.any? { |type| element.is_a?(type) }
        end

        def render_callout_annotations(sourcecode, doc)
          return unless sourcecode.class.attributes.key?(:callout_annotations)

          annotations = sourcecode.callout_annotations
          return if annotations.nil? || annotations.empty?

          Array(annotations).each do |annotation|
            render_annotation(annotation, doc)
          end
        end

        def render_annotation(annotation, doc)
          return unless annotation.class.attributes.key?(:p)

          Array(annotation.p).each do |p|
            para = Uniword::Builder::ParagraphBuilder.new
            style = annotation_style
            para.style = style if style
            @inline.render(p, para)
            doc << para
          end
        end

        def annotation_style
          @resolver.paragraph_style(:sourcecode)
        end
      end
    end
  end
end
