# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_54 (House Style 2026-08, Referencing > References within the
        # document): when referring to figures and tables, give the citation
        # in the text before the place where the figure or table appears.
        #
        # Walks the document in document order, recording the position of
        # every numbered figure/table (anchor or id) and of every xref
        # targeting one (inline xrefs are collected from each node's mixed
        # content and direct xref attributes). A figure or table is flagged
        # when its earliest citation appears after the asset itself. Assets
        # never cited are UnreferencedAssetsRule's domain (ISO_21) and are
        # not flagged here — the two rules are mutually exclusive by
        # construction. Unnumbered assets are exempt (the House Style
        # requirement covers numbered assets only), and citations made from
        # within the asset itself (captions, cells) do not count: a figure
        # cannot cite itself into existence.
        class AssetCitedFirstRule < Base
          code "ISO_54"

          policy category: "Referencing > References within the document",
                 rule: "cite figures and tables in the text before the place where they appear in the document",
                 source: :house_style, mn_category: :references

          include DocumentOrderWalk

          FIGURE_CLASS = Metanorma::Document::Components::AncillaryBlocks::FigureBlock
          BASIC_FIGURE_CLASS = Metanorma::BasicDocument::AncillaryBlocks::FigureBlock
          TABLE_CLASS = Metanorma::Document::Components::Tables::TableBlock

          ASSET_CLASSES = [FIGURE_CLASS, BASIC_FIGURE_CLASS, TABLE_CLASS].freeze
          ASSET_NAME = {
            FIGURE_CLASS => "Figure",
            BASIC_FIGURE_CLASS => "Figure",
            TABLE_CLASS => "Table"
          }.freeze

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            root = context.root
            asset_at = {} # anchor → [node, walk position]
            cited_at = {} # anchor → earliest citing position

            each_document_node_with_position(root) do |node, ancestors, position|
              if asset?(node)
                anchor = read_anchor_attr(node) || read_id_attr(node)
                next if anchor.nil? || anchor.empty?
                next if unnumbered?(node)

                asset_at[anchor] ||= [node, position]
              elsif node.is_a?(XREF_CLASS)
                record_citation(cited_at, node.target, ancestors, position)
              end
              inline_xrefs(node).each do |xref|
                record_citation(cited_at, xref.target, ancestors + [node],
                                position)
              end
            end

            issues = []
            asset_at.each do |anchor, (node, position)|
              citation = cited_at[anchor]
              next if citation.nil? # uncited assets: ISO_21's domain
              next unless citation > position

              klass = ASSET_CLASSES.find { |k| node.is_a?(k) }
              issues << build_issue(
                location: model_location(node),
                params: [ASSET_NAME.fetch(klass), anchor]
              )
            end
            issues
          end

          private

          def asset?(node)
            ASSET_CLASSES.any? { |klass| node.is_a?(klass) }
          end

          def unnumbered?(node)
            return false unless node.class.method_defined?(:unnumbered)

            value = node.unnumbered
            value == true || value.to_s == "true"
          end

          def record_citation(cited_at, target, ancestors, position)
            target = target.to_s
            return if target.empty?
            return if enclosing_asset_anchors(ancestors).include?(target)

            cited_at[target] ||= position
          end

          # Inline xrefs reachable from +node+: its mixed content plus any
          # direct xref attribute (table cells, definition-list terms).
          # Deduplicated by object identity: nodes with mixed content can
          # expose the same xref both ways.
          def inline_xrefs(node)
            xrefs = []
            if node.class.method_defined?(:each_mixed_content)
              node.each_mixed_content do |item|
                xrefs << item if item.is_a?(XREF_CLASS)
              end
            end
            xrefs.concat(Array(node.xref)) if node.class.method_defined?(:xref)
            xrefs.uniq { |x| x.object_id }
          end

          # Anchors of figures/tables the node sits inside: a citation made
          # from within an asset cannot count as that asset's citation.
          def enclosing_asset_anchors(ancestors)
            ancestors.filter_map do |ancestor|
              next unless asset?(ancestor)

              read_anchor_attr(ancestor) || read_id_attr(ancestor)
            end.compact
          end
        end
      end
    end
  end
end
