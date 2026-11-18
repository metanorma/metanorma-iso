# frozen_string_literal: true

require_relative "spec_helper"

# The STS HTML renderer's graphic handler reads the graphic's
# accessibility text from the <alt-text> child element — the NISO STS
# 1.2 form (access.class of graphic-model). The element has no
# @alttext attribute; reading one crashed every graphic-bearing
# document against sts < 0.6.14 (metanorma-iso#1793).
RSpec.describe "STS HTML renderer: graphic alt text" do
  let(:sts_xml) do
    <<~XML
      <standard xmlns:xlink="http://www.w3.org/1999/xlink">
        <front>
          <std-meta>
            <std-ident><originator>ISO</originator><doc-number>99999</doc-number></std-ident>
            <std-org><std-org-abbrev>ISO</std-org-abbrev></std-org>
            <content-language>en</content-language>
          </std-meta>
        </front>
        <body>
          <sec id="sec_1">
            <label>1</label>
            <title>Scope</title>
            <fig id="fig_1">
              <graphic xlink:href="figure-1.png">
                <alt-text>Overall schematic of the register</alt-text>
              </graphic>
            </fig>
          </sec>
        </body>
      </standard>
    XML
  end

  it "renders the graphic as an img with the alt-text content" do
    html = Metanorma::Iso::Sts.render_html(sts_xml)

    img = html[%r{<img[^>]*>}m]
    expect(img).not_to be_nil
    expect(img).to include("figure-1.png")
    expect(html).to include("Overall schematic of the register")
  end

  it "renders a graphic without alt-text as an img with an empty alt" do
    xml = sts_xml.sub(%r{<alt-text>[^<]*</alt-text>}, "")
    html = Metanorma::Iso::Sts.render_html(xml)

    img = html[%r{<img[^>]*>}m]
    expect(img).not_to be_nil
    expect(img).to include("figure-1.png")
  end
end
