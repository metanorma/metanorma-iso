# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer::ContentText
        def extract_text(node)
          return "" unless node
          return node if node.is_a?(String)

          c = node.content if node.class.method_defined?(:content)
          return "" unless c

          c.is_a?(Array) ? c.join : c.to_s
        end

        def extract_text_value(obj)
          return nil unless obj
          return obj if obj.is_a?(String)

          text = extract_attr(obj, :content) ||
            extract_attr(obj, :text) ||
            extract_attr(obj, :value)
          text || obj.to_s
        end

        private

        def extract_attr(obj, attr_name)
          return nil unless obj.class.method_defined?(attr_name)

          val = obj.send(attr_name)
          return nil unless val

          val.is_a?(Array) ? val.compact.join : val.to_s
        end
      end
    end
  end
end
