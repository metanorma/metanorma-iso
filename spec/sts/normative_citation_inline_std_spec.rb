# frozen_string_literal: true

require_relative "spec_helper"

# A body citation of a normative reference is an inline <std> (NISO STS
# idiom), not a bibr <xref>: guidelines 10.1.6 allow bibr only for the
# bibliography. The <std> carries the reference's designation in <std-ref>
# and its URN in <std-id>, which guidelines 10.1.7 and 10.2 match against
# the norm-refs entry. A bibliography citation keeps its bibr <xref>.
#
# Input is built from scratch with invented designations.
RSpec.describe "Normative citations as inline std" do
  let(:source_xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">
          <title language="en" type="main">Widget systems</title>
          <docidentifier type="ISO">ISO 99002:2024</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="scope"><title>Scope</title>
            <p id="p_scope">Gauges follow <xref target="NORMGAUGE" id="_x1"/><semx element="xref" source="_x1"><fmt-xref type="inline" target="NORMGAUGE">ISO 4242:2011,  Clause 5</fmt-xref></semx>, and the catalogue is in <xref target="BIBCATALOGUE" id="_x2"/><semx element="xref" source="_x2"><fmt-xref type="inline" target="BIBCATALOGUE">[1]</fmt-xref></semx>.</p>
          </clause>
          <references id="norm-refs" normative="true"><title>Normative references</title>
            <p id="p_norm">The following documents are referred to in the text.</p>
            <bibitem id="NORMGAUGE" type="standard">
              <docidentifier type="ISO">ISO 4242:2011</docidentifier>
              <docidentifier type="URN">urn:iso:std:iso:4242:stage-90.92</docidentifier>
            </bibitem>
          </references>
        </sections>
        <bibliography>
          <references id="bib" normative="false"><title>Bibliography</title>
            <bibitem id="BIBCATALOGUE" type="standard">
              <docidentifier type="ISO">ISO 5000</docidentifier>
              <docidentifier type="URN">urn:iso:std:iso:5000</docidentifier>
            </bibitem>
          </references>
        </bibliography>
      </metanorma>
    XML
  end

  let(:sts) { Metanorma::Iso::Sts.convert(source_xml) }
  let(:doc) { Nokogiri::XML(sts).tap(&:remove_namespaces!) }
  let(:scope_p) { doc.at_xpath("//sec[@id='scope']/p") }

  def rule_ids
    Metanorma::Iso::Sts::Validator.new.validate(sts).errors.map { |e| e[:rule_id] }
  end

  it "emits the normative citation as an inline std, not a bibr xref" do
    expect(doc.xpath("//xref[@rid='NORMGAUGE']")).to be_empty
    std = scope_p.at_xpath("./std")
    expect(std).not_to be_nil
    expect(std.at_xpath("./std-ref")&.text&.tr("\u00A0", " ")).to eq("ISO 4242:2011")
    expect(std.at_xpath("./std-id[@std-id-link-type='urn']")&.text)
      .to eq("urn:iso:std:iso:4242:stage-90.92")
  end

  it "keeps the locality as paragraph text after the std, in order" do
    children = scope_p.children.reject { |n| n.text? && n.text.strip.empty? }
    names = children.map { |n| n.element? ? n.name : "#text" }
    std_index = names.index("std")
    expect(std_index).not_to be_nil
    expect(names[0]).to eq("#text")
    expect(children[0].text).to start_with("Gauges follow")
    expect(children[std_index + 1].text.tr(" ", " ")).to start_with(",  Clause 5")
  end

  it "keeps a bibliography citation as a bibr xref to the bibliography ref" do
    xref = scope_p.at_xpath("./xref[@rid='BIBCATALOGUE']")
    expect(xref).not_to be_nil
    expect(xref["ref-type"]).to eq("bibr")
  end

  it "raises no bibr-target error (guidelines 10.1.6)" do
    expect(rule_ids).not_to include("iso-gdg-10.1.6-1")
  end

  it "raises no std-identity error for the inline std (guidelines 10.1.7, 10.2)" do
    expect(rule_ids).not_to include("iso-gdg-10.1.7-1", "iso-gdg-10.2-1")
  end
end
