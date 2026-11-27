# frozen_string_literal: true

# Delegates to the shared engine (metanorma-document 0.5.15, Metanorma::Document::Sts)
# per metanorma-iso#1760 / metanorma-document#165. The engine class is
# registry-wired (context.build) and resolves neutral by default.

module Metanorma
  module Iso
    module Sts
      module Transformer
        class NoteTransformer < Metanorma::Document::Sts::Transformer::NoteTransformer
          # Guidelines 5.6: a note's designation is NOTE, EXAMPLE or WARNING
          # (with any number). A warning is a note labelled WARNING with
          # @content-type="warning". The engine labels an admonition with its
          # MN type upcased, which gives <label>CAUTION</label> for a caution,
          # a designation the guidelines do not allow. A caution is coded as
          # a warning instead.
          def transform(source_note)
            model = super
            return model unless model.is_a?(::Sts::NisoSts::NonNormativeNote) && caution?(source_note)

            model.content_type = "warning"
            model
          end

          private

          def admonition_label(source)
            caution?(source) ? "WARNING" : super
          end

          def caution?(source)
            source.is_a?(admonition_block_class) &&
              attribute_string(source, :type) == "caution"
          end
        end
      end
    end
  end
end
