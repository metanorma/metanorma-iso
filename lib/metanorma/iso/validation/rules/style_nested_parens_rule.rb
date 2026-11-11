# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for parentheses (ISO House Style):
        #
        #   - nested parentheses "(...(...)...)" are rewritten using
        #     square brackets outside or commas;
        #   - more than two parenthetical sets in one sentence: use at
        #     most two (advisory).
        class StyleNestedParensRule < StyleRule
          # An opening parenthesis inside an unmatched outer pair.
          NESTED_PARENS_REGEX = /\([^()]*\(/.freeze

          # Parenthetical set within a sentence.
          PAREN_GROUP_REGEX = /\([^)]*\)/.freeze

          # Sentence boundary for the group-count advisory.
          SENTENCE_SPLIT_REGEX = /(?<=[.!?])\s+/.freeze

          MAX_PAREN_GROUPS_PER_SENTENCE = 2

          # Scan the paragraph's own mixed-content text, not the joined
          # extract: extract_text repeats the paragraph body (plain text +
          # derived json content), which would double-count the
          # parenthetical sets in the per-sentence advisory.
          def check(context)
            issues = []
            each_paragraph_with_parent(context.root) do |paragraph, parent|
              text = paragraph_text(paragraph)
              next if text.nil? || text.strip.empty?

              issues.concat(scan_text(parent, text))
            end
            issues.uniq { |issue| issue.params.first }
          end

          def scan_text(node, text)
            finding_if_match(node, text, NESTED_PARENS_REGEX,
                             "nested parentheses: rewrite using " \
                             "square brackets outside or commas") +
              sentences_with_too_many_groups(node, text)
          end

          private

          def paragraph_text(paragraph)
            return nil unless paragraph.class.method_defined?(:text)

            Array(paragraph.text).join
          end

          def sentences_with_too_many_groups(node, text)
            text.split(SENTENCE_SPLIT_REGEX).filter_map do |sentence|
              next unless sentence.scan(PAREN_GROUP_REGEX).size > MAX_PAREN_GROUPS_PER_SENTENCE

              build_warning(node, "more than #{MAX_PAREN_GROUPS_PER_SENTENCE} " \
                                  "parenthetical sets in one sentence: use at most " \
                                  "#{MAX_PAREN_GROUPS_PER_SENTENCE}")
            end
          end
        end
      end
    end
  end
end
