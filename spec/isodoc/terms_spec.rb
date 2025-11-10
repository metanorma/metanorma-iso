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

              <source status="modified">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
                  <modification>
                  <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                </modification>
              </source>
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
              <source status="identical">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
              </source>
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
               <fmt-title depth="1" id="_">Contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <terms id="terms_and_definitions" obligation="normative" displayorder="2">
               <title id="_">Terms and Definitions</title>
               <fmt-title depth="1" id="_">
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
                  <fmt-name id="_">
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
                  <fmt-definition id="_">
                     <semx element="definition" source="_">
                        <p id="_">
                           &lt;
                           <semx element="domain" source="_">rice</semx>
                           &gt; rice retaining its husk after threshing
                        </p>
                     </semx>
                  </fmt-definition>
                  <termexample id="_" autonum="1">
                     <fmt-name id="_">
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
                        <li id="_">
                           <fmt-name id="_">
                              <semx element="autonum" source="_">—</semx>
                           </fmt-name>
                           A
                        </li>
                     </ul>
                  </termexample>
                  <termexample id="_" autonum="2">
                     <fmt-name id="_">
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
                        <li id="_">
                           <fmt-name id="_">
                              <semx element="autonum" source="_">—</semx>
                           </fmt-name>
                           A
                        </li>
                     </ul>
                  </termexample>
                  <source status="modified" id="_">
                     <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                        <locality type="clause">
                           <referenceFrom>3.1</referenceFrom>
                        </locality>
                     </origin>
                     <modification id="_">
                        <p id="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                     </modification>
                  </source>
                  <fmt-termsource status="modified">
                     [SOURCE:
                     <semx element="source" source="_">
                        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                           <locality type="clause">
                              <referenceFrom>3.1</referenceFrom>
                           </locality>
                        </origin>
                        <semx element="origin" source="_">
                           <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                              <locality type="clause">
                                 <referenceFrom>3.1</referenceFrom>
                              </locality>
                              <span class="stdpublisher">ISO </span>
                              <span class="stddocNumber">7301</span>
                              :
                              <span class="stdyear">2011</span>
                              ,
                              <span class="citesec">3.1</span>
                           </fmt-origin>
                        </semx>
                        , modified —
                        <semx element="modification" source="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</semx>
                     </semx>
                     ]
                  </fmt-termsource>
               </term>
               <term id="paddy">
                  <fmt-name id="_">
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
                  <fmt-definition id="_">
                     <semx element="definition" source="_">
                        <p id="_">rice retaining its husk after threshing</p>
                     </semx>
                  </fmt-definition>
                  <termexample id="_" autonum="">
                     <fmt-name id="_">
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
                        <li id="_">
                           <fmt-name id="_">
                              <semx element="autonum" source="_">—</semx>
                           </fmt-name>
                           A
                        </li>
                     </ul>
                  </termexample>
                  <termnote id="_" autonum="1">
                     <fmt-name id="_">
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
                     <fmt-name id="_">
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
                        <li id="_">
                           <fmt-name id="_">
                              <semx element="autonum" source="_">—</semx>
                           </fmt-name>
                           A
                        </li>
                     </ul>
                     <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                  </termnote>
                  <source status="identical" id="_">
                     <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                        <locality type="clause">
                           <referenceFrom>3.1</referenceFrom>
                        </locality>
                     </origin>
                  </source>
                  <fmt-termsource status="identical">
                     [SOURCE:
                     <semx element="source" source="_">
                        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                           <locality type="clause">
                              <referenceFrom>3.1</referenceFrom>
                           </locality>
                        </origin>
                        <semx element="origin" source="_">
                           <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                              <locality type="clause">
                                 <referenceFrom>3.1</referenceFrom>
                              </locality>
                              <span class="stdpublisher">ISO </span>
                              <span class="stddocNumber">7301</span>
                              :
                              <span class="stdyear">2011</span>
                              ,
                              <span class="citesec">3.1</span>
                           </fmt-origin>
                        </semx>
                     </semx>
                     ]
                  </fmt-termsource>
               </term>
               <term id="A">
                  <fmt-name id="_">
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
                  <fmt-definition id="_">
                     <semx element="definition" source="_">term1 definition</semx>
                  </fmt-definition>
                  <term id="B">
                     <fmt-name id="_">
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
                     <fmt-definition id="_">
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
                    <p id="_">&lt;rice&gt;  rice retaining its husk after threshing</p>
                    <div id="_" class="example">
                       <p>
                          <span class="example_label">EXAMPLE 1</span>
                            Foreign seeds, husks, bran, sand, dust.
                       </p>
                       <div class="ul_wrap">
                          <ul>
                             <li id="_">A</li>
                          </ul>
                       </div>
                    </div>
                    <div id="_" class="example">
                       <p>
                          <span class="example_label">EXAMPLE 2</span>
      #{'                     '}
                       </p>
                       <div class="ul_wrap">
                          <ul>
                             <li id="_">A</li>
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
                    <div id="_" class="example">
                       <p>
                          <span class="example_label">EXAMPLE</span>
      #{'                     '}
                       </p>
                       <div class="ul_wrap">
                          <ul>
                             <li id="_">A</li>
                          </ul>
                       </div>
                    </div>
                    <div id="_" class="Note">
                       <p>
                          <span class="termnote_label">Note 1 to entry: </span>
                          The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.
                       </p>
                    </div>
                    <div id="_" class="Note">
                       <p>
                          <span class="termnote_label">Note 2 to entry: </span>
                       </p>
                       <div class="ul_wrap">
                          <ul>
                             <li id="_">A</li>
                          </ul>
                       </div>
                       <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
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
         <p class="Definition" id="_">&lt;rice&gt;  rice retaining its husk after threshing</p>
         <div id="_" class="example">
            <p>
               <span class="example_label">EXAMPLE 1</span>
               <span style="mso-tab-count:1">  </span>
               Foreign seeds, husks, bran, sand, dust.
            </p>
            <div class="ul_wrap">
               <ul>
                  <li id="_">A</li>
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
                  <li id="_">A</li>
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
         <div id="_" class="example">
            <p>
               <span class="example_label">EXAMPLE</span>
               <span style="mso-tab-count:1">  </span>
            </p>
            <div class="ul_wrap">
               <ul>
                  <li id="_">A</li>
               </ul>
            </div>
         </div>
         <div id="_" class="Note">
            <p class="Note">
               <span class="termnote_label">Note 1 to entry: </span>
               The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.
            </p>
         </div>
         <div id="_" class="Note">
            <p class="Note">
               <span class="termnote_label">Note 2 to entry: </span>
            </p>
            <div class="ul_wrap">
               <ul>
                  <li id="_">A</li>
               </ul>
            </div>
            <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
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
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true)
      .sub(%r{^.*<div class="WordSection3">}m, "")
      .sub(%r{</div>\s*<br.*$}m, ""))))
      .to be_equivalent_to Canon.format_xml(word)
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
               <fmt-title id="_" depth="1">Contents</fmt-title>
            </clause>
         </preface>
         <sections>
            <terms id="A" obligation="normative" displayorder="2">
               <title id="_">Terms and definitions</title>
               <fmt-title id="_" depth="1">
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
                  <fmt-name id="_">
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
                     <field-of-application id="_">Field</field-of-application>
                     <usage-info id="_">Usage Info 1</usage-info>
                  </preferred>
                  <fmt-preferred>
                     <p>
                        <semx element="preferred" source="_">
                           <strong>Second Term</strong>
                   <span class="fmt-designation-field">
                      , &lt;
                      <semx element="field-of-application" source="_">Field</semx>
                      ,
                      <semx element="usage-info" source="_">Usage Info 1</semx>
                      &gt;
                   </span>
                        </semx>
                     </p>
                  </fmt-preferred>
                  <definition id="_">
                     <verbal-definition>Definition 1</verbal-definition>
                  </definition>
                  <fmt-definition id="_">
                     <semx element="definition" source="_">Definition 1</semx>
                  </fmt-definition>
               </term>
               <term id="C">
                  <fmt-name id="_">
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
                     <preferred id="_">
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
                  <fmt-definition id="_">
                     <semx element="definition" source="_">Definition 2</semx>
                  </fmt-definition>
               </term>
            </terms>
         </sections>
      </iso-standard>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
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
        <source status='identical'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'>t1</termref>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </source>
        <source status='adapted'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </source>
        <source status='modified'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
          <modification>
            <p id='_'>with adjustments</p>
          </modification>
        </source>
        <source status='identical'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'>t1</termref>
          </origin>
        </source>
        <source status='adapted'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
        </source>
        <source status='modified'>
          <origin citeas=''>
            <termref base='IEV' target='xyz'/>
          </origin>
        </source>
      </term>
    INPUT
    output = <<~OUTPUT
      <terms id="terms_and_definitions" obligation="normative" displayorder="2">
         <title id="_">Terms and Definitions</title>
         <fmt-title id="_" depth="1">
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
            <fmt-name id="_">
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
            <fmt-definition id="_">
               <semx element="definition" source="_">
                  <p id="_">rice retaining its husk after threshing</p>
               </semx>
            </fmt-definition>
            <source status="identical" id="_">
               <origin citeas="">
                  <termref base="IEV" target="xyz">t1</termref>
               </origin>
               <modification id="_">
                  <p id="_">with adjustments</p>
               </modification>
            </source>
            <source status="adapted" id="_">
               <origin citeas="">
                  <termref base="IEV" target="xyz"/>
               </origin>
               <modification id="_">
                  <p original-id="_">with adjustments</p>
               </modification>
            </source>
            <source status="modified" id="_">
               <origin citeas="">
                  <termref base="IEV" target="xyz"/>
               </origin>
               <modification id="_">
                  <p original-id="_">with adjustments</p>
               </modification>
            </source>
            <source status="identical" id="_">
               <origin citeas="">
                  <termref base="IEV" target="xyz">t1</termref>
               </origin>
            </source>
            <source status="adapted" id="_">
               <origin citeas="">
                  <termref base="IEV" target="xyz"/>
               </origin>
            </source>
            <source status="modified" id="_">
               <origin citeas="">
                  <termref base="IEV" target="xyz"/>
               </origin>
            </source>
            <fmt-termsource status="identical">
               [SOURCE:
               <semx element="source" source="_">
                  <origin citeas="" id="_">
                     <termref base="IEV" target="xyz">t1</termref>
                  </origin>
                  <semx element="origin" source="_">
                     <fmt-origin citeas="">
                        <termref base="IEV" target="xyz">t1</termref>
                     </fmt-origin>
                  </semx>
                  —
                  <semx element="modification" source="_">with adjustments</semx>
               </semx>
               ;
               <semx element="source" source="_">
                  <origin citeas="" id="_">
                     <termref base="IEV" target="xyz"/>
                  </origin>
                  <semx element="origin" source="_">
                     <fmt-origin citeas="">
                        <termref base="IEV" target="xyz"/>
                     </fmt-origin>
                  </semx>
                  , modified —
                  <semx element="modification" source="_">with adjustments</semx>
               </semx>
               ;
               <semx element="source" source="_">
                  <origin citeas="" id="_">
                     <termref base="IEV" target="xyz"/>
                  </origin>
                  <semx element="origin" source="_">
                     <fmt-origin citeas="">
                        <termref base="IEV" target="xyz"/>
                     </fmt-origin>
                  </semx>
                  , modified —
                  <semx element="modification" source="_">with adjustments</semx>
               </semx>
               ;
               <semx element="source" source="_">
                  <origin citeas="" id="_">
                     <termref base="IEV" target="xyz">t1</termref>
                  </origin>
                  <semx element="origin" source="_">
                     <fmt-origin citeas="">
                        <termref base="IEV" target="xyz">t1</termref>
                     </fmt-origin>
                  </semx>
               </semx>
               ;
               <semx element="source" source="_">
                  <origin citeas="" id="_">
                     <termref base="IEV" target="xyz"/>
                  </origin>
                  <semx element="origin" source="_">
                     <fmt-origin citeas="">
                        <termref base="IEV" target="xyz"/>
                     </fmt-origin>
                  </semx>
                  , modified
               </semx>
               ;
               <semx element="source" source="_">
                  <origin citeas="" id="_">
                     <termref base="IEV" target="xyz"/>
                  </origin>
                  <semx element="origin" source="_">
                     <fmt-origin citeas="">
                        <termref base="IEV" target="xyz"/>
                     </fmt-origin>
                  </semx>
                  , modified
               </semx>
               ]
            </fmt-termsource>
         </term>
      </terms>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
          .new(presxml_options)
           .convert("test", input, true))
          .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end
  it "renders different types of termsource" do
    input = <<~INPUT
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="3.2.0" schema-version="v2.1.3" flavor="iso">
        <bibdata type="standard"/>
      <sections><terms id="_5f359ecf-13ce-6454-5c80-640a2bf4a403" obligation="normative">
      <title id="_dfb2eab2-f980-6365-3c47-81d0eb272962">Terms and definitions</title><p id="_dcc01114-4d03-3550-1347-4ba901bda94c">For the purposes of this document, the following terms and definitions apply.</p>
      <p id="_1df4aedb-297d-0c69-967f-f6a60db009d2">ISO and IEC maintain terminology databases for use in standardization at the following addresses:</p>

      <ul id="_e6ddc246-88cc-2222-8452-b939a5cefa0e"><li><p id="_93880b15-0e52-9141-f887-d290dce89ffd">ISO Online browsing platform: available at <link target="https://www.iso.org/obp"/></p>
      </li>
      <li><p id="_8a7ecb99-412c-1138-ae9d-76c4ac7b7d43">IEC Electropedia: available at <link target="https://www.electropedia.org"/></p>
      </li>
      </ul>

      <term id="_7d064b9d-3bb9-6e20-e22f-507f5e4097e5" anchor="term-Term-1"><preferred><expression>
      <name>Term 1</name>
      </expression>
      </preferred>
      <definition id="_cd3a2a7d-fa49-0f16-2345-d75a1af91f39"><verbal-definition id="_7d08bf49-9189-01ae-9a21-03260aea3f05"><p id="_08156712-5912-c3f8-37b4-963737b2f532">Definition</p></verbal-definition></definition>


       <source status="identical" type="authoritative"><origin bibitemid="internet_standards" type="inline" citeas="[3]"><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></origin>
      </source></term>

      <term id="_569838e3-e989-f64d-a1e3-61dbb515c552" anchor="term-Term-2"><preferred><expression>
      <name>Term 2</name>
      </expression>
      </preferred>
      <definition id="_d0d28852-8399-7970-7330-4234dda15f4e"><verbal-definition id="_3e46d6f6-8d6f-ac46-c2b0-75a8936dec9b"><p id="_5cee8601-19f1-6e98-a5a7-2b12e954273a">Definition</p></verbal-definition></definition>

       <source status="identical" type="authoritative"><origin bibitemid="internet_standards" type="inline" citeas="[3]"><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></origin>
      </source><source status="identical" type="authoritative"><origin bibitemid="graphql" type="inline" citeas="[4]"><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></origin>
      </source><source status="identical" type="authoritative"><origin bibitemid="iso643" type="inline" citeas="ISO 643"><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></origin>
      </source><source status="identical" type="authoritative"><origin bibitemid="ietf643" type="inline" citeas="IETF RFC 643"><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></origin>
      </source></term>

      <term id="_e317f9aa-b9a4-1293-613f-735347d56e23" anchor="term-Term-3"><preferred><expression>
      <name>Term 3</name>
      </expression>
      </preferred>
      <definition id="_fe95a4cc-db11-d725-38ef-e819e565e6f5"><verbal-definition id="_ca6b2887-689b-cab7-8c7e-2b1a198cfb31"><p id="_5ec1932c-6430-f59a-c279-6d641cf26f4f">Definition</p></verbal-definition></definition>


       <source status="identical" type="authoritative"><origin bibitemid="ihos49" type="inline" citeas="IHO S-49"><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></origin>
      </source></term>
      </terms>
        </sections><bibliography><references id="_239e89aa-72e5-2c0f-73f2-6eeedad3dc9b" normative="true" obligation="informative">
      <title id="_270c5ee6-077e-f285-ff95-287984a30140">Normative references</title><p id="_49996d2b-65c1-916b-9bbf-42b933aa0025">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>

      <bibitem id="_0bf94643-51e7-0612-465a-0ebfaf0ea7f8" type="standard" schema-version="v1.2.9" anchor="ihos49">
        <fetched>2025-11-09</fetched>
      <title type="main" format="text/plain" language="en">Standardization of Mariners’ Routeing Guides</title>

        <uri type="pdf">https://iho.int/uploads/user/pubs/standards/s-49/S-49_e2.0_EN.pdf</uri>
        <docidentifier type="IHO" primary="true">S-49</docidentifier>
        <docnumber>49</docnumber>
        <date type="published">
          <from>2010-04-01</from>
        </date>
        <contributor>
          <role type="publisher"/>
          <organization>
      <name>International Hydrographic Organization</name>

            <abbreviation>IHO</abbreviation>
            <uri>www.iho.int</uri>
          </organization>
        </contributor>
        <edition>2.0.0</edition>
        <version>
          <revision-date>2010-04-01</revision-date>
        </version>
        <language>en</language>
        <language>fr</language>
        <script>Latn</script>
        <status>
          <stage>in-force</stage>
        </status>
        <copyright>
          <from>2010</from>
          <owner>
            <organization>
      <name>International Hydrographic Organization</name>

              <abbreviation>IHO</abbreviation>
              <uri>www.iho.int</uri>
            </organization>
          </owner>
        </copyright>
        <series type="main">
      <title type="original" format="text/plain">        <variant language="en" script="Latn">Standards and Specifications</variant>        <variant language="fr" script="Latn">Normes et Spécifications</variant>     </title>

          <place>Monaco</place>
          <organization>International Hydrographic Organization</organization>
          <number>S</number>
        </series>
        <place>Monaco</place>
        <validity>
          <validityBegins>2010-04-01 00:00</validityBegins>
        </validity>
      </bibitem>
      </references><references id="_2a6e02cf-9fc9-205c-7bc5-0717479c98b5" normative="false" obligation="informative">
      <title id="_50ceb1e1-516f-2673-d73d-4f0c58b4d023">Bibliography</title><bibitem id="_e53b7b5d-73ab-a3f3-9a5c-06d34ca53c86" type="standard" schema-version="v1.2.9" anchor="iso643">
        <fetched>2025-11-10</fetched>
      <title type="main" format="text/plain" language="en" script="Latn">Steels — Micrographic determination of the apparent grain size</title>

        <docidentifier type="ISO" primary="true">ISO 643</docidentifier>
        <docidentifier type="URN">urn:iso:std:iso:643:stage-60.60</docidentifier>
        <docnumber>643</docnumber>
        <contributor>
          <role type="publisher"/>
          <organization>
      <name>International Organization for Standardization</name>

            <abbreviation>ISO</abbreviation>
            <uri>www.iso.org</uri>
          </organization>
        </contributor>
        <edition>5</edition>
        <language>en</language>
        <language>fr</language>
        <script>Latn</script>
        <status>
          <stage>60</stage>
          <substage>60</substage>
        </status>
        <copyright>
          <from>2024</from>
          <owner>
            <organization>
      <name>ISO</name>

            </organization>
          </owner>
        </copyright>
      </bibitem><bibitem id="_a4f328bd-83e3-7e30-b615-ee100b0353fe" type="standard" schema-version="v1.2.9" anchor="ietf643">
        <fetched>2025-11-10</fetched>
      <title type="main" format="text/plain">Network Debugging Protocol</title>

        <uri type="src">https://www.rfc-editor.org/info/rfc643</uri>
        <docidentifier type="IETF" primary="true">RFC 643</docidentifier>
        <docidentifier type="DOI">10.17487/RFC0643</docidentifier>
        <docnumber>RFC0643</docnumber>
        <date type="published">
          <on>1974-07</on>
        </date>
        <contributor>
          <role type="author"/>
          <person>
      <name>          <completename language="en" script="Latn">E. Mader</completename>       </name>

          </person>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
      <name>RFC Publisher</name>

          </organization>
        </contributor>
        <contributor>
          <role type="authorizer"/>
          <organization>
      <name>RFC Series</name>

          </organization>
        </contributor>
        <language>en</language>
        <script>Latn</script>
        <abstract format="text/html" language="en" script="Latn">
          <p id="_90cdb0ff-afa4-fdbd-e41a-af9941b771fa">To be used in an implementation of a PDP-11 network bootstrap device and a cross-network debugger.</p>

        </abstract>
        <series>
      <title format="text/plain">RFC</title>

          <number>643</number>
        </series>
        <series type="stream">
      <title format="text/plain">Legacy</title>

        </series>
      </bibitem><bibitem anchor="internet_standards" id="_ba141f1c-0ee3-7ad0-eb2a-bcee27aa6af8" type="webresource">
        <formattedref format="application/x-isodoc+xml">Internet Engineering Task Force#{' '}
      Internet Standards#{' '}
      July 2024#{' '}
      <link target="https://www.rfc-editor.org/standards#IS"/></formattedref>
        <title>Internet Standards</title>
        <uri>https://www.rfc-editor.org/standards#IS</uri>
        <docidentifier type="metanorma">[3]</docidentifier>
        <date type="published">
        <on>July 2024</on>
      </date>
        <contributor>
        <role type="author"/>
        <organization>
          <name>Internet Engineering Task Force</name>
        </organization>
      </contributor>
        <language>en</language>
        <script>Latn</script>
      </bibitem><bibitem anchor="graphql" id="_f6915ecc-cd1b-5c9c-0a62-9fecc313d104" type="standard">
        <formattedref format="application/x-isodoc+xml">Joint Development Foundation Projects, LLC#{' '}
      The GraphQL Specification Project#{' '}
      October 2021#{' '}
      <link target="https://spec.graphql.org"/></formattedref>
        <title>The GraphQL Specification Project</title>
        <uri>https://spec.graphql.org</uri>
        <docidentifier type="metanorma">[4]</docidentifier>
        <date type="published">
        <on>October 2021</on>
      </date>
        <contributor>
        <role type="author"/>
        <organization>
          <name>Joint Development Foundation Projects, LLC</name>
        </organization>
      </contributor>
        <language>en</language>
        <script>Latn</script>
      </bibitem>

      </references></bibliography>
      </metanorma>
    INPUT
    output = <<~OUTPUT
       <terms id="_" obligation="normative" displayorder="3">
          <title id="_">Terms and definitions</title>
          <fmt-title depth="1" id="_">
             <span class="fmt-caption-label">
                <semx element="autonum" source="_">2</semx>
             </span>
             <span class="fmt-caption-delim">
                <tab/>
             </span>
             <semx element="title" source="_">Terms and definitions</semx>
          </fmt-title>
          <fmt-xref-label>
             <span class="fmt-element-name">Clause</span>
             <semx element="autonum" source="_">2</semx>
          </fmt-xref-label>
          <p id="_">For the purposes of this document, the following terms and definitions apply.</p>
          <p id="_">ISO and IEC maintain terminology databases for use in standardization at the following addresses:</p>
          <ul id="_">
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
                <p id="_">
                   ISO Online browsing platform: available at
                   <link target="https://www.iso.org/obp" id="_"/>
                   <semx element="link" source="_">
                      <fmt-link target="https://www.iso.org/obp"/>
                   </semx>
                </p>
             </li>
             <li id="_">
                <fmt-name id="_">
                   <semx element="autonum" source="_">—</semx>
                </fmt-name>
                <p id="_">
                   IEC Electropedia: available at
                   <link target="https://www.electropedia.org" id="_"/>
                   <semx element="link" source="_">
                      <fmt-link target="https://www.electropedia.org"/>
                   </semx>
                </p>
             </li>
          </ul>
          <term id="term-Term-1" anchor="term-Term-1">
             <fmt-name id="_">
                <span class="fmt-caption-label">
                   <semx element="autonum" source="_">2</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="term-Term-1">1</semx>
                </span>
             </fmt-name>
             <fmt-xref-label>
                <semx element="autonum" source="_">2</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="term-Term-1">1</semx>
             </fmt-xref-label>
             <preferred id="_">
                <expression>
                   <name>Term 1</name>
                </expression>
             </preferred>
             <fmt-preferred>
                <p>
                   <semx element="preferred" source="_">
                      <strong>Term 1</strong>
                   </semx>
                </p>
             </fmt-preferred>
             <definition id="_">
                <verbal-definition id="_">
                   <p original-id="_">Definition</p>
                </verbal-definition>
             </definition>
             <fmt-definition id="_">
                <semx element="definition" source="_">
                   <p id="_">Definition</p>
                </semx>
             </fmt-definition>
             <source status="identical" type="authoritative" id="_">
                <origin bibitemid="internet_standards" type="inline" citeas="[3]">
                   <localityStack>
                      <locality type="clause">
                         <referenceFrom>3</referenceFrom>
                      </locality>
                   </localityStack>
                </origin>
             </source>
             <fmt-termsource status="identical" type="authoritative">
                [SOURCE:
                <semx element="source" source="_">
                   <origin bibitemid="internet_standards" type="inline" citeas="[3]" id="_">
                      <localityStack>
                         <locality type="clause">
                            <referenceFrom>3</referenceFrom>
                         </locality>
                      </localityStack>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-xref type="inline" style="short" target="internet_standards">
                         INTERNET ENGINEERING TASK FORCE.
                         <em>
                            <span class="stddocTitle">Internet Standards</span>
                         </em>
                         [website]. 2024,
                         <span class="citesec">Clause 3</span>
                      </fmt-xref>
                      <fmt-xref target="internet_standards">
                         <sup>[3]</sup>
                      </fmt-xref>
                   </semx>
                </semx>
                ]
             </fmt-termsource>
          </term>
          <term id="term-Term-2" anchor="term-Term-2">
             <fmt-name id="_">
                <span class="fmt-caption-label">
                   <semx element="autonum" source="_">2</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="term-Term-2">2</semx>
                </span>
             </fmt-name>
             <fmt-xref-label>
                <semx element="autonum" source="_">2</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="term-Term-2">2</semx>
             </fmt-xref-label>
             <preferred id="_">
                <expression>
                   <name>Term 2</name>
                </expression>
             </preferred>
             <fmt-preferred>
                <p>
                   <semx element="preferred" source="_">
                      <strong>Term 2</strong>
                   </semx>
                </p>
             </fmt-preferred>
             <definition id="_">
                <verbal-definition id="_">
                   <p original-id="_">Definition</p>
                </verbal-definition>
             </definition>
             <fmt-definition id="_">
                <semx element="definition" source="_">
                   <p id="_">Definition</p>
                </semx>
             </fmt-definition>
             <source status="identical" type="authoritative" id="_">
                <origin bibitemid="internet_standards" type="inline" citeas="[3]">
                   <localityStack>
                      <locality type="clause">
                         <referenceFrom>3</referenceFrom>
                      </locality>
                   </localityStack>
                </origin>
             </source>
             <source status="identical" type="authoritative" id="_">
                <origin bibitemid="graphql" type="inline" citeas="[4]">
                   <localityStack>
                      <locality type="clause">
                         <referenceFrom>3</referenceFrom>
                      </locality>
                   </localityStack>
                </origin>
             </source>
             <source status="identical" type="authoritative" id="_">
                <origin bibitemid="iso643" type="inline" citeas="ISO 643">
                   <localityStack>
                      <locality type="clause">
                         <referenceFrom>3</referenceFrom>
                      </locality>
                   </localityStack>
                </origin>
             </source>
             <source status="identical" type="authoritative" id="_">
                <origin bibitemid="ietf643" type="inline" citeas="IETF RFC 643">
                   <localityStack>
                      <locality type="clause">
                         <referenceFrom>3</referenceFrom>
                      </locality>
                   </localityStack>
                </origin>
             </source>
             <fmt-termsource status="identical" type="authoritative">
                [SOURCE:
                <semx element="source" source="_">
                   <origin bibitemid="internet_standards" type="inline" citeas="[3]" id="_">
                      <localityStack>
                         <locality type="clause">
                            <referenceFrom>3</referenceFrom>
                         </locality>
                      </localityStack>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-xref type="inline" style="short" target="internet_standards">
                         INTERNET ENGINEERING TASK FORCE.
                         <em>
                            <span class="stddocTitle">Internet Standards</span>
                         </em>
                         [website]. 2024,
                         <span class="citesec">Clause 3</span>
                      </fmt-xref>
                      <fmt-xref target="internet_standards">
                         <sup>[3]</sup>
                      </fmt-xref>
                   </semx>
                </semx>
                ;
                <semx element="source" source="_">
                   <origin bibitemid="graphql" type="inline" citeas="[4]" id="_">
                      <localityStack>
                         <locality type="clause">
                            <referenceFrom>3</referenceFrom>
                         </locality>
                      </localityStack>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-xref type="inline" style="short" target="graphql">
                         JOINT DEVELOPMENT FOUNDATION PROJECTS, LLC.
                         <em>
                            <span class="stddocTitle">The GraphQL Specification Project</span>
                         </em>
                         ,
                         <span class="citesec">Clause 3</span>
                      </fmt-xref>
                      <fmt-xref target="graphql">
                         <sup>[4]</sup>
                      </fmt-xref>
                   </semx>
                </semx>
                ;
                <semx element="source" source="_">
                   <origin bibitemid="iso643" type="inline" citeas="ISO 643" id="_">
                      <localityStack>
                         <locality type="clause">
                            <referenceFrom>3</referenceFrom>
                         </locality>
                      </localityStack>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-xref type="inline" target="iso643">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">643</span>
                         ,
                         <span class="citesec">Clause 3</span>
                      </fmt-xref>
                   </semx>
                </semx>
                ;
                <semx element="source" source="_">
                   <origin bibitemid="ietf643" type="inline" citeas="IETF RFC 643" id="_">
                      <localityStack>
                         <locality type="clause">
                            <referenceFrom>3</referenceFrom>
                         </locality>
                      </localityStack>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-xref type="inline" target="ietf643">
                         <span class="stdpublisher">IETF </span>
                         <span class="stdpublisher">RFC </span>
                         <span class="stddocNumber">643</span>
                         ,
                         <span class="citesec">Clause 3</span>
                      </fmt-xref>
                      <fmt-xref target="ietf643">
                         <sup>[2]</sup>
                      </fmt-xref>
                   </semx>
                </semx>
                ]
             </fmt-termsource>
          </term>
          <term id="term-Term-3" anchor="term-Term-3">
             <fmt-name id="_">
                <span class="fmt-caption-label">
                   <semx element="autonum" source="_">2</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="term-Term-3">3</semx>
                </span>
             </fmt-name>
             <fmt-xref-label>
                <semx element="autonum" source="_">2</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="term-Term-3">3</semx>
             </fmt-xref-label>
             <preferred id="_">
                <expression>
                   <name>Term 3</name>
                </expression>
             </preferred>
             <fmt-preferred>
                <p>
                   <semx element="preferred" source="_">
                      <strong>Term 3</strong>
                   </semx>
                </p>
             </fmt-preferred>
             <definition id="_">
                <verbal-definition id="_">
                   <p original-id="_">Definition</p>
                </verbal-definition>
             </definition>
             <fmt-definition id="_">
                <semx element="definition" source="_">
                   <p id="_">Definition</p>
                </semx>
             </fmt-definition>
             <source status="identical" type="authoritative" id="_">
                <origin bibitemid="ihos49" type="inline" citeas="IHO S-49">
                   <localityStack>
                      <locality type="clause">
                         <referenceFrom>3</referenceFrom>
                      </locality>
                   </localityStack>
                </origin>
             </source>
             <fmt-termsource status="identical" type="authoritative">
                [SOURCE:
                <semx element="source" source="_">
                   <origin bibitemid="ihos49" type="inline" citeas="IHO S-49" id="_">
                      <localityStack>
                         <locality type="clause">
                            <referenceFrom>3</referenceFrom>
                         </locality>
                      </localityStack>
                   </origin>
                   <semx element="origin" source="_">
                      <fmt-xref type="inline" target="ihos49">
                         <span class="stdpublisher">IHO</span>
                          S-
                         <span class="stddocNumber">49</span>
                         ,
                         <span class="citesec">Clause 3</span>
                      </fmt-xref>
                   </semx>
                </semx>
                ]
             </fmt-termsource>
          </term>
       </terms>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
          .new(presxml_options)
           .convert("test", input, true))
          .at("//xmlns:terms").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
