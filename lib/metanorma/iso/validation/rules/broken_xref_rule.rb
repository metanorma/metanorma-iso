# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # STANDOC_38: every xref/@target must resolve to an existing
        # element with @id or @anchor in the document. Flags broken
        # cross-references.
        #
        # Self-contained: builds its own target index via
        # each_node_with_id_or_anchor rather than depending on
        # SharedState ordering (which varies by rule discovery order).
        class BrokenXrefRule < Base
          code "STANDOC_38"

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            targets = collect_all_targets(context.root)
            issues = []
            each_xref(context.root) do |xref|
              target = xref.target.to_s
              next if target.empty?
              next if targets.include?(target)

              issues << build_issue(location: model_location(xref),
                                    params: [target])
            end
            issues
          end

          private

          def collect_all_targets(root)
            targets = Set.new
            each_node_with_id_or_anchor(root) do |_node, id, anchor|
              targets << id if id
              targets << anchor if anchor
            end
            targets
          end
        end
      end
    end
  end
end
