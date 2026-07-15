# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::CommentRenderer do
  let(:adapter) { build_adapter }
  let(:resolver) { adapter.resolver }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { adapter.send(:create_document) }
  let(:inline) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }
  let(:renderer) { described_class.new(resolver, inline) }

  describe "#render" do
    it "parses annotations from annotation_container content" do
      content = <<~XML
        <annotation date="2026-01-01" reviewer="ISO" id="ann1" from="s1" to="s1">
          <p>Test comment.</p>
        </annotation>
        <fmt-annotation-body date="2026-01-01" reviewer="ISO" id="fab1" from="s1" to="s1">
          <p>Test comment.</p>
        </fmt-annotation-body>
      XML

      container = Struct.new(:content).new(content)
      result = renderer.render(container, doc)

      expect(result).not_to be_nil
      expect(result.count).to eq(1)
      comment = result.comments.first
      expect(comment.author).to eq("ISO")
      expect(comment.text).to include("Test comment.")
    end

    it "assigns sequential comment IDs" do
      content = <<~XML
        <annotation date="2026-01-01" reviewer="A" id="a1"><p>First</p></annotation>
        <fmt-annotation-body date="2026-01-01" reviewer="A" id="f1"><p>First</p></fmt-annotation-body>
        <annotation date="2026-01-01" reviewer="B" id="a2"><p>Second</p></annotation>
        <fmt-annotation-body date="2026-01-01" reviewer="B" id="f2"><p>Second</p></fmt-annotation-body>
      XML

      container = Struct.new(:content).new(content)
      result = renderer.render(container, doc)

      expect(result.count).to eq(2)
      expect(result.comments.first.comment_id).to eq("1")
      expect(result.comments.last.comment_id).to eq("2")
    end

    it "maps fmt-annotation-body IDs to comment IDs" do
      content = <<~XML
        <annotation date="2026-01-01" reviewer="ISO" id="a1"><p>Test</p></annotation>
        <fmt-annotation-body date="2026-01-01" reviewer="ISO" id="fab-uuid-123"><p>Test</p></fmt-annotation-body>
      XML

      container = Struct.new(:content).new(content)
      renderer.render(container, doc)

      expect(renderer.comment_id_map).to include("fab-uuid-123" => "1")
    end

    it "handles nil annotation_container" do
      result = renderer.render(nil, doc)
      expect(result).to be_nil
    end

    it "handles empty content" do
      container = Struct.new(:content).new("")
      result = renderer.render(container, doc)
      expect(result).to be_nil
    end

    it "looks up comment IDs by annotation target ID" do
      content = <<~XML
        <annotation date="2026-01-01" reviewer="ISO" id="a1"><p>Test</p></annotation>
        <fmt-annotation-body date="2026-01-01" reviewer="ISO" id="target-456"><p>Test</p></fmt-annotation-body>
      XML

      container = Struct.new(:content).new(content)
      renderer.render(container, doc)

      expect(renderer.lookup_comment_id("target-456")).to eq("1")
      expect(renderer.lookup_comment_id("nonexistent")).to be_nil
    end
  end
end
