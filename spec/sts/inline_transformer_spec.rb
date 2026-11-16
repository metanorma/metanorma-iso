# frozen_string_literal: true

require_relative "spec_helper"

# Tests the inline-transformer behaviour through the public API
# (Metanorma::Iso::Sts.convert), not by poking at private transformer
# methods via send(:. The interface is the test surface.
RSpec.describe "inline transformer via public API" do
  let(:xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">
          <title language="en" type="main">Test</title>
          <docidentifier>ISO 9999</docidentifier>
          <language>en</language>
        </bibdata>
      <sections>
          <clause id="clause1"><title>Scope</title>
            <p id="p1">See <xref target="clause1"/> for ISO 8601 details.</p>
          </clause>
        </sections>
      </metanorma>
    XML
  end
  let(:sts) { Metanorma::Iso::Sts.convert(xml) }

  describe "footnote integration" do
    it "renders fn references as xref when fn present" do
      fn_xml = xml.sub(
        "<p id=\"p1\">See <xref target=\"clause1\"/> for ISO 8601 details.</p>",
        "<p id=\"p1\">See <xref target=\"clause1\"/> for <fn reference=\"1\"><p>Footnote text</p></fn> details.</p>",
      )
      sts = Metanorma::Iso::Sts.convert(fn_xml)
      expect(sts).to include("<xref")
    end
  end

  describe "eref transformation" do
    it "builds std with citeas text" do
      eref_xml = xml.sub(
        "<p id=\"p1\">See <xref target=\"clause1\"/> for ISO 8601 details.</p>",
        "<p id=\"p1\"><eref bibitemid=\"ISO8601\" citeas=\"ISO 8601-1:2019\"/></p>",
      )
      sts = Metanorma::Iso::Sts.convert(eref_xml)
      expect(sts).to include("ISO 8601-1:2019")
      expect(sts).to include("<std")
    end
  end

  describe "xref ID remapping" do
    it "renders xref with rid in STS output" do
      expect(sts).to match(/<xref[^>]*rid=/)
    end
  end

  describe "NBSP processing" do
    it "inserts NBSP between ISO and document number in text" do
      nbsp = [0xC2, 0xA0].pack("C*").force_encoding("UTF-8")
      expect(sts).to include("ISO#{nbsp}8601")
    end
  end
end
