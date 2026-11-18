# frozen_string_literal: true

require "plurimath"
require "omml"

module IsoDoc
  module Iso
    module Docx
      # MathML extraction and MathML→OMML conversion shared by block
      # formulas (FormulaRenderer, <m:oMathPara>) and inline stems
      # (InlineRenderers::StemRenderer, <m:oMath>).
      module MathmlOmml
        private

        # MathML string carried by a semantic <stem> (direct :math) or a
        # presentation <fmt-stem> (math nested in <semx>), or nil.
        def extract_mathml_from_stem(stem)
          return nil unless stem

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

          extract_mathml_from_content(stem)
        end

        # Parsed <m:oMathPara> for +mathml_string+, or nil when Plurimath
        # cannot convert it.
        def convert_to_omml_para(mathml_string)
          omml_xml = Plurimath::Mathml::Parser.new(mathml_string).parse.to_omml
          return nil if omml_xml.nil? || omml_xml.empty?

          Omml.parse(omml_xml)
        rescue StandardError
          nil
        end

        # Inline <m:oMath> elements for +mathml_string+: the oMath children
        # of the converted oMathPara. Empty when conversion fails.
        def convert_to_omml_inline(mathml_string)
          omml_para = convert_to_omml_para(mathml_string)
          return [] unless omml_para.respond_to?(:o_math)

          Array(omml_para.o_math).compact
        end

        # Convert a single Mml::V3::Math, an array of them, or a raw
        # MathML string into a single MathML string. Returns nil when
        # the input is empty or unrecognised.
        def mathml_from_value(value)
          return nil if value.nil?

          case value
          when Array
            value.filter_map { |v| mathml_string_from_object(v) }.first
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
          %i[content text value].each do |attr|
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
