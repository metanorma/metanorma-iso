# frozen_string_literal: true

require_relative "spec_helper"

# metanorma/metanorma-pdfa#122: the STS inline dispatch public_send'd
# :monospace straight onto Sts::NisoSts::Term, and on metanorma-iso
# 3.5.21's floating sts floor (`>= 0.5.6`; NisoSts::Term grew its
# monospace slot only in sts 0.6.12) any definition list whose term
# carried monospace text died with NoMethodError and lost the whole
# STS output. These specs lock the guarded dispatch: every append
# probes the target's class for the slot, keeps the run as text when
# the class lacks it, and NISO STS <term> carries its dt's inline
# content the way the schema models it.
RSpec.describe "inline dispatch onto STS targets" do
  let(:doc) { Nokogiri::XML(Metanorma::Iso::Sts.convert(xml)) }

  context "when a definition-list term carries inline content" do
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
              <dl id="dl1">
                <dt id="dt1">ISO <strong>PDF</strong> path in <tt>mono</tt> form</dt>
                <dd>
                  <p id="p1">First definition.</p>
                </dd>
              </dl>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "converts without raising" do
      expect { Metanorma::Iso::Sts.convert(xml) }.not_to raise_error
    end

    it "carries the term's bold and monospace runs inside <term>" do
      term = doc.at_xpath("//def-list/def-item/term")
      expect(term).not_to be_nil
      expect(term.at_xpath("./bold")&.text).to eq("PDF")
      expect(term.at_xpath("./monospace")&.text).to eq("mono")
    end

    it "keeps the plain text runs around the inline elements" do
      term = doc.at_xpath("//def-list/def-item/term")
      expect(term.text).to eq("ISO PDF path in mono form")
    end
  end

  context "when a definition-list term wraps its text in paragraphs" do
    # The dt walk yields the paragraph blocks as model objects: they
    # degrade to their rendered text instead of being dropped.
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
              <dl id="dl1">
                <dt id="dt1"><p>Term one</p></dt>
                <dd>
                  <p id="p1">First definition.</p>
                </dd>
              </dl>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "renders the wrapped text as the term content" do
      term = doc.at_xpath("//def-list/def-item/term")
      expect(term).not_to be_nil
      expect(term.text).to eq("Term one")
    end
  end
end

# Direct transformer coverage against real metanorma-document and sts
# model instances: apply_inline_content must answer for targets whose
# classes lack the slots the walk produces (the #122 shape) without
# raising and without losing the run.
RSpec.describe Metanorma::Iso::Sts::Transformer::InlineTransformer do
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
  let(:paragraph_transformer) do
    Metanorma::Iso::Sts::Transformer::ParagraphTransformer.new(context)
  end

  def paragraph_model(xml_fragment)
    Metanorma::Document::Components::Paragraphs::ParagraphBlock
      .from_xml(xml_fragment)
  end

  def dt_model(xml_fragment)
    Metanorma::Document::Components::Lists::DtElement.from_xml(xml_fragment)
  end

  it "dispatches bold and monospace model objects onto a tbx:definition" do
    para = paragraph_model(
      '<p id="p1">A <strong>bold</strong> and <tt>mono</tt> bit.</p>')
    definition = Sts::TbxIsoTml::Definition.new
    transformer.apply_inline_content(para, definition)

    expect(Array(definition.bold).first.value.join).to eq("bold")
    expect(Array(definition.monospace).first.content.join).to eq("mono")
    expect(definition.value.join).to eq("A  and  bit.")
  end

  it "keeps walk order across text and inline elements" do
    para = paragraph_model('<p id="p1">before <em>mid</em> after</p>')
    term = Sts::NisoSts::Term.new do |t|
      transformer.apply_inline_content(para, t)
    end

    expect(Array(term.text).join).to eq("before  after")
    expect(Array(term.italic).first.value.join).to eq("mid")
    expect(term.element_order.map(&:node_type)).to eq(%i[text element text])
    expect(term.to_xml).to include("before <italic>mid</italic> after")
  end

  it "degrades to text when the target class lacks the slot" do
    # Sts::TbxIsoTml::Term declares no monospace or ext_link slot —
    # the #122 crash shape, reproduced against the released gem.
    term = ::Sts::TbxIsoTml::Term.new
    expect(term.class.attributes.key?(:monospace)).to be(false)

    dt = dt_model(
      '<dt id="dt1">path <tt>code</tt> end</dt>'
    )
    entries = paragraph_transformer.entries_for(dt)
    transformer.apply_inline_entries(entries, term)

    expect(Array(term.value).join).to eq("path code end")
  end

  it "raises nothing for kinds the target has no slot for" do
    para = paragraph_model('<p id="p1">See <fn id="fn1"><p>footnote</p></fn>.</p>')
    definition = Sts::TbxIsoTml::Definition.new
    expect { transformer.apply_inline_content(para, definition) }
      .not_to raise_error
    expect(definition.value.join).to include("footnote")
  end

  it "probes a generic text carrier when the class is not in the table" do
    # Sts::NisoSts::StyledContent carries text on :content and is not
    # in TEXT_ATTR_FOR — the fallback probing must find it.
    para = paragraph_model('<p id="p1">styled text</p>')
    styled = Sts::NisoSts::StyledContent.new
    transformer.apply_inline_content(para, styled)

    expect(styled.content.join).to eq("styled text")
  end
end
