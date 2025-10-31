require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML bibliographies" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <language>en</language>
        </bibdata>
        <preface>
          <foreword>
            <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
              <eref bibitemid="ISO712"/>
              <eref bibitemid="ISBN"/>
              <eref bibitemid="ISSN"/>
              <eref bibitemid="ISO16634"/>
              <eref bibitemid="ref1"/>
              <eref bibitemid="ref10"/>
              <eref bibitemid="ref12"/>
            </p>
          </foreword>
        </preface>
        <bibliography>
          <references id="_normative_references" normative="true" obligation="informative">
            <title>Normative References</title>
            <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
            <bibitem id="ISO712" type="standard">
              <title format="text/plain">Cereals or cereal products</title>
              <title format="text/plain" type="main">Cereals and cereal products</title>
              <docidentifier type="ISO">ISO 712</docidentifier>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>International Organization for Standardization</name>
                </organization>
              </contributor>
            </bibitem>
            <bibitem id="ISO16634" type="standard">
              <title format="text/plain" language="x">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
              <title format="text/plain" language="en">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
              <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
              <date type="published">
                <on>--</on>
              </date>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>ISO</name>
                </organization>
              </contributor>
              <note format="text/plain" reference="1" type="Unpublished-Status">Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
              <extent type="part">
                <referenceFrom>all</referenceFrom>
              </extent>
            </bibitem>
            <bibitem id="ISO20483" type="standard">
              <title format="text/plain">Cereals and pulses</title>
              <docidentifier type="ISO">ISO 20483:2013-2014</docidentifier>
              <date type="published">
                <from>2013</from>
                <to>2014</to>
              </date>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>International Organization for Standardization</name>
                </organization>
              </contributor>
            </bibitem>
            <bibitem id="ref1">
              <formattedref format="application/x-isodoc+xml">
                <smallcap>Standard No I.C.C 167</smallcap> .

                <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em>
                (see

                <link target="http://www.icc.or.at"/>
                )</formattedref>
              <docidentifier type="ICC">167</docidentifier>
            </bibitem>
            <note>
              <p>This is an annotation of ISO 20483:2013-2014</p>
            </note>
          </references>
          <references id="_bibliography" normative="false" obligation="informative">
            <title>Bibliography</title>
            <bibitem id="ISBN" type="book">
              <title format="text/plain">Chemicals for analytical laboratory use</title>
              <docidentifier type="ISBN">ISBN</docidentifier>
              <docidentifier type="metanorma">[1]</docidentifier>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <abbreviation>ISBN</abbreviation>
                </organization>
              </contributor>
            </bibitem>
            <bibitem id="ISSN" type="journal">
              <title format="text/plain">Instruments for analytical laboratory use</title>
              <docidentifier type="ISSN">ISSN</docidentifier>
              <docidentifier type="metanorma">[2]</docidentifier>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <abbreviation>ISSN</abbreviation>
                </organization>
              </contributor>
            </bibitem>
            <note>
              <p>This is an annotation of document ISSN.</p>
            </note>
            <note>
              <p>This is another annotation of document ISSN.</p>
            </note>
            <bibitem id="ISO3696" type="standard">
              <title format="text/plain">Water for analytical laboratory use</title>
              <docidentifier type="ISO">ISO 3696</docidentifier>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>ISO</name>
                </organization>
              </contributor>
            </bibitem>
            <bibitem id="ref10">
              <formattedref format="application/x-isodoc+xml">
                <smallcap>Standard No I.C.C 167</smallcap> .

                <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em>
                (see

                <link target="http://www.icc.or.at"/>
                )</formattedref>
              <docidentifier type="metanorma">[10]</docidentifier>
            </bibitem>
            <bibitem id="ref11">
              <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
              <docidentifier type="IETF">RFC 10</docidentifier>
            </bibitem>
            <bibitem id="ref12">
              <formattedref format="application/x-isodoc+xml">CitationWorks. 2019.
                <em>How to cite a reference</em>
                </formattedref>
              <docidentifier type="metanorma">[Citn]</docidentifier>
              <docidentifier type="IETF">RFC 20</docidentifier>
            </bibitem>
          </references>
        </bibliography>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <language current="true">en</language>
         </bibdata>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Contents</fmt-title>
            </clause>
            <foreword id="_" displayorder="2">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <p id="_">
                  <eref bibitemid="ISO712" id="_"/>
                  <semx element="eref" source="_">
                     <fmt-xref target="ISO712">
                        <span class="stdpublisher">ISO </span>
                        <span class="stddocNumber">712</span>
                     </fmt-xref>
                  </semx>
                  <eref bibitemid="ISBN" id="_"/>
                  <semx element="eref" source="_">
                     <fmt-xref target="ISBN">[1]</fmt-xref>
                  </semx>
                  <eref bibitemid="ISSN" id="_"/>
                  <semx element="eref" source="_">
                     <fmt-xref target="ISSN">[2]</fmt-xref>
                  </semx>
                  <eref bibitemid="ISO16634" id="_"/>
                  <semx element="eref" source="_">
                     <fmt-xref target="ISO16634">
                        <span class="stdpublisher">ISO </span>
                        <span class="stddocNumber">16634</span>
                        :--
                     </fmt-xref>
                  </semx>
                  <eref bibitemid="ref1" id="_"/>
                  <semx element="eref" source="_">
                     <fmt-xref target="ref1">ICC 167</fmt-xref>
                  </semx>
                  <eref bibitemid="ref10" id="_"/>
                  <semx element="eref" source="_">
                     <fmt-xref target="ref10">[4]</fmt-xref>
                  </semx>
                  <eref bibitemid="ref12" id="_"/>
                  <semx element="eref" source="_">
                     <fmt-xref target="ref12">Citn</fmt-xref>
                  </semx>
               </p>
            </foreword>
         </preface>
         <sections>
            <references id="_" normative="true" obligation="informative" displayorder="3">
               <title id="_">Normative References</title>
               <fmt-title id="_" depth="1">
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
                  <title format="text/plain" type="main">Cereals and cereal products</title>
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
               <bibitem id="ISO16634" type="standard">
                  <formattedref>
                     <em>
                        <span class="stddocTitle">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</span>
                     </em>
                  </formattedref>
                  <title format="text/plain" language="x">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
                  <title format="text/plain" language="en">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
                  <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
                  <docidentifier scope="biblio-tag">ISO 16634:-- (all parts)</docidentifier>
                  <date type="published">
                     <on>--</on>
                  </date>
                  <contributor>
                     <role type="publisher"/>
                     <organization>
                        <name>ISO</name>
                     </organization>
                  </contributor>
                  <note format="text/plain" reference="1" type="Unpublished-Status">Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
                  <extent type="part">
                     <referenceFrom>all</referenceFrom>
                  </extent>
                  <biblio-tag>
                     <span class="stdpublisher">ISO </span>
                     <span class="stddocNumber">16634</span>
                     :-- (all parts)
                     <fn id="_" reference="1" original-reference="1" target="_">
                        <p>Under preparation. (Stage at the time of publication ISO/DIS 16634)</p>
                        <fmt-fn-label>
                           <span class="fmt-caption-label">
                              <sup>
                                 <semx element="autonum" source="_">1</semx>
                                 <span class="fmt-label-delim">)</span>
                              </sup>
                           </span>
                        </fmt-fn-label>
                     </fn>
                     ,
                  </biblio-tag>
               </bibitem>
               <bibitem id="ISO20483" type="standard">
                  <formattedref>
                     <em>
                        <span class="stddocTitle">Cereals and pulses</span>
                     </em>
                  </formattedref>
                  <title format="text/plain">Cereals and pulses</title>
                  <docidentifier type="ISO">ISO 20483:2013-2014</docidentifier>
                  <docidentifier scope="biblio-tag">ISO 20483:2013-2014</docidentifier>
                  <date type="published">
                     <from>2013</from>
                     <to>2014</to>
                  </date>
                  <contributor>
                     <role type="publisher"/>
                     <organization>
                        <name>International Organization for Standardization</name>
                     </organization>
                  </contributor>
                  <biblio-tag>
                     <span class="stdpublisher">ISO </span>
                     <span class="stddocNumber">20483</span>
                     :
                     <span class="stdyear">2013</span>
                     -
                     <span class="stddocPartNumber">2014</span>
                     ,
                  </biblio-tag>
               </bibitem>
               <bibitem id="ref1">
                  <formattedref format="application/x-isodoc+xml">
                     <smallcap>Standard No I.C.C 167</smallcap>
                     .
                     <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em>
                     (see
                     <link target="http://www.icc.or.at" id="_"/>
                     <semx element="link" source="_">
                        <fmt-link target="http://www.icc.or.at"/>
                     </semx>
                     )
                  </formattedref>
                  <docidentifier type="ICC">ICC 167</docidentifier>
                  <docidentifier scope="biblio-tag">ICC 167</docidentifier>
                  <biblio-tag>ICC 167, </biblio-tag>
               </bibitem>
               <note>
                  <fmt-name id="_">
                     <span class="fmt-caption-label">
                        <span class="fmt-element-name">NOTE</span>
                     </span>
                     <span class="fmt-label-delim">
                        <tab/>
                     </span>
                  </fmt-name>
                  <p>This is an annotation of ISO 20483:2013-2014</p>
               </note>
            </references>
         </sections>
         <bibliography>
            <references id="_" normative="false" obligation="informative" displayorder="4">
               <title id="_">Bibliography</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Bibliography</semx>
               </fmt-title>
               <bibitem id="ISBN" type="book">
                  <formattedref>
                     <em>Chemicals for analytical laboratory use</em>
                     . n.d.
                  </formattedref>
                  <title format="text/plain">Chemicals for analytical laboratory use</title>
                  <docidentifier type="metanorma-ordinal">[1]</docidentifier>
                  <docidentifier type="ISBN">ISBN</docidentifier>
                  <contributor>
                     <role type="publisher"/>
                     <organization>
                        <abbreviation>ISBN</abbreviation>
                     </organization>
                  </contributor>
                  <biblio-tag>
                     [1]
                     <tab/>
                  </biblio-tag>
               </bibitem>
               <bibitem id="ISSN" type="journal">
                  <formattedref>
                     <em>Instruments for analytical laboratory use</em>
                     . n.d.
                  </formattedref>
                  <title format="text/plain">Instruments for analytical laboratory use</title>
                  <docidentifier type="metanorma-ordinal">[2]</docidentifier>
                  <docidentifier type="ISSN">ISSN</docidentifier>
                  <contributor>
                     <role type="publisher"/>
                     <organization>
                        <abbreviation>ISSN</abbreviation>
                     </organization>
                  </contributor>
                  <biblio-tag>
                     [2]
                     <tab/>
                  </biblio-tag>
               </bibitem>
               <note>
                  <fmt-name id="_">
                     <span class="fmt-caption-label">
                        <span class="fmt-element-name">NOTE</span>
                     </span>
                     <span class="fmt-label-delim">
                        <tab/>
                     </span>
                  </fmt-name>
                  <p>This is an annotation of document ISSN.</p>
               </note>
               <note>
                  <fmt-name id="_">
                     <span class="fmt-caption-label">
                        <span class="fmt-element-name">NOTE</span>
                     </span>
                     <span class="fmt-label-delim">
                        <tab/>
                     </span>
                  </fmt-name>
                  <p>This is another annotation of document ISSN.</p>
               </note>
               <bibitem id="ISO3696" type="standard">
                  <formattedref>
                     <em>
                        <span class="stddocTitle">Water for analytical laboratory use</span>
                     </em>
                  </formattedref>
                  <title format="text/plain">Water for analytical laboratory use</title>
                  <docidentifier type="metanorma-ordinal">[3]</docidentifier>
                  <docidentifier type="ISO">ISO 3696</docidentifier>
                  <docidentifier scope="biblio-tag">ISO 3696</docidentifier>
                  <contributor>
                     <role type="publisher"/>
                     <organization>
                        <name>ISO</name>
                     </organization>
                  </contributor>
                  <biblio-tag>
                     [3]
                     <tab/>
                     <span class="stdpublisher">ISO </span>
                     <span class="stddocNumber">3696</span>
                     ,
                  </biblio-tag>
               </bibitem>
               <bibitem id="ref10">
                  <formattedref format="application/x-isodoc+xml">
                     <smallcap>Standard No I.C.C 167</smallcap>
                     .
                     <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em>
                     (see
                     <link target="http://www.icc.or.at" id="_"/>
                     <semx element="link" source="_">
                        <fmt-link target="http://www.icc.or.at"/>
                     </semx>
                     )
                  </formattedref>
                  <docidentifier type="metanorma-ordinal">[4]</docidentifier>
                  <biblio-tag>
                     [4]
                     <tab/>
                  </biblio-tag>
               </bibitem>
               <bibitem id="ref11">
                  <formattedref>
                     <em>
                        <span class="stddocTitle">Internet Calendaring and Scheduling Core Object Specification (iCalendar)</span>
                     </em>
                  </formattedref>
                  <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
                  <docidentifier type="metanorma-ordinal">[5]</docidentifier>
                  <docidentifier type="IETF">IETF RFC 10</docidentifier>
                  <docidentifier scope="biblio-tag">IETF RFC 10</docidentifier>
                  <biblio-tag>
                     [5]
                     <tab/>
                     <span class="stdpublisher">IETF </span>
                     <span class="stdpublisher">RFC </span>
                     <span class="stddocNumber">10</span>
                     ,
                  </biblio-tag>
               </bibitem>
               <bibitem id="ref12">
                  <formattedref format="application/x-isodoc+xml">
                     CitationWorks. 2019.
                     <em>How to cite a reference</em>
                  </formattedref>
                  <docidentifier type="metanorma">[Citn]</docidentifier>
                  <docidentifier type="IETF">IETF RFC 20</docidentifier>
                  <docidentifier scope="biblio-tag">IETF RFC 20</docidentifier>
                  <biblio-tag>
                     Citn
                     <tab/>
                     <span class="stdpublisher">IETF </span>
                     <span class="stdpublisher">RFC </span>
                     <span class="stddocNumber">20</span>
                     ,
                  </biblio-tag>
               </bibitem>
            </references>
         </bibliography>
         <fmt-footnote-container>
            <fmt-fn-body id="_" target="_" reference="1">
               <semx element="fn" source="_">
                  <p>
                     <fmt-fn-label>
                        <span class="fmt-caption-label">
                           <sup>
                              <semx element="autonum" source="_">1</semx>
                           </sup>
                        </span>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                     </fmt-fn-label>
                     Under preparation. (Stage at the time of publication ISO/DIS 16634)
                  </p>
               </semx>
            </fmt-fn-body>
         </fmt-footnote-container>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                      <br/>
                <div id="_">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p id="_">
                      <a href="#ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                      </a>
                      <a href="#ISBN">[1]</a>
                      <a href="#ISSN">[2]</a>
                      <a href="#ISO16634">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">16634</span>
                         :--
                      </a>
                      <a href="#ref1">ICC 167</a>
                      <a href="#ref10">[4]</a>
                      <a href="#ref12">Citn</a>
                   </p>
                </div>
                <div>
                   <h1>1  Normative References</h1>
                   <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                   <p id="ISO712" class="NormRef">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      ,
                      <i>
                         <span class="stddocTitle">Cereals and cereal products</span>
                      </i>
                   </p>
                   <p id="ISO16634" class="NormRef">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">16634</span>
                      :-- (all parts)
                      <a class="FootnoteRef" href="#fn:1">
                         <sup>1</sup>
                      </a>
                      ,
                      <i>
                         <span class="stddocTitle">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</span>
                      </i>
                   </p>
                   <p id="ISO20483" class="NormRef">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">20483</span>
                      :
                      <span class="stdyear">2013</span>
                      -
                      <span class="stddocPartNumber">2014</span>
                      ,
                      <i>
                         <span class="stddocTitle">Cereals and pulses</span>
                      </i>
                   </p>
                   <p id="ref1" class="NormRef">
                      ICC 167,
                      <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                      .
                      <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i>
                      (see
                      <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                      )
                   </p>
                   <div class="Note">
                      <p>
                         <span class="note_label">NOTE  </span>
                         This is an annotation of ISO 20483:2013-2014
                      </p>
                   </div>
                </div>
                <br/>
                <div>
                   <h1 class="Section3">Bibliography</h1>
                   <p id="ISBN" class="Biblio">
                      [1]#{' '}
                      <i>Chemicals for analytical laboratory use</i>
                      . n.d.
                   </p>
                   <p id="ISSN" class="Biblio">
                      [2]#{' '}
                      <i>Instruments for analytical laboratory use</i>
                      . n.d.
                   </p>
                   <div class="Note">
                      <p>
                         <span class="note_label">NOTE  </span>
                         This is an annotation of document ISSN.
                      </p>
                   </div>
                   <div class="Note">
                      <p>
                         <span class="note_label">NOTE  </span>
                         This is another annotation of document ISSN.
                      </p>
                   </div>
                   <p id="ISO3696" class="Biblio">
                      [3]#{' '}
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">3696</span>
                      ,
                      <i>
                         <span class="stddocTitle">Water for analytical laboratory use</span>
                      </i>
                   </p>
                   <p id="ref10" class="Biblio">
                      [4]#{' '}
                      <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                      .
                      <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i>
                      (see
                      <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                      )
                   </p>
                   <p id="ref11" class="Biblio">
                      [5]#{' '}
                      <span class="stdpublisher">IETF </span>
                      <span class="stdpublisher">RFC </span>
                      <span class="stddocNumber">10</span>
                      ,
                      <i>
                         <span class="stddocTitle">Internet Calendaring and Scheduling Core Object Specification (iCalendar)</span>
                      </i>
                   </p>
                   <p id="ref12" class="Biblio">
                      Citn#{' '}
                      <span class="stdpublisher">IETF </span>
                      <span class="stdpublisher">RFC </span>
                      <span class="stddocNumber">20</span>
                      , CitationWorks. 2019.
                      <i>How to cite a reference</i>
                   </p>
                </div>
                <aside id="fn:1" class="footnote">
                   <p>Under preparation. (Stage at the time of publication ISO/DIS 16634)</p>
                </aside>
             </div>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(/reference="[^"]+"/, 'reference="1"'))))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(/fn:[^"]+"/, 'fn:1"')
      .gsub(/<sup>[^<]+</, "<sup>1<"))))
      .to be_equivalent_to Canon.format_xml(html)
  end

  it "processes websites" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
              <bibdata>
                <language>en</language>
              </bibdata>
              <bibliography>
              <references normative="false">
              <fmt-title id="_">Bibliography</fmt-title>
              <bibitem id="ignf" type="website">
        <fetched>2022-05-06</fetched>
        <title type="title-main" format="text/plain">IGNF. (IGN France) Registry</title>
        <title type="main" format="text/plain">IGNF. (IGN France) Registry</title>
        <uri>https://registre.ign.fr/</uri>
        <docidentifier type="metanorma">2</docidentifier>
      </bibitem>
      </references>
              </bibliography>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
         <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
            <bibdata>
              <language current='true'>en</language>
            </bibdata>
               <preface>
         <clause type="toc" id="_" displayorder="1">
            <fmt-title id="_" depth="1">Contents</fmt-title>
         </clause>
      </preface>
      <bibliography>
         <references normative="false" displayorder="2" id="_">
            <fmt-title id="_" depth="1">Bibliography</fmt-title>
              <bibitem id='ignf' type='website'>
                <formattedref>
                  <em>
                    <span class='stddocTitle'>IGNF. (IGN France) Registry</span>
                  </em>
                   [website]. Available from:
                  <span class='biburl'>
                   <link target="https://registre.ign.fr/" id="_">https://registre.ign.fr/</link>
                    <semx element="link" source="_">
                       <fmt-link target="https://registre.ign.fr/">https://registre.ign.fr/</fmt-link>
                    </semx>
                  </span>
                </formattedref>
               <fetched/>
               <title type="title-main" format="text/plain">IGNF. (IGN France) Registry</title>
               <title type="main" format="text/plain">IGNF. (IGN France) Registry</title>
                <uri>https://registre.ign.fr/</uri>
                <docidentifier type='metanorma-ordinal'>[1]</docidentifier>
                <biblio-tag>[1]<tab/></biblio-tag>
              </bibitem>
            </references>
            </bibliography>
          </iso-standard>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "renders bibliography [1] references" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>en</language>
      </bibdata>
      <sections><clause id="_7f1f55f3-9959-408e-ce64-ba25716cb080" inline-header="false" obligation="normative">
      <title id="_197c5920-4bbf-7c2e-7b8d-f4f455e85560">Clause</title>
      <p id="_64d21512-c8ec-11c8-cd59-67dc0b878dcd">Sentence <eref type="inline" bibitemid="internet_standards" citeas="[1]"/>.</p>

      <p id="_cad3c9fc-f546-d026-9efe-d850aa04137b">Sentence <eref type="inline" style="superscript" bibitemid="internet_standards" citeas="[1]"/>.</p>

      <p id="_8ec8708e-8bda-b2a0-5b50-2cb5ea28519a">Sentence <erefstack><eref connective="and" bibitemid="internet_standards" citeas="[1]" type="inline"/><eref connective="and" bibitemid="graphql" citeas="[2]" type="inline"/></erefstack>.</p>

      <p id="_8ec8708e-8bda-b2a0-5b50-2cb5ea28519b">Sentence <erefstack><eref connective="and" bibitemid="internet_standards" citeas="[1]" type="inline"/><eref connective="and" bibitemid="graphql" citeas="[2]" type="inline"/><eref connective="and" bibitemid="internet_standards" citeas="[1]" type="inline"/></erefstack>.</p>

      <p id="_77efedf3-56a3-f46e-3344-15dd295af592">Sentence <erefstack style="superscript"><eref connective="and" bibitemid="internet_standards" citeas="[1]" type="inline"/><eref connective="and" bibitemid="graphql" citeas="[2]" type="inline"/></erefstack>.</p>

      <p id="_77efedf3-56a3-f46e-3344-15dd295af593">Sentence <erefstack style="superscript"><eref connective="and" bibitemid="internet_standards" citeas="[1]" type="inline"/><eref connective="and" bibitemid="graphql" citeas="[2]" type="inline"/><eref connective="and" bibitemid="internet_standards" citeas="[1]" type="inline"/></erefstack>.</p>

      <p id="_15af3752-132c-5bf4-26b7-57522b8d5ce2">Sentence <eref type="inline" bibitemid="internet_standards" citeas="[1]"><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></eref>.</p>

      <p id="_2d1771b1-38ac-7901-3b21-0e99c715f8f0">Sentence <eref type="inline" style="superscript" bibitemid="internet_standards" citeas="[1]"><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></eref>.</p>
      </clause>

      <terms id="_e124b581-f1d9-34be-9312-5b68ae58bc8a" obligation="normative">
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


       <source status="identical" type="authoritative"><origin bibitemid="internet_standards" type="inline" citeas="[1]"><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></origin>
      </source></term>

      <term id="_2baf3b3d-7b0d-1d47-b78d-f0a037d0edf7" anchor="term-Term-2"><preferred><expression>
      <name>Term 2</name>
      </expression>
      </preferred>
      <definition id="_d0d28852-8399-7970-7330-4234dda15f4e"><verbal-definition id="_3e46d6f6-8d6f-ac46-c2b0-75a8936dec9b"><p id="_5cee8601-19f1-6e98-a5a7-2b12e954273a">Definition</p></verbal-definition></definition>

       <source status="identical" type="authoritative"><origin bibitemid="internet_standards" type="inline" citeas="[1]"><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></origin>
      </source><source status="identical" type="authoritative"><origin bibitemid="graphql" type="inline" citeas="[2]"><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></origin>
      </source></term>
      </terms>
      </sections>
      <bibliography><references id="_cd4f6c9c-b025-1fdf-4aa5-9ef14295f99f" normative="false" obligation="informative">
      <title id="_2b4ed339-a7ed-1bbb-9576-55fcbc1ace3a">Bibliography</title><bibitem anchor="internet_standards" id="_6ac01dcf-8be2-8d2b-cca7-47690ab0876d" type="webresource">
        <title>Internet Standards</title>
        <uri>https://www.rfc-editor.org/standards#IS</uri>
        <docidentifier type="metanorma">[1]</docidentifier>
        <date type="published">
        <on>July 2024</on>
      </date>
        <contributor>
        <role type="author"/>
        <organization>
          <name>Internet Engineering Task Force</name>
        </organization>
      </contributor>
      </bibitem><bibitem anchor="graphql" id="_a42afe30-3f9a-2719-5872-73f49c6329e1" type="standard">
        <title>The GraphQL Specification Project</title>
        <uri>https://spec.graphql.org</uri>
        <docidentifier type="metanorma">[2]</docidentifier>
        <date type="published">
        <on>October 2021</on>
      </date>
        <contributor>
        <role type="author"/>
        <organization>
          <name>Joint Development Foundation Projects, LLC</name>
        </organization>
      </contributor>
      </bibitem>
      </references></bibliography>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
       <sections>
          <clause id="_" inline-header="false" obligation="normative" displayorder="2">
             <title id="_">Clause</title>
             <fmt-title depth="1" id="_">
                <span class="fmt-caption-label">
                   <semx element="autonum" source="_">1</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Clause</semx>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Clause</span>
                <semx element="autonum" source="_">1</semx>
             </fmt-xref-label>
             <p id="_">
                Sentence
                <eref type="inline" bibitemid="internet_standards" citeas="[1]" id="_"/>
                <semx element="eref" source="_">
                   Reference
                   <fmt-xref type="inline" target="internet_standards">[1]</fmt-xref>
                </semx>
                .
             </p>
             <p id="_">
                Sentence
                <eref type="inline" style="superscript" bibitemid="internet_standards" citeas="[1]" id="_"/>
                <semx element="eref" source="_">
                   <sup>
                      <fmt-xref type="inline" style="superscript" target="internet_standards">[1]</fmt-xref>
                   </sup>
                </semx>
                .
             </p>
             <p id="_">
                Sentence
                <erefstack id="_">
                   <eref connective="and" bibitemid="internet_standards" citeas="[1]" type="inline" id="_"/>
                   <eref connective="and" bibitemid="graphql" citeas="[2]" type="inline" id="_"/>
                </erefstack>
                <semx element="erefstack" source="_">
                   References
                   <semx element="eref" source="_">
                      <fmt-xref connective="and" type="inline" target="internet_standards">[1]</fmt-xref>
                   </semx>
                   <span class="fmt-conn">and</span>
                   <semx element="eref" source="_">
                      <fmt-xref connective="and" type="inline" target="graphql">[2]</fmt-xref>
                   </semx>
                </semx>
                .
             </p>
             <p id="_">
                Sentence
                <erefstack id="_">
                   <eref connective="and" bibitemid="internet_standards" citeas="[1]" type="inline" id="_"/>
                   <eref connective="and" bibitemid="graphql" citeas="[2]" type="inline" id="_"/>
                   <eref connective="and" bibitemid="internet_standards" citeas="[1]" type="inline" id="_"/>
                </erefstack>
                <semx element="erefstack" source="_">
                   References
                   <semx element="eref" source="_">
                      <fmt-xref connective="and" type="inline" target="internet_standards">[1]</fmt-xref>
                   </semx>
                   <span class="fmt-enum-comma">,</span>
                   <semx element="eref" source="_">
                      <fmt-xref connective="and" type="inline" target="graphql">[2]</fmt-xref>
                   </semx>
                   <span class="fmt-conn">and</span>
                   <semx element="eref" source="_">
                      <fmt-xref connective="and" type="inline" target="internet_standards">[1]</fmt-xref>
                   </semx>
                </semx>
                .
             </p>
             <p id="_">
                Sentence
                <erefstack style="superscript" id="_">
                   <eref connective="and" bibitemid="internet_standards" citeas="[1]" type="inline" id="_"/>
                   <eref connective="and" bibitemid="graphql" citeas="[2]" type="inline" id="_"/>
                </erefstack>
                <semx element="erefstack" source="_">
                   <sup>
                      <semx element="eref" source="_">
                         <fmt-xref connective="and" type="inline" target="internet_standards">[1]</fmt-xref>
                      </semx>
                   </sup>
                   <sup>
                      <semx element="eref" source="_">
                         <fmt-xref connective="and" type="inline" target="graphql">[2]</fmt-xref>
                      </semx>
                   </sup>
                </semx>
                .
             </p>
             <p id="_">
                Sentence
                <erefstack style="superscript" id="_">
                   <eref connective="and" bibitemid="internet_standards" citeas="[1]" type="inline" id="_"/>
                   <eref connective="and" bibitemid="graphql" citeas="[2]" type="inline" id="_"/>
                   <eref connective="and" bibitemid="internet_standards" citeas="[1]" type="inline" id="_"/>
                </erefstack>
                <semx element="erefstack" source="_">
                   <sup>
                      <semx element="eref" source="_">
                         <fmt-xref connective="and" type="inline" target="internet_standards">[1]</fmt-xref>
                      </semx>
                   </sup>
                   <sup>
                      <semx element="eref" source="_">
                         <fmt-xref connective="and" type="inline" target="graphql">[2]</fmt-xref>
                      </semx>
                   </sup>
                   <sup>
                      <semx element="eref" source="_">
                         <fmt-xref connective="and" type="inline" target="internet_standards">[1]</fmt-xref>
                      </semx>
                   </sup>
                </semx>
                .
             </p>
             <p id="_">
                Sentence
                <eref type="inline" bibitemid="internet_standards" citeas="[1]" id="_">
                   <localityStack>
                      <locality type="clause">
                         <referenceFrom>3</referenceFrom>
                      </locality>
                   </localityStack>
                </eref>
                <semx element="eref" source="_">
                   Reference
                   <fmt-xref type="inline" target="internet_standards">
                      [1],
                      <span class="citesec">Clause 3</span>
                   </fmt-xref>
                </semx>
                .
             </p>
             <p id="_">
                Sentence
                <eref type="inline" style="superscript" bibitemid="internet_standards" citeas="[1]" id="_">
                   <localityStack>
                      <locality type="clause">
                         <referenceFrom>3</referenceFrom>
                      </locality>
                   </localityStack>
                </eref>
                <semx element="eref" source="_">
                   <sup>
                      <fmt-xref type="inline" style="superscript" target="internet_standards">
                         [1],
                         <span class="citesec">Clause 3</span>
                      </fmt-xref>
                   </sup>
                </semx>
                .
             </p>
          </clause>
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
                   <origin bibitemid="internet_standards" type="inline" citeas="[1]">
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
                      <origin bibitemid="internet_standards" type="inline" citeas="[1]" id="_">
                         <localityStack>
                            <locality type="clause">
                               <referenceFrom>3</referenceFrom>
                            </locality>
                         </localityStack>
                      </origin>
                      <semx element="origin" source="_">
                         Reference
                         <fmt-xref type="inline" target="internet_standards">
                            [1],
                            <span class="citesec">Clause 3</span>
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
                   <origin bibitemid="internet_standards" type="inline" citeas="[1]">
                      <localityStack>
                         <locality type="clause">
                            <referenceFrom>3</referenceFrom>
                         </locality>
                      </localityStack>
                   </origin>
                </source>
                <source status="identical" type="authoritative" id="_">
                   <origin bibitemid="graphql" type="inline" citeas="[2]">
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
                      <origin bibitemid="internet_standards" type="inline" citeas="[1]" id="_">
                         <localityStack>
                            <locality type="clause">
                               <referenceFrom>3</referenceFrom>
                            </locality>
                         </localityStack>
                      </origin>
                      <semx element="origin" source="_">
                         Reference
                         <fmt-xref type="inline" target="internet_standards">
                            [1],
                            <span class="citesec">Clause 3</span>
                         </fmt-xref>
                      </semx>
                   </semx>
                   ;
                   <semx element="source" source="_">
                      <origin bibitemid="graphql" type="inline" citeas="[2]" id="_">
                         <localityStack>
                            <locality type="clause">
                               <referenceFrom>3</referenceFrom>
                            </locality>
                         </localityStack>
                      </origin>
                      <semx element="origin" source="_">
                         Reference
                         <fmt-xref type="inline" target="graphql">
                            [2],
                            <span class="citesec">Clause 3</span>
                         </fmt-xref>
                      </semx>
                   </semx>
                   ]
                </fmt-termsource>
             </term>
          </terms>
       </sections>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
    xml = xml.at("//xmlns:sections")
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
