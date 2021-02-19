require "spec_helper"
require "metanorma"
require "fileutils"

# RSpec.describe Asciidoctor::Gb do
RSpec.describe Metanorma::Iso::Processor do
  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Iso::Processor)
  processor = registry.find_processor(:iso)

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~"OUTPUT"
      [[:doc, "doc"], [:html, "html"], [:html_alt, "alt.html"], [:isosts, "iso.sts.xml"], [:pdf, "pdf"], [:presentation, "presentation.xml"], [:rxl, "rxl"], [:sts, "sts.xml"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::ISO })
  end

  it "generates IsoDoc XML from a blank document" do
    expect(xmlpp(processor.input_to_isodoc(<<~"INPUT", nil))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
    INPUT
        #{BLANK_HDR}
        <sections/>
      </iso-standard>
    OUTPUT
  end

  it "generates HTML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    processor.output(<<~"INPUT", "test.xml", "test.html", :html)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <terms id="H" obligation="normative"><title>1&#xA0; Terms, Definitions, Symbols and Abbreviated Terms</title>
            <term id="J">
              <name>1.1</name>
              <preferred>Term2</preferred>
            </term>
          </terms>
        </sections>
      </iso-standard>
    INPUT
    expect(xmlpp(File.read("test.html", encoding: "utf-8")
      .gsub(%r{^.*<main}m, "<main")
      .gsub(%r{</main>.*}m, "</main>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <main class="main-section">
          <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
          <p class="zzSTDTitle1"></p>
          <div id="H"><h1 id="toc0">1&#xA0; Terms, Definitions, Symbols and Abbreviated Terms</h1>
            <h2 class="TermNum" id="J">1.1</h2>
            <p class="Terms" style="text-align:left;">Term2</p>
          </div>
        </main>
      OUTPUT
  end
end
