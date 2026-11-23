# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_25: at most one Symbols and Abbreviated Terms section, unless
        # this is a vocabulary document (which may have multiple).
        class SymbolsSectionCountRule < Base
          include DeclarativeDispatch

          code "ISO_25"
          declarative_rule "iso.symbols.at-most-one"

          policy category: "Document structure",
                 rule: "at most one Symbols and Abbreviated Terms section (vocabulary documents excepted)",
                 source: :directives, directives: "17",
                 mn_category: :structure

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            return [] if context.state&.vocab

            super
          end

          private

          def declarative_issue(_finding, _context)
            build_issue(location: "DefinitionSection", params: [])
          end

          def legacy_check(context)
            count = enum_count(each_definitions_section(context.root))
            return [] if count <= 1
            return [] if context.state.vocab

            [build_issue(location: "DefinitionSection", params: [])]
          end

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
