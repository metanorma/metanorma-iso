# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::IsoMetaTransformer do
  let(:t) { Metanorma::Iso::Sts::Transformer }

  let(:full) do
    <<~XML
      <title language="en" type="title-intro">Geographic information</title>
      <title language="en" type="title-main">Registration</title>
      <title language="en" type="title-part">Part 1</title>
      <docidentifier type="ISO">ISO/FDIS 19135:2025</docidentifier>
      <docnumber>19135</docnumber>
      <language>en</language>
      <edition>2</edition>
      <date type="released"><on>2025-09-01</on></date>
      <copyright><from>2025</from>
        <owner><organization><name>ISO</name><abbreviation>ISO</abbreviation></organization></owner>
      </copyright>
      <status><stage>50</stage></status>
      <ext><doctype>technical-specification</doctype><ics><code>35.240.70</code></ics></ext>
    XML
  end

  def bibdata_of(inner)
    source = t::SourceDocument.parse(<<~XML)
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">#{inner}</bibdata>
        <sections/>
      </metanorma>
    XML
    [t::Context.new(source), source.bibdata]
  end

  def meta_for(inner)
    context, bibdata = bibdata_of(inner)
    Nokogiri::XML(described_class.new(context).transform(bibdata).to_xml)
  end

  it "returns a MetadataStd, empty when there is no bibdata" do
    context, = bibdata_of("<docidentifier>ISO 1</docidentifier>")
    result = described_class.new(context).transform(nil)

    expect(result).to be_a(Sts::NisoSts::MetadataStd)
    expect(Nokogiri::XML(result.to_xml).root.element_children).to be_empty
  end

  describe "title-wrap" do
    it "splits intro, main and complementary titles and joins them in <full>" do
      tw = meta_for(full).at_xpath("/std-meta/title-wrap")

      expect(tw["xml:lang"]).to eq("en")
      expect(tw.at_xpath("./intro").text).to eq("Geographic information")
      expect(tw.at_xpath("./main").text).to eq("Registration")
      expect(tw.at_xpath("./compl").text).to eq("Part 1")
      expect(tw.at_xpath("./full").text).to eq("Geographic information — Registration — Part 1")
    end

    it "treats an untyped title as the main title" do
      doc = meta_for(%(<title language="en">Plain title</title><docidentifier>ISO 1</docidentifier>))

      expect(doc.at_xpath("/std-meta/title-wrap/main").text).to eq("Plain title")
    end

    it "emits no title-wrap when there is no title" do
      expect(meta_for("<docidentifier>ISO 1</docidentifier>").at_xpath("/std-meta/title-wrap")).to be_nil
    end
  end

  describe "identification" do
    it "decomposes <std-ident> with the abbreviated document type" do
      ident = meta_for(full).at_xpath("/std-meta/std-ident")

      expect(ident.at_xpath("./originator").text).to eq("ISO")
      expect(ident.at_xpath("./doc-type").text).to eq("TS")
      expect(ident.at_xpath("./doc-number").text).to eq("19135")
      expect(ident.at_xpath("./edition").text).to eq("2")
    end

    {
      "international-standard" => "IS", "technical-report" => "TR",
      "publicly-available-specification" => "PAS", "guide" => "GUIDE",
      "amendment" => "Amd", "technical-corrigendum" => "TCor"
    }.each do |doctype, abbr|
      it "maps doctype #{doctype} to #{abbr}" do
        doc = meta_for(%(<docidentifier>ISO 1</docidentifier><docnumber>1</docnumber><ext><doctype>#{doctype}</doctype></ext>))

        expect(doc.at_xpath("/std-meta/std-ident/doc-type").text).to eq(abbr)
      end
    end

    it "emits dated then undated <std-ref> when the identifier carries a year" do
      refs = meta_for(full).xpath("/std-meta/std-ref")

      expect(refs.map { |r| [r["type"], r.text] }).to eq(
        [["dated", "ISO/FDIS 19135:2025"], ["undated", "ISO/FDIS 19135"]],
      )
    end

    it "emits only the dated <std-ref> when the identifier has no year" do
      refs = meta_for(%(<docidentifier>ISO 1234</docidentifier>)).xpath("/std-meta/std-ref")

      expect(refs.map { |r| [r["type"], r.text] }).to eq([["dated", "ISO 1234"]])
    end

    it "emits <doc-ref> as the dated identifier plus the upper-cased language initial" do
      expect(meta_for(full).at_xpath("/std-meta/doc-ref").text).to eq("ISO/FDIS 19135:2025(E)")
    end

    it "emits the language as <content-language>, defaulting to en" do
      expect(meta_for(full).xpath("/std-meta/content-language").map(&:text)).to eq(%w[en])
      expect(meta_for(%(<docidentifier>ISO 1</docidentifier>)).xpath("/std-meta/content-language").map(&:text)).to eq(%w[en])
    end

    it "emits the publishing organisation as sdo <std-org>" do
      org = meta_for(full).at_xpath("/std-meta/std-org")

      expect(org["std-org-type"]).to eq("sdo")
      expect(org.at_xpath("./std-org-abbrev").text).to eq("ISO")
    end
  end

  describe "release version" do
    { "60" => "IS", "50" => "FDIS", "40" => "DIS", "30" => "CD", "20" => "WD" }.each do |stage, abbr|
      it "maps stage #{stage} to #{abbr}" do
        doc = meta_for(%(<docidentifier>ISO 1</docidentifier><status><stage>#{stage}</stage></status>))

        expect(doc.at_xpath("/std-meta/release-version").text).to eq(abbr)
      end
    end

    it "emits no release-version without a status" do
      expect(meta_for(%(<docidentifier>ISO 1</docidentifier>)).at_xpath("/std-meta/release-version")).to be_nil
    end
  end

  describe "dates, committee data, ICS and permissions" do
    it "emits the released date as <release-date>" do
      expect(meta_for(full).xpath("/std-meta/release-date").map(&:text)).to eq(["2025-09-01"])
    end

    it "ignores dates that are not 'released'" do
      doc = meta_for(%(<docidentifier>ISO 1</docidentifier><date type="published"><on>2020-01-01</on></date>))

      expect(doc.at_xpath("/std-meta/release-date")).to be_nil
    end

    it "emits ICS codes as plain strings" do
      expect(meta_for(full).xpath("/std-meta/ics").map(&:text)).to eq(["35.240.70"])
    end

    it "emits permissions with the copyright statement, year and holder" do
      perm = meta_for(full).at_xpath("/std-meta/permissions")

      expect(perm.at_xpath("./copyright-statement").text).to eq("© 2025 ISO")
      expect(perm.at_xpath("./copyright-year").text).to eq("2025")
      expect(perm.at_xpath("./copyright-holder").text).to eq("ISO")
    end

    it "emits no permissions without copyright" do
      expect(meta_for(%(<docidentifier>ISO 1</docidentifier>)).at_xpath("/std-meta/permissions")).to be_nil
    end
  end

  describe "child order" do
    it "follows the STS content-model sequence" do
      order = meta_for(full).root.element_children.map(&:name).uniq

      expect(order).to eq(
        %w[title-wrap release-version std-ident std-org content-language std-ref doc-ref release-date ics permissions],
      )
    end
  end
end
