# frozen_string_literal: true

require "bundler/setup"
require "rspec"
require "tmpdir"
require "base64"
require "rake"
require "isodoc/iso/docx/mhtml_parity"

RSpec.describe IsoDoc::Iso::Docx::MhtmlParity do
  let(:fixtures) { File.expand_path("../../fixtures/docx_parity", __dir__) }
  let(:submitted) { File.join(fixtures, "submitted.mhtml") }
  let(:document) { File.read(File.join(fixtures, "document.xml")) }
  let(:styles) { File.read(File.join(fixtures, "styles.xml")) }

  around do |example|
    Dir.mktmpdir("parity-spec-") do |dir|
      @dir = dir
      example.run
    end
  end

  def docx(document_xml = document, styles_xml = styles)
    path = File.join(@dir, "output.docx")
    Zip::OutputStream.open(path) do |zip|
      zip.put_next_entry("word/document.xml")
      zip.write(document_xml)
      zip.put_next_entry("word/styles.xml")
      zip.write(styles_xml)
    end
    path
  end

  def mhtml(body, encoding: "base64")
    html = "<html><body>#{body}</body></html>"
    encoded = encoding == "base64" ? Base64.strict_encode64(html) : html
    path = File.join(@dir, "output.doc")
    File.write(path, <<~MIME.gsub("\n", "\r\n"))
      MIME-Version: 1.0
      Content-Type: multipart/related; boundary="output"

      --output
      Content-Type: text/html; charset=utf-8
      Content-Transfer-Encoding: #{encoding}

      #{encoded}
      --output--
    MIME
    path
  end

  it "normalizes submitted MHTML and DOCX to the same ordered structure/styles" do
    comparison = described_class.new(submitted, docx)

    expect(comparison).to be_match
    expect(comparison.report).to include("MATCH (15 structure/style tokens)")
    expect(described_class.normalize(submitted)).to eq([
      "heading1|heading1", "paragraph|bodytext", "note|note", "example|example",
      "table|tablegrid", "row", "cell", "paragraph|normal", "/cell", "/row", "/table",
      "paragraph|dimension100", "figure", "paragraph|figuretitle", "paragraph|normal",
    ])
  end

  it "decodes base64 and CRLF in a Uniword-style .doc" do
    output = mhtml('<h1>Scope</h1><p class="BodyText">Body</p>' \
                   '<p class="Note">Note</p><p class="Example">Example</p>' \
                   '<table class="TableGrid"><tr><td><p>Cell</p></td></tr></table>' \
                   '<p class="Dimension100"><img src="changed.png"></p>' \
                   '<p class="FigureTitle">Caption</p><p>Closing</p>')

    expect(described_class.new(submitted, output)).to be_match
  end

  it "uses the MIME start part even when another HTML part comes first" do
    path = File.join(@dir, "root-part.doc")
    content = File.read(submitted)
      .sub('boundary="parity-fixture"', 'boundary="parity-fixture"; start="<main>"')
      .sub("Content-Location: file:///submitted.htm", "Content-ID: <main>\nContent-Location: file:///submitted.htm")
      .sub("--parity-fixture\n", "--parity-fixture\nContent-Type: text/html\n\n<html><body><p>Header</p></body></html>\n--parity-fixture\n")
    File.write(path, content)

    expect(described_class.new(submitted, path)).to be_match
  end

  it "reports style substitutions with positions on both sides" do
    output = docx(document.sub('w:val="note-id"', 'w:val="example-id"'))
    comparison = described_class.new(submitted, output)

    expect(comparison).not_to be_match
    expect(comparison.report).to include("- 3: note|note", "+ 3: example|example")
  end

  it "aligns a missing paragraph without cascading differences" do
    xml = Nokogiri::XML(document)
    xml.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='body-id']]", described_class::W).remove
    report = described_class.new(submitted, docx(xml.to_xml)).report

    expect(report.lines.grep(/^[+-] /)).to eq(["- 2: paragraph|bodytext"])
  end

  it "reports inserted paragraphs" do
    output = docx(document.sub("<w:sectPr/>", '<w:p><w:pPr><w:pStyle w:val="NewStyle"/></w:pPr></w:p>'))

    expect(described_class.new(submitted, output).report).to include("+ 16: paragraph|newstyle")
  end

  it "detects heading level changes even when style names agree" do
    changed_styles = styles.sub('w:outlineLvl w:val="0"', 'w:outlineLvl w:val="1"')

    expect(described_class.new(submitted, docx(document, changed_styles)).report)
      .to include("- 1: heading1|heading1", "+ 1: heading2|heading1")
  end

  it "honors a direct body-text outline level over an inherited heading level" do
    xml = document.sub('<w:pStyle w:val="heading-id"/>', '<w:pStyle w:val="heading-id"/><w:outlineLvl w:val="9"/>')

    expect(described_class.normalize(docx(xml)).first).to eq("paragraph|heading1")
  end

  it "preserves table boundaries and nested tables" do
    output = mhtml('<table><tr><td><p>A</p><table><tr><td><p>B</p></td></tr></table></td></tr></table>')

    expect(described_class.normalize(output)).to eq([
      "table", "row", "cell", "paragraph|normal", "table", "row", "cell",
      "paragraph|normal", "/cell", "/row", "/table", "/cell", "/row", "/table",
    ])
  end

  it "reports missing images independently of their paragraph styles" do
    output = docx(document.sub("<w:drawing/>", ""))

    expect(described_class.new(submitted, output).report).to include("- 13: figure")
  end

  it "preserves a class style over a generic heading tag style" do
    path = File.join(@dir, "custom-heading.doc")
    File.write(path, File.read(submitted).sub('<h1 id=3D"random-heading">', '<h1 class=3D"IntroTitle">'))

    expect(described_class.normalize(path).first).to eq("heading1|introtitle")
  end

  it "normalizes inline-only and empty HTML cells to Word paragraphs" do
    output = mhtml('<table><tr><td><strong>Text</strong></td><td></td></tr></table>')

    expect(described_class.normalize(output)).to eq([
      "table", "row", "cell", "paragraph|normal", "/cell",
      "cell", "paragraph|normal", "/cell", "/row", "/table",
    ])
  end

  it "reports reordered structures" do
    xml = document.sub('w:val="note-id"', 'w:val="temporary"')
      .sub('w:val="example-id"', 'w:val="note-id"')
      .sub('w:val="temporary"', 'w:val="example-id"')

    expect(described_class.new(submitted, docx(xml))).not_to be_match
  end

  it "retains unknown style names and significant punctuation" do
    output = mhtml('<p class="Box-begin"></p><p class="Boxbegin"></p>', encoding: "8bit")

    expect(described_class.normalize(output)).to eq(["paragraph|box-begin", "paragraph|boxbegin"])
  end

  it "does not silently treat an invalid package as an empty document" do
    path = File.join(@dir, "broken.docx")
    Zip::OutputStream.open(path) { |zip| zip.put_next_entry("unrelated.xml") }

    expect { described_class.normalize(path) }.to raise_error(ArgumentError, "Missing word/document.xml")
  end

  it "rejects MHTML without an HTML part" do
    path = File.join(@dir, "broken.mhtml")
    File.write(path, File.read(submitted).gsub("text/html", "text/plain"))

    expect { described_class.normalize(path) }.to raise_error(ArgumentError, /No HTML body/)
  end

  describe "docx:parity task" do
    around do |example|
      previous = Rake.application
      Rake.application = Rake::Application.new
      load File.expand_path("../../../lib/tasks/docx_parity.rake", __dir__)
      example.run
    ensure
      Rake.application = previous
    end

    def run_cases(cases)
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("DOCX_PARITY_CASES").and_return(JSON.generate(cases))
      Rake::Task["docx:parity"].invoke
    end

    it "prints a report for artifact paths including spaces" do
      output = File.join(@dir, "output with spaces.docx")
      File.rename(docx, output)

      expect { run_cases([{ submitted: submitted, output: output }]) }
        .to output(/MATCH/).to_stdout
    end

    %w[doc docx].each do |format|
      it "generates Uniword #{format} from presentation XML and prints differences" do
        source = File.join(fixtures, "source.presentation.xml")

        expect { run_cases([{ submitted: submitted, source: source, format: format }]) }
          .to output(/Source: .*source.presentation.xml.*--- .*submitted.mhtml.*\+\+\+ .*output.#{format}.*- \d+:/m).to_stdout
      end
    end

    it "rejects ambiguous source and output entries" do
      expect { run_cases([{ submitted: submitted, source: "a.xml", output: "b.doc" }]) }
        .to raise_error(ArgumentError, "Supply exactly one of output or source")
    end

    it "rejects empty case lists" do
      expect { run_cases([]) }.to raise_error(ArgumentError, /nonempty JSON array/)
    end
  end
end
