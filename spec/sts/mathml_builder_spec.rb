# frozen_string_literal: true

require_relative "spec_helper"
require "mml"

RSpec.describe Metanorma::Iso::Sts::MathmlBuilder do
  describe ".wrap_math_content" do
    it "wraps inner MathML in a <math> element with namespace" do
      result = described_class.wrap_math_content("<mi>x</mi>")
      expect(result).to eq("<math xmlns='http://www.w3.org/1998/Math/MathML'><mi>x</mi></math>")
    end
  end

  describe ".math_klass_for" do
    it "returns Mml::V3::Math for NisoSts::InlineFormula targets" do
      result = described_class.math_klass_for(Sts::NisoSts::InlineFormula)
      expect(result).to eq(Mml::V3::Math)
    end

    it "returns Mml::V3::Math for non-NisoSts targets" do
      result = described_class.math_klass_for(Mml::V3::Math)
      expect(result).to eq(Mml::V3::Math)
    end
  end

  describe ".inline_formula_from_stem" do
    it "returns nil for nodes without math" do
      struct = Struct.new(:math).new(nil)
      result = described_class.inline_formula_from_stem(struct)
      expect(result).to be_nil
    end

    it "builds a NisoSts::InlineFormula when klass is specified" do
      struct = Struct.new(:math) do
        def class
          Struct.new(:name).new("FmtStemElement")
        end
      end.new(nil)
      result = described_class.inline_formula_from_stem(struct, klass: Sts::NisoSts::InlineFormula)
      expect(result).to be_nil
    end
  end
end
