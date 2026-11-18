# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class BodyTransformer < Base
          def transform(source)
            sections = []

            # The foreword/introduction are front secs (FrontTransformer);
            # boilerplate copyright is std-meta content only. The body
            # carries the document's own sections (Guidelines 4.3/4.4).
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
