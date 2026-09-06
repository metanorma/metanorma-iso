# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_27: in vocabulary documents, Symbols and Abbreviated Terms
        # sections are only permitted in annexes.
        class SymbolsInAnnexRule < Base
          code "ISO_27"

          def applicable?(context)
            !context.root.nil? && context.state.vocab
          end

          def check(context)
            issues = []
            each_definitions_section(context.root) do |definitions, parent|
              next if parent == :annex
              issues << build_issue(location: location_of(definitions), params: [])
            end
            issues
          end

          private

          def location_of(definitions)
            id = definitions.id if definitions.class.method_defined?(:id)
            return "definitions" if id.nil? || id.to_s.empty?

            "definitions##{id}"
          end
        end
      end
    end
  end
end
