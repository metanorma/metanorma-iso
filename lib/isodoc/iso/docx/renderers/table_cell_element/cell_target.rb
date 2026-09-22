# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Adapter that lets a TableCellBuilder masquerade as the "doc"
          # parameter expected by TableCellElement handlers.
          #
          # Carries the cell's row-type-derived style key (e.g.
          # :table_body, :table_header) so handlers can apply the correct
          # paragraph style without knowing their position in the table.
          class CellTarget
            attr_reader :builder, :style_key

            def initialize(builder, style_key)
              @builder = builder
              @style_key = style_key
            end

            def <<(paragraph)
              @builder << paragraph
            end
          end
        end
      end
    end
  end
end
