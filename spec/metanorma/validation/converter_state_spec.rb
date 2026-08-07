require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::ConverterState do
  it "is a Struct with the expected fields" do
    expect(described_class.members).to contain_exactly(
      :lang, :script, :doctype, :vocab, :amd, :i18n, :novalid, :document
    )
  end

  it "builds from keyword arguments" do
    state = described_class.new(lang: "en", script: "Latn", doctype: "international-standard")
    expect(state.lang).to eq("en")
    expect(state.script).to eq("Latn")
    expect(state.doctype).to eq("international-standard")
    expect(state.vocab).to be_nil
  end
end
