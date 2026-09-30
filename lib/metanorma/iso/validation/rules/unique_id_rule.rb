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

          # Nodes whose +id+ is bibliographic *content* (docidentifier text,
          # ORCID, …), not an XML identity attribute. UniqueIdRule only cares
          # about the latter; Relaton repeats the same identifier across
          # amendment/relation graphs and must not be treated as a clash.
          NON_IDENTITY_ID_NODES = [
            "Metanorma::Document::Relaton::DocumentIdentifier",
            "Metanorma::Document::Relaton::OrgIdentifier",
            "Metanorma::Document::Relaton::PersonIdentifier",
            "Metanorma::Document::Relaton::OrgSubdivisionIdentifier",
          ].freeze

          # IsoPreface maps every front-matter <clause> into both +clause+
          # (IsoClauseSection) and +content+ (ContentSection) as a render
          # mirror. Only the typed clause instance is identity-bearing.
          MIRRORED_CONTENT_SECTION =
            "Metanorma::Standoc::Document::Sections::ContentSection"

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

          # Override TreeTraversal readers: only XML identity attributes count.
          def read_id_attr(node)
            return nil if non_identity_id_node?(node)
            return nil unless node.class.method_defined?(:id)

            value = node.id
            return nil if value.nil? || value.to_s.empty?

            value.to_s
          end

          def read_anchor_attr(node)
            return nil if mirrored_content_section?(node)
            return nil unless node.class.method_defined?(:anchor)

            value = node.anchor
            return nil if value.nil? || value.to_s.empty?

            value.to_s
          end

          def non_identity_id_node?(node)
            NON_IDENTITY_ID_NODES.include?(node.class.name) ||
              mirrored_content_section?(node)
          end

          def mirrored_content_section?(node)
            node.class.name == MIRRORED_CONTENT_SECTION
          end
        end
      end
    end
  end
end
