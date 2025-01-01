require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML terms" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <terms id="terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
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
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <terms id="terms_and_definitions" obligation="normative" displayorder="2">
                 <title id="_">Terms and Definitions</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="terms_and_definitions">1</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Terms and Definitions</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="terms_and_definitions">1</semx>
                 </fmt-xref-label>
                 <term id="paddy1">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="terms_and_definitions">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="paddy1">1</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="terms_and_definitions">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="paddy1">1</semx>
                    </fmt-xref-label>
                    <preferred id="_">
                       <expression>
                          <name>paddy</name>
                       </expression>
                    </preferred>
                    <fmt-preferred>
                       <p>
                          <semx element="preferred" source="_">
                             <strong>paddy</strong>
                          </semx>
                       </p>
                    </fmt-preferred>
                    <domain id="_">rice</domain>
                    <definition id="_">
                       <verbal-definition>
                          <p original-id="_">rice retaining its husk after threshing</p>
                       </verbal-definition>
                    </definition>
                    <fmt-definition>
                       <semx element="definition" source="_">
                          <p id="_">
                             &lt;
                             <semx element="domain" source="_">rice</semx>
                             &gt; rice retaining its husk after threshing
                          </p>
                       </semx>
                    </fmt-definition>
                    <termexample id="_" autonum="1">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">EXAMPLE</span>
                             <semx element="autonum" source="_">1</semx>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Example</span>
                          <semx element="autonum" source="_">1</semx>
                       </fmt-xref-label>
                       <fmt-xref-label container="paddy1">
                          <span class="fmt-xref-container">
                             <semx element="autonum" source="terms_and_definitions">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="paddy1">1</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Example</span>
                          <semx element="autonum" source="_">1</semx>
                       </fmt-xref-label>
                       <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
                       <ul>
                          <li>A</li>
                       </ul>
                    </termexample>
                    <termexample id="_" autonum="2">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">EXAMPLE</span>
                             <semx element="autonum" source="_">2</semx>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Example</span>
                          <semx element="autonum" source="_">2</semx>
                       </fmt-xref-label>
                       <fmt-xref-label container="paddy1">
                          <span class="fmt-xref-container">
                             <semx element="autonum" source="terms_and_definitions">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="paddy1">1</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Example</span>
                          <semx element="autonum" source="_">2</semx>
                       </fmt-xref-label>
                       <ul>
                          <li>A</li>
                       </ul>
                    </termexample>
                    <termsource status="modified" id="_">
                       <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                          <locality type="clause">
                             <referenceFrom>3.1</referenceFrom>
                          </locality>
                       </origin>
                       <modification>
                          <p original-id="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                       </modification>
                    </termsource>
                    <fmt-termsource status="modified">
                       [SOURCE:
                       <semx element="termsource" source="_">
                          <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                             <locality type="clause">
                                <referenceFrom>3.1</referenceFrom>
                             </locality>
                             <span class="stdpublisher">ISO </span>
                             <span class="stddocNumber">7301</span>
                             :
                             <span class="stdyear">2011</span>
                             ,
                             <span class="citesec">3.1</span>
                          </origin>
                          , modified — The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here
                       </semx>
                       ]
                    </fmt-termsource>
                 </term>
                 <term id="paddy">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="terms_and_definitions">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="paddy">2</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="terms_and_definitions">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="paddy">2</semx>
                    </fmt-xref-label>
                    <preferred id="_">
                       <expression>
                          <name>paddy</name>
                       </expression>
                    </preferred>
                    <fmt-preferred>
                       <p>
                          <semx element="preferred" source="_">
                             <strong>paddy</strong>
                          </semx>
                       </p>
                    </fmt-preferred>
                    <admitted id="_">
                       <expression>
                          <name>paddy rice</name>
                       </expression>
                    </admitted>
                    <admitted id="_">
                       <expression>
                          <name>rough rice</name>
                       </expression>
                    </admitted>
                    <fmt-admitted>
                       <p>
                          <semx element="admitted" source="_">paddy rice</semx>
                       </p>
                       <p>
                          <semx element="admitted" source="_">rough rice</semx>
                       </p>
                    </fmt-admitted>
                    <deprecates id="_">
                       <expression>
                          <name>cargo rice</name>
                       </expression>
                    </deprecates>
                    <fmt-deprecates>
                       <p>
                          DEPRECATED:
                          <semx element="deprecates" source="_">cargo rice</semx>
                       </p>
                    </fmt-deprecates>
                    <definition id="_">
                       <verbal-definition>
                          <p original-id="_">rice retaining its husk after threshing</p>
                       </verbal-definition>
                    </definition>
                    <fmt-definition>
                       <semx element="definition" source="_">
                          <p id="_">rice retaining its husk after threshing</p>
                       </semx>
                    </fmt-definition>
                    <termexample id="_" autonum="">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">EXAMPLE</span>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Example</span>
                       </fmt-xref-label>
                       <fmt-xref-label container="paddy">
                          <span class="fmt-xref-container">
                             <semx element="autonum" source="terms_and_definitions">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="paddy">2</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Example</span>
                       </fmt-xref-label>
                       <ul>
                          <li>A</li>
                       </ul>
                    </termexample>
                    <termnote id="_" autonum="1">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             Note
                             <semx element="autonum" source="_">1</semx>
                             to entry
                          </span>
                          <span class="fmt-label-delim">: </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="_">1</semx>
                       </fmt-xref-label>
                       <fmt-xref-label container="paddy">
                          <span class="fmt-xref-container">
                             <semx element="autonum" source="terms_and_definitions">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="paddy">2</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="_">1</semx>
                       </fmt-xref-label>
                       <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                    </termnote>
                    <termnote id="_" autonum="2">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             Note
                             <semx element="autonum" source="_">2</semx>
                             to entry
                          </span>
                          <span class="fmt-label-delim">: </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="_">2</semx>
                       </fmt-xref-label>
                       <fmt-xref-label container="paddy">
                          <span class="fmt-xref-container">
                             <semx element="autonum" source="terms_and_definitions">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="paddy">2</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="_">2</semx>
                       </fmt-xref-label>
                       <ul>
                          <li>A</li>
                       </ul>
                       <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                    </termnote>
                    <termsource status="identical" id="_">
                       <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                          <locality type="clause">
                             <referenceFrom>3.1</referenceFrom>
                          </locality>
                       </origin>
                    </termsource>
                    <fmt-termsource status="identical">
                       [SOURCE:
                       <semx element="termsource" source="_">
                          <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                             <locality type="clause">
                                <referenceFrom>3.1</referenceFrom>
                             </locality>
                             <span class="stdpublisher">ISO </span>
                             <span class="stddocNumber">7301</span>
                             :
                             <span class="stdyear">2011</span>
                             ,
                             <span class="citesec">3.1</span>
                          </origin>
                       </semx>
                       ]
                    </fmt-termsource>
                 </term>
                 <term id="A">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="terms_and_definitions">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="A">3</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="terms_and_definitions">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="A">3</semx>
                    </fmt-xref-label>
                    <preferred id="_">
                       <expression>
                          <name>term1</name>
                       </expression>
                    </preferred>
                    <fmt-preferred>
                       <p>
                          <semx element="preferred" source="_">
                             <strong>term1</strong>
                          </semx>
                       </p>
                    </fmt-preferred>
                    <definition id="_">
                       <verbal-definition>term1 definition</verbal-definition>
                    </definition>
                    <fmt-definition>
                       <semx element="definition" source="_">term1 definition</semx>
                    </fmt-definition>
                    <term id="B">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <semx element="autonum" source="terms_and_definitions">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="A">3</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="B">1</semx>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <semx element="autonum" source="terms_and_definitions">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="A">3</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="B">1</semx>
                       </fmt-xref-label>
                       <preferred id="_">
                          <expression>
                             <name>term2</name>
                          </expression>
                       </preferred>
                       <fmt-preferred>
                          <p>
                             <semx element="preferred" source="_">
                                <strong>term2</strong>
                             </semx>
                          </p>
                       </fmt-preferred>
                       <definition id="_">
                          <verbal-definition>term2 definition</verbal-definition>
                       </definition>
                       <fmt-definition>
                          <semx element="definition" source="_">term2 definition</semx>
                       </fmt-definition>
                    </term>
                 </term>
              </terms>
           </sections>
        </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                <div id="terms_and_definitions">
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
                      <p><span class="termnote_label">Note 1 to entry: </span>The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.</p>
                   </div>
                   <div id="_" class="Note">
                      <p>
                         <span class="termnote_label">Note 2 to entry: </span>
                         </p>
                         <div class="ul_wrap">
                            <ul>
                               <li>A</li>
                            </ul>
                         </div>
                         <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.</p>
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
          <div id="terms_and_definitions">
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
             <p class="Note"><span class="termnote_label">Note 1 to entry: </span>The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.</p>
          </div>
          <div id="_" class="Note">
             <p class="Note">
                <span class="termnote_label">Note 2 to entry: </span>
                </p>
                <div class="ul_wrap">
                   <ul>
                      <li>A</li>
                   </ul>
                </div>
                <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.</p>
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
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true)
      .sub(%r{^.*<div class="WordSection3">}m, "")
      .sub(%r{</div>\s*<br.*$}m, ""))))
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
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <terms id="A" obligation="normative" displayorder="2">
                 <title id="_">Terms and definitions</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Terms and definitions</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="A">1</semx>
                 </fmt-xref-label>
                 <term id="second">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="A">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="second">1</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="A">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="second">1</semx>
                    </fmt-xref-label>
                    <preferred id="_">
                       <expression>
                          <name>Second Term</name>
                       </expression>
                       <field-of-application>Field</field-of-application>
                       <usage-info>Usage Info 1</usage-info>
                    </preferred>
                    <fmt-preferred>
                       <p>
                          <semx element="preferred" source="_">
                             <strong>Second Term</strong>
                             , &lt;Field, Usage Info 1&gt;
                          </semx>
                       </p>
                    </fmt-preferred>
                    <definition id="_">
                       <verbal-definition>Definition 1</verbal-definition>
                    </definition>
                    <fmt-definition>
                       <semx element="definition" source="_">Definition 1</semx>
                    </fmt-definition>
                 </term>
                 <term id="C">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="A">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="C">2</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="A">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="C">2</semx>
                    </fmt-xref-label>
                    <preferred language="fr" script="Latn" type="prefix" id="_">
                       <expression>
                          <name>First Designation</name>
                       </expression>
                    </preferred>
                    <fmt-preferred>
                       <p>
                          <semx element="preferred" source="_">
                             <strong>First Designation</strong>
                          </semx>
                       </p>
                    </fmt-preferred>
                    <related type="contrast" id="_">
                       <preferred>
                          <expression>
                             <name>Fifth Designation</name>
                             <grammar>
                                <gender>neuter</gender>
                             </grammar>
                          </expression>
                       </preferred>
                       <xref target="second"/>
                    </related>
                    <definition id="_">
                       <verbal-definition>Definition 2</verbal-definition>
                    </definition>
                    <fmt-definition>
                       <semx element="definition" source="_">Definition 2</semx>
                    </fmt-definition>
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
          <terms id="terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
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
        <terms id="terms_and_definitions" obligation="normative" displayorder="2">
           <title id="_">Terms and Definitions</title>
           <fmt-title depth="1">
              <span class="fmt-caption-label">
                 <semx element="autonum" source="terms_and_definitions">1</semx>
              </span>
              <span class="fmt-caption-delim">
                 <tab/>
              </span>
              <semx element="title" source="_">Terms and Definitions</semx>
           </fmt-title>
           <fmt-xref-label>
              <span class="fmt-element-name">Clause</span>
              <semx element="autonum" source="terms_and_definitions">1</semx>
           </fmt-xref-label>
           <p>For the purposes of this document, the following terms and definitions apply.</p>
           <term id="paddy1">
              <fmt-name>
                 <span class="fmt-caption-label">
                    <semx element="autonum" source="terms_and_definitions">1</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="paddy1">1</semx>
                 </span>
              </fmt-name>
              <fmt-xref-label>
                 <semx element="autonum" source="terms_and_definitions">1</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="paddy1">1</semx>
              </fmt-xref-label>
              <preferred id="_">
                 <expression>
                    <name>paddy</name>
                 </expression>
              </preferred>
              <fmt-preferred>
                 <p>
                    <semx element="preferred" source="_">
                       <strong>paddy</strong>
                    </semx>
                 </p>
              </fmt-preferred>
              <definition id="_">
                 <verbal-definition>
                    <p original-id="_">rice retaining its husk after threshing</p>
                 </verbal-definition>
              </definition>
              <fmt-definition>
                 <semx element="definition" source="_">
                    <p id="_">rice retaining its husk after threshing</p>
                 </semx>
              </fmt-definition>
              <termsource status="identical" id="_">
                 <origin citeas="">
                    <termref base="IEV" target="xyz">t1</termref>
                 </origin>
                 <modification>
                    <p original-id="_">with adjustments</p>
                 </modification>
              </termsource>
              <termsource status="adapted" id="_">
                 <origin citeas="">
                    <termref base="IEV" target="xyz"/>
                 </origin>
                 <modification>
                    <p original-id="_">with adjustments</p>
                 </modification>
              </termsource>
              <termsource status="modified" id="_">
                 <origin citeas="">
                    <termref base="IEV" target="xyz"/>
                 </origin>
                 <modification>
                    <p original-id="_">with adjustments</p>
                 </modification>
              </termsource>
              <termsource status="identical" id="_">
                 <origin citeas="">
                    <termref base="IEV" target="xyz">t1</termref>
                 </origin>
              </termsource>
              <termsource status="adapted" id="_">
                 <origin citeas="">
                    <termref base="IEV" target="xyz"/>
                 </origin>
              </termsource>
              <termsource status="modified" id="_">
                 <origin citeas="">
                    <termref base="IEV" target="xyz"/>
                 </origin>
              </termsource>
              <fmt-termsource status="identical">
                 [SOURCE:
                 <semx element="termsource" source="_">
                    <origin citeas="">
                       <termref base="IEV" target="xyz">t1</termref>
                    </origin>
                    — with adjustments
                 </semx>
                 ;
                 <semx element="termsource" source="_">
                    <origin citeas="">
                       <termref base="IEV" target="xyz"/>
                    </origin>
                    , modified — with adjustments
                 </semx>
                 ;
                 <semx element="termsource" source="_">
                    <origin citeas="">
                       <termref base="IEV" target="xyz"/>
                    </origin>
                    , modified — with adjustments
                 </semx>
                 ;
                 <semx element="termsource" source="_">
                    <origin citeas="">
                       <termref base="IEV" target="xyz">t1</termref>
                    </origin>
                 </semx>
                 ;
                 <semx element="termsource" source="_">
                    <origin citeas="">
                       <termref base="IEV" target="xyz"/>
                    </origin>
                    , modified
                 </semx>
                 ;
                 <semx element="termsource" source="_">
                    <origin citeas="">
                       <termref base="IEV" target="xyz"/>
                    </origin>
                    , modified
                 </semx>
                 ]
              </fmt-termsource>
           </term>
        </terms>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
          .new(presxml_options)
           .convert("test", input, true))
          .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
