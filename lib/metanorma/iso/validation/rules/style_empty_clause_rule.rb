# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: clauses and annexes carry content beyond their
        # title (ISO House Style). An empty clause — no content children
        # at all — and a note-only clause (whose only content is a note)
        # are both forbidden. A clause containing only subclauses is NOT
        # empty: the subclauses carry the content.
        class StyleEmptyClauseRule < Base
          code "STANDOC_48"

          policy category: "Document structure",
                 rule: "no clause or annex without content beyond its title; note-only clauses are forbidden",
                 source: :house_style, mn_category: :structure

          # Attribute names whose presence makes a clause non-empty.
          # Layout-only children (pagebreak, bookmark, columnbreak,
          # toc placeholders) do not count as content.
          CONTENT_ATTRIBUTES = %i[
            paragraphs ordered_lists unordered_lists definition_lists
            tables figures formulas examples sourcecode_blocks
            quote_blocks admonitions terms definitions references clause
            appendix term form requirement recommendation permission
            amend svgmaps imagemaps term_sources floating_title
          ].freeze

          NOTE_ATTRIBUTES = %i[notes].freeze

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            each_clause_holder(context.root) do |holder|
              next unless content_present?(holder).empty?

              issues << empty_clause_issue(holder)
            end
            issues
          end

          private

          # Yield every clause and annex, recursively.
          def each_clause_holder(root, &block)
            return enum_for(__method__, root) unless block

            visit_clause_holder(root.sections, &block) if root.sections
            Array(root.annex).each { |a| visit_clause_holder(a, &block) }
          end

          def visit_clause_holder(holder, &block)
            return unless holder

            yield(holder)
            Array(holder.clause).each { |c| visit_clause_holder(c, &block) } if holder.class.method_defined?(:clause)
            Array(holder.appendix).each { |a| visit_clause_holder(a, &block) } if holder.class.method_defined?(:appendix)
          end

          # The names of content attributes present on the holder. Notes
          # are not content: a clause whose only children are notes is a
          # note-only clause (still empty).
          def content_present?(holder)
            CONTENT_ATTRIBUTES.select do |attr|
              holder.class.method_defined?(attr) &&
                !Array(holder.public_send(attr)).empty?
            end
          end

          def empty_clause_issue(holder)
            message = if note_present?(holder)
                        "empty clause: the only content is a note; " \
                        "House Style forbids note-only clauses"
                      else
                        "empty clause: no content beyond the title; " \
                        "House Style forbids empty clauses and annexes"
                      end
            build_issue(location: model_location(holder), params: [message])
          end

          def note_present?(holder)
            NOTE_ATTRIBUTES.any? do |attr|
              holder.class.method_defined?(attr) &&
                !Array(holder.public_send(attr)).empty?
            end
          end
        end
      end
    end
  end
end
