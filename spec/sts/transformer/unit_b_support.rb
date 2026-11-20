# frozen_string_literal: true

require_relative "../spec_helper"

# Builds a typed MN source tree from a hand-written XML string and hands
# back the typed nodes, so a transformer can be driven in isolation.
module TransformerUnitSupport
  def source_xml(sections: "", back: "", language: "<language>en</language>")
    <<~XML
      <standard-document xmlns="https://www.metanorma.org/ns/standoc">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
          <title>T</title>
          #{language}
        </bibdata>
        <sections>#{sections}</sections>
        #{back}
      </standard-document>
    XML
  end

  def context_for(xml)
    source = Metanorma::Iso::Sts::Transformer::SourceDocument.parse(xml)
    Metanorma::Iso::Sts::Transformer::Context.new(source)
  end

  # All typed nodes whose class name ends in ::+suffix+, document order.
  def nodes_of(node, suffix, seen = {}, out = [])
    return out if node.nil? || node.is_a?(String) || seen[node.object_id]

    seen[node.object_id] = true
    out << node if node.class.name.to_s.end_with?("::#{suffix}")
    return out unless node.class.respond_to?(:attributes)

    node.class.attributes.each_key do |name|
      value = begin
        node.public_send(name)
      rescue StandardError
        nil
      end
      Array(value).each { |child| nodes_of(child, suffix, seen, out) }
    end
    out
  end

  def node_of(root, suffix, id: nil)
    found = nodes_of(root, suffix)
    id ? found.find { |n| n.id == id } : found.first
  end

  # Serialized model as a namespace-free Nokogiri document.
  def xml_of(model)
    Nokogiri::XML(model.to_xml).remove_namespaces!
  end
end
