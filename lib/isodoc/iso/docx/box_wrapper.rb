# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Mixin for renderers that wrap content in Box-begin / Box-end.
      #
      # Era C template uses three styles to draw a thin border around
      # notes, examples, warnings:
      #   Box-begin  — empty paragraph marking the start
      #   Box-title  — optional title (e.g., "Note 1", "EXAMPLE 1")
      #   Box-end    — empty paragraph marking the end
      #
      # The body content uses the appropriate indentation style
      # (Noteindent, Exampleindent, Warningtext).
      module BoxWrapper
        # Yield a block that appends body paragraphs to +doc+.
        # Wraps the block's output with Box-begin before and Box-end after.
        # If +title_text+ is provided, inserts a Box-title paragraph
        # before the body.
        def with_box(doc, title_text: nil)
          doc << box_paragraph(:box_begin)
          if title_text && !title_text.to_s.empty?
            t = box_paragraph(:box_title)
            t << title_text.to_s
            doc << t
          end
          yield
          doc << box_paragraph(:box_end)
        end

        private

        def box_paragraph(key)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(key)
          para
        end
      end
    end
  end
end
