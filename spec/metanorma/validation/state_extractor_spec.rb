require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::StateExtractor do
  describe ".extract" do
    it "returns default state for nil root" do
      state = described_class.extract(nil)
      expect(state.lang).to eq("en")
      expect(state.script).to eq("Latn")
    end

    it "extracts language from bibdata.language" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata>
            <docidentifier>ISO 1</docidentifier>
            <language>fr</language>
            <script>Latn</script>
          </bibdata>
        </metanorma>
      XML
      root = Metanorma::IsoDocument::Root.from_xml(xml)
      state = described_class.extract(root)
      expect(state.lang).to eq("fr")
      expect(state.script).to eq("Latn")
    end

    it "extracts doctype from bibdata.ext.doctype" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata>
            <docidentifier>ISO 1</docidentifier>
            <ext><doctype>technical-report</doctype></ext>
          </bibdata>
        </metanorma>
      XML
      root = Metanorma::IsoDocument::Root.from_xml(xml)
      state = described_class.extract(root)
      expect(state.doctype).to eq("technical-report")
    end

    it "extracts vocab from bibdata.ext.subdoctype" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata>
            <docidentifier>ISO 1</docidentifier>
            <ext><doctype>international-standard</doctype><subdoctype>vocabulary</subdoctype></ext>
          </bibdata>
        </metanorma>
      XML
      root = Metanorma::IsoDocument::Root.from_xml(xml)
      state = described_class.extract(root)
      expect(state.vocab).to be(true)
      expect(state.amd).to be(false)
    end

    it "detects amendment doctype" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata>
            <docidentifier>ISO 1</docidentifier>
            <ext><doctype>amendment</doctype></ext>
          </bibdata>
        </metanorma>
      XML
      root = Metanorma::IsoDocument::Root.from_xml(xml)
      state = described_class.extract(root)
      expect(state.amd).to be(true)
    end

    it "passes document identifier through" do
      state = described_class.extract(nil, document: "path/to/file.xml")
      expect(state.document).to eq("path/to/file.xml")
    end
  end
end

RSpec.describe "auto-detection via API" do
  it "auto-detects doctype when not passed explicitly" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
          <ext><doctype>pizza</doctype></ext>
        </bibdata>
      </metanorma>
    XML
    report = Metanorma::Iso::API.validate(xml)
    expect(report.issues.map(&:code)).to include("ISO_5")
  end

  it "allows overriding doctype" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
        </bibdata>
      </metanorma>
    XML
    report = Metanorma::Iso::API.validate(xml, doctype: "pizza")
    expect(report.issues.map(&:code)).to include("ISO_5")
  end
end
