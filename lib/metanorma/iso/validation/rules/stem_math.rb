# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Shared plurimath inspection for stem-content rules (ISO_143,
        # ISO_144). StyleRule strips stems from the prose text it lints
        # (+prose_exclusions+), so math-content rules walk the stem
        # elements themselves and inspect their content: plurimath — the
        # Metanorma math ecosystem parser — parses both the AsciiMath
        # source and the MathML a stem stores, making stem semantics
        # inspectable at the AST level.
        #
        # Extraction reads the stem's stored content in canonical
        # preference order: the AsciiMath source text when present, else
        # the MathML model's own XML serialization. Parsing is lazy
        # (plurimath is required at first use, the way
        # metanorma-document's native-models integration requires it)
        # and never raises: an unavailable parser or an unparseable stem
        # yields no findings, so the rules degrade to silence instead of
        # guessing at source they cannot read.
        module StemMath
          # Semantic stem carriers: the inline <stem> element and the
          # <stem> of a <formula> block. The rendered <fmt-stem> is the
          # presentation form of the same math and duplicates the
          # semantic stem, so it is not walked: it would double-report.
          STEM_CLASSES = [
            Metanorma::Document::Components::Inline::StemInlineElement,
            Metanorma::Document::Components::TextElements::StemElement,
          ].freeze

          # Yield every stem element in the document.
          def each_stem(root, &block)
            STEM_CLASSES.each { |klass| each_instance_of(root, klass, &block) }
          end

          # The math content stored on a stem, as [kind, payload]: kind
          # is :asciimath or :mathml, payload is the string plurimath
          # parses. AsciiMath is preferred: it is the canonical authored
          # source; MathML is the fallback for stems stored rendered.
          def math_source(stem)
            source = stem_asciimath_source(stem)
            return [:asciimath, source] unless source.nil? || source.empty?

            math = stem_math_model(stem)
            [:mathml, math.to_xml] if math
          end

          # Parse a stored stem source into a Plurimath AST, or nil when
          # plurimath is unavailable or the source does not parse.
          def parse_stem(kind, payload)
            require "plurimath"
            Plurimath::Math.parse(payload, kind)
          rescue StandardError, LoadError
            nil
          end

          private

          # The AsciiMath source of a stem, or nil. Inline stems carry a
          # collection of AsciimathElement (text-mapped); formula-block
          # stems carry a single Asciiml (value-mapped).
          def stem_asciimath_source(stem)
            source = stem.asciimath
            if source.is_a?(Metanorma::Document::Components::TextElements::Asciiml)
              return source.value
            end

            Array(source).filter_map do |element|
              element.text if element.is_a?(
                Metanorma::Document::Components::Inline::AsciimathElement
              )
            end.first
          end

          # The MathML model of a stem: SemanticMathElement instances on
          # inline stems, Mml::V3::Math on formula-block stems — both
          # serialize through #to_xml.
          def stem_math_model(stem)
            Array(stem.math).first
          end
        end
      end
    end
  end
end
