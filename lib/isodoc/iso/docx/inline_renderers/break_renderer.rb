# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders an inline <br/> as a Word break run (<w:r><w:br/></w:r>).
        class BreakRenderer
          include Base

          def render(_element, para)
            run = Uniword::Wordprocessingml::Run.new
            run.break = Uniword::Wordprocessingml::Break.new
            para << run
          end
        end
      end
    end
  end
end
