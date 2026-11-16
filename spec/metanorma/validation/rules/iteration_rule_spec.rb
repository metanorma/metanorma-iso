require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::IterationRule do
  let(:state) do
    Metanorma::Iso::Validation::ConverterState.new(
      lang: "en", script: "Latn", document: "spec"
    )
  end
  let(:rule) { described_class.new }

  describe "#check" do
    context "with missing iteration (nil status)" do
      let(:context) do
        root = Metanorma::IsoDocument::Root.from_xml(<<~XML)
          <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
            <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          </metanorma>
        XML
        Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                                state: state, shared: nil)
      end

      it "emits no issues" do
        expect(rule.check(context)).to eq([])
      end
    end

    context "with a numeric iteration" do
      let(:context) do
        root = Metanorma::IsoDocument::Root.from_xml(<<~XML)
          <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
            <bibdata>
              <docidentifier>ISO 1</docidentifier>
              <status><iteration>3</iteration></status>
            </bibdata>
          </metanorma>
        XML
        Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                                state: state, shared: nil)
      end

      it "emits no issues" do
        expect(rule.check(context)).to eq([])
      end
    end
  end

  describe "code" do
    it "declares ISO_6" do
      expect(described_class.new.code).to eq("ISO_6")
    end
  end
end
