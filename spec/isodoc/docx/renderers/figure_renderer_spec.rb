# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::FigureRenderer do
  let(:adapter) { build_adapter }

  it "renders figure name with Figuretitle style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <figure id="f1">
            <name>Figure 1 — Sample</name>
            <image src="spec/fixtures/dummy.png" mimetype="image/png" height="100" width="100"/>
          </figure>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }

      expect(styles).to include("Figuretitle"),
        "figure name should use Figuretitle, got: #{styles.inspect}"
    end
  end

  it "renders figure notes with Figurenote style (not generic Noteindent)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <figure id="f1">
            <name>Figure 1 — Sample</name>
            <note id="fnote1"><p>Source: own elaboration.</p></note>
          </figure>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }

      expect(styles).to include("Figurenote"),
        "figure note should use Figurenote, got: #{styles.inspect}"
    end
  end
end
