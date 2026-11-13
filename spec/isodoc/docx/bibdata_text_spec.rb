# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::BibDataText do
  let(:model) { parse_iso_document(minimal_iso_xml(body)) }

  describe "#header" do
    context "with primary identifier, copyright year, and language" do
      let(:body) do
        <<~XML
          <bibdata>
            <docidentifier primary="true">ISO/DIS 15926-100</docidentifier>
            <language>en</language>
            <copyright>
              <from>2026</from>
              <owner><organization><name>ISO</name></organization></owner>
            </copyright>
          </bibdata>
        XML
      end

      it "returns identifier with year and language tag" do
        expect(described_class.new(model).header).to eq("ISO/DIS 15926-100:2026(en)")
      end
    end

    context "with multiple identifiers picks the one marked primary" do
      let(:body) do
        <<~XML
          <bibdata>
            <docidentifier>ISO ABC</docidentifier>
            <docidentifier primary="true">ISO/PRIM-1</docidentifier>
            <language>en</language>
          </bibdata>
        XML
      end

      it "uses the primary identifier" do
        expect(described_class.new(model).header).to start_with("ISO/PRIM-1")
      end
    end

    context "without copyright falls back to identifier without year" do
      let(:body) do
        <<~XML
          <bibdata>
            <docidentifier primary="true">ISO 1234</docidentifier>
            <language>en</language>
          </bibdata>
        XML
      end

      it "returns identifier with language tag but no year" do
        expect(described_class.new(model).header).to eq("ISO 1234(en)")
      end
    end

    context "without bibdata returns empty string" do
      let(:body) { "" }

      it "returns empty string" do
        expect(described_class.new(model).header).to eq("")
      end
    end
  end

  describe "#copyright" do
    context "with copyright holder and year" do
      let(:body) do
        <<~XML
          <bibdata>
            <copyright>
              <from>2025</from>
              <owner><organization><name>ISO</name></organization></owner>
            </copyright>
          </bibdata>
        XML
      end

      it "returns full copyright string" do
        expect(described_class.new(model).copyright)
          .to eq("© ISO 2025 – All rights reserved")
      end
    end

    context "with different holder" do
      let(:body) do
        <<~XML
          <bibdata>
            <copyright>
              <from>2024</from>
              <owner><organization><name>IEC</name></organization></owner>
            </copyright>
          </bibdata>
        XML
      end

      it "uses the provided holder" do
        expect(described_class.new(model).copyright)
          .to eq("© IEC 2024 – All rights reserved")
      end
    end

    context "without copyright falls back to default ISO 2026" do
      let(:body) do
        <<~XML
          <bibdata>
            <docidentifier primary="true">ISO 1234</docidentifier>
          </bibdata>
        XML
      end

      it "uses the default copyright" do
        expect(described_class.new(model).copyright)
          .to eq("© ISO 2026 – All rights reserved")
      end
    end

    context "without bibdata falls back to default" do
      let(:body) { "" }

      it "uses the default copyright" do
        expect(described_class.new(model).copyright)
          .to eq("© ISO 2026 – All rights reserved")
      end
    end
  end
end
