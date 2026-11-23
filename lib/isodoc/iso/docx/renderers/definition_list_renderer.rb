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

          COMPONENTS = Metanorma::Document::Components
          DEFINITION_BLOCK_CLASSES = [
            COMPONENTS::Lists::OrderedList, COMPONENTS::Lists::UnorderedList,
            COMPONENTS::Lists::DefinitionList, COMPONENTS::Tables::TableBlock,
            COMPONENTS::Blocks::NoteBlock, COMPONENTS::AncillaryBlocks::ExampleBlock,
            COMPONENTS::AncillaryBlocks::SourcecodeBlock,
            COMPONENTS::AncillaryBlocks::FigureBlock,
            COMPONENTS::AncillaryBlocks::FormulaBlock,
            COMPONENTS::MultiParagraph::QuoteBlock,
            COMPONENTS::MultiParagraph::AdmonitionBlock,
            Metanorma::Iso::Document::Terms::TermNote
          ].freeze

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
            append_table_footnotes(table, footnotes, columns: 2, style_key: :table_footnote) unless footnotes.empty?
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
              next render_cell_blocks(node, cell) if block_definition?(node)

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
                row.cell { |cell| symbol_definition_cell(definitions[i], cell) }
              end
            end
            doc << tbl
          end

          def symbol_definition_cell(definition, cell)
            if block_definition?(definition)
              render_cell_blocks(definition, cell)
            elsif definition
              cell << render_cell_paragraph(definition, :table_body)
            end
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

            if block_definition?(definition)
              render_definition_blocks(definition, doc, definition_key)
            else
              definition_para = build_paragraph(definition_key)
              @inline_renderer.render(definition, definition_para)
              anchor_entry(definition, definition_para)
              doc << definition_para
            end
          end

          # A dd of several paragraphs, or one holding a list, note or other
          # block (a note may sit inside its paragraph), is walked child by
          # child; a dd of inline content or a single plain paragraph keeps
          # the one-paragraph path.
          def block_definition?(definition)
            return false unless ordered?(definition)

            children = ordered_children(definition)
            children.any? { |child| block_child?(child) || embeds_blocks?(child) } ||
              children.count { |child| paragraph?(child) } > 1
          end

          def ordered_children(node)
            children = []
            each_ordered_element(node) { |type, child| children << child if type == :element }
            children
          end

          def paragraph?(child)
            child.is_a?(COMPONENTS::Paragraphs::ParagraphBlock)
          end

          def block_child?(child)
            DEFINITION_BLOCK_CLASSES.any? { |klass| child.is_a?(klass) }
          end

          def embeds_blocks?(child)
            paragraph?(child) && ordered_children(child).any? { |inner| block_child?(inner) }
          end

          # Each child keeps its own block, in source order. Text and inline
          # elements between blocks share one paragraph; the dd's and each
          # paragraph's bookmark lands on the next paragraph emitted.
          def render_definition_blocks(definition, doc, key)
            stream_definition(definition, doc, key) do |child, target|
              @walker.dispatch(child, target)
            end
          end

          # Blocks in a table cell take the cell handlers' styling.
          def render_cell_blocks(definition, cell)
            target = TableCellElement::CellTarget.new(cell, :table_body)
            stream_definition(definition, target, :table_body) do |child, doc|
              if child.is_a?(COMPONENTS::Tables::TableBlock)
                @walker.dispatch(child, doc)
              else
                cell_registry.dispatch(child, doc)
              end
            end
            # A nested table must be followed by a paragraph in its cell.
            target << Uniword::Builder::ParagraphBuilder.new if Array(cell.model.element_order).last&.name == "tbl"
          end

          def cell_registry
            @cell_registry ||= TableCellElement::Registry.new(
              resolver: @resolver, inline_renderer: @inline_renderer,
            )
          end

          def term_note_renderer
            @term_note_renderer ||= NoteRenderer.new(
              resolver: @resolver, context: @context,
              inline_renderer: @inline_renderer, walker: @walker
            )
          end

          def stream_definition(definition, doc, key, &dispatch)
            state = { loose: nil, anchors: [definition], key: key, doc: doc,
                      dispatch: dispatch }
            stream_children(definition, state)
            flush_loose(state)
          end

          def stream_children(node, state)
            each_ordered_element(node) do |type, child|
              if type == :text
                add_loose(state) { |para| @inline_renderer.add_text(para, child) } unless child.strip.empty?
              elsif paragraph?(child)
                flush_loose(state)
                state[:anchors] << child
                stream_paragraph(child, state)
                flush_loose(state)
              elsif block_child?(child)
                flush_loose(state)
                if child.is_a?(Metanorma::Iso::Document::Terms::TermNote)
                  term_note_renderer.render(child, state[:doc])
                else
                  state[:dispatch].call(child, state[:doc])
                end
              else
                add_loose(state) { |para| @inline_renderer.dispatch_inline(child, para) }
              end
            end
          end

          # A plain paragraph renders whole; one that embeds a note is split
          # around it.
          def stream_paragraph(paragraph, state)
            if embeds_blocks?(paragraph)
              stream_children(paragraph, state)
            else
              add_loose(state) { |para| @inline_renderer.render(paragraph, para) }
            end
          end

          def add_loose(state)
            state[:loose] ||= build_paragraph(state[:key])
            yield state[:loose]
          end

          def flush_loose(state)
            para = state[:loose] or return

            state[:anchors].each { |node| anchor_paragraph(node, para) }
            state[:anchors] = []
            state[:doc] << para
            state[:loose] = nil
          end
        end
      end
    end
  end
end
