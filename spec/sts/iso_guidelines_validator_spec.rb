# frozen_string_literal: true

require_relative "spec_helper"
require "nokogiri"

# ISO NISO STS coding-guidelines validator (ed 2.1): the Ruby rule ids map
# 1:1 to the vendored schematron ids, errors fail the gate, warnings only
# report. Fixtures are real STS XML documents, evaluated by the real
# validator (no doubles).
# rubocop:disable RSpec/MultipleExpectations
# rule id => [violating body, clean body, back (violating), back (clean)]
# Each pair differs only in the property the rule checks.
RULE_FIXTURES = {
  "iso-gdg-3.4-1" => [
    '<sec><label>4</label><title>X</title><p>See <xref ref-type="sec" rid="nowhere">x</xref>.</p></sec>',
    '<sec id="s4"><label>4</label><title>X</title><p>See <xref ref-type="sec" rid="s4">x</xref>.</p></sec>',
  ],
  "iso-gdg-A.3.1-8" => [
    '<sec id="d"><label>4</label><title>X</title><p id="d">t</p></sec>',
    '<sec id="d"><label>4</label><title>X</title><p id="e">t</p></sec>',
  ],
  "iso-gdg-5.7-2" => [
    '<sec><label>4</label><title>X</title><list list-type="fancy"><list-item><p>a</p></list-item></list></sec>',
    '<sec><label>4</label><title>X</title><list list-type="dash"><list-item><p>a</p></list-item></list></sec>',
  ],
  "iso-gdg-5.7-1" => [
    '<sec><label>4</label><title>X</title><list list-type="dash"><list list-type="dash"><list-item><p>a</p></list-item></list></list></sec>',
    '<sec><label>4</label><title>X</title><list list-type="dash"><list-item><p>a</p></list-item></list></sec>',
  ],
  "iso-gdg-9.2.7-1" => [
    "<sec><label>4</label><title>X</title><p><tbx:see>x</tbx:see></p></sec>",
    "<sec><label>4</label><title>X</title><p>x</p></sec>",
  ],
  "iso-gdg-B.2.13-1" => [
    "<sec><label>4</label><title>X</title><boxed-text><p>b</p></boxed-text></sec>",
    "<sec><label>4</label><title>X</title><p>b</p></sec>",
  ],
  "iso-gdg-4.4.2-1" => [
    "<sec><title>X</title><sec><label>4.1</label><title>Y</title><p>y</p></sec></sec>",
    "<sec><label>4</label><title>X</title><sec><label>4.1</label><title>Y</title><p>y</p></sec></sec>",
  ],
  "iso-gdg-4.2-1" => [
    "<sec><label>4</label><title>Introduction</title><p>i</p></sec>",
    '<sec sec-type="intro"><title>Introduction</title><p>i</p></sec>',
  ],
  "iso-gdg-10.1.1-1" => [
    '<sec id="s4"><label>4</label><title>X</title><p><xref ref-type="bogus" rid="s4">x</xref></p></sec>',
    '<sec id="s4"><label>4</label><title>X</title><p><xref ref-type="sec" rid="s4">x</xref></p></sec>',
  ],
  "iso-gdg-10.1.2-1" => [
    '<sec id="s4"><label>4</label><title>X</title><p><xref ref-type="fig" rid="s4">x</xref></p></sec>',
    '<sec id="s4"><label>4</label><title>X</title><p><xref ref-type="sec" rid="s4">x</xref></p></sec>',
  ],
  "iso-gdg-10.1.8-1" => [
    '<sec id="s4"><label>4</label><title>X</title><p><xref ref-type="fn" rid="s4">x</xref></p></sec>',
    '<sec id="s4"><label>4</label><title>X</title><p>t<fn id="f1"><p>n</p></fn><xref ref-type="fn" rid="f1">1</xref></p></sec>',
  ],
  "iso-gdg-10.1.9-1" => [
    '<sec><label>4</label><title>X</title><p><ext-link xlink:href="https://example.org">x</ext-link></p></sec>',
    '<sec><label>4</label><title>X</title><p><ext-link ext-link-type="uri" xlink:href="https://example.org">x</ext-link></p></sec>',
  ],
  "iso-gdg-4.5.1-1" => [
    nil, nil,
    '<back><app-group><app id="a" content-type="optional"><label>Annex A</label><title>T</title><p>x</p></app></app-group></back>',
    '<back><app-group><app id="a" content-type="informative"><label>Annex A</label><title>T</title><p>x</p></app></app-group></back>'
  ],
  "iso-gdg-4.5.1-2" => [
    nil, nil,
    '<back><app-group><app id="a" content-type="normative"><title>T</title><p>x</p></app></app-group></back>',
    '<back><app-group><app id="a" content-type="normative"><label>Annex A</label><title>T</title><p>x</p></app></app-group></back>'
  ],
  "iso-gdg-4.5.2-3" => [
    nil, nil,
    '<back><ref-list content-type="bibl"><title>Bibliography</title><ref id="r1"><mixed-citation><name>A</name></mixed-citation></ref></ref-list></back>',
    '<back><ref-list content-type="bibl"><title>Bibliography</title><ref id="r1"><mixed-citation>A</mixed-citation></ref></ref-list></back>'
  ],
  "iso-gdg-D.1.1-1" => [
    '<sec><label>4</label><title>X</title><editing-instruction content-type="rewrite"><p>e</p></editing-instruction></sec>',
    '<sec><label>4</label><title>X</title><editing-instruction content-type="addition"><p>e</p></editing-instruction></sec>',
  ],
  "iso-gdg-E.3-1" => [
    '<sec><label>4</label><title>X</title><supplementary-material id="m"/></sec>',
    '<sec><label>4</label><title>X</title><supplementary-material id="m" xlink:href="a.zip"/></sec>',
  ],
}.freeze

