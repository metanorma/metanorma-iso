# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::BodyTransformer do
  def body_for(sections_xml, extra = "")
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">
          <title language="en" type="main">Test</title>
          <docidentifier>ISO 9999</docidentifier>
          <language>en</language>
        </bibdata>
        #{extra}
        <sections>#{sections_xml}</sections>
      </metanorma>
    XML
    source = Metanorma::Iso::Sts::Transformer::SourceDocument.parse(xml)
    context = Metanorma::Iso::Sts::Transformer::Context.new(source)
    described_class.new(context).transform(source)
  end

  it "returns a <body> holding one <sec> per top-level clause, in order" do
    body = body_for(<<~XML)
      <clause id="c1"><title>Scope</title><p id="p1">One.</p></clause>
      <clause id="c2"><title>Normative references</title><p id="p2">Two.</p></clause>
    XML

    expect(body).to be_a(Sts::NisoSts::Body)
    doc = Nokogiri::XML(body.to_xml)
    secs = doc.xpath("/body/sec")
    expect(secs.map { |s| s["id"] }).to eq(%w[c1 c2])
    expect(secs.map { |s| s.at_xpath("./title").text }).to eq(["Scope", "Normative references"])
    expect(secs.first.at_xpath("./p").text).to eq("One.")
  end

  it "emits an empty <body> when there are no sections" do
    body = body_for("")

    expect(body.sec).to be_empty
    expect(Nokogiri::XML(body.to_xml).root.element_children).to be_empty
  end

  it "does not emit the foreword (it belongs to <front>)" do
    body = body_for(%(<clause id="c1"><title>Scope</title><p id="p1">x</p></clause>),
                    %(<preface><foreword id="fw"><title>Foreword</title><p id="fp">FW</p></foreword></preface>))

    expect(Nokogiri::XML(body.to_xml).xpath("//sec").map { |s| s["id"] }).to eq(%w[c1])
    expect(body.to_xml).not_to include("FW")
  end

  it "does not emit annexes (they belong to <back>)" do
    body = body_for(%(<clause id="c1"><title>Scope</title><p id="p1">x</p></clause>),
                    %(<annex id="a1" obligation="normative"><title>Ann</title><p id="ap">ANNEXTEXT</p></annex>))

    expect(body.to_xml).not_to include("ANNEXTEXT")
  end
end
