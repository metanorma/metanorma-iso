# frozen_string_literal: true

require_relative "unit_b_support"

RSpec.describe Metanorma::Iso::Sts::Transformer::NoteTransformer do
  include TransformerUnitSupport

  let(:sections) do
    <<~XML
      <clause id="c1"><title>Clause</title>
        <note id="n1"><p id="np1">Plain note</p></note>
        <note id="n2" autonum="2"><p id="np2">Numbered note</p></note>
        <note id="n3"><p id="np3">Note with list</p><ul id="nu"><li id="nl"><p id="nlp">Item</p></li></ul></note>
        <note id="n4"/>
        <admonition id="a1" type="caution"><p id="ap1">Careful</p></admonition>
        <admonition id="a2" type="warning"><fmt-name><span class="fmt-caption-label">Hot surface above 100</span></fmt-name><p id="ap2">Hot</p></admonition>
        <example id="e1"><p id="ep1">Plain example</p></example>
        <example id="e2" autonum="3"><p id="ep2">Numbered example</p></example>
        <example id="e3"><p id="ep3">Example with code</p><sourcecode id="sc">a &lt; b</sourcecode></example>
      </clause>
    XML
  end
  let(:context) { context_for(source_xml(sections: sections)) }
  let(:root) { context.source.typed_root }
  let(:transformer) { described_class.new(context) }

  def note_xml(suffix, id)
    xml_of(transformer.transform(node_of(root, suffix, id: id)))
  end

  describe "#transform for an admonition" do
    let(:doc) { note_xml("AdmonitionBlock", "a1") }

    it "emits the paragraph although an admonition has no list attributes" do
      expect(doc.at_xpath("//p[@id='ap1']").text).to eq("Careful")
    end

    it "labels the note by the admonition type" do
      expect(doc.at_xpath("//label").text).to eq("CAUTION")
    end

    it "keeps trailing title digits out of the label" do
      expect(note_xml("AdmonitionBlock", "a2").at_xpath("//label").text).to eq("WARNING")
    end
  end

  describe "#transform for a note" do
    it "emits a non-normative-note labelled NOTE with the paragraph" do
      doc = note_xml("NoteBlock", "n1")

      expect(doc.root.name).to eq("non-normative-note")
      expect(doc.at_xpath("/non-normative-note/label").text).to eq("NOTE")
      expect(doc.at_xpath("/non-normative-note/p/@id").value).to eq("np1")
      expect(doc.at_xpath("/non-normative-note/p").text).to eq("Plain note")
    end

    it "appends the autonum to the label" do
      expect(note_xml("NoteBlock", "n2").at_xpath("/non-normative-note/label").text).to eq("NOTE 2")
    end

    it "carries a nested list as a list child" do
      doc = note_xml("NoteBlock", "n3")

      expect(doc.at_xpath("/non-normative-note/list/@list-type").value).to eq("bullet")
      expect(doc.at_xpath("/non-normative-note/list/list-item/p").text).to eq("Item")
    end

    it "returns nil for a note with no content" do
      expect(transformer.transform(node_of(root, "NoteBlock", id: "n4"))).to be_nil
    end
  end

  describe "#transform for an example" do
    it "emits a non-normative-example labelled EXAMPLE with the paragraph" do
      doc = note_xml("ExampleBlock", "e1")

      expect(doc.root.name).to eq("non-normative-example")
      expect(doc.at_xpath("/non-normative-example/label").text).to eq("EXAMPLE")
      expect(doc.at_xpath("/non-normative-example/p").text).to eq("Plain example")
    end

    it "appends the autonum to the label" do
      expect(note_xml("ExampleBlock", "e2").at_xpath("/non-normative-example/label").text).to eq("EXAMPLE 3")
    end

    it "emits sourcecode as a preformat with the entity decoded" do
      doc = note_xml("ExampleBlock", "e3")

      expect(doc.at_xpath("/non-normative-example/preformat").text).to eq("a < b")
    end
  end
end
