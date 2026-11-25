# frozen_string_literal: true

require "bundler/setup"
require "metanorma/document"
require "metanorma-iso"
require "metanorma/iso/document"
require "metanorma/iso/html"

RSpec.describe Metanorma::Iso::Html::Renderer do
  let(:themes_dir) { File.expand_path("../../../../lib/metanorma/iso/themes", __dir__) }
  let(:fixture) { File.expand_path("../../../fixtures/html-theme-parity/document.xml", __dir__) }
  let(:document) { Metanorma::Iso::Document::Root.from_xml(File.read(fixture)) }

  context "with the default ISO theme (ISO/IEC Directives house style)" do
    let(:theme) { Metanorma::Html::Theme.load(:iso) }
    let(:html) { described_class.new.generate_full_document(document, theme: theme) }

    def dir2_selectors
      [
        ".main-section :is(h1, h2, h3, h4, h5, h6) > .caption-label",
        ".main-section .annex-title",
        ".main-section .caption-delim { opacity: 1; }",
        ".main-section .TermNum",
        ".main-section p.term-source",
        ".main-section .note-block::before",
        ".main-section .mn-labeled-list .li-label",
        ".main-section .table-caption",
        ".main-section .TableFootnoteRef",
        ".main-section figcaption",
        ".main-section .biblio-entry",
        '[data-theme="dark"], [data-theme="oled"]',
      ]
    end

    it "is registered by this gem with the Directives palette" do
      expect(theme).to have_attributes(
        theme_dir: File.join(themes_dir, "iso"), primary: "#0b5aa2",
        font_body: start_with('"Segoe UI"'), extra_css: nil
      )
    end

    it "styles the body elements defined by ISO/IEC Directives Part 2" do
      expect(dir2_selectors.reject { |selector| File.read(File.join(themes_dir, "iso", "custom.css")).include?(selector) }).to be_empty
    end

    it "renders the Directives palette and stylesheet" do
      expect(html).to include("--mn-primary: #0b5aa2;", "--iso-link: var(--mn-primary);",
                              "fonts.googleapis.com/css2?family=Roboto")
    end

    it "drops the legacy serif body" do
      expect(html).not_to include("Cambria")
    end
  end

  context "with the iso-legacy theme" do
    let(:theme) { Metanorma::Html::Theme.load("iso-legacy") }
    let(:html) { described_class.new.generate_full_document(document, theme: theme) }

    it "keeps the previous default palette" do
      expect(theme).to have_attributes(theme_dir: File.join(themes_dir, "iso-legacy"), primary: "#b3000c")
    end

    it "keeps the legacy serif body" do
      expect(html).to include("font-family: Cambria, serif;")
    end

    it "does not load the Directives stylesheet" do
      expect(html).not_to include("--iso-link")
    end
  end
end
