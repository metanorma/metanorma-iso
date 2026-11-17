# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders <dl> definition lists with context-aware styling.
        #
        # Era C template provides three patterns:
        #   1. Key lists (formula or figure zone) — <dt> as KeyTitle,
        #      <dd> as KeyText. Used to define symbols in formulas and
        #      figure keys.
        #   2. Symbols-clause lists (:definitions zone) — a two-column
        #      table, one row per dt/dd pair with the term in the first
        #      cell and the definition in the second. This mirrors the
        #      classic isodoc Word chain, which rendered every dl not
        #      nested in a table as a table
        #      (WordFunction::Body#dl_parse_table). Scoped to the
        #      "Symbols and abbreviated terms" clause so general dls keep
        #      their paragraph rendering.
        #   3. General definition lists — both <dt> and <dd> as Definition
        #      (used in terms sections and elsewhere)
        #
        # The renderer detects the zone via Context#zone (set by
        # Context#with_formula / #with_figure / #with_definitions around
        # the parent block's render) and picks the appropriate pattern.
        class DefinitionListRenderer
          include Base
          include ListAttachments

          KEY_LIST_ZONES = %i[formula figure].freeze
          SYMBOL_TABLE_ZONES = %i[definitions].freeze

          def render(definition_list, doc)
            if KEY_LIST_ZONES.include?(@context.zone)
              render_formula_key(definition_list, doc)
            elsif SYMBOL_TABLE_ZONES.include?(@context.zone)
              render_symbol_table(definition_list, doc)
            else
              render_general(definition_list, doc)
            end
            render_attached_notes(definition_list, doc)
          end

          private

          def render_formula_key(definition_list, doc)
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
