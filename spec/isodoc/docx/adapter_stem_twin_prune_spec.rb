# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Adapter do # rubocop:disable RSpec/SpecFilePathFormat
  # flatten_number_stems is private; exercised without building a document.
  let(:adapter) { described_class.allocate }
  let(:mathml) { "http://www.w3.org/1998/Math/MathML" }
  let(:complex) { math("<mi>x</mi><mo>+</mo><mn>1</mn>") }
  let(:inline_renderer) do
    context = IsoDoc::Iso::Docx::Context.new
    resolver = IsoDoc::Iso::Docx::StyleResolver.new(
      IsoDoc::Iso::DocxStyleMapping.new, context
    )
    IsoDoc::Iso::Docx::InlineRenderer.new(
      context, resolver, Uniword::Builder::DocumentBuilder.new
    )
  end

  def prune(body)
    xml = "<metanorma xmlns=\"http://riboseinc.com/isoxml\">#{body}</metanorma>"
    Nokogiri::XML(adapter.send(:flatten_number_stems, xml))
  end

  def stem_ids(doc, name)
    doc.xpath("//*[local-name()='#{name}']").map { |n| n["id"] }
  end

  def math(inner)
    "<math xmlns=\"#{mathml}\">#{inner}</math>"
  end

  def fmt_twin(source, content = complex)
    "<fmt-stem><semx source=\"#{source}\">#{content}</semx></fmt-stem>"
  end

  def footnote_text(content)
    xml = "<fn id=\"f\" reference=\"1\"><p id=\"fp\">#{content}</p></fn>"
    fn = parse_model_with_ordering(
      Metanorma::Document::Components::Inline::FnElement, xml
    )
    inline_renderer.send(:footnote_body_text, fn.p.first)
  end

  def stem_pair(asciimath, content: math("<mi>x</mi>"), id: "s1")
    am = "<asciimath>#{asciimath}</asciimath>"
    "<stem type=\"MathML\" id=\"#{id}\">#{content}#{am}</stem>" \
      "<fmt-stem type=\"MathML\"><semx element=\"stem\" source=\"#{id}\">" \
      "#{content}#{am}</semx></fmt-stem>"
  end

  describe "pruning in flatten_number_stems" do
    it "drops a semantic stem whose fmt-stem twin is on the same parent" do
      doc = prune("<p id=\"p\"><stem id=\"s1\">#{complex}</stem> #{fmt_twin('s1')}</p>")

      expect(stem_ids(doc, "stem")).to be_empty
    end

    it "keeps the fmt-stem of a pruned pair" do
      doc = prune("<p id=\"p\"><stem id=\"s1\">#{complex}</stem>#{fmt_twin('s1')}</p>")

      expect(doc.xpath("//*[local-name()='fmt-stem']//*[local-name()='mi']"))
        .not_to be_empty
    end

    it "keeps a stem that has no twin" do
      doc = prune("<p id=\"p\"><stem id=\"s1\">#{complex}</stem>" \
                  "#{fmt_twin('other')}<stem id=\"s2\">#{complex}</stem></p>")

      expect(stem_ids(doc, "stem")).to eq(%w[s1 s2])
    end

    it "keeps a stem whose twin sits on a different parent" do
      doc = prune("<p id=\"a\"><stem id=\"s1\">#{complex}</stem></p>" \
                  "<p id=\"b\">#{fmt_twin('s1')}</p>")

      expect(stem_ids(doc, "stem")).to eq(["s1"])
    end

    it "keeps the text around a pruned stem" do
      doc = prune("<p id=\"p\">a <stem id=\"s1\">#{complex}</stem> b" \
                  "#{fmt_twin('s1')}</p>")

      expect(doc.at_xpath("//*[local-name()='p']").text)
        .to include("a ").and include(" b")
    end

    it "keeps the stem under a semx parent, where the model drops fmt-stem" do
      doc = prune("<semx element=\"name\" source=\"n\">Temp " \
                  "<stem id=\"s1\">#{complex}</stem>#{fmt_twin('s1')}</semx>")

      expect(stem_ids(doc, "stem")).to eq(["s1"])
    end

    it "drops the fmt-stem under a semx parent" do
      doc = prune("<semx element=\"name\" source=\"n\">Temp " \
                  "<stem id=\"s1\">#{complex}</stem>#{fmt_twin('s1')}</semx>")

      expect(doc.xpath("//*[local-name()='fmt-stem']")).to be_empty
    end

    context "with a numeric stem under a semx parent" do
      def semx_pair(raw, formatted, asciimath)
        am = "<asciimath>#{asciimath}</asciimath>"
        prune("<semx element=\"name\" source=\"n\">Range " \
              "<stem id=\"s1\">#{math(raw)}#{am}</stem>" \
              "<fmt-stem><semx source=\"s1\">#{math(formatted)}#{am}" \
              "</semx></fmt-stem></semx>")
      end

      let(:doc) do
        semx_pair("<mn>1770.9</mn>", "<mn>1 770,9</mn>", "1770.9")
      end

      def stem
        doc.at_xpath("//*[local-name()='stem']")
      end

      it "keeps the formatted number" do
        expect(stem.text).to include("1 770,9")
      end

      it "drops the semantic number" do
        expect(stem.text).not_to include("1770.9")
      end

      it "keeps the stem id and a single stem" do
        expect(stem_ids(doc, "stem")).to eq(["s1"])
      end

      it "leaves the asciimath of a unit stem untouched" do
        unit = "<mn>1 770,9</mn><mi>hPa</mi>"
        out = semx_pair("<mn>1770.9</mn>", unit, "1770.9 hPa")

        expect(out.at_xpath("//*[local-name()='asciimath']").text)
          .to eq("1770.9 hPa")
      end
    end
  end

  describe "footnote body text" do
    it "renders a footnote stem and its fmt-stem twin once" do
      expect(footnote_text("Mean #{stem_pair('"CO"_2')}, 2025."))
        .to eq('Mean "CO"_2, 2025.')
    end

    it "does not duplicate a footnote stem that has no twin" do
      solo = "<stem type=\"AsciiMath\" id=\"s9\"><asciimath>K_L</asciimath></stem>"

      expect(footnote_text("Mean #{solo}.")).to eq("Mean K_L.")
    end

    context "with a UnitsML stem" do
      let(:text) do
        unit = math("<mstyle><mn>9.8</mn><mo>&#x2062;</mo>" \
                    "<mrow xref=\"U_NISTu1\"><mstyle mathvariant=\"normal\">" \
                    "<mi>m</mi></mstyle></mrow></mstyle>")
        footnote_text("Value #{stem_pair('9.8 "unitsml(m)"', content: unit)}.")
      end

      it "shows the rendered unit, not the unitsml source" do
        expect(text).not_to include("unitsml(")
      end

      it "shows the quantity once" do
        expect(text.scan(/9[.,]8/).length).to eq(1)
      end
    end
  end
end
