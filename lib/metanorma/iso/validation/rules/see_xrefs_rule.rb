# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_46 / ISO_47 / ISO_48: cross-references preceded by "see" or
        # "refer to" point to a normative section or reference.
        #
        # ISO_46: "see <xref>" pointing to a normative section/annex
        # ISO_47: "see <eref>" with a broken bibitem reference
        # ISO_48: "see <eref>" pointing to a normative reference
        #
        # Walks every paragraph's mixed content looking for xref/eref
        # elements preceded by "see" or "refer to" text. Uses lutaml-model's
        # each_mixed_content for document-order iteration.
        class SeeXrefsRule < Base
          code "ISO_46" # default; ISO_47, ISO_48 emitted explicitly.

          SEE_PREFIX = /\b(see|refer\s+to)\p{Zs}*\z/i.freeze

          def applicable?(context)
            !context.root.nil? && context.state.lang.to_s == "en"
          end

          def check(context)
            normative_anchors = collect_normative_anchors(context.root)
            bibitem_index = collect_bibitem_anchors(context.root)
            issues = []

            each_paragraph_with_parent(context.root) do |paragraph, _parent|
              each_inline_with_preceding_text(paragraph) do |item, preceding_text|
                issues.concat(check_xref(item, preceding_text, normative_anchors))
                issues.concat(check_eref(item, preceding_text, bibitem_index))
              end
            end
            issues
          end

          private

          def collect_normative_anchors(root)
            anchors = Set.new

            if root.bibliography
              Array(root.bibliography.references).each do |refs|
                next unless normative?(refs)
                add_anchor(anchors, refs)
              end
            end
            Array(root.annex).each do |annex|
              next unless normative_obligation?(annex)
              add_anchor(anchors, annex)
            end
            anchors
          end

          def add_anchor(set, node)
            anchor = read_anchor_attr(node)
            set << anchor if anchor
            return unless node.class.method_defined?(:each_mixed_content)

            # Walk descendants for nested anchors via BFS using class introspection
            enqueue_for_anchor_walk(node, set)
          end

          def enqueue_for_anchor_walk(node, set)
            return unless node.is_a?(Lutaml::Model::Serializable)

            node.class.attributes.each_value do |attr_def|
              next unless attr_def.type.is_a?(Class) rescue false

              value = node.public_send(attr_def.name)
              case value
              when Array
                value.each { |v| record_anchor(set, v) if v.is_a?(Lutaml::Model::Serializable) }
              when Lutaml::Model::Serializable
                record_anchor(set, value)
              end
            end
          end

          def record_anchor(set, node)
            anchor = read_anchor_attr(node)
            set << anchor if anchor
            enqueue_for_anchor_walk(node, set)
          end

          def collect_bibitem_anchors(root)
            index = {}
            return index unless root.bibliography

            Array(root.bibliography.references).each do |refs|
              Array(refs.references).each do |bib|
                next unless bib.class.method_defined?(:id) && bib.id

                index[bib.id] = { normative: normative?(refs) }
              end
            end
            index
          end

          def normative?(node)
            return false unless node.class.method_defined?(:normative)

            value = node.normative
            value == true || value.to_s == "true"
          end

          def normative_obligation?(node)
            return false unless node.class.method_defined?(:obligation)

            node.obligation.to_s == "normative"
          end

          def check_xref(item, preceding_text, normative_anchors)
            return [] unless item.is_a?(Metanorma::Document::Components::Inline::XrefElement)
            return [] unless see_prefix?(preceding_text)

            target = item.target.to_s
            return [] unless normative_anchors.include?(target)

            [Metanorma::Iso::Validation::Issue.from_finding(
              code: "ISO_46", location: model_location(item), params: [target]
            )]
          end

          def check_eref(item, preceding_text, bibitem_index)
            return [] unless item.is_a?(Metanorma::Document::Components::Inline::ErefElement)
            return [] unless see_prefix?(preceding_text)

            bibitemid = item.bibitemid.to_s
            entry = bibitem_index[bibitemid]

            if entry.nil?
              return [Metanorma::Iso::Validation::Issue.from_finding(
                code: "ISO_47", location: model_location(item), params: [bibitemid]
              )]
            end
            return [] unless entry[:normative]

            [Metanorma::Iso::Validation::Issue.from_finding(
              code: "ISO_48", location: model_location(item), params: [bibitemid]
            )]
          end

          def see_prefix?(text)
            SEE_PREFIX.match?(text)
          end
        end
      end
    end
  end
end
