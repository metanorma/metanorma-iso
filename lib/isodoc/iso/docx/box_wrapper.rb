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
        include ModelUtils

        # Yield a block that appends body paragraphs to +doc+.
        # Wraps the block's output with Box-begin before and Box-end after.
        # If +title_text+ is provided, inserts a Box-title paragraph
        # before the body.
        def with_box(doc, title_text: nil)
          doc << box_paragraph(:box_begin)
          append_box_title(doc, title_text)
          yield
          doc << box_paragraph(:box_end)
        end

        # Extract a title from +node+'s fmt-name attribute and render
        # it as a Box-title paragraph. No-op when the node has no
        # fmt-name or its text is empty.
        def append_title_from_fmt_name(node, doc)
          fmt = attribute_value(node, :fmt_name)
          return unless fmt

          text = collect_all_text(fmt).to_s.strip
          append_box_title(doc, text)
        end

        private

        def append_box_title(doc, title_text)
          return if title_text.nil? || title_text.to_s.empty?

          title_para = box_paragraph(:box_title)
          title_para << title_text.to_s
          doc << title_para
        end

        def box_paragraph(key)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(key)
          para
        end
      end
    end
  end
end
