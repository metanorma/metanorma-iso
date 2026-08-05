# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Renders a NoteBlock inside a table cell. Unlike the body-level
          # NoteRenderer, the cell version does not wrap the note in
          # Box-begin/Box-end — it renders the note content as a single
          # paragraph carrying the Note paragraph style.
          class NoteHandler
            include Base

            def render(element, target)
              cell_para = Uniword::Builder::ParagraphBuilder.new
              cell_para.style = @resolver.paragraph_style(:note)
              @inline_renderer.render(element, cell_para)
              target << cell_para
            end
          end
        end
      end
    end
  end
end
