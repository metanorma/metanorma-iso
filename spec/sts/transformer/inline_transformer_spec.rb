# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::InlineTransformer do
  let(:t) { Metanorma::Iso::Sts::Transformer }

  def paragraph_in(inner)
    source = t::SourceDocument.parse(<<~XML)
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard"><title language="en" type="main">T</title>
          <docidentifier>ISO 1</docidentifier><language>en</language></bibdata>
        <sections><clause id="c1"><title>S</title><p id="p1">#{inner}</p></clause></sections>
      </metanorma>
    XML
    [described_class.new(t::Context.new(source)), source.sections.first.paragraphs.first]
  end

  # TBX targets serialize in their own namespace with un-namespaced
  # inline children, so address elements by local name.
  def child(doc, name)
    doc.root.at_xpath("./*[local-name()='#{name}']")
  end

  def own_text(doc)
    doc.root.xpath("./text()").map(&:text).join
  end

  describe "#apply_inline_content" do
    it "appends the text runs and inline markup onto a TBX definition" do
      transformer, para = paragraph_in("A <strong>bold</strong> and <em>slanted</em> end.")
      target = Sts::TbxIsoTml::Definition.new

      result = transformer.apply_inline_content(para, target)
      doc = Nokogiri::XML(result.to_xml)

      expect(result).to equal(target)
      expect(doc.root.name).to eq("definition")
      expect(child(doc, "bold").text).to eq("bold")
      expect(child(doc, "italic").text).to eq("slanted")
      expect(own_text(doc)).to include("A ").and include(" end.")
    end

    it "serializes every text run, so none is dropped" do
      transformer, para = paragraph_in("one <strong>b</strong> two <em>i</em> three")
      doc = Nokogiri::XML(transformer.apply_inline_content(para, Sts::TbxIsoTml::Note.new).to_xml)

      expect(own_text(doc)).to include("one").and include("two").and include("three")
    end

    it "carries subscript and superscript with their text" do
      transformer, para = paragraph_in("H<sub>2</sub>O and x<sup>2</sup>")
      doc = Nokogiri::XML(transformer.apply_inline_content(para, Sts::TbxIsoTml::Note.new).to_xml)

      expect(child(doc, "sub").text).to eq("2")
      expect(child(doc, "sup").text).to eq("2")
    end

    it "carries monospace text onto a TBX example" do
      transformer, para = paragraph_in("Use <tt>cmd</tt> now")
      doc = Nokogiri::XML(transformer.apply_inline_content(para, Sts::TbxIsoTml::Example.new).to_xml)

      expect(doc.root.name).to eq("example")
      expect(child(doc, "monospace").text).to eq("cmd")
    end

    it "writes plain text to the model's own text attribute (Paragraph uses text)" do
      transformer, para = paragraph_in("Just words.")
      target = Sts::NisoSts::Paragraph.new

      transformer.apply_inline_content(para, target)

      expect(Nokogiri::XML(target.to_xml).root.text).to eq("Just words.")
    end

    # sts 0.6.15 grew TbxIsoTml::Definition's :value slot, so the fn run
    # no longer hits the no-slot path; per the #122 contract the run the
    # target cannot slot survives as its text ("label body"), never
    # vanishes. The fn MARKUP itself is still not carried (no <fn>).
    it "carries the footnote run as text, without fn markup (TBX targets)" do
      transformer, para = paragraph_in(%(Before<fn reference="1"><p id="fnp">NOTE-BODY</p></fn> after.))
      xml = transformer.apply_inline_content(para, Sts::TbxIsoTml::Definition.new).to_xml

      expect(xml).not_to include("<fn")
      expect(xml).to include("Before")
      expect(xml).to include("NOTE-BODY")
    end
  end

  describe "#transform" do
    it "turns a paragraph into a <p> with its inline markup" do
      transformer, para = paragraph_in("Say <strong>hi</strong>.")
      doc = Nokogiri::XML(transformer.transform(para).to_xml)

      expect(doc.root.name).to eq("p")
      expect(doc.at_xpath("/p/bold").text).to eq("hi")
    end
  end
end
