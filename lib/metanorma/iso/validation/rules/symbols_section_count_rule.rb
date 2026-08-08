# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_25: at most one Symbols and Abbreviated Terms section, unless
        # this is a vocabulary document (which may have multiple).
        class SymbolsSectionCountRule < Base
          code "ISO_25"

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            count = enum_count(each_definitions_section(context.root))
            return [] if count <= 1
            return [] if context.state.vocab

            [build_issue(location: "definitions", params: [])]
          end

          private

          def enum_count(enumerator)
            count = 0
            enumerator.each { count += 1 }
            count
          end
        end
      end
    end
  end
end
