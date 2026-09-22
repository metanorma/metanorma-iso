# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::TableCellElement do
  describe "Registry dispatch" do
    it "dispatches ParagraphBlock to ParagraphHandler" do
      registry = described_class::Registry.new(
        resolver: nil, inline_renderer: nil,
      )
      expect(registry.lookup(Metanorma::Document::Components::Paragraphs::ParagraphBlock))
        .to be_a(described_class::ParagraphHandler)
    end

    it "dispatches NoteBlock to NoteHandler" do
      registry = described_class::Registry.new(
        resolver: nil, inline_renderer: nil,
      )
      expect(registry.lookup(Metanorma::Document::Components::Blocks::NoteBlock))
        .to be_a(described_class::NoteHandler)
    end

    it "dispatches OrderedList to ListHandler with decimal_list" do
      registry = described_class::Registry.new(
        resolver: nil, inline_renderer: nil,
      )
      handler = registry.lookup(Metanorma::Document::Components::Lists::OrderedList)
      expect(handler).to be_a(described_class::ListHandler)
    end

    it "dispatches UnorderedList to ListHandler with dash_list" do
      registry = described_class::Registry.new(
        resolver: nil, inline_renderer: nil,
      )
      handler = registry.lookup(Metanorma::Document::Components::Lists::UnorderedList)
      expect(handler).to be_a(described_class::ListHandler)
    end

    it "falls back to ParagraphHandler for unmatched classes" do
      registry = described_class::Registry.new(
        resolver: nil, inline_renderer: nil,
      )
      expect(registry.lookup(Object)).to be_a(described_class::ParagraphHandler)
    end
  end

  describe "CellTarget" do
    it "exposes builder and style_key" do
      builder = Uniword::Builder::TableCellBuilder.new
      target = described_class::CellTarget.new(builder, :table_body)
      expect(target.builder).to be(builder)
      expect(target.style_key).to eq(:table_body)
    end

    it "delegates << to the builder" do
      builder = Uniword::Builder::TableCellBuilder.new
      target = described_class::CellTarget.new(builder, :table_body)
      para = Uniword::Builder::ParagraphBuilder.new
      target << para
      expect(builder.model.paragraphs).to include(para.build)
    end
  end
end
