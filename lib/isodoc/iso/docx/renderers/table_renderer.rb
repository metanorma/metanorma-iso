# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a TableBlock as a Uniword table with header and body
        # rows. Cells may contain simple inline content or block-level
        # content (paragraphs, notes, lists) — the renderer dispatches
        # accordingly.
        #
        # The optional table name (fmt_name / name) is rendered first
        # as a separate paragraph with the table-title style.
        class TableRenderer
          include Base
          include ModelUtils
          include TableFootnotes

          def render(table, doc)
            tbl = Uniword::Builder::TableBuilder.new
            footnotes = collecting_table_footnotes do
              render_table_name(table, doc)
              build_table_sections(table, tbl)
            end
            append_collected_footnotes(tbl, footnotes)
            nested = doc.is_a?(TableCellElement::CellTarget)
            ensure_table_structure(tbl.model, table.width, colgroup_weights(table), nested: nested)

            if has_table_attachments?(table)
              render_wrapped_table(tbl.model, table, doc, nested: nested)
            else
              doc << tbl
            end
          end

          # Era C wraps a table and its note/example/key annotations in
          # an outer 2-row 1-column table so the annotations visually
          # belong to the table. Row 1 contains the actual table; row 2
          # contains the rendered attachments as paragraphs.
          def render_wrapped_table(inner_table_model, table, doc, nested: false)
            outer = Uniword::Builder::TableBuilder.new

            outer.row do |row|
              row.cell do |c|
                c << inner_table_model
                # OOXML: a w:tc must end with a w:p, not a nested w:tbl.
                c << Uniword::Builder::ParagraphBuilder.new
              end
            end
            outer.row do |row|
              row.cell { |c| append_attachments_to_cell(c, table) }
            end

            ensure_table_width(inner_table_model, nil, nested: true)
            ensure_table_width(outer.model, table.width, nested: nested)
            ensure_table_grid(outer.model, table.width, nil)
            doc << outer
          end

          def append_attachments_to_cell(cell_builder, table)
            buffer = TableAttachmentBuffer.new(@walker, TABLE_ATTACHMENT_ATTRS)
            buffer.render(table)
            buffer.paragraphs.each { |p| cell_builder << p }
          end

          def has_table_attachments?(table)
            return false unless ordered?(table)

            mapping = build_element_mapping(table)
            return false unless mapping

            table.element_order.any? do |el|
              next false unless el.element?

              attr_name = mapping[el.name]
              TABLE_ATTACHMENT_ATTRS.include?(attr_name)
            end
          end

          def render_table_name(table, doc)
            name = table.fmt_name || table.name
            return unless name

            title_para = Uniword::Builder::ParagraphBuilder.new
            title_para.style = @resolver.table_title_style
            with_bookmark(table, title_para) do
              @inline_renderer.render(name, title_para)
            end
            doc << title_para
          end

          def build_table_sections(table, tbl)
            @context.with_table do
              render_table_section(table.thead, tbl, :header)
              render_table_section(table.tbody, tbl, :body)
              render_table_section(table.tfoot, tbl, :footer)
            end
          end

          # The submitted ISO tables set table footnotes in Tablefootnote style.
          def append_collected_footnotes(tbl, footnotes)
            return if footnotes.empty?

            append_table_footnotes(tbl, footnotes, columns: table_column_count(tbl.model), style_key: :table_footnote)
          end

          # Era C tables in presentation XML carry <note>, <example>,
          # <sourcecode>, <dl>, and <key> as direct children — siblings
          # of <thead>/<tbody>/<tfoot>. These are table-level annotations
          # that follow the table; render each in document order via the
          # standard block dispatcher so they pick up NoteRenderer,
          # ExampleRenderer, DefinitionListRenderer, etc.
          TABLE_ATTACHMENT_ATTRS = %i[note example sourcecode dl key].freeze

          NESTED_TABLE = Metanorma::Document::Components::Tables::TableBlock
          CELL_BLOCK_ELEMENTS = %w[note example p ol ul dl sourcecode quote table].freeze

          # OOXML default table look val 04A0: first-row + first-column
          # special formatting on, no banding. Matches Word's "Table Grid".
          DEFAULT_TABLE_LOOK_VAL = "04A0"
          DEFAULT_TABLE_LOOK_FLAGS = {
            first_row: 1,
            last_row: 0,
            first_column: 1,
            last_column: 0,
            no_h_band: 0,
            no_v_band: 1,
          }.freeze
          # Used only when no template section margins are available.
          DEFAULT_FALLBACK_WIDTH_TWIPS = 10204
          WIDTH_UNITS_TO_TWIPS = {
            "pt" => 20, "px" => 15, "in" => 1440,
            "cm" => 1440 / 2.54, "mm" => 1440 / 25.4
          }.freeze
          # Border sizes in eighths of a point: 1 pt frame, 0.5 pt rules.
          FRAME_SIZE = 8
          RULE_SIZE = 4

          private

          def render_table_section(section, tbl, row_type)
            return unless section

            rows = section.tr
            return unless rows

            spans = TableRowSpans.new
            Array(rows).each { |tr| render_table_row(tr, tbl, row_type, spans) }
          end

          def render_table_row(table_row, tbl, row_type, spans)
            spans.start_row
            tbl.row do |row|
              row_cells(table_row).each do |cell|
                render_continuations(spans, row)
                render_row_cell(cell, row, row_type, spans)
              end
              render_continuations(spans, row)
              spans.each_trailing_continuation do |gap, n|
                gap.times { add_empty_cell(row) }
                add_continuation(row, n)
              end
            end
          end

          # Cells in source order; th and td may be mixed within a row.
          def row_cells(table_row)
            if ordered?(table_row)
              cells = []
              each_ordered_element(table_row, allow_filter: %i[th td]) do |type, obj|
                cells << obj if type == :element
              end
              return cells unless cells.empty?
            end
            Array(table_row.th) + Array(table_row.td)
          end

          def render_continuations(spans, row)
            spans.each_continuation_here { |n| add_continuation(row, n) }
          end

          def add_empty_cell(row)
            row.cell { |c| c << Uniword::Builder::ParagraphBuilder.new }
          end

          def add_continuation(row, colspan)
            row.cell do |c|
              c.column_span(colspan) if colspan > 1
              c.model.properties.v_merge = TableRowSpans.continuation
              c << Uniword::Builder::ParagraphBuilder.new
            end
          end

          def render_row_cell(cell, row, row_type, spans)
            return unless cell

            col_span = [cell.colspan.to_i, 1].max
            row_span = [cell.rowspan.to_i, 1].max
            row.cell do |c|
              c.column_span(col_span) if col_span > 1
              c.model.properties.v_merge = TableRowSpans.restart if row_span > 1
              render_cell_content(cell, c, row_type)
            end
            spans.place(col_span, row_span)
          end

          def render_cell_content(cell, cell_builder, row_type)
            style_key = table_cell_style_key(row_type)
            if cell_has_block_content?(cell)
              render_cell_block_content(cell, cell_builder, style_key)
            else
              render_inline_cell(cell, cell_builder, style_key)
            end
          end

          def render_inline_cell(cell, cell_builder, style_key)
            cell_para = Uniword::Builder::ParagraphBuilder.new
            apply_cell_style(cell_para, style_key)
            @inline_renderer.render(cell, cell_para)
            cell_builder << cell_para
          end

          def table_cell_style_key(row_type)
            case row_type
            when :header then :table_header
            when :footer then :table_footer
            else :table_body
            end
          end

          def cell_has_block_content?(cell)
            return false unless ordered?(cell)

            cell.element_order.any? do |el|
              next false unless el.element?

              CELL_BLOCK_ELEMENTS.include?(el.name)
            end
          end

          def render_cell_block_content(cell, cell_builder, style_key = nil)
            each_ordered_element(cell) do |type, obj|
              case type
              when :text
                append_text_to_cell(obj, cell_builder, style_key)
              when :element
                # Word fuses two tables with no paragraph between them.
                cell_builder << Uniword::Builder::ParagraphBuilder.new if obj.is_a?(NESTED_TABLE) && ends_in_table?(cell_builder)
                dispatch_cell_element(obj, TableCellElement::CellTarget.new(cell_builder, style_key))
              end
            end
            # OOXML: a w:tc must end with a w:p, not a nested w:tbl.
            cell_builder << Uniword::Builder::ParagraphBuilder.new if ends_in_table?(cell_builder)
          end

          # Reads what the cell actually emitted, so an element that renders
          # nothing (an empty list) cannot hide a trailing table.
          def ends_in_table?(cell_builder)
            Array(cell_builder.model.element_order).last&.name == "tbl"
          end

          def append_text_to_cell(text, cell_builder, style_key)
            return if text.nil? || text.strip.empty?

            cell_para = Uniword::Builder::ParagraphBuilder.new
            apply_cell_style(cell_para, style_key)
            cell_para << text
            cell_builder << cell_para
          end

          def apply_cell_style(cell_para, style_key)
            return unless style_key

            cell_para.style = @resolver.paragraph_style(style_key)
          end

          def dispatch_cell_element(element, target)
            return render(element, target) if element.is_a?(NESTED_TABLE)

            cell_registry.dispatch(element, target)
          end

          def cell_registry
            @cell_registry ||= TableCellElement::Registry.new(
              resolver: @resolver, inline_renderer: @inline_renderer,
              dispatcher: method(:dispatch_cell_element)
            )
          end

          def ensure_table_structure(table_model, width, weights = nil, nested: false)
            ensure_table_properties(table_model)
            ensure_table_borders(table_model)
            ensure_table_width(table_model, width, nested: nested)
            ensure_table_look(table_model)
            ensure_table_grid(table_model, width, weights)
          end

          def ensure_table_properties(table_model)
            return if table_model.properties

            table_model.properties = Uniword::Wordprocessingml::TableProperties.new
          end

          # The ISO PDF draws a solid 1 pt frame and 0.5 pt rules between
          # every row and column (iso.international-standard.xsl,
          # table-border / table-cell-border).
          def ensure_table_borders(table_model)
            return if table_model.properties.table_borders

            frame = table_border(FRAME_SIZE)
            rule = table_border(RULE_SIZE)
            table_model.properties.table_borders =
              Uniword::Wordprocessingml::TableBorders.new(
                top: frame, bottom: frame, left: frame, right: frame,
                inside_h: rule, inside_v: rule
              )
          end

          def table_border(size)
            Uniword::Wordprocessingml::Border.new(
              val: "single", sz: size, space: 0, color: "000000",
            )
          end

          def ensure_table_width(table_model, width, nested: false)
            width = valid_table_width(width)
            relative = nested && (width.nil? || width.end_with?("%"))
            value = if relative
                      width.nil? ? 5000 : ([width.to_f, 100].min * 50).round.clamp(1, 5000)
                    else
                      grid_total(width)
                    end
            table_model.properties.table_width =
              Uniword::Properties::TableWidth.new(
                w: value, type: relative ? "pct" : "dxa",
              )
            table_model.properties.table_layout =
              Uniword::Properties::TableLayout.new(type: "fixed")
          end

          def ensure_table_look(table_model)
            return if table_model.properties.table_look

            table_model.properties.table_look =
              Uniword::Properties::TableLook.new(
                val: DEFAULT_TABLE_LOOK_VAL,
                **DEFAULT_TABLE_LOOK_FLAGS,
              )
          end

          # Column sizes the author gave in a colgroup, or nil.
          def colgroup_weights(table)
            cols = table.colgroup&.col
            return nil if cols.nil? || Array(cols).empty?

            Array(cols).map(&:width)
          end

          def ensure_table_grid(table_model, width, weights)
            cols = table_column_count(table_model)
            return if cols.zero?

            widths = TableColumnWidths.new(table_model, cols, weights: weights)
              .twips(grid_total(width))
            table_model.grid = Uniword::Wordprocessingml::TableGrid.new(
              columns: widths.map { |w| Uniword::Wordprocessingml::GridCol.new(width: w) },
            )
            apply_cell_widths(table_model, widths)
          end

          def grid_total(width)
            available = @context.text_width || DEFAULT_FALLBACK_WIDTH_TWIPS
            width = valid_table_width(width)
            return available unless width

            factor = if width.end_with?("%")
                       available / 100.0
                     else
                       WIDTH_UNITS_TO_TWIPS[width[/[a-z]+\z/]]
                     end
            return available if factor && width.to_f >= available / factor

            total = factor ? (width.to_f * factor).round : width.to_i
            total.clamp(1, available)
          end

          def valid_table_width(width)
            value = width.to_s.strip
            return unless value.match?(/\A\+?(?:\d+(?:\.\d+)?|\.\d+)(?:%|pt|px|in|cm|mm)?\z/)
            return unless value.to_f.positive? && value.to_f.finite?

            value
          end

          def apply_cell_widths(table_model, widths)
            table_model.rows.each do |row|
              col = 0
              Array(row.cells).each do |cell|
                span = [cell.properties&.grid_span&.value.to_i, 1].max
                cell.properties ||= Uniword::Wordprocessingml::TableCellProperties.new
                cell.properties.cell_width = Uniword::Properties::CellWidth.new(
                  w: widths[col, span].to_a.sum, type: "dxa",
                )
                fit_nested_tables(cell, widths[col, span].to_a.sum)
                col += span
              end
            end
          end

          # Nested tables are built before the parent grid is known. Scale
          # their grids after assigning the containing cell's actual width.
          def fit_nested_tables(cell, available)
            Array(cell.tables).each do |table|
              width = table.properties.table_width
              total = if width.type == "pct"
                        (available * width.w.to_i / 5000.0).round
                      else
                        [width.w.to_i, available].min
                      end
              width.w = total unless width.type == "pct"
              weights = Array(table.grid&.columns).map(&:width)
              ensure_table_grid(table, total.to_s, weights)
            end
          end

          def table_column_count(table_model)
            table_model.rows.map { |r| row_grid_width(r) }.max || 0
          end

          def row_grid_width(row)
            Array(row.cells).sum do |cell|
              [cell.properties&.grid_span&.value.to_i, 1].max
            end
          end
        end
      end
    end
  end
end
