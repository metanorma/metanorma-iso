# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::TermRenderer do
  let(:adapter) { build_adapter }

  it "renders the term number with TermNum style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <terms id="terms">
          <title>Terms</title>
          <term id="t1">
            <name>3.1</name>
            <preferred><expression><name>alpha</name></expression></preferred>
          </term>
        </terms>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }
      expect(styles).to include("TermNum"),
        "term number should use TermNum, got: #{styles.inspect}"
    end
  end

  it "renders preferred designation with Terms style when fmt-name is present" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <terms id="terms">
          <title>Terms</title>
          <term id="t1">
            <fmt-name>3.1</fmt-name>
            <fmt-preferred><expression><name>beta</name></expression></fmt-preferred>
          </term>
        </terms>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }
      expect(styles).to include("Terms"),
        "preferred should use Terms style, got: #{styles.inspect}"
    end
  end

  it "renders admitted designation with TermsAdmitted style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <terms id="terms">
          <title>Terms</title>
          <term id="t1">
            <fmt-name>3.1</fmt-name>
            <fmt-preferred><expression><name>primary</name></expression></fmt-preferred>
            <fmt-admitted><expression><name>secondary</name></expression></fmt-admitted>
          </term>
        </terms>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }
      expect(styles).to include("TermsAdmitted"),
        "admitted should use TermsAdmitted, got: #{styles.inspect}"
    end
  end

  it "renders deprecated designation with DeprecatedTerm prefix" do
    # Era C style_mapping maps both alt_terms and deprecated_term to the
    # same styleId (TermsAdmitted); the "DEPRECATED: " prefix carries the
    # semantic distinction.
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <terms id="terms">
          <title>Terms</title>
          <term id="t1">
            <fmt-name>3.1</fmt-name>
            <fmt-preferred><expression><name>current</name></expression></fmt-preferred>
            <fmt-deprecates><expression><name>old</name></expression></fmt-deprecates>
          </term>
        </terms>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      deprecated_paras = pkg.document.body.paragraphs.select do |p|
        text = p.runs.map(&:text).compact.join
        p.properties&.style&.value == "TermsAdmitted" && text.include?("DEPRECATED")
      end
      expect(deprecated_paras.length).to eq(1),
        "expected exactly one deprecated paragraph with DEPRECATED prefix"
    end
  end

  it "renders term notes with Note style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <terms id="terms">
          <title>Terms</title>
          <term id="t1">
            <fmt-name>3.1</fmt-name>
            <fmt-preferred><expression><name>alpha</name></expression></fmt-preferred>
            <termnote id="tn1"><p>Note to entry.</p></termnote>
          </term>
        </terms>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }
      expect(styles).to include("Note"),
        "term note should use Note, got: #{styles.inspect}"
    end
  end

  it "renders term examples with Example style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <terms id="terms">
          <title>Terms</title>
          <term id="t1">
            <fmt-name>3.1</fmt-name>
            <fmt-preferred><expression><name>alpha</name></expression></fmt-preferred>
            <termexample id="te1">
              <fmt-name>EXAMPLE</fmt-name>
              <p>Sample example.</p>
            </termexample>
          </term>
        </terms>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      example_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "Example"
      end
      expect(example_paras.length).to be >= 1,
        "term example name should use Example style"
    end
  end

  it "renders term sources with Source style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <terms id="terms">
          <title>Terms</title>
          <term id="t1">
            <fmt-name>3.1</fmt-name>
            <fmt-preferred><expression><name>alpha</name></expression></fmt-preferred>
            <fmt-termsource status="identical" type="authoritative">[SOURCE: <semx element="source"><origin citeas="ISO 1234:2024"><localityStack><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></localityStack></origin></semx>]</fmt-termsource>
          </term>
        </terms>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      source_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "Source"
      end
      expect(source_paras.length).to eq(1),
        "term source should use Source style"
      text = source_paras.first.runs.map { |r| r.text || "" }.join
      expect(text).to include("SOURCE"),
        "term source paragraph should preserve [SOURCE: ...] text, got: #{text.inspect}"
    end
  end
end
