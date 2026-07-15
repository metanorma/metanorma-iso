# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::Registry do
  # Minimal renderer that records its calls for assertions.
  FakeRenderer = Struct.new(:calls) do
    def initialize
      @calls = []
    end

    attr_reader :calls

    def render(node, doc)
      @calls << [node, doc]
    end
  end

  let(:registry) { described_class.new }

  describe "#register and #lookup" do
    it "returns the registered renderer for an exact class match" do
      klass = Class.new
      renderer = FakeRenderer.new
      registry.register(klass, renderer)

      expect(registry.lookup(klass)).to be(renderer)
    end

    it "walks ancestors when no exact match exists" do
      base = Class.new
      subclass = Class.new(base)
      base_renderer = FakeRenderer.new
      registry.register(base, base_renderer)

      expect(registry.lookup(subclass)).to be(base_renderer)
    end

    it "returns nil when no ancestor is registered" do
      klass = Class.new
      expect(registry.lookup(klass)).to be_nil
    end

    it "prefers exact match over ancestor match" do
      base = Class.new
      subclass = Class.new(base)
      base_r = FakeRenderer.new
      sub_r = FakeRenderer.new
      registry.register(base, base_r)
      registry.register(subclass, sub_r)

      expect(registry.lookup(subclass)).to be(sub_r)
    end
  end

  describe "#dispatch" do
    it "calls #render on the matching renderer with the node and doc" do
      klass = Class.new
      renderer = FakeRenderer.new
      registry.register(klass, renderer)

      node = klass.new
      doc = Object.new
      registry.dispatch(node, doc)

      expect(renderer.calls).to eq([[node, doc]])
    end

    it "returns nil without raising when no renderer is registered" do
      klass = Class.new
      expect(registry.dispatch(klass.new, Object.new)).to be_nil
    end
  end

  describe "#registered?" do
    it "returns true for registered classes" do
      klass = Class.new
      registry.register(klass, FakeRenderer.new)
      expect(registry).to be_registered(klass)
    end

    it "returns false for unregistered classes" do
      expect(registry).not_to be_registered(Class.new)
    end
  end
end
