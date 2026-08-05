# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a Note block as a Box-wrapped region. The note's body
        # content (paragraphs, lists, etc.) is walked via the shared
        # walker; each child is dispatched normally but inside an
        # +@context.with_note+ zone so children pick up Noteindent (or
        # Noteindentcontinued for 2nd+ paragraphs) body style via
        # Context#zone + StyleResolver.
        #
        # The note's title (e.g. "NOTE 1") is extracted from fmt-name
        # and emitted as a Box-title paragraph at the top of the box.
        class NoteRenderer
          include Base
          include BoxWrapper

          def render(note, doc)
            @context.with_note do
              with_box(doc) do
                append_title_from_fmt_name(note, doc)
                @walker.walk(note, doc)
              end
            end
          end
        end
      end
    end
  end
end
