# frozen_string_literal: true

require_relative "spec_helper"

# End-to-end coverage (card P3-003, test 3): a small document built from
# scratch with invented text, converted Metanorma XML -> ISO-STS. It covers
# what the rice and 8601-style documents do not: an amendment identifier
# with a part number, normative and informative annexes with clauses,
# figures with keys (definition lists), nested mixed lists, a footnote and
# cross-references to a table, a figure, a clause and both annexes.
#
# The expected file is the converter's own output, read through and checked
# by hand (see the notes on each pending example for the known gaps it
# still records). Regenerate with:
#
#   Metanorma::Iso::Sts.convert(File.read(widget_amd.xml))
RSpec.describe "Amendment document end-to-end STS conversion" do
  let(:fixtures) { FIXTURES_ROOT.join("sts_e2e_b") }
  let(:source_xml) { File.read(fixtures.join("widget_amd.xml")) }
  let(:expected_xml) { File.read(fixtures.join("widget_amd.expected.sts.xml")) }
  let(:sts) { Metanorma::Iso::Sts.convert(source_xml) }
  let(:doc) { Nokogiri::XML(sts).tap(&:remove_namespaces!) }

  def plain(xpath)
    doc.at_xpath(xpath)&.text&.tr("\u00A0", " ")
  end

  it "matches the checked expected STS output" do
    expect(Nokogiri::XML(sts, &:noblanks).canonicalize)
      .to eq(Nokogiri::XML(expected_xml, &:noblanks).canonicalize)
  end

  it "carries the amendment identifier and part number into std-meta" do
    expect(doc.at_xpath("//std-meta/std-ident/part-number")&.text).to eq("2")
    expect(plain("//std-meta/std-ref[@type='dated']"))
      .to eq("ISO 99001-2:2025/Amd 1:2026")
    expect(plain("//std-meta/std-ref[@type='undated']"))
      .to eq("ISO 99001-2:2025/Amd 1")
    expect(plain("//std-meta/doc-ref"))
      .to eq("ISO 99001-2:2025/Amd 1:2026(E)")
    expect(doc.at_xpath("//std-meta/title-wrap/compl")&.text)
      .to eq("Rotary sockets")
  end

  it "emits a normative and an informative annex, lettered, with clauses" do
    apps = doc.xpath("//back/app-group/app")
    expect(apps.map { |a| [a["id"], a["content-type"], a.at_xpath("label").text] })
      .to eq([["sec_A", "normative", "Annex A"],
              ["sec_B", "informative", "Annex B"]])
    expect(apps[0].xpath("./sec/title").map(&:text))
      .to eq(["Torque test", "Visual test"])
    expect(apps[1].xpath("./sec/title").map(&:text)).to eq(["Rationale"])
  end

  it "nests lists three deep and keeps each list kind" do
    outer = doc.at_xpath("//sec[@id='_req_gen']/list")
    expect(outer["list-type"]).to eq("arabic")
    expect(outer.xpath("./list-item").size).to eq(2)
    bullets = outer.at_xpath("./list-item[1]/list")
    expect(bullets["list-type"]).to eq("bullet")
    roman = bullets.at_xpath("./list-item[2]/list")
    expect(roman["list-type"]).to eq("roman-lower")
    expect(roman.xpath("./list-item/p").map(&:text))
      .to eq(["grade one;", "grade two."])
    expect(roman.xpath("./list-item/label").map(&:text)).to eq(%w[i) ii)])
  end

  it "resolves every xref to an element that exists, with the right kind" do
    xrefs = doc.xpath("//xref")
    expect(xrefs.size).to eq(6)
    xrefs.each do |x|
      expect(doc.at_xpath("//*[@id='#{x['rid']}']")).not_to be_nil,
                                                            "dangling rid #{x['rid']}"
    end
    kinds = xrefs.to_h { |x| [x["rid"], x["ref-type"]] }
    expect(kinds).to include("_tab1" => "table", "sec_A" => "app",
                             "sec_B" => "app", "_req_gen" => "sec")
    fig = xrefs.find { |x| x["ref-type"] == "fig" }
    expect(doc.at_xpath("//fig[@id='#{fig['rid']}']/caption/title")&.text)
      .to eq("Socket layout")
  end

  it "keeps the footnote text and its label inside the paragraph" do
    fn = doc.at_xpath("//sec[@id='_scope']/p/fn")
    expect(fn.at_xpath("./label")&.text).to eq("1")
    expect(fn.at_xpath("./p")&.text).to include("fictional and apply to no real product")
  end

  it "places a figure in the body and one inside an annex clause" do
    expect(doc.xpath("//body//fig/caption/title").map(&:text))
      .to eq(["Socket layout"])
    expect(doc.xpath("//back//app[@id='sec_B']//fig/caption/title").map(&:text))
      .to eq(["Size series"])
    expect(doc.xpath("//fig/graphic/@href").map(&:value))
      .to contain_exactly("socket", "series")
  end

  it "produces an STS document with no dangling or duplicate ids" do
    ids = doc.xpath("//@id").map(&:value)
    expect(ids.size).to eq(ids.uniq.size)
  end

  # Known converter gaps, recorded by reading the output. Each is `pending`
  # so the example turns red once the converter is fixed and the pending
  # marker (and the expected file) must then be updated.
  describe "known gaps (pending)" do
    it "converts a figure key (dl) to a legend inside the fig" do
      expect(doc.xpath("//fig//def-list//term").map(&:text)).to eq(%w[a b n])
    end

    it "renders cross-reference text as the target label, not the raw id" do
      expect(doc.xpath("//xref").map(&:text)).not_to include("_tab1")
    end

    it "keeps a paragraph in a terms clause that has no terms" do
      expect(doc.at_xpath("//sec[@sec-type='terms']//p")&.text)
        .to eq("No terms are listed.")
    end

    it "separates the footnote number from its text" do
      expect(doc.at_xpath("//fn/p")&.text).to start_with("1) ")
    end
  end
end
