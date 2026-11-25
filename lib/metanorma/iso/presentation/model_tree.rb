# frozen_string_literal: true

require "digest"

module Metanorma
  module Iso
    module Presentation
      # Traverse the declared model graph. Parsed order wins; declared children
      # appended by native producers are included, never silently discarded.
      class ModelTree
        Inline = Metanorma::Document::Components::Inline
        attr_reader :root, :nodes

        def initialize(root)
          @root, @nodes, @paths = root, [], {}
          collect(root, "document", {})
        end

        def value(node, key)
          node.public_send(key) if node.class.attributes.key?(key)
        end

        def content_children(node)
          children = []
          if node.element_order&.any? && (node.mixed? || node.ordered?)
            node.each_mixed_content { |child| children << child if content?(child) }
          end
          counts = children.tally
          declared = Hash.new(0)
          node.class.attributes.each_key do |key|
            next if %i[bibdata bibliography].include?(key)

            Array(value(node, key)).each do |child|
              next unless content?(child)

              declared[child] += 1
              children << child if declared[child] > counts.fetch(child, 0)
            end
          end
          children
        end

        def content?(node)
          node.is_a?(Lutaml::Model::Serializable) && !node.is_a?(Inline::RenderedDisplay) &&
            !(node.is_a?(Inline::SemxElement) && node.element_attr == "xref" && node.fmt_xref&.any?)
        end

        def label(node)
          data = value(node, :fmt_ladl_label_data)
          data ||= Array(value(node, :fmt_xref_label)).filter_map do |entry|
            next unless entry.is_a?(Inline::FmtXrefLabelElement)

            entry.fmt_ladl_label_data
          end.first
          data if data.is_a?(Inline::FmtLadlLabelData)
        end

        def assign_ids!
          ids = {}
          nodes.each do |node|
            id = value(node, :id)
            next if id.nil? || id.empty?

            raise ArgumentError, "Duplicate ISO content id #{id}" if ids.key?(id)

            ids[id] = node
          end
          nodes.each do |node|
            next unless node.class.attributes.key?(:id)
            next unless value(node, :id).to_s.empty?

            id = "_native_#{Digest::SHA256.hexdigest(@paths.fetch(node.object_id))[0, 24]}"
            raise ArgumentError, "Generated ISO content id collides with #{id}" if ids.key?(id)

            node.id = id
            ids[id] = node
          end
        end

        # Native constructors do not populate the framework's parsed text order.
        # Text-only content is unambiguous; mixed text/children requires the
        # producer's authored order and must never be guessed here.
        def ensure_text_order!(node)
          return if node.element_order&.any?
          return unless node.mixed?

          text = Array(value(node, :text))
          return if text.empty?
          if content_children(node).any?
            raise Transformer::UnsupportedContent, "Mixed ISO content requires authored element_order"
          end

          node.element_order = text.map do |fragment|
            Lutaml::Xml::Element.new("Text", "text", text_content: fragment)
          end
        end

        private

        def collect(node, path, seen)
          raise ArgumentError, "ISO content must be a tree" if seen[node.object_id]

          seen[node.object_id] = true
          @paths[node.object_id] = path
          nodes << node
          content_children(node).each_with_index do |child, index|
            collect(child, "#{path}/#{index}:#{child.class.name}", seen)
          end
        end
      end
    end
  end
end
