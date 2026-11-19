# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"

# Cards P1-008/P1-009: ids on notes, lists, list items, definition-list
# entries, quotes, admonitions, examples and term notes/definitions must
# survive as Word bookmarks, with names unique and within Word's 40
# character limit. Only the xref targets used to be bookmarked.
RSpec.describe "DOCX bookmarks for note, list, dl, quote and term blocks" do
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:long_id) { "id-#{'x' * 45}" }

  let(:xml) do
    minimal_iso_xml(<<~XML)
      <sections>
        <clause id="c1"><title>Scope</title>
          <p id="lead">Lead.</p>
          <ul id="ul1"><li id="li1"><p id="lip1">First</p></li>
            <li id="li2"><p id="lip2">Second</p></li></ul>
          <note id="note1"><p id="notep1">A note.</p></note>
          <example id="ex1"><p id="exp1">An example.</p></example>
          <quote id="q1"><p id="qp1">Quoted.</p></quote>
          <admonition id="adm1" type="warning"><p id="admp1">Careful.</p></admonition>
          <dl id="dl1"><dt id="dt1">A</dt><dd id="dd1"><p id="ddp1">Alpha</p></dd></dl>
          <p id="#{long_id}">Too long a name for Word.</p>
        </clause>
      </sections>
    XML
  end

  let(:names) do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) do |zip|
        Nokogiri::XML(zip.read("word/document.xml"))
          .xpath("//w:bookmarkStart/@w:name", ns).map(&:value)
      end
    end
  end

  %w[ul1 li1 lip1 li2 lip2 note1 notep1 ex1 exp1 q1 qp1 adm1 admp1
     dl1 dt1 dd1 ddp1].each do |id|
    it "bookmarks #{id}" do
      expect(names).to include(id)
    end
  end

  it "keeps every bookmark name unique" do
    expect(names).to eq(names.uniq)
  end

  it "emits no bookmark name over Word's 40 character limit" do
    expect(names.map(&:length).max).to be <= 40
  end

  it "skips an id Word would reject instead of truncating it" do
    expect(names).not_to include(long_id)
  end
end
