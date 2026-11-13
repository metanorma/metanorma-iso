require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::SubpartIecRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(docid_xml, publisher_xml: "")
    publisher_inner = publisher_xml
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          #{docid_xml}
          #{publisher_inner}
        </bibdata>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  def iso_docid(value)
    %(<docidentifier type="ISO">#{value}</docidentifier>)
  end

  def iec_publisher
    %(<contributor>
      <role type="publisher"/>
      <organization><abbreviation>IEC</abbreviation></organization>
    </contributor>)
  end

  describe "#check" do
    it "passes when there is no ISO docid" do
      xml = %(<docidentifier type="canonical">ISO 1234</docidentifier>)
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "passes when ISO docid has no subpart pattern" do
      expect(rule.check(context_with(iso_docid("ISO 1234")))).to eq([])
    end

    it "flags ISO_16 when ISO docid has subpart and no IEC publisher" do
      issues = rule.check(context_with(iso_docid("ISO 1234-1-1")))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_16")
    end

    it "passes when ISO docid has subpart and IEC is a publisher" do
      xml = context_with(iso_docid("ISO/IEC 1234-1-1"), publisher_xml: iec_publisher)
      expect(rule.check(xml)).to eq([])
    end
  end

  describe "code" do
    it "declares ISO_16" do
      expect(described_class.new.code).to eq("ISO_16")
    end
  end
end
