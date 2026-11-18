# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders formula blocks with MathML→OMML conversion via Plurimath.
      #
      # Each formula is rendered as a paragraph with the Formula style,
      # containing an oMathPara element (OMML) for the equation. The formula
      # name/label (e.g., "(1)") is rendered after the equation.
      #
      # Uses Plurimath for MathML→OMML conversion, falling back to text
      # rendering when conversion fails.
      #
      # When +walker+ is supplied, the renderer also dispatches the formula's
      # +:dl+ (symbol key list) and +:p+ (accompanying paragraphs) children
      # through the walker so they render via DefinitionListRenderer and
      # ParagraphRenderer respectively. All dispatch happens inside
      # +Context#with_formula+ so children pick up the formula zone via
      # StyleResolver and render symbol keys as formula_dl tables.
      class FormulaRenderer
        include ModelUtils
        include MathConversion

        def initialize(resolver, inline_renderer, context: nil, walker: nil)
          @resolver = resolver
          @inline = inline_renderer
          @context = context
          @walker = walker
        end

        # Render a formula block into the document. When a walker is
        # configured, also dispatch the formula's +:dl+ and +:p+ children
        # inside the formula zone.
        def render(formula, doc)
          if @context
            containers = Array(attribute_value(formula, :fmt_footnote_container))
            @context.with_formula(containers.flat_map(&:fmt_fn_body)) do
              render_body(formula, doc)
              walk_extras(formula, doc)
            end
          else
            render_body(formula, doc)
            walk_extras(formula, doc)
          end
        end

        private

        def walk_extras(formula, doc)
          return unless @walker

          @walker.walk_attribute(formula, :dl, doc)
          @walker.walk_attribute(formula, :p, doc)
          walk_key(formula, doc)
        end

        # Presentation XML wraps the formula's symbol list in <key>
        # (formula/key/dl); the semantic form keeps a bare <dl> sibling.
        # Without this walk the where-clause definitions silently
        # disappear from the rendered document.
        def walk_key(formula, doc)
          key = attribute_value(formula, :key)
          return unless key

          @walker.walk_attribute(key, :dl, doc)
          @walker.walk_attribute(key, :p, doc)
        end

        def render_body(formula, doc)
          mathml = extract_mathml(formula)

          if mathml && !mathml.empty?
            render_formula_with_omml(formula, mathml, doc)
          else
            render_formula_as_text(formula, doc)
          end
        end

        def extract_mathml(formula)
          # Try the presentation-layer fmt_stem first, then fall back to
          # the semantic stem. fmt_stem wraps the math in a <semx>
          # element so the math appears under semx[].math; stem carries
          # it directly as stem.math.
          stem_mathml(formula.fmt_stem) || stem_mathml(formula.stem)
        end

        # Build the formula paragraph with OMML math content.
        #
        # The equation, tab, and number all go through the
        # ParagraphBuilder `<<` API: direct collection writes bypass
        # element_order tracking, and both the DOCX serializer and the
        # MHTML writer then fall back to runs-before-math order, which
        # puts the ISO formula number ahead of its equation.
        def render_formula_with_omml(formula, mathml_string, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:formula)

          omml_para = convert_to_omml_para(mathml_string)
          if omml_para
            para << omml_para
            append_formula_name(formula, para)
            doc << para.build
          else
            render_formula_as_text(formula, doc)
          end
        rescue StandardError
          render_formula_as_text(formula, doc)
        end

        def convert_to_omml_para(mathml_string)
          omml_para_from_mathml(mathml_string)
        end

        # Render formula as plain text when OMML conversion fails.
        def render_formula_as_text(formula, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:formula)

          stem = formula.fmt_stem || formula.stem
          @inline.render(stem, para) if stem

          name = attribute_value(formula, :fmt_name)
          append_formula_name_to_builder(name, para) if name

          doc << para
        end

        # Append the formula name/label to a paragraph builder.
        def append_formula_name(formula, builder)
          name_text = formula_name_text(formula)
          return if name_text.nil? || name_text.empty?

          tab_run = Uniword::Wordprocessingml::Run.new
          tab_run.tab = Uniword::Wordprocessingml::Tab.new
          builder << tab_run

          builder << build_styled_run(name_text)
        end

        def append_formula_name_to_builder(name, para)
          name_text = formula_name_text_value(name)
          return if name_text.nil? || name_text.empty?

          tab_run = Uniword::Wordprocessingml::Run.new
          tab_run.tab = Uniword::Wordprocessingml::Tab.new
          para << tab_run

          if @inline.is_a?(InlineRenderer)
            @inline.add_text_with_char_style(para, name_text, :stem)
          else
            para << name_text
          end
        end

        # The formula's <fmt-name> label, e.g. "(1)". The presentation
        # XML wraps the autonum in a span tree (fmt-caption-label /
        # fmt-autonum-delim), so the flat-text-only collect_text returns
        # "" for it and the ISO formula number silently disappears.
        # Route the label through the InlineRenderer — the same walk the
        # figure captions use — and take the produced run text; fall
        # back to collect_text for flat shapes.
        def formula_name_text(formula)
          name = attribute_value(formula, :fmt_name)
          return unless name

          formula_name_text_value(name)
        end

        def formula_name_text_value(name)
          if @inline.is_a?(InlineRenderer) && ordered?(name)
            temp = Uniword::Builder::ParagraphBuilder.new
            @inline.render(name, temp)
            temp.model.text
          else
            collect_text(name)
          end
        end

        def build_styled_run(text)
          run = Uniword::Wordprocessingml::Run.new(text: text)
          style = @resolver.character_style(:stem)
          if style
            run.properties = Uniword::Wordprocessingml::RunProperties.new(
              style: Uniword::Properties::RunStyleReference.new(value: style),
            )
          end
          run
        end
      end
    end
  end
end
