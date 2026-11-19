# frozen_string_literal: true

require_relative "spec_helper"

# ISO front matter flavor: <std-meta> per the IEC/ISO Coding Guidelines
# ed. 2.1 §4.3.2 ISO profile — std-ident decomposition, std-org-abbrev,
# content-language, std-ref dated/undated, the ISO-form doc-ref
# ("ISO/FDIS 19135:2025(E)"), release-date, permissions — plus the
# <processing-meta> child of <standard> with the ed 2.1 attributes and
# the guidelines-edition custom-meta.
RSpec.describe "ISO front matter (std-meta)" do
  let(:xml) do
    <<~XML
      <metanorma>
        <bibdata type="standard">
          <title language="en" type="title-intro">Geographic information</title>
          <title language="en" type="title-main">Registration</title>
          <docidentifier type="ISO">ISO/FDIS 19135:2025</docidentifier>
          <docnumber>19135</docnumber>
          <language>en</language>
          <edition>2</edition>
          <date type="released"><on>2025-09-01</on></date>
          <copyright>
            <from>2025</from>
            <owner><organization><name>ISO</name><abbreviation>ISO</abbreviation></organization></owner>
          </copyright>
          <status><stage>50</stage></status>
          <ext>
            <doctype>international-standard</doctype>
            <ics><code>35.240.70</code></ics>
          </ext>
        </bibdata>
        <sections><clause id="c1"><title>Scope</title><p id="p1">Text.</p></clause></sections>
      </metanorma>
    XML
  end

  let(:doc) { Nokogiri::XML(Metanorma::Iso::Sts.convert(xml)) }
  let(:std_meta) { doc.at_xpath("//front/std-meta") }

  it "emits <std-meta> (not <iso-meta>)" do
    expect(std_meta).not_to be_nil
    expect(doc.at_xpath("//front/iso-meta")).to be_nil
  end

  it "carries <std-org-abbrev>ISO</std-org-abbrev> under std-org" do
    org = doc.at_xpath("//front/std-meta/std-org")
    expect(org).not_to be_nil
    expect(org["std-org-type"]).to eq("sdo")
    expect(doc.at_xpath("//front/std-meta/std-org/std-org-abbrev").text).to eq("ISO")
  end

  it "carries <content-language>" do
    expect(doc.xpath("//front/std-meta/content-language").map(&:text)).to eq(%w[en])
  end

  it "emits the ISO-form <doc-ref> with the language code" do
    expect(doc.at_xpath("//front/std-meta/doc-ref").text).to eq("ISO/FDIS 19135:2025(E)")
  end

  it "decomposes <std-ident> and emits dated/undated <std-ref>" do
    expect(doc.at_xpath("//front/std-meta/std-ident/originator").text).to eq("ISO")
    expect(doc.at_xpath("//front/std-meta/std-ident/doc-number").text).to eq("19135")
    refs = doc.xpath("//front/std-meta/std-ref")
    expect(refs.map { |r| r["type"] }).to eq(%w[dated undated])
  end

  it "emits the release date and the copyright permissions block" do
    expect(doc.xpath("//front/std-meta/release-date").map(&:text)).to include("2025-09-01")
    expect(doc.at_xpath("//front/std-meta/permissions/copyright-holder").text).to eq("ISO")
  end

  describe "<processing-meta>" do
    it "sits directly under <standard> with the ed 2.1 attributes" do
      pm = doc.at_xpath("/standard/processing-meta")
      expect(pm).not_to be_nil
      expect(pm["tagset-family"]).to eq("sts")
      expect(pm["base-tagset"]).to eq("interchange")
      expect(pm["table-model"]).to eq("xhtml")
      expect(pm["mathml-version"]).to eq("3.0")
      expect(pm["math-representation"]).to eq("mathml")
      expect(pm["terminology-model"]).to eq("tbx")
    end

    it "names the guidelines edition via custom-meta-group" do
      name = doc.at_xpath("/standard/processing-meta/custom-meta-group/custom-meta/meta-name")
      value = doc.at_xpath("/standard/processing-meta/custom-meta-group/custom-meta/meta-value")
      expect(name.text).to eq("iec_iso_coding_guidelines_edition")
      expect(value.text).to eq("2.1")
    end
  end

  it "declares the mml and xlink namespaces on <standard>" do
    root = doc.root
    expect(root.namespaces).to include("xmlns:mml" => "http://www.w3.org/1998/Math/MathML")
    expect(root.namespaces).to include("xmlns:xlink" => "http://www.w3.org/1999/xlink")
  end
end
