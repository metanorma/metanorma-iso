# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders inline stem (formula) content.
        #
        # Stems carrying MathML are converted to an inline OMML equation
        # (oMath) via MathConversion — the same Plurimath pipeline block
        # formulas use — so the equation appears in Word exactly once as
        # a native formula. When conversion fails (no MathML, unsupported
        # content), the stem falls back to a text run with the Stem
        # character style.
        class StemRenderer
          include Base

          def render(element, para)
            return if render_number_as_text(element, para)
            return if render_as_omml(element, para)

            render_as_text(element, para)
          end

          private

          # 1.17.0 parity: a stem consisting of a bare number renders as
          # a plain text run — an OMML object for a bare digit reads as
          # math styling inside prose and table cells (metanorma-iso#1764).
          # Returns true when the paragraph received the number.
          def render_number_as_text(element, para)
            digits = parent.number_only_stem_text(element)
            return false unless digits

            parent.add_text(para, digits)
            true
          end

          # Append the stem's MathML as inline OMML equation models.
          # Returns true when the paragraph received the equation.
          def render_as_omml(element, para)
            omaths = parent.inline_omath_models(element)
            return false unless omaths

            omaths.each { |omath| para << omath }
            true
          rescue StandardError
            false
          end

          # Text fallback: the stem's AsciiMath (or MathML-derived)
          # textual representation with the Stem character style.
          def render_as_text(element, para)
            text = parent.stem_fallback_text(element)
            return if text.nil? || text.empty?

            parent.add_text_with_char_style(para, text, :stem)
          rescue StandardError
            nil
          end
        end
      end
    end
  end
end
