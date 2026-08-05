# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts do
  describe ".convert_to_model" do
    it "returns a Sts::NisoSts::Standard built from the source XML",
       :rice_e2e do
      model = described_class.convert_to_model(File.read(rice_xml_path))

      expect(model).to be_a(Sts::NisoSts::Standard)
      expect(model.front).to be_a(Sts::NisoSts::Front)
      expect(model.front.iso_meta).to be_a(Sts::NisoSts::MetadataIso)
      expect(model.body).to be_a(Sts::NisoSts::Body)
    end
  end

  describe ".convert" do
    it "returns ISO-STS XML with a <standard> root" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
          <bibdata type="standard">
            <title language="en" type="main">Test</title>
            <docidentifier>ISO 9999</docidentifier>
            <language>en</language>
            <status><stage>60</stage></status>
          </bibdata>
          <sections><clause id="s1"><title>Scope</title><p>Hello</p></clause></sections>
        </metanorma>
      XML

      sts = described_class.convert(xml)
      expect(sts).to include("<standard")
      expect(sts).to include("<iso-meta")
    end

    it "handles empty bibdata gracefully" do
      xml = '<metanorma xmlns="https://www.metanorma.org/ns/standoc"/>'
      sts = described_class.convert(xml)
      expect(sts).to include("<standard")
    end
  end

  describe ".render_html" do
    let(:sts_xml) do
      <<~XML
        <standard xmlns:xlink="http://www.w3.org/1999/xlink">
          <front><iso-meta>
            <title-wrap xml:lang="en"><main>Test Document</main></title-wrap>
          </iso-meta></front>
          <body><p>Hello world</p></body>
        </standard>
      XML
    end

    it "renders STS XML to a branded HTML page" do
      html = described_class.render_html(sts_xml)
      expect(html).to start_with("<!DOCTYPE html>")
      expect(html).to include("Test Document")
      expect(html).to include("Hello world")
      expect(html).to include("ISO")
    end

    it "renders a body fragment with full_document: false" do
      html = described_class.render_html(sts_xml, full_document: false)
      expect(html).not_to start_with("<!DOCTYPE html>")
      expect(html).not_to include("<html")
      expect(html).to include("Hello world")
    end

    it "accepts a typed model (round-tripping through XML)" do
      model = Sts::NisoSts::Standard.from_xml(sts_xml)
      html = described_class.render_html(model)
      expect(html).to start_with("<!DOCTYPE html>")
      expect(html).to include("Test Document")
    end
  end
end
