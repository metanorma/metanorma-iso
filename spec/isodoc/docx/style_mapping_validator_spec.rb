# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::StyleMappingValidator do
  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.load_default }
  let(:library) { IsoDoc::Iso::Docx::StyleLibrary.load_default }
  let(:num_lib) { IsoDoc::Iso::Docx::NumberingLibrary.load_default }

  it "validates the canonical Era C mapping with zero defects" do
    v = described_class.new(mapping, library, numbering: num_lib)
    expect(v).to be_valid
    expect(v.defects).to be_empty
  end

  describe "detecting defects when the mapping drifts" do
    let(:broken_mapping) do
      IsoDoc::Iso::DocxStyleMapping.new(config_path: broken_path)
    end

    let(:broken_path) do
      Tempfile.new(["broken-mapping", ".yml"]).tap do |f|
        f.write(<<~YAML)
          paragraph_styles:
            good_note: Note
            bad_note: DefinitelyDoesNotExist
            bad_warning: AlsoDoesNotExist
          character_styles:
            bad_char: PhantomCharStyle
          numbering:
            bad_num: 999
            good_num: 1
          auto_numbered_styles:
            - Heading1
            - PhantomHeading
        YAML
        f.close
      end.path
    end

    let(:validator) do
      described_class.new(broken_mapping, library, numbering: num_lib)
    end

    it "is not valid" do
      expect(validator).not_to be_valid
    end

    it "lists unknown paragraph defects" do
      styles = validator.unknown_paragraph_styles.map(&:style_id)
      expect(styles).to include("DefinitelyDoesNotExist")
      expect(styles).to include("AlsoDoesNotExist")
      expect(styles).to include("PhantomHeading")
    end

    it "lists unknown character defects" do
      styles = validator.unknown_character_styles.map(&:style_id)
      expect(styles).to include("PhantomCharStyle")
    end

    it "lists unknown numbering defects" do
      keys = validator.unknown_numbering.map(&:key)
      expect(keys).to include(:bad_num)
    end
  end

  describe "excluded_styles leak detection" do
    let(:leaky_path) do
      Tempfile.new(["leaky-mapping", ".yml"]).tap do |f|
        f.write(<<~YAML)
          paragraph_styles:
            note: Note
            leaked: STDTitle1
          character_styles: {}
          numbering: {}
          auto_numbered_styles: []
          excluded_styles:
            globs:
              - "STDTitle*"
        YAML
        f.close
      end.path
    end

    let(:leaky_mapping) do
      IsoDoc::Iso::DocxStyleMapping.new(config_path: leaky_path)
    end

    it "flags styles that match an excluded glob" do
      v = described_class.new(leaky_mapping, library, numbering: num_lib)
      expect(v.excluded_leaks.map(&:style_id)).to include("STDTitle1")
    end
  end
end
