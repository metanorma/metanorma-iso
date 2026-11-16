# frozen_string_literal: true

# MathML passthrough helper.
#
# Design note: previously this module extracted plain text from MathML via
# regex symbol rules, subscript/superscript rewriting, and asciimath
# conversion. That approach was wrong — mnconvert (the production
# Metanorma→STS converter) copies MathML verbatim into <inline-formula>.
# We do the same via Mml::V3::Math.from_xml + Sts::NisoSts::InlineFormula.
#
# The text-extraction methods (asciimath_to_plain_text, mathml_to_plain_text,
# apply_symbol_rules, apply_subscript_rules, apply_superscript_rules) were
# removed. No code should reach back into this module for math rendering —
# inline/dispatched formulas pass MathML through structurally.
module Metanorma
  module Iso
    module Sts
      module MathmlBuilder
        module_function

        MATHML_NS = "http://www.w3.org/1998/Math/MathML"

        def wrap_math_content(content)
          "<math xmlns='#{MATHML_NS}'>#{content}</math>"
        end

        # The Math model class nominally paired with a formula wrapper
        # class. sts >= 0.6.0 unified all MathML on Mml::V3::Math across
        # IsoSts, NisoSts, and TbxIsoTml, so this is always Mml::V3::Math
        # regardless of the formula wrapper's namespace. Kept as a
        # method (not a constant) so callers don't hard-code the class.
        def math_klass_for(_formula_klass)
          Mml::V3::Math
        end

        # Builds a math model instance from a stem-bearing typed model node.
        # Handles StemInlineElement (.math), StemBlockElement (.math),
        # and FmtStemElement (.semx[].math). Returns nil when the node
        # carries no parseable MathML — callers should silently drop
        # the formula in that case (mnconvert's behavior).
        #
        # `klass:` selects which typed Math model to instantiate.
        # Defaults to Mml::V3::Math — the canonical MathML model used
        # by sts >= 0.6.0 across IsoSts, NisoSts, and TbxIsoTml.
        def math_from_stem(stem_node, klass: Mml::V3::Math)
          math_el = first_math_element(stem_node)
          return nil unless math_el

          # The stem's `math` attribute already carries a typed MML model
          # (SemanticMathElement inherits Mml::V3::Math). Passing it
          # straight through avoids the earlier stringify-and-reparse
          # roundtrip — which depended on `math_el.content` and broke
          # when the typed model changed shape.
          return math_el if math_el.is_a?(klass)

          # Fallback for any future stem shape that isn't already an
          # Mml::V3::Math subclass: build from its serialized XML.
          string = math_el.to_s
          return nil if string.empty?

          klass.from_xml(wrap_math_content(string))
        rescue StandardError
          nil
        end

        # Wraps the stem's MathML in an InlineFormula for
        # use inside paragraphs and table cells. Returns nil if the
        # stem carries no parseable MathML.
        #
        # Always uses Mml::V3::Math — the canonical MathML model,
        # unified across all STS namespaces in sts >= 0.6.0.
        def inline_formula_from_stem(stem_node, klass: ::Sts::NisoSts::InlineFormula)
          math = math_from_stem(stem_node, klass: Mml::V3::Math)
          return nil unless math

          klass.new(math: math)
        end

        # SemanticMathElement is a subclass of Mml::V3::Math — already
        # a fully-typed Math model. The earlier stringify/re-parse path
        # broke because SemanticMathElement doesn't expose a `.content`
        # accessor at the Lutaml level.
        def first_math_element(stem_node)
          if stem_node.is_a?(Metanorma::Document::Components::Inline::FmtStemElement)
            Array(stem_node.semx).flat_map { |semx| Array(semx.math) }.first
          elsif stem_node.class.method_defined?(:math)
            Array(stem_node.math).first
          end
        end
      end
    end
  end
end
