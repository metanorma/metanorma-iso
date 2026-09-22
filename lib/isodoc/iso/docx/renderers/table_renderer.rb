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

          def render(table, doc)
            render_table_name(table, doc)

            tbl = Uniword::Builder::TableBuilder.new
            build_table_sections(table, tbl)
            ensure_table_structure(tbl.model, table.width)

            if has_table_attachments?(table)
              render_wrapped_table(tbl.model, table, doc)
            else
              doc << tbl
            end
          end

          # Era C wraps a table and its note/example/key annotations in
          # an outer 2-row 1-column table so the annotations visually
          # belong to the table. Row 1 contains the actual table; row 2
          # contains the rendered attachments as paragraphs.
          def render_wrapped_table(inner_table_model, table, doc)
            outer = Uniword::Builder::TableBuilder.new
            outer.width(table.width) if table.width

            outer.row do |row|
              row.cell { |c| c << inner_table_model }
            end
            outer.row do |row|
              row.cell { |c| append_attachments_to_cell(c, table) }
            end

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
            @inline_renderer.render(name, title_para)
            doc << title_para
          end

          def build_table_sections(table, tbl)
            @context.with_table do
              render_table_section(table.thead, tbl, :header)
              render_table_section(table.tbody, tbl, :body)
              render_table_section(table.tfoot, tbl, :footer)
            end
          end

          # Era C tables in presentation XML carry <note>, <example>,
          # <sourcecode>, <dl>, and <key> as direct children — siblings
          # of <thead>/<tbody>/<tfoot>. These are table-level annotations
          # that follow the table; render each in document order via the
          # standard block dispatcher so they pick up NoteRenderer,
          # ExampleRenderer, DefinitionListRenderer, etc.
          TABLE_ATTACHMENT_ATTRS = %i[note example sourcecode dl key].freeze

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
          DEFAULT_FALLBACK_WIDTH_TWIPS = 9000

          private

          def render_table_section(section, tbl, row_type)
            return unless section

            rows = section.tr
            return unless rows

            Array(rows).each { |tr| render_table_row(tr, tbl, row_type) }
          end

          def render_table_row(table_row, tbl, row_type)
            tbl.row do |row|
              cells = Array(table_row.th) + Array(table_row.td)
              cells.each { |cell| render_row_cell(cell, row, row_type) }
            end
          end

          def render_row_cell(cell, row, row_type)
            return unless cell

            col_span = cell.colspan
            row.cell do |c|
              c.column_span(col_span.to_i) if col_span
              render_cell_content(cell, c, row_type)
            end
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

              %w[note example p ol ul dl sourcecode quote].include?(el.name)
            end
          end

          def render_cell_block_content(cell, cell_builder, style_key = nil)
            each_ordered_element(cell) do |type, obj|
              case type
              when :text
                append_text_to_cell(obj, cell_builder, style_key)
              when :element
                dispatch_cell_element(obj, cell_builder, style_key)
              end
            end
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

          def dispatch_cell_element(element, cell_builder, style_key)
            target = TableCellElement::CellTarget.new(cell_builder, style_key)
            cell_registry.dispatch(element, target)
          end

          def cell_registry
            @cell_registry ||= TableCellElement::Registry.new(
              resolver: @resolver, inline_renderer: @inline_renderer,
            )
          end

          def ensure_table_structure(table_model, width)
            ensure_table_properties(table_model)
            ensure_table_width(table_model, width)
            ensure_table_look(table_model)
            ensure_table_grid(table_model, width)
          end

          def ensure_table_properties(table_model)
            return if table_model.properties

            table_model.properties = Uniword::Wordprocessingml::TableProperties.new
          end

          def ensure_table_width(table_model, width)
            return if table_model.properties.table_width

            table_model.properties.table_width =
              Uniword::Properties::TableWidth.new(
                w: parse_twips(width) || 0, type: "dxa",
              )
          end

          def ensure_table_look(table_model)
            return if table_model.properties.table_look

            table_model.properties.table_look =
              Uniword::Properties::TableLook.new(
                val: DEFAULT_TABLE_LOOK_VAL,
                **DEFAULT_TABLE_LOOK_FLAGS,
              )
          end

          def ensure_table_grid(table_model, width)
            return if table_model.grid

            cols = table_column_count(table_model)
            col_width = column_width(cols, width)
            grid_cols = Array.new(cols) do
              Uniword::Wordprocessingml::GridCol.new(width: col_width)
            end
            table_model.grid =
              Uniword::Wordprocessingml::TableGrid.new(columns: grid_cols)
          end

          def table_column_count(table_model)
            table_model.rows.map { |r| r.cells&.count || 0 }.max || 0
          end

          def column_width(cols, width)
            return 0 if cols.zero?

            total_width = parse_twips(width) || DEFAULT_FALLBACK_WIDTH_TWIPS
            total_width / cols
          end
        end
      end
    end
  end
end
