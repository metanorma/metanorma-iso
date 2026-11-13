# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <asciimath> as a text run with the Stem character style.
        class AsciimathRenderer
          include Base

          def render(element, para)
            return unless element.class.attributes.key?(:text)

            text = element.text
            return unless text.is_a?(String) && !text.empty?

            parent.add_text_with_char_style(para, text, :stem)
          end
        end
      end
    end
  end
end
