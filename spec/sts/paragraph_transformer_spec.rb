# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::ParagraphTransformer do
  let(:context) { make_context }
  let(:transformer) { described_class.new(context) }

  it "transforms a paragraph with id" do
    para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new
    para.id = "para1"
    para.text = ["Hello world"]

    result = transformer.transform(para)
    expect(result).to be_a(Sts::IsoSts::Paragraph)
  end

  it "skips underscore-prefixed IDs" do
    para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new
    para.id = "_hidden"
    para.text = ["Text"]

    result = transformer.transform(para)
    xml = result.to_xml
    expect(xml).not_to include("_hidden")
  end
end
