# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Source (document) order of a typed node's children.
        #
        # The typed model stores children per collection (paragraphs,
        # notes, clauses, ...), which loses their interleaving. XML-ordered
        # lutaml models keep the parse order in +element_order+; this walks
        # it and hands back the collection items in that order.
        module SourceOrder
          # @param node [Lutaml::Model::Serializable]
          # @param attrs [Array<Symbol>, nil] restrict to these attributes
          #   (nil keeps every mapped element)
          # @return [Array<Array(Symbol, Object)>] [attribute, item] pairs
          #   in source order; items the order record does not account for
          #   (programmatically built nodes, unnamed mappings) follow in
          #   attribute-declaration order, so nothing is lost.
          def self.entries(node, attrs = nil)
            queues = queues_for(node, attrs)
            by_element = element_attrs(node)
            ordered = []

            Array(node.respond_to?(:element_order) ? node.element_order : nil).each do |entry|
              next unless entry.respond_to?(:type) && entry.type == "Element"
              attr = by_element[entry.name]
              queue = attr && queues[attr]
              next if queue.nil? || queue.empty?

              ordered << [attr, queue.shift]
            end

            queues.each { |attr, queue| queue.each { |item| ordered << [attr, item] } }
            ordered
          end

          def self.queues_for(node, attrs)
            wanted = attrs || node.class.attributes.keys
            wanted.each_with_object({}) do |attr, h|
              next unless node.class.attributes.key?(attr)

              items = Array(node.public_send(attr)).compact
              h[attr] = items unless items.empty?
            end
          end

          # element name => attribute, for the node's XML mapping.
          def self.element_attrs(node)
            node.class.mappings_for(:xml).elements.to_h { |rule| [rule.name, rule.to] }
          end
          private_class_method :queues_for, :element_attrs
        end
      end
    end
  end
end
