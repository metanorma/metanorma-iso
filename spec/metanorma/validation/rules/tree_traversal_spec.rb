# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::TreeTraversal do
  # The rules mix in TreeTraversal; a style rule exercises extract_text
  # over real document models through from_xml.
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }

  def context_with(text, para_id: "_bff989c0-7244-3917-9bed-9771c1af6964")
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            <p id="#{para_id}">#{text}</p>
          </clause>
        </sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  describe "#extract_text" do
    # A traversal instance: TreeTraversal is mixed into Base and every
    # rule class; any style rule exposes the helpers.
    let(:walker) { Metanorma::Iso::Validation::Rules::StylePerCentRule.new }

    it "does not append identifier and metadata attributes to the text" do
      para = Metanorma::IsoDocument::Root.from_xml(<<~XML)
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <sections><clause id="c1">
            <p id="_bff989c0-7244-3917-9bed-9771c1af6964" type="note" displayorder="5">Clean prose.</p>
          </clause></sections>
        </metanorma>
      XML
      paragraph, _parent = walker.each_paragraph(para).first

      text = walker.extract_text(paragraph, strip: %i(stem fmt_stem))

      expect(text).to eq("Clean prose.")
    end

    it "keeps DocumentIdentifier content, whose id maps as XML content" do
      identifier =
        Metanorma::Document::Relaton::DocumentIdentifier
          .new(id: "ISO/IEC Directives, Part 1", type: "ISO")

      expect(walker.extract_text(identifier))
        .to include("ISO/IEC Directives, Part 1")
    end
  end

  describe "date-duration scanning over uuid-identified paragraphs" do
    let(:rule) { Metanorma::Iso::Validation::Rules::StyleDateDurationRule.new }

    it "finds no year range in a uuid id" do
      # The uuid middle segments "7244-3917" match /\d{4}-\d{4}/; the
      # paragraph text carries no dates (metanorma/metanorma-pdfa#115).
      issues = rule.check(context_with("Clean prose without dates."))

      expect(issues).to eq([])
    end

    it "still flags a genuine year range in the text" do
      issues = rule.check(context_with("the study covered 2020-2030"))

      expect(issues.size).to eq(1)
      expect(issues.first.message).to include("2020 to 2030")
    end
  end

  describe "per cent scanning over uuid-identified paragraphs" do
    let(:rule) { Metanorma::Iso::Validation::Rules::StylePerCentRule.new }

    it "finds no percent in a uuid id" do
      issues = rule.check(context_with("Clean prose without percentages."))

      expect(issues).to eq([])
    end

    it "still flags percent in the text" do
      issues = rule.check(context_with("grew by 45 percent"))

      expect(issues.size).to eq(1)
      expect(issues.first.message).to include("per cent")
    end
  end
end
