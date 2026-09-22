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

    it "returns Figuretitle style inside annex (Era C: same style for body and annex)" do
      context.with_annex do
        expect(resolver.figure_title_style).to eq("Figuretitle")
      end
    end
  end

  describe ".dimension_key_for" do
    it "returns :dimension_100 when pct is nil" do
      expect(described_class.dimension_key_for(nil)).to eq(:dimension_100)
    end

    it "returns :dimension_100 at or above 90%" do
      expect(described_class.dimension_key_for(90)).to eq(:dimension_100)
      expect(described_class.dimension_key_for(95)).to eq(:dimension_100)
      expect(described_class.dimension_key_for(100)).to eq(:dimension_100)
    end

    it "returns :dimension_75 between 60% and 89%" do
      expect(described_class.dimension_key_for(60)).to eq(:dimension_75)
      expect(described_class.dimension_key_for(70)).to eq(:dimension_75)
      expect(described_class.dimension_key_for(89)).to eq(:dimension_75)
    end

    it "returns :dimension_50 below 60%" do
      expect(described_class.dimension_key_for(10)).to eq(:dimension_50)
      expect(described_class.dimension_key_for(40)).to eq(:dimension_50)
      expect(described_class.dimension_key_for(59)).to eq(:dimension_50)
    end
  end

  describe "#image_paragraph_style" do
    it "returns FigureGraphic inside a figure zone regardless of width" do
      context.with_figure do
        expect(resolver.image_paragraph_style(nil)).to eq("FigureGraphic")
        expect(resolver.image_paragraph_style(50)).to eq("FigureGraphic")
      end
    end

    it "returns Dimension100 outside figure when width is nil" do
      expect(resolver.image_paragraph_style(nil)).to eq("Dimension100")
    end

    it "returns Dimension75 for medium-width standalone images" do
      expect(resolver.image_paragraph_style(70)).to eq("Dimension75")
    end

    it "returns Dimension50 for narrow standalone images" do
      expect(resolver.image_paragraph_style(40)).to eq("Dimension50")
    end
  end

  describe "#table_title_style" do
    it "returns Tabletitle style" do
      expect(resolver.table_title_style).to eq("Tabletitle")
    end

    it "returns Tabletitle style inside annex (Era C: same style for body and annex)" do
      context.with_annex do
        expect(resolver.table_title_style).to eq("Tabletitle")
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

RSpec.describe IsoDoc::Iso::Docx::StyleResolver, "strict mode (TODO 021)" do
  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.new }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:resolver) { described_class.new(mapping, context) }

  describe "#paragraph_style!" do
    it "returns the canonical Heading1 styleId for :heading1" do
      expect(resolver.paragraph_style!(:heading1)).to eq("Heading1")
    end

    it "returns the canonical Note styleId for :note in body zone" do
      expect(resolver.paragraph_style!(:note)).to eq("Note")
    end

    it "raises UnknownStyleError for an unknown key" do
      expect { resolver.paragraph_style!(:definitely_unknown) }
        .to raise_error(IsoDoc::Iso::Docx::UnknownStyleError, /definitely_unknown/)
    end

    it "includes the style key and role in the error message" do
      expect { resolver.paragraph_style!(:definitely_unknown, role: :custom_role) }
        .to raise_error(IsoDoc::Iso::Docx::UnknownStyleError, /custom_role/)
    end

    it "exposes key and context on the error for diagnostics" do
      err = nil
      begin
        resolver.paragraph_style!(:definitely_unknown)
      rescue IsoDoc::Iso::Docx::UnknownStyleError => e
        err = e
      end
      expect(err.key).to eq(:definitely_unknown)
      expect(err.context).to eq(context)
    end
  end

  describe "#character_style!" do
    it "returns InlineCode for :inline_code key" do
      expect(resolver.character_style!(:inline_code)).to eq("InlineCode")
    end

    it "raises UnknownStyleError for unknown character key" do
      expect { resolver.character_style!(:nope) }
        .to raise_error(IsoDoc::Iso::Docx::UnknownStyleError, /nope/)
    end
  end

  describe "#numbering_id!" do
    it "returns numId for :body_clause" do
      expect(resolver.numbering_id!(:body_clause)).to eq(4)
    end

    it "returns numId for :annex_clause" do
      expect(resolver.numbering_id!(:annex_clause)).to eq(7)
    end

    it "raises UnknownStyleError for unknown numbering key" do
      expect { resolver.numbering_id!(:nope) }
        .to raise_error(IsoDoc::Iso::Docx::UnknownStyleError, /nope/)
    end
  end

  describe "context-aware dispatch (zone enum)" do
    it "returns Noteindent body style in :note zone" do
      context.with_note do
        expect(resolver.context_body_style).to eq("Noteindent")
      end
    end

    it "returns Exampleindent body style in :example zone" do
      context.with_example do
        expect(resolver.context_body_style).to eq("Exampleindent")
      end
    end

    it "returns ForewordText body style in :foreword zone" do
      context.with_foreword do
        expect(resolver.context_body_style).to eq("ForewordText")
      end
    end

    it "returns BiblioText body style in :bibliography zone" do
      context.with_bibliography do
        expect(resolver.context_body_style).to eq("BiblioText")
      end
    end

    it "returns RefNorm body style in :normative zone" do
      context.with_normative do
        expect(resolver.context_body_style).to eq("RefNorm")
      end
    end

    it "returns nil in :body zone (default)" do
      expect(resolver.context_body_style).to be_nil
    end

    it "does not chain fallbacks — :annex zone has no body override" do
      context.with_annex do
        expect(resolver.context_body_style).to be_nil
      end
    end
  end

  describe "heading_style!" do
    it "returns Heading1 for level 1" do
      expect(resolver.heading_style!(1)).to eq("Heading1")
    end

    it "raises UnknownStyleError when level unmapped" do
      expect { resolver.heading_style!(99) }
        .to raise_error(IsoDoc::Iso::Docx::UnknownStyleError, /heading99/)
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
