# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a Note block as a Box-wrapped paragraph with Noteindent
        # body style. The Box-begin/Box-end wrappers draw the thin border
        # characteristic of Era C template's note layout.
        class NoteRenderer
          include Base
          include BoxWrapper

          def render(note, doc)
            @context.with_note do
              with_box(doc) do
                para = build_paragraph(:note_indent)
                @inline_renderer.render(note, para)
                doc << para
              end
            end
          end
        end
      end
    end
  end
end
