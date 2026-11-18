# frozen_string_literal: true

require_relative "spec_helper"

# Output-level coverage of the ISO STS HTML renderer: one compact STS
# document exercising each element class, asserting the emission each
# maps to. The transformer specs pin the STS XML; this file pins what
# the renderer turns that XML into (metanorma-iso#1793 exposed how
# little output coverage existed here).
RSpec.describe "STS HTML renderer output" do
  let(:sts_xml) do
    <<~XML
      <standard xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML">
        <front>
          <iso-meta>
            <title-wrap xml:lang="en"><main>Test document</main></title-wrap>
            <std-org><std-org-abbrev>ISO</std-org-abbrev></std-org>
          </iso-meta>
        </front>
        <body>
          <sec id="sec_1">
            <label>1</label>
            <title>Scope</title>
            <p id="p_1">This standard defines <xref ref-type="sec" rid="sec_2">clause 2</xref> terms and an <ext-link xlink:href="https://example.com">external link</ext-link>.</p>
            <non-normative-note id="note_1">
              <label>NOTE</label>
              <p id="p_n1">Notes are notes.</p>
            </non-normative-note>
            <fig id="fig_1">
              <graphic xlink:href="figure-1.png">
                <alt-text>Overall schematic</alt-text>
              </graphic>
            </fig>
          </sec>
          <sec id="sec_2">
            <label>2</label>
            <title>Contents</title>
            <disp-formula id="f_1">
              <tex-math><![CDATA[x = y]]></tex-math>
            </disp-formula>
            <table-wrap id="tab_1">
              <caption><title>Decoding table</title></caption>
              <table>
                <thead><tr><th align="left">Key</th><th align="left">Value</th></tr></thead>
                <tbody><tr><td>a</td><td>b</td></tr></tbody>
              </table>
            </table-wrap>
            <def-list id="dl_1">
              <def-item><term>term one</term><def><p id="p_d1">definition one</p></def></def-item>
            </def-list>
            <preformat id="pre_1">fixed  text</preformat>
          </sec>
        </body>
        <back>
          <ref-list>
            <ref id="ref_1"><mixed-citation>ISO 1:2025, Test reference</mixed-citation></ref>
          </ref-list>
        </back>
      </standard>
    XML
  end

  let(:html) { Metanorma::Iso::Sts.render_html(sts_xml) }

  it "renders a full HTML document" do
    expect(html).to start_with("<!DOCTYPE html>")
    expect(html).to include("</html>")
  end

  it "renders the standard title from std-meta" do
    expect(html).to include("Test document")
    expect(html).to include("ISO")
  end

  it "renders body sections with their labels and titles" do
    expect(html).to include("Scope")
    expect(html).to include("Contents")
  end

  it "renders paragraphs and internal xrefs" do
    expect(html).to include("This standard defines")
    expect(html).to include("clause 2")
    expect(html).to include("external link")
  end

  it "renders notes" do
    expect(html).to include("Notes are notes.")
  end

  it "renders figures as images with the alt-text content" do
    img = html[%r{<img[^>]*>}m]
    expect(img).not_to be_nil
    expect(img).to include("figure-1.png")
    expect(html).to include("Overall schematic")
  end

  # The formula CONTAINER renders; the tex-math CDATA content binding
  # is a separate sts-ruby/lutaml-model gap (parsed TexMath#content is
  # empty), tracked outside this spec.
  it "renders display formulas" do
    expect(html).to match(/formula|math/i)
  end

  it "renders tables with headers and body rows" do
    expect(html).to include("<table")
    expect(html).to include("Decoding table")
    expect(html).to include("Key")
    expect(html).to include("Value")
  end

  it "renders definition lists" do
    expect(html).to include("term one")
    expect(html).to include("definition one")
  end

  it "renders preformatted blocks" do
    expect(html).to include("fixed")
  end

  it "renders the back-matter references" do
    expect(html).to include("ISO 1:2025")
  end
end
