# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders inline stem (formula) content. A stem carrying MathML
        # renders as inline OMML (<m:oMath> inside the paragraph), the
        # inline counterpart of FormulaRenderer's <m:oMathPara>.
        #
        # Text fallback (Stem character style) is kept where the submitted
        # ISO Word output uses text, or OMML is unavailable:
        # - number-only MathML (<mn> tokens): plain text in the reference;
        # - MathML with no visible text (an empty <mi/>): no blank oMath;
        # - headings (UnitsML stems included): title text, see
        #   InlineRenderer#rendering_heading?;
        # - no MathML, or Plurimath cannot convert it.
        class StemRenderer
          include Base
          include MathmlOmml

          # Elements that never carry a visible token of their own.
          NON_TOKEN_ELEMENTS = %w[math mrow semantics mstyle annotation mspace].freeze

          def render(element, para)
            return if render_omml(element, para)

            render_text(element, para)
          end

          private

          def render_omml(element, para)
            mathml = omml_candidate(element)
            return false unless mathml

            o_maths = cached_omml(mathml)
            return false if o_maths.empty?

            o_maths.each { |o_math| para << o_math }
            true
          rescue StandardError
            false
          end

          # Plurimath plus Omml.parse cost ~26 ms a stem; ISO 2533 has 957
          # non-numeric stems but only 236 distinct ones. The oMath objects
          # are only serialized, so paragraphs can share them.
          def cached_omml(mathml)
            @omml_cache ||= {}
            @omml_cache[mathml] ||= convert_to_omml_inline(mathml)
          end

          def omml_candidate(element)
            return nil if parent.rendering_heading?

            mathml = extract_mathml_from_stem(element)
            return nil if blank?(mathml) || numeric_only?(mathml)

            mathml
          end

          def blank?(mathml)
            mathml.nil? || mathml.gsub(/<[^>]*>/, "").strip.empty?
          end

          # MathML whose only token elements are <mn>: a bare number.
          def numeric_only?(mathml)
            tokens = mathml.scan(/<(?:\w+:)?(m[a-z]+)\b/).flatten - NON_TOKEN_ELEMENTS
            tokens.all?("mn")
          end

          def render_text(element, para)
            text = parent.stem_fallback_text(element)
            return if text.nil? || text.empty?

            parent.add_text_with_char_style(para, text, :stem)
          end
        end
      end
    end
  end
end
