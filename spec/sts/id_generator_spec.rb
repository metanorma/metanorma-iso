# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::IdGenerator do
  let(:context) { make_context }
  let(:generator) { described_class.new(context) }

  it "generates IDs for foreword sections" do
    foreword = Metanorma::IsoDocument::Sections::IsoForewordSection.new
    expect(generator.id_for(foreword)).to eq("sec_foreword")
  end

  it "generates IDs for abstract sections" do
    abstract = Metanorma::IsoDocument::Sections::IsoAbstractSection.new
    expect(generator.id_for(abstract)).to eq("sec_abstract")
  end

  it "generates IDs for clause sections by number" do
    clause = Metanorma::IsoDocument::Sections::IsoClauseSection.new
    clause.id = "_clause_1"
    clause.number = "3"
    expect(generator.id_for(clause)).to eq("sec_3")
  end

  it "generates IDs for intro clauses" do
    clause = Metanorma::IsoDocument::Sections::IsoClauseSection.new
    clause.id = "_intro"
    clause.type = "intro"
    expect(generator.id_for(clause)).to eq("sec_intro")
  end

  it "remaps registered IDs" do
    generator.register("old_id", "new_id")
    expect(generator.remap("old_id")).to eq("new_id")
  end

  it "returns original ID when no mapping exists" do
    expect(generator.remap("unknown")).to eq("unknown")
  end
end
