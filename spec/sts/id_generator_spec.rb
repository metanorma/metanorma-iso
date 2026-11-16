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

  it "letters unnumbered annexes in document order" do
    first = Metanorma::IsoDocument::Sections::IsoAnnexSection.new
    first.id = "_ann1"
    second = Metanorma::IsoDocument::Sections::IsoAnnexSection.new
    second.id = "_ann2"

    expect(generator.id_for(first)).to eq("sec_A")
    expect(generator.id_for(second)).to eq("sec_B")
  end

  it "keeps past Z lettering unnumbered annexes NCName-safe" do
    26.times do |i|
      annex = Metanorma::IsoDocument::Sections::IsoAnnexSection.new
      annex.id = "_ann#{i}"
      generator.id_for(annex)
    end
    annex = Metanorma::IsoDocument::Sections::IsoAnnexSection.new
    annex.id = "_ann27"

    expect(generator.id_for(annex)).to eq("sec_AA")
  end

  it "uniquifies colliding fallback IDs with numeric suffixes" do
    first = Metanorma::IsoDocument::Sections::IsoTermsSection.new
    first.id = "_terms1"
    second = Metanorma::IsoDocument::Sections::IsoTermsSection.new
    second.id = "_terms2"

    expect(generator.id_for(first)).to eq("sec_terms")
    expect(generator.id_for(second)).to eq("sec_terms_1")
  end

  it "claims a document-unique variant of a taken base id" do
    expect(generator.claim("sec_x")).to eq("sec_x")
    expect(generator.claim("sec_x")).to eq("sec_x_1")
    expect(generator.claim("sec_x")).to eq("sec_x_2")
  end

  it "returns nil when claiming a nil base id" do
    expect(generator.claim(nil)).to be_nil
  end
end
