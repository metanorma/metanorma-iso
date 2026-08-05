# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::InlineRenderers::Registry do
  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.new }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { Uniword::Builder::DocumentBuilder.new }
  let(:resolver) { IsoDoc::Iso::Docx::StyleResolver.new(mapping, context) }
  let(:parent) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }
  let(:registry) { described_class.new(parent) }

  describe "#register and #lookup" do
    it "returns the registered handler for an exact class match" do
      klass = Class.new
      handler = make_handler("X")
      registry.register(klass, handler)
      expect(registry.lookup(klass)).to be(handler)
    end

    it "walks ancestors when no exact match exists" do
      base = Class.new
      subclass = Class.new(base)
      handler = make_handler("Base")
      registry.register(base, handler)
      expect(registry.lookup(subclass)).to be(handler)
    end

    it "returns nil when no ancestor is registered" do
      expect(registry.lookup(Class.new)).to be_nil
    end

    it "prefers exact match over ancestor match" do
      base = Class.new
      subclass = Class.new(base)
      base_h = make_handler("Base")
      sub_h = make_handler("Sub")
      registry.register(base, base_h)
      registry.register(subclass, sub_h)
      expect(registry.lookup(subclass)).to be(sub_h)
    end
  end

  describe "#dispatch" do
    it "calls #render on the matching handler with the element and para" do
      calls = []
      handler = make_recording_handler(calls)
      klass = Class.new
      registry.register(klass, handler)

      element = klass.new
      para = Uniword::Builder::ParagraphBuilder.new
      registry.dispatch(element, para)

      expect(calls).to eq([[element, para]])
    end

    it "returns nil from lookup for unregistered classes (parent fallback)" do
      # Registry has no entry for an anonymous class — lookup returns nil,
      # and dispatch delegates to parent.render_unmatched_element.
      expect(registry.lookup(Class.new)).to be_nil
    end
  end

  describe "#registered?" do
    it "returns true for registered classes" do
      klass = Class.new
      registry.register(klass, make_handler("X"))
      expect(registry).to be_registered(klass)
    end

    it "returns false for unregistered classes" do
      expect(registry).not_to be_registered(Class.new)
    end
  end

  describe "default registrations" do
    it "registers a handler for EmRawElement" do
      expect(registry).to be_registered(
        Metanorma::Document::Components::Inline::EmRawElement,
      )
    end

    it "registers a handler for FnElement" do
      expect(registry).to be_registered(
        Metanorma::Document::Components::Inline::FnElement,
      )
    end

    it "registers a handler for Bookmark" do
      expect(registry).to be_registered(
        Metanorma::Document::Components::IdElements::Bookmark,
      )
    end

    it "registers a handler for SpanElement" do
      expect(registry).to be_registered(
        Metanorma::Document::Components::Inline::SpanElement,
      )
    end

    it "registers a handler for TermExpression" do
      expect(registry).to be_registered(
        Metanorma::IsoDocument::Terms::TermExpression,
      )
    end
  end

  # Helpers — minimal stand-ins for handler objects so the registry
  # tests don't depend on the InlineRenderers::* handler classes.

  def make_handler(name)
    handler = Class.new do
      define_method(:render) { |_element, _para| name }
    end
    handler.new
  end

  def make_recording_handler(calls)
    Class.new do
      define_method(:render) { |element, para| calls << [element, para] }
    end.new
  end
end
