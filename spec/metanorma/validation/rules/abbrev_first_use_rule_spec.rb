# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::AbbrevFirstUseRule do
  let(:rule) { described_class.new }
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  # Document carrying no abbreviated-terms list: the abbreviation is
  # declared by a Clause 3 designation (abbreviation-type), and the body
  # uses it.
  def xml_no_list(body:, scope:, title: nil)
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
          #{title ? %(<title language="en" type="main">#{title}</title>) : nil}
        </bibdata>
        <sections>
          <clause type="scope" id="scope1"><title>Scope</title>
            <p id="s1">#{scope}</p>
          </clause>
          <clause id="terms1"><title>Terms and definitions</title>
            <terms id="t1">
              <term id="term-1">
                <preferred><expression><name>System Analysis and Graph Theory</name></expression></preferred>
                <preferred><expression><name>SAGT</name><abbreviation-type>acronym</abbreviation-type></expression></preferred>
                <definition><verbal-definition><p id="d1">A SAGT node is a system.</p></verbal-definition></definition>
              </term>
            </terms>
          </clause>
          <clause id="body1"><title>Body</title>
            <p id="b1">#{body}</p>
          </clause>
        </sections>
      </metanorma>
    XML
  end

  describe "declared abbreviations" do
    it "ignores documents without declared abbreviations" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="c1"><title>Body</title><p id="p1">Plain text only.</p></clause>
          </sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end
  end

  describe "first-use expansion in running text (no abbreviated-terms list)" do
    it "passes when the body expands the abbreviation before its first use" do
      xml = xml_no_list(
        body: "System Analysis and Graph Theory (SAGT) is applied here.",
        scope: "This document is about graph theory."
      )
      body_flags = rule.check(context_with(xml))
        .select { |i| i.params.include?("the body of the document") }
      expect(body_flags).to eq([])
    end

    it "flags ISO_53 when the body uses the abbreviation before any expansion" do
      xml = xml_no_list(
        body: "SAGT nodes are analysed here, long after the declaration.",
        scope: "This document is about graph theory."
      )
      issues = rule.check(context_with(xml))
        .select { |i| i.params.include?("the body of the document") }
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_53")
      expect(issues.first.params.first).to eq("SAGT")
    end

    it "flags when the expansion appears only after the bare use" do
      xml = xml_no_list(
        body: "SAGT nodes matter. System Analysis and Graph Theory (SAGT) " \
              "is defined in Clause 3.",
        scope: "This document is about graph theory."
      )
      issues = rule.check(context_with(xml))
        .select { |i| i.params.include?("the body of the document") }
      expect(issues.size).to eq(1)
    end

    it "does not treat the designation itself as a bare use" do
      xml = xml_no_list(
        body: "Nothing to see; the body never uses the abbreviation.",
        scope: "This document is about graph theory."
      ).sub("A SAGT node is a system.", "A node of the described system.")
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags ISO_53 per entry when Clause 3 entry text uses the abbreviation bare" do
      xml = xml_no_list(
        body: "The body never uses the abbreviation.",
        scope: "This document is about graph theory."
      )
      # entry d1 carries "A SAGT node is a system." with no expansion
      issues = rule.check(context_with(xml))
        .select { |i| i.params.include?("the terms and definitions entry") }
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_53")
    end

    it "passes for an entry whose text expands the abbreviation" do
      xml = xml_no_list(
        body: "The body never uses the abbreviation.",
        scope: "This document is about graph theory."
      ).sub("A SAGT node is a system.",
            "A System Analysis and Graph Theory (SAGT) node is a system.")
      issues = rule.check(context_with(xml))
      expect(issues).to eq([])
    end
  end

  describe "abbreviated-terms list makes body expansion optional" do
    let(:xml_with_list) do
      <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause type="scope" id="scope1"><title>Scope</title>
              <p id="s1">This document is about graph theory.</p>
            </clause>
            <clause id="terms1"><title>Terms and definitions</title>
              <terms id="t1">
                <term id="term-1">
                  <preferred><expression><name>System Analysis and Graph Theory</name></expression></preferred>
                  <preferred><expression><name>SAGT</name><abbreviation-type>acronym</abbreviation-type></expression></preferred>
                </term>
              </terms>
              <definitions type="abbreviated_terms" id="defs1">
                <title>Abbreviated terms</title>
                <dl id="dl1"><dt>SAGT</dt><dd><p>System Analysis and Graph Theory</p></dd></dl>
              </definitions>
            </clause>
            <clause id="body1"><title>Body</title>
              <p id="b1">SAGT nodes are used everywhere without expansion.</p>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "does not flag a bare body use when an abbreviated-terms list exists" do
      expect(rule.check(context_with(xml_with_list))).to eq([])
    end

    it "does not flag a bare Clause 3 entry use when a list exists" do
      # the fixture entry has no definition text; extend with a bare use
      xml = xml_with_list.sub(
        "</term>",
        '<definition><verbal-definition><p id="d1">A SAGT node.</p>' \
        "</verbal-definition></definition></term>"
      )
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "detects a titled abbreviated-terms list without the type attribute" do
      xml = xml_with_list.sub(%( type="abbreviated_terms"), "")
      expect(rule.check(context_with(xml))).to eq([])
    end
  end

  describe "Title and Scope expansion" do
    it "flags ISO_53 when the Title carries the abbreviation without expansion" do
      xml = xml_no_list(
        body: "No abbreviations in the body.",
        scope: "This document is about graph theory.",
        title: "SAGT and modelling"
      )
      issues = rule.check(context_with(xml))
        .select { |i| i.params.include?("Title") }
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_53")
      expect(issues.first.location).to eq("IsoBibliographicItem")
    end

    it "passes when the Title itself expands the abbreviation" do
      xml = xml_no_list(
        body: "No abbreviations in the body.",
        scope: "This document is about graph theory.",
        title: "Systems — System Analysis and Graph Theory (SAGT)"
      )
      issues = rule.check(context_with(xml)).select { |i| i.params.include?("Title") }
      expect(issues).to eq([])
    end

    it "flags ISO_53 when the Scope uses the abbreviation without expansion" do
      xml = xml_no_list(
        body: "No abbreviations in the body.",
        scope: "This document defines SAGT behaviour."
      )
      issues = rule.check(context_with(xml)).select { |i| i.params.include?("Scope") }
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_53")
    end

    it "passes when the Scope expands the abbreviation at its first use" do
      xml = xml_no_list(
        body: "No abbreviations in the body.",
        scope: "Systems (SAGT) are defined here; later SAGT mentions are fine."
      )
      issues = rule.check(context_with(xml)).select { |i| i.params.include?("Scope") }
      expect(issues).to eq([])
    end

    it "requires Title and Scope expansion even when an abbreviated-terms list exists" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause type="scope" id="scope1"><title>Scope</title>
              <p id="s1">This document defines SAGT behaviour.</p>
            </clause>
            <clause id="terms1"><title>Terms and definitions</title>
              <definitions type="abbreviated_terms" id="defs1">
                <title>Abbreviated terms</title>
                <dl id="dl1"><dt>SAGT</dt><dd><p>System Analysis and Graph Theory</p></dd></dl>
              </definitions>
            </clause>
            <clause id="body1"><title>Body</title>
              <p id="b1">SAGT everywhere, freely.</p>
            </clause>
          </sections>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.params).to include("Scope")
    end
  end

  describe "code and policy metadata" do
    it "declares ISO_53" do
      expect(rule.code).to eq("ISO_53")
    end

    it "declares House Style policy metadata" do
      meta = described_class.policy_metadata
      expect(meta[:category]).to eq("Abbreviated terms")
      expect(meta[:source]).to eq(:house_style)
      expect(meta[:mn_category]).to eq(:style)
    end
  end
end
