# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders an inline <tab/> as a Word tab run.
        class TabRenderer
          include Base

          def render(_element, para)
            run = Uniword::Wordprocessingml::Run.new
            run.tab = Uniword::Wordprocessingml::Tab.new
            para << run
          end
        end
      end
    end
  end
end
