# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <keyword> as a bold + small-caps run.
        class KeywordRenderer
          include Base

          def render(element, para)
            text = parent.collect_text(element)
            return if text.nil? || text.empty?

            run = Uniword::Builder::RunBuilder.new
            run.text(text).bold.small_caps
            para << run.build
          end
        end
      end
    end
  end
end
