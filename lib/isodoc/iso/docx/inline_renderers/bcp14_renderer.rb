# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <bcp14> (BCP 14 RFC keyword) as bold text, since BCP14
        # elements always wrap a single keyword string with no nesting.
        class Bcp14Renderer
          include Base

          def render(element, para)
            text = parent.collect_text(element)
            return if text.nil? || text.to_s.empty?

            run = Uniword::Builder::RunBuilder.new
            run.text(text.to_s).bold
            para << run.build
          end
        end
      end
    end
  end
end
