# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders a <bookmark> element as a Word bookmark range
        # (BookmarkStart + BookmarkEnd) with a unique ID.
        class BookmarkRenderer
          include Base

          # The name is claimed like every other id bookmark, so an id
          # already bookmarked (a clause, a block) is not emitted twice.
          def render(element, para)
            return if parent.heading_annotations_suppressed?

            name = context.claim_bookmark_name(bookmark_name(element))
            return unless name

            id = context.next_bookmark_id.to_s
            start = Uniword::Wordprocessingml::BookmarkStart.new(id: id, name: name)
            para << start
            para << Uniword::Wordprocessingml::BookmarkEnd.new(id: id)
          end

          private

          # Model bookmarks carry their reference in +anchor+; XML
          # <bookmark> nodes may use the +anchor+ attribute, the +id+,
          # or neither.
          def bookmark_name(element)
            if element.is_a?(Metanorma::Document::Components::IdElements::Bookmark)
              element.anchor || element.id
            else
              element[:anchor] || element.id || element.name
            end
          end
        end
      end
    end
  end
end
