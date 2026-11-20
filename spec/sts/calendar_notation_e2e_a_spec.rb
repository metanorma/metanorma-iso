# frozen_string_literal: true

require_relative "spec_helper"

# End-to-end STS conversion of an ISO 8601-1-style document built from
# scratch with invented text (a fictional lunar-cycle tally notation):
# terms with notes and examples, a formula with its where-list, a table,
# a normative reference, an annex and a bibliography.
#
# The golden file is the converter's own output, read and checked by hand
# against the NISO STS target shape. Where the output is NOT what the
# source document asks for, the golden file pins today's behaviour and a
# `pending` example states the correct behaviour (it turns red the moment
# the converter is fixed, so the golden file gets regenerated then):
#
#   1. body clauses are emitted grouped by kind (terms after clauses,
#      normative references last), not in source order;
#   2. blocks inside a clause are emitted grouped by kind (the formula
#      lands after the "where" paragraph, notes and examples after it);
#   3. the introductory paragraph of a terms section is dropped.
RSpec.describe "ISO 8601-1-style document end-to-end to STS" do
  let(:fixtures) { FIXTURES_ROOT.join("sts_e2e") }
  let(:input) { File.read(fixtures.join("calendar_notation_e2e_a.input.xml")) }
  let(:expected) do
    File.read(fixtures.join("calendar_notation_e2e_a.expected.sts.xml"))
  end
  let(:sts) { Metanorma::Iso::Sts.convert(input) }
  let(:doc) { Nokogiri::XML(sts).tap(&:remove_namespaces!) }

  def canonical(xml)
    Nokogiri::XML(xml, &:noblanks).canonicalize
  end

  # The converter inserts no-break spaces (ISO NBSP rules); compare text
  # with them folded to plain spaces.
  def plain(node)
    node.text.tr("\u00A0", " ")
  end

  it "matches the reviewed golden STS output" do
    expect(canonical(sts)).to eq(canonical(expected))
  end

  it "carries the document identity into std-meta" do
    expect(plain(doc.at_xpath("//std-meta/std-ref[@type='dated']")))
      .to eq("ISO 98765-1:2030")
    expect(doc.at_xpath("//std-meta/title-wrap/main").text)
      .to eq("Representations for information interchange")
  end

  it "emits the terms as term-sec entries with preferred and admitted terms" do
    entries = doc.xpath("//sec[@sec-type='terms']/term-sec/termEntry")
    expect(entries.size).to eq(3)
    tally = entries[1]
    expect(tally.xpath(".//tig").map { |t| t.at_xpath("term").text })
      .to eq(["tally mark", "stroke"])
    expect(tally.xpath(".//normativeAuthorization/@value").map(&:text))
      .to eq(%w[preferredTerm admittedTerm])
  end

  it "keeps term notes and examples inside their own term entry" do
    cycle = doc.xpath("//termEntry")[0]
    expect(cycle.at_xpath(".//note").text).to include("shorter than")
    expect(cycle.at_xpath(".//example").text).to include("next")
    expect(doc.xpath("//termEntry")[1].xpath(".//note | .//example"))
      .to be_empty
  end

  it "emits clause notes and examples with their labels" do
    expect(doc.xpath("//non-normative-note/label").map(&:text))
      .to eq(%w[NOTE NOTE])
    expect(doc.at_xpath("//non-normative-example/label").text)
      .to eq("EXAMPLE")
    expect(doc.at_xpath("//non-normative-note//italic").text).to eq("r")
  end

  it "emits the formula as MathML with its where-list" do
    formula = doc.at_xpath("//disp-formula[@id='rules-f1']")
    expect(formula.xpath(".//math/*").map(&:name))
      .to eq(%w[mi mo mn mi mo mi])
    expect(doc.xpath("//def-list[@id='rules-dl1']/def-item/term").map(&:text))
      .to eq(%w[n b r])
  end

  it "emits the table with its caption, header and body rows" do
    wrap = doc.at_xpath("//table-wrap[@id='tbl1']")
    expect(wrap.at_xpath("caption/title").text)
      .to eq("Decomposition of selected totals")
    expect(wrap.xpath("table/thead/tr/th").map(&:text))
      .to eq(["Total n", "Bundles b", "Remainder r"])
    expect(wrap.xpath("table/tbody/tr").map { |r| r.xpath("td").map(&:text) })
      .to eq([%w[3 0 3], %w[12 2 2]])
  end

  it "emits the normative reference with its title in the body" do
    ref = doc.at_xpath("//sec[@sec-type='norm-refs']//ref[@id='nref1']")
    expect(plain(ref.at_xpath("mixed-citation")))
      .to eq("ISO 44444:2028, Invented time units")
    expect(plain(ref.at_xpath("std/std-ref"))).to eq("ISO 44444:2028")
  end

  it "emits the bibliography as numbered refs in the back matter" do
    refs = doc.xpath("//back/ref-list[@content-type='bibl']/ref")
    expect(refs.map { |r| r.at_xpath("label").text }).to eq(%w[[1] [2]])
    expect(refs.map { |r| r.at_xpath("std/title").text })
      .to eq(["Invented ledger practice", "A Handbook of Tallies"])
  end

  it "emits the annex as a labelled informative app" do
    app = doc.at_xpath("//back/app-group/app")
    expect(app["content-type"]).to eq("informative")
    expect(plain(app.at_xpath("label"))).to eq("Annex A")
  end

  it "keeps body clauses in source order (scope, norm-refs, terms, rules)" do
    pending "body clauses are grouped by kind, not kept in source order"
    expect(doc.xpath("//body/sec/@id").map(&:text))
      .to eq(%w[scope norm-refs sec_terms rules])
  end

  it "keeps the formula before its where paragraph" do
    pending "blocks inside a clause are grouped by kind, not source order"
    names = doc.at_xpath("//sec[@id='rules-count']").element_children
      .map { |e| e["id"] || e.name }
    expect(names.index("rules-f1")).to be < names.index("rules-p2")
  end

  it "keeps the introductory paragraph of the terms section" do
    pending "the terms-section introductory paragraph is dropped"
    expect(doc.at_xpath("//sec[@sec-type='terms']/p").text)
      .to include("the following terms and definitions apply")
  end
end
