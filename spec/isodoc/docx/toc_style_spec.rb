# frozen_string_literal: true

require_relative "spec_helper"
require "zip"

# ToC paragraph styles in the shipped DIS template.
#
# The ISO ToC is not all-bold and steps its indent per level: TOC1 keeps
# its hanging layout (number at the margin, text wrap at 720 twips),
# TOC2/TOC3 add one 360-twip indent step per level.
#
# The styles carry a single tab stop: the right-hand page-number stop
# with a dot leader, positioned inside the paragraph's text area — the
# page text width (from the template's section page size and margins)
# minus the style's right indent — so the page number right-aligns at
# the right edge and the leader fills between the heading text and it.
# There are deliberately no left tab stops: a left stop that the entry
# number has already passed is skipped by Word, which then jumps to the
# page-number stop instead — carrying the entire heading text to the
# right margin behind the leader (metanorma-pdfa#119).
#
# The template DOCX is the operative source (its styles.xml is shipped
# verbatim into the output); styles.yml is the extracted mirror used by
# the style library and validators. This spec pins both in lockstep.
RSpec.describe "TOC styles in the DIS template" do
  let(:template_path) do
    IsoDoc::Iso::DocxTemplates.template_path(:dis)
  end
  let(:styles_xml) do
    Zip::File.open(template_path) do |zip|
      Nokogiri::XML(zip.find_entry("word/styles.xml").get_input_stream.read)
    end
  end
  let(:document_xml) do
    Zip::File.open(template_path) do |zip|
      Nokogiri::XML(zip.find_entry("word/document.xml").get_input_stream.read)
    end
  end
  let(:w_ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }

  # The page text width in twips, derived from the template's section
  # page size and margins.
  def page_text_width
    sect = document_xml.at_xpath("//w:sectPr", w_ns)
    width = sect.at_xpath("./w:pgSz/@w:w", w_ns).value.to_i
    left = sect.at_xpath("./w:pgMar/@w:left", w_ns).value.to_i
    right = sect.at_xpath("./w:pgMar/@w:right", w_ns).value.to_i
    width - left - right
  end

  def style(style_id)
    styles_xml.at_xpath("//w:style[@w:styleId='#{style_id}']", w_ns)
  end

  def indent(style_id)
    style(style_id).at_xpath("./w:pPr/w:ind", w_ns)
  end

  def right_tab(style_id)
    style(style_id).at_xpath("./w:pPr/w:tabs/w:tab[@w:val='right']", w_ns)
  end

  # The tab stop must sit inside the paragraph's text area: at the
  # right indent boundary, never beyond it.
  def expected_right_tab_pos(style_id)
    page_text_width - indent(style_id)["w:right"].to_i
  end

  it "does not bold TOC1" do
    expect(style("TOC1").at_xpath("./w:rPr/w:b", w_ns)).to be_nil,
      "TOC1 must not carry a blanket bold run property"
  end

  it "keeps the TOC1 hanging layout" do
    ind = indent("TOC1")
    expect(ind).not_to be_nil
    expect(ind["w:left"]).to eq("720")
    expect(ind["w:hanging"]).to eq("720")
  end

  it "indents TOC2 one step below TOC1" do
    ind = indent("TOC2")
    expect(ind).not_to be_nil
    expect(ind["w:left"]).to eq("1080")
    expect(ind["w:hanging"]).to eq("360")
  end

  it "indents TOC3 one step below TOC2" do
    ind = indent("TOC3")
    expect(ind).not_to be_nil
    expect(ind["w:left"]).to eq("1440")
    expect(ind["w:hanging"]).to eq("360")
  end

  describe "Simple-template generated output" do
    let(:generated_simple_toc_indents) do
      fixture = File.expand_path("../../fixtures/iso/is/document-en.dis.presentation.xml", __dir__)
      Dir.mktmpdir("toc-simple-") do |dir|
        output = File.join(dir, "output.docx")
        IsoDoc::Iso::Docx::Adapter.new(template: :simple).convert(fixture, output)
        generated_styles = Zip::File.open(output) do |zip|
          Nokogiri::XML(zip.find_entry("word/styles.xml").get_input_stream.read)
        end
        simple_styles = IsoDoc::Iso::Docx::StyleLibrary.load_default(template: :simple)
        %w[TOC1 TOC2 TOC3].to_h do |style_id|
          ind = generated_styles.at_xpath(
            "//w:style[@w:styleId='#{style_id}']/w:pPr/w:ind", w_ns
          )
          yaml_indent = simple_styles.definition_for(style_id)
            .dig("paragraph_properties", "indent")
          [style_id, [ind&.[]("w:left"), ind&.[]("w:hanging"),
                      yaml_indent["left"], yaml_indent["hanging"]]]
        end
      end
    end

    it "preserves stepped TOC indents and matches styles.yml" do
      expect(generated_simple_toc_indents).to eq(
        "TOC1" => ["720", "720", "1.27", "1.27"],
        "TOC2" => ["1080", "360", "1.905", "0.635"],
        "TOC3" => ["1440", "360", "2.54", "0.635"],
      )
    end
  end

  it "carries no bold anywhere in the TOC1-TOC3 style cascade" do
    %w[TOC1 TOC2 TOC3].each do |style_id|
      expect(style(style_id).at_xpath(".//w:b", w_ns)).to be_nil,
        "#{style_id} inherits or defines bold — the ToC must not be all-bold"
    end
  end

  # The ToC field collects outline levels 1-3 (\o "1-3"), so an outline
  # level on the part-title styles lists "Part 1: ..." above Scope once
  # Word updates the field (metanorma-iso#1842).
  %w[MainTitle1 MainTitle2 MainTitle3].each do |style_id|
    it "keeps #{style_id} out of the document outline" do
      expect(style(style_id).at_xpath("./w:pPr/w:outlineLvl", w_ns)).to be_nil
    end

    it "keeps #{style_id} out of the outline in styles.yml" do
      expect(IsoDoc::Iso::Docx::StyleLibrary.load_default.definition_for(style_id)
        .dig("paragraph_properties", "outline_level")).to be_nil
    end
  end

  describe "page-number tab stop" do
    %w[TOC1 TOC2 TOC3].each do |style_id|
      it "#{style_id} carries a single right tab stop with a dot leader" do
        tabs = style(style_id).xpath("./w:pPr/w:tabs/w:tab", w_ns)
        expect(tabs.length).to eq(1)
        expect(right_tab(style_id)["w:leader"]).to eq("dot")
      end

      it "#{style_id} positions the page-number tab inside the text area" do
        tab = right_tab(style_id)
        expect(tab).not_to be_nil
        pos = tab["w:pos"].to_i
        expect(pos).to eq(expected_right_tab_pos(style_id)),
          "#{style_id} page-number tab must sit at the right indent " \
          "boundary (text width #{page_text_width} minus right indent)"
        expect(pos).to be_positive
        expect(pos).to be < page_text_width
      end

      it "#{style_id} carries no left tab stops" do
        left = style(style_id).xpath("./w:pPr/w:tabs/w:tab[@w:val='left']", w_ns)
        expect(left).to be_empty,
          "#{style_id} left tab stops make Word skip past an overshot " \
          "number into the page-number stop (metanorma-pdfa#119)"
      end
    end
  end

  describe "styles.yml mirror" do
    let(:library) do
      IsoDoc::Iso::Docx::StyleLibrary.load_default
    end

    def yaml_style(id)
      library.definition_for(id)
    end

    it "records TOC1 as non-bold" do
      bold = yaml_style("TOC1").dig("run_properties", "bold")
      expect(bold).not_to be(true)
    end

    it "mirrors the template indent steps" do
      {
        "TOC1" => ["720", "720"],
        "TOC2" => ["1080", "360"],
        "TOC3" => ["1440", "360"],
      }.each do |style_id, (left, hanging)|
        props = yaml_style(style_id)["paragraph_properties"]
        indent = props&.fetch("indent", nil)
        expect(indent).not_to be_nil,
          "styles.yml #{style_id} carries no indent"
        expect(indent["left"]).to eq(left)
        expect(indent["hanging"]).to eq(hanging)
      end
    end

    it "mirrors the page-number tab stop of the template" do
      %w[TOC1 TOC2 TOC3].each do |style_id|
        props = yaml_style(style_id)["paragraph_properties"]
        tabs = props["tabs"] || []
        expect(tabs.length).to eq(1),
          "styles.yml #{style_id} must carry exactly the page-number tab stop"
        tab = tabs.first
        expect(tab["type"]).to eq("right")
        expect(tab["leader"]).to eq("dot")
        expect(tab["position"].to_s).to eq(expected_right_tab_pos(style_id).to_s),
          "styles.yml #{style_id} tab position must match the template " \
          "(text width minus right indent)"
      end
    end
  end
end
