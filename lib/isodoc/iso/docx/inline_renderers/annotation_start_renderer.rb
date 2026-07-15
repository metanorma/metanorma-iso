# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders a comment-range start marker for an annotation element
        # (FmtFootnoteContainer, FmtFnLabel, FmtAnnotationStart). Maps
        # the element's +target+ to a DOCX comment ID via the parent's
        # +comment_id_lookup+.
        class AnnotationStartRenderer
          include Base

          def render(element, para)
            target_id = element.target if element.class.attributes.key?(:target)
            return unless target_id

            comment_id = parent.lookup_comment_id(target_id)
            return unless comment_id

            para << Uniword::Wordprocessingml::CommentRangeStart.new(id: comment_id)
          rescue ArgumentError
            nil
          end
        end
      end
    end
  end
end
