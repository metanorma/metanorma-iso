# frozen_string_literal: true

require_relative "spec_helper"

# A figure with sub-figures and no image of its own (rice Annex C.2). Each
# sub-figure carries its image; the converter must emit every sub-figure as
# a <fig> with its own <graphic>, not a <fig> without one (iso-gdg-8.1-2).
RSpec.describe "Sub-figure graphics" do
  let(:xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">
          <title language="en" type="main">Test</title>
          <docidentifier>ISO 9999</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1"><title>Scope</title>
            <p id="_p1">See <xref target="_group_fig">the group</xref>,
              <xref target="_stage_a">a</xref> and <xref target="_stage_b">b</xref>.</p>
            <figure id="_group_fig" anchor="fig-group" autonum="1">
              <name>Stages overview</name>
              <figure id="_stage_a" anchor="fig-a" autonum="1 a">
                <name>First stage</name>
                <image id="_img_a" src="images/stage-a.png" mimetype="image/png"/>
              </figure>
              <figure id="_stage_b" anchor="fig-b" autonum="1 b">
                <name>Second stage</name>
                <image id="_img_b" src="images/stage-b.png" mimetype="image/png"/>
              </figure>
            </figure>
            <p id="_p2">Again <xref target="_stage_a">a</xref> and <xref target="_stage_b">b</xref>.</p>
          </clause>
        </sections>
      </metanorma>
    XML
  end

  let(:sts) { Metanorma::Iso::Sts.convert(xml) }
  let(:doc) { Nokogiri::XML(sts) }

  it "emits no <fig> without a <graphic>" do
    expect(doc.xpath("//fig[not(graphic)]").size).to eq(0)
  end

  it "emits each sub-figure's image as <graphic xlink:href>" do
    hrefs = doc.xpath("//fig/graphic").map { |g| g["xlink:href"] }
    expect(hrefs).to eq(%w[stage-a stage-b])
  end

  # The label separates "Figure" from the number with a no-break space.
  it "keeps each sub-figure's label" do
    labels = doc.xpath("//fig").map { |f| f.at_xpath("./label")&.text }
    expect(labels).to eq(["Figure 1 a", "Figure 1 b"])
  end

  it "keeps each sub-figure's caption" do
    titles = doc.xpath("//fig").map { |f| f.at_xpath("./caption/title")&.text }
    expect(titles).to eq(["First stage", "Second stage"])
  end

  it "keeps the group's cross-reference resolvable" do
    expect(doc.xpath("//fig[@id = //xref[@ref-type='fig']/@rid]")).not_to be_empty
  end

  # The first sub-figure carries the group's id, so xrefs to the group and
  # to that sub-figure share it; xrefs before and after the figure resolve.
  it "resolves every xref to an emitted <fig>, before and after the figure" do
    fig_ids = doc.xpath("//fig/@id").map(&:value)
    rids = doc.xpath("//xref/@rid").map(&:value)
    a, b = fig_ids
    expect([fig_ids.uniq.size, rids]).to eq([2, [a, a, b, a, b]])
  end
end
