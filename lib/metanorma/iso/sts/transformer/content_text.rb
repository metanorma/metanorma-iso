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

          extract_attr(obj, :content) ||
            extract_attr(obj, :text) ||
            extract_attr(obj, :value) ||
            primitive_string(obj)
        end

        # Lutaml::Model::Serializable instances fall through to Object#to_s
        # (which calls #inspect) when their text-bearing attrs are empty.
        # On parsed models with Nokogiri-backed element_order trees, that
        # inspect can be pathologically slow or even recurse — never use
        # it as a text fallback. Only stringify genuine primitives.
        def primitive_string(obj)
          case obj
          when Integer, Float, Symbol, TrueClass, FalseClass then obj.to_s
          else nil
          end
        end

        private

        def extract_attr(obj, attr_name)
          return nil unless obj.class.method_defined?(attr_name)

          val = obj.public_send(attr_name)
          return nil unless val

          val.is_a?(Array) ? val.compact.join : val.to_s
        end
      end
    end
  end
end
