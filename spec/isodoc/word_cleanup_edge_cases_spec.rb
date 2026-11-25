# frozen_string_literal: true

require_relative "../spec_helper"
require "nokogiri"

RSpec.describe "Word cleanup edge cases" do # rubocop:disable RSpec/DescribeClass
  let(:converter) { IsoDoc::Iso::WordConvert.allocate }

  def xml(body)
    Nokogiri::XML("<html><body>#{body}</body></html>")
  end

  context "when a definition is a list" do
    %w[ol_wrap ul_wrap].each do |wrap|
      it "adds the term gap to the first item of #{wrap}" do
        doc = xml("<p class='Terms'>term</p><div class='#{wrap}'><ul><li><p id='a'>one</p></li>" \
                  "<li><p id='b'>two</p></li></ul></div>")
        converter.send(:definition_spacing, doc)
        expect(doc.xpath("//li/p").map { |para| para["style"] }).to eq(["margin-top:12.0pt;", nil])
      end
    end

    it "leaves a list that does not follow a designation" do
      doc = xml("<p class='Definition'>text</p><div class='ul_wrap'><ul>" \
                "<li><p id='a'>one</p></li></ul></div>")
      converter.send(:definition_spacing, doc)
      expect(doc.at("//p[@id='a']")["style"]).to be_nil
    end
  end

  context "when a definition has an unusual style" do
    it "does not start an empty style with a semicolon" do
      doc = xml("<p class='Terms'>term</p><p class='Definition' style=''>x</p>")
      converter.send(:definition_spacing, doc)
      expect(doc.at("//p[@class='Definition']")["style"]).to eq("margin-top:12.0pt;")
    end

    it "does not add the gap twice" do
      doc = xml("<p class='Terms'>term</p><p class='Definition'>x</p>")
      2.times { converter.send(:definition_spacing, doc) }
      expect(doc.at("//p[@class='Definition']")["style"]).to eq("margin-top:12.0pt;")
    end
  end

  context "when spacing footnote text" do
    def spaced(note)
      doc = xml("<a class='FootnoteRef' href='#n'>1</a><aside id='n'>#{note}</aside>")
      converter.send(:footnote_anchor_space, doc)
      doc.at("//aside/p")
    end

    it "adds a space before a leading image" do
      expect(spaced("<p><img src='a.png'/> text</p>").children.first.text).to eq(" ")
    end

    it "keeps an existing leading space" do
      expect(spaced("<p> text</p>").text).to eq(" text")
    end

    it "adds one space to plain text" do
      expect(spaced("<p>text</p>").text).to eq(" text")
    end

    it "ignores an empty link target" do
      doc = xml("<a class='FootnoteRef' href='#'>1</a><p id=''>text</p>")
      converter.send(:footnote_anchor_space, doc)
      expect(doc.at("//p").text).to eq("text")
    end

    it "spaces a note once when two references share it" do
      doc = xml("<a class='FootnoteRef' href='#n'>1</a>" \
                "<a class='FootnoteRef' href='#n'>1</a>" \
                "<aside id='n'><p>text</p></aside>")
      converter.send(:footnote_anchor_space, doc)
      expect(doc.at("//aside/p").text).to eq(" text")
    end
  end

  context "when a DIS footnote starts with a list" do
    let(:html2doc) { Html2Doc::IsoDIS.allocate }

    def cleaned(para)
      doc = xml("<div style='mso-element:footnote'><a href='#x'>1</a>#{para}</div>")
      html2doc.footnote_cleanup(doc)
      doc.at("//div/p").children.map { |node| node.name == "a" ? "[a]" : node.text }.join
    end

    it "puts the space before the list label" do
      para = "<p>&#x2014;<span style='mso-tab-count:1'>&#xa0;</span> list start</p>"
      expect(cleaned(para)).to eq("[a] — list start")
    end

    it "leaves ordinary footnote text alone" do
      expect(cleaned("<p> plain text</p>")).to eq("[a] plain text")
    end
  end

  context "when an annex has hidden ToC title variants" do
    it "removes every variant after the annex heading" do
      doc = xml("<div><h1 class='Annex'>A</h1>" \
                "<p class='variant-title-toc'>one</p>" \
                "<p class='variant-title-toc'>two</p><p>body</p></div>")
      converter.send(:remove_toc_variants, doc)
      expect(doc.xpath("//p").map(&:text)).to eq(["body"])
    end

    it "removes the variant before an untitled annex" do
      doc = xml("<div><p class='variant-title-toc'>Annex C</p>" \
                "<p class='ANNEX'>Annex C</p></div>")
      converter.send(:remove_toc_variants, doc)
      expect(doc.xpath("//p").map { |para| para["class"] }).to eq(["ANNEX"])
    end
  end
end
