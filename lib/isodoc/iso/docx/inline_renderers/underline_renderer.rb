# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <underline> as an underline run.
        class UnderlineRenderer
          include Base

          def render(element, para)
            text = parent.collect_text(element)
            return if text.nil? || text.empty?

            run = Uniword::Builder::RunBuilder.new
            run.text(text).underline
            para << run.build
          end
        end
      end
    end
  end
end
