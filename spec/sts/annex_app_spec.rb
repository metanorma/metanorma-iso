# frozen_string_literal: true

require_relative "spec_helper"

# Annexes serialize as <app> elements in <back><app-group>. The app
# content model wants label/annex-type/title, then para-level content,
# then child secs — so the annex body dispatches straight into the app
# (no wrapper <sec>, which would need its own label/title to be
# schema-valid), and every annex needs its own xs:ID.
RSpec.describe "Annex to app conversion" do
  let(:xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">
          <title language="en" type="main">Test</title>
          <docidentifier>ISO 9999</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1"><title>Scope</title><p id="p1">Scope text.</p></clause>
        </sections>
        <annex id="_ann1" obligation="normative" inline-header="false">
          <title>Conformance test suite</title>
          <p id="ap1">Intro paragraph of the annex.</p>
          <clause id="_ann1c1"><title>General</title><p id="ap2">Clause text.</p></clause>
        </annex>
        <annex id="_ann2" obligation="informative" inline-header="false">
          <title>Differences</title>
          <p id="ap3">Intro paragraph of the second annex.</p>
        </annex>
      </metanorma>
    XML
  end

  let(:doc) { Nokogiri::XML(Metanorma::Iso::Sts.convert(xml)) }

  it "emits one app per annex with sequential letters" do
    apps = doc.xpath("//app")
    expect(apps.size).to eq(2)
    expect(apps.map { |a| a["id"] }).to eq(%w[sec_A sec_B])
  end

  it "labels each annex and emits the obligation as annex-type" do
    first, second = doc.xpath("//app").to_a
    expect(first.at_xpath("./label")&.text).to eq("Annex\u00A0A")
    expect(first.at_xpath("./annex-type")&.text).to eq("(normative)")
    expect(second.at_xpath("./label")&.text).to eq("Annex\u00A0B")
    expect(second.at_xpath("./annex-type")&.text).to eq("(informative)")
  end

  it "dispatches annex content directly into the app" do
    first = doc.at_xpath("//app[@id='sec_A']")
    expect(first.at_xpath("./title")&.text).to eq("Conformance test suite")
    expect(first.at_xpath("./p")&.text).to include("Intro paragraph of the annex")
    expect(first.xpath("./sec").size).to eq(1)
  end

  it "emits no wrapper sec around the annex body" do
    doc.xpath("//app").each do |app|
      # the app's immediate children are its label/annex-type/title and
      # its own blocks/secs — never a lone structureless wrapper sec
      children = app.element_children.map(&:name)
      expect(children).not_to eq(["sec"])
    end
  end

  it "orders app content before the child secs" do
    first = doc.at_xpath("//app[@id='sec_A']")
    names = first.element_children.map(&:name)
    expect(names.index("p")).to be < names.index("sec")
  end

  it "keeps app ids distinct from any other xs:ID in the document" do
    ids = doc.xpath("//*[@id]").map { |e| e["id"] }
    expect(ids.uniq.size).to eq(ids.size)
  end
end
