# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::BlockDispatcher do
  let(:t) { Metanorma::Iso::Sts::Transformer }

  let(:source) do
    t::SourceDocument.parse(<<~XML)
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard"><title language="en" type="main">T</title>
          <docidentifier>ISO 1</docidentifier><language>en</language></bibdata>
        <sections>
          <clause id="c1"><title>Scope</title>
            <p id="p1">Para one.</p>
            <ul id="u1"><li><p id="lp1">bullet</p></li></ul>
            <dl id="d1"><dt>A</dt><dd><p id="dp1">Alpha</p></dd></dl>
            <note id="n1"><p id="np1">A note.</p></note>
            <figure id="f1" anchor="fa"><name>Fig</name><image id="i1" src="a.png" mimetype="image/png"/></figure>
          </clause>
        </sections>
      </metanorma>
    XML
  end
  let(:context) { t::Context.new(source) }
  let(:dispatcher) { described_class.new(context) }
  let(:clause) { source.sections.first }

  describe "#dispatch" do
    it "returns nil for nil and for plain strings" do
      expect(dispatcher.dispatch(nil)).to be_nil
      expect(dispatcher.dispatch("text")).to be_nil
    end

    it "returns nil for classes it has no handler for" do
      expect(dispatcher.dispatch(Object.new)).to be_nil
    end

    it "returns nil for presentation-only classes" do
      presentation = Metanorma::Document::Components::Inline::FmtTitleElement.new
      expect(dispatcher.dispatch(presentation)).to be_nil
    end

    it "routes a clause to a <sec>" do
      sec = dispatcher.dispatch(clause)

      expect(sec).to be_a(Sts::NisoSts::Section)
      expect(Nokogiri::XML(sec.to_xml).root.name).to eq("sec")
    end

    it "routes a paragraph to <p>" do
      p_el = dispatcher.dispatch(clause.paragraphs.first)

      expect(p_el).to be_a(Sts::NisoSts::Paragraph)
      expect(Nokogiri::XML(p_el.to_xml).root.name).to eq("p")
    end

    it "routes an unordered list to <list>" do
      list = dispatcher.dispatch(clause.unordered_lists.first)

      expect(list).to be_a(Sts::NisoSts::List)
      expect(Nokogiri::XML(list.to_xml).root["list-type"]).to eq("bullet")
    end

    it "routes a definition list to <def-list>" do
      expect(dispatcher.dispatch(clause.definition_lists.first)).to be_a(Sts::NisoSts::DefList)
    end

    it "routes a figure to <fig>" do
      expect(dispatcher.dispatch(clause.figures.first)).to be_a(Sts::NisoSts::Figure)
    end

    it "wraps a note in an array so trailing notes can follow" do
      result = dispatcher.dispatch(clause.notes.first)

      expect(result).to be_an(Array)
      expect(result.first).to be_a(Sts::NisoSts::NonNormativeNote)
    end
  end

  describe "#dispatch_section_blocks" do
    it "collects the typed blocks of a clause in source order" do
      blocks = dispatcher.dispatch_section_blocks(clause)

      expect(blocks.map(&:class)).to eq(
        [Sts::NisoSts::Paragraph, Sts::NisoSts::List, Sts::NisoSts::DefList,
         Sts::NisoSts::NonNormativeNote, Sts::NisoSts::Figure],
      )
    end

    it "emits each block once (no overlap with mixed content)" do
      blocks = dispatcher.dispatch_section_blocks(clause)

      expect(blocks.count { |b| b.is_a?(Sts::NisoSts::Paragraph) }).to eq(1)
    end

    it "returns no blocks for an empty clause" do
      empty = t::SourceDocument.parse(<<~XML).sections.first
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
          <bibdata type="standard"><title language="en" type="main">T</title><docidentifier>ISO 1</docidentifier></bibdata>
          <sections><clause id="c9"><title>Empty</title></clause></sections>
        </metanorma>
      XML

      expect(dispatcher.dispatch_section_blocks(empty)).to eq([])
    end

    it "places a note that follows a paragraph after that paragraph, as a sibling" do
      src = t::SourceDocument.parse(<<~XML)
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
          <bibdata type="standard"><title language="en" type="main">T</title><docidentifier>ISO 1</docidentifier></bibdata>
          <sections><clause id="c2"><title>X</title>
            <p id="pa">Lead.</p><note id="na"><p id="npa">After lead.</p></note>
          </clause></sections>
        </metanorma>
      XML
      d = described_class.new(t::Context.new(src))
      blocks = d.dispatch_section_blocks(src.sections.first)
      xml = blocks.map(&:to_xml).join

      expect(xml).to include("Lead.")
      expect(xml).to include("After lead.")
      expect(xml.scan("After lead.").size).to eq(1)
    end
  end
end
