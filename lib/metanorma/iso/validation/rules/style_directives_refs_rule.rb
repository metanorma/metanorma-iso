# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO/IEC Directives Parts 1 and 2 are not listed in Clause 2
        # (normative references) or in the Bibliography, and their text
        # is not reproduced (ISO House Style).
        class StyleDirectivesRefsRule < Base
          code "ISO_84"

          policy category: "Relationship with the ISO/IEC Directives, Parts 1 and 2",
                 rule: "do not list the ISO/IEC Directives in Clause 2 or the Bibliography, or reproduce their text",
                 source: :house_style, mn_category: :references

          # The extracted bibitem text concatenates attributes without
          # separators (id then docidentifier), so the left boundary
          # accepts any non-letter, not only a word boundary.
          DIRECTIVES_REGEX = /(?:\A|[^A-Za-z])ISO\/IEC\s+Directives\b/i.freeze
          PART_REGEX = /(?:,\s*)?Parts?\s+([1-9]\d*)\b/i.freeze

          def applicable?(context)
            !context.root.nil? && !context.root.bibliography.nil?
          end

          def check(context)
            issues = []
            Array(context.root.bibliography.references).each do |section|
              Array(section.references).each do |bibitem|
                issue = directives_issue(section, bibitem)
                issues << issue if issue
              end
            end
            issues
          end

          private

          def directives_issue(section, bibitem)
            text = extract_text(bibitem).strip
            match = text.match(DIRECTIVES_REGEX) or return nil

            part = part_number_after(text, match.end(0))
            return nil if part && !%w[1 2].include?(part)

            build_issue(
              location: bibitem_location(bibitem),
              params: ["do not list ISO/IEC Directives#{part_label(part)} " \
                       "in #{section_label(section)} or reproduce their text"]
            )
          end

          def part_number_after(text, offset)
            text[offset, 32]&.match(PART_REGEX)&.[](1)
          end

          def part_label(part)
            part ? " Part #{part}" : ""
          end

          def section_label(section)
            normative?(section) ? "Clause 2 (normative references)" : "the Bibliography"
          end

          def normative?(section)
            section.normative == true || section.normative.to_s == "true"
          end

          def bibitem_location(bibitem)
            id = read_id(bibitem)
            id.nil? || id.to_s.empty? ? "bibitem" : "bibitem##{id}"
          end
        end
      end
    end
  end
end
