# frozen_string_literal: true

require "bundler/setup"
require "metanorma/document"
require "metanorma-iso"
require "metanorma/iso/document"
require "metanorma/iso/html"

RSpec.describe Metanorma::Iso::Html::Renderer do
  let(:fixture) do
    File.expand_path("../../../fixtures/samples/international-standard/document-en.presentation.xml", __dir__)
  end
  let(:document) { Metanorma::Iso::Document::Root.from_xml(File.read(fixture)) }
  let(:renderer) { described_class.new }
  let(:paragraph_class) { Metanorma::Document::Components::Paragraphs::ParagraphBlock }

  def section_paragraphs(doc)
    renderer.send(:collect_document_children, doc).grep(paragraph_class)
  end

  it "has title paragraphs in the fixture sections" do
    expect(renderer.send(:collect_ordered_children, document.sections).grep(paragraph_class)).not_to be_empty
  end

  it "drops section paragraphs when the ISO document title is rendered" do
    expect(renderer.send(:render_doc_title, document)).not_to be_empty
    expect(section_paragraphs(document)).to be_empty
  end

  it "keeps title paragraphs when no document title is rendered" do
    allow(renderer).to receive(:render_doc_title).and_return(nil)
    kept = section_paragraphs(document)
    expect(kept).not_to be_empty
    expect(kept.map { |p| p.class_attr.to_s }).to all(start_with("zzSTDTitle"))
  end
end
