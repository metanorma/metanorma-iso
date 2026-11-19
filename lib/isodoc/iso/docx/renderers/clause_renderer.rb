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
            depth = [@context.section_depth, 6].min
            introduction_clause_style || @resolver.heading_style(depth)
          end

          private

          def introduction_clause_style
            return unless @context.in_introduction && @context.section_depth == 1

            @resolver.paragraph_style(:annex_heading2)
          end

          def render_title_content(title, para)
            return super unless introduction_clause_style

            # numId 0 cancels the annex numbering inherited from a2.
            para.numbering(0)
            @inline_renderer.with_heading do
              @inline_renderer.render(title, para)
            end
          end
        end
      end
    end
  end
end
