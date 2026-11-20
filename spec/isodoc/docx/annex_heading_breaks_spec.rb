# frozen_string_literal: true

require_relative "spec_helper"

# An annex heading's number ("Annex A") comes from the ANNEX style's
# numbering; the presentation XML adds the obligation line and the gap
# before the title as soft breaks, in the heading's caption delimiter.
# They must reach the DOCX the way the PDF lays them out
# (metanorma-iso#1728).
RSpec.describe "DOCX annex heading soft breaks" do
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
  let(:document) do
    convert(<<~ANNEX)
      <annex id="annexA" obligation="normative">
        <fmt-title><strong><span class="fmt-caption-label"><span class="fmt-element-name">Annex</span> <semx element="autonum" source="annexA">A</semx></span></strong><br/><span class="fmt-obligation">(normative)</span><span class="fmt-caption-delim"><br/><br/></span><semx element="title" source="at"><strong>Determination of defects</strong></semx></fmt-title>
        <p>Content.</p>
      </annex>
    ANNEX
  end
  let(:heading) { document.at_xpath("//w:p[w:pPr/w:pStyle/@w:val='ANNEX']", ns) }

  def convert(inner)
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier primary="true">ISO 1:2016</docidentifier>
        <ext><doctype>international-standard</doctype></ext>
      </bibdata>
      <sections>
        <clause id="s1">
          <fmt-title depth="1"><span class="fmt-caption-label"><semx element="autonum" source="s1">1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="s1t">Scope</semx></fmt-title>
          <p>Body.</p>
        </clause>
      </sections>
      #{inner}
    INNER
    Dir.mktmpdir do |dir|
      path = File.join(dir, "out.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) { |z| Nokogiri::XML(z.read("word/document.xml")) }
    end
  end

  # Items of the heading in document order: :br or the run text.
  def sequence(para)
    para.xpath("./w:r", ns).flat_map do |run|
      items = []
      items << :br if run.at_xpath("./w:br", ns)
      text = run.xpath("./w:t", ns).map(&:text).join
      items << text unless text.empty?
      items
    end
  end

  it "puts the obligation on its own line and a gap before the title" do
    expect(sequence(heading)).to eq([:br, "(normative)", :br, :br, "Determination of defects"])
  end

  it "does not repeat the number the style's numbering supplies" do
    expect(heading.text).not_to match(/Annex|\bA\b/)
  end

  it "still drops the tab delimiter of a numbered clause heading" do
    scope = document.at_xpath("//w:p[w:pPr/w:pStyle/@w:val='Heading1'][.//w:t[.='Scope']]", ns)
    expect([scope.xpath(".//w:br", ns).size, scope.xpath(".//w:tab", ns).size]).to eq([0, 0])
  end
end
