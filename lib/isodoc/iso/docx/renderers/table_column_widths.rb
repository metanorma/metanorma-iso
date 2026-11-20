# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Splits a table's total width across its grid columns, the way the
        # ISO PDF does: the column widths of a colgroup when the source
        # gives them, otherwise in proportion to the longest text each
        # column holds. Cells that span columns do not vote.
        class TableColumnWidths
          MIN_WEIGHT = 6
          MAX_WEIGHT = 60

          # weights: Array of relative column sizes (colgroup widths) or nil.
          def initialize(table_model, cols, weights: nil)
            @table = table_model
            @cols = cols
            @weights = usable(weights)
          end

          # Twips per column, summing exactly to +total+.
          def twips(total)
            weights = @weights || content_weights
            sum = weights.sum.to_f
            widths = weights.map { |w| (total * w / sum).floor }
            widths[-1] += total - widths.sum if widths.any?
            widths
          end

          private

          def usable(weights)
            list = Array(weights).map { |w| w.to_s[/\d+(\.\d+)?/].to_f }
            return nil unless list.size == @cols && list.all?(&:positive?)

            list
          end

          def content_weights
            longest = Array.new(@cols, 0)
            @table.rows.each do |row|
              col = 0
              Array(row.cells).each do |cell|
                span = [cell.properties&.grid_span&.value.to_i, 1].max
                longest[col] = [longest[col], cell_length(cell)].max if span == 1 && col < @cols
                col += span
              end
            end
            longest.map { |n| n.clamp(MIN_WEIGHT, MAX_WEIGHT) }
          end

          def cell_length(cell)
            Array(cell.paragraphs).map { |p| p.text.to_s.length }.max.to_i
          end
        end
      end
    end
  end
end
