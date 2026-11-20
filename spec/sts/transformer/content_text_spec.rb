# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::ContentText do
  subject(:host) { Class.new { include Metanorma::Iso::Sts::Transformer::ContentText }.new }

  let(:content_node) { Struct.new(:content) }
  let(:text_node) { Struct.new(:text) }
  let(:both_node) { Struct.new(:content, :text) }

  describe "#extract_text" do
    it "returns an empty string for nil" do
      expect(host.extract_text(nil)).to eq("")
    end

    it "returns a String unchanged" do
      expect(host.extract_text("plain")).to eq("plain")
    end

    it "joins array content" do
      expect(host.extract_text(content_node.new(%w[a b c]))).to eq("abc")
    end

    it "stringifies scalar content" do
      expect(host.extract_text(content_node.new(42))).to eq("42")
    end

    it "falls back to #text when #content is nil" do
      expect(host.extract_text(both_node.new(nil, ["x", "y"]))).to eq("xy")
    end

    it "prefers #content over #text" do
      expect(host.extract_text(both_node.new("c", "t"))).to eq("c")
    end

    it "returns an empty string when neither attribute holds a value" do
      expect(host.extract_text(both_node.new(nil, nil))).to eq("")
      expect(host.extract_text(Object.new)).to eq("")
    end
  end

  describe "#extract_text_value" do
    it "returns nil for nil and passes a String through" do
      expect(host.extract_text_value(nil)).to be_nil
      expect(host.extract_text_value("s")).to eq("s")
    end

    it "prefers content, then text, then value" do
      expect(host.extract_text_value(Struct.new(:content, :text, :value).new("c", "t", "v"))).to eq("c")
      expect(host.extract_text_value(Struct.new(:content, :text, :value).new(nil, "t", "v"))).to eq("t")
      expect(host.extract_text_value(Struct.new(:content, :text, :value).new(nil, nil, "v"))).to eq("v")
    end

    it "joins array attributes, dropping nils" do
      expect(host.extract_text_value(content_node.new(["a", nil, "b"]))).to eq("ab")
    end

    it "stringifies primitives" do
      expect(host.extract_text_value(7)).to eq("7")
      expect(host.extract_text_value(:sym)).to eq("sym")
      expect(host.extract_text_value(true)).to eq("true")
    end

    it "returns nil for an object with no text-bearing attribute (never its inspect)" do
      expect(host.extract_text_value(Object.new)).to be_nil
    end
  end

  describe "#primitive_string" do
    it "stringifies Integer, Float, Symbol and booleans only" do
      expect(host.primitive_string(1)).to eq("1")
      expect(host.primitive_string(1.5)).to eq("1.5")
      expect(host.primitive_string(false)).to eq("false")
      expect(host.primitive_string([1])).to be_nil
      expect(host.primitive_string(Object.new)).to be_nil
    end
  end
end
