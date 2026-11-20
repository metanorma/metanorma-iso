# frozen_string_literal: true

require_relative "spec_helper"

# QuoteBlock / AdmonitionBlock (the metanorma-document MultiParagraph
# classes carrying <quote> / <admonition>) reach the STS transformer
# through the block dispatcher. Their transformer calls duck-typed
# autonum / ul slots those classes never declared, so any document
# carrying a quote or an admonition died with NoMethodError and lost
# the whole STS output. These specs lock the current-API reads: each
# block renders what it carries and skips what it does not declare.
RSpec.describe "quote and admonition blocks" do
  let(:doc) { Nokogiri::XML(Metanorma::Iso::Sts.convert(xml)) }

  context "when a quote carries paragraphs" do
    let(:xml) do
      <<~XML
        <metanorma>
          <bibdata>
            <title language="en" type="main">T</title>
            <docidentifier>ISO 1:2025</docidentifier>
            <language>en</language>
          </bibdata>
          <sections>
            <clause id="c1"><title>Body</title>
              <quote id="q1">
                <p id="qp1">Quoted sentence spans:requirement[shall] hold.</p>
              </quote>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "renders the quote as disp-quote with its paragraph" do
      quote = doc.at_xpath("//body//disp-quote")
      expect(quote).not_to be_nil
      expect(quote["id"]).to eq("q1")
      expect(quote.at_xpath("./p")&.text).to include("Quoted sentence")
    end

    it "invents no NOTE designation for the quote" do
      expect(doc.at_xpath("//body//disp-quote/label")).to be_nil
    end
  end

  context "when a quote carries attribution" do
    let(:xml) do
      <<~XML
        <metanorma>
          <bibdata>
            <title language="en" type="main">T</title>
            <docidentifier>ISO 1:2025</docidentifier>
            <language>en</language>
          </bibdata>
          <sections>
            <clause id="c1"><title>Body</title>
              <quote id="q1">
                <p id="qp1">Quoted text.</p>
                <attribution id="qa1"><p id="qap1">RFC 7932, Section 3</p></attribution>
              </quote>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "carries the attribution text" do
      quote = doc.at_xpath("//body//disp-quote")
      expect(quote.at_xpath("./attribution")&.text).to include("RFC 7932")
    end
  end

  context "when a quote carries a list" do
    let(:xml) do
      <<~XML
        <metanorma>
          <bibdata>
            <title language="en" type="main">T</title>
            <docidentifier>ISO 1:2025</docidentifier>
            <language>en</language>
          </bibdata>
          <sections>
            <clause id="c1"><title>Body</title>
              <quote id="q1">
                <ul id="qul1">
                  <li><p id="qlp1">Bullet inside quote.</p></li>
                </ul>
              </quote>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "preserves the bullet text as a sibling list of the disp-quote" do
      # The disp-quote model has no list slot; the quote's lists surface
      # as siblings after it instead of being dropped.
      section = doc.at_xpath("//body//sec[@id='c1']")
      expect(section.at_xpath("./disp-quote")).to be_nil
      list = section.at_xpath("./list")
      expect(list).not_to be_nil
      expect(list.at_xpath(".//list-item/p")&.text).to include("Bullet inside quote.")
    end
  end

  context "when a quote carries a list whose item nests a note" do
    let(:xml) do
      <<~XML
        <metanorma>
          <bibdata>
            <title language="en" type="main">T</title>
            <docidentifier>ISO 1:2025</docidentifier>
            <language>en</language>
          </bibdata>
          <sections>
            <clause id="c1"><title>Body</title>
              <quote id="q1">
                <ul id="qul1">
                  <li><p id="qlp1">Bullet inside quote.<note id="qn1"><p id="qnp1">Listed note.</p></note></p></li>
                </ul>
              </quote>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "renders the item's note as non-normative-note" do
      note = doc.at_xpath("//body//sec[@id='c1']//list-item/non-normative-note")
      expect(note&.text).to include("Listed note.")
    end
  end

  context "when an admonition carries a type" do
    let(:xml) do
      <<~XML
        <metanorma>
          <bibdata>
            <title language="en" type="main">T</title>
            <docidentifier>ISO 1:2025</docidentifier>
            <language>en</language>
          </bibdata>
          <sections>
            <clause id="c1"><title>Body</title>
              <admonition id="ad1" type="editorial">
                <p id="adp1">The above sentence is incorrect.</p>
              </admonition>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "renders the admonition as a note labelled with the upcased type" do
      # mnconvert's mapping for <admonition type="editorial"> is
      # <non-normative-note><label>EDITORIAL</label>.
      note = doc.at_xpath("//body//non-normative-note")
      expect(note.at_xpath("./label")&.text).to eq("EDITORIAL")
      expect(note.at_xpath("./p")&.text).to include("The above sentence is incorrect.")
    end
  end

  context "when an admonition carries no type" do
    let(:xml) do
      <<~XML
        <metanorma>
          <bibdata>
            <title language="en" type="main">T</title>
            <docidentifier>ISO 1:2025</docidentifier>
            <language>en</language>
          </bibdata>
          <sections>
            <clause id="c1"><title>Body</title>
              <admonition id="ad1">
                <p id="adp1">Untyped admonition body.</p>
              </admonition>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "renders the content with no invented label and no crash" do
      note = doc.at_xpath("//body//non-normative-note")
      expect(note).not_to be_nil
      expect(note.at_xpath("./label")).to be_nil
      expect(note.at_xpath("./p")&.text).to include("Untyped admonition body.")
    end
  end

  context "when a note carries an autonum" do
    let(:xml) do
      <<~XML
        <metanorma>
          <bibdata>
            <title language="en" type="main">T</title>
            <docidentifier>ISO 1:2025</docidentifier>
            <language>en</language>
          </bibdata>
          <sections>
            <clause id="c1"><title>Body</title>
              <note id="n1" autonum="2"><p id="np1">Numbered note.</p></note>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "keeps the NOTE designation with the autonumber" do
      note = doc.at_xpath("//body//non-normative-note")
      # The NBSP post-processor joins the designation and its number.
      expect(note.at_xpath("./label")&.text).to eq("NOTE\u00A02")
    end
  end

  context "when a quote carries nothing renderable" do
    let(:xml) do
      <<~XML
        <metanorma>
          <bibdata>
            <title language="en" type="main">T</title>
            <docidentifier>ISO 1:2025</docidentifier>
            <language>en</language>
          </bibdata>
          <sections>
            <clause id="c1"><title>Body</title>
              <quote id="q1"/>
              <p id="p1">Following paragraph.</p>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "emits no shell element and the rest of the section survives" do
      expect(doc.at_xpath("//body//disp-quote")).to be_nil
      expect(doc.at_xpath("//body//sec[@id='c1']/p")&.text).to include("Following paragraph.")
    end
  end
