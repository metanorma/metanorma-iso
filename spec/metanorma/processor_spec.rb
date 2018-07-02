require "spec_helper"
require "metanorma"

#RSpec.describe Asciidoctor::Gb do
RSpec.describe Metanorma::Iso::Processor do

  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Iso::Processor)
  processor = registry.find_processor(:iso)

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~"OUTPUT"
    [[:doc, "doc"], [:html, "html"], [:html_alt, "alt.html"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Asciidoctor::ISO })
    expect(processor.version.to_s).to match(%r{/IsoDoc })
  end

  it "generates IsoDoc XML from a blank document" do
    expect(processor.input_to_isodoc(<<~"INPUT")).to be_equivalent_to <<~"OUTPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT
    #{BLANK_HDR}
<sections/>
</iso-standard>
    OUTPUT
  end

  it "generates HTML from IsoDoc XML" do
    system "rm -f test.xml"
    processor.output(<<~"INPUT", "test.html", :html)
               <iso-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
        </terms>
        </sections>
        </iso-standard>
    INPUT
    expect(File.read("test.html", encoding: "utf-8").gsub(%r{^.*<main}m, "<main").gsub(%r{</main>.*}m, "</main>")).to be_equivalent_to <<~"OUTPUT"
           <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <p class="zzSTDTitle1"></p>
             <div id="H"><h1>1.&#xA0; Terms and definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       <h2 class="TermNum" id="J">1.1</h2>
         <p class="Terms" style="text-align:left;">Term2</p>
       </div>
           </main>
    OUTPUT
  end

end
