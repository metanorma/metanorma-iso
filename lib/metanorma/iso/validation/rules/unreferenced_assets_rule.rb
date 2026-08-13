# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_21 / ISO_22: every numbered asset (annex, table, figure,
        # formula) must be cross-referenced at least once via <xref>.
        # Unreferenced assets clutter the document. ISO_22 fires for
        # formulas; ISO_21 for the others.
        class UnreferencedAssetsRule < Base
          code "ISO_21"

          ASSET_TYPES = {
            "Annex" => :annex,
            "Table" => :table,
            "Figure" => :figure,
            "Formula" => :formula
          }.freeze

          CODE_BY_ASSET_NAME = {
            "Annex" => "ISO_21",
            "Table" => "ISO_21",
            "Figure" => "ISO_21",
            "Formula" => "ISO_22"
          }.freeze

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            referenced = collect_xref_targets(context.root)
            issues = []

            collect_assets(context.root) do |asset_name, anchor, node|
              next if anchor.nil? || anchor.to_s.empty?
              next if referenced.include?(anchor)
              next if unnumbered?(node)

              issues << build_issue_explicit(asset_name, anchor, node)
            end
            issues
          end

          private

          def collect_xref_targets(root)
            targets = Set.new
            each_xref(root) { |x| targets << x.target.to_s if x.target }
            targets
          end

          def collect_assets(root)
            yield_each_asset_of_type(root, Metanorma::Iso::Document::Sections::IsoAnnexSection, "Annex") { |n, a, m| yield(m, a, n) }
            yield_each_asset_of_type(root, Metanorma::Document::Components::Tables::TableBlock, "Table") { |n, a, m| yield(m, a, n) }
            yield_each_asset_of_type(root, Metanorma::BasicDocument::AncillaryBlocks::FigureBlock, "Figure") { |n, a, m| yield(m, a, n) }
            yield_each_asset_of_type(root, Metanorma::Document::Components::AncillaryBlocks::FormulaBlock, "Formula") { |n, a, m| yield(m, a, n) }
          end

          def yield_each_asset_of_type(root, klass, asset_name)
            each_instance_of(root, klass) do |node|
              anchor = read_anchor_attr(node) || read_id_attr(node)
              yield(node, anchor, asset_name)
            end
          end

          def unnumbered?(node)
            return false unless node.class.method_defined?(:unnumbered)

            value = node.unnumbered
            value == true || value.to_s == "true"
          end

          def build_issue_explicit(asset_name, anchor, node)
            code = CODE_BY_ASSET_NAME.fetch(asset_name)
            Metanorma::Iso::Validation::Issue.from_finding(
              code: code,
              location: model_location(node),
              params: [asset_name, anchor]
            )
          end
        end
      end
    end
  end
end
