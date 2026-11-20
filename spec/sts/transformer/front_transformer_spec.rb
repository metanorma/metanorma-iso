# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::FrontTransformer do
  def front_for(preface_xml)
    source = Metanorma::Iso::Sts::Transformer::SourceDocument.parse(<<~XML)
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">
          <title language="en" type="main">Widgets</title>
          <docidentifier>ISO 4242</docidentifier>
          <language>en</language>
        </bibdata>
        #{preface_xml}
        <sections><clause id="c1"><title>Scope</title><p id="p1">x</p></clause></sections>
      </metanorma>
    XML
    context = Metanorma::Iso::Sts::Transformer::Context.new(source)
    transformer = described_class.new(context)
    [transformer, source, Nokogiri::XML(transformer.transform(source).to_xml)]
  end

  let(:preface) do
    <<~XML
      <preface>
        <foreword id="fw"><title>Foreword</title><p id="fwp">Foreword body.</p></foreword>
        <introduction id="in"><title>Introduction</title><p id="inp">Intro body.</p></introduction>
      </preface>
    XML
  end

  it "returns <front> carrying <std-meta> built from the bibdata" do
    _, _, doc = front_for("")

    expect(doc.root.name).to eq("front")
    expect(doc.at_xpath("/front/std-meta/title-wrap/main").text).to eq("Widgets")
    expect(doc.at_xpath("/front/std-meta/std-ref").text).to eq("ISO 4242")
    expect(doc.at_xpath("/front/iso-meta")).to be_nil
  end

  it "emits the foreword as an unnumbered <sec sec-type='foreword'>" do
    _, _, doc = front_for(preface)
    sec = doc.at_xpath("/front/sec[@sec-type='foreword']")

    expect(sec).not_to be_nil
    expect(sec.at_xpath("./title").text).to eq("Foreword")
    expect(sec.at_xpath("./p").text).to eq("Foreword body.")
  end

  it "emits the introduction as <sec sec-type='intro'> after the foreword" do
    _, _, doc = front_for(preface)
    secs = doc.xpath("/front/sec")

    expect(secs.map { |s| s["sec-type"] }).to eq(%w[foreword intro])
    expect(secs.last.at_xpath("./title").text).to eq("Introduction")
    expect(secs.last.at_xpath("./p").text).to eq("Intro body.")
  end

  it "emits no <sec> when the document has neither" do
    _, _, doc = front_for("")

    expect(doc.xpath("/front/sec")).to be_empty
  end

  it "emits only the foreword when there is no introduction" do
    _, _, doc = front_for(%(<preface><foreword id="fw"><title>Foreword</title><p id="a">A.</p></foreword></preface>))

    expect(doc.xpath("/front/sec").map { |s| s["sec-type"] }).to eq(%w[foreword])
  end

  describe "#front_sections" do
    it "returns the models in foreword, introduction order" do
      transformer, source, = front_for(preface)
      secs = transformer.front_sections(source)

      expect(secs.map(&:class)).to all(eq(Sts::NisoSts::Section))
      expect(secs.map(&:type)).to eq(%w[foreword intro])
    end
  end
end
