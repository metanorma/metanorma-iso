# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <tt> / <monospace> as a run with the InlineCode
        # character style (Era C). The styleId flows from
        # style_mapping.yml via StyleResolver.
        class MonospaceRenderer
          include Base

          def render(element, para)
            text = parent.collect_text(element)
            return if text.nil? || text.empty?

            parent.add_text_with_char_style(para, text, :inline_code)
          end
        end
      end
    end
  end
end
