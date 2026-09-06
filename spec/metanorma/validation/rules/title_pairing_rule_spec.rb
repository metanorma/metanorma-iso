require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::TitlePairingRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(titles_xml)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
          #{titles_xml}
        </bibdata>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  def title_element(type:, lang:, text:)
    %(<title type="#{type}" language="#{lang}">#{text}</title>)
  end

  describe "#check with paired titles" do
    it "passes when both EN and FR have all three components" do
      titles = [
        title_element(type: "title-intro", lang: "en", text: "Foo"),
        title_element(type: "title-intro", lang: "fr", text: "Le Foo"),
        title_element(type: "title-main", lang: "en", text: "Bar"),
        title_element(type: "title-main", lang: "fr", text: "Le Bar"),
        title_element(type: "title-part", lang: "en", text: "Baz"),
        title_element(type: "title-part", lang: "fr", text: "Le Baz")
      ].join("\n")
      expect(rule.check(context_with(titles))).to eq([])
    end
  end

  describe "#check for missing components" do
    it "flags ISO_10 when EN title-intro is missing but FR has it" do
      titles = [
        title_element(type: "title-intro", lang: "fr", text: "Le Foo"),
        title_element(type: "title-main", lang: "en", text: "Bar"),
        title_element(type: "title-main", lang: "fr", text: "Le Bar")
      ].join("\n")
      issues = rule.check(context_with(titles))
      iso10 = issues.select { |i| i.code == "ISO_10" }
      expect(iso10.size).to eq(1)
    end

    it "flags ISO_11 when FR title-intro is missing but EN has it" do
      titles = [
        title_element(type: "title-intro", lang: "en", text: "Foo"),
        title_element(type: "title-main", lang: "en", text: "Bar"),
        title_element(type: "title-main", lang: "fr", text: "Le Bar")
      ].join("\n")
      issues = rule.check(context_with(titles))
      expect(issues.select { |i| i.code == "ISO_11" }.size).to eq(1)
    end

    it "flags ISO_12 when EN title-main is missing but FR has it" do
      titles = [
        title_element(type: "title-main", lang: "fr", text: "Le Bar")
      ].join("\n")
      issues = rule.check(context_with(titles))
      expect(issues.select { |i| i.code == "ISO_12" }.size).to eq(1)
    end

    it "flags ISO_13 when FR title-main is missing but EN has it" do
      titles = [
        title_element(type: "title-main", lang: "en", text: "Bar")
      ].join("\n")
      issues = rule.check(context_with(titles))
      expect(issues.select { |i| i.code == "ISO_13" }.size).to eq(1)
    end

    it "flags ISO_14 when EN title-part is missing but FR has it" do
      titles = [
        title_element(type: "title-main", lang: "en", text: "Bar"),
        title_element(type: "title-main", lang: "fr", text: "Le Bar"),
        title_element(type: "title-part", lang: "fr", text: "Le Baz")
      ].join("\n")
      issues = rule.check(context_with(titles))
      expect(issues.select { |i| i.code == "ISO_14" }.size).to eq(1)
    end

    it "flags ISO_15 when FR title-part is missing but EN has it" do
      titles = [
        title_element(type: "title-main", lang: "en", text: "Bar"),
        title_element(type: "title-main", lang: "fr", text: "Le Bar"),
        title_element(type: "title-part", lang: "en", text: "Baz")
      ].join("\n")
      issues = rule.check(context_with(titles))
      expect(issues.select { |i| i.code == "ISO_15" }.size).to eq(1)
    end
  end
end
