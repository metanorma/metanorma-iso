# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
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
        def initialize(resolver, inline_renderer, context)
          @resolver = resolver
          @inline_renderer = inline_renderer
          @context = context
        end

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
            title_para = build_paragraph(@resolver.paragraph_style(:key_title))
            @inline_renderer.render(dt, title_para)
            doc << title_para

            dd = definitions[i]
            next unless dd
            text_para = build_paragraph(@resolver.paragraph_style(:key_text))
            @inline_renderer.render(dd, text_para)
            doc << text_para
          end
        end

        def render_general(dl, doc)
          terms = Array(dl.dt)
          definitions = Array(dl.dd)
          terms.each_with_index do |dt, i|
            term_para = build_paragraph(@resolver.paragraph_style(:definition))
            @inline_renderer.render(dt, term_para)
            doc << term_para

            dd = definitions[i]
            next unless dd
            definition_para = build_paragraph(@resolver.paragraph_style(:definition))
            @inline_renderer.render(dd, definition_para)
            doc << definition_para
          end
        end

        def build_paragraph(style)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = style if style
          para
        end
      end
    end
  end
end
