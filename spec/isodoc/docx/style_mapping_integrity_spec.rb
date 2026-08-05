# frozen_string_literal: true

# Spec: every semantic key in style_mapping.yml resolves to a styleId
# that exists in styles.yml. Catches regressions where the mapping
# references a style that has been renamed or removed.
#
# See TODO.new-dis/019-spec-style-mapping-integrity.md for the design.

require_relative "spec_helper"

RSpec.describe "style_mapping integrity" do
  let(:mapping)   { IsoDoc::Iso::DocxStyleMapping.load_default }
  let(:library)   { IsoDoc::Iso::Docx::StyleLibrary.load_default }
  let(:num_lib)   { IsoDoc::Iso::Docx::NumberingLibrary.load_default }
  let(:validator) do
    IsoDoc::Iso::Docx::StyleMappingValidator.new(mapping, library,
                                                  numbering: num_lib)
  end

  it "loads the Era C style library (250 styles)" do
    expect(library.all_style_ids.size).to be > 200
    expect(library.template_era).to eq("late_typefi")
    expect(library.reference_doc).to eq("20250530-ISO_DIS_15926-100.docx")
  end

  it "loads 7 canonical abstractNums" do
    expect(num_lib.abstract_num_ids.size).to eq(7)
    expected_abstracts = %w[0 1 2 3 4 5 6].to_set
    expect(num_lib.abstract_num_ids).to eq(expected_abstracts)
  end

  describe "paragraph_styles" do
    it "every mapped styleId exists as a paragraph style" do
      missing = validator.unknown_paragraph_styles
      expect(missing).to be_empty,
        "paragraph_styles missing from styles.yml: " +
        missing.map(&:message).join("\n  ")
    end
  end

  describe "character_styles" do
    it "every mapped styleId exists as a character style" do
      missing = validator.unknown_character_styles
      expect(missing).to be_empty,
        "character_styles missing from styles.yml: " +
        missing.map(&:message).join("\n  ")
    end
  end

  describe "numbering" do
    it "every numId exists in numbering.yml" do
      missing = validator.unknown_numbering
      expect(missing).to be_empty,
        "numbering missing from numbering.yml: " +
        missing.map(&:message).join("\n  ")
    end

    it "canonical Era C numbering keys are present" do
      expect(mapping.numbering_id(:intro_clause)).to eq(8)
      expect(mapping.numbering_id(:list_continue_dash)).to eq(3)
      expect(mapping.numbering_id(:body_clause)).to eq(4)
      expect(mapping.numbering_id(:decimal_ordered_list)).to eq(1)
      expect(mapping.numbering_id(:annex_clause)).to eq(7)
    end
  end

  describe "excluded_styles" do
    it "no excluded styleId appears in the mapping" do
      leaks = validator.excluded_leaks
      expect(leaks).to be_empty,
        "mapping references excluded (pollution) styles: " +
        leaks.map(&:message).join("\n  ")
    end
  end

  describe "Era C canonical style coverage" do
    # Spot-check the 14 Era C content styles that the audit identified
    # as missing from the old Era B YAML.
    {
      note_indent: "Noteindent",
      example_indent: "Exampleindent",
      admonition: "Warningtext",
      admonition_title: "Warningtitle",
      box_begin: "Box-begin",
      box_end: "Box-end",
      box_title: "Box-title",
      key_title: "KeyTitle",
      key_text: "KeyText",
      figure_description: "Figuredescription",
      figure_note: "Figurenote",
      figure_subtitle: "Figuresubtitle",
      quote: "Disp-quotep",
      dimension_50: "Dimension50",
      dimension_75: "Dimension75",
      dimension_100: "Dimension100",
      header_centered: "HeaderCentered",
      footer_page_number: "FooterPageNumber",
      footer_roman: "FooterPageRomanNumber",
      annex: "ANNEX",
    }.each do |key, expected_style_id|
      it "maps #{key} -> #{expected_style_id}" do
        expect(mapping.paragraph_style(key)).to eq(expected_style_id)
      end
    end
  end

  describe "InlineCode character styles" do
    it "maps inline_code to InlineCode" do
      expect(mapping.character_style(:inline_code)).to eq("InlineCode")
    end

    it "maps inline_code_bold to InlineCodeBold" do
      expect(mapping.character_style(:inline_code_bold)).to eq("InlineCodeBold")
    end
  end
end
