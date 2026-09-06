require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::RuleRegistry do
  before do
    # Define a fake rule class in the Rules namespace, then clean it up.
    stub_const("Metanorma::Iso::Validation::Rules::SpecExampleRule",
               Class.new(Metanorma::Iso::Validation::Rules::Base) do
                 code "ISO_TEST"
               end)
  end

  it "discovers rule classes that inherit from Base" do
    registry = described_class.new
    classes = registry.all
    expect(classes).to include(Metanorma::Iso::Validation::Rules::SpecExampleRule)
  end

  it "ignores non-Class constants in the Rules namespace" do
    stub_const("Metanorma::Iso::Validation::Rules::NOT_A_CLASS", 42)
    registry = described_class.new
    expect(registry.all).not_to include(42)
  end

  it "excludes abstract rule classes from discovery" do
    registry = described_class.new
    expect(registry.all).not_to include(Metanorma::Iso::Validation::Rules::StyleRule)
  end

  it "includes concrete subclasses of abstract bases" do
    registry = described_class.new
    expect(registry.all).to include(Metanorma::Iso::Validation::Rules::StyleNumberRule)
  end
end
