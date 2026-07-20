# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::CommentRenderer do
  let(:adapter) { build_adapter }
  let(:resolver) { adapter.resolver }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { adapter.send(:create_document) }
  let(:inline) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }
  let(:renderer) { described_class.new(resolver, inline) }

  # Parse an <annotation-container> fragment into the structured model the
  # renderer consumes (fmt-annotation-body elements live in the body inline
  # flow, not in the container).
  def parse_container(inner)
    Metanorma::IsoDocument::AnnotationContainer.from_xml(
      "<annotation-container xmlns=\"https://www.metanorma.org/ns/iso\">" \
      "#{inner}</annotation-container>"
    )
  end

  def comment_text(comment)
    comment.paragraphs.flat_map do |p|
      p.runs.flat_map { |r| Array(r.text).map(&:to_s) }
    end.join
  end

  describe "#render" do
    it "parses annotations from the annotation_container model" do
      container = parse_container(<<~XML)
        <annotation date="2026-01-01" reviewer="ISO" id="ann1" from="s1" to="s1">
          <p>Test comment.</p>
        </annotation>
      XML

      result = renderer.render(container, doc)

      expect(result).not_to be_nil
      expect(result.count).to eq(1)
      comment = result.comments.first
      expect(comment.author).to eq("ISO")
      expect(comment_text(comment)).to include("Test comment.")
    end

    it "assigns sequential comment IDs" do
      container = parse_container(<<~XML)
        <annotation date="2026-01-01" reviewer="A" id="a1"><p>First</p></annotation>
        <annotation date="2026-01-01" reviewer="B" id="a2"><p>Second</p></annotation>
      XML

      result = renderer.render(container, doc)

      expect(result.count).to eq(2)
      expect(result.comments.first.comment_id).to eq("1")
      expect(result.comments.last.comment_id).to eq("2")
    end

    it "maps annotation IDs to comment IDs" do
      container = parse_container(<<~XML)
        <annotation date="2026-01-01" reviewer="ISO" id="a1"><p>Test</p></annotation>
      XML

      renderer.render(container, doc)

      expect(renderer.comment_id_map).to include("a1" => "1")
    end

    it "handles nil annotation_container" do
      result = renderer.render(nil, doc)
      expect(result).to be_nil
    end

    it "handles a container with no annotations" do
      container = parse_container("")
      result = renderer.render(container, doc)
      expect(result).to be_nil
    end

    it "looks up comment IDs by annotation target ID" do
      container = parse_container(<<~XML)
        <annotation date="2026-01-01" reviewer="ISO" id="target-456"><p>Test</p></annotation>
      XML

      renderer.render(container, doc)

      expect(renderer.lookup_comment_id("target-456")).to eq("1")
      expect(renderer.lookup_comment_id("nonexistent")).to be_nil
    end
  end
end
