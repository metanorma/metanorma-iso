# frozen_string_literal: true

require_relative "spec_helper"
require "zip"

# ToC paragraph styles in the shipped DIS template.
#
# The ISO ToC is not all-bold and steps its indent per level: TOC1 keeps
# its hanging layout (number at the margin, text wrap at 720 twips),
# TOC2/TOC3 add one 360-twip indent step per level with a matching left
# tab stop, so the entry number starts one step deeper than the previous
# level and the title aligns at the wrap point.
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
  let(:w_ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }

  def style(style_id)
    styles_xml.at_xpath("//w:style[@w:styleId='#{style_id}']", w_ns)
  end

  def indent(style_id)
    style(style_id).at_xpath("./w:pPr/w:ind", w_ns)
  end

  def left_tab_pos(style_id)
    style(style_id).at_xpath(
      "./w:pPr/w:tabs/w:tab[@w:val='left']/@w:pos", w_ns,
    )&.to_s
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
    expect(left_tab_pos("TOC2")).to eq("1080")
  end

  it "indents TOC3 one step below TOC2" do
    ind = indent("TOC3")
    expect(ind).not_to be_nil
    expect(ind["w:left"]).to eq("1440")
    expect(ind["w:hanging"]).to eq("360")
    expect(left_tab_pos("TOC3")).to eq("1440")
  end

  it "carries no bold anywhere in the TOC1-TOC3 style cascade" do
    %w[TOC1 TOC2 TOC3].each do |style_id|
      expect(style(style_id).at_xpath(".//w:b", w_ns)).to be_nil,
        "#{style_id} inherits or defines bold — the ToC must not be all-bold"
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
        tabs = props["tabs"] || []
        left_tab = tabs.find { |t| t["type"] == "left" }
        expect(left_tab&.fetch("position")).to eq(left),
          "styles.yml #{style_id} left tab stop must match the indent"
      end
    end
  end
end
