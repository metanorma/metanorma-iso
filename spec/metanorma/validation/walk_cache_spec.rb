# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::WalkCache do
  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil)
  end

  def doc_xml(body)
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            #{body}
          </clause>
          <terms id="terms1">
            <title>Terms</title>
            <term id="t1">
              <preferred>Term</preferred>
              <definition><verbal-definition><p>study of cats</p></verbal-definition></definition>
            </term>
          </terms>
        </sections>
      </metanorma>
    XML
  end

  let(:xml) do
    doc_xml(<<~BODY.chomp)
      <p id="p1">plain prose with <em>emphasis</em></p>
      <p>see <xref target="c1">clause</xref></p>
    BODY
  end

  let(:context) { context_with(xml) }
  let(:cache) { context.walk_cache }
  let(:paragraph) { cache.paragraphs_with_parent(context.root).first.first }

  it "is created per Context" do
    expect(cache).to be_a(described_class)
  end

  it "creates a distinct cache per Context" do
    expect(context_with(xml).walk_cache).not_to equal(cache)
  end

  describe "#paragraphs_with_parent" do
    it "matches the shared walk order" do
      walked = []
      cache.each_paragraph_with_parent(context.root) do |p, parent|
        walked << [p, parent]
      end
      expect(cache.paragraphs_with_parent(context.root)).to eq(walked)
    end

    it "memoizes per root" do
      first = cache.paragraphs_with_parent(context.root)
      expect(cache.paragraphs_with_parent(context.root)).to equal(first)
    end

    it "freezes the memoized pair list" do
      expect(cache.paragraphs_with_parent(context.root)).to be_frozen
    end
  end

  describe "#text_of" do
    it "matches extract_text for the same node and strip set" do
      expected = cache.extract_text(paragraph, strip: %i(stem fmt_stem))
      expect(cache.text_of(paragraph, strip: %i(stem fmt_stem))).to eq(expected)
    end

    it "extracts attribute text when the attribute is not stripped" do
      expect(cache.text_of(paragraph, strip: [])).to include("emphasis")
    end

    it "excludes attribute text for a strip set naming it" do
      expect(cache.text_of(paragraph, strip: %i(em)))
        .not_to include("emphasis")
    end

    it "returns a fresh string per call" do
      text = cache.text_of(paragraph, strip: [])
      text << " MUTATED"
      expect(cache.text_of(paragraph, strip: [])).not_to include("MUTATED")
    end
  end

  describe "#xrefs" do
    it "collects every xref" do
      expect(cache.xrefs(context.root).size).to eq(1)
    end

    it "memoizes the xref list" do
      xrefs = cache.xrefs(context.root)
      expect(cache.xrefs(context.root)).to equal(xrefs)
    end

    it "freezes the xref list" do
      expect(cache.xrefs(context.root)).to be_frozen
    end
  end

  describe "#terms" do
    it "collects every term" do
      expect(cache.terms(context.root).size).to eq(1)
    end

    it "collects the term with its identifier" do
      expect(cache.terms(context.root).first.id).to eq("t1")
    end

    it "memoizes the term list" do
      terms = cache.terms(context.root)
      expect(cache.terms(context.root)).to equal(terms)
    end

    it "freezes the term list" do
      expect(cache.terms(context.root)).to be_frozen
    end
  end
end
