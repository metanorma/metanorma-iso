# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::FootnoteCollector do
  let(:collector) { described_class.new }

  it "registers first footnote with id fn_1" do
    entry = collector.register("Some footnote text")
    expect(entry[:id]).to eq("fn_1")
    expect(entry[:number]).to eq(1)
  end

  it "deduplicates identical footnotes" do
    entry1 = collector.register("Same text")
    entry2 = collector.register("Same text")
    expect(entry1[:id]).to eq(entry2[:id])
    expect(collector.count).to eq(1)
  end

  it "numbers footnotes sequentially" do
    collector.register("First")
    collector.register("Second")
    entry3 = collector.register("Third")
    expect(entry3[:number]).to eq(3)
  end

  it "normalizes whitespace for deduplication" do
    entry1 = collector.register("  padded text  ")
    entry2 = collector.register("padded text")
    expect(entry1[:id]).to eq(entry2[:id])
  end

  it "produces fn_group with all unique footnotes" do
    collector.register("Footnote A")
    collector.register("Footnote B")

    group = collector.fn_group
    expect(group).to be_a(Sts::IsoSts::FnGroup)
    xml = group.to_xml
    expect(xml).to include("fn_1")
    expect(xml).to include("fn_2")
    expect(xml).to include("Footnote A")
    expect(xml).to include("Footnote B")
  end

  it "returns nil fn_group when empty" do
    expect(collector.fn_group).to be_nil
  end

  it "looks up existing footnotes" do
    entry = collector.register("Find me")
    found = collector.lookup("Find me")
    expect(found[:id]).to eq(entry[:id])
  end

  it "returns nil for unknown lookup" do
    expect(collector.lookup("never registered")).to be_nil
  end

  it "stores and reproduces rich paragraph content" do
    fn_para = Sts::IsoSts::Paragraph.new
    fn_para.content = ["Rich footnote text"]
    collector.register("rich text", paragraphs: [fn_para])

    group = collector.fn_group
    xml = group.to_xml
    expect(xml).to include("Rich footnote text")
  end
end
