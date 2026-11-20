# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::Context do
  let(:t) { Metanorma::Iso::Sts::Transformer }

  def source_with(language: "<language>fr</language>", id: "ISO 1234")
    t::SourceDocument.parse(<<~XML)
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard"><title language="en" type="main">T</title>
          <docidentifier>#{id}</docidentifier>#{language}</bibdata>
        <sections/>
        <annex id="_ann" obligation="normative"><title>A</title><p id="ap">x</p></annex>
      </metanorma>
    XML
  end

  it "exposes the source it wraps" do
    source = source_with
    expect(described_class.new(source).source).to equal(source)
  end

  describe "#language" do
    it "is the source language when present" do
      expect(described_class.new(source_with).language).to eq("fr")
    end

    it "defaults to en when the source has none" do
      expect(described_class.new(source_with(language: "")).language).to eq("en")
    end
  end

  it "#docidentifier delegates to the source" do
    expect(described_class.new(source_with(id: "ISO 4321")).docidentifier).to eq("ISO 4321")
  end

  describe "collaborators" do
    subject(:ctx) { described_class.new(source_with) }

    it "builds a fresh id generator that already claimed the annex id" do
      expect(ctx.id_generator).to be_a(t::IdGenerator)
      annex = ctx.source.annexes.first
      expect(ctx.id_generator.id_for_annex(annex, nil)).to eq("sec_A")
    end

    it "builds an empty footnote collector" do
      expect(ctx.footnote_collector).to be_a(t::FootnoteCollector)
      expect(ctx.footnote_collector.register("a")).to eq("fn_1")
    end
  end

  describe "provision lookup" do
    let(:requirement) { Struct.new(:anchor).new("req-1") }

    it "has no provision index without presentation XML" do
      expect(described_class.new(source_with).provision_index).to be_nil
      expect(described_class.new(source_with, presentation_xml: "").provision_index).to be_nil
    end

    it "returns nil from provision_for without presentation XML" do
      expect(described_class.new(source_with).provision_for(requirement)).to be_nil
    end

    it "returns nil for a requirement without an anchor, even with presentation XML" do
      ctx = described_class.new(source_with, presentation_xml: "<metanorma/>")
      expect(ctx.provision_for(Struct.new(:anchor).new(nil))).to be_nil
      expect(ctx.provision_for(Struct.new(:anchor).new(""))).to be_nil
    end

    it "keeps the presentation XML it was given and indexes it lazily, once" do
      ctx = described_class.new(source_with, presentation_xml: "<metanorma/>")
      expect(ctx.presentation_xml).to eq("<metanorma/>")
      idx = ctx.provision_index
      expect(idx).to be_a(t::ProvisionIndex)
      expect(ctx.provision_index).to equal(idx)
    end
  end
end
