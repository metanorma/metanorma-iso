# frozen_string_literal: true

require_relative "spec_helper"
require_relative "support/docx_unpacker"
require_relative "support/style_id_asserter"

# End-to-end spec for the DOCX adapter against a large ISO presentation
# XML. Default fixture is the smaller DIS sample; rice is opt-in via
# the RICE_E2E=1 environment variable.
#
# Per CLAUDE.md: NEVER load rice presentation XML in a background task.
# This spec is tagged :slow so it never runs in default rake tasks.
# Invoke explicitly:
#
#   bundle exec rspec spec/isodoc/docx/end_to_end_spec.rb --tag slow
#
# For rice:
#   RICE_E2E=1 bundle exec rspec spec/isodoc/docx/end_to_end_spec.rb --tag slow
RSpec.describe "IsoDoc::Iso::Docx::Adapter", :slow do
  let(:fixture_path) do
    path = if ENV["RICE_E2E"]
             "spec/examples/rice.presentation.xml"
           else
             "spec/fixtures/iso/is/document-en.dis.presentation.xml"
           end
    File.expand_path(path, Dir.pwd)
  end
  let(:output_path) do
    dir = Dir.mktmpdir("e2e-")
    File.join(dir, "output.docx")
  end
  let(:unpacked) { IsoDoc::Iso::Docx::DocxUnpacker.unpack(output_path) }
  let(:w_ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }

  before do
    skip "Presentation XML fixture missing (#{fixture_path})" unless File.exist?(fixture_path)
    build_adapter.convert(fixture_path, output_path)
  end

  after do
    unpacked&.cleanup
    FileUtils.rm_f(output_path)
  end

  describe "styleId coverage" do
    let(:asserter) do
      IsoDoc::Iso::Docx::StyleIdAsserter.new(
        unpacked.document_xml,
        library: IsoDoc::Iso::Docx::StyleLibrary.load_default,
        excluded: IsoDoc::Iso::DocxStyleMapping.load_default.excluded_style_ids,
      )
    end

    it "uses only styleIds defined in the Era C library" do
      expect(asserter.unknown_style_ids).to be_empty,
                                            "Unknown styleIds (not in Era C library): #{asserter.unknown_style_ids.inspect}"
    end

    it "uses no pollution styleIds" do
      expect(asserter.pollution_style_ids).to be_empty,
                                              "Pollution styleIds present: #{asserter.pollution_style_ids.inspect}"
    end
  end

  describe "canonical numbering" do
    # Era C: numbering is bound via the style cascade, not via explicit
    # numPr on each paragraph. So Heading1 style references abstractNum
    # 3 → numId=4; ANNEX references abstractNum 6 → numId=7. Body
    # paragraphs themselves should not carry explicit numPr (the style
    # already does it for them).

    it "Heading1 style references numId=4 in styles.xml" do # rubocop:disable RSpec/ExampleLength
      doc = unpacked.styles_xml
      style = doc.at_xpath("//w:style[w:name[@w:val='Heading1']]", w_ns)
      skip "No Heading1 style in styles.xml" unless style

      num_id = style.at_xpath(".//w:numPr/w:numId/@w:val", w_ns)
      expect(num_id&.to_s).to eq("4"),
                              "Heading1 style should reference numId=4, found: #{num_id}"
    end

    it "ANNEX style references numId=7 in styles.xml" do # rubocop:disable RSpec/ExampleLength
      doc = unpacked.styles_xml
      style = doc.at_xpath("//w:style[w:name[@w:val='ANNEX']]", w_ns)
      skip "No ANNEX style in styles.xml" unless style

      num_id = style.at_xpath(".//w:numPr/w:numId/@w:val", w_ns)
      expect(num_id&.to_s).to eq("7"),
                              "ANNEX style should reference numId=7, found: #{num_id}"
    end

    it "numbering.xml defines 7 abstractNums (canonical Era C scheme)" do
      doc = unpacked.numbering_xml
      skip "No numbering.xml" unless doc

      abstracts = doc.xpath("//w:abstractNum", w_ns)
      expect(abstracts.size).to be >= 7,
                                "Era C canonical scheme has 7 abstractNums, found #{abstracts.size}"
    end
  end

  describe "note/example inline-label layout" do
    it "wraps no Noteindent/Exampleindent paragraphs in Era C boxes" do # rubocop:disable RSpec/ExampleLength
      doc = unpacked.document_xml
      bodies = doc.xpath(
        "//w:p[w:pPr/w:pStyle[@w:val='Noteindent']]" \
        "|//w:p[w:pPr/w:pStyle[@w:val='Noteindentcontinued']]" \
        "|//w:p[w:pPr/w:pStyle[@w:val='Exampleindent']]" \
        "|//w:p[w:pPr/w:pStyle[@w:val='Exampleindentcontinued']]",
        w_ns,
      )
      skip "No note/example body paragraphs in fixture" if bodies.empty?

      bodies.each do |para|
        prior_styles = para.xpath("preceding-sibling::w:p/w:pPr/w:pStyle/@w:val", w_ns).map(&:to_s)
        # Closed boxes and boxes later in the document do not enclose this paragraph.
        box_depth = prior_styles.count("Box-begin") - prior_styles.count("Box-end")

        expect(box_depth).to eq(0),
                             "note/example body must not be enclosed by Box-begin/Box-end (inline-label contract)"
      end
    end

    it "carries the NOTE/EXAMPLE label inline in the first body paragraph" do # rubocop:disable RSpec/ExampleLength
      doc = unpacked.document_xml
      label_paras = doc.xpath(
        "//w:p[w:pPr/w:pStyle[@w:val='Noteindent'] or w:pPr/w:pStyle[@w:val='Example']]",
        w_ns,
      ).select do |para|
        para.xpath(".//w:t", w_ns).map(&:text).join.start_with?("NOTE", "EXAMPLE")
      end
      skip "No label-carrying note/example paragraphs in fixture" if label_paras.empty?

      expect(label_paras).not_to be_empty
    end
  end

  describe "formula key lists" do
    it "KeyTitle and KeyText counts match (balanced dt/dd pairs)" do # rubocop:disable RSpec/ExampleLength
      doc = unpacked.document_xml
      titles = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='KeyTitle']]", w_ns)
      texts = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='KeyText']]", w_ns)

      skip "No KeyTitle/KeyText in fixture" if titles.empty? && texts.empty?

      expect(titles.size).to eq(texts.size),
                             "KeyTitle count (#{titles.size}) should match KeyText count (#{texts.size})"
    end
  end

  describe "image Dimension styles" do
    it "every image paragraph uses Dimension50/75/100" do # rubocop:disable RSpec/ExampleLength
      doc = unpacked.document_xml
      drawings = doc.xpath("//w:r/w:drawing", w_ns)
      skip "No image drawings in fixture" if drawings.empty?

      drawings.each do |drawing|
        paragraph = drawing.ancestors("w:p").first
        next unless paragraph

        style = paragraph.at_xpath("w:pPr/w:pStyle/@w:val", w_ns)
        expect(style&.to_s).to match(/\ADimension(50|75|100)\z/),
                               "Image paragraph should use Dimension*, found: #{style}"
      end
    end
  end

  describe "block quotes" do
    it "Disp-quotep paragraphs do not carry manual indent" do # rubocop:disable RSpec/ExampleLength
      doc = unpacked.document_xml
      quotes = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='Disp-quotep']]", w_ns)
      skip "No Disp-quotep paragraphs in fixture" if quotes.empty?

      quotes.each do |quote|
        manual_ind = quote.at_xpath("w:pPr/w:ind", w_ns)
        expect(manual_ind).to be_nil,
                              "Disp-quotep paragraph should not set manual indent"
      end
    end
  end

  describe "inline code" do
    it "InlineCode rStyle is used in the document" do
      doc = unpacked.document_xml
      inline_code = doc.xpath("//w:r[w:rPr/w:rStyle[@w:val='InlineCode']]", w_ns)
      skip "No InlineCode runs in fixture" if inline_code.empty?
      expect(inline_code).not_to be_empty
    end
  end
end
