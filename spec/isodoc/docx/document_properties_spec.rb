# frozen_string_literal: true

require_relative "spec_helper"
require "uniword/ooxml/custom_properties"

RSpec.describe IsoDoc::Iso::Docx::DocumentProperties do
  def build_model(doctype:, stage: nil)
    status_xml = stage ? "<status><stage>#{stage}</stage></status>" : ""
    xml = <<~XML
      <iso-standard xmlns="https://www.metanorma.org/ns/iso">
        <bibdata type="standard">
          <docidentifier>ISO 1234</docidentifier>
          <docnumber>1234</docnumber>
          #{status_xml}
          <ext>
            <doctype>#{doctype}</doctype>
          </ext>
        </bibdata>
        <sections></sections>
      </iso-standard>
    XML
    Metanorma::IsoDocument::Root.from_xml(xml)
  end

  def find_property(props, name)
    props.properties.find { |p| p.name == name }
  end

  it "abbreviates known doctypes from YAML" do
    [
      ["international-standard", "IS"],
      ["technical-specification", "TS"],
      ["technical-report", "TR"],
      ["publicly-available-specification", "PAS"],
      ["international-workshop-agreement", "IWA"],
      ["guide", "Guide"],
      ["amendment", "AMD"],
      ["technical-corrigendum", "COR"],
    ].each do |doctype, expected|
      model = build_model(doctype: doctype)
      props = described_class.new(model).build
      expect(find_property(props, "ident-doc-type").value).to eq(expected)
    end
  end

  it "falls back to upcased doctype when not in YAML" do
    model = build_model(doctype: "exotic-flavor")
    props = described_class.new(model).build
    expect(find_property(props, "ident-doc-type").value).to eq("EXOTIC-FLAVOR")
  end

  it "omits ident-doc-type when no doctype present" do
    xml = <<~XML
      <iso-standard xmlns="https://www.metanorma.org/ns/iso">
        <bibdata type="standard">
          <docnumber>1234</docnumber>
        </bibdata>
        <sections></sections>
      </iso-standard>
    XML
    model = Metanorma::IsoDocument::Root.from_xml(xml)
    props = described_class.new(model).build
    expect(find_property(props, "ident-doc-type")).to be_nil
  end

  it "abbreviates stages from YAML" do
    # The original code buckets stage via `stage / 10 * 10`. Only the
    # decile-bucketed entries are reachable; the 95 => "COR" entry in the
    # YAML is preserved for documentation but unreachable through the
    # bucket math (stage 95 buckets to 90 => "AMD").
    [
      [0, "PWI"],
      [10, "NP"],
      [20, "WD"],
      [30, "CD"],
      [40, "DIS"],
      [50, "FDIS"],
      [60, "IS"],
      [90, "AMD"],
      [95, "AMD"],
      [99, "AMD"],
    ].each do |stage, expected|
      model = build_model(doctype: "international-standard", stage: stage)
      props = described_class.new(model).build
      expect(find_property(props, "release-version").value).to eq(expected)
    end
  end

  it "falls back to IS when stage buckets to an unmapped decile" do
    # Stage 75 buckets to 70, which is not in the YAML, so we fall
    # back to the default "IS" abbreviation.
    model = build_model(doctype: "international-standard", stage: 75)
    props = described_class.new(model).build
    expect(find_property(props, "release-version").value).to eq("IS")
  end

  it "omits release-version when no stage present" do
    model = build_model(doctype: "international-standard")
    props = described_class.new(model).build
    expect(find_property(props, "release-version")).to be_nil
  end

  it "loads YAML data from DIS template by default" do
    model = build_model(doctype: "international-standard")
    props = described_class.new(model).build
    expect(find_property(props, "ident-doc-type").value).to eq("IS")
  end
end
