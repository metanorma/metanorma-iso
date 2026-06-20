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
            name = table.fmt_name || table.name
            if name
              title_para = Uniword::Builder::ParagraphBuilder.new
              title_para.style = @resolver.table_title_style
              @inline_renderer.render(name, title_para)
              doc << title_para
            end

            tbl = Uniword::Builder::TableBuilder.new

            @context.with_table do
              render_table_section(table.thead, tbl, :header)
              render_table_section(table.tbody, tbl, :body)
              render_table_section(table.tfoot, tbl, :body)
            end

            ensure_table_structure(tbl.model, table.width)
            doc << tbl
          end

          private

          def render_table_section(section, tbl, row_type)
            return unless section

            rows = section.tr
            return unless rows

            Array(rows).each do |tr|
              tbl.row do |row|
                cells = Array(tr.th) + Array(tr.td)
                cells.each do |cell|
                  next unless cell
                  col_span = cell.colspan
                  row.cell do |c|
                    c.column_span(col_span.to_i) if col_span
                    render_cell_content(cell, c, row_type)
                  end
                end
              end
            end
          end

          def render_cell_content(cell, cell_builder, row_type)
            style_key = table_cell_style_key(row_type)
            if cell_has_block_content?(cell)
              render_cell_block_content(cell, cell_builder, style_key)
            else
              cell_para = Uniword::Builder::ParagraphBuilder.new
              cell_para.style = @resolver.paragraph_style(style_key) if style_key
              @inline_renderer.render(cell, cell_para)
              cell_builder << cell_para
            end
          end

          def table_cell_style_key(row_type)
            case row_type
            when :header then :table_header
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
                next if obj.nil? || obj.strip.empty?
                cell_para = Uniword::Builder::ParagraphBuilder.new
                cell_para.style = @resolver.paragraph_style(style_key) if style_key
                cell_para << obj
                cell_builder << cell_para
              when :element
                render_cell_element(obj, cell_builder, style_key)
              end
            end
          end

          def render_cell_element(element, cell_builder, style_key = nil)
            case element
            when Metanorma::Document::Components::Paragraphs::ParagraphBlock
              cell_para = Uniword::Builder::ParagraphBuilder.new
              cell_para.style = @resolver.paragraph_style(style_key) if style_key
              @inline_renderer.render(element, cell_para)
              cell_builder << cell_para
            when Metanorma::Document::Components::Blocks::NoteBlock
              cell_para = Uniword::Builder::ParagraphBuilder.new
              cell_para.style = @resolver.paragraph_style(:note)
              @inline_renderer.render(element, cell_para)
              cell_builder << cell_para
            when Metanorma::Document::Components::Lists::OrderedList
              num_id = @resolver.numbering_id(:decimal_list)
              Array(element.listitem).each do |item|
                render_cell_list_item(item, cell_builder, num_id, style_key)
              end
            when Metanorma::Document::Components::Lists::UnorderedList
              num_id = @resolver.numbering_id(:dash_list)
              Array(element.listitem).each do |item|
                render_cell_list_item(item, cell_builder, num_id, style_key)
              end
            else
              cell_para = Uniword::Builder::ParagraphBuilder.new
              cell_para.style = @resolver.paragraph_style(style_key) if style_key
              @inline_renderer.render(element, cell_para)
              cell_builder << cell_para
            end
          end

          def render_cell_list_item(item, cell_builder, num_id, style_key = nil)
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.paragraph_style(style_key) if style_key
            para.numbering(num_id, 0) if num_id
            paragraphs = item.paragraphs
            if paragraphs && !paragraphs.empty?
              paragraphs.each { |p| @inline_renderer.render(p, para) }
            else
              @inline_renderer.render(item, para)
            end
            cell_builder << para
          end

          def ensure_table_structure(table_model, width)
            unless table_model.properties
              table_model.properties = Uniword::Wordprocessingml::TableProperties.new
            end
            unless table_model.properties.table_width
              table_model.properties.table_width =
                Uniword::Properties::TableWidth.new(
                  w: parse_twips(width) || 0, type: "dxa",
                )
            end
            unless table_model.properties.table_look
              table_model.properties.table_look =
                Uniword::Properties::TableLook.new(
                  val: "04A0",
                  first_row: 1,
                  last_row: 0,
                  first_column: 1,
                  last_column: 0,
                  no_h_band: 0,
                  no_v_band: 1,
                )
            end

            return if table_model.grid

            cols = table_model.rows.map { |r| (r.cells&.count || 0) }.max || 0
            total_width = parse_twips(width) || 9000
            col_width = cols > 0 ? (total_width / cols) : 0
            grid_cols = Array.new(cols) do
              Uniword::Wordprocessingml::GridCol.new(width: col_width)
            end
            table_model.grid = Uniword::Wordprocessingml::TableGrid.new(columns: grid_cols)
          end
        end
      end
    end
  end
end
