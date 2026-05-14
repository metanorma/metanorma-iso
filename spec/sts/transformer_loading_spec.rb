# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe "Transformer module loading" do
  it "loads all transformer classes" do
    expect(Metanorma::Iso::Sts::Transformer::Base).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::Context).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::IsoMetaTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::FrontTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::BodyTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::BackTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::SectionTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::ParagraphTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::InlineTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::ListTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::DefListTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::NoteTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::ExampleTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::IdGenerator).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::NbspProcessor).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::DocumentTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::FootnoteCollector).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::BlockDispatcher).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::TableTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::FigureTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::FormulaTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::SourcecodeTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::QuoteTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::TermTransformer).to be_a(Class)
    expect(Metanorma::Iso::Sts::Transformer::ReferenceTransformer).to be_a(Class)
  end

  it "contains zero respond_to? calls in any transformer source file" do
    transformer_dir = File.join(__dir__, "..", "..", "lib", "metanorma", "iso",
                                "sts", "transformer")
    count = 0
    Dir.glob("#{transformer_dir}/**/*.rb").each do |f|
      c = File.read(f).scan("respond_to?").length
      count += c
    end
    expect(count).to eq(0),
                     "Found #{count} respond_to? calls in transformer files"
  end

  it "contains no rescue NoMethodError in transformer files" do
    transformer_dir = File.join(__dir__, "..", "..", "lib", "metanorma", "iso",
                                "sts", "transformer")
    violations = []
    Dir.glob("#{transformer_dir}/**/*.rb").each do |f|
      lines = File.readlines(f)
      lines.each_with_index do |line, i|
        violations << "#{f}:#{i + 1}" if line.include?("rescue NoMethodError")
      end
    end
    expect(violations).to be_empty,
                          "Found rescue NoMethodError in: #{violations.join(', ')}"
  end

  it "contains no send(:private_method, ...) in transformer files" do
    transformer_dir = File.join(__dir__, "..", "..", "lib", "metanorma", "iso",
                                "sts", "transformer")
    violations = []
    Dir.glob("#{transformer_dir}/**/*.rb").each do |f|
      lines = File.readlines(f)
      lines.each_with_index do |line, i|
        violations << "#{f}:#{i + 1}" if line.match?(/\.send\(:\w+,/)
      end
    end
    expect(violations).to be_empty,
                          "Found send(:private, ...) in: #{violations.join(', ')}"
  end
end
