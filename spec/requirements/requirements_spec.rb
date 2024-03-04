require "spec_helper"

RSpec.describe Metanorma::Requirements::Iso::Modspec do
  it "treates Modspec requirements as tables for cross-referencing" do
    input = <<~INPUT
      <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <table id="A0"/>
          <permission model="ogc" id="A1">
          <title>First</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        </permission>
          <table id="A2"/>
        </foreword>
        <introduction id="B"><title>Introduction</title>
        <p><xref target="A0"/><xref target="A1"/><xref target="A2"/></p>
        </introduction>
        </preface>
        </ogc-standard>
    INPUT
    presxml = <<~OUTPUT
      <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
        <preface>
          <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
          <foreword id='A' displayorder='2'>
            <title>Preface</title>
            <table id='A0'>
              <name>Table 1</name>
            </table>
            <table id='A1' class='modspec' type='recommend'>
              <name>Table 2 — Permission 1: First</name>
              <tbody>
                <tr>
                  <th>Identifier</th>
                  <td>
                    <tt>/ogc/recommendation/wfs/2</tt>
                  </td>
                </tr>
              </tbody>
            </table>
            <table id='A2'>
              <name>Table 3</name>
            </table>
          </foreword>
          <introduction id='B' displayorder='3'>
            <title>Introduction</title>
            <p>
              <xref target='A0'>
                <span class='citetbl'>Table 1</span>
              </xref>
              <xref target='A1'>
                Table 2, Permission 1
              </xref>
              <xref target='A2'>
                <span class='citetbl'>Table 3</span>
              </xref>
            </p>
          </introduction>
        </preface>
      </ogc-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes permissions" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <permission model="ogc" id="A1">
          <title>First</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <inherit><eref type="inline" bibitemid="rfc2616" citeas="RFC 2616">RFC 2616 (HTTP/1.1)</eref></inherit>
        <subject>user</subject>
        <classification> <tag>control-class</tag> <value>Technical</value> </classification><classification> <tag>priority</tag> <value>P0</value> </classification><classification> <tag>family</tag> <value>System and Communications Protection</value> </classification><classification> <tag>family</tag> <value>System and Communications Protocols</value> </classification>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <specification exclude="true" type="tabular">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
        <dl>
        <dt>A</dt><dd>B</dd>
        <dt>C</dt><dd>D</dd>
        </dl>
        </description>
        <measurement-target exclude="false">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
        <component class="test-purpose"><p>TEST PURPOSE</p></component>
        <component class="test-method"><p>TEST METHOD</p></component>
        <component class="conditions"><p>CONDITIONS</p></component>
        <component class="part"><p>FIRST PART</p></component>
        <component class="part"><p>SECOND PART</p></component>
        <component class="part"><p>THIRD PART</p></component>
        <component class="reference"><p>REFERENCE PART</p></component>
        <component class="panda GHz express"><p>PANDA PART</p></component>
      </permission>
          </foreword></preface>
          <bibliography><references id="_bibliography" obligation="informative" normative="false">
      <title>Bibliography</title>
      <bibitem id="rfc2616" type="standard"> <fetched>2020-03-27</fetched> <title format="text/plain" language="en" script="Latn">Hypertext Transfer Protocol — HTTP/1.1</title> <docidentifier type="IETF">RFC 2616</docidentifier> <docidentifier type="IETF" scope="anchor">RFC2616</docidentifier> <docidentifier type="DOI">10.17487/RFC2616</docidentifier> <date type="published">  <on>1999-06</on> </date> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">R. Fielding</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">J. Gettys</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">J. Mogul</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">H. Frystyk</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">L. Masinter</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">P. Leach</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">T. Berners-Lee</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <language>en</language> <script>Latn</script> <abstract format="text/plain" language="en" script="Latn">HTTP has been in use by the World-Wide Web global information initiative since 1990. This specification defines the protocol referred to as “HTTP/1.1”, and is an update to RFC 2068. [STANDARDS-TRACK]</abstract> <series type="main">  <title format="text/plain" language="en" script="Latn">RFC</title>  <number>2616</number> </series> <place>Fremont, CA</place></bibitem>
      </references></bibliography>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
      <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
                <preface>
          <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
                <foreword id="A" displayorder="2"><title>Preface</title>
                <table id="A1" class="modspec" type="recommend">
            <name>Table 1 — Permission 1: First</name>
            <tbody>
              <tr><th>Identifier</th><td><tt>/ogc/recommendation/wfs/2</tt></td></tr>
              <tr><th>Subject</th><td>user</td></tr>
            <tr><th>Prerequisites</th><td>/ss/584/2015/level/1<br/>
            <xref type="inline" target="rfc2616">RFC 2616 (HTTP/1.1)</xref></td></tr>
            <tr>
        <th>Control-class</th>
        <td>Technical</td>
      </tr>
      <tr>
        <th>Priority</th>
        <td>P0</td>
      </tr>
      <tr>
        <th>Family</th>
        <td>System and Communications Protection<br/>
        System and Communications Protocols</td>
      </tr>
      <tr><th>Statement</th><td>
          <p id="_">I recommend <em>this</em>.</p>
            </td>
            </tr>
            <tr>
            <th>A</th>
            <td>B</td>
          </tr>
          <tr>
            <th>C</th>
            <td>D</td>
          </tr>
      <tr>
        <td colspan='2'>
          <p id='_'>The measurement target shall be measured as:</p>
          <formula id='_'>
            <name>1</name>
            <stem type='AsciiMath'>r/1 = 0</stem>
          </formula>
        </td>
      </tr>
      <tr>
        <td colspan='2'>
          <p id='_'>The following code will be run for verification:</p>
          <sourcecode id='_'>
            CoreRoot(success): HttpResponse if (success)
            recommendation(label: success-response) end
          </sourcecode>
        </td>
      </tr>
             <tr>
                   <th>Test purpose</th>
                   <td>
                     <p>TEST PURPOSE</p>
                   </td>
                 </tr>
                 <tr>
                   <th>Test method</th>
                   <td>
                     <p>TEST METHOD</p>
                   </td>
                 </tr>
                 <tr>
                   <th>Conditions</th>
                   <td>
                     <p>CONDITIONS</p>
                   </td>
                 </tr>
                 <tr>
                   <th>A</th>
                   <td>
                     <p>FIRST PART</p>
                   </td>
                 </tr>
                 <tr>
                   <th>B</th>
                   <td>
                     <p>SECOND PART</p>
                   </td>
                 </tr>
                 <tr>
                   <th>C</th>
                   <td>
                     <p>THIRD PART</p>
                   </td>
                 </tr>
                 <tr>
                  <th>Reference</th>
                  <td>
                    <p>REFERENCE PART</p>
                  </td>
                </tr>
                <tr>
                  <th>Panda GHz express</th>
                  <td>
                    <p>PANDA PART</p>
                  </td>
                </tr>
              </tbody></table>
                </foreword></preface>
                <bibliography><references id="_" obligation="informative" normative="false" displayorder="3">
            <title depth="1">Bibliography</title>
            <bibitem id="rfc2616" type="standard">
            <formattedref><smallcap>R. Fielding, J. Gettys, J. Mogul, H. Frystyk, L. Masinter, P. Leach, & T. Berners-Lee</smallcap>. <em><span class="stddocTitle">Hypertext Transfer Protocol — HTTP/1.1</span></em>.</formattedref>
                <docidentifier type='metanorma-ordinal'>[1]</docidentifier>
                <docidentifier type='IETF'>IETF&#xa0;RFC&#xa0;2616</docidentifier>
                <docidentifier type='IETF' scope='anchor'>IETF&#xa0;RFC2616</docidentifier>
                <docidentifier type='DOI'>DOI 10.17487/RFC2616</docidentifier>
                <biblio-tag>[1]<tab/>IETF&#xa0;RFC&#xa0;2616, </biblio-tag>
          </bibitem>
            </references></bibliography>
                </ogc-standard>
    OUTPUT

    html = <<~OUTPUT
      <body lang='en'>
         <div class='title-section'>
           <p> </p>
         </div>
         <br/>
         <div class='prefatory-section'>
           <p> </p>
         </div>
         <br/>
         <div class='main-section'>
           <br/>
           <div class="TOC" id="_">
              <h1 class="IntroTitle">Contents</h1>
          </div>
          <br/>
           <div id='A'>
                         <h1 class="ForewordTitle">Preface</h1>
              <p class="TableTitle" style="text-align:center;">Table 1 — Permission 1: First</p>
              <table id="A1" class="modspec" style="border-width:1px;border-spacing:0;">
                <tbody>
                  <tr>
                    <th style="font-weight:bold;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="row">Identifier</th>
                    <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">
                      <tt>/ogc/recommendation/wfs/2</tt>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">Subject</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">user</td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">Prerequisites</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">/ss/584/2015/level/1<br/><a href="#rfc2616">RFC 2616 (HTTP/1.1)</a></td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">Control-class</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">Technical</td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">Priority</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">P0</td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">Family</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">System and Communications Protection<br/>
          System and Communications Protocols</td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">Statement</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">
                      <p id="_">I recommend <i>this</i>.</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">A</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">B</td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">C</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">D</td>
                  </tr>
                  <tr>
                    <td colspan="2" style="border-top:none;border-bottom:solid windowtext 1.0pt;">
                      <p id="_">The measurement target shall be measured as:</p>
                      <div id="_">
                        <div class="formula">
                          <p><span class="stem">(#(r/1 = 0)#)</span>  (1)</p>
                        </div>
                      </div>
                    </td>
                  </tr>
                  <tr>
                    <td colspan="2" style="border-top:none;border-bottom:solid windowtext 1.0pt;">
                      <p id="_">The following code will be run for verification:</p>
                      <pre id="_" class="sourcecode"><br/>
             CoreRoot(success): HttpResponse if (success)<br/>
             recommendation(label: success-response) end<br/>
           </pre>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">Test purpose</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">
                      <p>TEST PURPOSE</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">Test method</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">
                      <p>TEST METHOD</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">Conditions</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">
                      <p>CONDITIONS</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">A</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">
                      <p>FIRST PART</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">B</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">
                      <p>SECOND PART</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">C</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">
                      <p>THIRD PART</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.0pt;" scope="row">Reference</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.0pt;">
                      <p>REFERENCE PART</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="row">Panda GHz express</th>
                    <td style="border-top:none;border-bottom:solid windowtext 1.5pt;">
                      <p>PANDA PART</p>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <br/>
            <div>
              <h1 class="Section3">Bibliography</h1>
              <p id="rfc2616" class="Biblio">[1]  IETF&#xa0;RFC&#xa0;2616, <span style="font-variant:small-caps;">R. Fielding, J. Gettys, J. Mogul, H. Frystyk, L. Masinter, P. Leach,  T. Berners-Lee</span>. <i><span class="stddocTitle">Hypertext Transfer Protocol — HTTP/1.1</span></i>.</p>
            </div>
          </div>
        </body>
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
          <div id="A">
            <h1 class="ForewordTitle">Preface</h1>
            <p class="Tabletitle" style="text-align:center;">Table 1 — Permission 1: First</p>
            <div align="center" class="table_container">
              <table id="A1" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;" width="100%">
                <tbody>
                  <tr>
                    <th style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">Identifier</th>
                    <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                      <tt>/ogc/recommendation/wfs/2</tt>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">Subject</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">user</td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">Prerequisites</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">/ss/584/2015/level/1<br/><a href="#rfc2616">RFC 2616 (HTTP/1.1)</a></td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">Control-class</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">Technical</td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">Priority</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">P0</td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">Family</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">System and Communications Protection<br/>
        System and Communications Protocols</td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">Statement</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                      <p class="ForewordText" id="_">I recommend <i>this</i>.</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">A</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">B</td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">C</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">D</td>
                  </tr>
                  <tr>
                    <td colspan="2" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                      <p class="ForewordText" id="_">The measurement target shall be measured as:</p>
                      <div id="_">
                        <div class="formula">
                          <p><span class="stem">(#(r/1 = 0)#)</span><span style="mso-tab-count:1">  </span>(1)</p>
                        </div>
                      </div>
                    </td>
                  </tr>
                  <tr>
                    <td colspan="2" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                      <p class="ForewordText" id="_">The following code will be run for verification:</p>
                      <p id="_" class="Sourcecode"><br/>      CoreRoot(success): HttpResponse if (success)<br/>      recommendation(label: success-response) end<br/>    </p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">Test purpose</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                      <p class="ForewordText">TEST PURPOSE</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">Test method</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                      <p class="ForewordText">TEST METHOD</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">Conditions</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                      <p class="ForewordText">CONDITIONS</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">A</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                      <p class="ForewordText">FIRST PART</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">B</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                      <p class="ForewordText">SECOND PART</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">C</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                      <p class="ForewordText">THIRD PART</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">Reference</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                      <p class="ForewordText">REFERENCE PART</p>
                    </td>
                  </tr>
                  <tr>
                    <th style="font-weight:bold;border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">Panda GHz express</th>
                    <td style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                      <p class="ForewordText">PANDA PART</p>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <p> </p>
        </div>
        <p class="section-break">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
          <p class="page-break">
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div>
            <h1 class="BiblioTitle">Bibliography</h1>
            <p id="rfc2616" class="Biblio">[1]<span style="mso-tab-count:1">  </span>IETF&#xa0;RFC&#xa0;2616, <span style="font-variant:small-caps;">R. Fielding, J. Gettys, J. Mogul, H. Frystyk, L. Masinter, P. Leach,  T. Berners-Lee</span>. <i><span class="stddocTitle">Hypertext Transfer Protocol — HTTP/1.1</span></i>.</p>
          </div>
        </div>
        <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"/>
      </body>
    OUTPUT

    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::Iso::WordConvert.new({})
      .convert("test", presxml, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(doc)
  end

  it "processes permission verifications" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface>
              <foreword id="A"><title>Preface</title>
          <permission model="ogc" id="A1" type="verification">
          <title>First</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <subject>user</subject>
        <classification> <tag>control-class</tag> <value>Technical</value> </classification><classification> <tag>priority</tag> <value>P0</value> </classification><classification> <tag>family</tag> <value>System and Communications Protection</value> </classification><classification> <tag>family</tag> <value>System and Communications Protocols</value> </classification>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <specification exclude="true" type="tabular">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
        <dl>
        <dt>A</dt><dd>B</dd>
        <dt>C</dt><dd>D</dd>
        </dl>
        </description>
        <measurement-target exclude="false">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
      </permission>
          </foreword></preface>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
      <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
         <preface>
          <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
           <foreword id='A' displayorder='2'>
             <title>Preface</title>
             <table id='A1' class='modspec' type='recommendtest'>
               <name>Table 1 — Conformance test 1: First</name>
               <tbody>
                 <tr>
                <th>Identifier</th>
                <td><tt>/ogc/recommendation/wfs/2</tt></td>
                </tr>
                 <tr>
                   <th>Subject</th>
                   <td>user</td>
                 </tr>
                 <tr>
                   <th>Prerequisite</th>
                   <td>/ss/584/2015/level/1</td>
                 </tr>
                 <tr>
                   <th>Control-class</th>
                   <td>Technical</td>
                 </tr>
                 <tr>
                   <th>Priority</th>
                   <td>P0</td>
                 </tr>
                 <tr>
                   <th>Family</th>
                   <td>System and Communications Protection<br/>
                   System and Communications Protocols</td>
                 </tr>
                         <tr><th>Description</th><td>
          <p id="_">I recommend <em>this</em>.</p>
            </td>
            </tr>
            <tr>
            <th>A</th>
            <td>B</td>
          </tr>
          <tr>
            <th>C</th>
            <td>D</td>
          </tr>
                 <tr>
                   <td colspan='2'>
                     <p id='_'>The measurement target shall be measured as:</p>
                     <formula id='_'>
                       <name>1</name>
                       <stem type='AsciiMath'>r/1 = 0</stem>
                     </formula>
                   </td>
                 </tr>
                 <tr>
                   <td colspan='2'>
                     <p id='_'>The following code will be run for verification:</p>
                     <sourcecode id='_'>
                       CoreRoot(success): HttpResponse if (success)
                       recommendation(label: success-response) end#{' '}
                     </sourcecode>
                   </td>
                 </tr>
               </tbody>
             </table>
           </foreword>
         </preface>
       </ogc-standard>
    OUTPUT

    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
  .gsub(%r{^.*<body}m, "<body")
  .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes abstract tests" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface>
              <foreword id="A"><title>Preface</title>
          <permission model="ogc" id="A1" type="abstracttest">
          <title>First</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <subject>user</subject>
        <classification> <tag>control-class</tag> <value>Technical</value> </classification><classification> <tag>priority</tag> <value>P0</value> </classification><classification> <tag>family</tag> <value>System and Communications Protection</value> </classification><classification> <tag>family</tag> <value>System and Communications Protocols</value> </classification>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <specification exclude="true" type="tabular">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
        <dl>
        <dt>A</dt><dd>B</dd>
        <dt>C</dt><dd>D</dd>
        </dl>
        </description>
        <measurement-target exclude="false">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
      </permission>
          </foreword></preface>
          </ogc-standard>
    INPUT
    presxml = <<~OUTPUT
      <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <preface>
          <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
              <foreword id="A" displayorder="2"><title>Preface</title>
          <table id="A1" type="recommendtest" class="modspec">
          <name>Table 1 — Abstract test 1: First</name>
        <tbody>
          <tr><th>Identifier</th><td><tt>/ogc/recommendation/wfs/2</tt></td></tr>
        <tr><th>Subject</th><td>user</td></tr>
        <tr><th>Prerequisite</th><td>/ss/584/2015/level/1</td></tr><tr><th>Control-class</th><td>Technical</td></tr><tr><th>Priority</th><td>P0</td></tr>
        <tr><th>Family</th><td>System and Communications Protection<br/>
        System and Communications Protocols</td></tr>

        <tr><th>Description</th><td>
          <p id="_">I recommend <em>this</em>.</p>
            </td>
            </tr>
            <tr>
            <th>A</th>
            <td>B</td>
          </tr>
          <tr>
            <th>C</th>
            <td>D</td>
          </tr>
            <tr> <td colspan='2'>
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_"><name>1</name>
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </td></tr><tr><td colspan="2">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </td></tr></tbody></table>
          </foreword></preface>
          </ogc-standard>
    OUTPUT

    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
              .convert("test", input, true)
  .gsub(%r{^.*<body}m, "<body")
  .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes permission classes" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <permission model="ogc" id="A1" type="class" keep-with-next="true" keep-lines-together="true">
          <title>First</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <inherit>/ss/584/2015/level/2</inherit>
        <subject>user</subject>
        <permission model="ogc" id="A2">
          <title>First #1</title>
        <identifier>/ogc/recommendation/wfs/10</identifier>
        </permission>
        <requirement model="ogc" id="A3">
          <title>First #2</title>
        <identifier>Requirement 1</identifier>
        </requirement>
        <recommendation model="ogc" id="A4">
          <title>First #3</title>
        <identifier>Recommendation 1</identifier>
        </recommendation>
      </permission>
      <permission model="ogc" id="B1">
          <title>Second</title>
        <identifier>/ogc/recommendation/wfs/10</identifier>
      </permission>
          </foreword></preface>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
          <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
        <preface>
          <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
          <foreword id='A' displayorder='2'>
            <title>Preface</title>
            <table id='A1' keep-with-next='true' keep-lines-together='true' class='modspec' type='recommendclass'>
              <name>Table 1 — Permissions class 1: First</name>
              <tbody>
                <tr>
                  <th>Identifier</th>
                  <td><tt>/ogc/recommendation/wfs/2</tt></td>
                </tr>
                <tr>
                  <th>Target type</th>
                  <td>user</td>
                </tr>
                <tr>
                  <th>Prerequisites</th>
                  <td>/ss/584/2015/level/1<br/>
                  /ss/584/2015/level/2</td>
                </tr>
                                 <tr>
                   <th>Provisions</th>
                   <td>
                     <xref target='B1'>
                       Permission 1:
                       Second
                     </xref>
                     <br/>
                     <xref target='A3'>
                       Requirement 1-1:
                       First #2
                     </xref>
                     <br/>
                     <xref target='A4'>
                       Recommendation 1-1:
                       First #3
                     </xref>
                   </td>
                 </tr>
              </tbody>
            </table>
            <table id='B1' class='modspec' type='recommend'>
              <name>Table 2 — Permission 1: Second</name>
              <tbody>
                <tr>
                  <th>Identifier</th>
                  <td><tt>/ogc/recommendation/wfs/10</tt></td>
                </tr>
                <tr>
                  <th>Included in</th>
                  <td>
                    <xref target='A1'>Permissions class 1: First</xref>
                  </td>
                </tr>
              </tbody>
            </table>
          </foreword>
        </preface>
      </ogc-standard>
    OUTPUT

    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
            .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes conformance classes" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <permission model="ogc" id="A1" type="conformanceclass">
          <title>First</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <inherit>ABC</inherit>
        <subject>user</subject>
        <classification><tag>target</target><value>ABC</value></classification>
        <classification><tag>indirect-dependency</target><value><link target="http://www.example.com/"/></value></classification>
        <classification><tag>indirect-dependency</target><value>ABC</value></classification>
        <permission model="ogc" id="A2">
        <identifier>Permission 1</identifier>
        </permission>
        <requirement model="ogc" id="A3">
        <identifier>Requirement 1</identifier>
        </requirement>
        <recommendation model="ogc" id="A4">
        <identifier>Recommendation 1</identifier>
        </recommendation>
      </permission>
          <permission model="ogc" id="B" type="conformanceclass">
          <title>Second</title>
          <identifier>ABC</identifier>
          </permission>
          <permission model="ogc" id="B2">
          <title>Third</title>
        <identifier>Permission 1</identifier>
        </permission>
          </foreword></preface>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
      <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
         <preface>
          <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
           <foreword id='A' displayorder='2'>
             <title>Preface</title>
             <table id='A1' class='modspec' type='recommendclass'>
               <name>Table 1 — Conformance class 1: First</name>
               <tbody>
                 <tr>
                   <th>Identifier</th>
                   <td><tt>/ogc/recommendation/wfs/2</tt></td>
                 </tr>
                 <tr>
                   <th>Subject</th>
                   <td>user</td>
                 </tr>
                 <tr>
                   <th>Requirements class</th>
                   <td>
                     <xref target='B'>Conformance class 2: Second</xref>
                   </td>
                 </tr>
                 <tr>
                   <th>Prerequisites</th>
                   <td>/ss/584/2015/level/1<br/>
                     <xref target='B'>Conformance class 2: Second</xref>
                   </td>
                 </tr>
                 <tr>
                   <th>Indirect prerequisites</th>
                   <td>
                     <link target='http://www.example.com/'/>
                   <br/>
                     <xref target='B'>Conformance class 2: Second</xref>
                   </td>
                 </tr>
                 <tr>
                   <th>Conformance tests</th>
                   <td>
                     <xref target='B2'>
                       Permission 1:
                       Third
                     </xref>
                     <br/>
                     <xref target='A3'>
                       Requirement 1-1
                     </xref>
                     <br/>
                     <xref target='A4'>
                       Recommendation 1-1
                     </xref>
                   </td>
                 </tr>
               </tbody>
             </table>
             <table id='B' class='modspec' type='recommendclass'>
               <name>Table 2 — Conformance class 2: Second</name>
               <tbody>
                 <tr>
                   <th>Identifier</th>
                   <td><tt>ABC</tt></td>
                 </tr>
               </tbody>
             </table>
             <table id='B2' class='modspec' type='recommend'>
             <name>Table 3 — Permission 1: Third</name>
        <tbody>
          <tr>
            <th>Identifier</th>
            <td><tt>Permission 1</tt></td>
          </tr>
          <tr>
            <th>Included in</th>
            <td>
              <xref target='A1'>
                Conformance class 1:
                First
              </xref>
            </td>
          </tr>
        </tbody>
      </table>
           </foreword>
         </preface>
       </ogc-standard>
    OUTPUT

    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes conformance classes in French" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
              <bibdata><language>fr</language></bibdata>
          <preface><foreword id="A"><title>Preface</title>
          <permission model="ogc" id="A1" type="conformanceclass">
          <title>First</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <inherit>ABC</inherit>
        <subject>user</subject>
        <classification><tag>target</target><value>ABC</value></classification>
        <classification><tag>indirect-dependency</target><value><link target="http://www.example.com/"/></value></classification>
        <classification><tag>indirect-dependency</target><value>ABC</value></classification>
        <permission model="ogc" id="A2">
        <identifier>Permission 1</identifier>
        </permission>
        <requirement model="ogc" id="A3">
        <identifier>Requirement 1</identifier>
        </requirement>
        <recommendation model="ogc" id="A4">
        <identifier>Recommendation 1</identifier>
        </recommendation>
      </permission>
          <permission model="ogc" id="B" type="conformanceclass">
          <title>Second</title>
          <identifier>ABC</identifier>
          </permission>
          <permission model="ogc" id="B2">
          <title>Third</title>
        <identifier>Permission 1</identifier>
        </permission>
          </foreword></preface>
          </ogc-standard>
    INPUT
    presxml = <<~OUTPUT
      <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
         <bibdata>
           <language current='true'>fr</language>
         </bibdata>
         <preface>
          <clause type="toc" id="_" displayorder="1"> <title depth="1">Sommaire</title> </clause>
           <foreword id='A' displayorder='2'>
             <title>Preface</title>
             <table id='A1' class='modspec' type='recommendclass'>
               <name>Tableau 1 — Classe de confirmité 1&#xa0;: First</name>
               <tbody>
                 <tr>
                   <th>Identifiant</th>
                   <td><tt>/ogc/recommendation/wfs/2</tt></td>
                 </tr>
                 <tr>
                   <th>Sujet</th>
                   <td>user</td>
                 </tr>
                 <tr>
                   <th>Classe d&#x2019;exigences</th>
                   <td>
                     <xref target='B'>Classe de confirmité 2&#xa0;: Second</xref>
                   </td>
                 </tr>
                 <tr>
                   <th>Prérequis</th>
                   <td>/ss/584/2015/level/1<br/>
                     <xref target='B'>Classe de confirmité 2&#xa0;: Second</xref>
                   </td>
                 </tr>
                 <tr>
                   <th>Prérequis indirect</th>
                   <td>
                     <link target='http://www.example.com/'/>
                   <br/>
                     <xref target='B'>Classe de confirmité 2&#xa0;: Second</xref>
                   </td>
                 </tr>
                   <tr>
                   <th>Tests de conformité</th>
                   <td>
                     <xref target='B2'>
                       Autorisation 1&#xa0;:
                       Third
                     </xref>
                     <br/>
                     <xref target='A3'>
                       Exigence 1-1
                     </xref>
                     <br/>
                     <xref target='A4'>
                       Recommandation 1-1
                     </xref>
                   </td>
                 </tr>
               </tbody>
             </table>
             <table id='B' class='modspec' type='recommendclass'>
             <name>Tableau 2 — Classe de confirmité 2&#xa0;: Second</name>
               <tbody>
                 <tr>
                   <th>Identifiant</th>
                   <td><tt>ABC</tt></td>
                 </tr>
               </tbody>
             </table>
             <table id='B2' class='modspec' type='recommend'>
             <name>Tableau 3 — Autorisation 1&#xa0;: Third</name>
        <tbody>
          <tr>
            <th>Identifiant</th>
            <td><tt>Permission 1</tt></td>
          </tr>
          <tr>
            <th>Inclus dans</th>
            <td>
              <xref target='A1'>
                 Classe de confirmit&#xE9; 1&#xa0;:
                 First
              </xref>
            </td>
          </tr>
        </tbody>
      </table>
           </foreword>
         </preface>
       </ogc-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
       .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")
       .gsub(%r{^.*<body}m, "<body")
       .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes requirement classes" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <requirement model="ogc" id="A1" type="class">
          <title>First</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <inherit>/ss/584/2015/level/2</inherit>
        <subject>user</subject>
        <permission model="ogc" id="A2">
          <title>First #1</title>
        <identifier>Permission 1</identifier>
        </permission>
      </requirement>
      <permission model="ogc" id="A5">
          <title>Second</title>
        <identifier>Permission 1</identifier>
        </permission>
          </foreword></preface>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
      <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
         <preface>
          <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
           <foreword id='A' displayorder='2'>
             <title>Preface</title>
             <table id='A1' class='modspec' type='recommendclass'>
               <name>Table 1 — Requirements class 1: First</name>
               <tbody>
                 <tr>
                   <th>Identifier</th>
                   <td><tt>/ogc/recommendation/wfs/2</tt></td>
                 </tr>
                 <tr>
                   <th>Target type</th>
                   <td>user</td>
                 </tr>
                 <tr>
                   <th>Prerequisites</th>
                   <td>/ss/584/2015/level/1<br/>
                   /ss/584/2015/level/2</td>
                 </tr>
                 <tr>
                 <th>Provision</th>
                 <td>
            <xref target='A5'>
              Permission 1:
              Second
            </xref>
            </td>
          </tr>
               </tbody>
             </table>
             <table id='A5' class='modspec' type='recommend'>
                <name>Table 2 — Permission 1: Second</name>
               <tbody>
                 <tr>
                   <th>Identifier</th>
                   <td><tt>Permission 1</tt></td>
                 </tr>
                 <tr>
                   <th>Included in</th>
                   <td>
                     <xref target='A1'>
                       Requirements class 1:
                       First
                     </xref>
                   </td>
                 </tr>
               </tbody>
             </table>
           </foreword>
         </preface>
       </ogc-standard>
    OUTPUT

    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes recommendation classes" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <recommendation model="ogc" id="A1" type="class">
          <title>First</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <inherit>/ss/584/2015/level/2</inherit>
        <subject>user</subject>
        <permission model="ogc" id="A2">
          <title>First #1</title>
        <identifier>Permission 1</identifier>
        </permission>
        <requirement model="ogc" id="A3">
          <title>First #2</title>
        <identifier>Requirement 1</identifier>
        </requirement>
        <recommendation model="ogc" id="A4">
          <title>First #3</title>
        <identifier>Recommendation 1</identifier>
        </recommendation>
      </recommendation>
          </foreword></preface>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
          <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
        <preface>
          <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
          <foreword id='A' displayorder='2'>
            <title>Preface</title>
            <table id='A1' class='modspec' type='recommendclass'>
            <name>Table 1 — Recommendations class 1: First</name>
              <tbody>
                <tr>
                  <th>Identifier</th>
                  <td><tt>/ogc/recommendation/wfs/2</tt></td>
                </tr>
                <tr>
                  <th>Target type</th>
                  <td>user</td>
                </tr>
                <tr>
                  <th>Prerequisites</th>
                  <td>/ss/584/2015/level/1<br/>
                  /ss/584/2015/level/2</td>
                </tr>
                <tr>
                   <th>Provisions</th>
                   <td>
                   <xref target='A2'>Permission 1-1:
                     First #1
                   </xref>
                   <br/>
                   <xref target='A3'>
                     Requirement 1-1:
                     First #2
                   </xref>
                   <br/>
                   <xref target='A4'>
                     Recommendation 1-1:
                     First #3
                   </xref>
                   </td>
                 </tr>
              </tbody>
            </table>
          </foreword>
        </preface>
      </ogc-standard>
    OUTPUT

    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes requirements" do
    input = <<~INPUT
                <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A0"><title>Preface</title>
          <requirement model="ogc" id="A" unnumbered="true">
        <title>A New Requirement</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <subject>user</subject>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <specification exclude="true" type="tabular" keep-with-next="true" keep-lines-together="true">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
              </tr>
              <tr>
                <td style="text-align:left;">Mission</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
          <p id="_">As for the measurement targets,</p>
        </description>
        <measurement-target exclude="false">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="B">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
      </requirement>
          </foreword></preface>
          </ogc-standard>
    INPUT
    presxml = <<~OUTPUT
          <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
        <preface>
          <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
          <foreword id='A0' displayorder='2'>
            <title>Preface</title>
            <table id='A' unnumbered='true' class='modspec' type='recommend'>
            <name>Table — Requirement: A New Requirement</name>
              <tbody>
                <tr>
                  <th>Identifier</th>
                  <td><tt>/ogc/recommendation/wfs/2</tt></td>
                </tr>
                <tr>
                  <th>Subject</th>
                  <td>user</td>
                </tr>
                <tr>
                  <th>Prerequisite</th>
                  <td>/ss/584/2015/level/1</td>
                </tr>
                <tr>
                  <th>Statements</th><td>
                    <p id='_'>
                      I recommend
                      <em>this</em>
                      .
                    </p>
                    <br/>
                    <p id='_'>As for the measurement targets,</p>
                  </td>
                </tr>
                <tr>
                  <td colspan='2'>
                    <p id='_'>The measurement target shall be measured as:</p>
                    <formula id='B'>
                      <name>1</name>
                      <stem type='AsciiMath'>r/1 = 0</stem>
                    </formula>
                  </td>
                </tr>
                <tr>
                  <td colspan='2'>
                    <p id='_'>The following code will be run for verification:</p>
                    <sourcecode id='_'>
                      CoreRoot(success): HttpResponse if (success)
                      recommendation(label: success-response) end
                    </sourcecode>
                  </td>
                </tr>
              </tbody>
            </table>
          </foreword>
        </preface>
      </ogc-standard>
    OUTPUT

    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes recommendations" do
    input = <<~INPUT
            <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <recommendation model="ogc" id="_">
          <title>First</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <subject>user</subject>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <specification exclude="true" type="tabular">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
              </tr>
              <tr>
                <td style="text-align:left;">Mission</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
          <p id="_">As for the measurement targets,</p>
        </description>
        <measurement-target exclude="false">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
      </recommendation>
          </foreword></preface>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
          <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
        <preface>
          <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
          <foreword id='A' displayorder='2'>
            <title>Preface</title>
            <table id='_' class='modspec' type='recommend'>
              <name>Table 1 — Recommendation 1: First</name>
              <tbody>
                <tr>
                  <th>Identifier</th>
                  <td><tt>/ogc/recommendation/wfs/2</tt></td>
                </tr>
                <tr>
                  <th>Subject</th>
                  <td>user</td>
                </tr>
                <tr>
                  <th>Prerequisite</th>
                  <td>/ss/584/2015/level/1</td>
                </tr>
                <tr>
                  <th>Statements</th><td>
                    <p id='_'>
                      I recommend
                      <em>this</em>
                      .
                    </p>
                  <br/>
                    <p id='_'>As for the measurement targets,</p>
                  </td>
                </tr>
                <tr>
                  <td colspan='2'>
                    <p id='_'>The measurement target shall be measured as:</p>
                    <formula id='_'>
                      <name>1</name>
                      <stem type='AsciiMath'>r/1 = 0</stem>
                    </formula>
                  </td>
                </tr>
                <tr>
                  <td colspan='2'>
                    <p id='_'>The following code will be run for verification:</p>
                    <sourcecode id='_'>
                      CoreRoot(success): HttpResponse if (success)
                      recommendation(label: success-response) end
                    </sourcecode>
                  </td>
                </tr>
              </tbody>
            </table>
          </foreword>
        </preface>
      </ogc-standard>
    OUTPUT

    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to xmlpp(presxml)
  end
end
