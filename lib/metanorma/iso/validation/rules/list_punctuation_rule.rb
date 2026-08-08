# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: every list must be preceded by text ending in
        # a colon or full stop. ISO/IEC DIR 2 house style.
        #
        # Walks every clause/annex's children in document order. Uses
        # +each_mixed_content+ to track the previous sibling. When a
        # list (ol/ul) is encountered, inspects the last character of
        # the previous block's text content:
        #   ":" or empty → broken-sentence rules (handled by legacy
        #                  list_after_colon_punctuation for now)
        #   "."          → full-sentence rules (handled by legacy
        #                  list_full_sentence for now)
        #   other        → STANDOC_48 "All lists must be preceded by
        #                  colon or full stop"
        class ListPunctuationRule < Base
          code "STANDOC_48"

          ACCEPTABLE_PREFIXES = %w[: .].freeze
          ACCEPTABLE_SCRIPTS = %w[Cyrl Latn Grek].freeze

          def applicable?(context)
            !context.root.nil? &&
              ACCEPTABLE_SCRIPTS.include?(context.state.script.to_s)
          end

          def check(context)
            issues = []
            each_clause_holder(context.root) do |holder|
              issues.concat(check_holder(holder))
            end
            issues
          end

          private

          def each_clause_holder(root)
            return enum_for(__method__, root) unless block_given?

            yield_holder(root.sections) { |h| yield(h) } if root.sections
            Array(root.annex).each { |a| yield_holder(a) { |h| yield(h) } }
          end

          def yield_holder(holder, &block)
            return unless holder

            yield(holder)
            return unless holder.class.method_defined?(:clause)

            Array(holder.clause).each { |c| yield_holder(c, &block) }
          end

          # Walks the holder's children in document order, tracking the
          # previous block. When a list is encountered, examines the
          # previous block's last character.
          def check_holder(holder)
            issues = []
            previous_block = nil

            each_mixed_content_of(holder) do |item|
              next if item.is_a?(String)

              if list?(item)
                issues.concat(check_list(item, previous_block))
              end
              previous_block = item
            end
            issues
          end

          def each_mixed_content_of(node)
            return enum_for(__method__, node) unless block_given?

            return unless node.class.method_defined?(:each_mixed_content)

            node.each_mixed_content { |i| yield(i) }
          end

          def list?(item)
            item.is_a?(Metanorma::Document::Components::Lists::OrderedList) ||
              item.is_a?(Metanorma::Document::Components::Lists::UnorderedList)
          end

          def check_list(list, previous_block)
            prefix = last_char_of(previous_block)
            return [] if acceptable_prefix?(prefix)

            [build_issue(location: model_location(list),
                        params: ["All lists must be preceded by colon or full stop (got #{prefix.inspect})"])]
          end

          def last_char_of(block)
            return nil if block.nil?

            text = extract_text(block).strip
            text.empty? ? nil : text[-1]
          end

          def acceptable_prefix?(char)
            char.nil? || ACCEPTABLE_PREFIXES.include?(char)
          end
        end
      end
    end
  end
end
