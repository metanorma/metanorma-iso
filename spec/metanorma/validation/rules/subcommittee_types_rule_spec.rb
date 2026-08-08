require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::TechnicalCommitteeTypeRule do
  let(:state) do
    Metanorma::Iso::Validation::ConverterState.new(document: "spec")
  end
  let(:rule) { described_class.new }

  def build_context(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  def xml_with_subtype(subtype)
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
          <contributor>
            <role><description>committee</description></role>
            <organization>
              <subdivision type="Technical committee" subtype="#{subtype}"/>
            </organization>
          </contributor>
        </bibdata>
      </metanorma>
    XML
  end

  describe "#check" do
    %w[TC PC JTC JPC].each do |valid|
      it "accepts #{valid}" do
        expect(rule.check(build_context(xml_with_subtype(valid)))).to eq([])
      end
    end

    it "flags ISO_2 for an invalid subtype" do
      issues = rule.check(build_context(xml_with_subtype("ZZZ")))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_2")
      expect(issues.first.message).to include("invalid technical committee type ZZZ")
    end

    it "ignores Subcommittee subdivisions" do
      xml = xml_with_subtype("ZZZ").sub('type="Technical committee"',
                                        'type="Subcommittee"')
      expect(rule.check(build_context(xml))).to eq([])
    end
  end

  describe "code" do
    it "declares ISO_2" do
      expect(described_class.new.code).to eq("ISO_2")
    end
  end
end

RSpec.describe Metanorma::Iso::Validation::Rules::SubcommitteeTypeRule do
  let(:state) do
    Metanorma::Iso::Validation::ConverterState.new(document: "spec")
  end
  let(:rule) { described_class.new }

  def build_context(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  def xml_with_subtype(subtype)
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
          <contributor>
            <role><description>committee</description></role>
            <organization>
              <subdivision type="Subcommittee" subtype="#{subtype}"/>
            </organization>
          </contributor>
        </bibdata>
      </metanorma>
    XML
  end

  describe "#check" do
    %w[SC JSC].each do |valid|
      it "accepts #{valid}" do
        expect(rule.check(build_context(xml_with_subtype(valid)))).to eq([])
      end
    end

    it "flags ISO_3 for an invalid subtype" do
      issues = rule.check(build_context(xml_with_subtype("ZZZ")))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_3")
      expect(issues.first.message).to include("invalid subcommittee type ZZZ")
    end

    it "ignores Technical committee subdivisions" do
      xml = xml_with_subtype("ZZZ").sub('type="Subcommittee"',
                                        'type="Technical committee"')
      expect(rule.check(build_context(xml))).to eq([])
    end
  end

  describe "code" do
    it "declares ISO_3" do
      expect(described_class.new.code).to eq("ISO_3")
    end
  end
end
