# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::FormulaTransformer < Transformer::Base
        def transform(formula)
          ::Sts::NisoSts::DisplayFormula.new do |f|
            f.id = id_for(formula)

            formula_label = label_for(formula)
            f.label = formula_label if formula_label

            if formula.stem
              stem = formula.stem
              if stem.class.method_defined?(:math) && stem.math
                f.math = stem.math
              elsif stem.content
                tex = ::Sts::NisoSts::TexMath.new
                tex.content = [stem.content]
                f.tex_math = tex
              end
            end
          end
        end

        private

        def label_for(formula)
          autonum = formula.autonum if formula.class.method_defined?(:autonum)
          autonum && !autonum.to_s.empty? ? ::Sts::NisoSts::Label.new(content: [autonum.to_s]) : nil
        end
      end
    end
  end
end
