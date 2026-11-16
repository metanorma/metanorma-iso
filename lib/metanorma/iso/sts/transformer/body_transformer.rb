# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class BodyTransformer < Base
          def transform(source)
            sections = []

            sections += front_transformer.preface_sections(source) if source.front?

            source.sections.each do |clause|
              sec = dispatcher.dispatch(clause)
              sections << sec if sec
            end

            ModelBuilder.body(sec: sections)
          end
        end
      end
    end
  end
end
