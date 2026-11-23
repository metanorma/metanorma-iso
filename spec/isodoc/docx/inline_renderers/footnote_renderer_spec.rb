# frozen_string_literal: true

require_relative "../spec_helper"
require "tmpdir"
require "zip"
require "nokogiri"
require_relative "../../../support/docx_footnote_helpers"

RSpec.describe IsoDoc::Iso::Docx::InlineRenderers::FootnoteRenderer do
  include DocxFootnoteHelpers

  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.new }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { Uniword::Builder::DocumentBuilder.new }
  let(:resolver) { IsoDoc::Iso::Docx::StyleResolver.new(mapping, context) }
  let(:parent) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }
  let(:renderer) { described_class.new(parent) }
  let(:para) { Uniword::Builder::ParagraphBuilder.new }

  # Build the ParagraphBuilder to a Paragraph so we can inspect runs.
  def built_runs
    para.build.runs
  end

  def footnote_bodies
    doc.model.footnotes.footnote_entries
       .reject { |e| e.type == "separator" || e.type == "continuationSeparator" }
       .map do |entry|
         Array(entry.paragraphs).map do |p|
           # Drop the gap run that separates Word's number marker from the body.
           p.runs.map { |r| Array(r.text).join }.join.delete_prefix(" ")
         end.join(" ")
       end
  end

  describe "#render" do
    # OOXML invariant: identical footnotes should share ONE footnote
    # definition. The renderer caches by source identity (target/id) and
    # reuses the existing footnote id for subsequent references.
    it "creates a fresh footnote (and reference) for the first invocation" do
      renderer.render(fn(target: "t1", text: "First footnote."), para)
      first_ref = built_runs.find { |r| r.footnote_reference }
      first_id = first_ref&.footnote_reference&.id

      expect(first_ref).not_to be_nil, "first render must add a footnoteReference"
      expect(first_id).not_to be_nil
    end

    it "reuses the same footnote id for subsequent identical <fn>" do
      renderer.render(fn(target: "t1", text: "First footnote."), para)
      first_id = built_runs.find { |r| r.footnote_reference }&.footnote_reference&.id

      renderer.render(fn(target: "t1", text: "First footnote."), para)
      second_id = built_runs.last.footnote_reference&.id

      expect(second_id).to eq(first_id),
        "second <fn> with same target should reuse the first footnote id " \
        "(got first=#{first_id.inspect}, second=#{second_id.inspect})"
    end

    it "preserves separate source footnotes with identical text", :aggregate_failures do
      renderer.render(fn(target: "first", text: "Same."), para)
      renderer.render(fn(target: "second", text: "Same."), para)

      expect(footnote_bodies).to eq(["Same.", "Same."])
      expect(built_runs.map { |r| r.footnote_reference.id }).to eq(%w[1 2])
    end

    it "keeps distinct bodies when presentation targets collide", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      renderer.render(fn(target: "shared", text: "Term example."), para)
      renderer.render(fn(target: "shared", text: "Definition list."), para)
      renderer.render(fn(target: "shared", text: "Term example."), para)

      expect(footnote_bodies).to eq(["Term example.", "Definition list."])
      expect(built_runs.map { |r| r.footnote_reference.id }).to eq(%w[1 2 1])
    end

    it "preserves emphasis and native math in the footnote body", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      element = Metanorma::Document::Components::Inline::FnElement.from_xml(
        '<fn target="rich"><p>Value <em>italic</em> and <strong>bold</strong> ' \
        '<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math><asciimath>x</asciimath></stem> here.</p></fn>',
      )
      renderer.render(element, para)
      xml = Nokogiri::XML(doc.model.footnotes.to_xml)

      expect(xml.xpath("//*[local-name()='t']").map(&:text))
        .to eq([" ", "Value ", "italic", " and ", "bold", " ", "x", " here."])
      expect(xml.xpath("//*[local-name()='r'][*[local-name()='rPr']/*[local-name()='i']]/*[local-name()='t']").text).to eq("italic")
      expect(xml.xpath("//*[local-name()='r'][*[local-name()='rPr']/*[local-name()='b']]/*[local-name()='t']").text).to eq("bold")
      expect(xml.xpath("//*[local-name()='oMath']").size).to eq(1)
    end

    it "distinguishes rich bodies with identical text under the same target", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      %w[em strong].each do |tag|
        element = Metanorma::Document::Components::Inline::FnElement.from_xml(
          "<fn target=\"shared\"><p><#{tag}>same</#{tag}></p></fn>",
        )
        renderer.render(element, para)
      end

      expect(footnote_bodies).to eq(%w[same same])
      expect(built_runs.map { |r| r.footnote_reference.id }).to eq(%w[1 2])
    end

    it "suppresses footnote creation and restores rendering after an error", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      expect do
        parent.with_heading_annotations_suppressed do
          renderer.render(fn(target: "silent", text: "Hidden."), para)
          raise "stop"
        end
      end.to raise_error("stop")
      expect(built_runs).to be_empty
      expect(doc.model.footnotes).to be_nil

      renderer.render(fn(target: "visible", text: "Visible."), para)
      expect(footnote_bodies).to eq(["Visible."])
    end

    it "skips the reference when the footnote text is empty" do
      empty = fn(target: "t2", text: "")
      renderer.render(empty, para)

      fn_refs = built_runs.select { |r| r.footnote_reference }
      expect(fn_refs).to be_empty,
        "an empty <fn> must not create a footnoteReference"
    end

    it "collects mixed-content fn bodies including stem segments", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      renderer.render(fn_with_stem(target: "t90"), para)

      bodies = footnote_bodies.join(" ")
      expect(bodies).to include("The time")
      xml = Nokogiri::XML(doc.model.footnotes.to_xml)
      expect(xml.xpath("//*[local-name()='oMath']").size).to eq(1)
      expect(xml.xpath("//*[local-name()='t']").map(&:text).join).to include("t90")
      expect(bodies).to include("18,2 min")
    end

    it "appends exactly one footnoteReference per non-empty <fn>" do
      renderer.render(fn(target: "t3", text: "Third footnote."), para)

      fn_refs = built_runs.select { |r| r.footnote_reference }
      expect(fn_refs.length).to eq(1),
        "one <fn> must produce exactly one footnoteReference, got #{fn_refs.length}"
    end

    it "every produced footnoteReference has a non-empty id" do
      renderer.render(fn(target: "t4", text: "Fourth."), para)

      fn_refs = built_runs.select { |r| r.footnote_reference }
      expect(fn_refs).not_to be_empty
      fn_refs.each do |r|
        expect(r.footnote_reference.id).not_to be_nil
        expect(r.footnote_reference.id.to_s).not_to be_empty,
          "footnoteReference must have a non-empty id"
      end
    end

    it "registers the new footnote in footnotes.xml" do
      renderer.render(fn(target: "t5", text: "Fifth footnote."), para)

      fn_ids = doc.model.footnotes&.footnote_entries&.map { |e| e.id.to_s } || []
      ref_ids = built_runs.map { |r| r.footnote_reference&.id.to_s }.compact

      ref_ids.each do |ref_id|
        expect(fn_ids).to include(ref_id),
          "footnoteReference id #{ref_id.inspect} must exist in footnotes.xml"
      end
    end
  end

  describe "ISO footnote labels" do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" } }
    let(:adapter) { build_adapter }

    it "uses bare reference numbers including collapsed references", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      xml = labelled_xml('<span class="fmt-label-delim">)</span>')
      xml = xml.sub(" more.</p>", ' more.<fn target="f1" reference="1"><p>Footnote body.</p><fmt-fn-label>1)</fmt-fn-label></fn></p>')
      convert_parts(xml) do |document, footnotes|
        refs = document.xpath("//w:footnoteReference/@w:id", ns).map(&:value)
        expect(refs.size).to eq(2)
        expect(refs.uniq.size).to eq(1)
        paragraph = document.at_xpath("//w:p[w:r/w:footnoteReference]", ns)
        expect(paragraph.xpath("w:r/w:t", ns).text).to eq("Body text more.")
        expect(footnotes.xpath("//w:footnote[not(@w:type)]", ns).size).to eq(1)
      end
    end

    it "keeps the body marker style and space before text", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      convert_parts(labelled_xml('<span class="fmt-label-delim">)</span>')) do |_, footnotes|
        para = body_footnote(footnotes).at_xpath("w:p", ns)
        expect(para.element_children.first.name).to eq("pPr")
        marker = para.xpath("w:r", ns).first
        expect(marker.at_xpath("w:footnoteRef", ns)).not_to be_nil
        expect(marker.at_xpath("w:rPr/w:rStyle/@w:val", ns).value).to eq("FootnoteReference")
        expect(para.xpath("w:r/w:t", ns).text).to eq(" Footnote body.")
      end
    end

    it "also separates a bare presentation label from its body" do
      convert_parts(labelled_xml("")) do |_, footnotes|
        para = body_footnote(footnotes).at_xpath("w:p", ns)
        expect(para.xpath("w:r/w:t", ns).text).to eq(" Footnote body.")
      end
    end
  end
end
