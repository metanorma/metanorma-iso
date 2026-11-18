# frozen_string_literal: true

require "plurimath"
require "omml"

module IsoDoc
  module Iso
    module Docx
      # Shared MathML → OMML conversion for stem content.
      #
      # Used by FormulaRenderer (block formulas, rendered as oMathPara on
      # a dedicated Formula paragraph) and InlineRenderers::StemRenderer
      # (inline stems, rendered as oMath runs inside the host paragraph).
      #
      # Conversion path: model MathML (Mml::V3::Math or subclasses) →
      # MathML string → Plurimath → OMML XML → Omml model objects. Every
      # step degrades to nil on failure so callers can fall back to text
      # rendering.
      module MathConversion
        include ModelUtils

        # Extract a MathML string from a stem-shaped model element.
        #
        # Accepts the shapes the presentation and semantic XML emit:
        # - semantic <stem>: the math under the :math attribute (singular
        #   or collection),
        # - presentation <fmt-stem>: the math under <semx> children,
        # - either: a raw MathML string under the content/text/value
        #   attributes.
        #
        # Returns nil when the element carries no usable MathML.
        def stem_mathml(stem)
          return nil unless stem

          mathml = mathml_from_stem_shape(stem)
          return mathml if mathml && !mathml.empty?

          extract_mathml_from_content(stem)
        end

        # Convert a MathML string into an Omml oMathPara model.
        # Returns nil when conversion fails (callers fall back to text).
        def omml_para_from_mathml(mathml_string)
          plurimath_formula = Plurimath::Mathml::Parser.new(mathml_string).parse
          omml_xml = plurimath_formula.to_omml
          return nil if omml_xml.nil? || omml_xml.empty?

          Omml.parse(omml_xml)
        rescue StandardError
          nil
        end

        # Convert a stem-shaped model element into inline OMML equation
        # models (Omml oMath children), suitable for appending to a
        # Uniword paragraph between text runs. Returns nil when the stem
        # carries no MathML or the conversion fails.
        def inline_omath_models(stem)
          mathml = stem_mathml(stem)
          return nil unless mathml

          omml_para = omml_para_from_mathml(mathml)
          return nil unless omml_para.is_a?(Omml::Models::OMathPara)

          omaths = omml_para.o_math.to_a
          omaths.empty? ? nil : omaths
        rescue StandardError
          nil
        end

        # 1.17.0 parity: a stem whose MathML is a bare number renders as
        # plain text, not as an equation object. Returns the digits when
        # the MathML carries exactly one <mn> with a digits-only payload
        # and no other MathML elements beyond the math/semantics/mrow
        # wrappers, nil otherwise.
        def number_only_stem_text(stem)
          mathml = stem_mathml(stem)
          return nil unless mathml.to_s.include?("<mn")

          digits = mathml.scan(%r{<mn[^>]*>([^<]*)</mn>}).flatten.join.strip
          return nil unless digits.match?(/\A\d+\z/)
          return nil unless mathml.scan(/<mn[\s>]/).length == 1

          wrappers = mathml.gsub(%r{<mn[^>]*>[^<]*</mn>}, "")
                           .scan(/<([a-zA-Z]+)[\s>]/).flatten
          return nil unless wrappers.all? { |tag| %w[math semantics mrow].include?(tag) }

          digits
        rescue StandardError
          nil
        end

        private

        # Direct :math attribute (semantic stem), then <semx>-wrapped
        # math (presentation fmt-stem).
        def mathml_from_stem_shape(stem)
          return "" unless stem.is_a?(Lutaml::Model::Serializable)

          if stem.class.attributes.key?(:math)
            mathml = mathml_from_value(stem.math)
            return mathml if mathml
          end

          if stem.class.attributes.key?(:semx)
            Array(stem.semx).each do |child|
              next unless child.class.attributes.key?(:math)

              mathml = mathml_from_value(child.math)
              return mathml if mathml
            end
          end

          ""
        end

        # Convert a single Mml::V3::Math, an array of them, or a raw
        # MathML string into a single MathML string. Returns "" when
        # the input is empty or unrecognised.
        def mathml_from_value(value)
          return "" if value.nil?

          case value
          when Array
            value.filter_map { |v| mathml_string_from_object(v) }.first || ""
          else
            mathml_string_from_object(value) || ""
          end
        end

        def mathml_string_from_object(obj)
          return obj if obj.is_a?(String)
          return nil unless obj.is_a?(Lutaml::Model::Serializable)

          xml = obj.to_xml
          xml&.strip&.empty? ? nil : xml
        rescue StandardError
          nil
        end

        # Some stems carry the MathML as a raw string under :content,
        # :text, or :value instead of a typed math attribute.
        def extract_mathml_from_content(node)
          [:content, :text, :value].each do |attr|
            next unless node.class.attributes.key?(attr)

            val = node.public_send(attr)
            return val if val.is_a?(String) && val.include?("<math")
          end
          nil
        end
      end
    end
  end
end
