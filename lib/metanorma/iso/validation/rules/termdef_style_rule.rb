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
        # Walks every term via TreeTraversal#each_term. Reads the first
        # definition's verbal-definition text and the preferred designation
        # text. The script/language gating mirrors the legacy rule.
        class TermdefStyleRule < Base
          code "ISO_4" # default; ISO_35 emitted explicitly for period-ending.

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

            text = extract_text(definition).strip
            return [] if text.empty?

            term_text = preferred_text(term)
            issues = []

            if state.lang.to_s == "en" && ARTICLE_REGEX.match?(text)
              issues << build_issue(code: "ISO_4", location: term_location(term),
                                    params: [term_text])
            end

            if PERIOD_SCRIPTS.include?(state.script.to_s) && PERIOD_REGEX.match?(text)
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
