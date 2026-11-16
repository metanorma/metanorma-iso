# frozen_string_literal: true

require_relative "spec_helper"
require "zip"
require "nokogiri"

# Template metrics: the template.docx style definitions mirror the
# iso.international-standard.xsl (PDF) layout contract, so DOCX line
# and page breaks land close to the PDF (metanorma-pdfa#117).
#
# XSL contract (2024 layout):
#   p-style     — margin-bottom 8pt, line-height 1.13 (11pt body → 12.43pt)
#   title-style — 13/12/11pt bold, space-before 18/12/14pt, space-after 8pt
#                 (level 3: 9pt), line-height normal (≈1.001em in FOP)
#   note-p-style    — margin-top 8pt, margin-bottom 12pt
#   example-p-style — margin-top 8pt, margin-bottom 8pt
#   example-body-style — 7mm indent left + right
RSpec.describe "template.docx XSL-aligned metrics" do
  let(:template_path) do
    IsoDoc::Iso::DocxTemplates.template_path(:dis)
  end
  let(:styles_xml) do
    Zip::File.open(template_path) do |z|
      Nokogiri::XML(z.find_entry("word/styles.xml").get_input_stream.read)
    end
  end
  let(:w_ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:styles_yml) do
    YAML.load_file(
      File.join(IsoDoc::Iso::DocxTemplates.config_dir(:dis), "styles.yml")
    )
  end

  def spacing(style_id)
    style = styles_xml.at_xpath("//w:style[@w:styleId='#{style_id}']", w_ns)
    style.at_xpath("w:pPr/w:spacing", w_ns)
  end

  def spacing_attr(style_id, attr)
    spacing(style_id)&.[]("w:#{attr}")
  end

  def indent_attr(style_id, attr)
    style = styles_xml.at_xpath("//w:style[@w:styleId='#{style_id}']", w_ns)
    style.at_xpath("w:pPr/w:ind", w_ns)&.[]("w:#{attr}")
  end

  def yml_spacing(style_id)
    styles_yml.dig("style_library", "paragraph_styles", style_id,
                   "paragraph_properties", "spacing")
  end

  def yml_indent(style_id)
    styles_yml.dig("style_library", "paragraph_styles", style_id,
                   "paragraph_properties", "indent")
  end

  def assert_spacing(style_id, before: nil, after:, line:, rule:)
    expect(spacing_attr(style_id, "after")).to eq(after),
      "#{style_id} w:after should be #{after} (XSL margin-bottom), " \
      "got #{spacing_attr(style_id, 'after').inspect}"
    expect(spacing_attr(style_id, "line")).to eq(line),
      "#{style_id} w:line should be #{line} (XSL line-height), " \
      "got #{spacing_attr(style_id, 'line').inspect}"
    expect(spacing_attr(style_id, "lineRule")).to eq(rule),
      "#{style_id} w:lineRule should be #{rule}, got #{spacing_attr(style_id, 'lineRule').inspect}"
    if before
      expect(spacing_attr(style_id, "before")).to eq(before),
        "#{style_id} w:before should be #{before} (XSL space-before), " \
        "got #{spacing_attr(style_id, 'before').inspect}"
    end
  end

  it "mirrors the XSL body metrics in Normal (margin-bottom 8pt, line-height 1.13)" do
    assert_spacing("Normal", after: "160", line: "249", rule: "exact")
  end

  it "mirrors the XSL body metrics in BaseText" do
    assert_spacing("BaseText", after: "160", line: "249", rule: "exact")
  end

  it "mirrors the XSL H1 metrics in Heading1 (18pt before, 8pt after, 15.6pt line)" do
    assert_spacing("Heading1", before: "360", after: "160", line: "312", rule: "exact")
  end

  it "mirrors the XSL H2 metrics in Heading2 (12pt before, 8pt after)" do
    assert_spacing("Heading2", before: "240", after: "160", line: "312", rule: "exact")
  end

  it "mirrors the XSL H3 metrics in Heading3 (14pt before, 9pt after)" do
    assert_spacing("Heading3", before: "280", after: "180", line: "288", rule: "exact")
  end

  it "mirrors the XSL note paragraph spacing (12pt bottom, 12pt line, no top margin)" do
    assert_spacing("Note", before: "0", after: "240", line: "240", rule: "exact")
  end

  it "mirrors the XSL example paragraph spacing (8pt bottom, 12pt line, no top margin)" do
    assert_spacing("Example", before: "0", after: "160", line: "240", rule: "exact")
  end

  it "renders note bodies full width (XSL note has no body indent)" do
    expect(indent_attr("Noteindent", "left")).to be_nil,
      "Noteindent should not carry a left indent (XSL note body is full width)"
    assert_spacing("Noteindent", before: "0", after: "240", line: "240", rule: "exact")
  end

  it "indents example bodies 7mm on both sides (XSL example-body-style)" do
    expect(indent_attr("Exampleindent", "left")).to eq("397"),
      "Exampleindent left should be 397 twips (7mm), got #{indent_attr('Exampleindent', 'left').inspect}"
    expect(indent_attr("Exampleindent", "right")).to eq("397"),
      "Exampleindent right should be 397 twips (7mm), got #{indent_attr('Exampleindent', 'right').inspect}"
    assert_spacing("Exampleindent", before: "0", after: "160", line: "240", rule: "exact")
  end

  it "keeps natural leading on cover styles that inherit Normal" do
    %w[MainTitle1 MainTitle2 MainTitle3 release-version zzCover zzCopyright
       Warningtext Warningtitle].each do |style_id|
      expect(spacing_attr(style_id, "lineRule")).to eq("auto"),
        "#{style_id} must pin lineRule=auto so the tightened Normal leading does not distort it"
    end
  end

  describe "styles.yml mirror" do
    it "agrees with the template on every tuned style" do
      %w[Normal BaseText BaseHeading Heading1 Heading2 Heading3
         Note Example Noteindent Noteindentcontinued
         Exampleindent Exampleindentcontinued].each do |style_id|
        yml = yml_spacing(style_id)
        expect(yml).not_to be_nil, "styles.yml missing spacing for #{style_id}"

        expect(yml["after"]).to eq(spacing_attr(style_id, "after")),
          "styles.yml #{style_id} after disagrees with template"
        expect(yml["line"]).to eq(spacing_attr(style_id, "line")),
          "styles.yml #{style_id} line disagrees with template"
        expect(yml["line_rule"]).to eq(spacing_attr(style_id, "lineRule")),
          "styles.yml #{style_id} line_rule disagrees with template"
        if (yml_before = yml["before"])
          expect(yml_before).to eq(spacing_attr(style_id, "before")),
            "styles.yml #{style_id} before disagrees with template"
        end
      end
    end

    it "drops the Noteindent left indent in the mirror" do
      expect(yml_indent("Noteindent")).to be_nil,
        "styles.yml Noteindent should have no indent block"
    end

    it "records the 7mm example body indent in the mirror" do
      indent = yml_indent("Exampleindent")
      expect(indent).to eq({ "left" => "397", "right" => "397" })
    end
  end
end
