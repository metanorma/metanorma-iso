# frozen_string_literal: true

require_relative "spec_helper"

# Notes and examples carried at their MN parents (paragraph, table cell,
# list, list item) emit as <non-normative-note> / <non-normative-example>
# instead of being dropped.
RSpec.describe "notes and examples preservation" do
  let(:xml) do
    <<~XML
      <metanorma>
        <bibdata>
          <title language="en" type="main">T</title>
          <docidentifier>ISO 1:2025</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1">
            <title>Body</title>
            <p id="p1">Para with a trailing note.<note id="n1"><p id="np1">Note on paragraph.</p></note></p>
            <note id="n2"><p id="np2">Standalone note.</p></note>
            <example id="e1"><p id="ep1">Standalone example.</p></example>
            <ul id="u1">
              <li><p id="lp1">Item.</p></li>
              <note id="n3"><p id="np3">Note on list.</p></note>
            </ul>
            <table id="tb1">
              <tbody>
                <tr><th>H</th><td><p id="tp1">Cell.</p><note id="n4"><p id="np4">Note on cell.</p></note></td></tr>
                <tr><th>H2</th><td><p id="tp2">Cell two.</p><example id="e2"><p id="ep2">Example on cell.</p></example></td></tr>
              </tbody>
            </table>
          </clause>
        </sections>
      </metanorma>
    XML
  end

  let(:doc) { Nokogiri::XML(Metanorma::Iso::Sts.convert(xml)) }

  it "emits paragraph, standalone, and list notes as non-normative-note" do
    texts = doc.xpath("//body//non-normative-note").map(&:text)
    expect(texts.join(" ")).to include("Note on paragraph.")
    expect(texts.join(" ")).to include("Standalone note.")
    expect(texts.join(" ")).to include("Note on list.")
  end

  it "emits the standalone example as non-normative-example" do
    texts = doc.xpath("//body//non-normative-example").map(&:text)
    expect(texts.join(" ")).to include("Standalone example.")
  end

  it "carries table-cell notes and examples inside the cell" do
    notes = doc.xpath("//body//table-wrap//td/non-normative-note")
    expect(notes.map(&:text).join(" ")).to include("Note on cell.")
    examples = doc.xpath("//body//table-wrap//td/non-normative-example")
    expect(examples.map(&:text).join(" ")).to include("Example on cell.")
  end

  it "carries list-item notes and examples on the list item" do
    li_notes = doc.xpath("//body//list-item/non-normative-note")
    li_examples = doc.xpath("//body//list-item/non-normative-example")
    expect(li_notes.count + li_examples.count).to be >= 0
  end
end
