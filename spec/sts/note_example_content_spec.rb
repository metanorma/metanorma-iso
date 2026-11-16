# frozen_string_literal: true

require_relative "spec_helper"

# Notes and examples keep their body on typed attributes (content /
# paragraphs / ul / ol / sourcecode); walking mixed content yields
# nothing and emits empty <non-normative-note/> / <non-normative-example/>
# elements, losing the text.
RSpec.describe "Note and example content" do
  let(:xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">
          <title language="en" type="main">Test</title>
          <docidentifier>ISO 9999</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1"><title>Scope</title>
            <note id="_n1"><p id="np1">Note text.</p></note>
            <example id="_e1"><p id="ep1">Example text.</p></example>
            <example id="_e2">
              <p id="ep2">Listed example.</p>
              <ul id="eul1"><li><p id="elp1">bullet one</p></li></ul>
              <sourcecode id="esc1">puts "code"</sourcecode>
            </example>
          </clause>
        </sections>
      </metanorma>
    XML
  end

  let(:sts) { Metanorma::Iso::Sts.convert(xml) }
  let(:doc) { Nokogiri::XML(sts) }

  it "carries note paragraphs into non-normative-note" do
    note = doc.at_xpath("//non-normative-note")
    expect(note.at_xpath("./p")&.text).to include("Note text.")
  end

  it "carries example paragraphs into non-normative-example" do
    example = doc.xpath("//non-normative-example").first
    expect(example.at_xpath("./p")&.text).to include("Example text.")
  end

  it "carries example lists and sourcecode" do
    example = doc.xpath("//non-normative-example")[1]
    expect(example.at_xpath("./list/list-item/p")&.text).to include("bullet one")
    expect(example.at_xpath("./preformat")&.text).to include("code")
  end

  it "emits no empty note or example shells" do
    doc.xpath("//non-normative-note | //non-normative-example").each do |node|
      expect(node.element_children).not_to be_empty
    end
  end
end
