# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"

# Locks in the classification of the rice hyperlink gap (cards P1-008/P1-009):
# every internal xref/eref in the presentation XML becomes exactly one
# internal hyperlink to an existing bookmark. The reference rice.docx links
# that have no counterpart (table1a..d, tableD-1a, figureC-1a, IEC61010-2)
# are Word-authored bookmarks of the 2016 CD edition with no source target.
NS = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }.freeze

RSpec.describe "Rice DOCX cross-reference hyperlinks" do
  let(:parts) do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "rice.docx")
      build_adapter.convert(File.read("spec/examples/rice.presentation.xml"), path)
      Zip::File.open(path) do |zip|
        %w[word/document.xml word/footnotes.xml].to_h { |n| [n, Nokogiri::XML(zip.read(n))] }
      end
    end
  end
  let(:document) { parts["word/document.xml"] }

  let(:source_targets) do
    Nokogiri::XML(File.read("spec/examples/rice.presentation.xml")).tap(&:remove_namespaces!)
      .xpath("//fmt-xref|//fmt-eref").filter_map { |e| e["target"] }
      .grep_v(%r{\A(https?:|mailto:)}).tally
  end
  let(:anchors) do
    document.xpath("//w:hyperlink/@w:anchor", NS).map(&:value).reject { |a| a.start_with?("_Toc") }.tally
  end
  let(:bookmark_names) { document.xpath("//w:bookmarkStart/@w:name", NS).map(&:value) }

  it "emits one internal hyperlink per source xref/eref target" do
    expect(anchors).to eq(source_targets)
  end

  it "points every hyperlink anchor at an existing bookmark" do
    expect(document.xpath("//w:hyperlink/@w:anchor", NS).map(&:value) - bookmark_names).to be_empty
  end

  it "keeps bookmark names unique" do
    expect(bookmark_names).to eq(bookmark_names.uniq)
  end

  # rice.docx keeps table footnotes inside the table, as in ISO's own output:
  # no Word footnote reference in a table, bodies in the table's last row.
  it "keeps table footnotes out of the Word footnotes" do
    expect(document.xpath("//w:tbl//w:footnoteReference", NS)).to be_empty
    expect(parts["word/footnotes.xml"].text).not_to include("Organic extraneous matter")
  end

  it "puts the table footnote bodies in the last row of their tables" do
    last_rows = document.xpath("//w:tbl/w:tr[last()]", NS).map(&:text).join
    expect(last_rows).to include("Organic extraneous matter", "Parboiled rice.")
  end
end
