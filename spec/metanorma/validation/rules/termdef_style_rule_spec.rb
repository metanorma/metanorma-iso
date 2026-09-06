require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::TermdefStyleRule do
  let(:rule) { described_class.new }

  def context_with(xml, lang: "en", script: "Latn")
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    state = Metanorma::Iso::Validation::ConverterState.new(
      lang: lang, script: script, document: "spec"
    )
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  def term_xml(definition_text:, id: "t1", preferred: "Term")
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <terms id="terms1">
            <title>Terms</title>
            <term id="#{id}">
              <preferred>#{preferred}</preferred>
              <definition><verbal-definition><p>#{definition_text}</p></verbal-definition></definition>
            </term>
          </terms>
        </sections>
      </metanorma>
    XML
  end

  describe "#check ISO_4 (article prefix, English)" do
    it "flags definition starting with 'the'" do
      xml = term_xml(definition_text: "the study of cats")
      issues = rule.check(context_with(xml))
      iso4 = issues.select { |i| i.code == "ISO_4" }
      expect(iso4.size).to eq(1)
      expect(iso4.first.message).to include("term definition starts with article")
    end

    it "passes definition starting with a noun" do
      xml = term_xml(definition_text: "study of cats")
      issues = rule.check(context_with(xml))
      expect(issues.select { |i| i.code == "ISO_4" }).to eq([])
    end

    it "does not flag article prefixes for non-English documents" do
      xml = term_xml(definition_text: "the study of cats")
      issues = rule.check(context_with(xml, lang: "fr"))
      expect(issues.select { |i| i.code == "ISO_4" }).to eq([])
    end
  end

  describe "#check ISO_35 (period suffix, Latin/Cyrillic)" do
    it "flags Latin-script definition ending with period" do
      xml = term_xml(definition_text: "study of cats.")
      issues = rule.check(context_with(xml, script: "Latn"))
      iso35 = issues.select { |i| i.code == "ISO_35" }
      expect(iso35.size).to eq(1)
    end

    it "passes Latin-script definition without trailing period" do
      xml = term_xml(definition_text: "study of cats")
      issues = rule.check(context_with(xml, script: "Latn"))
      expect(issues.select { |i| i.code == "ISO_35" }).to eq([])
    end

    it "does not flag for non-Latin/Cyrillic scripts" do
      xml = term_xml(definition_text: "study of cats.")
      issues = rule.check(context_with(xml, script: "Hans"))
      expect(issues.select { |i| i.code == "ISO_35" }).to eq([])
    end
  end
end
