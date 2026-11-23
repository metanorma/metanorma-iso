# frozen_string_literal: true

require_relative "spec_helper"

# A heading must render every inline element of its title, and agree with
# the contents entry built from the same title.
RSpec.describe "DOCX heading inline content" do # rubocop:disable RSpec/DescribeClass
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:annex_title) { "Annex <tt>code</tt>" }
  let(:xml) do
    minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="s1"><fmt-title><span class="fmt-caption-label"><semx element="autonum" source="s1">1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title">Target</semx></fmt-title><p>Body.</p>
          <clause id="s11"><fmt-title><span class="fmt-caption-label"><semx element="autonum" source="s1">1</semx>.<semx element="autonum" source="s11">1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title"><tt>tt only</tt></semx></fmt-title><p>Body.</p></clause>
          <clause id="s12"><fmt-title><span class="fmt-caption-label"><semx element="autonum" source="s1">1</semx>.<semx element="autonum" source="s12">2</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title">Use <tt>tt</tt> here</semx></fmt-title><p>Body.</p></clause>
          <clause id="s13"><fmt-title><span class="fmt-caption-label"><semx element="autonum" source="s1">1</semx>.<semx element="autonum" source="s13">3</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title">#{xref}</semx></fmt-title><p>Body.</p></clause>
        </clause>
        <clause id="s2"><fmt-title><span class="fmt-caption-label"><semx element="autonum" source="s2">2</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title">See #{xref} and <link target="https://x.org" id="l1">x</link><semx element="link" source="l1"><fmt-link target="https://x.org">x</fmt-link></semx> end</semx></fmt-title><p>Body.</p></clause>
      </sections>
      <annex id="a1" obligation="normative"><fmt-title><span class="fmt-caption-delim"><br/></span><semx element="title">#{annex_title}</semx></fmt-title><p>Annex body.</p></annex>
    INNER
  end
  let(:document) do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) { |zip| Nokogiri::XML(zip.read("word/document.xml")) }
    end
  end

  def xref
    '<xref target="s1" id="x1"/><semx element="xref" source="x1">' \
      '<fmt-xref target="s1"><span class="citesec"><span class="fmt-element-name">Clause</span> ' \
      '<semx element="autonum" source="s1">1</semx></span></fmt-xref></semx>'
  end

  def text_of(paragraph)
    paragraph.xpath(".//w:t", ns).map(&:text).join
  end

  def paragraphs(style_pattern)
    document.xpath("//w:p[w:pPr/w:pStyle[#{style_pattern}]]", ns)
  end

  def headings
    paragraphs("starts-with(@w:val,'Heading')").map { |p| text_of(p) }
  end

  def toc
    paragraphs("starts-with(@w:val,'TOC') and string-length(@w:val)=4").map { |p| text_of(p) }
  end

  it "keeps a tt-only subclause title as a heading", :aggregate_failures do
    expect(headings).to include("tt only")
    expect(toc).to include("1.1 tt only1")
  end

  it "keeps the heading style and bookmark of a tt-only title", :aggregate_failures do
    heading = paragraphs("@w:val='Heading2'").find { |p| text_of(p) == "tt only" }
    expect(heading).not_to be_nil
    expect(heading.xpath(".//w:bookmarkStart", ns)).not_to be_empty
  end

  it "renders tt mixed with text", :aggregate_failures do
    expect(headings).to include("Use tt here")
    expect(toc).to include("1.2 Use tt here1")
  end

  it "renders a title holding only an xref", :aggregate_failures do
    expect(headings).to include("Clause 1")
    expect(toc).to include("1.3 Clause 11")
  end

  it "renders xref and link text inside a clause title", :aggregate_failures do
    expect(headings).to include("See Clause 1 and x end")
    expect(toc).to include("2 See Clause 1 and x end1")
  end

  it "keeps the xref label inside the heading's internal hyperlink" do
    link = document.xpath("//w:p[w:pPr/w:pStyle[@w:val='Heading1']]//w:hyperlink[@w:anchor]", ns).first
    expect(text_of(link)).to eq("Clause 1")
  end

  it "renders tt in an annex title" do
    expect(paragraphs("@w:val='ANNEX'").map { |p| text_of(p) }.join).to include("code")
  end

  context "with a tt-only annex title" do
    let(:annex_title) { "<tt>code</tt>" }

    it "keeps the annex heading and its contents entry", :aggregate_failures do
      expect(paragraphs("@w:val='ANNEX'").map { |p| text_of(p) }.join).to include("code")
      expect(toc.join).to include("code")
    end
  end
end
