# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders <dl> definition lists with context-aware styling.
        #
        # Formula keys use bordered tables. Figure keys use KeyTitle and
        # KeyText; the Symbols clause uses a two-column table; other
        # definition lists use Definition paragraphs.
        class DefinitionListRenderer
          include Base
          include ListAttachments
          include TableFootnotes

          def render(definition_list, doc)
            case @context.zone
            when :formula
              render_formula_key(definition_list, doc)
            when :figure
              render_figure_key(definition_list, doc)
            when :definitions
              render_symbol_table(definition_list, doc)
            else
              render_general(definition_list, doc)
            end
            render_attached_notes(definition_list, doc)
          end

          private

          def render_formula_key(definition_list, doc)
            terms = Array(definition_list.dt)
            return if terms.empty?

            table = formula_key_table
            definitions = Array(definition_list.dd)
            footnotes = collecting_table_footnotes do
              terms.each_with_index do |term, index|
                table.row do |row|
                  formula_cell(row, term)
                  formula_cell(row, definitions[index])
                end
              end
            end
            # The ISO templates have no tablefootnote paragraph style.
            append_table_footnotes(table, footnotes, columns: 2, style_key: :footnote_text) unless footnotes.empty?
            doc << table
          end

          def formula_key_table
            table = Uniword::Builder::TableBuilder.new
            # The submitted formula_dl table starts 20.15 points from the margin.
            table.model.properties.table_indent =
              Uniword::Properties::TableIndent.new(value: 403, type: "dxa")
            line = Uniword::Wordprocessingml::Border.new(val: "single", sz: 4)
            table.model.properties.table_borders =
              Uniword::Wordprocessingml::TableBorders.new(
                top: line, bottom: line, left: line, right: line,
                inside_h: line, inside_v: line
              )
            table
          end

          def formula_cell(row, node)
            row.cell do |cell|
              formula_cell_content(node).each_with_index do |part, i|
                para = build_paragraph(:table_body)
                @inline_renderer.render(part, para) if part
                anchor_entry(part, para) if part
                anchor_paragraph(node, para) if i.zero? && !part.equal?(node)
                cell << para
              end
            end
          end

          def formula_cell_content(node)
            paragraphs = attribute_value(node, :p)
            return [node] if paragraphs.nil? || paragraphs.empty?
            return [node] unless Array(node.element_order).all? do |entry|
              entry.element? ? entry.name == "p" : entry.text_content.to_s.strip.empty?
            end

            paragraphs
          end

          def render_figure_key(definition_list, doc)
            render_pairs(definition_list, doc,
                         term_key: :key_title,
                         definition_key: :key_text)
          end

          # Classic chain parity: the symbols dl becomes a two-column
          # table with one row per dt/dd pair. Both cells are always
          # emitted so the grid stays rectangular, like the classic
          # <td valign="top"> term/definition pair.
          def render_symbol_table(definition_list, doc)
            tbl = Uniword::Builder::TableBuilder.new
            terms = Array(definition_list.dt)
            definitions = Array(definition_list.dd)
            terms.each_with_index do |dt, i|
              tbl.row do |row|
                row.cell do |cell|
                  cell << render_cell_paragraph(dt, :table_body)
                end
                row.cell do |cell|
                  dd = definitions[i]
                  cell << render_cell_paragraph(dd, :table_body) if dd
                end
              end
            end
            doc << tbl
          end

          def render_cell_paragraph(node, style_key)
            para = build_paragraph(style_key)
            @inline_renderer.render(node, para)
            anchor_entry(node, para)
            para
          end

          # A dt/dd (and the p children rendered into the same paragraph)
          # keep their id as a bookmark on the paragraph that carries them.
          def anchor_entry(node, para)
            anchor_paragraph(node, para)
            Array(attribute_value(node, :p)).each do |p|
              anchor_paragraph(p, para)
            end
          end

          def render_general(definition_list, doc)
            render_pairs(definition_list, doc,
                         term_key: :definition,
                         definition_key: :definition)
          end

          def render_pairs(definition_list, doc, term_key:, definition_key:)
            terms = Array(definition_list.dt)
            definitions = Array(definition_list.dd)
            terms.each_with_index do |dt, i|
              append_pair(doc, dt, definitions[i], term_key, definition_key)
            end
          end

          def append_pair(doc, term, definition, term_key, definition_key)
            term_para = build_paragraph(term_key)
            @inline_renderer.render(term, term_para)
            anchor_entry(term, term_para)
            doc << term_para

            return unless definition

            definition_para = build_paragraph(definition_key)
            @inline_renderer.render(definition, definition_para)
            anchor_entry(definition, definition_para)
            doc << definition_para
          end
        end
      end
    end
  end
end
