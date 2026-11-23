# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../../../support/contained_docx_helper"

RSpec.describe "DOCX tables in table-cell containers", type: :feature do
  include ContainedDocxHelper

  let(:inner_table) do
    '<table id="inner"><tbody><tr><td>deep</td></tr></tbody></table>'
  end
  let(:xml) do
    minimal_iso_xml(<<~XML)
      <sections><clause id="scope"><title>Scope</title>
        <table id="outer"><tbody><tr><td>
          #{container}
          <p>Following paragraph.</p>
          <note><p>Preserved note.</p></note>
          <example><fmt-name>EXAMPLE</fmt-name><p>Simple example.</p></example>
          <ul><li><p>Simple bullet.</p></li></ul>
        </td></tr></tbody></table>
      </clause></sections>
    XML
  end
  let(:outer) { converted_contained_table(xml) }
  let(:texts) { outer.xpath(".//w:p", contained_ns).map(&:text) }

  {
    "unordered list" => "<ul><li><p>Intro.</p>%s<p>After.</p></li></ul>",
    "ordered list" => "<ol><li><p>Intro.</p>%s<p>After.</p></li></ol>",
    "bare list item" => "<ul><li>Intro.%s<p>After.</p></li></ul>",
    "bare example" => "<example>Intro.%s<p>After.</p></example>",
    "example" => "<example><fmt-name>EXAMPLE 1</fmt-name><p>Intro.</p>%s<p>After.</p></example>",
    "definition list" => "<dl><dt>Term</dt><dd><p>Intro.</p>%s<p>After.</p></dd></dl>",
    "direct cell" => "<p>Intro.</p>%s<p>After.</p>",
  }.each do |name, markup|
    context "with a table inside a #{name}" do
      let(:container) { format(markup, inner_table) }

      it "retains the table and its text exactly once" do
        expect([outer.xpath(".//w:tbl", contained_ns).size,
                outer.xpath(".//w:t[text()='deep']", contained_ns).size]).to eq([1, 1])
      end

      it "preserves the paragraph and table order" do
        sequence = ["Intro.", "deep", "After."]
        expect(texts.select { |text| sequence.include?(text) }).to eq(sequence)
      end

      it "preserves following simple cell content" do
        expect(texts).to include(
          "Following paragraph.", "Preserved note.", "EXAMPLESimple example.", "Simple bullet."
        )
      end

      it "ends every cell in a paragraph" do
        expect(outer.xpath(".//w:tc", contained_ns).map { |cell| cell.element_children.last.name }.uniq).to eq(["p"])
      end
    end
  end

  context "with a table-first list item" do
    let(:container) { "<ul><li>#{inner_table}<p>After.</p></li></ul>" }

    it "keeps the table before the following paragraph without duplicating text" do
      expect(texts.reject(&:empty?).first(2)).to eq(["deep", "After."])
    end
  end

  context "with a paragraph-free list item" do
    let(:container) { "<ul><li>#{inner_table}</li></ul>" }

    it "renders the table text exactly once" do
      expect(outer.xpath(".//w:t[text()='deep']", contained_ns).size).to eq(1)
    end
  end

  context "with a labelled example containing a table" do
    let(:container) { "<example><fmt-name>EXAMPLE 1</fmt-name>#{inner_table}</example>" }

    it "retains the example label before the table" do
      expect(texts.reject(&:empty?).first(2)).to eq(["EXAMPLE 1", "deep"])
    end
  end

  context "with three sibling tables in an example" do
    let(:container) { "<example>#{inner_table * 3}</example>" }

    it "keeps the tables separate with intervening paragraphs" do
      names = outer.at_xpath("w:tr/w:tc", contained_ns).element_children.map(&:name)
      expect(names.first(6)).to eq(%w[tcPr tbl p tbl p tbl])
    end
  end
end
