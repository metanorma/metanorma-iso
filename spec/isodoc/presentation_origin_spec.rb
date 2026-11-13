# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc::Iso::PresentationXMLConvert do
  subject(:conv) { described_class.new({ semanticxmlinsert: "false" }) }

  let(:docxml) do
    Nokogiri::XML(<<~XML)
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
        <preface>
          <p id="target">first</p>
        </preface>
        <sections>
          <p id="target">second</p>
          <semx id="s1" element="eref" source="target">
            <fmt-eref style="full" bibitemid="iso1" citeas="[1]"/>
          </semx>
          <semx id="s2" element="origin" source="absent">
            <fmt-origin bibitemid="iso1" citeas="[1]"/>
          </semx>
        </sections>
      </metanorma>
    XML
  end

  let(:eref) do
    docxml.at("//*[local-name() = 'semx' and @element = 'eref']")
  end

  let(:origin) do
    docxml.at("//*[local-name() = 'semx' and @element = 'origin']")
  end

  it "resolves a reference source to the first element with that id" do
    conv.bracketed_refs_processing(docxml)
    expect(conv.source_semx(eref))
      .to eql(docxml.xpath("//*[local-name() = 'p' and @id = 'target']").first)
  end

  it "returns nil when the source id does not exist" do
    conv.bracketed_refs_processing(docxml)
    expect(conv.source_semx(origin)).to be_nil
  end

  it "returns the same node object the document scan used to find" do
    conv.bracketed_refs_processing(docxml)
    expect(conv.source_semx(eref)).to be(eref.document.at("//*[@id = 'target']"))
  end
end
