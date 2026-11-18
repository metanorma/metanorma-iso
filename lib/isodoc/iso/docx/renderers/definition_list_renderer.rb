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
            footnotes = {}
            handler = ->(note, para) { collect_table_footnote(note, para, footnotes) }
            @context.with_formula_key_footnotes(handler) do
              terms.each_with_index do |term, index|
                table.row do |row|
                  formula_cell(row, term)
                  formula_cell(row, definitions[index])
                end
              end
            end
            append_table_footnotes(table, footnotes) unless footnotes.empty?
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
              formula_cell_content(node).each do |part|
                para = build_paragraph(:table_body)
                @inline_renderer.render(part, para) if part
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

          def collect_table_footnote(note, para, footnotes)
            label = note.reference

            append_footnote_label(para, label) unless note.hiddenref
            body = Array(@context.formula_footnote_bodies).find { |entry| entry.id == note.target }
            paragraphs = body ? Array(body.semx&.p) : Array(note.p)
            footnotes[note.target || label] ||= [label, paragraphs] unless paragraphs.empty?
          end

          def append_footnote_label(para, label)
            properties = Uniword::Wordprocessingml::RunProperties.new(
              vertical_align: Uniword::Properties::VerticalAlign.new(value: "superscript"),
            )
            para << Uniword::Wordprocessingml::Run.new(text: label, properties: properties)
          end

          def append_table_footnotes(table, footnotes)
            table.row do |row|
              row.cell do |cell|
                cell.column_span(2)
                footnotes.each_value do |label, paragraphs|
                  paragraphs.each_with_index do |part, index|
                    # The ISO templates have no tablefootnote paragraph style.
                    para = build_paragraph(:footnote_text)
                    if index.zero?
                      append_footnote_label(para, label)
                      para << " "
                    end
                    @inline_renderer.render(part, para)
                    cell << para
                  end
                end
              end
            end
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
            para
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
            doc << term_para

            return unless definition

            definition_para = build_paragraph(definition_key)
            @inline_renderer.render(definition, definition_para)
            doc << definition_para
          end
        end
      end
    end
  end
end
