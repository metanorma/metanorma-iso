# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"
require "zip"
require "nokogiri"

# A NOTE attached to a list is a direct child of <ul>/<ol>/<dl> in the
# source XML — a sibling of the items, not a child of the last item. The
# list renderers used to emit only their items, so the whole note — its
# text, any footnote anchor inside it, and the footnote body — vanished
# from both DOCX and MHTML output.
RSpec.describe "list-attached note with an inline footnote" do
  let(:adapter) { build_adapter }
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }

  let(:note_xml) do
    minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <ul id="ul1">
            <li><p>First item.</p></li>
            <li><p>Second item.</p></li>
            <note id="n1">
              <p>Note text with a footnote.<fn id="fn1" reference="1"><p>The footnote body survives.</p></fn></p>
            </note>
          </ul>
        </clause>
      </sections>
    INNER
  end

  it "keeps note text, anchor, and footnote body in the DOCX output" do
    dir = Dir.mktmpdir
    path = File.join(dir, "output.docx")
    adapter.convert(note_xml, path)

    document_xml = docx_entry_xml(path, "word/document.xml")
    footnotes_xml = docx_entry_xml(path, "word/footnotes.xml")

    document_text = document_xml.xpath("//w:t", ns).map(&:text).join
    expect(document_text).to include("Note text with a footnote."),
                             "the list-attached note text must survive in document.xml"

    anchor = document_xml.at_xpath("//w:footnoteReference", ns)
    expect(anchor).not_to be_nil,
                          "the footnote anchor must survive in document.xml"

    anchor_id = anchor["w:id"] || anchor[:id] || anchor.attr("w:id")
    entry = footnotes_xml.xpath("//w:footnote", ns).find do |fn|
      (fn["w:id"] || fn.attr("w:id")).to_s == anchor_id.to_s
    end
    expect(entry).not_to be_nil,
                         "the anchored footnote entry must exist in footnotes.xml"
    expect(entry.xpath(".//w:t", ns).map(&:text).join)
      .to include("The footnote body survives."),
          "the footnote body must survive in footnotes.xml"
  end

  # A NOTE attached to a sentence parses into the parent paragraph, and
  # the nested NoteBlock carries no element_order — its body is then only
  # reachable through the note's content collection. This is the shape the
  # compile produces for `NOTE:` following a paragraph, so the walker's
  # unordered fallback must reach the content paragraphs, footnotes
  # included.
  it "walks an unordered note's content paragraphs" do
    fn = Metanorma::Document::Components::Inline::FnElement.new(
      id: "fn9",
      reference: "1",
      p: [Metanorma::Document::Components::Paragraphs::ParagraphBlock.new(
        text: "Paragraph-note footnote body.",
      )],
    )
    body = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new(
      text: "Note after a sentence with a footnote.",
      fn: [fn],
    )
    note = Metanorma::Document::Components::Blocks::NoteBlock.new(
      id: "n4",
      autonum: "1",
      content: [body],
    )
    expect(note.element_order).to be_nil,
      "the spec models the nested-note shape: no element_order"

    dispatched = []
    walker = IsoDoc::Iso::Docx::Renderers::Walker.new(->(node, _doc) { dispatched << node })
    walker.walk(note, nil)

    expect(dispatched).to include(body),
      "the unordered note's content paragraph must be dispatched for rendering"
  end

  it "keeps note text, anchor, and footnote body in the MHTML (.doc) output" do
    dir = Dir.mktmpdir
    path = File.join(dir, "output.doc")
    adapter.convert(note_xml, path)

    html = Uniword::Mhtml::MhtmlPackage.from_file(path).raw_html

    expect(html).to include("Note text with a footnote."),
                    "the list-attached note text must survive in the MHTML body"
    expect(html).to include("MsoFootnoteReference"),
                    "the footnote anchor must survive in the MHTML body"
    expect(html).to include("mso-element:footnote"),
                    "the footnote-list section must carry the footnote entry"
    expect(html).to include("The footnote body survives."),
                    "the footnote body must survive in the MHTML footnote-list"
  end

  it "renders notes attached to ordered and definition lists (DOCX)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <ol id="ol1">
            <li><p>Ordered item.</p></li>
            <note id="n2"><p>Ordered-list note text.</p></note>
          </ol>
          <dl id="dl1">
            <dt>Term</dt>
            <dd>Definition</dd>
            <note id="n3"><p>Definition-list note text.</p></note>
          </dl>
        </clause>
      </sections>
    INNER

    dir = Dir.mktmpdir
    path = File.join(dir, "output.docx")
    adapter.convert(xml, path)

    document_text = docx_entry_xml(path, "word/document.xml")
      .xpath("//w:t", ns).map(&:text).join
    expect(document_text).to include("Ordered-list note text."),
                             "note attached to an ordered list must survive"
    expect(document_text).to include("Definition-list note text."),
                             "note attached to a definition list must survive"
  end

  private

  def docx_entry_xml(path, entry_name)
    Zip::File.open(path) do |zip|
      Nokogiri::XML(zip.find_entry(entry_name).get_input_stream.read)
    end
  end
end
