require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML tables" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <table alt="tool tip" id="tableD-1" summary="long desc">
              <name>Repeatability and reproducibility of
                <em>husked</em>
                rice yield</name>
              <thead>
                <tr>
                  <td align="left" rowspan="2">Description</td>
                  <td align="center" colspan="4">Rice sample</td>
                </tr>
                <tr>
                  <td align="left">Arborio</td>
                  <td align="center">Drago
                    <fn reference="a">
                      <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p></fn>
                  </td>
                  <td align="center">Balilla
                    <fn reference="a">
                      <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p></fn>
                  </td>
                  <td align="center">Thaibonnet</td>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <th align="left">Number of laboratories retained after eliminating outliers</th>
                  <td align="center">13</td>
                  <td align="center">11</td>
                  <td align="center">13</td>
                  <td align="center">13</td>
                </tr>
                <tr>
                  <td align="left">Mean value, g/100 g</td>
                  <td align="center">81,2</td>
                  <td align="center">82,0</td>
                  <td align="center">81,8</td>
                  <td align="center">77,7</td>
                </tr>
              </tbody>
              <tfoot>
                <tr>
                  <td align="left">Reproducibility limit,
                    <stem type="AsciiMath">R</stem>
                    (= 2,83
                    <stem type="AsciiMath">s_R</stem>
                    )</td>
                  <td align="center">2,89</td>
                  <td align="center">0,57</td>
                  <td align="center">2,26</td>
                  <td align="center">6,06</td>
                </tr>
              </tfoot>
              <dl key="true">
                <dt>Drago</dt>
                <dd>A type of rice</dd>
              </dl>
                          <source status="generalisation">
        <origin bibitemid="ISO712" type="inline" citeas="">
          <localityStack>
            <locality type="section">
              <referenceFrom>1</referenceFrom>
            </locality>
          </localityStack>
        </origin>
        <modification>
          <p id="_">with adjustments</p>
        </modification>
      </source>
              <note>
                <p>This is a table about rice</p>
              </note>
            </table>
          </foreword>
        </preface>
        <annex id="Annex"><title>Annex</title>
        <table id="AnnexTable">
        <name>Another table</name>
        <tbody><td>?</td></tbody>
        </table>
        </annex>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <table alt="tool tip" id="tableD-1" summary="long desc" autonum="1">
                   <name id="_">
                      Repeatability and reproducibility of
                      <em>husked</em>
                      rice yield
                   </name>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Table</span>
                         <semx element="autonum" source="tableD-1">1</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">
                         Repeatability and reproducibility of
                         <em>husked</em>
                         rice yield
                      </semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="tableD-1">1</semx>
                   </fmt-xref-label>
                   <thead>
                      <tr>
                         <td align="left" rowspan="2">Description</td>
                         <td align="center" colspan="4">Rice sample</td>
                      </tr>
                      <tr>
                         <td align="left">Arborio</td>
                         <td align="center">
                            Drago
                            <fn reference="a" id="_" target="_">
                               <p original-id="_">Parboiled rice.</p>
                               <fmt-fn-label>
                                  <sup>
                                     <semx element="autonum" source="_">a</semx>
                                  </sup>
                               </fmt-fn-label>
                            </fn>
                         </td>
                         <td align="center">
                            Balilla
                            <fn reference="a" id="_" target="_">
                               <p id="_">Parboiled rice.</p>
                               <fmt-fn-label>
                                  <sup>
                                     <semx element="autonum" source="_">a</semx>
                                  </sup>
                               </fmt-fn-label>
                            </fn>
                         </td>
                         <td align="center">Thaibonnet</td>
                      </tr>
                   </thead>
                   <tbody>
                      <tr>
                         <th align="left">Number of laboratories retained after eliminating outliers</th>
                         <td align="center">13</td>
                         <td align="center">11</td>
                         <td align="center">13</td>
                         <td align="center">13</td>
                      </tr>
                      <tr>
                         <td align="left">Mean value, g/100 g</td>
                         <td align="center">81,2</td>
                         <td align="center">82,0</td>
                         <td align="center">81,8</td>
                         <td align="center">77,7</td>
                      </tr>
                   </tbody>
                   <tfoot>
                      <tr>
                         <td align="left">
                            Reproducibility limit,
                            <stem type="AsciiMath" id="_">R</stem>
                            <fmt-stem type="AsciiMath">
                               <semx element="stem" source="_">R</semx>
                            </fmt-stem>
                            (= 2,83
                            <stem type="AsciiMath" id="_">s_R</stem>
                            <fmt-stem type="AsciiMath">
                               <semx element="stem" source="_">s_R</semx>
                            </fmt-stem>
                            )
                         </td>
                         <td align="center">2,89</td>
                         <td align="center">0,57</td>
                         <td align="center">2,26</td>
                         <td align="center">6,06</td>
                      </tr>
                   </tfoot>
                   <dl key="true">
                      <name id="_">Key</name>
                      <fmt-name>
                         <semx element="name" source="_">Key</semx>
                      </fmt-name>
                      <dt>Drago</dt>
                      <dd>A type of rice</dd>
                   </dl>
                   <source status="generalisation">
                      [SOURCE:
                      <origin bibitemid="ISO712" type="inline" citeas="" id="_">
                         <localityStack>
                            <locality type="section">
                               <referenceFrom>1</referenceFrom>
                            </locality>
                         </localityStack>
                      </origin>
                      <semx element="origin" source="_">
                         <fmt-origin bibitemid="ISO712" type="inline" citeas="">
                            <localityStack>
                               <locality type="section">
                                  <referenceFrom>1</referenceFrom>
                               </locality>
                            </localityStack>
                            , Section 1
                         </fmt-origin>
                      </semx>
                      —
                      <semx element="modification" source="_">with adjustments</semx>
                      ]
                   </source>
                   <note>
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">NOTE</span>
                         </span>
                         <span class="fmt-label-delim">
                            <tab/>
                         </span>
                      </fmt-name>
                      <p>This is a table about rice</p>
                   </note>
                   <fmt-footnote-container>
                      <fmt-fn-body id="_" target="_" reference="a">
                         <semx element="fn" source="_">
                            <p id="_">
                               <fmt-fn-label>
                                  <sup>
                                     <semx element="autonum" source="_">a</semx>
                                  </sup>
                                  <span class="fmt-caption-delim">
                                     <tab/>
                                  </span>
                               </fmt-fn-label>
                               Parboiled rice.
                            </p>
                         </semx>
                      </fmt-fn-body>
                   </fmt-footnote-container>
                </table>
             </foreword>
          </preface>
          <annex id="Annex" autonum="A" displayorder="3">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title>
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="Annex">A</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">(informative)</span>
                <span class="fmt-caption-delim">
                   <br/>
                   <br/>
                </span>
                <semx element="title" source="_">
                   <strong>Annex</strong>
                </semx>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="Annex">A</semx>
             </fmt-xref-label>
             <table id="AnnexTable" autonum="A.1">
                <name id="_">Another table</name>
                <fmt-name>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="Annex">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="AnnexTable">1</semx>
                   </span>
                   <span class="fmt-caption-delim"> — </span>
                   <semx element="name" source="_">Another table</semx>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="Annex">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AnnexTable">1</semx>
                </fmt-xref-label>
                <tbody>
                   <td>?</td>
                </tbody>
             </table>
          </annex>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
       <main class="main-section">
          <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
          <br/>
          <br/>
          <div id="_">
             <h1 class="ForewordTitle" id="_">
                <a class="anchor" href="#_"/>
                <a class="header" href="#_">Foreword</a>
             </h1>
             <p class="TableTitle" style="text-align:center;">
                Table 1 — Repeatability and reproducibility of
                <i>husked</i>
                rice yield
             </p>
             <table id="tableD-1" class="MsoISOTable" style="border-width:1px;border-spacing:0;" title="tool tip">
                <caption>
                   <span style="display:none">long desc</span>
                </caption>
                <thead>
                   <tr>
                      <td rowspan="2" style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;;text-align:center;vertical-align:middle;" scope="col">Description</td>
                      <td colspan="4" style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;;text-align:center;vertical-align:middle;" scope="colgroup">Rice sample</td>
                   </tr>
                   <tr>
                      <td style="text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;;text-align:center;vertical-align:middle;" scope="col">Arborio</td>
                      <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;;text-align:center;vertical-align:middle;" scope="col">
                         Drago
                         <a href="#tableD-1a" class="TableFootnoteRef">a</a>
                      </td>
                      <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;;text-align:center;vertical-align:middle;" scope="col">
                         Balilla
                         <a href="#tableD-1a" class="TableFootnoteRef">a</a>
                      </td>
                      <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;;text-align:center;vertical-align:middle;" scope="col">Thaibonnet</td>
                   </tr>
                </thead>
                <tbody>
                   <tr>
                      <th style="font-weight:bold;text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="row">Number of laboratories retained after eliminating outliers</th>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">11</td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                   </tr>
                   <tr>
                      <td style="text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;">Mean value, g/100 g</td>
                      <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">81,2</td>
                      <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">82,0</td>
                      <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">81,8</td>
                      <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">77,7</td>
                   </tr>
                </tbody>
                <tfoot>
                   <tr>
                      <td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:0pt;">
                         Reproducibility limit,
                         <span class="stem">(#(R)#)</span>
                         (= 2,83
                         <span class="stem">(#(s_R)#)</span>
                         )
                      </td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:0pt;">2,89</td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:0pt;">0,57</td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:0pt;">2,26</td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:0pt;">6,06</td>
                   </tr>
                   <tr>
                      <td colspan="5" style="border-top:0pt;border-bottom:solid windowtext 1.5pt;">
                         <div class="figdl">
                            <p class="ListTitle">Key</p>
                            <dl>
                               <dt>
                                  <p>Drago</p>
                               </dt>
                               <dd>A type of rice</dd>
                            </dl>
                         </div>
                         <div class="BlockSource">
                            <p>[SOURCE: , Section 1 — with adjustments]</p>
                         </div>
                         <div class="Note">
                            <p>
                               <span class="note_label">NOTE  </span>
                               This is a table about rice
                            </p>
                         </div>
                         <div id="fn:tableD-1a" class="TableFootnote">
                            <p id="_" class="TableFootnote">
                               <span class="TableFootnoteRef">a</span>
                                 Parboiled rice.
                            </p>
                         </div>
                      </td>
                   </tr>
                </tfoot>
             </table>
          </div>
          <br/>
          <div id="Annex" class="Section3">
             <h1 class="Annex" id="_">
                <a class="anchor" href="#Annex"/>
                <a class="header" href="#Annex">
                   <b>Annex A</b>
                   <br/>
                   <span class="obligation">(informative)</span>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </a>
             </h1>
             <p class="TableTitle" style="text-align:center;">Table A.1 — Another table</p>
             <table id="AnnexTable" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                <tbody>
                   <tr/>
                </tbody>
             </table>
          </div>
       </main>
    OUTPUT

    doc = <<~OUTPUT
       <div>
          <table xmlns:m="m" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;" title="tool tip" summary="long desc">
             <a name="tableD-1" id="tableD-1"/>
             <thead>
                <tr>
                   <td rowspan="2" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;" valign="middle">Description</td>
                   <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;" valign="middle">Rice sample</td>
                </tr>
                <tr>
                   <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;" valign="middle">Arborio</td>
                   <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;" valign="middle">
                      Drago
                      <a href="#tableD-1a" class="TableFootnoteRef">a</a>
                   </td>
                   <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;" valign="middle">
                      Balilla
                      <a href="#tableD-1a" class="TableFootnoteRef">a</a>
                   </td>
                   <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;" valign="middle">Thaibonnet</td>
                </tr>
             </thead>
             <tbody>
                <tr>
                   <th align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">Number of laboratories retained after eliminating outliers</th>
                   <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
                   <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">11</td>
                   <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
                   <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
                </tr>
                <tr>
                   <td align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">Mean value, g/100 g</td>
                   <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">81,2</td>
                   <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">82,0</td>
                   <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">81,8</td>
                   <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">77,7</td>
                </tr>
             </tbody>
             <tfoot>
                <tr>
                   <td align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;page-break-after:auto;">
                      Reproducibility limit,
                      <span class="stem">(#(R)#)</span>
                      (= 2,83
                      <span class="stem">(#(s_R)#)</span>
                      )
                   </td>
                   <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;page-break-after:auto;">2,89</td>
                   <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;page-break-after:auto;">0,57</td>
                   <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;page-break-after:auto;">2,26</td>
                   <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;page-break-after:auto;">6,06</td>
                </tr>
                <tr>
                   <td colspan="5" style="border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">
                      <div class="figdl">
                         <p class="ListTitle">Key</p>
                         <p style="text-indent: -2.0cm; margin-left: 2.0cm; tab-stops: 2.0cm;" class="MsoNormal">
                            Drago
                            <span style="mso-tab-count:1">  </span>
                            A type of rice
                         </p>
                      </div>
                      <div class="BlockSource">
                         <p class="MsoNormal">[SOURCE: , Section 1 — with adjustments]</p>
                      </div>
                      <div class="Note">
                         <p class="Note">
                            <span class="note_label">
                               NOTE
                               <span style="mso-tab-count:1">  </span>
                            </span>
                            This is a table about rice
                         </p>
                      </div>
                      <div class="TableFootnote">
                         <a name="ftntableD-1a" id="ftntableD-1a"/>
                         <p class="ForewordText">
                            <a name="_" id="_"/>
                            <span class="TableFootnoteRef">a</span>
                            <span style="mso-tab-count:1">  </span>
                            Parboiled rice.
                         </p>
                      </div>
                   </td>
                </tr>
             </tfoot>
          </table>
       </div>
    OUTPUT
    doc2 = <<~OUTPUT
      <div class='Section3'>
        <a name='Annex' id='Annex'/>
        <p class='ANNEX'>
          <br/>
           <span style='font-weight:normal;'>(informative)</span>
          <br/>
          <br/>
          <b>Annex</b>
        </p>
        <p class='AnnexTableTitle' style='text-align:center;'>Table A.1&#xA0;&#x2014; Another table</p>
        <div align='center' class='table_container'>
          <table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
            <a name='AnnexTable' id='AnnexTable'/>
            <tbody>
              <tr/>
            </tbody>
          </table>
        </div>
      </div>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    IsoDoc::Iso::HtmlConvert.new({}).convert("test", pres_output, false)
    expect(File.exist?("test.html")).to be true
    out = File.read("test.html")
      .sub(/^.*<main /m, "<main ")
      .sub(%r{</main>.*$}m, "</main>")
    expect(Xml::C14n.format(strip_guid(out)))
      .to be_equivalent_to Xml::C14n.format(html)
    IsoDoc::Iso::WordConvert.new({}).convert("test", pres_output, false)
    expect(File.exist?("test.doc")).to be true
    out = File.read("test.doc")
      .sub(/^.+?<table /m, '<table xmlns:m="m" ')
      .sub(%r{</div>\s*<p class="MsoNormal">.*$}m, "")
    expect(Xml::C14n.format("<div>#{strip_guid(out)}"))
      .to be_equivalent_to Xml::C14n.format(doc)
    out = File.read("test.doc")
      .sub(/^.+?<div class="Section3"/m, '<div class="Section3"')
      .sub(%r{</div>\s*<br[^>]+>\s*<div class="colophon".*$}m, "")
    expect(Xml::C14n.format(strip_guid(out))).to be_equivalent_to Xml::C14n.format(doc2)
  end

  it "processes units statements in tables" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <table id="tableD-1">
              <name>Repeatability and reproducibility of
                <em>husked</em>
                rice yield</name>
              <thead>
                <tr>
                  <td>Description</td>
                  <td>Rice sample</td>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <th align="left">Number of laboratories retained after eliminating outliers</th>
                  <td align="center">13</td>
                </tr>
                <tr>
                  <td align="left">Mean value, g/100 g</td>
                  <td align="center">81,2</td>
                </tr>
              </tbody>
              <dl>
                <dt>Drago</dt>
                <dd>A type of rice</dd>
              </dl>
              <note id="A">Note 1</note>
              <note id="B" type="units">Units in mm</note>
              <note id="C">Note 2</note>
              <note id="D" type="units">Other units in sec</note>
            </table>
          </foreword>
        </preface>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Contents</fmt-title>
              </clause>
              <foreword id="_" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <table id="tableD-1" autonum="1">
                    <name id="_">
                       Repeatability and reproducibility of
                       <em>husked</em>
                       rice yield
                    </name>
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <span class="fmt-element-name">Table</span>
                          <semx element="autonum" source="tableD-1">1</semx>
                       </span>
                       <span class="fmt-caption-delim"> — </span>
                       <semx element="name" source="_">
                          Repeatability and reproducibility of
                          <em>husked</em>
                          rice yield
                       </semx>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Table</span>
                       <semx element="autonum" source="tableD-1">1</semx>
                    </fmt-xref-label>
                    <thead>
                       <tr>
                          <td>Description</td>
                          <td>Rice sample</td>
                       </tr>
                    </thead>
                    <tbody>
                       <tr>
                          <th align="left">Number of laboratories retained after eliminating outliers</th>
                          <td align="center">13</td>
                       </tr>
                       <tr>
                          <td align="left">Mean value, g/100 g</td>
                          <td align="center">81,2</td>
                       </tr>
                    </tbody>
                    <dl>
                       <dt>Drago</dt>
                       <dd>A type of rice</dd>
                    </dl>
                    <note id="A" autonum="1">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">NOTE</span>
                             <semx element="autonum" source="A">1</semx>
                          </span>
                          <span class="fmt-label-delim">
                             <tab/>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="A">1</semx>
                       </fmt-xref-label>
                       <fmt-xref-label container="_">
                          <span class="fmt-xref-container">
                             <semx element="foreword" source="_">Foreword</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="A">1</semx>
                       </fmt-xref-label>
                       Note 1
                    </note>
                    <note id="B" type="units">Units in mm</note>
                    <note id="C" autonum="2">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">NOTE</span>
                             <semx element="autonum" source="C">2</semx>
                          </span>
                          <span class="fmt-label-delim">
                             <tab/>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="C">2</semx>
                       </fmt-xref-label>
                       <fmt-xref-label container="_">
                          <span class="fmt-xref-container">
                             <semx element="foreword" source="_">Foreword</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="C">2</semx>
                       </fmt-xref-label>
                       Note 2
                    </note>
                    <note id="D" type="units">Other units in sec</note>
                 </table>
              </foreword>
           </preface>
        </iso-standard>
    OUTPUT
    html = <<~OUTPUT
          #{HTML_HDR}
            <br/>
            <div id="_">
              <h1 class="ForewordTitle">Foreword</h1>
              <p class="TableTitle" style="text-align:center;">Table 1 — Repeatability and reproducibility of
                 <i>husked</i>
                 rice yield</p>
              <div align="right">
                <b>Units in mm</b>
              </div>
              <div align="right">
                <b>Other units in sec</b>
              </div>
              <table id="tableD-1" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                <thead>
                  <tr>
                    <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;" scope="col">Description</td>
                    <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;" scope="col">Rice sample</td>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <th style="font-weight:bold;text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="row">Number of laboratories retained after eliminating outliers</th>
                    <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                  </tr>
                  <tr>
                    <td style="text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;">Mean value, g/100 g</td>
                    <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">81,2</td>
                  </tr>
                </tbody>
                <div class="figdl">
                <dl>
                  <dt>
                    <p>Drago</p>
                  </dt>
                  <dd>A type of rice</dd>
                </dl>
                </div>
                <div id="A" class="Note"><p><span class="note_label">NOTE  1  </span></p>Note 1</div>
                <div id="C" class="Note"><p><span class="note_label">NOTE  2  </span></p>Note 2</div>
              </table>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    doc = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72">
        <div class="WordSection1">
          <p> </p>
        </div>
        <p class="section-break">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection2">
          <p class="page-break">
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
              <div class="TOC" id="_">
          <p class="zzContents">Contents</p>
        </div>
        <p class="page-break">
          <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
        </p>
          <div id="_">
            <h1 class="ForewordTitle">Foreword</h1>
            <p class="Tabletitle" style="text-align:center;">Table 1 — Repeatability and reproducibility of
               <i>husked</i>
               rice yield</p>
            <div align="right">
              <b>Units in mm</b>
            </div>
            <div align="right">
              <b>Other units in sec</b>
            </div>
            <div align="center" class="table_container">
              <table id="tableD-1" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                <thead>
                  <tr>
                    <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Description</td>
                    <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Rice sample</td>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <th align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">Number of laboratories retained after eliminating outliers</th>
                    <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
                  </tr>
                  <tr>
                    <td align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">Mean value, g/100 g</td>
                    <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">81,2</td>
                  </tr>
                </tbody>
                <div class="figdl">
                <p style="text-indent: -2.0cm; margin-left: 2.0cm; tab-stops: 2.0cm;">Drago<span style="mso-tab-count:1">  </span>A type of rice</p>
                </div>
                <div id="A" class="Note"><p class="Note"><span class="note_label">NOTE  1<span style="mso-tab-count:1">  </span></span></p>Note 1</div>
                <div id="C" class="Note"><p class="Note"><span class="note_label">NOTE  2<span style="mso-tab-count:1">  </span></span></p>Note 2</div>
              </table>
            </div>
          </div>
          <p> </p>
        </div>
        <p class="section-break">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
        </div>
        <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"/>
      </body>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
       .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)))).to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true))
      .at("//body").to_xml))).to be_equivalent_to Xml::C14n.format(doc)
  end
end