RSpec.describe Metanorma::Iso::Sts::Validator, "ISO guidelines ed 2.1" do
  let(:validator) { described_class.new }

  # A document conforming to the structural rules (Guidelines 4.1-4.4);
  # +body+ is spliced into <body> after the mandatory clauses.
  def sts_xml(body = "", back: "")
    <<~XML
      <?xml version="1.0"?>
      <standard xmlns:tbx="urn:iso:std:iso:30042:ed-1" xmlns:xlink="http://www.w3.org/1999/xlink" xml:lang="en" dtd-version="1.2">
        <processing-meta tagset-family="sts" base-tagset="interchange" table-model="xhtml" mathml-version="3.0" math-representation="mathml" terminology-model="tbx">
          <custom-meta-group><custom-meta><meta-name>iec_iso_coding_guidelines_edition</meta-name><meta-value>2.1</meta-value></custom-meta></custom-meta-group>
        </processing-meta>
        <front>
          <std-meta><permissions><copyright-statement>All rights reserved</copyright-statement></permissions></std-meta>
          <sec sec-type="foreword"><title>Foreword</title><p>Foreword text.</p></sec>
        </front>
        <body>
          <sec sec-type="scope"><label>1</label><title>Scope</title><p>Scope text.</p></sec>
          <sec sec-type="norm-refs"><label>2</label><title>Normative references</title><p>There are no normative references.</p></sec>
          <sec sec-type="terms"><label>3</label><title>Terms and definitions</title><p>No terms are defined.</p></sec>
          #{body}
        </body>
        #{back}
      </standard>
    XML
  end

  def rule_ids_for(xml)
    validator.validate(xml).errors.map(&:rule_id)
  end

  describe "rule catalogue" do
    let(:sch_path) do
      REPO_ROOT.join("lib/metanorma/iso/schematron/iso-sts.sch")
    end
    let(:sch_ids) do
      doc = Nokogiri::XML(sch_path.read)
      doc.remove_namespaces!
      doc.xpath("//assert[@id] | //report[@id]").map { |n| n["id"] }.uniq.sort
    end

    it "vendors the 110 error-rule assert/report ids" do
      expect(sch_ids.size).to eq(110)
    end

    it "implements every schematron id, and only those" do
      implemented = described_class.rule_ids.sort
      expect(implemented - sch_ids).to be_empty
      expect(sch_ids - implemented).to be_empty
      expect(implemented).to eq(implemented.uniq)
    end

    it "carries no OIML X 999 rule" do
      ids = described_class.rule_ids
      expect(ids).to all(start_with("iso-gdg-"))
    end
  end

  describe "severity" do
    it "passes a conforming shell with no error findings" do
      report = validator.validate(sts_xml)
      expect(report.errors.map(&:rule_id)).to be_empty
      expect(report).to be_valid
    end

    it "fails Sts.validate on an error finding" do
      report = Metanorma::Iso::Sts.validate("<other/>")
      expect(report).not_to be_valid
      expect(report.errors.map(&:severity)).to all(eq(:error))
    end

    it "keeps warnings report-only" do
      report = Metanorma::Iso::Sts::ValidationReport.new
      report.add(rule_id: "iso-gdg-x", message: "advice", severity: :warning)
      expect(report).to be_valid
      expect(report.warnings.map(&:rule_id)).to eq(["iso-gdg-x"])
      expect(report.to_s).to include("1 warnings")
    end

    it "fails once an error joins the warnings" do
      report = Metanorma::Iso::Sts::ValidationReport.new
      report.add(rule_id: "w", message: "w", severity: :warning)
      report.add(rule_id: "e", message: "e")
      expect(report).not_to be_valid
      expect(report.to_s).to include("FAILED (1 errors, 1 warnings")
    end
  end

  RULE_FIXTURES.each do |rule_id, (bad_body, good_body, bad_back, good_back)|
    describe rule_id do
      it "fires on a violating fixture" do
        xml = sts_xml(bad_body.to_s, back: bad_back.to_s)
        expect(rule_ids_for(xml)).to include(rule_id)
      end

      it "stays silent on the clean fixture" do
        xml = sts_xml(good_body.to_s, back: good_back.to_s)
        expect(rule_ids_for(xml)).not_to include(rule_id)
      end
    end
  end

  describe "document structure" do
    it "fires iso-gdg-4.1-1 on a non-<standard> root" do
      expect(rule_ids_for("<other/>")).to include("iso-gdg-4.1-1")
    end

    it "fires iso-gdg-4.3.2-6 without <processing-meta>" do
      xml = sts_xml.sub(%r{<processing-meta.*?</processing-meta>}m, "")
      expect(rule_ids_for(xml)).to include("iso-gdg-4.3.2-6")
    end

    it "fires iso-gdg-4.4.2-2 when the scope clause is missing" do
      xml = sts_xml.sub(%r{<sec sec-type="scope">.*?</sec>}m, "")
      expect(rule_ids_for(xml)).to include("iso-gdg-4.4.2-2")
    end

    it "fires iso-gdg-4.3.1-1 and iso-gdg-4.4.1-1 on an empty <standard>" do
      ids = rule_ids_for("<standard/>")
      expect(ids).to include("iso-gdg-4.3.1-1", "iso-gdg-4.4.1-1")
    end

    it "reports the offending node path with each finding" do
      report = validator.validate(sts_xml(RULE_FIXTURES["iso-gdg-5.7-2"][0]))
      finding = report.errors.find { |e| e.rule_id == "iso-gdg-5.7-2" }
      expect(finding.xpath).to include("list")
      expect(finding.message).to include("fancy")
      expect(finding.severity).to eq(:error)
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
