# frozen_string_literal: true

require_relative "spec_helper"
require "uniword/ooxml/custom_properties"

RSpec.describe "IsoDoc::Iso::Docx::DocumentProperties", :aggregate_failures do
  let(:property_class) { IsoDoc::Iso::Docx::DocumentProperties }

  def build_model(doctype:, stage: nil)
    doctype_xml = doctype ? "<ext><doctype>#{doctype}</doctype></ext>" : ""
    status_xml = stage ? "<status><stage>#{stage}</stage></status>" : ""
    xml = <<~XML
      <iso-standard xmlns="https://www.metanorma.org/ns/iso">
        <bibdata type="standard">
          <docidentifier>ISO 1234</docidentifier>
          <docnumber>1234</docnumber>
          #{status_xml}
          #{doctype_xml}
        </bibdata>
        <sections></sections>
      </iso-standard>
    XML
    Metanorma::IsoDocument::Root.from_xml(xml)
  end

  def find_property(props, name)
    props.properties.find { |p| p.name == name }
  end

  def add_doctype(model, language:, value:)
    model.bibdata.ext.doctype_element <<
      Metanorma::Iso::Document::Metadata::DoctypeElement.new(
        language: language, value: value,
      )
  end

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
    it "abbreviates #{doctype} as #{expected} from YAML" do
      model = build_model(doctype: doctype)
      props = property_class.new(model).build
      expect(find_property(props, "ident-doc-type").value).to eq(expected)
    end
  end

  it "falls back to upcased doctype when not in YAML" do
    model = build_model(doctype: "exotic-flavor")
    props = property_class.new(model).build
    expect(find_property(props, "ident-doc-type").value).to eq("EXOTIC-FLAVOR")
  end

  it "omits ident-doc-type when no doctype present" do
    model = build_model(doctype: nil)
    props = property_class.new(model).build
    expect(find_property(props, "ident-doc-type")).to be_nil
  end

  # Stages are bucketed by decile. Stage 95 therefore maps to AMD, even
  # though the YAML preserves the unreachable 95 => COR entry.
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
    it "abbreviates stage #{stage} as #{expected} from YAML" do
      model = build_model(doctype: "international-standard", stage: stage)
      props = property_class.new(model).build
      expect(find_property(props, "release-version").value).to eq(expected)
    end
  end

  it "falls back to IS when stage buckets to an unmapped decile" do
    # Stage 75 buckets to 70, which is not in the YAML, so we fall
    # back to the default "IS" abbreviation.
    model = build_model(doctype: "international-standard", stage: 75)
    props = property_class.new(model).build
    expect(find_property(props, "release-version").value).to eq("IS")
  end

  it "omits release-version when no stage present" do
    model = build_model(doctype: "international-standard")
    props = property_class.new(model).build
    expect(find_property(props, "release-version")).to be_nil
  end

  it "loads YAML data from DIS template by default" do
    model = build_model(doctype: "international-standard")
    props = property_class.new(model).build
    expect(find_property(props, "ident-doc-type").value).to eq("IS")
  end

  it "abbreviates stage and doctype from Simple template YAML" do
    model = build_model(doctype: "technical-specification", stage: 30)
    props = property_class.new(model, template: :simple).build

    expect(find_property(props, "release-version").value).to eq("CD")
    expect(find_property(props, "ident-doc-type").value).to eq("TS")
  end

  it "prefers the English doctype over the first entry" do
    model = build_model(doctype: "technical-report")
    model.bibdata.ext.doctype_element.first.language = "fr"
    add_doctype(model, language: "en", value: "technical-specification")
    props = property_class.new(model).build

    expect(find_property(props, "ident-doc-type").value).to eq("TS")
  end

  [nil, "", "   "].each do |value|
    it "omits ident-doc-type when the doctype value is #{value.inspect}" do
      model = build_model(doctype: "technical-report")
      model.bibdata.ext.doctype_element.first.value = value
      props = property_class.new(model).build

      expect(find_property(props, "ident-doc-type")).to be_nil
    end
  end

  it "uses the first doctype when no English entry is present" do
    model = build_model(doctype: "technical-report")
    model.bibdata.ext.doctype_element.first.language = "fr"
    add_doctype(model, language: "de", value: "technical-specification")
    props = property_class.new(model).build

    expect(find_property(props, "ident-doc-type").value).to eq("TR")
  end
end
