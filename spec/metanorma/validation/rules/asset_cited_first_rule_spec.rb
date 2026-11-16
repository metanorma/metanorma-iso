# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::AssetCitedFirstRule do
  let(:rule) { described_class.new }
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  def xml_doc(body)
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>Body</title>#{body}</clause>
        </sections>
      </metanorma>
    XML
  end

  describe "#check" do
    it "passes when every figure is cited before it appears" do
      xml = xml_doc(
        "<p id=\"p1\">See <xref target=\"fig-1\">Figure 1</xref>.</p>" \
        "<figure id=\"fig-1\"><name>Cap</name></figure>"
      )
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "passes when every table is cited before it appears" do
      xml = xml_doc(
        "<p id=\"p1\">See <xref target=\"tab-1\">Table 1</xref>.</p>" \
        "<table id=\"tab-1\"><name>Table 1</name></table>"
      )
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags ISO_54 when a table is cited only after it appears" do
      xml = xml_doc(
        "<table id=\"tab-1\"><name>Table 1</name></table>" \
        "<p id=\"p1\">See <xref target=\"tab-1\">Table 1</xref>.</p>"
      )
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_54")
      expect(issues.first.params).to eq(%w[Table tab-1])
    end

    it "flags ISO_54 when a figure is cited only after it appears" do
      xml = xml_doc(
        "<figure id=\"fig-1\"><name>Cap</name></figure>" \
        "<p id=\"p1\">See <xref target=\"fig-1\">Figure 1</xref>.</p>"
      )
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.params).to eq(%w[Figure fig-1])
    end

    it "passes when an earlier citation exists even if a later one follows the asset" do
      xml = xml_doc(
        "<p id=\"p0\">See <xref target=\"tab-1\">Table 1</xref>.</p>" \
        "<table id=\"tab-1\"><name>Table 1</name></table>" \
        "<p id=\"p1\">See Table <xref target=\"tab-1\">1</xref> again.</p>"
      )
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "does not flag assets never cited (UnreferencedAssetsRule's domain)" do
      xml = xml_doc("<table id=\"tab-1\"><name>Table 1</name></table>")
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "exempts unnumbered assets" do
      xml = xml_doc(
        "<table id=\"tab-1\" unnumbered=\"true\"><name>Table</name></table>" \
        "<p id=\"p1\">See <xref target=\"tab-1\">Table</xref>.</p>"
      )
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "does not count a citation made inside the asset itself" do
      xml = xml_doc(
        "<figure id=\"fig-1\"><name>See <xref target=\"fig-1\">Figure 1</xref></name></figure>"
      )
      # the only citation is inside the figure: uncited → ISO_21's domain
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "sees citations made from table cells (flag when they come after the asset)" do
      xml = xml_doc(
        "<table id=\"tab-1\"><name>T1</name></table>" \
        "<table id=\"tab-2\"><name>T2</name>" \
        "<thead><tr><th>H</th></tr></thead>" \
        "<tbody><tr><td>See <xref target=\"tab-1\">Table 1</xref></td></tr></tbody>" \
        "</table>"
      )
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.params).to eq(%w[Table tab-1])
    end

    it "passes when a table cell cites a later asset" do
      xml = xml_doc(
        "<table id=\"tab-1\"><name>T1</name>" \
        "<thead><tr><th>H</th></tr></thead>" \
        "<tbody><tr><td>See <xref target=\"tab-2\">Table 2</xref></td></tr></tbody>" \
        "</table>" \
        "<table id=\"tab-2\"><name>T2</name></table>"
      )
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags assets appearing in annexes before their citation" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="c1"><title>Body</title><p id="p1">Body text.</p></clause>
          </sections>
          <annex id="an1"><title>Annex</title>
            <table id="tab-a1"><name>Table A.1</name></table>
          </annex>
          <annex id="an2"><title>Annex 2</title>
            <p id="p2">See <xref target="tab-a1">Table A.1</xref>.</p>
          </annex>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.params).to eq(%w[Table tab-a1])
    end
  end

  describe "code and policy metadata" do
    it "declares ISO_54" do
      expect(rule.code).to eq("ISO_54")
    end

    it "declares House Style policy metadata" do
      meta = described_class.policy_metadata
      expect(meta[:category]).to eq("Referencing > References within the document")
      expect(meta[:source]).to eq(:house_style)
      expect(meta[:mn_category]).to eq(:references)
    end
  end
end
