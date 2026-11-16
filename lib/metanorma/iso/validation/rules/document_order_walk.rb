# frozen_string_literal: true

require "set"

module Metanorma
  module Iso
    module Validation
      module Rules
        # Document-order traversal for model-based rules that need positional
        # comparison (first-use tracking, asset-before-citation ordering).
        #
        # The shared TreeTraversal walkers are breadth-first over attribute
        # declaration order, which is NOT document order. lutaml-model keeps
        # the original element sequence on ordered nodes (element_order), so
        # this walker performs a depth-first, pre-order descent through the
        # document's structural regions — preface, sections, annexes — using
        # element_order when the node carries it and falling back to the XML
        # mapping's element declaration order otherwise.
        #
        # Included by individual rules (not mixed into Base) so the shared
        # BFS helpers and this ordered walk stay MECE.
        module DocumentOrderWalk
          PARAGRAPH_CLASS =
            Metanorma::Document::Components::Paragraphs::ParagraphBlock
          XREF_CLASS = Metanorma::Document::Components::Inline::XrefElement

          # Depth-first, pre-order walk over the document body in document
          # order: preface, then sections, then annexes. Yields (node,
          # ancestors) where ancestors is the chain of structural containers
          # (nearest last). Bibliography is not walked: it carries declared
          # entries, not running text.
          def each_document_node(root)
            return enum_for(__method__, root) unless block_given?

            regions = [root&.preface, root&.sections] + Array(root&.annex)
            visited = Set.new
            regions.each do |region|
              descend_document_node(region, [], visited) { |n, a| yield(n, a) }
            end
          end

          # Every paragraph block in document order, with its ancestor chain.
          def each_document_paragraph(root, &block)
            return enum_for(__method__, root) unless block_given?

            each_document_node(root) do |node, ancestors|
              yield(node, ancestors) if node.is_a?(PARAGRAPH_CLASS)
            end
          end

          # Same walk as each_document_node, additionally yielding a
          # monotonically increasing position counter per visited node, so
          # rules can compare the document position of nodes of different
          # kinds (an asset against the citation that targets it).
          def each_document_node_with_position(root)
            return enum_for(__method__, root) unless block_given?

            position = 0
            each_document_node(root) do |node, ancestors|
              position += 1
              yield(node, ancestors, position)
            end
          end

          # True when the ancestor chain carries a node of the given class.
          def under_ancestor?(ancestors, klass)
            ancestors.any? { |a| a.is_a?(klass) }
          end

          # Concatenated text of every paragraph in the subtree rooted at
          # +node+ (node's own title text included). Document-order based.
          def subtree_text(node)
            parts = []
            visited = Set.new
            descend_document_node(node, [], visited) do |n, _|
              parts << ordered_text(n) if n.is_a?(PARAGRAPH_CLASS)
            end
            parts << title_text_of(node) if node.class.method_defined?(:title)
            parts.reject { |t| t.to_s.strip.empty? }.join(" ")
          end

          # Paragraph text assembled in mixed-content order: raw strings and
          # inline elements appear in their document sequence, unlike
          # extract_text which walks attributes in declaration order.
          def ordered_text(paragraph)
            return extract_text(paragraph) unless ordered_text?(paragraph)

            parts = []
            paragraph.each_mixed_content do |item|
              parts << (item.is_a?(String) ? item : extract_text(item))
            end
            parts.join
          end

          private

          def ordered_text?(paragraph)
            paragraph.is_a?(Lutaml::Model::Serializable) &&
              paragraph.class.method_defined?(:each_mixed_content)
          end

          def descend_document_node(node, ancestors, visited, &block)
            return unless node.is_a?(Lutaml::Model::Serializable)
            return if visited.include?(node.object_id)

            visited << node.object_id
            yield(node, ancestors)

            child_ancestors = ancestors + [node]
            each_ordered_child(node) do |child|
              descend_document_node(child, child_ancestors, visited, &block)
            end
          end

          # Yield the structural children of +node+ in document order.
          # Ordered nodes (element_order populated by the parser) yield
          # children by their original sequence; other serializable nodes
          # fall back to the XML mapping's element declaration order.
          def each_ordered_child(node, &block)
            return enum_for(__method__, node) unless block

            mapping = element_attr_mapping(node)
            if node.element_order.is_a?(Array) && !node.element_order.empty? &&
               mapping
              indices = Hash.new(0)
              node.element_order.each do |entry|
                next unless entry.respond_to?(:element?) && entry.element?

                attr = mapping[entry.name.to_s]
                next unless attr

                yield_nth_element(node, attr, indices, &block)
              end
            elsif mapping
              mapping.each_value do |attr|
                each_declared_element(node, attr) { |child| yield(child) }
              end
            end
          end

          # Ordered mode: yield the nth occurrence of the mapped attribute,
          # tracking per-attribute consumption counters.
          def yield_nth_element(node, attr, indices)
            return unless node.class.method_defined?(attr)

            value = node.public_send(attr)
            if value.is_a?(Array)
              idx = indices[attr]
              indices[attr] = idx + 1
              yield(value[idx]) if value[idx]
            elsif value.is_a?(Lutaml::Model::Serializable)
              yield(value)
            end
          end

          # Declaration-order fallback: yield every value of the mapped
          # attribute (arrays in sequence).
          def each_declared_element(node, attr)
            return unless node.class.method_defined?(attr)

            Array(node.public_send(attr)).each do |value|
              yield(value) if value.is_a?(Lutaml::Model::Serializable)
            end
          end

          # element name → attribute name, from the node's XML mapping.
          # Cached per class: the mapping is static.
          ELEMENT_ATTR_CACHE = {}

          def element_attr_mapping(node)
            return nil unless node.is_a?(Lutaml::Model::Serializable)

            klass = node.class
            cached = ELEMENT_ATTR_CACHE[klass]
            return cached if cached

            mapping = klass.mappings_for(:xml, node.lutaml_register)
            result = nil
            if mapping
              result = {}
              mapping.mapping_elements_hash.each_value do |rules|
                Array(rules).each do |rule|
                  result[rule.name.to_s] = rule.to
                end
              end
            end
            ELEMENT_ATTR_CACHE[klass] = result
            result
          rescue StandardError
            ELEMENT_ATTR_CACHE[klass] = nil
            nil
          end

          def title_text_of(node)
            title = node.title
            return "" if title.nil?

            title.is_a?(String) ? title : extract_text(title)
          end
        end
      end
    end
  end
end
