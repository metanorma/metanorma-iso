# frozen_string_literal: true

require "plurimath"
require "omml"

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
      # StyleResolver (e.g., KeyTitle / KeyText for the dl's items).
      class FormulaRenderer
        include ModelUtils

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
            @context.with_formula do
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
          extract_mathml_from_stem(formula.fmt_stem) ||
            extract_mathml_from_stem(formula.stem)
        end

        def extract_mathml_from_stem(stem)
          return nil unless stem

          # Direct :math attribute (Mml::V3::Math or array of them).
          if stem.class.attributes.key?(:math)
            mathml = mathml_from_value(stem.math)
            return mathml if mathml
          end

          # Wrapped in semx children (presentation-layer fmt_stem).
          if stem.class.attributes.key?(:semx)
            Array(stem.semx).each do |child|
              next unless child.class.attributes.key?(:math)

              mathml = mathml_from_value(child.math)
              return mathml if mathml
            end
          end

          extract_mathml_from_content(stem)
        end

        # Convert a single Mml::V3::Math, an array of them, or a raw
        # MathML string into a single MathML string. Returns nil when
        # the input is empty or unrecognised.
        def mathml_from_value(value)
          return nil if value.nil?

          case value
          when Array
            value.map { |v| mathml_string_from_object(v) }.compact.first
          else
            mathml_string_from_object(value)
          end
        end

        def mathml_string_from_object(obj)
          return obj.to_s if obj.is_a?(String)
          return nil unless obj.is_a?(Lutaml::Model::Serializable)

          xml = obj.to_xml
          xml&.strip&.empty? ? nil : xml
        rescue StandardError
          nil
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

          Omml.parse(omml_xml)
        rescue StandardError
          nil
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

        # Append the formula name/label to a built paragraph model.
        def append_formula_name(formula, built_para)
          name = attribute_value(formula, :fmt_name)
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
      end
    end
  end
end
