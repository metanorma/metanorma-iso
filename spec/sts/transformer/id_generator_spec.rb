# frozen_string_literal: true

require_relative "unit_b_support"

RSpec.describe Metanorma::Iso::Sts::Transformer::IdGenerator, :aggregate_failures do # rubocop:disable RSpec/SpecFilePathFormat
  include TransformerUnitSupport

  subject(:generator) { described_class.new }

  def source_for(sections: "", back: "")
    Metanorma::Iso::Sts::Transformer::SourceDocument.parse(
      source_xml(sections: sections, back: back),
    )
  end

  describe "#claim" do
    it "returns the base for a first claim and suffixes each repeat" do
      expect(generator.claim("sec_1")).to eq("sec_1")
      expect(generator.claim("sec_1")).to eq("sec_1_1")
      expect(generator.claim("sec_1")).to eq("sec_1_2")
    end

    it "is nil for a nil base" do
      expect(generator.claim(nil)).to be_nil
    end
  end

  describe "#register, #remap and #kind_for" do
    it "remaps a registered id and records its kind" do
      generator.register("src", "sec_src", "annex")
      expect(generator.remap("src")).to eq("sec_src")
      expect(generator.kind_for("src")).to eq("annex")
    end

    it "falls back to the source id for an unregistered target" do
      expect(generator.remap("unknown")).to eq("unknown")
      expect(generator.kind_for("unknown")).to be_nil
    end
  end

  describe "#id_for_annex" do
    it "uses the autonum letter when there is one" do
      expect(generator.id_for_annex(Object.new, "C")).to eq("sec_C")
    end

    it "assigns letters in order when unnumbered, rolling over after Z" do
      ids = Array.new(28) { generator.id_for_annex(Object.new, nil) }
      expect(ids.first(2)).to eq(%w[sec_A sec_B])
      expect(ids[25..]).to eq(%w[sec_Z sec_AA sec_AB])
    end
  end

  describe "#pre_register" do
    let(:source) do
      source_for(sections: <<~XML)
        <clause id="c1"><title>One</title><clause id="c2"><title>Nested</title></clause></clause>
        <terms id="t1"><title>Terms</title></terms>
      XML
    end

    it "claims clause ids as they are and an unnumbered terms section as sec_terms" do
      generator.pre_register(source)
      expect(generator.id_map).to eq("c1" => "c1", "c2" => "c2", "t1" => "sec_terms")
    end

    it "lets a forward cross-reference resolve to a later renamed element" do
      generator.pre_register(source)
      expect(generator.remap("t1")).to eq("sec_terms")
      expect(generator.kind_for("c2")).to eq("clause")
    end

    it "is idempotent for a source id already registered" do
      generator.pre_register(source)
      expect(generator.id_for_clause(source.sections.first)).to eq("c1")
      expect(generator.id_map["c1"]).to eq("c1")
    end
  end

  describe "#id_for_terms" do
    it "uniquifies a second unnumbered terms section" do
      one = source_for(sections: '<terms id="a"><title>A</title></terms>').sections.first
      two = source_for(sections: '<terms id="b"><title>B</title></terms>').sections.first
      expect([generator.id_for_terms(one, nil), generator.id_for_terms(two, nil)])
        .to eq(%w[sec_terms sec_terms_1])
    end
  end

  describe "#figure_id" do
    it "numbers figures fig_1, fig_2 in call order and is stable per figure" do
      fig_a = Object.new
      fig_b = Object.new
      expect(generator.figure_id(fig_a)).to eq("fig_1")
      expect(generator.figure_id(fig_b)).to eq("fig_2")
      expect(generator.figure_id(fig_a)).to eq("fig_1")
    end
  end

  describe "#id_for" do
    it "returns nil for nil and a counter id for an object without a source id" do
      expect(generator.id_for(nil)).to be_nil
      expect(generator.id_for(Object.new, prefix: "x")).to eq("x_1")
    end
  end
end
