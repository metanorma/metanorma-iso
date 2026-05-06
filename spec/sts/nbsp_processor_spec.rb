# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::NbspProcessor do
  it "inserts NBSP between Part and digit" do
    result = described_class.process("Part 1")
    expect(result).to eq("Part 1")
  end

  it "inserts NBSP between ISO and digit" do
    result = described_class.process("ISO 8601")
    expect(result).to eq("ISO 8601")
  end

  it "inserts NBSP between digit and percent" do
    result = described_class.process("100 %")
    expect(result).to eq("100 %")
  end

  it "inserts NBSP between Annex and letter" do
    result = described_class.process("Annex A")
    expect(result).to eq("Annex A")
  end

  it "inserts NBSP between Table and number" do
    result = described_class.process("Table 1")
    expect(result).to eq("Table 1")
  end

  it "inserts NBSP between Formula and paren" do
    result = described_class.process("Formula (1)")
    expect(result).to eq("Formula (1)")
  end

  it "returns non-String input unchanged" do
    expect(described_class.process(nil)).to be_nil
    expect(described_class.process(42)).to eq(42)
  end

  it "handles multiple patterns in one string" do
    result = described_class.process("ISO 8601 Part 1")
    expect(result).to include("ISO 8601")
    expect(result).to include("Part 1")
  end
end
