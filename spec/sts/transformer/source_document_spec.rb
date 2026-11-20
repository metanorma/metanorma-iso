# frozen_string_literal: true

require_relative "unit_b_support"

RSpec.describe Metanorma::Iso::Sts::Transformer::SourceDocument, :aggregate_failures do # rubocop:disable RSpec/SpecFilePathFormat
  include TransformerUnitSupport

  def parse(**opts)
    described_class.parse(source_xml(**opts))
  end

  describe "#language" do
    it "reads a well-formed language code" do
      expect(parse(language: "<language>fr</language>").language).to eq("fr")
    end

    it "falls back to en for a value that is not a language code" do
      expect(parse(language: "<language>French</language>").language).to eq("en")
    end

    it "falls back to en when the document names no language" do
      expect(parse(language: "").language).to eq("en")
    end
  end

  describe "#docidentifier" do
    it "returns the identifier text" do
      expect(parse.docidentifier).to eq("ISO 1")
      expect(parse).to have_metadata
    end

    it "prefers the untyped identifier over a typed one listed first" do
      xml = source_xml.sub("<docidentifier>ISO 1</docidentifier>",
                           '<docidentifier type="internal">INT 9</docidentifier>' \
                           "<docidentifier>ISO 1</docidentifier>")
      expect(described_class.parse(xml).docidentifier).to eq("ISO 1")
    end
  end

  describe "#sections" do
    it "orders sections by displayorder when the presentation XML gives it" do
      doc = parse(sections: '<clause id="late" displayorder="3"/>' \
                            '<clause id="early" displayorder="1"/>' \
                            '<terms id="middle" displayorder="2"/>')
      expect(doc.sections.map(&:id)).to eq(%w[early middle late])
    end

    it "keeps source order across collections when there is no displayorder" do
      doc = parse(sections: '<clause id="a"/><terms id="b"/><clause id="c"/>')
      expect(doc.sections.map(&:id)).to eq(%w[a b c])
    end

    it "is empty for a document without sections" do
      expect(parse.sections).to eq([])
    end
  end

  describe "#annexes and #has_back?" do
    it "lists annexes and reports a back matter" do
      doc = parse(back: '<annex id="an1"><title>Extra</title></annex>')
      expect(doc.annexes.map(&:id)).to eq(["an1"])
      expect(doc).to have_back
    end

    it "reports no back matter without annexes or bibliography" do
      expect(parse.annexes).to eq([])
      expect(parse).not_to have_back
    end
  end

  describe "#term_autonum_for" do
    it "is nil for an unknown term id" do
      expect(parse.term_autonum_for("nope")).to be_nil
    end
  end

  describe ".from_xml" do
    it "accepts an IO as well as a string" do
      doc = described_class.from_xml(StringIO.new(source_xml))
      expect(doc.docidentifier).to eq("ISO 1")
    end
  end
end
