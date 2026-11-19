# frozen_string_literal: true

require_relative "spec_helper"

# tbx:termEntry structure per the NISO STS TBX module: langSet's free-mix
# content (subjectField among it) precedes the mandatory tig run, and
# term-sec / termEntry must not share one derived id (xs:ID uniqueness),
# so the section takes sec_ and the entry term_ off the same source id.
RSpec.describe "Term entry structure and ids" do
  let(:xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">
          <title language="en" type="main">Test</title>
          <docidentifier>ISO 9999</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <terms id="_terms1" obligation="normative">
            <title>Terms and definitions</title>
            <term id="_8b70fb0a-3c42">
              <preferred><expression><name>relation</name></expression></preferred>
              <domain>register</domain>
              <definition id="def1">
                <verbal-definition id="vd1">
                  <p id="p1">association declared between units of information</p>
                </verbal-definition>
              </definition>
            </term>
            <terms id="_terms2" obligation="normative">
              <title>More terms</title>
              <term id="_d4a0f91e-830e">
                <preferred><expression><name>change</name></expression></preferred>
              </term>
            </terms>
          </terms>
        </sections>
      </metanorma>
    XML
  end

  let(:sts) { Metanorma::Iso::Sts.convert(xml) }
  let(:doc) { Nokogiri::XML(sts) }

  it "emits subjectField before definition and tig inside langSet" do
    langset = doc.at_xpath("//*[local-name()='langSet']")
    names = langset.element_children.map { |c| c.name.sub(/\Atbx:/, "") }
    expect(names).to eq(%w[subjectField definition tig])
  end

  it "derives the termEntry id with the term_ prefix" do
    entry = doc.at_xpath("//*[local-name()='termEntry']")
    expect(entry["id"]).to eq("term_8b70fb0a-3c42")
  end

  it "derives the term-sec id with the sec_ prefix" do
    term_sec = doc.at_xpath("//term-sec")
    expect(term_sec["id"]).to eq("sec_8b70fb0a-3c42")
  end

  it "keeps termEntry and term-sec ids distinct document-wide" do
    ids = doc.xpath("//*[@id]").map { |e| e["id"] }
    expect(ids.uniq.size).to eq(ids.size)
  end

  it "uniquifies the fallback sec_terms id per terms section" do
    terms_ids = doc.xpath("//sec[@sec-type='terms']").map { |s| s["id"] }
    expect(terms_ids).to eq(%w[sec_terms sec_terms_1])
  end
end
