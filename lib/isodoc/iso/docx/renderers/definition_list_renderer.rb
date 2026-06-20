# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders <dl> definition lists with context-aware styling.
        #
        # Era C template provides two patterns:
        #   1. Formula key lists — <dt> as KeyTitle, <dd> as KeyText
        #      (used inside <formula> to define symbols)
        #   2. General definition lists — both <dt> and <dd> as Definition
        #      (used in terms sections and elsewhere)
        #
        # The renderer detects the formula zone via Context#zone (set by
        # Context#with_formula around FormulaRenderer's body) and picks
        # the appropriate pattern.
        class DefinitionListRenderer
          include Base

          def render(dl, doc)
            if @context.zone == :formula
              render_formula_key(dl, doc)
            else
              render_general(dl, doc)
            end
          end

          private

          def render_formula_key(dl, doc)
            terms = Array(dl.dt)
            definitions = Array(dl.dd)
            terms.each_with_index do |dt, i|
              title = build_paragraph(:key_title)
              @inline_renderer.render(dt, title)
              doc << title

              dd = definitions[i]
              next unless dd
              text = build_paragraph(:key_text)
              @inline_renderer.render(dd, text)
              doc << text
            end
          end

          def render_general(dl, doc)
            terms = Array(dl.dt)
            definitions = Array(dl.dd)
            terms.each_with_index do |dt, i|
              term = build_paragraph(:definition)
              @inline_renderer.render(dt, term)
              doc << term

              dd = definitions[i]
              next unless dd
              definition = build_paragraph(:definition)
              @inline_renderer.render(dd, definition)
              doc << definition
            end
          end
        end
      end
    end
  end
end
