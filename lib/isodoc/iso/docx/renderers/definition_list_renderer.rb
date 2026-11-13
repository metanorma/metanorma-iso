# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders <dl> definition lists with context-aware styling.
        #
        # Era C template provides two patterns:
        #   1. Key lists (formula or figure zone) — <dt> as KeyTitle,
        #      <dd> as KeyText. Used to define symbols in formulas and
        #      figure keys.
        #   2. General definition lists — both <dt> and <dd> as Definition
        #      (used in terms sections and elsewhere)
        #
        # The renderer detects the zone via Context#zone (set by
        # Context#with_formula / Context#with_figure around the parent
        # block's render) and picks the appropriate pattern.
        class DefinitionListRenderer
          include Base

          KEY_LIST_ZONES = %i[formula figure].freeze

          def render(definition_list, doc)
            if KEY_LIST_ZONES.include?(@context.zone)
              render_formula_key(definition_list, doc)
            else
              render_general(definition_list, doc)
            end
          end

          private

          def render_formula_key(definition_list, doc)
            render_pairs(definition_list, doc,
                         term_key: :key_title,
                         definition_key: :key_text)
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
