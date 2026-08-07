require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::DoctypeRule do
  let(:doctype) { "international-standard" }
  let(:amd) { false }
  let(:state) do
    Metanorma::Iso::Validation::ConverterState.new(
      lang: "en", script: "Latn", doctype: doctype, amd: amd
    )
  end
  let(:context) do
    Metanorma::Iso::Validation::Context.new(
      root: nil, log: nil, state: state, shared: nil
    )
  end
  let(:rule) { described_class.new }

  describe "#applicable?" do
    context "with a normal doctype" do
      it { expect(rule).to be_applicable(context) }
    end

    context "with amendment doctype (skipped per existing behavior)" do
      let(:amd) { true }
      it { expect(rule).not_to be_applicable(context) }
    end
  end

  describe "#check" do
    context "with a valid doctype" do
      let(:doctype) { "international-standard" }
      it "emits no issues" do
        expect(rule.check(context)).to eq([])
      end
    end

    context "with an invalid doctype" do
      let(:doctype) { "pizza" }
      it "emits one ISO_5 issue" do
        issues = rule.check(context)
        expect(issues.size).to eq(1)
        expect(issues.first.code).to eq("ISO_5")
        expect(issues.first.message).to include("pizza is not a recognised document type")
      end
    end

    context "with every allowed doctype" do
      Metanorma::Iso::Validation::Rules::DoctypeRule::ALLOWED_DOCTYPES.each do |dt|
        it "accepts #{dt}" do
          state[:doctype] = dt
          expect(rule.check(context)).to eq([])
        end
      end
    end
  end

  describe "code" do
    it "declares ISO_5" do
      expect(described_class.new.code).to eq("ISO_5")
    end
  end
end
