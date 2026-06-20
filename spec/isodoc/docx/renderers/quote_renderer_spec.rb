# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::QuoteRenderer do
  let(:adapter) { build_adapter }

  it "renders block quote with Disp-quotep style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <quote id="q1">
            <p>To be or not to be.</p>
            <author>Shakespeare</author>
          </quote>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }

      expect(styles).to include("Disp-quotep"),
        "quote should use Disp-quotep style, got: #{styles.inspect}"
    end
  end

  it "does not Box-wrap quotes (only Note/Example/Admonition use Box)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <quote id="q1">
            <p>A quotable line.</p>
          </quote>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }
      quote_index = styles.index("Disp-quotep")
      expect(quote_index).to be_truthy

      before_quote = styles.take(quote_index)
      after_quote = styles.drop(quote_index + 1)

      adjacent_box = [before_quote.last, after_quote.first].compact
      expect(adjacent_box).not_to include("Box-begin"),
        "Box-begin should not wrap quotes"
      expect(adjacent_box).not_to include("Box-end"),
        "Box-end should not wrap quotes"
    end
  end

  it "renders quote attribution with Disp-quoteattrib style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <quote id="q1">
            <p>To be or not to be.</p>
            <attribution><p>— Shakespeare, Hamlet</p></attribution>
          </quote>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }

      expect(styles).to include("Disp-quotep"),
        "quote body should use Disp-quotep, got: #{styles.inspect}"
      expect(styles).to include("Disp-quoteattrib"),
        "attribution should use Disp-quoteattrib, got: #{styles.inspect}"

      attrib_index = styles.index("Disp-quoteattrib")
      body_index = styles.index("Disp-quotep")
      expect(attrib_index).to be > body_index,
        "attribution should follow body, got body=#{body_index} attrib=#{attrib_index}"
    end
  end

  it "renders each paragraph of a multi-paragraph quote as its own paragraph" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <quote id="q1">
            <p>First quoted paragraph.</p>
            <p>Second quoted paragraph.</p>
          </quote>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      quote_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "Disp-quotep"
      end

      expect(quote_paras.length).to eq(2),
        "expected 2 Disp-quotep paragraphs, got: #{quote_paras.length}"
    end
  end
end
