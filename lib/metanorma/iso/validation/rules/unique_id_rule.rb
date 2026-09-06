# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # STANDOC_36: every @id and @anchor must be unique within the
        # document. Walks every model node with an :id or :anchor attribute,
        # detects duplicates, and populates SharedState (doc_ids, doc_anchors,
        # id_seq, anchor_seq) for downstream xref rules (TODOs 23-26).
        #
        # The legacy Standoc::Validate#repeat_id_validate also populates
        # @doc_ids / @doc_anchors — that population continues to run via
        # super, but Iso::Validate overrides repeat_id_validate1 and
        # repeat_anchor_validate1 to skip duplicate detection (avoiding
        # double-reporting with this rule).
        class UniqueIdRule < Base
          code "STANDOC_36"

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            populate_shared_state(context)
            collect_duplicate_issues(context)
          end

          private

          def populate_shared_state(context)
            shared = context.shared
            return unless shared

            each_node_with_id_or_anchor(context.root) do |node, id, anchor|
              add_id(shared, id, node) if id
              add_anchor(shared, anchor, node) if anchor
            end
          end

          def add_id(shared, id, node)
            shared.doc_ids[id] ||= { node: node }
            shared.id_seq << id unless shared.id_seq.include?(id)
          end

          def add_anchor(shared, anchor, node)
            shared.doc_anchors[anchor] ||= { node: node }
            shared.anchor_seq << anchor unless shared.anchor_seq.include?(anchor)
          end

          def collect_duplicate_issues(context)
            issues = []
            seen_ids = {}
            seen_anchors = {}

            each_node_with_id_or_anchor(context.root) do |node, id, anchor|
              if id
                if seen_ids.key?(id)
                  issues << build_issue(location: model_location(node),
                                        params: [id, "duplicate"])
                else
                  seen_ids[id] = node
                end
              end
              next unless anchor

              if seen_anchors.key?(anchor)
                issues << build_issue(location: model_location(node),
                                      params: [anchor, "duplicate"])
              else
                seen_anchors[anchor] = node
              end
            end

            issues
          end
        end
      end
    end
  end
end
