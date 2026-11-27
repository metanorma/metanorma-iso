# frozen_string_literal: true

# Delegates to the shared engine (metanorma-document 0.5.15, Metanorma::Document::Sts)
# per metanorma-iso#1760 / metanorma-document#165. The engine class is
# registry-wired (context.build) and resolves neutral by default.

module Metanorma
  module Iso
    module Sts
      module Transformer
        class QuoteTransformer < Metanorma::Document::Sts::Transformer::QuoteTransformer
        end
      end
    end
  end
end
