# frozen_string_literal: true

require_relative "unit_b_support"

RSpec.describe Metanorma::Iso::Sts::Transformer::SectionTransformer do
  include TransformerUnitSupport

  let(:sections) do
    <<~XML
      <clause id="scope1"><title>Scope</title><p id="sp">Scope text</p></clause>
      <clause id="intro1" type="intro"><title>Opening</title><p id="ip">Intro text</p></clause>
      <clause id="plain1"><title>Requirements</title>
        <p id="pp">Body text</p>
        <note id="pn"><p id="pnp">A note</p></note>
        <clause id="sub1"><title>Detail</title><p id="subp">Nested text</p></clause>
      </clause>
      <clause id="notitle"><p id="ntp">Untitled</p></clause>
      <clause id="withterms"><title>Terms and definitions</title>
        <terms id="tsec"><title>General</title>
          <term id="tm1"><preferred><expression><name>cat</name></expression></preferred>
            <definition><verbal-definition><p id="dp">small animal</p></verbal-definition></definition></term>
        </terms>
      </clause>
    XML
  end
  let(:context) { context_for(source_xml(sections: sections)) }
  let(:root) { context.source.typed_root }
  let(:transformer) { described_class.new(context) }

  def sec(id)
    xml_of(transformer.transform(node_of(root, "IsoClauseSection", id: id)))
  end

  it "emits a sec carrying the id, title and paragraph" do
    result = transformer.transform(node_of(root, "IsoClauseSection", id: "plain1"))

    expect(result).to be_a(Sts::NisoSts::Section)
    doc = xml_of(result)
    expect(doc.at_xpath("/sec/@id").value).to eq("plain1")
    expect(doc.at_xpath("/sec/title").text).to eq("Requirements")
    expect(doc.at_xpath("/sec/p[@id='pp']").text).to eq("Body text")
  end

  it "flags a Scope clause with sec-type scope" do
    expect(sec("scope1").at_xpath("/sec/@sec-type").value).to eq("scope")
  end

  it "flags a clause typed intro with sec-type intro" do
    expect(sec("intro1").at_xpath("/sec/@sec-type").value).to eq("intro")
  end

  it "leaves an ordinary clause without sec-type" do
    expect(sec("plain1").at_xpath("/sec/@sec-type")).to be_nil
  end

  it "omits the title element when the clause has no title" do
    doc = sec("notitle")

    expect(doc.xpath("/sec/title")).to be_empty
    expect(doc.at_xpath("/sec/p").text).to eq("Untitled")
  end

  it "nests sub-clauses as child secs and carries notes" do
    doc = sec("plain1")

    expect(doc.at_xpath("/sec/sec/@id").value).to eq("sub1")
    expect(doc.at_xpath("/sec/sec/title").text).to eq("Detail")
    expect(doc.at_xpath("/sec/non-normative-note/p").text).to eq("A note")
  end

  it "wraps a nested terms section as a sec-type terms sec holding term-secs" do
    doc = sec("withterms")
    terms = doc.at_xpath("/sec/sec[@sec-type='terms']")

    expect(doc.at_xpath("/sec/@sec-type").value).to eq("terms")
    expect(terms.at_xpath("title").text).to eq("General")
    expect(terms.at_xpath("term-sec/termEntry/langSet/tig/term").text).to eq("cat")
  end

  describe "#append_section_content" do
    it "routes each model to its typed slot in order" do
      target = Sts::NisoSts::Section.new
      para = Sts::NisoSts::Paragraph.new(text: ["x"])
      inner = Sts::NisoSts::Section.new(id: "inner")
      transformer.append_section_content(target, [para, inner])

      expect(target.paragraphs).to eq([para])
      expect(target.sec).to eq([inner])
    end
  end
end
