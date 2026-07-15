# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders a comment-range end marker and a comment-reference run
        # for an FmtAnnotationEnd element.
        class AnnotationEndRenderer
          include Base

          def render(element, para)
            target_id = element.target if element.class.attributes.key?(:target)
            return unless target_id

            comment_id = parent.lookup_comment_id(target_id)
            return unless comment_id

            end_marker = Uniword::Wordprocessingml::CommentRangeEnd.new(id: comment_id)
            para << end_marker

            ref_run = Uniword::Wordprocessingml::Run.new(
              comment_reference: Uniword::Wordprocessingml::CommentReference.new(
                id: comment_id,
              ),
            )
            parent.apply_run_char_style(ref_run, :comment_reference)
            para << ref_run
          rescue ArgumentError
            nil
          end
        end
      end
    end
  end
end
