# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::FootnoteCollector, :aggregate_failures do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:collector) { described_class.new }

  it "numbers new footnotes in registration order" do
    expect(collector.register("a")).to eq("fn_1")
    expect(collector.register("b")).to eq("fn_2")
    expect(collector.size).to eq(2)
  end

  it "returns the same id for a source id registered twice" do
    first = collector.register("a")
    collector.register("b")
    expect(collector.register("a")).to eq(first)
    expect(collector.size).to eq(2)
  end

  it "does not spend a number on a repeated source id" do
    collector.register("a")
    collector.register("a")
    expect(collector.register("b")).to eq("fn_2")
  end

  it "reports which source ids are known" do
    collector.register("a")
    expect(collector.known?("a")).to be(true)
    expect(collector.known?("z")).to be(false)
  end

  it "starts empty" do
    expect(collector.size).to eq(0)
  end
end
