# frozen_string_literal: true

require_relative "unit_b_support"

RSpec.describe Metanorma::Iso::Sts::Transformer::TermTransformer do
  include TransformerUnitSupport

  let(:terms) do
    <<~XML
      <terms id="ts"><title>Terms</title>
        <term id="tm1">
          <preferred><expression><name>cat</name></expression></preferred>
          <admitted><expression><name>kitty</name></expression></admitted>
          <deprecates><expression><name>moggy</name></expression></deprecates>
          <domain>zoo</domain>
          <definition><verbal-definition><p id="dp">small animal</p></verbal-definition></definition>
          <termnote id="tn"><p id="tnp">a note</p></termnote>
          <termexample id="te"><p id="tep">an example</p></termexample>
          <termsource status="identical"><origin citeas="ISO 9">x</origin></termsource>
        </term>
        <term id="tm2">
          <preferred><expression><name>dog</name></expression></preferred>
          <definition><verbal-definition><p id="dp2">other animal</p></verbal-definition></definition>
        </term>
      </terms>
    XML
  end
  let(:language) { "<language>fr</language>" }
  let(:context) { context_for(source_xml(sections: terms, language: language)) }
  let(:root) { context.source.typed_root }
  let(:transformer) { described_class.new(context) }

  def term_xml(id)
    xml_of(transformer.transform(node_of(root, "IsoTerm", id: id)))
  end

  it "wraps the term in a term-sec holding a termEntry, with distinct sec_/term_ ids" do
    doc = term_xml("tm1")

    expect(doc.root.name).to eq("term-sec")
    expect(doc.at_xpath("/term-sec/@id").value).to eq("sec_tm1")
    expect(doc.at_xpath("/term-sec/termEntry/@id").value).to eq("term_tm1")
  end

  it "sets the langSet language from the document language" do
    expect(term_xml("tm1").at_xpath("//langSet/@lang").value).to eq("fr")
  end

  it "emits definition, note, example and source from the term" do
    doc = term_xml("tm1")

    expect(doc.at_xpath("//langSet/subjectField").text).to eq("zoo")
    expect(doc.at_xpath("//langSet/definition").text).to eq("small animal")
    expect(doc.at_xpath("//langSet/note").text).to eq("a note")
    expect(doc.at_xpath("//langSet/example").text).to eq("an example")
    expect(doc.at_xpath("//langSet/source").text).to eq("ISO 9")
  end

  it "marks preferred, admitted and deprecated designations when there are several" do
    doc = term_xml("tm1")
    tigs = doc.xpath("//langSet/tig").to_h do |tig|
      [tig.at_xpath("term").text, tig.at_xpath("normativeAuthorization/@value")&.value]
    end

    expect(tigs).to eq("cat" => "preferredTerm", "kitty" => "admittedTerm", "moggy" => "deprecatedTerm")
  end

  it "omits normativeAuthorization for a lone preferred designation" do
    doc = term_xml("tm2")

    expect(doc.xpath("//langSet/tig").size).to eq(1)
    expect(doc.at_xpath("//langSet/tig/term").text).to eq("dog")
    expect(doc.xpath("//langSet/tig/normativeAuthorization")).to be_empty
  end

  context "when bibdata declares no language" do
    let(:language) { "" }

    it "falls back to en instead of raising" do
      expect(term_xml("tm2").at_xpath("//langSet/@lang").value).to eq("en")
    end
  end
end
