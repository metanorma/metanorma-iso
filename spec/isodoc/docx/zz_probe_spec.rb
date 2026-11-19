# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::ModelUtils do
  let(:utilizer) { Class.new { include IsoDoc::Iso::Docx::ModelUtils }.new }

  describe "#parse_model_with_ordering" do
    # Ordering must reach mixed inline content (text around <em>), not
    # just the root, even when leptris is the ambient adapter
    # (lutaml/lutaml-model#1163).
    let(:xml) do
      <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation" flavor="iso">
        <bibdata type="standard">
        <title language="en" type="title-main">Main T</title>
        </bibdata>
        <preface><foreword id="fw"><fmt-title>T</fmt-title><p>Hello <em>world</em> end</p></foreword></preface>
        <sections><clause id="c1"><fmt-title>C</fmt-title><p>x</p></clause></sections>
        </metanorma>
      XML
    end
    let(:root) do
      Lutaml::Model::AdapterScope.with(xml: :leptris) do
        utilizer.parse_model_with_ordering(Metanorma::Iso::Document::Root, xml)
      end
    end
    let(:paragraph) { root.preface.foreword.paragraphs.first }

    it "populates element_order on inline paragraph content" do
      expect(utilizer.ordered?(paragraph)).to be(true)
    end
  end
end
