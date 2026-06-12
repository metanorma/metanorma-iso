# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::StyleResolver do
  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.new }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:resolver) { described_class.new(mapping, context) }

  describe "#paragraph_style" do
    it "delegates to style mapping" do
      expect(resolver.paragraph_style(:note)).to eq("Note")
    end

    it "returns nil for unknown styles" do
      expect(resolver.paragraph_style(:nonexistent_xyz)).to be_nil
    end
  end

  describe "#character_style" do
    it "delegates to style mapping" do
      expect(resolver.character_style(:hyperlink)).to eq("Hyperlink")
    end
  end

  describe "#heading_style" do
    it "returns body heading style outside annex" do
      expect(resolver.heading_style(1)).to eq("Heading1")
      expect(resolver.heading_style(3)).to eq("Heading3")
    end

    it "returns annex heading style inside annex (a2–a6)" do
      context.with_annex do
        expect(resolver.heading_style(2)).to eq("a2")
        expect(resolver.heading_style(3)).to eq("a3")
      end
    end

    it "falls back to body heading for level 1 inside annex" do
      context.with_annex do
        expect(resolver.heading_style(1)).to eq("Heading1")
      end
    end
  end

  describe "#figure_title_style" do
    it "returns Figuretitle style" do
      expect(resolver.figure_title_style).to eq("Figuretitle")
    end

    it "returns AnnexFigureTitle style inside annex" do
      context.with_annex do
        expect(resolver.figure_title_style).to eq("AnnexFigureTitle")
      end
    end
  end

  describe "#table_title_style" do
    it "returns Tabletitle style" do
      expect(resolver.table_title_style).to eq("Tabletitle")
    end

    it "returns AnnexTableTitle style inside annex" do
      context.with_annex do
        expect(resolver.table_title_style).to eq("AnnexTableTitle")
      end
    end
  end

  describe "#term_number_style" do
    it "returns TermNum at section_depth 2" do
      context.section_depth = 2
      expect(resolver.term_number_style).to eq("TermNum")
    end

    it "returns TermNum at section_depth 3" do
      context.section_depth = 3
      expect(resolver.term_number_style).to eq("TermNum")
    end

    it "returns TermNum at section_depth 1" do
      context.section_depth = 1
      expect(resolver.term_number_style).to eq("TermNum")
    end

    it "returns TermNum at high depths" do
      context.section_depth = 10
      expect(resolver.term_number_style).to eq("TermNum")
    end
  end

  describe "#numbering_id" do
    it "returns numId for dash bullet lists" do
      expect(resolver.numbering_id(:dash_list)).to eq(3)
    end

    it "returns numId for decimal lists" do
      expect(resolver.numbering_id(:decimal_list)).to eq(1)
    end

    it "returns numId for body clause numbering" do
      expect(resolver.numbering_id(:body_clause)).to eq(4)
    end

    it "returns nil for unknown numbering keys" do
      expect(resolver.numbering_id(:nonexistent_xyz)).to be_nil
    end
  end

  describe "#span_class_style" do
    it "maps hyperlink span class to character style" do
      expect(resolver.span_class_style("Hyperlink")).to eq("Hyperlink")
    end

    it "returns nil for unknown span class" do
      expect(resolver.span_class_style("nonexistent_xyz")).to be_nil
    end

    it "returns nil for nil input" do
      expect(resolver.span_class_style(nil)).to be_nil
    end
  end
end

RSpec.describe IsoDoc::Iso::Docx::StyleResolver, "Simple template" do
  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.new(template: :simple) }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:resolver) { described_class.new(mapping, context) }

  describe "#figure_title_style" do
    it "returns body FigureTitle outside annex" do
      expect(resolver.figure_title_style).to eq("FigureTitle")
    end

    it "returns AnnexFigureTitle inside annex" do
      context.with_annex do
        expect(resolver.figure_title_style).to eq("AnnexFigureTitle")
      end
    end
  end

  describe "#table_title_style" do
    it "returns Tabletitle outside annex" do
      expect(resolver.table_title_style).to eq("Tabletitle")
    end

    it "returns AnnexTableTitle inside annex" do
      context.with_annex do
        expect(resolver.table_title_style).to eq("AnnexTableTitle")
      end
    end
  end

  describe "#numbering_id" do
    it "uses Simple numbering values" do
      expect(resolver.numbering_id(:dash_list)).to eq(18)
      expect(resolver.numbering_id(:annex_clause)).to eq(7)
    end
  end
end
