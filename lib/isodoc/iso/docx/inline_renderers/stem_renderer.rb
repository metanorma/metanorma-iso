# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders inline stem (formula) content as a text run with the
        # Stem character style. MathML content cannot be rendered inline
        # in this codepath (block formulas go through FormulaRenderer);
        # we fall back to the stem's ascimath/textual representation.
        class StemRenderer
          include Base

          def render(element, para)
            text = parent.stem_fallback_text(element)
            return if text.nil? || text.empty?

            parent.add_text_with_char_style(para, text, :stem)
          rescue StandardError
            text = parent.stem_fallback_text(element)
            return if text.nil? || text.empty?

            parent.add_text_with_char_style(para, text, :stem)
          end
        end
      end
    end
  end
end
