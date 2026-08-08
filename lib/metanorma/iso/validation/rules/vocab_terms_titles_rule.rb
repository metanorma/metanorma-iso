# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_44 / ISO_45: vocabulary documents have specific term-heading
        # rules.
        #
        # ISO_44: a single terms clause should have the heading
        # "Terms and definitions" (i18n.termsdef).
        # ISO_45: when there are multiple terms clauses, each should start
        # with "Terms related to" (i18n.termsrelated).
        #
        # Walks every terms section via TreeTraversal#each_terms_section.
        # Gated on context.state.vocab.
        class VocabTermsTitlesRule < Base
          code "ISO_44" # default; ISO_45 emitted explicitly for multi-case.

          def applicable?(context)
            !context.root.nil? && context.state.vocab
          end

          def check(context)
            terms_sections = enum_to_a(each_terms_section(context.root))
            return [] if terms_sections.empty?

            if terms_sections.size == 1
              check_single(context, terms_sections.first)
            else
              terms_sections.flat_map { |s| check_multiple(context, s) }
            end
          end

          private

          def check_single(context, section)
            expected = termsdef_text(context)
            return [] if title_matches?(section, expected)

            [build_issue_explicit("ISO_44", section)]
          end

          def check_multiple(context, section)
            expected_prefix = termsrelated_text(context)
            return [] if title_start_with?(section, expected_prefix)

            [build_issue_explicit("ISO_45", section)]
          end

          def termsdef_text(context)
            context.state.i18n&.termsdef
          end

          def termsrelated_text(context)
            context.state.i18n&.termsrelated
          end

          def title_matches?(section, expected)
            return false if expected.nil?

            title = section_title(section)
            !title.nil? && title == expected
          end

          def title_start_with?(section, expected_prefix)
            return false if expected_prefix.nil?

            title = section_title(section)
            !title.nil? && title.start_with?(expected_prefix)
          end

          def section_title(section)
            return nil unless section.class.method_defined?(:title)

            title = section.title
            return nil if title.nil?

            extract_text(title).strip
          end

          def build_issue_explicit(code, section)
            Metanorma::Iso::Validation::Issue.from_finding(
              code: code, location: section_location(section), params: []
            )
          end

          def section_location(section)
            id = section.id if section.class.method_defined?(:id)
            return "terms" if id.nil? || id.to_s.empty?

            "terms##{id}"
          end

          def enum_to_a(enumerator)
            enumerator.to_a
          end
        end
      end
    end
  end
end
