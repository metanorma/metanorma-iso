require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::TitleNamesDoctypeRule do
  let(:rule) { described_class.new }

  def context_with(titles_xml, lang: "en")
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
          #{titles_xml}
        </bibdata>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    state = Metanorma::Iso::Validation::ConverterState.new(
      lang: lang, document: "spec"
    )
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  def title(type:, lang:, text:)
    %(<title type="#{type}" language="#{lang}">#{text}</title>)
  end

  describe "#check" do
    it "passes when title-main does not name a doctype" do
      xml = title(type: "title-main", lang: "en", text: "Quality management")
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags ISO_17 when title-main contains 'International Standard'" do
      xml = title(type: "title-main", lang: "en", text: "International Standard for widgets")
      issues = rule.check(context_with(xml))
      iso17 = issues.select { |i| i.code == "ISO_17" }
      expect(iso17.size).to eq(1)
    end

    it "flags ISO_17 when title-main contains 'Technical Report'" do
      xml = title(type: "title-main", lang: "en", text: "Some Technical Report thing")
      issues = rule.check(context_with(xml))
      expect(issues.select { |i| i.code == "ISO_17" }.size).to eq(1)
    end

    it "flags ISO_18 when title-intro names a doctype" do
      xml = title(type: "title-intro", lang: "en", text: "Technical Specification for X")
      issues = rule.check(context_with(xml))
      expect(issues.select { |i| i.code == "ISO_18" }.size).to eq(1)
    end

    it "is not applicable for non-English documents" do
      xml = title(type: "title-main", lang: "fr", text: "International Standard")
      context = context_with(xml, lang: "fr")
      expect(rule).not_to be_applicable(context)
    end
  end

  describe "code" do
    it "declares ISO_17" do
      expect(described_class.new.code).to eq("ISO_17")
    end
  end
end
