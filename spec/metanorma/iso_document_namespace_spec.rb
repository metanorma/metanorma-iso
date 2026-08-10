# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Metanorma::Iso::Document namespace" do
  describe "canonical namespace" do
    it "exposes Metanorma::Iso::Document as a Module" do
      expect(Metanorma::Iso::Document).to be_a(Module)
    end

    it "exposes Root with the canonical name" do
      expect(Metanorma::Iso::Document::Root.name)
        .to eq("Metanorma::Iso::Document::Root")
    end

    it "Root is a lutaml Serializable" do
      expect(Metanorma::Iso::Document::Root < Lutaml::Model::Serializable).to be(true)
    end
  end

  describe "ISO-specific submodules" do
    [
      %w[Sections IsoPreface],
      %w[Sections IsoForewordSection],
      %w[Sections IsoAbstractSection],
      %w[Sections IsoAnnexSection],
      %w[Sections IsoClauseSection],
      %w[Sections IsoSections],
      %w[Sections IsoTermsSection],
      %w[Metadata IsoBibliographicItem],
      %w[Metadata IsoDocumentType],
      %w[Metadata IsoDocumentId],
      %w[Metadata IsoLocalizedTitle],
      %w[Blocks],
      %w[Terms IsoTerm],
    ].each do |path|
      it "Metanorma::Iso::Document::#{path.join("::")}" do
        constant = path.reduce(Metanorma::Iso::Document) do |ns, name|
          ns.const_get(name)
        end
        expect(constant).to be_a(Module)
        expect(constant.name).to start_with("Metanorma::Iso::Document")
      end
    end
  end

  describe "backwards-compat alias" do
    it "Metanorma::IsoDocument aliases to the new namespace" do
      expect(Metanorma::IsoDocument).to eq(Metanorma::Iso::Document)
    end

    it "Metanorma::IsoDocument::Root resolves via the alias" do
      expect(Metanorma::IsoDocument::Root).to eq(Metanorma::Iso::Document::Root)
    end

    it "the alias preserves class identity (not a duplicate)" do
      expect(Metanorma::IsoDocument::Root.equal?(
               Metanorma::Iso::Document::Root)).to be(true)
    end
  end

  describe "XML round-trip via the new namespace" do
    it "parses an ISO <metanorma> document" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <preface><foreword><p>text</p></foreword></preface>
          <sections><clause id="c1"><title>1</title><p>body</p></clause></sections>
        </metanorma>
      XML
      root = Metanorma::Iso::Document::Root.from_xml(xml)
      expect(root).to be_a(Metanorma::Iso::Document::Root)
      expect(root.preface).to be_a(Metanorma::Iso::Document::Sections::IsoPreface)
    end

    it "parses via the alias too" do
      xml = "<foreword><p>x</p></foreword>"
      fw = Metanorma::IsoDocument::Sections::IsoForewordSection.from_xml(xml)
      expect(fw).to be_a(Metanorma::Iso::Document::Sections::IsoForewordSection)
    end
  end

  describe "parent namespace" do
    it "Metanorma::Standoc::Document is also available" do
      expect(Metanorma::Standoc::Document).to be_a(Module)
      expect(Metanorma::Standoc::Document::Root).to be_a(Class)
    end

    it "Metanorma::StandardDocument alias is available" do
      expect(Metanorma::StandardDocument).to eq(Metanorma::Standoc::Document)
    end
  end
end