end

# Direct transformer coverage against real metanorma-document model
# instances: the dispatcher may route any block class through
# NoteTransformer, so designation_label and extract_lists must answer
# for the classes that lack the slots they read.
RSpec.describe Metanorma::Iso::Sts::Transformer::NoteTransformer do
  let(:source) do
    Metanorma::Iso::Sts::Transformer::SourceDocument.parse(<<~XML)
      <metanorma>
        <bibdata>
          <title language="en" type="main">T</title>
          <docidentifier>ISO 1:2025</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1"><title>Body</title><p id="p1">Text.</p></clause>
        </sections>
      </metanorma>
    XML
  end

  let(:context) { Metanorma::Iso::Sts::Transformer::Context.new(source) }
  let(:transformer) { described_class.new(context) }

  let(:paragraph_block_class) do
    Metanorma::Document::Components::Paragraphs::ParagraphBlock
  end

  # Real metanorma-document models, parsed from XML fragments —
  # parsed models carry the element order the mixed-content walks need.
  def quote_model(xml_fragment)
    Metanorma::Document::Components::MultiParagraph::QuoteBlock
      .from_xml(xml_fragment)
  end

  def admonition_model(xml_fragment)
    Metanorma::Document::Components::MultiParagraph::AdmonitionBlock
      .from_xml(xml_fragment)
  end

  it "labels a QuoteBlock without an autonum slot as plain NOTE" do
    quote = quote_model('<quote id="q1"><p id="qp1">Quoted.</p></quote>')
    expect(quote.class.attributes.key?(:autonum)).to be(false)
    expect(transformer.designation_label(quote, "NOTE")).to eq("NOTE")
  end

  it "labels an AdmonitionBlock without an autonum slot as plain NOTE" do
    admonition = admonition_model(
      '<admonition id="ad1"><p id="adp1">Admonished.</p></admonition>'
    )
    expect(admonition.class.attributes.key?(:autonum)).to be(false)
    expect(transformer.designation_label(admonition, "NOTE")).to eq("NOTE")
  end

  it "keeps the autonumber for classes that declare the slot" do
    note = Metanorma::Document::Components::Blocks::NoteBlock
           .from_xml('<note id="n1" autonum="3"><p id="np1">Noted.</p></note>')
    expect(transformer.designation_label(note, "NOTE")).to eq("NOTE 3")
  end

  # extract_paragraphs / extract_lists are private: their contract is
  # observed through the public transform.
  it "transforms an AdmonitionBlock into a note with its paragraphs and no lists" do
    admonition = admonition_model(
      '<admonition id="ad1" type="editorial"><p id="adp1">Admonished.</p></admonition>'
    )
    model = transformer.transform(admonition)
    expect(model).to be_a(::Sts::NisoSts::NonNormativeNote)
    expect(model.p.first.text.join).to include("Admonished.")
    expect(Array(model.list)).to be_empty
  end

  it "transforms a QuoteBlock's paragraphs and lists without raising" do
    quote = quote_model(
      '<quote id="q1"><p id="qp1">Quoted.</p>' \
      '<ul id="qul1"><li id="qli1"><p id="lip1">Item.</p></li></ul></quote>'
    )
    model = transformer.transform(quote)
    expect(model).to be_a(::Sts::NisoSts::NonNormativeNote)
    expect(model.p.first.text.join).to include("Quoted.")
    expect(model.list.first.list_item.first.p.first.text.join).to include("Item.")
  end

  it "renders a QuoteBlock through the quote transformer as disp-quote" do
    quote = quote_model('<quote id="q1"><p id="qp1">Quoted.</p></quote>')
    model = Metanorma::Iso::Sts::Transformer::QuoteTransformer.new(context).transform(quote)
    expect(model).to be_a(::Sts::NisoSts::DispQuote)
    expect(model.id).to eq("q1")
    expect(model.paragraphs.first.text.join).to include("Quoted.")
  end
end
