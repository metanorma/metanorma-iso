# frozen_string_literal: true

require_relative "spec_helper"
require "metanorma-iso"

# This integration spec belongs with the DOCX specs.
RSpec.describe Metanorma::Iso::Processor, "#output" do # rubocop:disable RSpec/SpecFilePathFormat
  let(:fixture) do
    File.expand_path(
      "../../fixtures/iso/is/document-en.dis.presentation.xml", __dir__
    )
  end
  let(:source) { Nokogiri::XML(File.read(fixture)).remove_namespaces! }

  it "renders a distinct styled paragraph for each source element" do
    expect(missing_source_paragraphs).to be_empty
  end

  def missing_source_paragraphs
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      Metanorma::Iso::Processor.new.output(nil, fixture, path, :docx)
      extract_docx(path) { |doc, _| compare_source(doc.remove_namespaces!) }
    end
  end

  def compare_source(doc)
    note_styles = %w[Note Noteindent]
    example_styles = %w[Example Exampleindent]
    [
      ["//clause/p/note | //term/termnote", 6, note_styles, "//body/p", "./p"],
      ["//table/note", 3, note_styles, "//tc/p", "./p"],
      ["//figure/note", 1, %w[Figurenote], "//body/p", "./p"],
      ["//term/termexample", 1, example_styles, "//body/p", "./p"],
      ["//annex//example", 1, example_styles, "//body/p", "./fmt-name"],
      ["//term/definition", 15, %w[Definition], "//body/p", "./verbal-definition/p"],
    ].flat_map do |xpath, count, styles, location, first|
      compare_paragraphs(doc, xpath, count, styles, location, first)
    end
  end

  def compare_paragraphs(doc, xpath, count, styles, location, first)
    elements = source.xpath(xpath)
    return ["#{xpath}: expected #{count} elements, found #{elements.size}"] unless elements.size == count

    paragraphs = styled_paragraph_text(doc, location, styles)
    elements.filter_map do |element|
      text = first_paragraph_fragment(element.at_xpath(first))
      index = paragraphs.index { |paragraph| paragraph.include?(text) }
      # Consume the match so identical term notes need separate paragraphs.
      next if index && paragraphs.delete_at(index)

      "#{element.path}: missing #{styles.join('/')} paragraph containing #{text.inspect}"
    end
  end

  def styled_paragraph_text(doc, location, styles)
    doc.xpath(location).filter_map do |paragraph|
      style = paragraph.at_xpath("pPr/pStyle")&.[]("val")
      normalize(paragraph.xpath(".//t").map(&:text).join) if styles.include?(style)
    end
  end

  def first_paragraph_fragment(paragraph)
    # Use a prose fragment from the first paragraph. References and footnotes
    # can interrupt that prose with Word fields and footnote markers.
    text = paragraph.xpath(".//text()[not(ancestor::fn or ancestor::concept or ancestor::eref or ancestor::xref)]")
    text.map { |node| normalize(node.text) }.max_by(&:length)
  end

  def normalize(text)
    text.tr("\u00a0", " ").split.join(" ")
  end
end
