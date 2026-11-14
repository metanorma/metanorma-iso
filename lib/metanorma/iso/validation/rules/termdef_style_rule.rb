# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_4 / ISO_35: term-definition style.
        #
        # ISO_4 (English only): definition must not start with an article
        # ("the", "a"). Source: ISO/IEC DIR 2, 16.5.6.
        # ISO_35 (Cyrillic / Latin scripts): definition must not end with
        # a period.
        #
        # The ISO_35 test reads only the definition's final OWN text run
        # (TreeTraversal#last_own_text): footnote text, eref locality
        # digits, and other markup internals never count as the
        # definition's end.
        #   metanorma/metanorma-pdfa#118: "ICC.1 specifications" fired
        #   ISO_35 although the definition carried no trailing period.
        #
        # ISO/IEC DIR 2:2021, 16.5.6 states the no-full-stop rule without
        # a script qualifier ("It shall not start with an article ('the',
        # 'a') nor end with a full stop"), so the requirement is in
        # principle universal; the Cyrl/Latn gating is kept because the
        # companion article rule is plainly language-dependent and no
        # evidence supports widening the check to other scripts (CJK and
        # Arabic traditions punctuate differently). Widening is an owner
        # decision, not a correction.
        #
        # Walks every term via TreeTraversal#each_term. Reads the first
        # definition's verbal-definition text and the preferred designation
        # text. The script/language gating mirrors the legacy rule.
        class TermdefStyleRule < Base
          code "ISO_4" # default; ISO_35 emitted explicitly for period-ending.

          policy category: "Document structure",
                 rule: "a definition must not start with an article or end with a full stop",
                 source: :directives, directives: "16.5.6",
                 mn_category: :style

          ARTICLE_REGEX = /\A(the|a)\b/i.freeze
          PERIOD_REGEX = /\.\Z/.freeze
          PERIOD_SCRIPTS = %w[Cyrl Latn].freeze

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            each_term(context.root) do |term|
              issues.concat(check_term(term, context.state))
            end
            issues
          end

          private

          def check_term(term, state)
            definition = first_verbal_definition(term)
            return [] unless definition

            term_text = preferred_text(term)
            issues = []

            # ISO_4 tests the definition's opening as concatenated for the
            # reader (unchanged behavior).
            article_text = extract_text(definition).strip
            if state.lang.to_s == "en" && ARTICLE_REGEX.match?(article_text)
              issues << build_issue(code: "ISO_4", location: term_location(term),
                                    params: [term_text])
            end

            # ISO_35 tests only the definition's final own text run: footnote
            # text, eref locality digits, and other markup internals are not
            # the end of the definition the reader sees (pdfa#118).
            text = (last_own_text(definition) || "").strip
            if PERIOD_SCRIPTS.include?(state.script.to_s) &&
                !text.empty? && PERIOD_REGEX.match?(text)
              issues << build_issue(code: "ISO_35", location: term_location(term),
                                    params: [term_text])
            end

            issues
          end

          def first_verbal_definition(term)
            definitions = Array(term.definition)
            return nil if definitions.empty?

            definitions.first.verbal_definition
          end

          def preferred_text(term)
            preferreds = Array(term.preferred)
            return "" if preferreds.empty?

            extract_text(preferreds.first).strip
          end

          def term_location(term)
            id = term.id if term.class.method_defined?(:id)
            return "term" if id.nil? || id.to_s.empty?

            "term##{id}"
          end

          # Build an issue with an explicit code (overriding the class default).
          # Used because this rule emits both ISO_4 and ISO_35.
          def build_issue(code:, location:, params: [])
            Metanorma::Iso::Validation::Issue.from_finding(
              code: code, location: location, params: params
            )
          end
        end
      end
    end
  end
end
