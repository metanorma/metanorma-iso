# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a Note block with the XSL inline-label layout: the
        # note's label ("NOTE 1") runs inline at the head of the first
        # body paragraph, and the body paragraphs pick up Noteindent
        # (Noteindentcontinued for 2nd+) via Context#zone + StyleResolver.
        #
        # This mirrors iso.international-standard.xsl's note contract —
        # label inline (note-name-style), no border, no shading — where
        # the Era C template previously drew a Box-begin/Box-title/
        # Box-end grey box around every note.
        #
        # When the note's first child is not a plain paragraph (list,
        # sourcecode, a paragraph carrying embedded blocks, ...), the
        # label falls back to its own keep-with-next paragraph and the
        # full child walk proceeds through the normal dispatch path.
        class NoteRenderer
          include Base
          include BoxWrapper

          def render(note, doc)
            @context.with_note do
              with_inline_label(note, doc, :note_indent)
            end
          end
        end
      end
    end
  end
end
