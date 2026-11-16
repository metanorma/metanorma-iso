# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # List-attached notes. Metanorma attaches a NOTE to the preceding
        # list: in the source XML the <note> is a direct child of <ul>,
        # <ol>, or <dl> — a sibling of the items, not a child of the last
        # item. The list renderers emit only their items, so each includes
        # this module to flush the attached notes through the standard
        # block dispatcher (NoteRenderer) after the list body. Skipping
        # this step dropped the whole note — text, footnote anchors, and
        # footnote bodies alike — from DOCX and MHTML output.
        module ListAttachments
          include ModelUtils

          # Dispatch every note attached to +list+ to +doc+, in document
          # order. No-op when the model class carries no :note attribute.
          def render_attached_notes(list, doc)
            attribute_collection(list, :note).each do |note|
              @walker.dispatch(note, doc)
            end
          end
        end
      end
    end
  end
end
