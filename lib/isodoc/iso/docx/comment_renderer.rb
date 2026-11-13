# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders document annotations as OOXML comments.
      #
      # Annotations from the model's `annotation_container` are rendered as
      # Word comments (word/comments.xml) with inline range markers
      # (commentRangeStart/commentRangeEnd/commentReference) in the
      # document body.
      #
      # Comment IDs are assigned sequentially during rendering. The inline
      # renderer looks up the mapping from annotation element ID to comment
      # ID via the `comment_id_map` this renderer maintains.
      class CommentRenderer
        attr_reader :comment_id_map

        def initialize(resolver, inline_renderer)
          @resolver = resolver
          @inline = inline_renderer
          @comment_id_map = {}
          @comment_counter = 0
        end

        # Render all annotations from the annotation_container as comments.
        # Returns the CommentsPart (or nil if no annotations).
        def render(annotation_container, doc)
          return nil unless annotation_container
          return nil unless annotation_container.class.attributes.key?(:annotations)

          annotations = annotation_container.annotations
          return nil if annotations.nil? || annotations.empty?

          comments_part = Uniword::CommentsPart.new

          annotations.each do |ann|
            comment_id = next_comment_id

            @comment_id_map[ann.id] = comment_id if ann.id

            comment = Uniword::Comment.new(
              comment_id: comment_id,
              author: ann.reviewer.to_s,
              date: ann.date.to_s,
            )

            Array(ann.paragraphs).each do |para|
              next if para.nil?
              text = paragraph_text(para)
              next if text.nil? || text.strip.empty?

              p = Uniword::Wordprocessingml::Paragraph.new
              r = Uniword::Wordprocessingml::Run.new(text: text)
              p.runs << r
              comment.paragraphs << p
            end

            comments_part.add_comment(comment)
          end

          doc.model.comments = comments_part
          comments_part
        end

        # Look up the DOCX comment ID for a given annotation element ID.
        def lookup_comment_id(annotation_element_id)
          @comment_id_map[annotation_element_id]
        end

        private

        def next_comment_id
          @comment_counter += 1
          @comment_counter.to_s
        end

        def paragraph_text(para)
          return "" unless para.is_a?(Lutaml::Model::Serializable)

          texts = []
          if para.class.attributes.key?(:text)
            Array(para.text).each { |t| texts << t if t.is_a?(String) }
          end
          texts.compact.join
        end
      end
    end
  end
end
