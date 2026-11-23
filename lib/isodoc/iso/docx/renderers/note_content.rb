# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Notes can carry their blocks directly or inside presentation semx.
        # Nested notes parsed in mixed paragraphs have no element_order.
        module NoteContent
          NOTE_BODY_ATTRS = %i[content p ul ol dl formula quote semx table figure example].freeze
          NOTE_LABEL_ATTRS = %i[name fmt_name fmt_xref_label].freeze

          private

          def single_note_paragraph?(note)
            children = block_children(note)
            children.one? && children.first.is_a?(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
          end

          def block_children(node)
            children = if ordered?(node)
                         labels = NOTE_LABEL_ATTRS.flat_map { |attr| Array(attribute_value(node, attr)) }
                         elements = []
                         each_ordered_element(node) do |type, child|
                           elements << child if type == :element && labels.none? { |label| label.equal?(child) }
                         end
                         elements
                       else
                         NOTE_BODY_ATTRS.flat_map { |attr| Array(attribute_value(node, attr)) }
                       end
            children.flat_map do |child|
              if child.is_a?(Metanorma::Document::Components::Inline::SemxElement)
                block_children(child)
              else
                child
              end
            end
          end
        end
      end
    end
  end
end
