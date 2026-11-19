# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::ParagraphRenderer do
  let(:adapter) { build_adapter }

  it "renders a plain paragraph in the default body zone without an explicit rstyle" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p>A plain body paragraph.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      plain = pkg.document.body.paragraphs.find do |p|
        p.runs.any? { |r| r.text.to_s.include?("A plain body paragraph") }
      end
      expect(plain).not_to be_nil
      # Era C body text uses the document default; no rStyle is required.
      style_value = para_style_value(plain)
      expect(style_value).to be_nil.or eq("Bodytext")
    end
  end

  it "skips paragraphs with class zzSTDTitle (cover title duplicates)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p class="zzSTDTitle">Spurious cover title</p>
          <p>Real body text.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      texts = pkg.document.body.paragraphs.flat_map { |p| p.runs.map(&:text) }
      expect(texts.join).not_to include("Spurious cover title"),
        "zzSTDTitle paragraph should be suppressed"
    end
  end

  it "applies explicit alignment when present" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p align="center">Centered text.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      centered = pkg.document.body.paragraphs.find do |p|
        p.runs.any? { |r| r.text.to_s.include?("Centered text") }
      end
      expect(centered).not_to be_nil
      align = centered.properties&.alignment&.value
      expect(align).to eq("center"),
        "align=center should map to paragraph alignment center, got: #{align.inspect}"
    end
  end

  it "renders floating-title paragraphs with heading style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p type="floating-title" depth="2">Sub-heading</p>
          <p>Body text.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      heading_paras = pkg.document.body.paragraphs.select do |p|
        style_id = para_style_value(p).to_s
        style_id.start_with?("Heading")
      end
      expect(heading_paras).not_to be_empty,
        "floating-title should produce a Heading* paragraph"
    end
  end

  it "splits a paragraph with an embedded <note> into siblings" do
    xml = minimal_iso_xml(<<~INNER)
      <bibdata>
        <docidentifier type="ISO">ISO 1234</docidentifier>
        <title language="en" format="plain">Split Note</title>
        <status><stage>60</stage></status>
      </bibdata>
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <p id="p1">Body text before note.<note id="n1"><p id="np1">Lower mass fractions of moisture are sometimes needed.</p></note></p>
          <p id="p2">Body paragraph after.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      paragraphs = pkg.document.body.paragraphs
      body_texts = paragraphs.map { |p| p.runs.map(&:text).join }
      joined = body_texts.join

      # Inline content before the note is preserved.
      expect(joined).to include("Body text before note."),
        "text before embedded note should be rendered"
      # Sibling paragraph after the note is preserved.
      expect(joined).to include("Body paragraph after."),
        "sibling paragraph after embedded note should be rendered"
      # The note's body text is rendered (not silently dropped).
      expect(joined).to include("Lower mass fractions of moisture"),
        "embedded note body text should be rendered"

      # The embedded note follows the XSL inline-label contract: the
      # note body lands in a Noteindent paragraph and no Era C box is
      # drawn around it.
      styles = paragraphs.map { |p| para_style_value(p).to_s }
      expect(styles).not_to include("Box-begin"),
        "embedded note must not be wrapped in Box-begin"
      expect(styles).to include("Noteindent"),
        "embedded note body should use Noteindent style"
      expect(styles).not_to include("Box-end"),
        "embedded note must not be wrapped in Box-end"
    end
  end
  # Presentation XML keeps the semantic <stem> next to the <fmt-stem>
  # that renders it. Paragraphs, cells and paragraphs split around a
  # note printed both ("t_90t_90" in the ISO 2533 test method).
  describe "a stem followed by its fmt-stem" do
    def stem_pair(id, sym)
      math = %(<math xmlns="http://www.w3.org/1998/Math/MathML"><mi>#{sym}</mi></math>)
      %(<stem type="MathML" id="#{id}">#{math}<asciimath>#{sym}</asciimath></stem>) +
        %(<fmt-stem type="MathML"><semx element="stem" source="#{id}">#{math}) +
        %(<asciimath>#{sym}</asciimath></semx></fmt-stem>)
    end

    let(:texts) do
      xml = minimal_iso_xml(<<~INNER)
        <sections><clause id="c1"><title>Scope</title>
          <p>PLAIN #{stem_pair("s1", "pa")} end</p>
          <p>SPLIT #{stem_pair("s2", "sp")} mid <note id="n1"><p>inner</p></note> tail #{stem_pair("s3", "sq")}</p>
          <table id="t1"><thead><tr><th>#{stem_pair("s4", "th")}</th></tr></thead>
            <tbody><tr><td><p>CELL #{stem_pair("s5", "td")}</p></td></tr></tbody></table>
        </clause></sections>
      INNER
      texts = nil
      convert_and_extract(adapter, xml) do |pkg|
        ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
               "m" => "http://schemas.openxmlformats.org/officeDocument/2006/math" }
        doc = Nokogiri::XML(pkg.document.to_xml)
        texts = doc.xpath("//w:p", ns).map { |p| p.xpath(".//m:t | .//w:t", ns).map(&:text).join }
      end
      texts
    end

    it "renders each symbol once", :aggregate_failures do
      expect(texts).to include("PLAIN pa end", "SPLIT sp mid ", " tail sq", "th", "CELL td")
      expect(texts.join).not_to match(/papa|spsp|sqsq|thth|tdtd/)
    end
  end
end
