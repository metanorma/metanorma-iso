# frozen_string_literal: true

require_relative "../spec_helper"

# Integration assertions pair changed content with single-paragraph preservation.
# The label's tab separator has no w:t text, so a label and its body join
# directly in these text extractions; label_separator_spec asserts the tab.
# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations, RSpec/SpecFilePathFormat

RSpec.describe IsoDoc::Iso::Docx::Renderers::NoteRenderer do
  let(:adapter) { build_adapter }

  it "keeps term-note paragraphs separate and preserves a single paragraph" do
    xml = minimal_iso_xml(<<~XML)
      <sections><terms id="terms"><title>Terms</title><term id="t">
        <fmt-name>3.1</fmt-name><termnote id="tn"><fmt-name>Note 1 to entry:</fmt-name><p>Para A.</p><p>Para B.</p></termnote>
        <termnote id="single"><fmt-name>Note 2 to entry:</fmt-name><p>Single <strong>bold</strong>.</p></termnote>
      </term></terms></sections>
    XML
    convert_and_extract(adapter, xml) do |pkg|
      texts = pkg.document.body.paragraphs.map { |p| p.runs.map { |r| run_text(r) }.join }
      expect(texts.grep(/Para [AB]/)).to eq(["Note 1 to entry: Para A.", "Para B."])
      expect(texts.grep(/Single/)).to eq(["Note 2 to entry: Single bold."])
    end
  end

  it "keeps cell-note paragraphs separate and preserves its single paragraph" do
    xml = minimal_iso_xml(<<~XML)
      <sections><clause id="c"><title>Scope</title><table id="t"><tbody><tr><td>
        <note id="n"><fmt-name>NOTE 1</fmt-name><p>Para A.</p><p>Para B.</p></note>
        <note id="single"><fmt-name>NOTE 2</fmt-name><p>Single <strong>bold</strong>.</p></note>
      </td></tr></tbody></table></clause></sections>
    XML
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(xml, path)
      extract_docx(path) do |doc, ns|
        texts = doc.xpath("//w:tc//w:p", ns).map { |p| p.xpath(".//w:t", ns).map(&:text).join }
        expect(texts.grep(/Para [AB]/)).to eq(["NOTE 1Para A.", "Para B."])
        expect(texts.grep(/Single/)).to eq(["NOTE 2Single bold."])
      end
    end
  end

  it "keeps a NOTE inside a list item, including its body" do
    xml = minimal_iso_xml(<<~XML)
      <sections><clause id="c"><title>Scope</title><ul><li><p>Item.<note id="n"><fmt-name>NOTE</fmt-name><p>Note body.</p><ul><li><p>Inside list.</p></li></ul><p>Note tail.</p></note>After note.</p></li></ul></clause></sections>
    XML
    convert_and_extract(adapter, xml) do |pkg|
      texts = pkg.document.body.paragraphs.map { |p| p.runs.map { |r| run_text(r) }.join }
      expect(texts.grep(/Item\.|Note body|Inside list|Note tail|After note/)).to eq(["Item.", "NOTENote body.", "Inside list.", "Note tail.", "After note."])
    end
  end

  it "retains term-note lists, tables, and nested examples in order without duplicates" do
    xml = minimal_iso_xml(<<~XML)
      <sections><terms id="terms"><title>Terms</title><term id="t"><fmt-name>3.1</fmt-name>
        <termnote id="n"><fmt-name>Note 1 to entry:</fmt-name><p>Before.</p>
          <ul><li><p>Listed.</p></li></ul>
          <table id="nt"><tbody><tr><td><p>Cell.</p></td></tr></tbody></table>
          <example id="e"><fmt-name>EXAMPLE</fmt-name><p>Nested.</p></example><p>After.</p>
        </termnote>
      </term></terms></sections>
    XML
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(xml, path)
      extract_docx(path) do |doc, ns|
        texts = doc.xpath("//w:body//w:p", ns).map { |p| p.xpath(".//w:t", ns).map(&:text).join }
        expect(texts.grep(/Before\.|Listed\.|Cell\.|Nested\.|After\./))
          .to eq(["Before.", "Listed.", "Cell.", "EXAMPLENested.", "After."])
      end
    end
  end

  it "retains images and semx-wrapped tables inside clause notes" do
    xml = minimal_iso_xml(<<~XML)
      <sections><clause id="c"><title>Scope</title>
        <note id="n"><fmt-name>NOTE</fmt-name><p>Before.</p>
          <figure id="f"><image src="spec/assets/rice_image1.png" mimetype="image/png" width="100" height="100"/></figure>
          <semx element="note"><table id="nt"><tbody><tr><td><p>Wrapped cell.</p></td></tr></tbody></table></semx>
          <example id="e"><fmt-name>EXAMPLE</fmt-name><p>Nested.</p></example><p>After.</p>
        </note>
      </clause></sections>
    XML
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(xml, path)
      extract_docx(path) do |doc, ns|
        expect(doc.xpath("//w:body//w:drawing", ns).size).to eq(1)
        texts = doc.xpath("//w:body//w:p", ns).map { |p| p.xpath(".//w:t", ns).map(&:text).join }
        expect(texts.grep(/Before\.|Wrapped cell\.|Nested\.|After\./))
          .to eq(["Before.", "Wrapped cell.", "EXAMPLENested.", "After."])
      end
    end
  end

  it "retains a cell note label when its first block is a list" do
    xml = minimal_iso_xml(<<~XML)
      <sections><clause id="c"><title>Scope</title><table id="t"><tbody><tr><td>
        <note id="n"><fmt-name>NOTE 1</fmt-name><ul><li><p>Listed.</p></li></ul><p>After.</p></note>
      </td></tr></tbody></table></clause></sections>
    XML
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(xml, path)
      extract_docx(path) do |doc, ns|
        texts = doc.xpath("//w:tc//w:p", ns).map { |p| p.xpath(".//w:t", ns).map(&:text).join }
        expect(texts.reject(&:empty?)).to eq(["NOTE 1", "Listed.", "After."])
      end
    end
  end

  it "retains images, nested examples and tables in a cell note in order" do
    xml = minimal_iso_xml(<<~XML)
      <sections><clause id="c"><title>Scope</title><table id="outer"><tbody><tr><td>
        <note id="n"><fmt-name>NOTE</fmt-name><p>Before.</p>
          <figure id="f"><image src="spec/assets/rice_image1.png" mimetype="image/png" width="100" height="100"/></figure>
          <example id="e"><fmt-name>EXAMPLE</fmt-name><p>Nested.</p><p>Example tail.</p></example>
          <table id="inner"><tbody><tr><td><p>Inner cell.</p></td></tr></tbody></table><p>After.</p>
        </note>
      </td></tr></tbody></table></clause></sections>
    XML
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      adapter.convert(xml, path)
      extract_docx(path) do |doc, ns|
        expect(doc.xpath("//w:tc//w:drawing", ns).size).to eq(1)
        expect(doc.xpath("//w:tc/w:tbl", ns).size).to eq(1)
        texts = doc.xpath("//w:tc//w:p", ns).map { |p| p.xpath(".//w:t", ns).map(&:text).join }
        expect(texts.grep(/Before\.|Nested\.|Example tail\.|Inner cell\.|After\./))
          .to eq(["NOTEBefore.", "EXAMPLENested.", "Example tail.", "Inner cell.", "After."])
      end
    end
  end
end

# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations, RSpec/SpecFilePathFormat
