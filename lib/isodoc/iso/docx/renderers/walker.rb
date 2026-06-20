# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Mixed-content walker. Extracts the traversal logic that the
        # Adapter used to hold as private methods (#walk_mixed_content,
        # #fallback_walk) into a standalone, injectable object.
        #
        # The walker is the bridge between the Adapter's dispatch entry
        # point and the renderers' recursion: a renderer that needs to
        # walk its children calls +@walker.walk(node, doc)+ rather than
        # recursing through the Adapter. This keeps renderers decoupled
        # from the Adapter and lets us swap dispatch strategies without
        # touching renderer code.
        class Walker
          include ModelUtils

          # +dispatcher+ must respond to +#call(node, doc)+ (e.g., a Method
          # or Proc) and is invoked for each non-text child encountered
          # during traversal.
          def initialize(dispatcher)
            @dispatcher = dispatcher
          end

          # Walk +node+'s children in document order. For each element
          # child, dispatch it via the configured dispatcher. Text
          # children are skipped (block-level walk, not inline).
          #
          # If +node+ has no element_order (i.e., not a Lutaml serializable
          # in ordered mode), falls back to attribute-based traversal.
          def walk(node, doc)
            return unless node

            walked = false
            each_ordered_element(node) do |type, obj|
              walked = true
              next if type == :text

              @dispatcher.call(obj, doc)
            end
            return if walked

            fallback_walk(node, doc)
          end

          private

          # Attribute-based fallback for nodes without element_order.
          # Visits any collection-valued attribute that holds block content.
          def fallback_walk(node, doc)
            return unless node.is_a?(Lutaml::Model::Serializable)

            BLOCK_ATTRS.each do |attr|
              next unless node.class.attributes.key?(attr)

              val = node.public_send(attr)
              next if val.nil?

              Array(val).each { |b| @dispatcher.call(b, doc) }
            end
          end

          BLOCK_ATTRS = %i[
            paragraphs tables figures formulas examples notes
            admonitions sourcecode_blocks quote_blocks
            definition_lists unordered_lists ordered_lists
            clause terms definitions references term
            p annex
          ].freeze
          private_constant :BLOCK_ATTRS
        end
      end
    end
  end
end
