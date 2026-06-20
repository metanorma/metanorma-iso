# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a Terms section (clause containing term entries). The
        # title uses Heading1 style regardless of nested depth because
        # terms sections are always top-level document sections.
        class TermsSectionRenderer < SectionRenderer
          def title_style_for(_section)
            @resolver.heading_style(1)
          end
        end
      end
    end
  end
end
