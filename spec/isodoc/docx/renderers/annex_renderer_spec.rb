# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::AnnexRenderer do
  let(:adapter) { build_adapter }

  it "renders annex title with Annex paragraph style" do
    xml = minimal_iso_xml(<<~INNER)
      <annex id="a1" inline-header="false" obligation="normative">
        <title>Annex A (informative)</title>
        <p>Annex body.</p>
      </annex>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }
      expect(styles).to include("ANNEX"),
        "annex title should use ANNEX style, got: #{styles.inspect}"
    end
  end

  it "sets the in_annex context flag for descendants" do
    xml = minimal_iso_xml(<<~INNER)
      <annex id="a1" inline-header="false" obligation="normative">
        <title>Annex</title>
        <clause id="a1c1"><title>In annex</title><p>Body.</p></clause>
      </annex>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      expect(adapter.context.in_annex).to eq(false)
    end
  end
end
