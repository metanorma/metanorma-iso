# frozen_string_literal: true

require "plurimath"

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
      # The renderer wraps its body in +Context#with_formula+ so that
      # DefinitionListRenderer can detect formula context and switch to
      # KeyTitle/KeyText styling for the formula's symbol key list.
      class FormulaRenderer
        def initialize(resolver, inline_renderer, context: nil)
          @resolver = resolver
          @inline = inline_renderer
          @context = context
        end

        # Render a formula block into the document.
        def render(formula, doc)
          if @context
            @context.with_formula { render_body(formula, doc) }
          else
            render_body(formula, doc)
          end
        end

        private

        def render_body(formula, doc)
          mathml = extract_mathml(formula)

          if mathml && !mathml.empty?
            render_formula_with_omml(formula, mathml, doc)
          else
            render_formula_as_text(formula, doc)
          end
        end

        private

        def extract_mathml(formula)
          stem = formula.fmt_stem || formula.stem
          return nil unless stem

          # Primary path: stem.math is an Mml::V3::Math object with to_xml
          if stem.class.attributes.key?(:math)
            math_obj = stem.math
            if math_obj && !math_obj.nil?
              mathml = math_obj.to_xml
              return mathml if mathml && !mathml.strip.empty?
            end
          end

          # Secondary: mathml attribute
          if stem.class.attributes.key?(:mathml)
            mathml = stem.mathml
            return mathml if mathml && !mathml.to_s.empty?
          end

          extract_mathml_from_content(stem)
        end

        def extract_mathml_from_content(node)
          [:content, :text, :value].each do |attr|
            next unless node.class.attributes.key?(attr)
            val = node.public_send(attr)
            return val if val.is_a?(String) && val.include?("<math")
          end
          nil
        end

        # Build the formula paragraph with OMML math content.
        def render_formula_with_omml(formula, mathml_string, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:formula)

          omml_para = convert_to_omml_para(mathml_string)
          if omml_para
            built = para.build
            built.o_math_paras << omml_para
            append_formula_name(formula, built)
            doc << built
          else
            render_formula_as_text(formula, doc)
          end
        rescue StandardError
          render_formula_as_text(formula, doc)
        end

        def convert_to_omml_para(mathml_string)
          plurimath_formula = Plurimath::Mathml::Parser.new(mathml_string).parse
          omml_xml = plurimath_formula.to_omml
          return nil if omml_xml.nil? || omml_xml.empty?

          Uniword::Math::OMathPara.from_xml(omml_xml)
        rescue StandardError
          nil
        end

        # Render formula as plain text when OMML conversion fails.
        def render_formula_as_text(formula, doc)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:formula)

          stem = formula.fmt_stem || formula.stem
          @inline.render(stem, para) if stem

          name = formula.fmt_name if formula.class.attributes.key?(:fmt_name)
          append_formula_name_to_builder(name, para) if name

          doc << para
        end

        # Append the formula name/label to a built paragraph model.
        def append_formula_name(formula, built_para)
          name = formula.fmt_name if formula.class.attributes.key?(:fmt_name)
          return unless name

          name_text = collect_text(name)
          return if name_text.nil? || name_text.empty?

          tab_run = Uniword::Wordprocessingml::Run.new
          tab_run.tab = Uniword::Wordprocessingml::Tab.new
          built_para.runs << tab_run

          name_run = build_styled_run(name_text)
          built_para.runs << name_run
        end

        def append_formula_name_to_builder(name, para)
          name_text = collect_text(name)
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

        def collect_text(node)
          return node.to_s if node.is_a?(String)
          return "" unless node

          texts = []
          [:text, :content, :content_text].each do |attr|
            next unless node.is_a?(Lutaml::Model::Serializable)
            next unless node.class.attributes.key?(attr)
            val = node.public_send(attr)
            case val
            when Array then texts.concat(val.grep(String))
            when String then texts << val
            end
          end
          texts.compact.join
        end
      end
    end
  end
end
