# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe "DOCX bookmarks for tables, figures and formulas" do
  let(:tiny_png) do
    "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAA9JREFUCNdj+M+ABf3HCwEACJ8FL0AAAAAASUVORK5CYII="
  end

  let(:xml) do
    minimal_iso_xml(<<~XML)
      <sections><clause id="c1"><title>Scope</title>
        <p id="p1">See <xref target="table1">Table 1</xref>,
          <xref target="fig1">Figure 1</xref>,
          <xref target="f1">Formula (1)</xref> and
          <eref bibitemid="ISO712" citeas="ISO 712">ISO 712</eref>.</p>
        <table id="table1"><fmt-name>Table 1</fmt-name>
          <tbody><tr><td>a</td></tr></tbody></table>
        <figure id="fig1"><fmt-name>Figure 1</fmt-name>
          <image src="#{tiny_png}" width="100" height="100"/></figure>
        <formula id="f1"><fmt-name>(1)</fmt-name>
          <fmt-stem type="MathML"><semx element="stem" source="f1"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>E</mi></math></semx></fmt-stem></formula>
      </clause></sections>
      <bibliography><references id="r1" normative="true"><title>Normative references</title>
        <bibitem id="ISO712" type="standard"><title>Cereals</title>
          <docidentifier>ISO 712</docidentifier></bibitem>
      </references></bibliography>
    XML
  end

  let(:document) do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) do |zip|
        Nokogiri::XML(zip.read("word/document.xml"))
      end
    end
  end

  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:bookmark_names) do
    document.xpath("//w:bookmarkStart/@w:name", ns).map(&:value)
  end

  %w[table1 fig1 f1].each do |id|
    it "bookmarks #{id} so its xref anchor resolves" do
      expect(bookmark_names).to include(id)
    end
  end

  it "does not duplicate bookmark names" do
    expect(bookmark_names).to eq(bookmark_names.uniq)
  end

  it "closes every bookmark with a matching end" do
    starts = document.xpath("//w:bookmarkStart/@w:id", ns).map(&:value)
    ends = document.xpath("//w:bookmarkEnd/@w:id", ns).map(&:value)
    expect(starts.sort).to eq(ends.sort)
  end

  it "links eref to the bibitem through an internal anchor" do
    anchors = document.xpath("//w:hyperlink/@w:anchor", ns).map(&:value)
    expect(anchors).to include("ISO712")
  end

  it "bookmarks the cited bibitem" do
    expect(bookmark_names).to include("ISO712")
  end

  it "leaves no hyperlink anchor without a bookmark" do
    anchors = document.xpath("//w:hyperlink/@w:anchor", ns).map(&:value)
    expect(anchors - bookmark_names).to be_empty
  end
end
