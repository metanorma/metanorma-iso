# frozen_string_literal: true

require_relative "spec_helper"
require "asciidoctor"
require "metanorma-iso"

RSpec.describe IsoDoc::Iso::Docx::Adapter do # rubocop:disable RSpec/SpecFilePathFormat
  describe "#drop_source_stems" do
    let(:adapter) { described_class.allocate }
    let(:math) { "<math xmlns=\"http://www.w3.org/1998/Math/MathML\"><mi>x</mi></math>" }

    def drop(body)
      xml = "<metanorma xmlns=\"http://riboseinc.com/isoxml\">#{body}</metanorma>"
      document = Nokogiri::XML(xml)
      adapter.send(:drop_source_stems, document)
      document.root.element_children.first.element_children.map(&:name)
    end

    def stem(id = "s1")
      "<stem id=\"#{id}\" type=\"MathML\">#{math}</stem>"
    end

    def fmt_stem(source, inner = math)
      "<fmt-stem type=\"MathML\"><semx element=\"stem\" source=\"#{source}\">" \
        "#{inner}</semx></fmt-stem>"
    end

    it "drops a formula stem whose fmt-stem renders it as MathML" do
      expect(drop("<formula>#{stem}#{fmt_stem('s1')}<name>1</name></formula>"))
        .to eq(%w[fmt-stem name])
    end

    it "keeps an inline stem, which the inline renderer prints" do
      expect(drop("<p>#{stem}#{fmt_stem('s1')}</p>")).to eq(%w[stem fmt-stem])
    end

    it "keeps a formula stem whose fmt-stem has no MathML to render" do
      expect(drop("<formula>#{stem}#{fmt_stem('s1', '<asciimath>x</asciimath>')}</formula>"))
        .to eq(%w[stem fmt-stem])
    end

    it "keeps a formula stem whose fmt-stem renders another stem" do
      expect(drop("<formula>#{stem}#{fmt_stem('s2')}</formula>")).to eq(%w[stem fmt-stem])
    end

    it "keeps a formula stem without an id" do
      expect(drop("<formula><stem>#{math}</stem>#{fmt_stem('s1')}</formula>"))
        .to eq(%w[stem fmt-stem])
    end

    it "returns malformed input unchanged from the pre-parse step" do
      expect(adapter.send(:prune_for_model, "<a><b></a>")).to eq("<a><b></a>")
    end
  end

  describe "rendered output", type: :feature do
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

        [stem]
        ++++
        r = 1/2 d
        ++++

        |===
        | stem:[0] | stem:[x_1]
        |===
      ADOC
      IsoDoc::Iso::PresentationXMLConvert.new({})
        .convert("test", Asciidoctor.convert(adoc, backend: :iso, header_footer: true), true)
    end

    # Ids that differ on every run.
    let(:random_attributes) { /\s(?:w14:paraId|w14:textId|w:rsid\w*)="[^"]*"/ }

    def parts(adapter)
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(presxml, path)
        Zip::File.open(path) do |zip|
          %w[word/document.xml word/footnotes.xml].to_h do |part|
            [part, zip.find_entry(part).get_input_stream.read.gsub(random_attributes, "")]
          end
        end
      end
    end

    def formula_stem_count(xml)
      Nokogiri::XML(xml).xpath("//*[local-name()='formula']/*[local-name()='stem']").size
    end

    it "drops the formula's source stem before the parse" do
      pruned = described_class.allocate.send(:prune_for_model, presxml)

      expect([formula_stem_count(presxml), formula_stem_count(pruned)]).to eq([1, 0])
    end

    it "writes the same document and footnotes as without the drop", :aggregate_failures do
      kept = described_class.new
      allow(kept).to receive(:drop_source_stems)
      dropped = parts(described_class.new)

      expect(dropped["word/document.xml"]).to include("oMathPara")
        .and include("<m:sub><m:r><m:t>1</m:t>").and include(">0<")
      expect(dropped["word/footnotes.xml"]).to include("t_90")
      expect(dropped).to eq(parts(kept))
    end
  end
end
