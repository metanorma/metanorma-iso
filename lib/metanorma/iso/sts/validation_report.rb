# frozen_string_literal: true

# Delegates to the shared engine (metanorma-document 0.5.15, Metanorma::Document::Sts)
# per metanorma-iso#1760 / metanorma-document#165.

module Metanorma
  module Iso
    module Sts
      class ValidationReport < Metanorma::Document::Sts::ValidationReport
      end
    end
  end
end
