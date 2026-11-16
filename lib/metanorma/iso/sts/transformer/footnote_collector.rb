# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Collects footnotes during conversion so they can be flushed to the
        # right location in the STS output.
        class FootnoteCollector
          def initialize
            @seen = {}
            @counter = 0
          end

          def register(source_id)
            return @seen[source_id] if @seen.key?(source_id)

            @counter += 1
            @seen[source_id] = "fn_#{@counter}"
          end

          def known?(source_id)
            @seen.key?(source_id)
          end

          def size
            @seen.size
          end
        end
      end
    end
  end
end
