# frozen_string_literal: true

require_relative "spec_helper"
require "asciidoctor"
require "metanorma-iso"

RSpec.describe IsoDoc::Iso::Docx::Adapter do # rubocop:disable RSpec/SpecFilePathFormat
  describe "#drop_source_stems" do
    let(:adapter) { described_class.allocate }

    def drop(body)
      xml = "<metanorma xmlns=\"http://riboseinc.com/isoxml\"><p>#{body}</p></metanorma>"
      Nokogiri::XML(adapter.send(:drop_source_stems, xml))
        .xpath("//*[local-name()='p']/*").map(&:name)
    end

    def fmt_stem(source)
      "<fmt-stem type=\"MathML\"><semx element=\"stem\" source=\"#{source}\">" \
        "<asciimath>x</asciimath></semx></fmt-stem>"
    end

    it "drops a stem whose fmt-stem sibling points back to it" do
      expect(drop("<stem id=\"s1\"><asciimath>x</asciimath></stem>#{fmt_stem('s1')}"))
        .to eq(["fmt-stem"])
    end

    it "keeps a stem that no fmt-stem renders" do
      expect(drop("<stem id=\"s1\"><asciimath>x</asciimath></stem>")).to eq(["stem"])
    end

    it "keeps a stem whose next fmt-stem renders another stem" do
      expect(drop("<stem id=\"s1\"><asciimath>x</asciimath></stem>#{fmt_stem('s2')}"))
        .to eq(%w[stem fmt-stem])
    end

    it "keeps a stem without an id" do
      expect(drop("<stem><asciimath>x</asciimath></stem>#{fmt_stem('s1')}"))
        .to eq(%w[stem fmt-stem])
    end

    it "returns malformed input unchanged" do
      expect(adapter.send(:drop_source_stems, "<a><b></a>")).to eq("<a><b></a>")
    end
  end

  # Inline renderers walk every child, so the source <stem> beside a
  # <fmt-stem> printed each symbol twice ("0" "0" in a table cell).
  describe "rendered runs", type: :feature do
    let(:presxml) do
      adoc = <<~ADOC
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:
        :no-isobib:

        == Clause

        The time stem:[t_90] is short.footnote:[See stem:[t_90].]

        |===
        | stem:[0] | stem:[x_1]
        |===
      ADOC
      IsoDoc::Iso::PresentationXMLConvert.new({})
        .convert("test", Asciidoctor.convert(adoc, backend: :iso, header_footer: true), true)
    end
    let(:kept) do
      adapter = described_class.new
      allow(adapter).to receive(:drop_source_stems) { |xml| xml }
      runs(adapter)
    end
    let(:dropped) { runs(described_class.new) }

    def runs(adapter)
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(presxml, path)
        Zip::File.open(path) do |zip|
          ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
          %w[word/document.xml word/footnotes.xml].to_h do |part|
            xml = Nokogiri::XML(zip.find_entry(part).get_input_stream.read)
            [part, xml.xpath("//w:p", ns).map { |p| p.xpath("w:r", ns).map(&:to_xml) }]
          end
        end
      end
    end

    def paragraph(runs, text)
      runs.find { |p| p.join.include?(text) }
    end

    [">0<", ">x_1<", "The time "].each do |text|
      it "renders the stem in #{text.inspect} once, as the fmt-stem run", :aggregate_failures do
        after = paragraph(dropped["word/document.xml"], text)

        expect(paragraph(kept["word/document.xml"], text).uniq).to eq(after)
        expect(after.join.scan(/>(?:0|x_1|t_90)</).size).to eq(1)
      end
    end

    it "keeps every other paragraph unchanged" do
      stem_free = ->(all) { all.reject { |p| p.join.match?(/>(?:0|x_1|t_90)</) } }

      expect(stem_free.call(dropped["word/document.xml"]))
        .to eq(stem_free.call(kept["word/document.xml"]))
    end

    it "renders a footnote symbol once" do
      expect(dropped["word/footnotes.xml"].join).to include("See t_90.")
    end
  end
end
