# frozen_string_literal: true

require_relative "spec_helper"

# <graphic> requires xlink:href in the NISO STS schema; the image
# reference lives on the Image model's +source+ attribute (mapped from
# the src= XML attribute).
RSpec.describe "Figure graphic href" do
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
            <figure id="_fig1" anchor="fig-one">
              <name>Overview diagram</name>
              <image id="_img1" src="images/overview.svg" mimetype="image/svg+xml"/>
            </figure>
            <figure id="_fig2" anchor="fig-two">
              <name>No image</name>
            </figure>
          </clause>
        </sections>
      </metanorma>
    XML
  end

  let(:sts) { Metanorma::Iso::Sts.convert(xml) }
  let(:doc) { Nokogiri::XML(sts) }

  it "emits the image reference as xlink:href on graphic" do
    graphic = doc.at_xpath("//fig[@id='fig_1']//graphic")
    expect(graphic).not_to be_nil
    expect(graphic["xlink:href"]).to eq("overview")
  end

  it "declares the xlink namespace on the root element" do
    root = doc.root
    expect(root.namespaces).to include(
      "xmlns:xlink" => "http://www.w3.org/1999/xlink",
    )
  end

  it "omits graphic for figures without an image reference" do
    fig = doc.at_xpath("//fig[@id='fig_2']")
    expect(fig.at_xpath("./graphic")).to be_nil
  end
end
