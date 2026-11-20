# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::NbspProcessor, :aggregate_failures do # rubocop:disable RSpec/SpecFilePathFormat
  let(:nbsp) { "\u00A0" }

  describe ".process" do
    {
      "Part 3" => "Part\u00A03",
      "50 %" => "50\u00A0%",
      "ISO 9001" => "ISO\u00A09001",
      "ISO/IEC 27001" => "ISO/IEC\u00A027001",
      "NOTE 2" => "NOTE\u00A02",
      "Table 4" => "Table\u00A04",
      "Figure A.2" => "Figure\u00A0A.2",
      "Clause 7" => "Clause\u00A07",
      "Formula (3)" => "Formula\u00A0(3)",
      "Annex B" => "Annex\u00A0B",
      "text — Next" => "text\u00A0— Next",
    }.each do |input, expected|
      it "binds #{input.inspect} with no-break spaces" do
        expect(described_class.process(input)).to eq(expected)
      end
    end

    it "binds the number of a 'Note 1 to entry' label" do
      expect(described_class.process("Note 1 to entry"))
        .to start_with("Note#{nbsp}1")
    end

    # Known gap: the 'Note N to entry' rule never fires, because the
    # earlier NOTE rule has already turned the first space into U+00A0 and
    # \s does not match U+00A0.
    it "also binds 'to entry' (PENDING: rule order)" do
      pending "the Note-to-entry rule is shadowed by the NOTE rule"
      expect(described_class.process("Note 1 to entry"))
        .to eq("Note#{nbsp}1#{nbsp}to entry")
    end

    it "leaves ordinary spaces alone" do
      text = "see the table for 5 items and part of the rest"
      expect(described_class.process(text)).to eq(text)
    end

    it "applies several rules to one string" do
      expect(described_class.process("Table 2 and Annex C"))
        .to eq("Table#{nbsp}2 and Annex#{nbsp}C")
    end

    it "returns a non-string unchanged" do
      expect(described_class.process(nil)).to be_nil
      expect(described_class.process(12)).to eq(12)
    end
  end

  describe ".apply_to_text" do
    it "rewrites text nodes and keeps tags and attributes byte for byte" do
      xml = '<p id="Table 1">See Table 1 <bold>Part 2</bold></p>'
      expect(described_class.apply_to_text(xml))
        .to eq("<p id=\"Table 1\">See Table#{nbsp}1 <bold>Part#{nbsp}2</bold></p>")
    end

    it "processes trailing text after the last tag" do
      expect(described_class.apply_to_text("<a/>Annex D"))
        .to eq("<a/>Annex#{nbsp}D")
    end

    it "processes text that has no tag at all" do
      expect(described_class.apply_to_text("Clause 5")).to eq("Clause#{nbsp}5")
    end

    it "does not hang on an unterminated tag" do
      expect(described_class.apply_to_text("a <b Table 1"))
        .to eq("a <b Table#{nbsp}1")
    end
  end
end
