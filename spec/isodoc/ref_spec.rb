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
                  <abbreviation>ISO</abbreviation>
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
            <bibitem id="ISBN" type="ISBN">
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
            <bibitem id="ISSN" type="ISSN">
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
                  <abbreviation>ISO</abbreviation>
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
                .</formattedref>
              <docidentifier type="metanorma">[Citn]</docidentifier>
              <docidentifier type="IETF">RFC 20</docidentifier>
            </bibitem>
          </references>
        </bibliography>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <language current="true">en</language>
        </bibdata>
        <preface>
          <foreword displayorder="1">
            <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
              <eref bibitemid="ISO712">ISO 712</eref>
              <eref bibitemid="ISBN">[1]</eref>
              <eref bibitemid="ISSN">[2]</eref>
              <eref bibitemid="ISO16634">ISO 16634:--</eref>
              <eref bibitemid="ref1">ICC 167</eref>
              <eref bibitemid="ref10">[10]</eref>
              <eref bibitemid="ref12">Citn</eref>
            </p>
          </foreword>
        </preface>
        <bibliography>
          <references id="_normative_references" normative="true" obligation="informative" displayorder="2">
            <title depth="1">1<tab/>Normative References</title>
            <p>The following documents are referred to in the text in such a way that
                       some or all of their content constitutes requirements of this document.
                       For dated references, only the edition cited applies. For undated
                       references, the latest edition of the referenced document (including any
                       amendments) applies.
                     </p>
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
              <title format="text/plain" language="x">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal
                         feeding stuffs
                       </title>
              <title format="text/plain" language="en">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
              <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
              <date type="published">
                <on>--</on>
              </date>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <abbreviation>ISO</abbreviation>
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

                <em>Determination of the protein content in cereal and cereal products
                           for food and animal feeding stuffs according to the Dumas combustion
                           method</em> (see

                <link target="http://www.icc.or.at"/>
                )</formattedref>
              <docidentifier type="ICC">ICC 167</docidentifier>
            </bibitem>
            <note>
              <name>NOTE</name>
              <p>This is an annotation of ISO 20483:2013-2014</p>
            </note>
          </references>
          <references id="_bibliography" normative="false" obligation="informative" displayorder="3">
            <title depth="1">Bibliography</title>
            <bibitem id="ISBN" type="ISBN">
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
            <bibitem id="ISSN" type="ISSN">
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
              <name>NOTE</name>
              <p>This is an annotation of document ISSN.</p>
            </note>
            <note>
              <name>NOTE</name>
              <p>This is another annotation of document ISSN.</p>
            </note>
            <bibitem id="ISO3696" type="standard">
              <title format="text/plain">Water for analytical laboratory use</title>
              <docidentifier type='metanorma-ordinal'>[1]</docidentifier>
              <docidentifier type="ISO">ISO 3696</docidentifier>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
            </bibitem>
            <bibitem id="ref10">
              <formattedref format="application/x-isodoc+xml">
                <smallcap>Standard No I.C.C 167</smallcap> .

                <em>Determination of the protein content in cereal and cereal products
                           for food and animal feeding stuffs according to the Dumas combustion
                           method</em> (see

                <link target="http://www.icc.or.at"/>
                )</formattedref>
              <docidentifier type="metanorma">[10]</docidentifier>
            </bibitem>
            <bibitem id="ref11">
              <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
              <docidentifier type='metanorma-ordinal'>[2]</docidentifier>
              <docidentifier type="IETF">IETF RFC 10</docidentifier>
            </bibitem>
            <bibitem id="ref12">
              <formattedref format="application/x-isodoc+xml">CitationWorks. 2019.

                <em>How to cite a reference</em>
                .</formattedref>
              <docidentifier type="metanorma">[Citn]</docidentifier>
              <docidentifier type="IETF">IETF RFC 20</docidentifier>
            </bibitem>
          </references>
        </bibliography>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
                <a href="#ISO712">ISO 712</a>
                <a href="#ISBN">[1]</a>
                <a href="#ISSN">[2]</a>
                <a href="#ISO16634">ISO 16634:--</a>
                <a href="#ref1">ICC 167</a>
                <a href="#ref10">[10]</a>
                <a href="#ref12">Citn</a>
              </p>
            </div>
            <p class="zzSTDTitle1"/>
            <div>
              <h1>1&#160; Normative References</h1>
              <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
              <p class="NormRef" id="ISO712">ISO 712,
                <i>Cereals and cereal products</i></p>
              <p class="NormRef" id="ISO16634">ISO 16634:-- (all parts)
                <a class="FootnoteRef" href="#fn:1">
                  <sup>1</sup></a>,
                <i>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</i></p>
              <p class="NormRef" id="ISO20483">ISO 20483:2013-2014,
                <i>Cereals and pulses</i></p>
              <p class="NormRef" id="ref1">ICC 167,
                <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                 .
                <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i>
                (see
                <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                )</p>
              <div class="Note">
                <p>
                  <span class="note_label">NOTE</span>&#160; This is an annotation of ISO 20483:2013-2014</p>
              </div>
            </div>
            <br/>
            <div>
              <h1 class="Section3">Bibliography</h1>
              <p class="Biblio" id="ISBN">[1]&#160; <i>Chemicals for analytical laboratory use</i></p>
              <p class="Biblio" id="ISSN">[2]&#160; <i>Instruments for analytical laboratory use</i></p>
              <div class="Note">
                <p>
                  <span class="note_label">NOTE</span>&#160; This is an annotation of document ISSN.</p>
              </div>
              <div class="Note">
                <p>
                  <span class="note_label">NOTE</span>&#160; This is another annotation of document ISSN.</p>
              </div>
              <p class="Biblio" id="ISO3696">[1]&#160; ISO 3696,
                <i>Water for analytical laboratory use</i></p>
              <p class="Biblio" id="ref10">[10]&#160; <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                 .
                <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i>
                (see
                <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                )</p>
              <p class="Biblio" id="ref11">[2]&#160; IETF RFC 10,
                <i>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</i></p>
              <p class="Biblio" id="ref12">Citn&#160; IETF RFC 20, CitationWorks. 2019.
                <i>How to cite a reference</i>
                .</p>
            </div>
            <aside class="footnote" id="fn:1">
              <p>Under preparation. (Stage at the time of publication ISO/DIS 16634)</p>
            </aside>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({}).convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
  end
end
