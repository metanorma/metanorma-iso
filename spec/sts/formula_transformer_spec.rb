# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::FormulaTransformer do
  let(:context) { make_context }
  let(:transformer) { described_class.new(context) }

  it "transforms a formula with a label" do
    source = Metanorma::Document::Components::AncillaryBlocks::FormulaBlock.new
    source.id = "_formula_1"
    source.displayorder = 1

    result = transformer.transform(source)
    expect(result).to be_a(Sts::IsoSts::DispFormula)
  end
end
