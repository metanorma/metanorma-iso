# frozen_string_literal: true

# Delegates to the shared engine (metanorma-document 0.5.15, Metanorma::Document::Sts)
# per metanorma-iso#1760 / metanorma-document#165.

module Metanorma
  module Iso
    module Sts
      module ParityValidator
        class Normaliser < Metanorma::Document::Sts::ParityValidator::Normaliser
        end
      end
    end
  end
end
