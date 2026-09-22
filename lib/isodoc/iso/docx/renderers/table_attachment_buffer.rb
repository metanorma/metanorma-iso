# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Buffer that captures rendered paragraphs (and tables) into an
        # in-memory array instead of appending them to a document. Used
        # by TableRenderer when wrapping a table and its note/example
        # attachments inside an outer 2-row table — the attachments
        # must land in the outer table's second-row cell, not as
        # siblings of the table in the parent block.
        #
        # The buffer quacks like a DocumentBuilder (#<<) so renderers
        # called via +walker.dispatch+ append their output to it.
        class TableAttachmentBuffer
          # +walker+ is the Renderers::Walker used to dispatch each
          # attachment through the normal renderer pipeline.
          # +attachment_attrs+ is the list of attribute names whose
          # values to dispatch (e.g. [:note, :example, :dl, :key]).
          def initialize(walker, attachment_attrs)
            @walker = walker
            @attachment_attrs = attachment_attrs
            @captured = []
          end

          # Dispatch every attachment child of +table+ into the buffer
          # via the walker. Walks in element_order so attachments land
          # in the same order as the source XML.
          def render(table)
            return unless @walker

            @attachment_attrs.each do |attr|
              next unless table.class.attributes.key?(attr)

              Array(table.public_send(attr)).each do |node|
                @walker.dispatch(node, self)
              end
            end
          end

          # Renderer protocol: append a paragraph or table model to the
          # captured list.
          def <<(node)
            @captured << node
            self
          end

          attr_reader :captured
          alias paragraphs captured
        end
      end
    end
  end
end