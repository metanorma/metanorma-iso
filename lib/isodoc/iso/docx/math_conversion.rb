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

        NUMBER_WRAPPER_TAGS = %w[math semantics mrow mstyle].freeze

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
          return nil if mathml.nil? || visibly_blank_mathml?(mathml)

          cached_inline_omaths(mathml)
        rescue StandardError
          nil
        end

        # Plurimath plus Omml.parse cost ~26 ms a stem; ISO 2533 has 957
        # non-numeric stems but only 236 distinct ones (25.6 ms fresh,
        # 5.1 ms repeated). The oMath models are only serialized, so
        # paragraphs share them. Failures are cached too (nil).
        def cached_inline_omaths(mathml)
          @inline_omath_cache ||= {}
          return @inline_omath_cache[mathml] if @inline_omath_cache.key?(mathml)

          @inline_omath_cache[mathml] = build_inline_omaths(mathml)
        end

        def build_inline_omaths(mathml)
          omml_para = omml_para_from_mathml(mathml)
          return nil unless omml_para.is_a?(Omml::Models::OMathPara)

          omaths = omml_para.o_math.to_a
          omaths.empty? ? nil : omaths
        end

        # 1.17.0 parity: a stem whose MathML is a bare number renders as
        # plain text, not as an equation object. Returns the number when
        # the MathML is exactly one <mn> matching NUMBER_PATTERN (signed,
        # grouped, decimal: the shapes Adapter#flatten_number_stems
        # flattens) inside only math/semantics/mrow wrappers or an
        # unstyled mstyle, nil otherwise. Keeping this in step with the
        # adapter makes a stem render the same before and after
        # flattening.
        def number_only_stem_text(stem)
          mathml = stem_mathml(stem)
          return nil unless mathml.to_s.include?("<mn")

          node = Nokogiri::XML(mathml).root
          node = visible_children(node).first while number_wrapper?(node)
          return nil unless node&.name == "mn" && node.element_children.empty?

          number = node.text.strip
          number if NUMBER_PATTERN.match?(number)
        rescue StandardError
          nil
        end

        private

        # MathML with no text content (an empty <mi/>) would convert to
        # an empty oMath and drop the stem; callers fall back to text.
        def visibly_blank_mathml?(mathml)
          Nokogiri::XML.fragment(mathml).text.strip.empty?
        end

        # Children that draw something: <mspace/> is spacing only.
        def visible_children(node)
          node.element_children.reject { |child| child.name == "mspace" }
        end

        # A wrapper with one visible child, to be looked through. A
        # mstyle/mrow with attributes other than displaystyle changes
        # rendering, so it is not a bare-number wrapper.
        def number_wrapper?(node)
          return false unless node && NUMBER_WRAPPER_TAGS.include?(node.name)
          return false unless visible_children(node).one?

          node.attribute_nodes.all? { |attr| attr.name == "displaystyle" }
        end

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
