require "spec_helper"

RSpec.describe IsoDoc do
  it "processes concept markup" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="Terms">
          <term id="B"><preferred><expression><name>B</name></expression></preferred>
          <p>
          <ul>
            <li><concept><refterm>term0</refterm>
              <xref target='clause1'/>
            </concept></li>
            <li><concept><refterm>term1</refterm>
              <renderterm>term</renderterm>
              <xref target='clause1'/>
            </concept></li>
          <li><concept><refterm>term2</refterm>
              <renderterm>w[o]rd</renderterm>
              <xref target='clause1'>Clause #1</xref>
            </concept></li>
            <li><concept><refterm>term3</refterm>
              <renderterm>term</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712"/>
            </concept></li>
            <li><concept><refterm>term4</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">The Aforementioned Citation</eref>
            </concept></li>
            <li><concept><refterm>term5</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
                <locality type='figure'>
                  <referenceFrom>a</referenceFrom>
                </locality>
              </eref>
            </concept></li>
            <li><concept><refterm>term6</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack connective="and">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack connective="and">
                <locality type='figure'>
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              </eref>
            </concept></li>
            <li><concept><refterm>term7</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack connective="and">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack connective="and">
                <locality type='figure'>
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              The Aforementioned Citation
              </eref>
            </concept></li>
            <li><concept><refterm>term8</refterm>
              <renderterm>word</renderterm>
              <termref base='IEV' target='135-13-13'/>
            </concept></li>
            <li><concept><refterm>term9</refterm>
              <renderterm>word</renderterm>
              <termref base='IEV' target='135-13-13'>The IEV database</termref>
            </concept></li>
            <li><concept><refterm>term10</refterm>
              <renderterm>word</renderterm>
              <strong>error!</strong>
            </concept></li>
            </ul>
          </p>
          </term>
          </terms>
          <clause id="clause1"><title>Clause 1</title></clause>
          </sections>
          <bibliography><references id="_" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography>
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
             <terms id="Terms" displayorder="3">
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="Terms">2</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="Terms">2</semx>
                </fmt-xref-label>
                <term id="B">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="Terms">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="B">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <semx element="autonum" source="Terms">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="B">1</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name>B</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <p>
                         <semx element="preferred" source="_">
                            <strong>B</strong>
                         </semx>
                      </p>
                   </fmt-preferred>
                   <p>
                      <ul>
                         <li>
                            <concept id="_">
                               <refterm>term0</refterm>
                               <xref target="clause1" original-id="_"/>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <semx element="xref" source="_">
                                     (
                                     <fmt-xref target="clause1">
                                        <span class="citesec">
                                           <span class="fmt-element-name">Clause</span>
                                           <semx element="autonum" source="clause1">3</semx>
                                        </span>
                                     </fmt-xref>
                                     )
                                  </semx>
                               </semx>
                            </fmt-concept>
                         </li>
                         <li>
                            <concept id="_">
                               <refterm>term1</refterm>
                               <renderterm>term</renderterm>
                               <xref target="clause1" original-id="_"/>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <em>term</em>
                                  <semx element="xref" source="_">
                                     (
                                     <fmt-xref target="clause1">
                                        <span class="citesec">
                                           <span class="fmt-element-name">Clause</span>
                                           <semx element="autonum" source="clause1">3</semx>
                                        </span>
                                     </fmt-xref>
                                     )
                                  </semx>
                               </semx>
                            </fmt-concept>
                         </li>
                         <li>
                            <concept id="_">
                               <refterm>term2</refterm>
                               <renderterm>w[o]rd</renderterm>
                               <xref target="clause1" original-id="_">Clause #1</xref>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <em>w[o]rd</em>
                                  <semx element="xref" source="_">
                                     (
                                     <fmt-xref target="clause1">Clause #1</fmt-xref>
                                     )
                                  </semx>
                               </semx>
                            </fmt-concept>
                         </li>
                         <li>
                            <concept id="_">
                               <refterm>term3</refterm>
                               <renderterm>term</renderterm>
                               <eref bibitemid="ISO712" type="inline" citeas="ISO 712" original-id="_"/>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <em>term</em>
                                  <semx element="eref" source="_">
                                     (
                                     <fmt-xref type="inline" target="ISO712">
                                        <span class="stdpublisher">ISO </span>
                                        <span class="stddocNumber">712</span>
                                     </fmt-xref>
                                     )
                                  </semx>
                               </semx>
                            </fmt-concept>
                         </li>
                         <li>
                            <concept id="_">
                               <refterm>term4</refterm>
                               <renderterm>word</renderterm>
                               <eref bibitemid="ISO712" type="inline" citeas="ISO 712" original-id="_">The Aforementioned Citation</eref>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <em>word</em>
                                  <semx element="eref" source="_">
                                     (
                                     <fmt-xref type="inline" target="ISO712">The Aforementioned Citation</fmt-xref>
                                     )
                                  </semx>
                               </semx>
                            </fmt-concept>
                         </li>
                         <li>
                            <concept id="_">
                               <refterm>term5</refterm>
                               <renderterm>word</renderterm>
                               <eref bibitemid="ISO712" type="inline" citeas="ISO 712" original-id="_">
                                  <locality type="clause">
                                     <referenceFrom>3.1</referenceFrom>
                                  </locality>
                                  <locality type="figure">
                                     <referenceFrom>a</referenceFrom>
                                  </locality>
                               </eref>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <em>word</em>
                                  <semx element="eref" source="_">
                                     (
                                     <fmt-xref type="inline" target="ISO712">
                                        <span class="stdpublisher">ISO </span>
                                        <span class="stddocNumber">712</span>
                                        ,
                                        <span class="citesec">3.1</span>
                                        ,
                                        <span class="citefig">Figure a</span>
                                     </fmt-xref>
                                     )
                                  </semx>
                               </semx>
                            </fmt-concept>
                         </li>
                         <li>
                            <concept id="_">
                               <refterm>term6</refterm>
                               <renderterm>word</renderterm>
                               <eref bibitemid="ISO712" type="inline" citeas="ISO 712" original-id="_">
                                  <localityStack connective="and">
                                     <locality type="clause">
                                        <referenceFrom>3.1</referenceFrom>
                                     </locality>
                                  </localityStack>
                                  <localityStack connective="and">
                                     <locality type="figure">
                                        <referenceFrom>b</referenceFrom>
                                     </locality>
                                  </localityStack>
                               </eref>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <em>word</em>
                                  <semx element="eref" source="_">
                                     (
                                     <fmt-xref type="inline" target="ISO712">
                                        <span class="stdpublisher">ISO </span>
                                        <span class="stddocNumber">712</span>
                                        ,
                                        <span class="citesec">3.1</span>
                                        <span class="fmt-conn">and</span>
                                        <span class="citefig">Figure b</span>
                                     </fmt-xref>
                                     )
                                  </semx>
                               </semx>
                            </fmt-concept>
                         </li>
                         <li>
                            <concept id="_">
                               <refterm>term7</refterm>
                               <renderterm>word</renderterm>
                               <eref bibitemid="ISO712" type="inline" citeas="ISO 712" original-id="_">
                                  <localityStack connective="and">
                                     <locality type="clause">
                                        <referenceFrom>3.1</referenceFrom>
                                     </locality>
                                  </localityStack>
                                  <localityStack connective="and">
                                     <locality type="figure">
                                        <referenceFrom>b</referenceFrom>
                                     </locality>
                                  </localityStack>
                                  The Aforementioned Citation
                               </eref>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <em>word</em>
                                  <semx element="eref" source="_">
                                     (
                                     <fmt-xref type="inline" target="ISO712">
               
               
               The Aforementioned Citation
               </fmt-xref>
                                     )
                                  </semx>
                               </semx>
                            </fmt-concept>
                         </li>
                         <li>
                            <concept id="_">
                               <refterm>term8</refterm>
                               <renderterm>word</renderterm>
                               <termref base="IEV" target="135-13-13"/>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <em>word</em>
                                  (
                                  <termref base="IEV" target="135-13-13"/>
                                  )
                               </semx>
                            </fmt-concept>
                         </li>
                         <li>
                            <concept id="_">
                               <refterm>term9</refterm>
                               <renderterm>word</renderterm>
                               <termref base="IEV" target="135-13-13">The IEV database</termref>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <em>word</em>
                                  (
                                  <termref base="IEV" target="135-13-13">The IEV database</termref>
                                  )
                               </semx>
                            </fmt-concept>
                         </li>
                         <li>
                            <concept id="_">
                               <refterm>term10</refterm>
                               <renderterm>word</renderterm>
                               <strong>error!</strong>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <em>word</em>
                                  <strong>error!</strong>
                               </semx>
                            </fmt-concept>
                         </li>
                      </ul>
                   </p>
                </term>
             </terms>
             <clause id="clause1" displayorder="4">
                <title id="_">Clause 1</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="clause1">3</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 1</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="clause1">3</semx>
                </fmt-xref-label>
             </clause>
             <references id="_" obligation="informative" normative="true" displayorder="2">
                <title id="_">Normative References</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                <bibitem id="ISO712" type="standard">
                   <formattedref>
                      <em>
                         <span class="stddocTitle">Cereals and cereal products</span>
                      </em>
                   </formattedref>
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">Cereals and cereal products</title>
                   <docidentifier type="ISO">ISO 712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                   <biblio-tag>
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      ,
                   </biblio-tag>
                </bibitem>
             </references>
          </sections>
          <bibliography/>
       </iso-standard>
    OUTPUT
    output = <<~OUTPUT
      #{HTML_HDR}
             <div>
               <h1>1  Normative References</h1>
               <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
               <p id="ISO712" class="NormRef"><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span>, <i><span class="stddocTitle">Cereals and cereal products</span></i></p>
             </div>
                          <div id="Terms">
               <h1>2</h1>
               <p class="TermNum" id="B">2.1</p>
               <p class="Terms" style="text-align:left;">
                 <b>B</b>
               </p>
               <p>
               <div class="ul_wrap">
                 <ul>
                   <li>
               (<a href="#clause1"><span class="citesec">Clause 3</span></a>)
             </li>
                   <li><i>term</i>
               (<a href="#clause1"><span class="citesec">Clause 3</span></a>)
             </li>
                   <li><i>w[o]rd</i>
               (<a href="#clause1">Clause #1</a>)
             </li>
                   <li><i>term</i>
               (<a href="#ISO712"><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span></a>)
             </li>
                   <li><i>word</i>
               (<a href="#ISO712">The Aforementioned Citation</a>)
             </li>
                   <li><i>word</i>
               (<a href="#ISO712"><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span>, <span class="citesec">3.1</span>, <span class="citefig">Figure a</span></a>)
             </li>
                   <li><i>word</i>
               (<a href="#ISO712"><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span>, <span class="citesec">3.1</span> and <span class="citefig">Figure b</span></a>)
             </li>
                   <li><i>word</i>
               (<a href="#ISO712">


               The Aforementioned Citation
               </a>)
             </li>
                   <li><i>word</i>
               (Termbase IEV, term ID 135-13-13)
             </li>
                   <li><i>word</i>
               (The IEV database)
             </li>
                   <li>
                     <i>word</i>
                     <b>error!</b>
                   </li>
                 </ul>
                 </div>
               </p>
             </div>
             <div id="clause1">
               <h1>3  Clause 1</h1>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes concept markup by context" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword id="A">
      <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
      </foreword></preface>
      <sections>
      <terms id="Terms">
      <clause id="A">
             <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
      </clause>
      <term id="clause1">
       <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
        </term>
      <term id="clause2">
       <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
        </term>
             <term id="clause3">
       <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
        <term id="clause4">
               <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
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
              <foreword id="A" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="2">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="Terms">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <semx element="autonum" source="Terms">1</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="A">1</semx>
                 </fmt-xref-label>
                 <ul>
                    <li>
                       <concept id="_">
                          <refterm>term1</refterm>
                          <renderterm>term</renderterm>
                          <xref target="clause1" original-id="_"/>
                       </concept>
                       <fmt-concept>
                          <semx element="concept" source="_">term</semx>
                       </fmt-concept>
                    </li>
                 </ul>
              </foreword>
           </preface>
           <sections>
              <terms id="Terms" displayorder="3">
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="Terms">1</semx>
                    </span>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="Terms">1</semx>
                 </fmt-xref-label>
                 <clause id="A" inline-header="true">
                    <fmt-title depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="Terms">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="A">1</semx>
                       </span>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="Terms">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="A">1</semx>
                    </fmt-xref-label>
                    <ul>
                       <li>
                          <concept id="_">
                             <refterm>term1</refterm>
                             <renderterm>term</renderterm>
                             <xref target="clause1" original-id="_"/>
                          </concept>
                          <fmt-concept>
                             <semx element="concept" source="_">term</semx>
                          </fmt-concept>
                       </li>
                    </ul>
                 </clause>
                 <term id="clause1">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="Terms">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="clause1">2</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="Terms">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="clause1">2</semx>
                    </fmt-xref-label>
                    <ul>
                       <li>
                          <concept id="_">
                             <refterm>term1</refterm>
                             <renderterm>term</renderterm>
                             <xref target="clause1" original-id="_"/>
                          </concept>
                          <fmt-concept>
                             <semx element="concept" source="_">
                                <em>term</em>
                                <semx element="xref" source="_">
                                   (
                                   <fmt-xref target="clause1">
                                      <span class="citesec">
                                         <semx element="autonum" source="Terms">1</semx>
                                         <span class="fmt-autonum-delim">.</span>
                                         <semx element="autonum" source="clause1">2</semx>
                                      </span>
                                   </fmt-xref>
                                   )
                                </semx>
                             </semx>
                          </fmt-concept>
                       </li>
                       <li>
                          <concept id="_">
                             <refterm>term1</refterm>
                             <renderterm>term</renderterm>
                             <xref target="clause1" original-id="_"/>
                          </concept>
                          <fmt-concept>
                             <semx element="concept" source="_">term</semx>
                          </fmt-concept>
                       </li>
                    </ul>
                 </term>
                 <term id="clause2">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="Terms">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="clause2">3</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="Terms">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="clause2">3</semx>
                    </fmt-xref-label>
                    <ul>
                       <li>
                          <concept id="_">
                             <refterm>term1</refterm>
                             <renderterm>term</renderterm>
                             <xref target="clause1" original-id="_"/>
                          </concept>
                          <fmt-concept>
                             <semx element="concept" source="_">
                                <em>term</em>
                                <semx element="xref" source="_">
                                   (
                                   <fmt-xref target="clause1">
                                      <span class="citesec">
                                         <semx element="autonum" source="Terms">1</semx>
                                         <span class="fmt-autonum-delim">.</span>
                                         <semx element="autonum" source="clause1">2</semx>
                                      </span>
                                   </fmt-xref>
                                   )
                                </semx>
                             </semx>
                          </fmt-concept>
                       </li>
                       <li>
                          <concept id="_">
                             <refterm>term1</refterm>
                             <renderterm>term</renderterm>
                             <xref target="clause1" original-id="_"/>
                          </concept>
                          <fmt-concept>
                             <semx element="concept" source="_">term</semx>
                          </fmt-concept>
                       </li>
                    </ul>
                 </term>
                 <term id="clause3">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="Terms">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="clause3">4</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="Terms">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="clause3">4</semx>
                    </fmt-xref-label>
                    <ul>
                       <li>
                          <concept id="_">
                             <refterm>term1</refterm>
                             <renderterm>term</renderterm>
                             <xref target="clause1" original-id="_"/>
                          </concept>
                          <fmt-concept>
                             <semx element="concept" source="_">
                                <em>term</em>
                                <semx element="xref" source="_">
                                   (
                                   <fmt-xref target="clause1">
                                      <span class="citesec">
                                         <semx element="autonum" source="Terms">1</semx>
                                         <span class="fmt-autonum-delim">.</span>
                                         <semx element="autonum" source="clause1">2</semx>
                                      </span>
                                   </fmt-xref>
                                   )
                                </semx>
                             </semx>
                          </fmt-concept>
                       </li>
                       <li>
                          <concept id="_">
                             <refterm>term1</refterm>
                             <renderterm>term</renderterm>
                             <xref target="clause1" original-id="_"/>
                          </concept>
                          <fmt-concept>
                             <semx element="concept" source="_">term</semx>
                          </fmt-concept>
                       </li>
                    </ul>
                    <term id="clause4">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <semx element="autonum" source="Terms">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="clause3">4</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="clause4">1</semx>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <semx element="autonum" source="Terms">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="clause3">4</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="clause4">1</semx>
                       </fmt-xref-label>
                       <ul>
                          <li>
                             <concept id="_">
                                <refterm>term1</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">
                                   <em>term</em>
                                   <semx element="xref" source="_">
                                      (
                                      <fmt-xref target="clause1">
                                         <span class="citesec">
                                            <semx element="autonum" source="Terms">1</semx>
                                            <span class="fmt-autonum-delim">.</span>
                                            <semx element="autonum" source="clause1">2</semx>
                                         </span>
                                      </fmt-xref>
                                      )
                                   </semx>
                                </semx>
                             </fmt-concept>
                          </li>
                          <li>
                             <concept id="_">
                                <refterm>term1</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">term</semx>
                             </fmt-concept>
                          </li>
                       </ul>
                    </term>
                 </term>
              </terms>
           </sections>
        </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes concept markup in term definitions" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
      <terms id="Terms">
      <term id="clause1">
      <preferred>A</preferred>
      <definition>
      <ul>
      <concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
        </definition>
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
              <terms id="Terms" displayorder="2">
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="Terms">1</semx>
                    </span>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="Terms">1</semx>
                 </fmt-xref-label>
                 <term id="clause1">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="Terms">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="clause1">1</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="Terms">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="clause1">1</semx>
                    </fmt-xref-label>
                    <preferred id="_">A</preferred>
                    <definition id="_">
                       <ul>
                          <concept>
                             <refterm>term1</refterm>
                             <renderterm>term</renderterm>
                             <xref target="clause1"/>
                          </concept>
                       </ul>
                       <li>
                          <concept>
                             <refterm>term1</refterm>
                             <renderterm>term</renderterm>
                             <xref target="clause1"/>
                          </concept>
                       </li>
                    </definition>
                    <fmt-definition>
                       <semx element="definition" source="_">
                          <ul>
                             <concept id="_">
                                <refterm>term1</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">
                                   <em>term</em>
                                   <semx element="xref" source="_">
                                      (
                                      <fmt-xref target="clause1">
                                         <span class="citesec">
                                            <semx element="autonum" source="Terms">1</semx>
                                            <span class="fmt-autonum-delim">.</span>
                                            <semx element="autonum" source="clause1">1</semx>
                                         </span>
                                      </fmt-xref>
                                      )
                                   </semx>
                                </semx>
                             </fmt-concept>
                          </ul>
                          <li>
                             <concept id="_">
                                <refterm>term1</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">term</semx>
                             </fmt-concept>
                          </li>
                       </semx>
                    </fmt-definition>
                 </term>
              </terms>
           </sections>
        </iso-standard>
        OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes concept attributes" do
    input = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <clause id="clause1"><title>Clause 1</title></clause>
       <terms id="A">
       <term id="B"><preferred><expression><name>B</name></expression></preferred<
       <p>
       <ul>
       <li>
              <concept ital="true"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
         <li><concept ref="true"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
       <li><concept ital="true" ref="true"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
        <li><concept ital="false"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
         <li><concept ref="false"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
       <li><concept ital="false" ref="false"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
       <li><concept ital="true" ref="true" linkmention="true" linkref="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept></li>
       <li><concept ital="true" ref="true" linkmention="true" linkref="false"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept></li>
       <li><concept ital="true" ref="true" linkmention="false" linkref="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept></li>
       <li><concept ital="true" ref="true" linkmention="false" linkref="false"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept></li>
        </ul></p>
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
              <clause id="clause1" displayorder="2">
                 <title id="_">Clause 1</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="clause1">1</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Clause 1</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="clause1">1</semx>
                 </fmt-xref-label>
              </clause>
              <terms id="A" displayorder="3">
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="A">2</semx>
                    </span>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="A">2</semx>
                 </fmt-xref-label>
                 <term id="B">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="A">2</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="B">1</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="A">2</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="B">1</semx>
                    </fmt-xref-label>
                    <preferred id="_">
                       <expression>
                          <name>B</name>
                       </expression>
                    </preferred>
                    <fmt-preferred>
                       <p>
                          <semx element="preferred" source="_">
                             <strong>B</strong>
                          </semx>
                       </p>
                    </fmt-preferred>
                    <p>
                       <ul>
                          <li>
                             <concept ital="true" id="_">
                                <refterm>term</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">
                                   <em>term</em>
                                   <semx element="xref" source="_">
                                      (
                                      <fmt-xref target="clause1">
                                         <span class="citesec">
                                            <span class="fmt-element-name">Clause</span>
                                            <semx element="autonum" source="clause1">1</semx>
                                         </span>
                                      </fmt-xref>
                                      )
                                   </semx>
                                </semx>
                             </fmt-concept>
                          </li>
                          <li>
                             <concept ref="true" id="_">
                                <refterm>term</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">
                                   term
                                   <semx element="xref" source="_">
                                      (
                                      <fmt-xref target="clause1">
                                         <span class="citesec">
                                            <span class="fmt-element-name">Clause</span>
                                            <semx element="autonum" source="clause1">1</semx>
                                         </span>
                                      </fmt-xref>
                                      )
                                   </semx>
                                </semx>
                             </fmt-concept>
                          </li>
                          <li>
                             <concept ital="true" ref="true" id="_">
                                <refterm>term</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">
                                   <em>term</em>
                                   <semx element="xref" source="_">
                                      (
                                      <fmt-xref target="clause1">
                                         <span class="citesec">
                                            <span class="fmt-element-name">Clause</span>
                                            <semx element="autonum" source="clause1">1</semx>
                                         </span>
                                      </fmt-xref>
                                      )
                                   </semx>
                                </semx>
                             </fmt-concept>
                          </li>
                          <li>
                             <concept ital="false" id="_">
                                <refterm>term</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">term</semx>
                             </fmt-concept>
                          </li>
                          <li>
                             <concept ref="false" id="_">
                                <refterm>term</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">term</semx>
                             </fmt-concept>
                          </li>
                          <li>
                             <concept ital="false" ref="false" id="_">
                                <refterm>term</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">term</semx>
                             </fmt-concept>
                          </li>
                          <li>
                             <concept ital="true" ref="true" linkmention="true" linkref="true" id="_">
                                <refterm>term</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">
                                   <semx element="xref" source="_">
                                      <fmt-xref target="clause1">
                                         <em>term</em>
                                      </fmt-xref>
                                   </semx>
                                   <semx element="xref" source="_">
                                      (
                                      <fmt-xref target="clause1">
                                         <span class="citesec">
                                            <span class="fmt-element-name">Clause</span>
                                            <semx element="autonum" source="clause1">1</semx>
                                         </span>
                                      </fmt-xref>
                                      )
                                   </semx>
                                </semx>
                             </fmt-concept>
                          </li>
                          <li>
                             <concept ital="true" ref="true" linkmention="true" linkref="false" id="_">
                                <refterm>term</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">
                                   <semx element="xref" source="_">
                                      <fmt-xref target="clause1">
                                         <em>term</em>
                                      </fmt-xref>
                                   </semx>
                                   <semx element="xref" source="_">
                                      (
                                      <span class="citesec">
                                         <span class="fmt-element-name">Clause</span>
                                         <semx element="autonum" source="clause1">1</semx>
                                      </span>
                                      )
                                   </semx>
                                </semx>
                             </fmt-concept>
                          </li>
                          <li>
                             <concept ital="true" ref="true" linkmention="false" linkref="true" id="_">
                                <refterm>term</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">
                                   <em>term</em>
                                   <semx element="xref" source="_">
                                      (
                                      <fmt-xref target="clause1">
                                         <span class="citesec">
                                            <span class="fmt-element-name">Clause</span>
                                            <semx element="autonum" source="clause1">1</semx>
                                         </span>
                                      </fmt-xref>
                                      )
                                   </semx>
                                </semx>
                             </fmt-concept>
                          </li>
                          <li>
                             <concept ital="true" ref="true" linkmention="false" linkref="false" id="_">
                                <refterm>term</refterm>
                                <renderterm>term</renderterm>
                                <xref target="clause1" original-id="_"/>
                             </concept>
                             <fmt-concept>
                                <semx element="concept" source="_">
                                   <em>term</em>
                                   <semx element="xref" source="_">
                                      (
                                      <span class="citesec">
                                         <span class="fmt-element-name">Clause</span>
                                         <semx element="autonum" source="clause1">1</semx>
                                      </span>
                                      )
                                   </semx>
                                </semx>
                             </fmt-concept>
                          </li>
                       </ul>
                    </p>
                 </term>
              </terms>
           </sections>
        </iso-standard>
    OUTPUT
    output = <<~OUTPUT
        #{HTML_HDR}
            <div id="clause1">
              <h1>1  Clause 1</h1>
            </div>
            <div id="A">
              <h1>2</h1>
              <p class="TermNum" id="B">2.1</p>
              <p class="Terms" style="text-align:left;">
                <b>B</b>
              </p>
              <p>
              <div class="ul_wrap">
                <ul>
                  <li><i>term</i>
            (<a href="#clause1"><span class="citesec">Clause 1</span></a>)
          </li>
                  <li>
            term
            (<a href="#clause1"><span class="citesec">Clause 1</span></a>)
          </li>
                  <li><i>term</i>
            (<a href="#clause1"><span class="citesec">Clause 1</span></a>)
          </li>
                  <li>
            term
          </li>
                  <li>
            term
          </li>
                  <li>
            term
          </li>
                  <li><a href="#clause1"><i>term</i></a> (<a href="#clause1"><span class="citesec">Clause 1</span></a>)</li>
                  <li><a href="#clause1"><i>term</i></a> (<span class="citesec">Clause 1</span>)</li>
                  <li><i>term</i> (<a href="#clause1"><span class="citesec">Clause 1</span></a>)</li>
                  <li><i>term</i> (<span class="citesec">Clause 1</span>)</li>
                </ul>
                </div>
              </p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)))).to be_equivalent_to Xml::C14n.format(output)
  end
end
