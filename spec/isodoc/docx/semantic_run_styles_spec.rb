# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"
require "zip"

# P2-001 / P2-003: the 2016 reference (spec/examples/rice.docx) carries
# citesec, citeapp, citefig, citetbl, stdpublisher0, stddocnumber, stdyear
# as run styles. The ISO DIS template deliberately has none of them
# (style_mapping.yml excluded_styles, "8601-era pollution", enforced by
# StyleMappingValidator). The presentation spans carrying those classes
# must therefore keep their text and emit no run style, so no rStyle
# dangles without a definition in word/styles.xml.
RSpec.describe IsoDoc::Iso::Docx::Adapter, "reference-only run styles" do
  let(:adapter) { build_adapter }
  let(:inner) do
    <<~INNER
      <sections>
        <clause id="c1">
          <fmt-title depth="1"><span class="fmt-caption-label"><semx element="autonum">1</semx></span><span class="fmt-caption-delim"><tab/></span>Scope</fmt-title>
          <p>See <xref target="c1" id="x1"/><semx element="xref" source="x1"><fmt-xref target="c1"><span class="citesec">1.2</span></fmt-xref></semx>.</p>
          <p>Cited <span class="stdpublisher">ISO</span> <span class="stddocNumber">712</span>:<span class="stdyear">2009</span></p>
        </clause>
      </sections>
    INNER
  end

  def convert
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      adapter.convert(minimal_iso_xml(inner), path)
      styles = Zip::File.open(path) { |zip| zip.read("word/styles.xml") }
      extract_docx(path) { |doc, ns| yield doc, ns, styles }
    end
  end

  it "keeps the text of reference-only spans without a run style",
     :aggregate_failures do
    convert do |doc, ns, _styles|
      %w[ISO 712 2009].each do |text|
        run = doc.at_xpath("//w:r[w:t='#{text}']", ns)
        expect(run).not_to be_nil
        expect(run.at_xpath("w:rPr/w:rStyle", ns)).to be_nil
      end
    end
  end

  it "defines every run style the document references" do
    convert do |doc, ns, styles|
      used = doc.xpath("//w:rStyle/@w:val", ns).map(&:value).uniq
      expect(used).to eq(["Hyperlink"])
      used.each { |id| expect(styles).to include(%(w:styleId="#{id}")) }
    end
  end
end
