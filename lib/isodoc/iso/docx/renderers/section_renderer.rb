# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Base class for section-like content (clauses, annexes, terms
        # sections, references). All sections share the same skeleton:
        #
        #   1. Optional pre-render hook (e.g., page break for annexes)
        #   2. Render the title as a styled paragraph with a bookmark
        #   3. Walk children via @walker
        #
        # Subclasses customize behavior by overriding template methods:
        #   - +#around_section+ — wraps the whole render (zone, depth)
        #   - +#title_style_for(section)+ — picks the heading style
        #
        # Open/Closed: adding a new section type = new subclass + new
        # entry in Adapter#build_dispatcher.
        class SectionRenderer
          include Base

          def render(section, doc)
            around_section(section, doc) do
              render_section_title(section, doc)
              walk_children(section, doc)
            end
          end

          # Hook for subclasses to wrap rendering in zone/depth context.
          # Default: no wrapping.
          def around_section(_section, _doc)
            yield
          end

          # Hook for subclasses to return the style key/symbol for the
          # title paragraph.
          def title_style_for(_section)
            raise NotImplementedError,
                  "#{self.class} must implement #title_style_for"
          end

          private

          def render_section_title(section, doc)
            title = section_title(section)
            return unless title
            return if heading_body_empty?(title)

            para = build_unstyled_paragraph
            para.style = title_style_for(section)
            with_bookmark(section, para) do
              @inline_renderer.render_heading(title, para)
            end
            doc << para
          end

          def section_title(section)
            return section.fmt_title if section.class.attributes.key?(:fmt_title) && section.fmt_title
            return section.title if section.class.attributes.key?(:title)

            nil
          end

          def walk_children(section, doc)
            @walker&.walk(section, doc)
          end
        end
      end
    end
  end
end
