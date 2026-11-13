# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders a <bookmark> element as a Word bookmark range
        # (BookmarkStart + BookmarkEnd) with a unique ID.
        class BookmarkRenderer
          include Base

          def render(element, para)
            # metanorma-document 0.4.x Bookmark: id is the base IdElement
            # attribute, anchor the bookmark's own name.
            name = element.id || element.anchor
            return unless name

            id = context.next_bookmark_id.to_s
            start = Uniword::Wordprocessingml::BookmarkStart.new(id: id, name: name)
            para << start
            para << Uniword::Wordprocessingml::BookmarkEnd.new(id: id)
          end
        end
      end
    end
  end
end
