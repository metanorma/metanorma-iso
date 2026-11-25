# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe "Bibliography footnote spacing" do # rubocop:disable RSpec/DescribeClass
  let(:converter) { IsoDoc::Iso::PresentationXMLConvert.new({}) }
  let(:note) { "<fn id='a'><p>Under <em>review</em> now.</p></fn>" }

  def entry(datefn, ids = { sdo: "ISO 1:2010" })
    converter.send(:biblio_ref_entry_code, 1, ids, true, datefn, nil)
  end

  it "puts the comma directly after a footnoted designation" do
    expect(entry("#{note}\n")).to end_with("</fn>, ")
  end

  it "leaves no gap between consecutive footnotes" do
    expect(entry("#{note}\n#{note}\n")).to include("</fn><fn").and end_with("</fn>, ")
  end

  it "keeps the spaces inside the footnote text" do
    expect(entry("#{note}\n")).to include("<p>Under <em>review</em> now.</p>")
  end

  it "keeps a designation without a footnote unchanged" do
    expect(entry("")).to end_with("<esc>ISO 1:2010</esc>, ")
  end

  it "trims the footnote on an entry without a designation" do
    expect(entry("#{note}\n", { ordinal: "[1]" })).to end_with("</fn><tab/>")
  end

  context "with a normative reference" do
    def norm_entry(datefn, ids = { sdo: "ISO 1:2010" })
      converter.send(:norm_ref_entry_code, 1, ids, true, datefn, nil)
    end

    it "puts the comma directly after a footnoted designation" do
      expect(norm_entry("#{note}\n")).to end_with("</fn>, ")
    end

    it "leaves no gap between consecutive footnotes" do
      expect(norm_entry("#{note}\n#{note}\n")).to include("</fn><fn").and end_with("</fn>, ")
    end

    it "keeps the spaces inside the footnote text" do
      expect(norm_entry("#{note}\n")).to include("<p>Under <em>review</em> now.</p>")
    end

    it "keeps a designation without a footnote unchanged" do
      expect(norm_entry("")).to eq("<esc>ISO 1:2010</esc>, ")
    end
  end
end
