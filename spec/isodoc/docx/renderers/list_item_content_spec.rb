# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe "List item content and depth styles" do
  let(:adapter) { build_adapter }

  def body_paragraphs(xml)
    convert_and_extract(adapter, xml) do |pkg|
      return pkg.document.body.paragraphs.map do |p|
        num = p.properties&.numbering_properties
        [para_style_value(p), p.runs.map { |r| run_text(r) }.join,
         num&.num_id&.value, num&.ilvl&.value]
      end
    end
  end

  def clause(inner)
    minimal_iso_xml(<<~X)
      <sections><clause id="c1"><title>Scope</title>#{inner}</clause></sections>
    X
  end

  it "renders a nested ordered list with level 2 style and no numPr" do
    rows = body_paragraphs(clause(<<~X))
      <ol id="o1"><li><fmt-name>a)</fmt-name><p>Outer.</p>
        <ol id="o2"><li><fmt-name>1)</fmt-name><p>Inner.</p></li></ol></li></ol>
    X
    outer = rows.find { |r| r[1].end_with?("Outer.") }
    inner = rows.find { |r| r[1].end_with?("Inner.") }
    expect(outer[0]).to eq("ListNumber1")
    expect(outer[3]).to be_nil
    expect(inner[0]).to eq("ListNumber2")
    expect(inner[3]).to be_nil
  end

  it "renders a bullet list nested in an ordered item at depth 2" do
    rows = body_paragraphs(clause(<<~X))
      <ol id="o1"><li><p>Outer.</p>
        <ul id="u1"><li><p>Bullet.</p></li></ul></li></ol>
    X
    expect(rows.find { |r| r[1] == "Bullet." }[0]).to eq("ListContinue2")
  end

  it "renders a nested bullet list with ListContinue2" do
    rows = body_paragraphs(clause(<<~X))
      <ul id="u1"><li><p>Top.</p>
        <ul id="u2"><li><p>Sub.</p></li></ul></li></ul>
    X
    expect(rows.find { |r| r[1] == "Top." }[0]).to eq("ListContinue1")
    expect(rows.find { |r| r[1] == "Sub." }[0]).to eq("ListContinue2")
  end

  it "returns to level 1 for a list after a nested list" do
    rows = body_paragraphs(clause(<<~X))
      <ol id="o1"><li><p>A.</p><ol id="o2"><li><p>A1.</p></li></ol></li>
        <li><p>B.</p></li></ol>
    X
    expect(rows.map { |r| r[1] }).to include("A.", "A1.", "B.")
    expect(rows.find { |r| r[1] == "B." }[0]).to eq("ListNumber1")
  end

  it "keeps item block content (note, second paragraph) in document order" do
    rows = body_paragraphs(clause(<<~X))
      <ul id="u1"><li><p>Item text.</p>
        <note id="n1"><p>Inside note.</p></note>
        <p>Second para.</p></li></ul>
    X
    texts = rows.map { |r| r[1] }
    expect(texts.index { |t| t.include?("Item text.") })
      .to be < texts.index { |t| t.include?("Inside note.") }
    expect(texts.index { |t| t.include?("Inside note.") })
      .to be < texts.index { |t| t.include?("Second para.") }
  end

  it "renders a formula inside a list item" do
    rows = body_paragraphs(clause(<<~X))
      <ol id="o1"><li><p>See:</p>
        <formula id="f1"><stem type="AsciiMath"><asciimath>x</asciimath></stem></formula>
      </li></ol>
    X
    lead = rows.index { |r| r[1] == "See:" }
    expect(rows[lead + 1]).not_to be_nil
  end
end
