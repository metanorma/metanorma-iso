# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a regular body clause. Tracks section depth so headings
        # nest correctly via the resolver's heading_style(depth) lookup.
        class ClauseRenderer < Renderers::SectionRenderer
          def around_section(_section, _doc)
            @context.section_depth += 1
            yield
          ensure
            @context.section_depth -= 1
          end

          def title_style_for(_section)
            if @context.in_introduction && @context.section_depth == 1
              style = @resolver.paragraph_style(:annex_heading2)
              return style if style
            end

            depth = [@context.section_depth, 6].min
            @resolver.heading_style(depth)
          end
        end
      end
    end
  end
end
