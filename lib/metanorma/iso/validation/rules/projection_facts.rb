# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Lossless typed traversal facts for checks whose identity/order cannot
        # be recovered from semantic XML. This extracts facts only: requirement
        # decisions live in the E2 YAML declarations. Nodes are diagnostic
        # projection records, never authored XML locations or invented models.
        class ProjectionFacts
          def initialize(root, xml, namespace, state: nil)
            @root = root
            @xml = xml
            @namespace = namespace
            @state = state
          end

          def append
            append_state
            return unless @root

            append_sequence
            append_identities
            append_assets
            append_xrefs
            append_asset_order
            append_term_sources
            append_term_xrefs
          end

          private

          def add(parent, name, attributes = {})
            node = Nokogiri::XML::Node.new(name, @xml)
            node.namespace = @namespace
            attributes.each { |key, value| node[key.to_s] = value.to_s unless value.nil? }
            parent.add_child(node)
            node
          end

          def append_state
            return unless @state

            add(@xml.root, "state", doctype: @state.doctype, amd: @state.amd)
          end

          def append_sequence
            parent = add(@xml.root, "sequence")
            SectionSequenceRule.new.projection_sequence(@root).each do |kind, location|
              add(parent, "item", kind: kind, location: location)
            end
          end

          def append_identities
            parent = add(@xml.root, "identities")
            UniqueIdRule.new.projection_identities(@root).each do |kind, value, location|
              add(parent, "identity", kind: kind, value: value, location: location)
            end
          end

          def append_assets
            parent = add(@xml.root, "assets")
            UnreferencedAssetsRule.new.projection_assets(@root).each do |name, anchor, location, unnumbered|
              add(parent, "asset", name: name, anchor: anchor, location: location, unnumbered: unnumbered)
            end
          end

          def append_xrefs
            parent = add(@xml.root, "xrefs")
            Base.new.each_xref(@root) { |xref| add(parent, "xref", target: xref.target) }
          end

          def append_term_sources
            parent = add(@xml.root, "term-sources")
            terms, identifiers = TermSourceCompleteRule.new.projection_term_sources(@root)
            order = 0
            terms.each do |location, label, sources|
              term = add(parent, "term")
              sources.each do |origin, bibitemid|
                order += 1
                add(term, "source", origin: origin, bibitemid: bibitemid,
                  location: location, label: label, order: order)
              end
            end
            bibliography = add(@xml.root, "bibliography-identities")
            identifiers.each { |id| add(bibliography, "identifier", value: id) }
          end

          def append_term_xrefs
            parent = add(@xml.root, "term-xrefs")
            references, anchors = TermXrefsRule.new.projection_term_xrefs(@root)
            references.each_with_index do |(target, location, in_terms), index|
              add(parent, "xref", target: target, location: location,
                "in-terms" => in_terms, order: index)
            end
            targets = add(@xml.root, "terms-identities")
            anchors.each { |anchor| add(targets, "identifier", value: anchor) }
          end

          def append_asset_order
            parent = add(@xml.root, "asset-order")
            assets, citations = AssetCitedFirstRule.new.projection_asset_order(@root)
            by_target = citations.group_by(&:first)
            assets.each do |name, anchor, location, unnumbered, position|
              asset = add(parent, "asset", name: name, anchor: anchor,
                location: location, unnumbered: unnumbered, position: position)
              Array(by_target[anchor]).each do |target, cited_at, ancestors|
                citation = add(asset, "citation", target: target, position: cited_at)
                ancestors.each { |value| add(citation, "within", anchor: value) }
              end
            end
          end
        end
      end
    end
  end
end
