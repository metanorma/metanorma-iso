require "spec_helper"
require "metanorma-core"
require "fileutils"
require "tempfile"

RSpec.describe "Metanorma::Iso::Processor" do
  subject(:processor) do
    registry = Metanorma::Registry.instance
    registry.register(described_class)
    registry.find_processor(:iso)
  end

  # Keep the established spec path while identifying the concrete processor.
  let(:described_class) { Metanorma::Iso::Processor }
  let(:inputxml) do
    <<~INPUT
    <metanorma xmlns="http://riboseinc.com/isoxml" flavor="iso">
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
    <name id="_">International Organization for Standardization</name>
    <abbreviation>ISO</abbreviation>
    </organization>
    </contributor>
    <contributor>
    <role type="publisher"/>
    <organization>
    <name id="_">International Organization for Standardization</name>
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
    <from>#{Time.now.year}</from>
    <owner>
    <organization>
    <name id="_">International Organization for Standardization</name>
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
                <fmt-preferred><p>Term2</p></fmt-preferred>
              </term>
            </terms>
          </sections>
    </metanorma>
    INPUT
  end

  after { FileUtils.rm_f ".asciidoc.log.txt" }

  it "registers against metanorma" do
    expect(processor).not_to be_nil
  end

  describe "#resolve_docx_template" do
    template_cases = [
      ["00", {}, :simple], ["10", {}, :simple], ["20", {}, :simple],
      ["30", {}, :simple], ["40", {}, :dis], ["50", {}, :dis],
      ["60.60", {}, :dis], ["90", {}, :dis], [nil, {}, :dis],
      ["30", { isowordtemplate: "dis" }, :dis],
      ["60.60", { isowordtemplate: "simple" }, :simple],
      [nil, { isowordtemplate: "simple" }, :simple]
    ]

    %i[string path].product([nil, "", "iso"]).each do |input_type, prefix|
      template_cases.each do |stage, options, template|
        context "with #{input_type} input, namespace prefix #{prefix.inspect}, stage #{stage || '(missing)'} and #{options}" do
          let(:xml) do
            namespace = "xmlns#{":#{prefix}" unless prefix.empty?}=\"http://riboseinc.com/isoxml\"" if prefix
            tag_prefix = prefix.to_s.empty? ? "" : "#{prefix}:"
            <<~XML
              <#{tag_prefix}metanorma #{namespace} flavor="iso">
                <#{tag_prefix}bibdata>
                  <#{tag_prefix}status>
                    #{"<#{tag_prefix}stage>#{stage}</#{tag_prefix}stage>" if stage}
                  </#{tag_prefix}status>
                </#{tag_prefix}bibdata>
              </#{tag_prefix}metanorma>
            XML
          end
          let(:xml_file) { Tempfile.new(["iso-stage", ".xml"]) }
          let(:template_input) { input_type == :path ? xml_file.path : xml }

          before do
            next unless input_type == :path

            xml_file.write(xml)
            xml_file.flush
          end

          after { xml_file.close! if input_type == :path }

          it "selects #{template}" do
            expect(processor.send(:resolve_docx_template, template_input, options))
              .to eq(template)
          end
        end
      end
    end
  end

  it "registers output formats against metanorma" do
    output = <<~OUTPUT
      [[:doc, "doc"], [:docx, "docx"], [:html, "html"], [:html_alt, "alt.html"], [:isosts, "iso.sts.xml"], [:pdf, "pdf"], [:presentation, "presentation.xml"], [:rxl, "rxl"], [:sts, "sts.xml"], [:sts_html, "sts.html"], [:xml, "xml"]]
    OUTPUT
    expect(processor.output_formats.sort.to_s).to be_xml_equivalent_to output.chop
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::Iso })
  end

  context "with a blank document" do
    let(:input) { "#{ASCIIDOC_BLANK_HDR}\n" }
    let(:output) do
      <<~OUTPUT
          #{BLANK_HDR_2}
          <sections/>
        </metanorma>
      OUTPUT
    end

    it "generates IsoDoc XML from a blank document" do
      expect(strip_guid(processor.input_to_isodoc(input, nil)))
        .to be_xml_equivalent_to strip_guid(output)
    end
  end

  context "when rendering HTML" do
    let(:expected_html) do
      <<~OUTPUT
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

    before do
      FileUtils.rm_f "test.xml"
      FileUtils.rm_f "test.html"
      processor.output(inputxml, "test.xml", "test.html", :html)
    end

    it "generates HTML from Metanorma XML" do
      expect(strip_guid(File.read("test.html", encoding: "utf-8")
        .gsub(%r{^.*<main}m, "<main")
        .gsub(%r{</main>.*}m, "</main>")))
        .to be_xml_equivalent_to expected_html
    end
  end

  context "with the native STS gate disabled" do
    before do
      Metanorma::Iso::Sts.enabled = false
      FileUtils.rm_f "test.xml"
      FileUtils.rm_f "test.sts.xml"
      FileUtils.rm_f "test.iso.sts.xml"
      File.write("test.xml", inputxml)
      processor.output(inputxml, "test.xml", "test.sts.xml", :sts)
      processor.output(inputxml, "test.xml", "test.iso.sts.xml", :isosts)
    end

    after { Metanorma::Iso::Sts.enabled = nil }

    it "generates STS from Metanorma XML via mnconvert (native gate off)", :aggregate_failures do
      expect(File.exist?("test.sts.xml")).to be true
      expect(File.exist?("test.iso.sts.xml")).to be true
    end
  end

  # Native document-model routing is the default; the transformer itself is
  # covered end-to-end in spec/sts. Here we assert the routing decision only.
  it "routes :isosts through the native driver by default (gate on)", :aggregate_failures do
    expect(Metanorma::Iso::Sts.enabled?).to be(true)
    expect(processor.document_transformers).to have_key(:isosts)
  end
end
