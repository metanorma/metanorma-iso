# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::StyleResolver do
  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.new }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:resolver) { described_class.new(mapping, context) }

  describe "#paragraph_style" do
    it "delegates to style mapping" do
      expect(resolver.paragraph_style(:note)).to eq("Note0")
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
    it "returns body figure title outside annex" do
      expect(resolver.figure_title_style).to eq("Figuretitle0")
    end

    it "returns annex figure title inside annex" do
      context.with_annex do
        expect(resolver.figure_title_style).to eq("Figuretitle0")
      end
    end
  end

  describe "#table_title_style" do
    it "returns body table title outside annex" do
      expect(resolver.table_title_style).to eq("Tabletitle0")
    end

    it "returns annex table title inside annex" do
      context.with_annex do
        expect(resolver.table_title_style).to eq("Tabletitle0")
      end
    end
  end

  describe "#numbering_id" do
    it "returns numId for dash bullet lists" do
      expect(resolver.numbering_id(:dash_list)).to eq(10)
    end

    it "returns numId for alpha lists" do
      expect(resolver.numbering_id(:alpha_list)).to eq(6)
    end

    it "returns numId for decimal lists" do
      expect(resolver.numbering_id(:decimal_list)).to eq(1)
    end

    it "returns nil for unknown numbering keys" do
      expect(resolver.numbering_id(:nonexistent_xyz)).to be_nil
    end
  end

  describe "#span_class_style" do
    it "maps stdpublisher span class to character style" do
      expect(resolver.span_class_style("stdpublisher")).to eq("stdpublisher")
    end

    it "maps stddocNumber span class to character style" do
      expect(resolver.span_class_style("stddocNumber")).to eq("stddocNumber")
    end

    it "maps stddocPartNumber span class to character style" do
      expect(resolver.span_class_style("stddocPartNumber")).to eq("stddocPartNumber")
    end

    it "maps stddocTitle span class to character style" do
      expect(resolver.span_class_style("stddocTitle")).to eq("stddocTitle")
    end

    it "maps stdyear span class to character style" do
      expect(resolver.span_class_style("stdyear")).to eq("stdyear")
    end

    it "maps citeapp span class to character style" do
      expect(resolver.span_class_style("citeapp")).to eq("citeapp")
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
