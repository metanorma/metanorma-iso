require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML terms" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
            <term id="paddy1">
              <preferred><expression><name>paddy</name></expression></preferred>
              <domain>rice</domain>
              <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
                <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
                <ul>
                <li>A</li>
                </ul>
              </termexample>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
                <ul>
                <li>A</li>
                </ul>
              </termexample>

              <termsource status="modified">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
                  <modification>
                  <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                </modification>
              </termsource>
            </term>

            <term id="paddy">
              <preferred><expression><name>paddy</name></expression></preferred>
              <admitted><expression><name>paddy rice</name></expression></admitted>
              <admitted><expression><name>rough rice</name></expression></admitted>
              <deprecates><expression><name>cargo rice</name></expression></deprecates>
              <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
              <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
                <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
                <ul>
                <li>A</li>
                </ul>
              </termexample>
              <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
              <ul><li>A</li></ul>
                <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termsource status="identical">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
              </termsource>
            </term>
            <term id="A">
              <preferred><expression><name>term1</name></expression></preferred>
              <definition><verbal-definition>term1 definition</verbal-definition></definition>
              <term id="B">
              <preferred><expression><name>term2</name></expression></preferred>
              <definition><verbal-definition>term2 definition</verbal-definition></definition>
              </term>
            </term>
          </terms>
        </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface> <clause type="toc" id="_" displayorder="1"> 
        <fmt-title depth="1">Contents</fmt-title>
          </clause> </preface>
        <sections>
          <terms id='_' obligation='normative' displayorder='2'>
          <title depth='1'>1<tab/>Terms and Definitions</title>

            <term id='paddy1'><name>1.1</name>
              <preferred><strong>paddy</strong></preferred>
              <domain hidden="true">rice</domain>
              <definition>
                <p id='_'>&#x3c;<domain>rice</domain>&#x3e; rice retaining its husk after threshing</p>
              </definition>
              <termexample id='_'>
                <name>EXAMPLE 1</name>
                <p id='_'>Foreign seeds, husks, bran, sand, dust.</p>
                <ul>
                  <li>A</li>
                </ul>
              </termexample>
              <termexample id='_'>
                <name>EXAMPLE 2</name>
                <ul>
                  <li>A</li>
                </ul>
              </termexample>
              <termsource status="modified">[SOURCE: <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality><span class="stdpublisher">ISO </span><span class="stddocNumber">7301</span>:<span class="stdyear">2011</span>, <span class="citesec">3.1</span></origin>, modified
                    &#x2014;
                   The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]</termsource>
            </term>
            <term id='paddy'><name>1.2</name>
              <preferred><strong>paddy</strong></preferred>
              <admitted>paddy rice</admitted>
              <admitted>rough rice</admitted>
              <deprecates>DEPRECATED: cargo rice</deprecates>
              <definition>
                <p id='_'>rice retaining its husk after threshing</p>
              </definition>
              <termnote id='_'>
                <name>Note 1 to entry:</name>
                <p id='_'>The starch of waxy rice consists almost entirely of amylopectin. The
                  kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termnote id='_'>
                <name>Note 2 to entry:</name>
                <ul>
                  <li>A</li>
                </ul>
                <p id='_'>The starch of waxy rice consists almost entirely of amylopectin. The
                  kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termexample id='_'>
                <name>EXAMPLE</name>
                <ul>
                  <li>A</li>
                </ul>
              </termexample>
              <termsource status="identical">[SOURCE: <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality><span class="stdpublisher">ISO </span><span class="stddocNumber">7301</span>:<span class="stdyear">2011</span>, <span class="citesec">3.1</span></origin>]</termsource>
            </term>
            <term id='A'>
              <name>1.3</name>
              <preferred><strong>term1</strong></preferred>
              <definition>term1 definition</definition>
              <term id='B'>
                <name>1.3.1</name>
                <preferred><strong>term2</strong></preferred>
                <definition>term2 definition</definition>
              </term>
            </term>
          </terms>
        </sections>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                <div id="_">
                   <h1>1  Terms and Definitions</h1>
                   <p class="TermNum" id="paddy1">1.1</p>
                   <p class="Terms" style="text-align:left;">
                      <b>paddy</b>
                   </p>
                   <p id="_">&lt;rice&gt; rice retaining its husk after threshing</p>
                   <div id="_" class="example">
                      <p>
                         <span class="example_label">EXAMPLE 1</span>
                           Foreign seeds, husks, bran, sand, dust.
                      </p>
                      <div class="ul_wrap">
                         <ul>
                            <li>A</li>
                         </ul>
                      </div>
                   </div>
                   <div id="_" class="example">
                      <p>
                         <span class="example_label">EXAMPLE 2</span>
                          
                      </p>
                      <div class="ul_wrap">
                         <ul>
                            <li>A</li>
                         </ul>
                      </div>
                   </div>
                   <p>
                      [SOURCE:
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">7301</span>
                      :
                      <span class="stdyear">2011</span>
                      ,
                      <span class="citesec">3.1</span>
                      , modified — The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
                   </p>
                   <p class="TermNum" id="paddy">1.2</p>
                   <p class="Terms" style="text-align:left;">
                      <b>paddy</b>
                   </p>
                   <p class="AltTerms" style="text-align:left;">paddy rice</p>
                   <p class="AltTerms" style="text-align:left;">rough rice</p>
                   <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
                   <p id="_">rice retaining its husk after threshing</p>
                   <div id="_" class="Note">
                      <p>Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.</p>
                   </div>
                   <div id="_" class="Note">
                      <p>
                         Note 2 to entry:
                         <div class="ul_wrap">
                            <ul>
                               <li>A</li>
                            </ul>
                         </div>
                         <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.</p>
                      </p>
                   </div>
                   <div id="_" class="example">
                      <p>
                         <span class="example_label">EXAMPLE</span>
                          
                      </p>
                      <div class="ul_wrap">
                         <ul>
                            <li>A</li>
                         </ul>
                      </div>
                   </div>
                   <p>
                      [SOURCE:
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">7301</span>
                      :
                      <span class="stdyear">2011</span>
                      ,
                      <span class="citesec">3.1</span>
                      ]
                   </p>
                   <p class="TermNum" id="A">1.3</p>
                   <p class="Terms" style="text-align:left;">
                      <b>term1</b>
                   </p>
                   term1 definition
                   <p class="TermNum" id="B">1.3.1</p>
                   <p class="Terms" style="text-align:left;">
                      <b>term2</b>
                   </p>
                   term2 definition
                </div>
             </div>
          </body>
       </html>
    OUTPUT

    word = <<~OUTPUT
          <div id="_">
          <h1>
             1
             <span style="mso-tab-count:1">  </span>
             Terms and Definitions
          </h1>
          <p class="TermNum" id="paddy1">1.1</p>
          <p class="Terms" style="text-align:left;">
             <b>paddy</b>
          </p>
          <p class="Definition" id="_">&lt;rice&gt; rice retaining its husk after threshing</p>
          <div id="_" class="example">
             <p>
                <span class="example_label">EXAMPLE 1</span>
                <span style="mso-tab-count:1">  </span>
                Foreign seeds, husks, bran, sand, dust.
             </p>
             <div class="ul_wrap">
                <ul>
                   <li>A</li>
                </ul>
             </div>
          </div>
          <div id="_" class="example">
             <p>
                <span class="example_label">EXAMPLE 2</span>
                <span style="mso-tab-count:1">  </span>
             </p>
             <div class="ul_wrap">
                <ul>
                   <li>A</li>
                </ul>
             </div>
          </div>
          <p class="Source">
             [SOURCE:
             <span class="stdpublisher">ISO </span>
             <span class="stddocNumber">7301</span>
             :
             <span class="stdyear">2011</span>
             ,
             <span class="citesec">3.1</span>
             , modified — The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
          </p>
          <p class="TermNum" id="paddy">1.2</p>
          <p class="Terms" style="text-align:left;">
             <b>paddy</b>
          </p>
          <p class="AltTerms" style="text-align:left;">paddy rice</p>
          <p class="AltTerms" style="text-align:left;">rough rice</p>
          <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
          <p class="Definition" id="_">rice retaining its husk after threshing</p>
          <div id="_" class="Note">
             <p class="Note">Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.</p>
          </div>
          <div id="_" class="Note">
             <p class="Note">
                Note 2 to entry:
                <div class="ul_wrap">
                   <ul>
                      <li>A</li>
                   </ul>
                </div>
                <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.</p>
             </p>
          </div>
          <div id="_" class="example">
             <p>
                <span class="example_label">EXAMPLE</span>
                <span style="mso-tab-count:1">  </span>
             </p>
             <div class="ul_wrap">
                <ul>
                   <li>A</li>
                </ul>
             </div>
          </div>
          <p class="Source">
             [SOURCE:
             <span class="stdpublisher">ISO </span>
             <span class="stddocNumber">7301</span>
             :
             <span class="stdyear">2011</span>
             ,
             <span class="citesec">3.1</span>
             ]
          </p>
          <p class="TermNum" id="A">1.3</p>
          <p class="Terms" style="text-align:left;">
             <b>term1</b>
          </p>
          term1 definition
          <p class="TermNum" id="B">1.3.1</p>
          <p class="Terms" style="text-align:left;">
             <b>term2</b>
          </p>
          term2 definition
       </div>
    OUTPUT
     pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true)
      .sub(%r{^.*<div class="WordSection3">}m, "")
      .sub(%r{</div>\s*<br.*$}m, "")))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes related terms" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
      <terms id='A' obligation='normative'>
            <title>Terms and definitions</title>
            <term id='second'>
        <preferred>
          <expression>
            <name>Second Term</name>
          </expression>
        <field-of-application>Field</field-of-application>
        <usage-info>Usage Info 1</usage-info>
        </preferred>
        <definition><verbal-definition>Definition 1</verbal-definition></definition>
      </term>
      <term id="C">
      <preferred language='fr' script='Latn' type='prefix'>
                <expression>
                  <name>First Designation</name>
                  </expression></preferred>
        <related type='contrast'>
          <preferred>
            <expression>
              <name>Fifth Designation</name>
              <grammar>
                <gender>neuter</gender>
              </grammar>
            </expression>
          </preferred>
          <xref target='second'/>
        </related>
        <definition><verbal-definition>Definition 2</verbal-definition></definition>
      </term>
          </terms>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
       <?xml version='1.0'?>
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
            <preface> <clause type="toc" id="_" displayorder="1">
          <fmt-title depth="1">Contents</fmt-title>
          </clause> </preface>
        <sections>
          <terms id='A' obligation='normative' displayorder='2'>
            <title depth='1'>1<tab/>Terms and definitions</title>
            <term id='second'>
              <name>1.1</name>
              <preferred><strong>Second Term</strong>, &#x3c;Field, Usage Info 1&#x3e;</preferred>
              <definition>Definition 1</definition>
            </term>
            <term id='C'>
              <name>1.2</name>
              <preferred language='fr' script='Latn' type='prefix'><strong>First Designation</strong></preferred>
              <definition>Definition 2</definition>
            </term>
          </terms>
        </sections>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes IsoXML term with different term source statuses" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata><language>en</language></bibdata>
          <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
          <p>For the purposes of this document, the following terms and definitions apply.</p>
      <term id="paddy1"><preferred><expression><name>paddy</name></expression></preferred>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
        <termsource status='identical'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'>t1</termref>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </termsource>
        <termsource status='adapted'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </termsource>
        <termsource status='modified'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </termsource>
        <termsource status='identical'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'>t1</termref>
          </origin>
        </termsource>
        <termsource status='adapted'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
        </termsource>
        <termsource status='modified'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
        </termsource>
      </term>
    INPUT
    output = <<~OUTPUT
      <terms id="_terms_and_definitions" obligation="normative" displayorder="2">
        <title depth="1">1<tab/>Terms and Definitions</title>
        <p>For the purposes of this document, the following terms and definitions apply.</p>
        <term id="paddy1">
          <name>1.1</name>
          <preferred>
            <strong>paddy</strong>
          </preferred>
          <definition>
            <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
          </definition>
          <termsource status="identical">[SOURCE: <origin citeas=""><termref base="IEV" target="xyz">t1</termref></origin>
           &#x2014;
            with adjustments

        ;
          <origin citeas=""><termref base="IEV" target="xyz"/></origin>, modified
           &#x2014;
            with adjustments

        ;
          <origin citeas=""><termref base="IEV" target="xyz"/></origin>, modified
           &#x2014;
            with adjustments

        ;
          <origin citeas=""><termref base="IEV" target="xyz">t1</termref></origin>
        ;
          <origin citeas=""><termref base="IEV" target="xyz"/></origin>, modified
        ;
          <origin citeas=""><termref base="IEV" target="xyz"/></origin>, modified]</termsource>
        </term>
      </terms>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
          .new(presxml_options)
           .convert("test", input, true))
          .at("//xmlns:terms").to_xml))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
