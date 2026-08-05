# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::PageBreakRenderer do
  let(:renderer) { described_class.new }

  it "calls #page_break on the document" do
    doc = FakeDoc.new
    renderer.render(:anything, doc)
    expect(doc.calls).to eq([:page_break])
  end
end

RSpec.describe IsoDoc::Iso::Docx::Renderers::HorizontalRuleRenderer do
  let(:renderer) { described_class.new }

  it "calls #horizontal_rule on the document" do
    doc = FakeDoc.new
    renderer.render(:anything, doc)
    expect(doc.calls).to eq([:horizontal_rule])
  end
end

RSpec.describe IsoDoc::Iso::Docx::Renderers::NullRenderer do
  let(:renderer) { described_class.new }

  it "returns nil and has no side effect on the document" do
    doc = FakeDoc.new
    expect(renderer.render(:anything, doc)).to be_nil
    expect(doc.calls).to be_empty
  end
end

# Minimal stand-in for a Uniword document builder. Records method calls
# so specs can assert that the renderer invoked the right side-effect
# method (e.g. +#page_break+).
class FakeDoc
  attr_reader :calls

  def initialize
    @calls = []
  end

  def page_break
    @calls << :page_break
  end

  def horizontal_rule
    @calls << :horizontal_rule
  end
end
