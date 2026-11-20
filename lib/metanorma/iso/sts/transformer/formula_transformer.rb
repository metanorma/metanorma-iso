# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class FormulaTransformer < Base
          def transform(source_formula)
            id = source_formula.id if source_formula.id
            label = extract_label(source_formula)
            math = extract_math(source_formula)
            ModelBuilder.disp_formula(id: id, label: label, math: math)
          end

          private

          def extract_label(source_formula)
            
            fmt_name = Array(source_formula.fmt_name).first
            return nil unless fmt_name
            RenderedTextExtractor.text_of(fmt_name)
          end

          # MathML passthrough: extract <math> from the formula's stem and
          # parse into Mml::V3::Math. Delegates to MathmlBuilder so the
          # math extraction logic lives in one place. Zero Nokogiri.
          def extract_math(source_formula)
            stem = first_stem(source_formula)
            return nil unless stem

            ::Metanorma::Iso::Sts::MathmlBuilder.math_from_stem(stem)
          end

          def first_stem(source_formula)
            if source_formula.stem
              Array(source_formula.stem).first
            elsif source_formula.class.attributes.key?(:formula) && source_formula.formula
              formula_el = Array(source_formula.formula).first
              Array(formula_el.stem).first if formula_el
            end
          end
        end
      end
    end
  end
end
