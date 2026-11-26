# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_26: a Symbols and Abbreviated Terms section may only contain
        # a definition list (and title). Flags when other block content
        # (paragraphs, tables, examples) is present.
        class SymbolsSectionContentRule < Base
          include DeclarativeDispatch
          code "ISO_26"
          declarative_rule "iso.symbols.content"

          policy category: "Document structure",
                 rule: "a Symbols and Abbreviated Terms section may only contain a definition list",
                 source: :directives, directives: "17.5",
                 mn_category: :structure

          def applicable?(context)
            !context.root.nil?
          end

          def legacy_check(context)
            issues = []
            each_definitions_section(context.root) do |definitions, _parent|
              next if content_valid?(definitions)
              issues << build_issue(location: location_of(definitions), params: [])
            end
            issues
          end

          private

          def declarative_issue(finding, _context)
            # The context is the definitions container; Engine reports its
            # first forbidden child as the subject.
            node = finding.node.parent
            id = node["id"]
            location = id.nil? || id.empty? ? "definitions" : "definitions##{id}"
            build_issue(location: location, params: [])
          end

          # DefinitionSection exposes :paragraphs, :unordered_lists, :tables,
          # :examples in addition to :definition_lists. Only the latter (plus
          # the title, which is separate) is permitted by ISO_26.
          def content_valid?(definitions)
            Array(definitions.paragraphs).empty? &&
              Array(definitions.unordered_lists).empty? &&
              Array(definitions.tables).empty? &&
              Array(definitions.examples).empty?
          end

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
