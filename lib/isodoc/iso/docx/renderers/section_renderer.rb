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
        # entry in Adapter#build_registry.
        class SectionRenderer
          include Base

          def render(section, doc)
            around_section(section, doc) do
              if untitled?(section)
                render_untitled_section(section, doc)
              else
                render_section_title(section, doc)
                walk_children(section, doc)
              end
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

            para = build_unstyled_paragraph
            para.style = title_style_for(section)
            suppress_number(para)
            with_bookmark(section, para) do
              render_title_content(title, para)
            end
            doc << para
          end

          # Amendment documents run with unnumbered clause titles. The
          # number comes from the heading style's numPr, so numId 0 on
          # the paragraph cancels it (as ClauseRenderer does for the
          # introduction's a2 headings).
          def suppress_number(para)
            return unless @context.suppress_heading_numbers?
            return unless @resolver.auto_numbered_style?(para.style&.value)

            para.numbering(0)
          end

          # A title holding only the autonum + delimiter (an untitled
          # inline-header sub-clause).
          def untitled?(section)
            title = section_title(section)
            !title.nil? && heading_body_empty?(title)
          end

          # No heading paragraph: the clause number and its id bookmark
          # lead the first body paragraph. When the clause's first child
          # is not a paragraph (table, list, note...), or it has none, there
          # is no paragraph to lead, so the number gets its own paragraph
          # ahead of that child (as in Word's reference rendering) rather
          # than landing on whichever paragraph happens to come next, or
          # being dropped.
          def render_untitled_section(section, doc)
            number = @inline_renderer.heading_number_text(section_title(section))
            return walk_children(section, doc) unless number

            name = bookmark_name(section)
            if first_child_paragraph?(section)
              @inline_renderer.with_clause_number(number, name) do
                walk_children(section, doc)
              end
            else
              render_number_paragraph(number, name, doc)
              walk_children(section, doc)
            end
          end

          def first_child_paragraph?(section)
            return true unless ordered?(section)

            title = section_title(section)
            first = nil
            each_ordered_element(section) do |type, obj|
              first ||= obj if type == :element && !obj.equal?(title)
            end
            first.is_a?(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
          end

          def render_number_paragraph(number, name, doc)
            para = build_unstyled_paragraph
            style = @resolver.context_body_style
            para.style = style if style
            @inline_renderer.emit_clause_number(para, number, name)
            @context.mark_zone_paragraph
            doc << para
          end

          def render_title_content(title, para)
            @inline_renderer.render_heading(title, para)
          end

          def section_title(section)
            return fmt_section_title(section) if fmt_section_title(section)
            return section.title if section.class.attributes.key?(:title)

            nil
          end

          def fmt_section_title(section)
            return unless section.class.attributes.key?(:fmt_title)

            section.fmt_title
          end

          def walk_children(section, doc)
            @walker&.walk(section, doc)
          end
        end
      end
    end
  end
end
