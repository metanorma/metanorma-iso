# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::FigureRenderer do
  let(:adapter) { build_adapter }

  let(:subfigure_xml) do
    tiny_png = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAA9JREFUCNdj+M+ABf3HCwEACJ8FL0AAAAAASUVORK5CYII="
    subfigures = %w[a b c].map do |label|
      <<~XML
        <figure id="fig-#{label}">
          <fmt-name>#{label})</fmt-name>
          <image src="#{tiny_png}" width="100" height="100"/>
        </figure>
      XML
    end.join
    minimal_iso_xml(<<~XML)
      <sections><clause id="c1"><title>Scope</title>
        <figure id="fig"><fmt-name>Figure 1</fmt-name>
          #{subfigures}
        </figure>
      </clause></sections>
    XML
  end

  let(:subfigure_image_counts) do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      adapter.convert(subfigure_xml, path)
      Zip::File.open(path) do |zip|
        document = Nokogiri::XML(zip.read("word/document.xml"))
        relationships = Nokogiri::XML(zip.read("word/_rels/document.xml.rels"))
        embeds = document.xpath(
          "//a:blip/@r:embed",
          "a" => "http://schemas.openxmlformats.org/drawingml/2006/main",
          "r" => "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
        ).map(&:value)
        targets = embeds.map do |id|
          relationships.at_xpath("//*[@Id='#{id}']")["Target"]
        end

        parts = targets.uniq.count do |target|
          zip.find_entry("word/#{target}")
        end
        { placements: embeds.size, parts: parts }
      end
    end
  end

  it "packages one image part for each subfigure a/b/c" do
    expect(subfigure_image_counts).to eq(placements: 3, parts: 3)
  end

  it "renders figure name with Figuretitle style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <figure id="f1">
            <name>Figure 1 — Sample</name>
            <image src="spec/fixtures/dummy.png" mimetype="image/png" height="100" width="100"/>
          </figure>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }

      expect(styles).to include("Figuretitle"),
        "figure name should use Figuretitle, got: #{styles.inspect}"
    end
  end

  it "renders figure notes with Figurenote style (not generic Noteindent)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <figure id="f1">
            <name>Figure 1 — Sample</name>
            <note id="fnote1"><p>Source: own elaboration.</p></note>
          </figure>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }

      expect(styles).to include("Figurenote"),
        "figure note should use Figurenote, got: #{styles.inspect}"
    end
  end

  # Presentation XML keeps the semantic <stem> and adds an <fmt-stem> twin
  # inside the caption's <semx>; the caption must show the stem once, as
  # text, the way body paragraphs do.
  def caption_stem_xml
    '<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mrow><mn>80</mn><mo rspace="thickmathspace">&#x2062;</mo><mrow xref="U_km"><mstyle mathvariant="normal"><mi>km</mi></mstyle></mrow></mrow></math><asciimath>80 "unitsml(km)"</asciimath></stem>' \
      '<fmt-stem type="MathML"><semx element="stem" source="s1"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>80</mn></math><asciimath>80 "unitsml(km)"</asciimath></semx></fmt-stem>'
  end

  it "keeps a stem inside the figure caption, once, as text" do
    name = "<fmt-name><semx element=\"name\">Fig #{caption_stem_xml}</semx></fmt-name>"
    xml = minimal_iso_xml("<sections><clause id=\"c1\"><title>Scope</title><figure id=\"f1\">%s</figure></clause></sections>" % name)
    convert_and_extract(adapter, xml) do |pkg|
      para = pkg.document.body.paragraphs.find { |x| para_style_value(x) == "Figuretitle" }
      expect(para.runs.map { |r| run_text(r) }.join).to eq("Fig 80 km")
    end
  end
end
