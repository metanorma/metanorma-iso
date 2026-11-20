# frozen_string_literal: true

require_relative "unit_b_support"

RSpec.describe Metanorma::Iso::Sts::Transformer::RenderedTextExtractor, :aggregate_failures do # rubocop:disable RSpec/SpecFilePathFormat
  include TransformerUnitSupport

  def sections(xml)
    Metanorma::Iso::Sts::Transformer::SourceDocument.parse(source_xml(sections: xml)).sections
  end

  describe ".text_of" do
    it "joins the text of a paragraph, descending into inline markup" do
      para = sections('<clause id="c"><p id="p">Alpha <strong>bold</strong> end</p></clause>')
        .first.paragraphs.first
      expect(described_class.text_of(para)).to eq("Alpha bold end")
    end

    it "uses the visible text of a cross-reference with a bare target" do
      para = sections('<clause id="c"><p id="p">see <xref target="sec-3.1"/> now</p></clause>')
        .first.paragraphs.first
      expect(described_class.text_of(para)).to eq("see 3.1 now")
    end

    it "returns a string as it is, and empty for nil or an unwalkable object" do
      expect(described_class.text_of("plain")).to eq("plain")
      expect(described_class.text_of(nil)).to eq("")
      expect(described_class.text_of(Object.new)).to eq("")
    end

    it "contributes nothing for a stem" do
      stem = Metanorma::Document::Components::Inline::StemInlineElement.new
      expect(described_class.text_of(stem)).to eq("")
    end

    it "leaves the math of an inline stem out of the surrounding text" do
      para = sections(<<~XML).first.paragraphs.first
        <clause id="c"><p id="p">pre <stem type="AsciiMath"><asciimath>x^2</asciimath></stem> post</p></clause>
      XML
      expect(described_class.text_of(para)).to eq("pre  post")
    end
  end

  describe ".autonum_of" do
    it "reads the autonum attribute of a section" do
      clause = sections('<clause id="c" autonum="7"><title>Z</title></clause>').first
      expect(described_class.autonum_of(clause)).to eq("7")
    end

    it "reads the caption label of a rendered title when there is no autonum" do
      clause = sections(<<~XML).first
        <clause id="c"><fmt-title><span class="fmt-caption-label"><semx element="autonum">4.2</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title">Name</semx></fmt-title></clause>
      XML
      expect(described_class.autonum_of(clause)).to eq("4.2")
    end

    it "is nil for a section with neither" do
      clause = sections('<clause id="c"><title>Plain</title></clause>').first
      expect(described_class.autonum_of(clause)).to be_nil
    end
  end
end
