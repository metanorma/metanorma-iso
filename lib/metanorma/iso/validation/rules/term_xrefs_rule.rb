# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_50 / ISO_51: cross-references to terms clauses must come
        # from within a terms context.
        #
        # ISO_50: a terms-clause is referenced from a non-terms context
        #         (only terms clauses can cross-reference other terms).
        # ISO_51: a non-terms clause is referenced from a terms context.
        #
        # Walks every paragraph; for each xref, checks whether the target
        # is in a terms clause and whether the xref's containing clause is
        # also a terms clause.
        class TermXrefsRule < Base
          code "ISO_50" # default; ISO_51 emitted explicitly.

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            terms_anchors = collect_terms_anchors(context.root)
            issues = []

            each_paragraph_with_parent(context.root) do |paragraph, parent|
              parent_is_terms = terms_container?(parent)
              each_inline_with_preceding_text(paragraph) do |item, _|
                next unless item.is_a?(Metanorma::Document::Components::Inline::XrefElement)

                target = item.target.to_s
                target_is_terms = terms_anchors.include?(target)
                issues.concat(check_cross(target, target_is_terms, parent_is_terms, item))
              end
            end
            issues
          end

          private

          # Collect all id/anchor values from terms sections and clauses
          # containing nested terms sections.
          def collect_terms_anchors(root)
            anchors = Set.new
            return anchors unless root.sections

            visit_terms_anchor_holder(root.sections, anchors)
            Array(root.annex).each { |a| visit_terms_anchor_holder(a, anchors) }
            anchors
          end

          def visit_terms_anchor_holder(holder, anchors)
            return unless holder

            if holder.is_a?(Metanorma::Iso::Document::Sections::IsoTermsSection)
              record_self_anchor(anchors, holder)
            end
            return unless holder.class.method_defined?(:clause)

            Array(holder.clause).each { |c| visit_terms_anchor_holder(c, anchors) }
          end

          def record_self_anchor(anchors, node)
            id = read_id_attr(node)
            anchors << id if id
            anchor = read_anchor_attr(node)
            anchors << anchor if anchor
          end

          def terms_container?(node)
            return false unless node

            case node
            when Metanorma::Iso::Document::Sections::IsoTermsSection then true
            else
              contained_in_terms?(node)
            end
          end

          # Walk up via class introspection is not feasible without parent
          # pointers; we rely on the parent passed by each_paragraph_with_parent,
          # which is the clause/annex directly containing the paragraph.
          def contained_in_terms?(_node)
            false
          end

          def check_cross(target, target_is_terms, parent_is_terms, xref)
            issues = []
            if target_is_terms && !parent_is_terms
              issues << Metanorma::Iso::Validation::Issue.from_finding(
                code: "ISO_50", location: model_location(xref), params: [target]
              )
            elsif !target_is_terms && parent_is_terms
              issues << Metanorma::Iso::Validation::Issue.from_finding(
                code: "ISO_51", location: model_location(xref), params: [target]
              )
            end
            issues
          end
        end
      end
    end
  end
end
