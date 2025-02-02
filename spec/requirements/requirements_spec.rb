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
       <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <table id="A0" autonum="1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Table</span>
                         <semx element="autonum" source="A0">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A0">1</semx>
                   </fmt-xref-label>
                </table>
                <permission model="ogc" autonum="1" original-id="A1">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A1">2</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Permission</span>
                      <semx element="autonum" source="A1">1</semx>
                      :
                      <tt>
                         <xref style="id" target="A1">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>First</title>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <fmt-provision>
                      <table id="A1" type="recommend" class="modspec" autonum="2">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="A1">2</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Permission</span>
                                  <semx element="autonum" source="A1">1</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="A1">First</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                                  </tt>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
                <table id="A2" autonum="3">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Table</span>
                         <semx element="autonum" source="A2">3</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A2">3</semx>
                   </fmt-xref-label>
                </table>
             </foreword>
             <introduction id="B" displayorder="3">
                <title id="_">Introduction</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <p>
                   <xref target="A0">
                      <span class="citetbl">
                         <span class="fmt-element-name">Table</span>
                         <semx element="autonum" source="A0">1</semx>
                      </span>
                   </xref>
                   <xref target="A1">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A1">2</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Permission</span>
                      <semx element="autonum" source="A1">1</semx>
                   </xref>
                   <xref target="A2">
                      <span class="citetbl">
                         <span class="fmt-element-name">Table</span>
                         <semx element="autonum" source="A2">3</semx>
                      </span>
                   </xref>
                </p>
             </introduction>
          </preface>
       </ogc-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
          <table id="A1">
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
      <bibitem id="rfc2616" type="standard"> <fetched>2020-03-27</fetched> <title format="text/plain" language="en" script="Latn">Hypertext Transfer Protocol — HTTP/1.1</title> <docidentifier type="IETF">RFC 2616</docidentifier> <docidentifier type="IETF" scope="anchor">RFC2616</docidentifier> 
      <docidentifier type="DOI">DOI 10.17487/RFC2616</docidentifier>
        <date type="published">  <on>1999-06</on> </date> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">R. Fielding</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">J. Gettys</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">J. Mogul</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">H. Frystyk</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">L. Masinter</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">P. Leach</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">T. Berners-Lee</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <language>en</language> <script>Latn</script> <abstract format="text/plain" language="en" script="Latn">HTTP has been in use by the World-Wide Web global information initiative since 1990. This specification defines the protocol referred to as “HTTP/1.1”, and is an update to RFC 2068. [STANDARDS-TRACK]</abstract> <series type="main">  <title format="text/plain" language="en" script="Latn">RFC</title>  <number>2616</number> </series> <place>Fremont, CA</place></bibitem>
      </references></bibliography>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
       <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <permission model="ogc" autonum="1" original-id="A1">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A1">1</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Permission</span>
                      <semx element="autonum" source="A1">1</semx>
                      :
                      <tt>
                         <xref style="id" target="A1">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>First</title>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <inherit id="_">
                      <eref type="inline" bibitemid="rfc2616" citeas="RFC 2616">RFC 2616 (HTTP/1.1)</eref>
                   </inherit>
                   <subject id="_">user</subject>
                   <classification>
                      <tag id="_">control-class</tag>
                      <value id="_">Technical</value>
                   </classification>
                   <classification>
                      <tag id="_">priority</tag>
                      <value id="_">P0</value>
                   </classification>
                   <classification>
                      <tag id="_">family</tag>
                      <value id="_">System and Communications Protection</value>
                   </classification>
                   <classification>
                      <tag id="_">family</tag>
                      <value id="_">System and Communications Protocols</value>
                   </classification>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>this</em>
                         .
                      </p>
                   </description>
                   <specification exclude="true" type="tabular">
                      <p id="_">This is the object of the recommendation:</p>
                      <table id="A1" unnumbered="true">
                         <tbody>
                            <tr>
                               <td style="text-align:left;">Object</td>
                               <td style="text-align:left;">Value</td>
                               <td style="text-align:left;">Accomplished</td>
                            </tr>
                         </tbody>
                      </table>
                   </specification>
                   <description id="_">
                      <dl>
                         <dt>A</dt>
                         <dd>B</dd>
                         <dt>C</dt>
                         <dd>D</dd>
                      </dl>
                   </description>
                   <measurement-target exclude="false" id="_">
                      <p original-id="_">The measurement target shall be measured as:</p>
                      <formula autonum="1" original-id="B">
                         <stem type="AsciiMath">r/1 = 0</stem>
                      </formula>
                   </measurement-target>
                   <verification exclude="false" id="_">
                      <p original-id="_">The following code will be run for verification:</p>
                      <sourcecode autonum="2" original-id="_">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </sourcecode>
                   </verification>
                   <import exclude="true">
                      <sourcecode id="_" autonum="2">success-response()</sourcecode>
                   </import>
                   <component class="test-purpose" id="_">
                      <p>TEST PURPOSE</p>
                   </component>
                   <component class="test-method" id="_">
                      <p>TEST METHOD</p>
                   </component>
                   <component class="conditions" id="_">
                      <p>CONDITIONS</p>
                   </component>
                   <component class="part" id="_">
                      <p>FIRST PART</p>
                   </component>
                   <component class="part" id="_">
                      <p>SECOND PART</p>
                   </component>
                   <component class="part" id="_">
                      <p>THIRD PART</p>
                   </component>
                   <component class="reference" id="_">
                      <p>REFERENCE PART</p>
                   </component>
                   <component class="panda GHz express" id="_">
                      <p>PANDA PART</p>
                   </component>
                   <fmt-provision>
                      <table id="A1" type="recommend" class="modspec" autonum="1">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="A1">1</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Permission</span>
                                  <semx element="autonum" source="A1">1</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="A1">First</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Subject</th>
                               <td>
                                  <semx element="subject" source="_">user</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Prerequisites</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                                  <br/>
                                  <semx element="inherit" source="_">
                                     <xref type="inline" target="rfc2616">RFC 2616 (HTTP/1.1)</xref>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>
                                  <semx element="tag" source="_">Control-class</semx>
                               </th>
                               <td>
                                  <semx element="value" source="_">Technical</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>
                                  <semx element="tag" source="_">Priority</semx>
                               </th>
                               <td>
                                  <semx element="value" source="_">P0</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>
                                  <semx element="tag" source="_">Family</semx>
                               </th>
                               <td>
                                  <semx element="value" source="_">System and Communications Protection</semx>
                                  <br/>
                                  <semx element="value" source="_">System and Communications Protocols</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Statement</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>this</em>
                                        .
                                     </p>
                                  </semx>
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
                            <tr id="_">
                               <td colspan="2" id="_">
                                  <semx element="measurement-target" source="_">
                                     <p id="_">The measurement target shall be measured as:</p>
                                     <formula id="B" autonum="1">
                                        <fmt-name>
                                           <span class="fmt-caption-label">
                                              <span class="fmt-autonum-delim">(</span>
                                              1
                                              <span class="fmt-autonum-delim">)</span>
                                           </span>
                                        </fmt-name>
                                        <fmt-xref-label>
                                           <span class="fmt-element-name">Formula</span>
                                           <span class="fmt-autonum-delim">(</span>
                                           <semx element="autonum" source="B">1</semx>
                                           <span class="fmt-autonum-delim">)</span>
                                        </fmt-xref-label>
                                        <fmt-xref-label container="A">
                                           <span class="fmt-xref-container">
                                              <semx element="foreword" source="A">Preface</semx>
                                           </span>
                                           <span class="fmt-comma">,</span>
                                           <span class="fmt-element-name">Formula</span>
                                           <span class="fmt-autonum-delim">(</span>
                                           <semx element="autonum" source="B">1</semx>
                                           <span class="fmt-autonum-delim">)</span>
                                        </fmt-xref-label>
                                        <stem type="AsciiMath">r/1 = 0</stem>
                                     </formula>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <td colspan="2" id="_">
                                  <semx element="verification" source="_">
                                     <p id="_">The following code will be run for verification:</p>
                                     <sourcecode id="_" autonum="2">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </sourcecode>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <th>Test purpose</th>
                               <td>
                                  <semx element="component" source="_">
                                     <p>TEST PURPOSE</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <th>Test method</th>
                               <td>
                                  <semx element="component" source="_">
                                     <p>TEST METHOD</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <th>Conditions</th>
                               <td>
                                  <semx element="component" source="_">
                                     <p>CONDITIONS</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <th>A</th>
                               <td>
                                  <semx element="component" source="_">
                                     <p>FIRST PART</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <th>B</th>
                               <td>
                                  <semx element="component" source="_">
                                     <p>SECOND PART</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <th>C</th>
                               <td>
                                  <semx element="component" source="_">
                                     <p>THIRD PART</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <th>Reference</th>
                               <td>
                                  <semx element="component" source="_">
                                     <p>REFERENCE PART</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <th>Panda GHz express</th>
                               <td>
                                  <semx element="component" source="_">
                                     <p>PANDA PART</p>
                                  </semx>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
             </foreword>
          </preface>
          <bibliography>
             <references id="_" obligation="informative" normative="false" displayorder="3">
                <title id="_">Bibliography</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <bibitem id="rfc2616" type="standard">
                   <formattedref>
                      <smallcap>R. Fielding, J. Gettys, J. Mogul, H. Frystyk, L. Masinter, P. Leach, &amp; T. Berners-Lee</smallcap>
                      .
                      <em>
                         <span class="stddocTitle">Hypertext Transfer Protocol — HTTP/1.1</span>
                      </em>
                      .
                   </formattedref>
                   <docidentifier type="metanorma-ordinal">[1]</docidentifier>
                   <docidentifier type="IETF">IETF RFC 2616</docidentifier>
                   <docidentifier type="IETF" scope="anchor">IETF RFC2616</docidentifier>
                   <docidentifier type="DOI">DOI 10.17487/RFC2616</docidentifier>
                   <docidentifier scope="biblio-tag">IETF RFC 2616</docidentifier>
                   <biblio-tag>
                      [1]
                      <tab/>
                      <span class="stdpublisher">IETF </span>
                      <span class="stdpublisher">RFC </span>
                      <span class="stddocNumber">2616</span>
                      ,
                   </biblio-tag>
                </bibitem>
             </references>
          </bibliography>
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
                          <div class="permission">
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
                      <div id="B">
                        <div class="formula">
                          <p><span class="stem">(#(r/1 = 0)#)</span>  (1)</p>
                        </div>
                      </div>
                    </td>
                  </tr>
                  <tr>
                    <td colspan="2" style="border-top:none;border-bottom:solid windowtext 1.0pt;">
                      <p id="_">The following code will be run for verification:</p>
                            <pre id="_" class="sourcecode">
                               CoreRoot(success): HttpResponse
                               <br/>
                                     if (success)
                               <br/>
                                     recommendation(label: success-response)
                               <br/>
                                     end
                               <br/>
                                  
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
            </div>
            <br/>
                         <div>
                <h1 class="Section3">Bibliography</h1>
                <p id="rfc2616" class="Biblio">
                   [1] 
                   <span class="stdpublisher">IETF </span>
                   <span class="stdpublisher">RFC </span>
                   <span class="stddocNumber">2616</span>
                   ,
                   <span style="font-variant:small-caps;">R. Fielding, J. Gettys, J. Mogul, H. Frystyk, L. Masinter, P. Leach, &amp; T. Berners-Lee</span>
                   .
                   <i>
                      <span class="stddocTitle">Hypertext Transfer Protocol — HTTP/1.1</span>
                   </i>
                   .
                </p>
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
            <div class="permission">
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
                      <div id="B">
                        <div class="formula">
                          <p><span class="stem">(#(r/1 = 0)#)</span><span style="mso-tab-count:1">  </span>(1)</p>
                        </div>
                      </div>
                    </td>
                  </tr>
                  <tr>
                    <td colspan="2" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:auto;">
                      <p class="ForewordText" id="_">The following code will be run for verification:</p>
                      <p id="_" class="Sourcecode">
                                  CoreRoot(success): HttpResponse
                                  <br/>
                                        if (success)
                                  <br/>
                                        recommendation(label: success-response)
                                  <br/>
                                        end
                                  <br/>
                                     
                               </p>
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
                <p id="rfc2616" class="Biblio">
                   [1]
                   <span style="mso-tab-count:1">  </span>
                   <span class="stdpublisher">IETF </span>
                   <span class="stdpublisher">RFC </span>
                   <span class="stddocNumber">2616</span>
                   ,
                   <span style="font-variant:small-caps;">R. Fielding, J. Gettys, J. Mogul, H. Frystyk, L. Masinter, P. Leach, &amp; T. Berners-Lee</span>
                   .
                   <i>
                      <span class="stddocTitle">Hypertext Transfer Protocol — HTTP/1.1</span>
                   </i>
                   .
                </p>
             </div>
          </div>
          <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
          <div class="colophon"/>
       </body>
    OUTPUT

    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(doc)
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
      </permission>
          </foreword></preface>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
       <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <permission model="ogc" type="verification" autonum="1" original-id="A1">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A1">1</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Conformance test</span>
                      <semx element="autonum" source="A1">1</semx>
                      :
                      <tt>
                         <xref style="id" target="A1">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>First</title>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <subject id="_">user</subject>
                   <classification>
                      <tag id="_">control-class</tag>
                      <value id="_">Technical</value>
                   </classification>
                   <classification>
                      <tag id="_">priority</tag>
                      <value id="_">P0</value>
                   </classification>
                   <classification>
                      <tag id="_">family</tag>
                      <value id="_">System and Communications Protection</value>
                   </classification>
                   <classification>
                      <tag id="_">family</tag>
                      <value id="_">System and Communications Protocols</value>
                   </classification>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>this</em>
                         .
                      </p>
                   </description>
                   <specification exclude="true" type="tabular">
                      <p id="_">This is the object of the recommendation:</p>
                      <table id="_" unnumbered="true">
                         <tbody>
                            <tr>
                               <td style="text-align:left;">Object</td>
                               <td style="text-align:left;">Value</td>
                               <td style="text-align:left;">Accomplished</td>
                            </tr>
                         </tbody>
                      </table>
                   </specification>
                   <description id="_">
                      <dl>
                         <dt>A</dt>
                         <dd>B</dd>
                         <dt>C</dt>
                         <dd>D</dd>
                      </dl>
                   </description>
                   <measurement-target exclude="false" id="_">
                      <p original-id="_">The measurement target shall be measured as:</p>
                      <formula autonum="1" original-id="B">
                         <stem type="AsciiMath">r/1 = 0</stem>
                      </formula>
                   </measurement-target>
                   <verification exclude="false" id="_">
                      <p original-id="_">The following code will be run for verification:</p>
                      <sourcecode autonum="2" original-id="_">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </sourcecode>
                   </verification>
                   <import exclude="true">
                      <sourcecode id="_" autonum="2">success-response()</sourcecode>
                   </import>
                   <fmt-provision>
                      <table id="A1" type="recommendtest" class="modspec" autonum="1">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="A1">1</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Conformance test</span>
                                  <semx element="autonum" source="A1">1</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="A1">First</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Subject</th>
                               <td>
                                  <semx element="subject" source="_">user</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Prerequisite</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>
                                  <semx element="tag" source="_">Control-class</semx>
                               </th>
                               <td>
                                  <semx element="value" source="_">Technical</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>
                                  <semx element="tag" source="_">Priority</semx>
                               </th>
                               <td>
                                  <semx element="value" source="_">P0</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>
                                  <semx element="tag" source="_">Family</semx>
                               </th>
                               <td>
                                  <semx element="value" source="_">System and Communications Protection</semx>
                                  <br/>
                                  <semx element="value" source="_">System and Communications Protocols</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Description</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>this</em>
                                        .
                                     </p>
                                  </semx>
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
                            <tr id="_">
                               <td colspan="2" id="_">
                                  <semx element="measurement-target" source="_">
                                     <p id="_">The measurement target shall be measured as:</p>
                                     <formula id="B" autonum="1">
                                        <fmt-name>
                                           <span class="fmt-caption-label">
                                              <span class="fmt-autonum-delim">(</span>
                                              1
                                              <span class="fmt-autonum-delim">)</span>
                                           </span>
                                        </fmt-name>
                                        <fmt-xref-label>
                                           <span class="fmt-element-name">Formula</span>
                                           <span class="fmt-autonum-delim">(</span>
                                           <semx element="autonum" source="B">1</semx>
                                           <span class="fmt-autonum-delim">)</span>
                                        </fmt-xref-label>
                                        <fmt-xref-label container="A">
                                           <span class="fmt-xref-container">
                                              <semx element="foreword" source="A">Preface</semx>
                                           </span>
                                           <span class="fmt-comma">,</span>
                                           <span class="fmt-element-name">Formula</span>
                                           <span class="fmt-autonum-delim">(</span>
                                           <semx element="autonum" source="B">1</semx>
                                           <span class="fmt-autonum-delim">)</span>
                                        </fmt-xref-label>
                                        <stem type="AsciiMath">r/1 = 0</stem>
                                     </formula>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <td colspan="2" id="_">
                                  <semx element="verification" source="_">
                                     <p id="_">The following code will be run for verification:</p>
                                     <sourcecode id="_" autonum="2">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </sourcecode>
                                  </semx>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
             </foreword>
          </preface>
       </ogc-standard>
    OUTPUT

    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
  .gsub(%r{^.*<body}m, "<body")
  .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
      </permission>
          </foreword></preface>
          </ogc-standard>
    INPUT
    presxml = <<~OUTPUT
       <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <permission model="ogc" type="abstracttest" autonum="1" original-id="A1">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A1">1</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Abstract test</span>
                      <semx element="autonum" source="A1">1</semx>
                      :
                      <tt>
                         <xref style="id" target="A1">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>First</title>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <subject id="_">user</subject>
                   <classification>
                      <tag id="_">control-class</tag>
                      <value id="_">Technical</value>
                   </classification>
                   <classification>
                      <tag id="_">priority</tag>
                      <value id="_">P0</value>
                   </classification>
                   <classification>
                      <tag id="_">family</tag>
                      <value id="_">System and Communications Protection</value>
                   </classification>
                   <classification>
                      <tag id="_">family</tag>
                      <value id="_">System and Communications Protocols</value>
                   </classification>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>this</em>
                         .
                      </p>
                   </description>
                   <specification exclude="true" type="tabular">
                      <p id="_">This is the object of the recommendation:</p>
                      <table id="_" unnumbered="true">
                         <tbody>
                            <tr>
                               <td style="text-align:left;">Object</td>
                               <td style="text-align:left;">Value</td>
                               <td style="text-align:left;">Accomplished</td>
                            </tr>
                         </tbody>
                      </table>
                   </specification>
                   <description id="_">
                      <dl>
                         <dt>A</dt>
                         <dd>B</dd>
                         <dt>C</dt>
                         <dd>D</dd>
                      </dl>
                   </description>
                   <measurement-target exclude="false" id="_">
                      <p original-id="_">The measurement target shall be measured as:</p>
                      <formula autonum="1" original-id="B">
                         <stem type="AsciiMath">r/1 = 0</stem>
                      </formula>
                   </measurement-target>
                   <verification exclude="false" id="_">
                      <p original-id="_">The following code will be run for verification:</p>
                      <sourcecode autonum="2" original-id="_">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </sourcecode>
                   </verification>
                   <import exclude="true">
                      <sourcecode id="_" autonum="2">success-response()</sourcecode>
                   </import>
                   <fmt-provision>
                      <table id="A1" type="recommendtest" class="modspec" autonum="1">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="A1">1</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Abstract test</span>
                                  <semx element="autonum" source="A1">1</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="A1">First</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Subject</th>
                               <td>
                                  <semx element="subject" source="_">user</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Prerequisite</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>
                                  <semx element="tag" source="_">Control-class</semx>
                               </th>
                               <td>
                                  <semx element="value" source="_">Technical</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>
                                  <semx element="tag" source="_">Priority</semx>
                               </th>
                               <td>
                                  <semx element="value" source="_">P0</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>
                                  <semx element="tag" source="_">Family</semx>
                               </th>
                               <td>
                                  <semx element="value" source="_">System and Communications Protection</semx>
                                  <br/>
                                  <semx element="value" source="_">System and Communications Protocols</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Description</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>this</em>
                                        .
                                     </p>
                                  </semx>
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
                            <tr id="_">
                               <td colspan="2" id="_">
                                  <semx element="measurement-target" source="_">
                                     <p id="_">The measurement target shall be measured as:</p>
                                     <formula id="B" autonum="1">
                                        <fmt-name>
                                           <span class="fmt-caption-label">
                                              <span class="fmt-autonum-delim">(</span>
                                              1
                                              <span class="fmt-autonum-delim">)</span>
                                           </span>
                                        </fmt-name>
                                        <fmt-xref-label>
                                           <span class="fmt-element-name">Formula</span>
                                           <span class="fmt-autonum-delim">(</span>
                                           <semx element="autonum" source="B">1</semx>
                                           <span class="fmt-autonum-delim">)</span>
                                        </fmt-xref-label>
                                        <fmt-xref-label container="A">
                                           <span class="fmt-xref-container">
                                              <semx element="foreword" source="A">Preface</semx>
                                           </span>
                                           <span class="fmt-comma">,</span>
                                           <span class="fmt-element-name">Formula</span>
                                           <span class="fmt-autonum-delim">(</span>
                                           <semx element="autonum" source="B">1</semx>
                                           <span class="fmt-autonum-delim">)</span>
                                        </fmt-xref-label>
                                        <stem type="AsciiMath">r/1 = 0</stem>
                                     </formula>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <td colspan="2" id="_">
                                  <semx element="verification" source="_">
                                     <p id="_">The following code will be run for verification:</p>
                                     <sourcecode id="_" autonum="2">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </sourcecode>
                                  </semx>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
             </foreword>
          </preface>
       </ogc-standard>
    OUTPUT

    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
              .convert("test", input, true)
  .gsub(%r{^.*<body}m, "<body")
  .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
       <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <permission model="ogc" type="class" keep-with-next="true" keep-lines-together="true" autonum="1" original-id="A1">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A1">1</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Permissions class</span>
                      <semx element="autonum" source="A1">1</semx>
                      :
                      <tt>
                         <xref style="id" target="A1">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>First</title>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <inherit id="_">/ss/584/2015/level/2</inherit>
                   <subject id="_">user</subject>
                   <permission model="ogc" autonum="1-1" original-id="A2" id="_">
                      <title>First #1</title>
                      <identifier original-id="_">/ogc/recommendation/wfs/10</identifier>
                   </permission>
                   <requirement model="ogc" autonum="1-1" original-id="A3" id="_">
                      <title>First #2</title>
                      <identifier original-id="_">Requirement 1</identifier>
                   </requirement>
                   <recommendation model="ogc" autonum="1-1" original-id="A4" id="_">
                      <title>First #3</title>
                      <identifier original-id="_">Recommendation 1</identifier>
                   </recommendation>
                   <fmt-provision>
                      <table id="A1" keep-with-next="true" keep-lines-together="true" type="recommendclass" class="modspec" autonum="1">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="A1">1</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Permissions class</span>
                                  <semx element="autonum" source="A1">1</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="A1">First</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Target type</th>
                               <td>
                                  <semx element="subject" source="_">user</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Prerequisites</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                                  <br/>
                                  <semx element="inherit" source="_">/ss/584/2015/level/2</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Provisions</th>
                               <td>
                                  <bookmark id="A2"/>
                                  <span class="fmt-caption-label">
                                     <xref target="B1">
                                        <span class="fmt-element-name">Permission</span>
                                        <semx element="autonum" source="B1">1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="B1">Second</semx>
                                     </xref>
                                  </span>
                                  <br/>
                                   <bookmark id="A3"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A3">
                                        <span class="fmt-element-name">Requirement</span>
                                        <semx element="autonum" source="A3">1-1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A3">First #2</semx>
                                     </xref>
                                  </span>
                                  <br/>
                                  <bookmark id="A4"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A4">
                                        <span class="fmt-element-name">Recommendation</span>
                                        <semx element="autonum" source="A4">1-1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A4">First #3</semx>
                                     </xref>
                                  </span>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
                <permission model="ogc" autonum="1" original-id="B1">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="B1">2</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Permission</span>
                      <semx element="autonum" source="B1">1</semx>
                      :
                      <tt>
                         <xref style="id" target="B1">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/10</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>Second</title>
                   <identifier id="_">/ogc/recommendation/wfs/10</identifier>
                   <fmt-provision>
                      <table id="B1" type="recommend" class="modspec" autonum="2">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="B1">2</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Permission</span>
                                  <semx element="autonum" source="B1">1</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="B1">Second</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">/ogc/recommendation/wfs/10</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Included in</th>
                               <td>
                                  <xref target="A1">
                                     <span class="fmt-element-name">Permissions class</span>
                                     <semx element="autonum" source="A1">1</semx>
                                     <span class="fmt-caption-delim">: </span>
                                     <semx element="title" source="A1">First</semx>
                                  </xref>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
             </foreword>
          </preface>
       </ogc-standard>
    OUTPUT

    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
            .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
      <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <permission model="ogc" type="conformanceclass" autonum="1" original-id="A1">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A1">1</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Conformance class</span>
                      <semx element="autonum" source="A1">1</semx>
                      :
                      <tt>
                         <xref style="id" target="A1">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>First</title>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <inherit id="_">ABC</inherit>
                   <subject id="_">user</subject>
                   <classification>
                      <tag>target</tag>
                      <value id="_">ABC</value>
                   </classification>
                   <classification>
                      <tag>indirect-dependency</tag>
                      <value id="_">
                         <link target="http://www.example.com/"/>
                      </value>
                   </classification>
                   <classification>
                      <tag>indirect-dependency</tag>
                      <value id="_">ABC</value>
                   </classification>
                   <permission model="ogc" autonum="1-1" original-id="A2" id="_">
                      <identifier original-id="_">Permission 1</identifier>
                   </permission>
                   <requirement model="ogc" autonum="1-1" original-id="A3" id="_">
                      <identifier original-id="_">Requirement 1</identifier>
                   </requirement>
                   <recommendation model="ogc" autonum="1-1" original-id="A4" id="_">
                      <identifier original-id="_">Recommendation 1</identifier>
                   </recommendation>
                   <fmt-provision>
                      <table id="A1" type="recommendclass" class="modspec" autonum="1">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="A1">1</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Conformance class</span>
                                  <semx element="autonum" source="A1">1</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="A1">First</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Subject</th>
                               <td>
                                  <semx element="subject" source="_">user</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Requirements class</th>
                               <td>
                                  <xref target="B">
                                     <span class="fmt-element-name">Conformance class</span>
                                     <semx element="autonum" source="B">2</semx>
                                     <span class="fmt-caption-delim">: </span>
                                     <semx element="title" source="B">Second</semx>
                                  </xref>
                               </td>
                            </tr>
                            <tr>
                               <th>Prerequisites</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                                  <br/>
                                  <xref target="B">
                                     <span class="fmt-element-name">Conformance class</span>
                                     <semx element="autonum" source="B">2</semx>
                                     <span class="fmt-caption-delim">: </span>
                                     <semx element="title" source="B">Second</semx>
                                  </xref>
                               </td>
                            </tr>
                            <tr>
                               <th>Indirect prerequisites</th>
                               <td>
                                  <semx element="value" source="_">
                                     <link target="http://www.example.com/"/>
                                  </semx>
                                  <br/>
                                  <xref target="B">
                                     <span class="fmt-element-name">Conformance class</span>
                                     <semx element="autonum" source="B">2</semx>
                                     <span class="fmt-caption-delim">: </span>
                                     <semx element="title" source="B">Second</semx>
                                  </xref>
                               </td>
                            </tr>
                            <tr>
                               <th>Conformance tests</th>
                               <td>
                                  <bookmark id="A2"/>
                                  <span class="fmt-caption-label">
                                     <xref target="B2">
                                        <span class="fmt-element-name">Permission</span>
                                        <semx element="autonum" source="B2">1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="B2">Third</semx>
                                     </xref>
                                  </span>
                                  <br/>
                                  <bookmark id="A3"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A3">
                                        <span class="fmt-element-name">Requirement</span>
                                        <semx element="autonum" source="A3">1-1</semx>
                                     </xref>
                                  </span>
                                  <br/>
                                  <bookmark id="A4"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A4">
                                        <span class="fmt-element-name">Recommendation</span>
                                        <semx element="autonum" source="A4">1-1</semx>
                                     </xref>
                                  </span>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
                <permission model="ogc" type="conformanceclass" autonum="2" original-id="B">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="B">2</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Conformance class</span>
                      <semx element="autonum" source="B">2</semx>
                      :
                      <tt>
                         <xref style="id" target="B">
                            <semx element="identifier" source="_">ABC</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>Second</title>
                   <identifier id="_">ABC</identifier>
                   <fmt-provision>
                      <table id="B" type="recommendclass" class="modspec" autonum="2">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="B">2</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Conformance class</span>
                                  <semx element="autonum" source="B">2</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="B">Second</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">ABC</semx>
                                  </tt>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
                <permission model="ogc" autonum="1" original-id="B2">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="B2">3</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Permission</span>
                      <semx element="autonum" source="B2">1</semx>
                      :
                      <tt>
                         <xref style="id" target="B2">
                            <semx element="identifier" source="_">Permission 1</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>Third</title>
                   <identifier id="_">Permission 1</identifier>
                   <fmt-provision>
                      <table id="B2" type="recommend" class="modspec" autonum="3">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="B2">3</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Permission</span>
                                  <semx element="autonum" source="B2">1</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="B2">Third</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">Permission 1</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Included in</th>
                               <td>
                                  <xref target="A1">
                                     <span class="fmt-element-name">Conformance class</span>
                                     <semx element="autonum" source="A1">1</semx>
                                     <span class="fmt-caption-delim">: </span>
                                     <semx element="title" source="A1">First</semx>
                                  </xref>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
             </foreword>
          </preface>
       </ogc-standard>
    OUTPUT

    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
      <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <bibdata>
             <language current="true">fr</language>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Sommaire</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <permission model="ogc" type="conformanceclass" autonum="1" original-id="A1">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Tableau</span>
                      <semx element="autonum" source="A1">1</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Classe de confirmité</span>
                      <semx element="autonum" source="A1">1</semx>
                       :
                      <tt>
                         <xref style="id" target="A1">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>First</title>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <inherit id="_">ABC</inherit>
                   <subject id="_">user</subject>
                   <classification>
                      <tag>target</tag>
                      <value id="_">ABC</value>
                   </classification>
                   <classification>
                      <tag>indirect-dependency</tag>
                      <value id="_">
                         <link target="http://www.example.com/"/>
                      </value>
                   </classification>
                   <classification>
                      <tag>indirect-dependency</tag>
                      <value id="_">ABC</value>
                   </classification>
                   <permission model="ogc" autonum="1-1" original-id="A2" id="_">
                      <identifier original-id="_">Permission 1</identifier>
                   </permission>
                   <requirement model="ogc" autonum="1-1" original-id="A3" id="_">
                      <identifier original-id="_">Requirement 1</identifier>
                   </requirement>
                   <recommendation model="ogc" autonum="1-1" original-id="A4" id="_">
                      <identifier original-id="_">Recommendation 1</identifier>
                   </recommendation>
                   <fmt-provision>
                      <table id="A1" type="recommendclass" class="modspec" autonum="1">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Tableau</span>
                               <semx element="autonum" source="A1">1</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Classe de confirmité</span>
                                  <semx element="autonum" source="A1">1</semx>
                                  <span class="fmt-caption-delim"> : </span>
                                  <semx element="title" source="A1">First</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifiant</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Sujet</th>
                               <td>
                                  <semx element="subject" source="_">user</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Classe d’exigences</th>
                               <td>
                                  <xref target="B">
                                     <span class="fmt-element-name">Classe de confirmité</span>
                                     <semx element="autonum" source="B">2</semx>
                                     <span class="fmt-caption-delim"> : </span>
                                     <semx element="title" source="B">Second</semx>
                                  </xref>
                               </td>
                            </tr>
                            <tr>
                               <th>Prérequis</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                                  <br/>
                                  <xref target="B">
                                     <span class="fmt-element-name">Classe de confirmité</span>
                                     <semx element="autonum" source="B">2</semx>
                                     <span class="fmt-caption-delim"> : </span>
                                     <semx element="title" source="B">Second</semx>
                                  </xref>
                               </td>
                            </tr>
                            <tr>
                               <th>Prérequis indirect</th>
                               <td>
                                  <semx element="value" source="_">
                                     <link target="http://www.example.com/"/>
                                  </semx>
                                  <br/>
                                  <xref target="B">
                                     <span class="fmt-element-name">Classe de confirmité</span>
                                     <semx element="autonum" source="B">2</semx>
                                     <span class="fmt-caption-delim"> : </span>
                                     <semx element="title" source="B">Second</semx>
                                  </xref>
                               </td>
                            </tr>
                            <tr>
                               <th>Tests de conformité</th>
                               <td>
                                   <bookmark id="A2"/>
                                  <span class="fmt-caption-label">
                                     <xref target="B2">
                                        <span class="fmt-element-name">Autorisation</span>
                                        <semx element="autonum" source="B2">1</semx>
                                        <span class="fmt-caption-delim"> : </span>
                                        <semx element="title" source="B2">Third</semx>
                                     </xref>
                                  </span>
                                  <br/>
                                  <bookmark id="A3"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A3">
                                        <span class="fmt-element-name">Exigence</span>
                                        <semx element="autonum" source="A3">1-1</semx>
                                     </xref>
                                  </span>
                                  <br/>
                                  <bookmark id="A4"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A4">
                                        <span class="fmt-element-name">Recommandation</span>
                                        <semx element="autonum" source="A4">1-1</semx>
                                     </xref>
                                  </span>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
                <permission model="ogc" type="conformanceclass" autonum="2" original-id="B">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Tableau</span>
                      <semx element="autonum" source="B">2</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Classe de confirmité</span>
                      <semx element="autonum" source="B">2</semx>
                       :
                      <tt>
                         <xref style="id" target="B">
                            <semx element="identifier" source="_">ABC</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>Second</title>
                   <identifier id="_">ABC</identifier>
                   <fmt-provision>
                      <table id="B" type="recommendclass" class="modspec" autonum="2">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Tableau</span>
                               <semx element="autonum" source="B">2</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Classe de confirmité</span>
                                  <semx element="autonum" source="B">2</semx>
                                  <span class="fmt-caption-delim"> : </span>
                                  <semx element="title" source="B">Second</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifiant</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">ABC</semx>
                                  </tt>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
                <permission model="ogc" autonum="1" original-id="B2">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Tableau</span>
                      <semx element="autonum" source="B2">3</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Autorisation</span>
                      <semx element="autonum" source="B2">1</semx>
                       :
                      <tt>
                         <xref style="id" target="B2">
                            <semx element="identifier" source="_">Permission 1</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>Third</title>
                   <identifier id="_">Permission 1</identifier>
                   <fmt-provision>
                      <table id="B2" type="recommend" class="modspec" autonum="3">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Tableau</span>
                               <semx element="autonum" source="B2">3</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Autorisation</span>
                                  <semx element="autonum" source="B2">1</semx>
                                  <span class="fmt-caption-delim"> : </span>
                                  <semx element="title" source="B2">Third</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifiant</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">Permission 1</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Inclus dans</th>
                               <td>
                                  <xref target="A1">
                                     <span class="fmt-element-name">Classe de confirmité</span>
                                     <semx element="autonum" source="A1">1</semx>
                                     <span class="fmt-caption-delim"> : </span>
                                     <semx element="title" source="A1">First</semx>
                                  </xref>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
             </foreword>
          </preface>
       </ogc-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
       .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")
       .gsub(%r{^.*<body}m, "<body")
       .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
     <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <requirement model="ogc" type="class" autonum="1" original-id="A1">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A1">1</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Requirements class</span>
                      <semx element="autonum" source="A1">1</semx>
                      :
                      <tt>
                         <xref style="id" target="A1">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>First</title>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <inherit id="_">/ss/584/2015/level/2</inherit>
                   <subject id="_">user</subject>
                   <permission model="ogc" autonum="1-1" original-id="A2" id="_">
                      <title>First #1</title>
                      <identifier original-id="_">Permission 1</identifier>
                   </permission>
                   <fmt-provision>
                      <table id="A1" type="recommendclass" class="modspec" autonum="1">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="A1">1</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Requirements class</span>
                                  <semx element="autonum" source="A1">1</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="A1">First</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Target type</th>
                               <td>
                                  <semx element="subject" source="_">user</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Prerequisites</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                                  <br/>
                                  <semx element="inherit" source="_">/ss/584/2015/level/2</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Provision</th>
                               <td>
                                  <bookmark id="A2"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A5">
                                        <span class="fmt-element-name">Permission</span>
                                        <semx element="autonum" source="A5">1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A5">Second</semx>
                                     </xref>
                                  </span>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </requirement>
                <permission model="ogc" autonum="1" original-id="A5">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A5">2</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Permission</span>
                      <semx element="autonum" source="A5">1</semx>
                      :
                      <tt>
                         <xref style="id" target="A5">
                            <semx element="identifier" source="_">Permission 1</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>Second</title>
                   <identifier id="_">Permission 1</identifier>
                   <fmt-provision>
                      <table id="A5" type="recommend" class="modspec" autonum="2">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="A5">2</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Permission</span>
                                  <semx element="autonum" source="A5">1</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="A5">Second</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">Permission 1</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Included in</th>
                               <td>
                                  <xref target="A1">
                                     <span class="fmt-element-name">Requirements class</span>
                                     <semx element="autonum" source="A1">1</semx>
                                     <span class="fmt-caption-delim">: </span>
                                     <semx element="title" source="A1">First</semx>
                                  </xref>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
             </foreword>
          </preface>
       </ogc-standard>
    OUTPUT

    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
      <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <recommendation model="ogc" type="class" autonum="1" original-id="A1">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A1">1</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Recommendations class</span>
                      <semx element="autonum" source="A1">1</semx>
                      :
                      <tt>
                         <xref style="id" target="A1">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>First</title>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <inherit id="_">/ss/584/2015/level/2</inherit>
                   <subject id="_">user</subject>
                   <permission model="ogc" autonum="1-1" original-id="A2" id="_">
                      <title>First #1</title>
                      <identifier original-id="_">Permission 1</identifier>
                   </permission>
                   <requirement model="ogc" autonum="1-1" original-id="A3" id="_">
                      <title>First #2</title>
                      <identifier original-id="_">Requirement 1</identifier>
                   </requirement>
                   <recommendation model="ogc" autonum="1-1" original-id="A4" id="_">
                      <title>First #3</title>
                      <identifier original-id="_">Recommendation 1</identifier>
                   </recommendation>
                   <fmt-provision>
                      <table id="A1" type="recommendclass" class="modspec" autonum="1">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="A1">1</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Recommendations class</span>
                                  <semx element="autonum" source="A1">1</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="A1">First</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Target type</th>
                               <td>
                                  <semx element="subject" source="_">user</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Prerequisites</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                                  <br/>
                                  <semx element="inherit" source="_">/ss/584/2015/level/2</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Provisions</th>
                               <td>
                                  <bookmark id="A2"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A2">
                                        <span class="fmt-element-name">Permission</span>
                                        <semx element="autonum" source="A2">1-1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A2">First #1</semx>
                                     </xref>
                                  </span>
                                  <br/>
                                  <bookmark id="A3"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A3">
                                        <span class="fmt-element-name">Requirement</span>
                                        <semx element="autonum" source="A3">1-1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A3">First #2</semx>
                                     </xref>
                                  </span>
                                  <br/>
                                  <bookmark id="A4"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A4">
                                        <span class="fmt-element-name">Recommendation</span>
                                        <semx element="autonum" source="A4">1-1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A4">First #3</semx>
                                     </xref>
                                  </span>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </recommendation>
             </foreword>
          </preface>
       </ogc-standard>
    OUTPUT

    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
      <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A0" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <requirement model="ogc" unnumbered="true" original-id="A">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A">(??)</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Requirement</span>
                      <semx element="autonum" source="A">(??)</semx>
                      :
                      <tt>
                         <xref style="id" target="A">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>A New Requirement</title>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <subject id="_">user</subject>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>this</em>
                         .
                      </p>
                   </description>
                   <specification exclude="true" type="tabular" keep-with-next="true" keep-lines-together="true">
                      <p id="_">This is the object of the recommendation:</p>
                      <table id="_" unnumbered="true">
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
                   <description id="_">
                      <p original-id="_">As for the measurement targets,</p>
                   </description>
                   <measurement-target exclude="false" id="_">
                      <p original-id="_">The measurement target shall be measured as:</p>
                      <formula autonum="1" original-id="B">
                         <stem type="AsciiMath">r/1 = 0</stem>
                      </formula>
                   </measurement-target>
                   <verification exclude="false" id="_">
                      <p original-id="_">The following code will be run for verification:</p>
                      <sourcecode autonum="2" original-id="_">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </sourcecode>
                   </verification>
                   <import exclude="true">
                      <sourcecode id="_" autonum="2">success-response()</sourcecode>
                   </import>
                   <fmt-provision>
                      <table id="A" unnumbered="true" type="recommend" class="modspec">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Requirement</span>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="A">A New Requirement</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Subject</th>
                               <td>
                                  <semx element="subject" source="_">user</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Prerequisite</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Statements</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>this</em>
                                        .
                                     </p>
                                  </semx>
                                  <br/>
                                  <semx element="description" source="_">
                                     <p id="_">As for the measurement targets,</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <td colspan="2" id="_">
                                  <semx element="measurement-target" source="_">
                                     <p id="_">The measurement target shall be measured as:</p>
                                     <formula id="B" autonum="1">
                                        <fmt-name>
                                           <span class="fmt-caption-label">
                                              <span class="fmt-autonum-delim">(</span>
                                              1
                                              <span class="fmt-autonum-delim">)</span>
                                           </span>
                                        </fmt-name>
                                        <fmt-xref-label>
                                           <span class="fmt-element-name">Formula</span>
                                           <span class="fmt-autonum-delim">(</span>
                                           <semx element="autonum" source="B">1</semx>
                                           <span class="fmt-autonum-delim">)</span>
                                        </fmt-xref-label>
                                        <fmt-xref-label container="A0">
                                           <span class="fmt-xref-container">
                                              <semx element="foreword" source="A0">Preface</semx>
                                           </span>
                                           <span class="fmt-comma">,</span>
                                           <span class="fmt-element-name">Formula</span>
                                           <span class="fmt-autonum-delim">(</span>
                                           <semx element="autonum" source="B">1</semx>
                                           <span class="fmt-autonum-delim">)</span>
                                        </fmt-xref-label>
                                        <stem type="AsciiMath">r/1 = 0</stem>
                                     </formula>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <td colspan="2" id="_">
                                  <semx element="verification" source="_">
                                     <p id="_">The following code will be run for verification:</p>
                                     <sourcecode id="_" autonum="2">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </sourcecode>
                                  </semx>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </requirement>
             </foreword>
          </preface>
       </ogc-standard>
    OUTPUT

    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes recommendations" do
    input = <<~INPUT
      <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <recommendation model="ogc" id="B">
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
          <formula id="C">
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
       <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <recommendation model="ogc" autonum="1" original-id="B">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="B">1</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Recommendation</span>
                      <semx element="autonum" source="B">1</semx>
                      :
                      <tt>
                         <xref style="id" target="B">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <title>First</title>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <subject id="_">user</subject>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>this</em>
                         .
                      </p>
                   </description>
                   <specification exclude="true" type="tabular">
                      <p id="_">This is the object of the recommendation:</p>
                      <table id="_" unnumbered="true">
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
                   <description id="_">
                      <p original-id="_">As for the measurement targets,</p>
                   </description>
                   <measurement-target exclude="false" id="_">
                      <p original-id="_">The measurement target shall be measured as:</p>
                      <formula autonum="1" original-id="C">
                         <stem type="AsciiMath">r/1 = 0</stem>
                      </formula>
                   </measurement-target>
                   <verification exclude="false" id="_">
                      <p original-id="_">The following code will be run for verification:</p>
                      <sourcecode autonum="2" original-id="_">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </sourcecode>
                   </verification>
                   <import exclude="true">
                      <sourcecode id="_" autonum="2">success-response()</sourcecode>
                   </import>
                   <fmt-provision>
                      <table id="B" type="recommend" class="modspec" autonum="1">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="B">1</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Recommendation</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-caption-delim">: </span>
                                  <semx element="title" source="B">First</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr>
                               <th>Identifier</th>
                               <td>
                                  <tt>
                                     <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                                  </tt>
                               </td>
                            </tr>
                            <tr>
                               <th>Subject</th>
                               <td>
                                  <semx element="subject" source="_">user</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Prerequisite</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Statements</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>this</em>
                                        .
                                     </p>
                                  </semx>
                                  <br/>
                                  <semx element="description" source="_">
                                     <p id="_">As for the measurement targets,</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <td colspan="2" id="_">
                                  <semx element="measurement-target" source="_">
                                     <p id="_">The measurement target shall be measured as:</p>
                                     <formula id="C" autonum="1">
                                        <fmt-name>
                                           <span class="fmt-caption-label">
                                              <span class="fmt-autonum-delim">(</span>
                                              1
                                              <span class="fmt-autonum-delim">)</span>
                                           </span>
                                        </fmt-name>
                                        <fmt-xref-label>
                                           <span class="fmt-element-name">Formula</span>
                                           <span class="fmt-autonum-delim">(</span>
                                           <semx element="autonum" source="C">1</semx>
                                           <span class="fmt-autonum-delim">)</span>
                                        </fmt-xref-label>
                                        <fmt-xref-label container="A">
                                           <span class="fmt-xref-container">
                                              <semx element="foreword" source="A">Preface</semx>
                                           </span>
                                           <span class="fmt-comma">,</span>
                                           <span class="fmt-element-name">Formula</span>
                                           <span class="fmt-autonum-delim">(</span>
                                           <semx element="autonum" source="C">1</semx>
                                           <span class="fmt-autonum-delim">)</span>
                                        </fmt-xref-label>
                                        <stem type="AsciiMath">r/1 = 0</stem>
                                     </formula>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <td colspan="2" id="_">
                                  <semx element="verification" source="_">
                                     <p id="_">The following code will be run for verification:</p>
                                     <sourcecode id="_" autonum="2">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </sourcecode>
                                  </semx>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </recommendation>
             </foreword>
          </preface>
       </ogc-standard>
    OUTPUT

    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end
end
