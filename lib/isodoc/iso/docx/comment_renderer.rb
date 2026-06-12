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
      # The annotation_container uses `map_all_content` (raw XML string),
      # so annotations are parsed via lightweight Lutaml models, similar to
      # BoilerplateRenderer.
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

          content = annotation_container.content
          return nil if content.nil? || content.strip.empty?

          parsed = parse_annotation_content(content)
          return nil if parsed.annotations.empty?

          comments_part = Uniword::CommentsPart.new

          parsed.annotations.each do |ann|
            comment_id = next_comment_id

            # Map the fmt-annotation-body ID to our sequential comment ID
            @comment_id_map[ann.id] = comment_id if ann.id

            comment = Uniword::Comment.new(
              comment_id: comment_id,
              author: ann.reviewer.to_s,
              date: ann.date.to_s,
            )

            # Add paragraphs from annotation content
            Array(ann.paragraph_texts).each do |para_text|
              next if para_text.nil? || para_text.strip.empty?
              p = Uniword::Wordprocessingml::Paragraph.new
              r = Uniword::Wordprocessingml::Run.new(text: para_text)
              p.runs << r
              comment.paragraphs << p
            end

            comments_part.add_comment(comment)
          end

          doc.model.comments = comments_part if doc.model.respond_to?(:comments=)
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

        def parse_annotation_content(raw_xml)
          wrapped = "<annotation-root>#{raw_xml}</annotation-root>"
          AnnotationContent.from_xml(wrapped)
        rescue StandardError
          AnnotationContent.new
        end

        # ── Lightweight annotation models ──
        #
        # Parses the raw XML content from annotation_container.content.
        # Uses fmt-annotation-body elements (the presentation-layer annotations)
        # which contain the actual rendered text.

        class AnnotationParagraph < Lutaml::Model::Serializable
          attribute :content, :string

          xml do
            root "p"
            map_all_content to: :content
          end
        end

        class AnnotationBody < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :reviewer, :string
          attribute :date, :string
          attribute :p, AnnotationParagraph, collection: true

          xml do
            root "fmt-annotation-body"
            map_attribute "id", to: :id
            map_attribute "reviewer", to: :reviewer
            map_attribute "date", to: :date
            map_element "p", to: :p
          end

          def paragraph_texts
            Array(p).map(&:content).compact
          end
        end

        class AnnotationContent < Lutaml::Model::Serializable
          attribute :annotations, AnnotationBody, collection: true

          xml do
            root "annotation-root"
            map_element "fmt-annotation-body", to: :annotations
          end
        end
      end
    end
  end
end
