require "spec_helper"
require "metanorma"
require "fileutils"

# RSpec.describe Asciidoctor::Gb do
RSpec.describe Metanorma::Iso::Processor do
  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Iso::Processor)
  processor = registry.find_processor(:iso)

  inputxml = <<~INPUT
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata type="standard">
    <title language="en" format="text/plain" type="main">English</title>
    <title language="en" format="text/plain" type="title-main">English</title>
    <title language="fr" format="text/plain" type="main">French</title>
    <title language="fr" format="text/plain" type="title-main">French</title>
    <docidentifier type="ISO">ISO DIR 1</docidentifier><docidentifier type="iso-with-lang">ISO DIR 1(F)</docidentifier><docidentifier type="iso-reference">ISO DIR 1(F)</docidentifier>
    <docnumber>1</docnumber>
    <contributor>
    <role type="author"/>
    <organization>
    <name>International Organization for Standardization</name>
    <abbreviation>ISO</abbreviation>
    </organization>
    </contributor>
    <contributor>
    <role type="publisher"/>
    <organization>
    <name>International Organization for Standardization</name>
    <abbreviation>ISO</abbreviation>
    </organization>
    </contributor>
    <language>fr</language>
    <script>Latn</script>
    <status>
    <stage>60</stage>
    <substage>60</substage>
    </status>
    <copyright>
    <from>#{Time.new.year}</from>
    <owner>
    <organization>
    <name>International Organization for Standardization</name>
    <abbreviation>ISO</abbreviation>
    </organization>
    </owner>
    </copyright>
    <ext>
    <doctype>directive</doctype>
    <subdoctype>vocabulary</subdoctype>
                <flavor>iso</flavor>
    <editorialgroup>
    <technical-committee/>
    <subcommittee/>
    <workgroup/>
    </editorialgroup>
    <structuredidentifier>
    <project-number>ISO 1</project-number>
    </structuredidentifier>
    <stagename>International standard</stagename>
    </ext>
    </bibdata>
    <boilerplate>
      <copyright-statement>
        <clause>
          <title>DOCUMENT PROT&#201;G&#201; PAR COPYRIGHT</title>
        <p id="boilerplate-year">&#169; ISO 2021</p>

      <p id="boilerplate-message">
    Droits de reproduction r&#233;serv&#233;s. Sauf indication contraire, aucune partie de cette publication ne
    peut &#234;tre reproduite ni utilis&#233;e sous quelque forme que ce soit et par aucun proc&#233;d&#233;, &#233;lectronique
    ou m&#233;canique, y compris la photocopie, l&#8217;affichage sur l&#8217;internet ou sur un Intranet, sans
    autorisation &#233;crite pr&#233;alable. Les demandes d&#8217;autorisation peuvent &#234;tre adress&#233;es &#224; l&#8217;ISO &#224;
    l&#8217;adresse ci-apr&#232;s ou au comit&#233; membre de l&#8217;ISO dans le pays du demandeur.
      </p>

      <p id="boilerplate-address" align="left">
        ISO copyright office<br/>
        Ch. de Blandonnet 8 &#8226; CP 401<br/>
        CH-1214 Vernier, Geneva, Switzerland<br/>
        Phone: +41 22 749 01 11<br/>
        Email: copyright@iso.org<br/>
        Website: www.iso.org
      </p>
        <p id="boilerplate-place">
        Publi&#233; en Suisse
      </p>
    </clause>
      </copyright-statement>


    </boilerplate>
          <sections>
            <terms id="H" obligation="normative" displayorder="1">
              <fmt-title>1&#xA0; Terms, Definitions, Symbols and Abbreviated Terms</fmt-title>
              <term id="J">
                <fmt-name>1.1</fmt-name>
                <preferred>Term2</preferred>
              </term>
            </terms>
          </sections>
    </iso-standard>
  INPUT

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~OUTPUT
      [[:doc, "doc"], [:html, "html"], [:html_alt, "alt.html"], [:isosts, "iso.sts.xml"], [:pdf, "pdf"], [:presentation, "presentation.xml"], [:rxl, "rxl"], [:sts, "sts.xml"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::Iso })
  end

  it "generates IsoDoc XML from a blank document" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
    INPUT
    output = <<~OUTPUT
        #{BLANK_HDR}
        <sections/>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(processor.input_to_isodoc(input, nil))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "generates HTML from Metanorma XML" do
    FileUtils.rm_f "test.xml"
    FileUtils.rm_f "test.html"
    processor.output(inputxml, "test.xml", "test.html", :html)
    expect(Xml::C14n.format(strip_guid(File.read("test.html", encoding: "utf-8")
      .gsub(%r{^.*<main}m, "<main")
      .gsub(%r{</main>.*}m, "</main>"))))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
        <main class="main-section">
          <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
          <div class="authority"/>
          <div id="H">
            <h1 id="_">
              <a class="anchor" href="#H"/>
              <a class="header" href="#H">1  Terms, Definitions, Symbols and Abbreviated Terms</a>
            </h1>
            <div id="J">
              <h2 class="TermNum" id="_">
                <a class="anchor" href="#J"/>
                <a class="header" href="#J">1.1</a>
              </h2>
            </div>
            <p class="Terms" style="text-align:left;">Term2</p>
          </div>
        </main>
      OUTPUT
  end

  it "generates STS from Metanorma XML" do
    FileUtils.rm_f "test.xml"
    FileUtils.rm_f "test.sts.xml"
    FileUtils.rm_f "test.iso.sts.xml"
    File.write("test.xml", inputxml)
    processor.output(inputxml, "test.xml", "test.sts.xml", :sts)
    processor.output(inputxml, "test.xml", "test.iso.sts.xml", :isosts)
    expect(File.exist?("test.sts.xml")).to be true
    expect(File.exist?("test.iso.sts.xml")).to be true
  end
end
