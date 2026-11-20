# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Tracks which grid columns are still covered by a rowspan from a
        # row above, so TableRenderer can emit OOXML vertical merges.
        #
        # OOXML has no rowspan: the first cell carries <w:vMerge
        # w:val="restart"/> and every covered row carries a real (empty)
        # <w:tc> with a bare <w:vMerge/> at the same grid position and
        # the same gridSpan. One tracker serves one table section
        # (thead/tbody/tfoot); spans never cross sections.
        class TableRowSpans
          # uniword's ValInt writes an integer w:val, but ST_Merge only
          # admits "restart"/"continue". Same element, string value.
          class VMerge < Uniword::Wordprocessingml::ValInt
            attribute :value, :string

            xml do
              element "vMerge"
              namespace Uniword::Ooxml::Namespaces::WordProcessingML
              map_attribute "val", to: :value, render_nil: false
            end
          end

          def initialize
            @pending = {} # grid column => [rows still covered, colspan]
            @column = 0
          end

          def self.restart
            VMerge.new(value: "restart")
          end

          def self.continuation
            VMerge.new
          end

          # Start a new row at grid column 0.
          def start_row
            @column = 0
          end

          # Yield [colspan] for each continuation cell due at the current
          # column, advancing past them.
          def each_continuation_here
            while (entry = @pending[@column])
              yield entry[1]
              consume(@column)
              @column += entry[1]
            end
          end

          # Record a real cell at the current column and advance.
          def place(colspan, rowspan)
            @pending[@column] = [rowspan - 1, colspan] if rowspan > 1
            @column += colspan
          end

          # Continuations left over once the row's own cells are done
          # (spans that end the row, or follow a gap).
          def each_trailing_continuation
            @pending.keys.select { |c| c >= @column }.sort.each do |col|
              entry = @pending[col]
              yield entry[1]
              consume(col)
            end
          end

          private

          def consume(col)
            entry = @pending[col]
            entry[0] -= 1
            @pending.delete(col) if entry[0].zero?
          end
        end
      end
    end
  end
end
