# frozen_string_literal: true

require "base64"
require "tempfile"

module IsoDoc
  module Iso
    module Docx
      # Shared utilities for model object introspection.
      #
      # Included by both Adapter and InlineRenderer to avoid duplication
      # of attribute access, text extraction, dimension parsing, and
      # ordered-content traversal.
      module ModelUtils
        # Whether a model node carries element_order information
        # (i.e., uses lutaml-model's ordered mapping mode).
        def ordered?(node)
          node.is_a?(Lutaml::Model::Serializable) &&
            node.element_order.is_a?(Array) &&
            !node.element_order.empty?
        end

        # Collect all text from a model node into a single string.
        def collect_text(node)
          return node.to_s if node.is_a?(String)
          return "" unless node

          extract_texts(node).compact.join
        end

        # Collect all text from a model node, walking element_order when
        # available so that mixed-content elements (titles, formattedref,
        # etc.) yield their full text content in document order. Falls
        # back to collect_text when element_order is not present.
        def collect_all_text(node)
          return node.to_s if node.is_a?(String)
          return "" unless node
          return collect_text(node) unless ordered?(node)

          segments = []
          each_ordered_element(node) do |type, obj|
            case type
            when :text then segments << obj.to_s
            when :element then segments << collect_all_text(obj)
            end
          end
          segments.join
        end

        # Extract text arrays from a model node's :text, :content, and
        # :content_text attributes.
        def extract_texts(node)
          return [] unless node.is_a?(Lutaml::Model::Serializable)

          texts = []
          [:text, :content, :content_text].each do |attr|
            next unless node.class.attributes.key?(attr)

            val = node.public_send(attr)
            case val
            when Array then texts.concat(val.grep(String))
            when String then texts << val
            end
          end
          texts.compact.reject { |t| mathml_content?(t) }
        end

        def mathml_content?(text)
          text.include?("<mstyle") || text.include?("<m:math") ||
            text.include?("<math ") || text.include?("<math>")
        end

        # Build the element-name → attribute-name mapping from a node's
        # XML mapping definition. Results are cached per model class.
        # Returns nil if the node has no ordered content or no mapping.
        ELEMENT_MAPPING_CACHE = {}

        def build_element_mapping(node)
          return nil unless ordered?(node)

          klass = node.class
          cached = ELEMENT_MAPPING_CACHE[klass]
          return cached if cached

          xml_mapping = klass.mappings_for(:xml, node.lutaml_register)
          return nil unless xml_mapping

          mapping = {}
          xml_mapping.mapping_elements_hash.each_value do |rule_or_array|
            Array(rule_or_array).each do |rule|
              mapping[rule.name] = rule.to
              mapping[rule.name.to_s] = rule.to if rule.name.is_a?(Symbol)
            end
          end
          ELEMENT_MAPPING_CACHE[klass] = mapping
          mapping
        end

        # Iterate a node's element_order in document order, yielding
        # [:text, String] for text nodes and [:element, Object] for
        # mapped model objects.
        def each_ordered_element(node, allow_filter: nil)
          return enum_for(__method__, node, allow_filter) unless block_given?
          return unless ordered?(node)

          element_to_attr = build_element_mapping(node)
          return unless element_to_attr

          indices = Hash.new(0)
          node.element_order.each do |el|
            if el.text?
              text = el.text_content
              yield(:text, text) if text
            elsif el.element?
              attr_name = element_to_attr[el.name]
              next unless attr_name
              next if allow_filter && !allow_filter.include?(attr_name)

              coll = node.public_send(attr_name)
              obj = if coll.is_a?(Array)
                      idx = indices[attr_name]
                      indices[attr_name] += 1
                      coll[idx]
                    else
                      coll
                    end
              yield(:element, obj) if obj
            end
          end
        end

        # Convert a data:image/...;base64,... URI to a Tempfile path.
        def extract_data_uri_to_tempfile(data_uri)
          match = data_uri.match(%r{^data:image/(\w+);base64,(.+)$}m)
          unless match
            raise ArgumentError, "Unsupported data URI format"
          end

          ext = match[1] == "jpeg" ? "jpg" : match[1]
          data = Base64.decode64(match[2])

          tmp = Tempfile.new(["img", ".#{ext}"])
          tmp.binmode
          tmp.write(data)
          tmp.close
          tmp.path
        end

        # Convert a CSS-style dimension string to EMU (for images) or
        # twips (for tables, depending on suffix).
        def parse_dimension(value)
          return nil unless value
          return nil if value == "auto"

          if value.end_with?("pt")
            (value.to_f * 20).to_i
          elsif value.end_with?("px")
            (value.to_f * 9525).to_i
          elsif value.end_with?("cm")
            (value.to_f * 360_000).to_i
          elsif value.end_with?("in")
            (value.to_f * 914_400).to_i
          else
            value.to_i
          end
        end

        # Parse a width value that may be a bare integer (twips) or a
        # CSS dimension string.
        def parse_twips(value)
          return nil unless value
          return value.to_i if value.match?(/\A\d+\z/)

          parse_dimension(value)
        end
      end
    end
  end
end
