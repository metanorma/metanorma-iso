# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::TermSourceCompleteRule do
  let(:rule) { described_class.new }
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  def xml_doc(term_body, bibliography: nil)
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="t1"><title>Terms and definitions</title>
            <terms id="terms1">
              <term id="term-1">
                <preferred><expression><name>cloud computing</name></expression></preferred>
                #{term_body}
              </term>
            </terms>
          </clause>
        </sections>
        #{bibliography}
      </metanorma>
    XML
  end

  let(:bibliography_one) do
    <<~XML
      <bibliography>
        <references normative="false">
          <bibitem id="iso17788" type="standard">
            <docidentifier>ISO/IEC 17788:2014</docidentifier>
          </bibitem>
        </references>
      </bibliography>
    XML
  end

  describe "#check" do
    it "passes for a term entry with no SOURCE line at all" do
      # whether an entry is reproduced from elsewhere is not decidable
      # from the model: absent SOURCE is not flagged (conservative boundary)
      xml = xml_doc(
        "<definition><verbal-definition>" \
        "<p id=\"d1\">A paradigm for enabling network access.</p>" \
        "</verbal-definition></definition>"
      )
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "passes for a complete SOURCE line citing a bibliography entry" do
      xml = xml_doc(
        "<termsource status=\"identical\">" \
        "<origin bibitemid=\"iso17788\" citeas=\"ISO/IEC 17788:2014\">" \
        "<localityStack><locality type=\"clause\">" \
        "<referenceFrom>3.2.5</referenceFrom>" \
        "</locality></localityStack></origin></termsource>",
        bibliography: bibliography_one
      )
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "passes for a legacy <source> element citing a bibliography entry" do
      xml = xml_doc(
        "<source><origin bibitemid=\"iso17788\" " \
        "citeas=\"ISO/IEC 17788:2014\"/></source>",
        bibliography: bibliography_one
      )
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags ISO_55 for a SOURCE line with no origin" do
      xml = xml_doc("<termsource status=\"identical\"/>",
                    bibliography: bibliography_one)
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_55")
      expect(issues.first.location).to eq("IsoTerm#term-1")
      expect(issues.first.params.first).to eq("cloud computing")
    end

    it "flags ISO_55 for an origin with no bibliography target" do
      xml = xml_doc(
        "<termsource status=\"modified\">" \
        "<origin citeas=\"some document\"/></termsource>",
        bibliography: bibliography_one
      )
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.params.last).to include("no bibliography entry")
    end

    it "flags ISO_55 when the cited source is not listed in the Bibliography" do
      xml = xml_doc(
        "<termsource status=\"identical\">" \
        "<origin bibitemid=\"missing_ref\" " \
        "citeas=\"ISO 99999:9999\"/></termsource>",
        bibliography: bibliography_one
      )
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.params.last).to include("missing_ref")
      expect(issues.first.params.last).to include("not listed in the Bibliography")
    end

    it "flags ISO_55 once per distinct violation on the same entry" do
      xml = xml_doc(
        "<termsource status=\"identical\">" \
        "<origin bibitemid=\"missing_a\"/></termsource>" \
        "<termsource status=\"modified\">" \
        "<origin bibitemid=\"missing_a\"/></termsource>",
        bibliography: bibliography_one
      )
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
    end

    it "accepts normative-reference entries as citation targets" do
      xml = xml_doc(
        "<termsource status=\"identical\">" \
        "<origin bibitemid=\"norm1\"/></termsource>",
        bibliography: <<~XML
          <bibliography>
            <references normative="true">
              <bibitem id="norm1" type="standard">
                <docidentifier>ISO 1</docidentifier>
              </bibitem>
            </references>
            <references normative="false"/>
          </bibliography>
        XML
      )
      expect(rule.check(context_with(xml))).to eq([])
    end
  end

  describe "code and policy metadata" do
    it "declares ISO_55" do
      expect(rule.code).to eq("ISO_55")
    end

    it "declares House Style policy metadata" do
      meta = described_class.policy_metadata
      expect(meta[:category]).to eq("Referencing > References in Clause 3")
      expect(meta[:source]).to eq(:house_style)
      expect(meta[:mn_category]).to eq(:references)
    end
  end
end
