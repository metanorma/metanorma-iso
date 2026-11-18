# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::DlTransformer do
  let(:source_xml) do
    <<~XML
      <standard-document xmlns="https://www.metanorma.org/ns/standoc">
        <bibdata>
          <docidentifier>OIML T 1</docidentifier>
          <title>Test</title>
        </bibdata>
        <sections>
          <clause id="c1">
            <dl id="d1">
              <dt id="t-ac">AC</dt>
              <dd id="dd-ac"><p id="p-ac">Alternating Current</p></dd>
              <dt id="t-dc">DC</dt>
              <dd id="dd-dc"><p id="p-dc">Direct Current</p></dd>
            </dl>
          </clause>
        </sections>
      </standard-document>
    XML
  end

  let(:source) { Metanorma::Iso::Sts::Transformer::SourceDocument.parse(source_xml) }
  let(:context) { Metanorma::Iso::Sts::Transformer::Context.new(source) }
  let(:transformer) { described_class.new(context) }

  def find_dl(node, seen = {})
    return nil unless node.is_a?(Object) && !node.is_a?(String)
    return nil if seen[node.object_id]
    seen[node.object_id] = true
    return node if node.class.name.end_with?("::DefinitionList")
    attrs = node.class.instance_variable_get(:@attributes) rescue nil
    return nil unless attrs
    attrs.each do |name, _|
      next unless node.class.method_defined?(name)
      val = node.public_send(name) rescue next
      next if val.nil?
      Array(val).each do |v|
        found = find_dl(v, seen)
        return found if found
      end
    end
    nil
  end

  describe "#transform" do
    it "emits a def-list with one def-item per dt/dd pair" do
      dl = find_dl(source.typed_root)
      expect(dl).not_to be_nil
      result = transformer.transform(dl)

      expect(result).to be_a(Sts::NisoSts::DefList)
      expect(result.def_item.size).to eq(2)
    end

    it "preserves the term text and definition paragraph" do
      dl = find_dl(source.typed_root)
      result = transformer.transform(dl)
      first = result.def_item.first

      expect(first.term.text.join).to eq("AC")
      expect(first.definition.paragraph.size).to eq(1)
      expect(first.definition.paragraph.first.text.join).to eq("Alternating Current")
    end

    it "emits valid STS XML" do
      dl = find_dl(source.typed_root)
      xml = transformer.transform(dl).to_xml

      expect(xml).to include("<def-list")
      expect(xml).to include("<def-item")
      expect(xml).to include("<term>AC</term>")
      expect(xml).to include("<p id=\"p-ac\">Alternating Current</p>")
    end
  end
end
