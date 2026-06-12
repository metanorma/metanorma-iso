# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::DocxStyleMapping do
  subject(:mapping) { described_class.new }

  describe "#initialize" do
    it "loads the default DIS config" do
      expect(mapping.paragraph_styles).to be_a(Hash)
      expect(mapping.character_styles).to be_a(Hash)
      expect(mapping.numbering).to be_a(Hash)
    end

    it "raises on missing config file" do
      expect { described_class.new(config_path: "/nonexistent.yml") }.to raise_error(Errno::ENOENT)
    end
  end

  describe "#paragraph_style" do
    it "returns style for known keys" do
      expect(mapping.paragraph_style(:foreword)).to eq("ForewordTitle")
      expect(mapping.paragraph_style(:note)).to eq("Note")
      expect(mapping.paragraph_style(:example)).to eq("Example")
    end

    it "returns nil for unknown keys" do
      expect(mapping.paragraph_style(:nonexistent)).to be_nil
    end

    it "accepts string keys" do
      expect(mapping.paragraph_style("foreword")).to eq("ForewordTitle")
    end

    it "returns new template style IDs" do
      expect(mapping.paragraph_style(:figure_title)).to eq("Figuretitle")
      expect(mapping.paragraph_style(:table_title)).to eq("Tabletitle")
      expect(mapping.paragraph_style(:terms)).to eq("Terms")
      expect(mapping.paragraph_style(:admitted_term)).to eq("AltTerms")
      expect(mapping.paragraph_style(:cover_large)).to eq("zzCoverlarge")
      expect(mapping.paragraph_style(:contents_title)).to eq("zzContents")
    end
  end

  describe "#character_style" do
    it "returns style for known keys" do
      expect(mapping.character_style(:hyperlink)).to eq("Hyperlink")
    end

    it "returns nil for unknown keys" do
      expect(mapping.character_style(:nonexistent)).to be_nil
    end
  end

  describe "#heading_style" do
    it "returns heading styleId for each level" do
      expect(mapping.heading_style(1)).to eq("Heading1")
      expect(mapping.heading_style(3)).to eq("Heading3")
      expect(mapping.heading_style(6)).to eq("Heading6")
    end

    it "returns default for levels beyond 6" do
      expect(mapping.heading_style(7)).to eq("Heading7")
    end
  end

  describe "#annex_heading_style" do
    it "returns annex heading styles (a2–a6)" do
      expect(mapping.annex_heading_style(2)).to eq("a2")
      expect(mapping.annex_heading_style(3)).to eq("a3")
      expect(mapping.annex_heading_style(4)).to eq("a4")
    end

    it "falls back to heading style for level 1" do
      expect(mapping.annex_heading_style(1)).to eq("Heading1")
    end
  end

  describe "#numbering_id" do
    it "returns numId for DIS numbering keys" do
      expect(mapping.numbering_id(:dash_list)).to eq(3)
      expect(mapping.numbering_id(:decimal_list)).to eq(1)
      expect(mapping.numbering_id(:body_clause)).to eq(4)
      expect(mapping.numbering_id(:annex_clause)).to eq(7)
      expect(mapping.numbering_id(:intro_clause)).to eq(8)
    end

    it "returns nil for unknown numbering keys" do
      expect(mapping.numbering_id(:nonexistent)).to be_nil
    end
  end
end

RSpec.describe IsoDoc::Iso::DocxStyleMapping, "Simple template" do
  subject(:mapping) { described_class.new(template: :simple) }

  it "loads Simple template styles" do
    expect(mapping.paragraph_style(:note)).to eq("Note")
    expect(mapping.paragraph_style(:sourcecode)).to eq("Code")
  end

  it "uses Simple-specific figure/table title styles" do
    expect(mapping.paragraph_style(:figure_title_annex)).to eq("AnnexFigureTitle")
    expect(mapping.paragraph_style(:table_title_annex)).to eq("AnnexTableTitle")
  end

  it "uses Simple numbering definitions" do
    expect(mapping.numbering_id(:decimal_list)).to eq(1)
    expect(mapping.numbering_id(:annex_clause)).to eq(7)
    expect(mapping.numbering_id(:dash_list)).to eq(18)
  end

  it "falls back to BodyText where Simple has no dedicated style" do
    expect(mapping.paragraph_style(:biblio_entry)).to eq("BodyText")
    expect(mapping.paragraph_style(:footnote_text)).to eq("BodyText")
  end
end

RSpec.describe IsoDoc::Iso::DocxTemplates do
  describe ".template_path" do
    it "returns DIS template path" do
      expect(IsoDoc::Iso::DocxTemplates.template_path(:dis))
        .to end_with("data/iso-dis/template.docx")
    end

    it "returns Simple template path" do
      expect(IsoDoc::Iso::DocxTemplates.template_path(:simple))
        .to end_with("data/iso-simple/template.dotx")
    end

    it "defaults to DIS for unknown types" do
      expect(IsoDoc::Iso::DocxTemplates.template_path(:unknown))
        .to end_with("data/iso-dis/template.docx")
    end
  end

  describe ".style_mapping_path" do
    it "returns DIS mapping path" do
      expect(IsoDoc::Iso::DocxTemplates.style_mapping_path(:dis))
        .to end_with("data/iso-dis/style_mapping.yml")
    end

    it "returns Simple mapping path" do
      expect(IsoDoc::Iso::DocxTemplates.style_mapping_path(:simple))
        .to end_with("data/iso-simple/style_mapping.yml")
    end
  end
end

RSpec.describe IsoDoc::Iso, ".default_docx_template" do
  it "returns a path to the bundled DIS template" do
    path = IsoDoc::Iso.default_docx_template
    expect(path).to end_with("data/iso-dis/template.docx")
    expect(File.exist?(path)).to be(true)
  end
end
