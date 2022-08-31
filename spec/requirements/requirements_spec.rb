require "spec_helper"

RSpec.describe Metanorma::Iso::Requirements::Modspec do
  it "processes permissions" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <permission model="ogc" id="A1">
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
      <bibitem id="rfc2616" type="standard"> <fetched>2020-03-27</fetched> <title format="text/plain" language="en" script="Latn">Hypertext Transfer Protocol — HTTP/1.1</title> <uri type="xml">https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.2616.xml</uri> <uri type="src">https://www.rfc-editor.org/info/rfc2616</uri> <docidentifier type="IETF">RFC 2616</docidentifier> <docidentifier type="IETF" scope="anchor">RFC2616</docidentifier> <docidentifier type="DOI">10.17487/RFC2616</docidentifier> <date type="published">  <on>1999-06</on> </date> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">R. Fielding</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">J. Gettys</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">J. Mogul</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">H. Frystyk</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">L. Masinter</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">P. Leach</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <contributor>  <role type="author"/>  <person>   <name>    <completename language="en">T. Berners-Lee</completename>   </name>   <affiliation>    <organization>     <name>IETF</name>     <abbreviation>IETF</abbreviation>    </organization>   </affiliation>  </person> </contributor> <language>en</language> <script>Latn</script> <abstract format="text/plain" language="en" script="Latn">HTTP has been in use by the World-Wide Web global information initiative since 1990. This specification defines the protocol referred to as “HTTP/1.1”, and is an update to RFC 2068. [STANDARDS-TRACK]</abstract> <series type="main">  <title format="text/plain" language="en" script="Latn">RFC</title>  <number>2616</number> </series> <place>Fremont, CA</place></bibitem>
      </references></bibliography>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
      <ogc-standard xmlns="https://standards.opengeospatial.org/document" type="presentation">
                <preface><foreword id="A" displayorder="1"><title>Preface</title>
                <table id="A1" class="modspec" type="recommend">
            <thead><tr><th scope="colgroup" colspan="2"><p class="RecommendationTitle">Permission 1</p></th></tr></thead>
            <tbody>
              <tr><td>Identifier</td><td><tt>/ogc/recommendation/wfs/2</tt></td></tr>
              <tr><td>Subject</td><td>user</td></tr><tr><td>Dependency</td><td>/ss/584/2015/level/1</td></tr><tr><td>Dependency</td><td><eref type="inline" bibitemid="rfc2616" citeas="RFC 2616">RFC 2616 (HTTP/1.1)</eref></td></tr>
            <tr>
        <td>Control-class</td>
        <td>Technical</td>
      </tr>
      <tr>
        <td>Priority</td>
        <td>P0</td>
      </tr>
      <tr>
        <td>Family</td>
        <td>System and Communications Protection</td>
      </tr>
      <tr>
        <td>Family</td>
        <td>System and Communications Protocols</td>
      </tr>
      <tr>
        <td colspan='2'>
          <p id='_'>
            I recommend
            <em>this</em>
            .
          </p>
        </td>
      </tr>
      <tr>
        <td>A</td>
        <td>B</td>
      </tr>
      <tr>
        <td>C</td>
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
                   <td>Test purpose</td>
                   <td>
                     <p>TEST PURPOSE</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Test method</td>
                   <td>
                     <p>TEST METHOD</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Conditions</td>
                   <td>
                     <p>CONDITIONS</p>
                   </td>
                 </tr>
                 <tr>
                   <td>A</td>
                   <td>
                     <p>FIRST PART</p>
                   </td>
                 </tr>
                 <tr>
                   <td>B</td>
                   <td>
                     <p>SECOND PART</p>
                   </td>
                 </tr>
                 <tr>
                   <td>C</td>
                   <td>
                     <p>THIRD PART</p>
                   </td>
                 </tr>
                 <tr>
                  <td>Reference</td>
                  <td>
                    <p>REFERENCE PART</p>
                  </td>
                </tr>
                <tr>
                  <td>Panda GHz express</td>
                  <td>
                    <p>PANDA PART</p>
                  </td>
                </tr>
              </tbody></table>
                </foreword></preface>
                <bibliography><references id="_bibliography" obligation="informative" normative="false" displayorder="2">
            <title depth="1">Bibliography</title>
            <bibitem id="rfc2616" type="standard">
              <formattedref>R. FIELDING, J. GETTYS, J. MOGUL, H. FRYSTYK, L. MASINTER, P. LEACH and T. BERNERS-LEE.
               <em>Hypertext Transfer Protocol&#x2009;&#x2014;&#x2009;HTTP/1.1</em>.
              In: RFC. June 1999. Fremont, CA. <link target='https://www.rfc-editor.org/info/rfc2616'>https://www.rfc-editor.org/info/rfc2616</link>.</formattedref>
                        <uri type='xml'>https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.2616.xml</uri>
                <uri type='src'>https://www.rfc-editor.org/info/rfc2616</uri>
                <docidentifier type='metanorma-ordinal'>[1]</docidentifier>
                <docidentifier type='IETF'>IETF RFC 2616</docidentifier>
                <docidentifier type='IETF' scope='anchor'>IETF RFC2616</docidentifier>
                <docidentifier type='DOI'>DOI 10.17487/RFC2616</docidentifier>
          </bibitem>
            </references></bibliography>
                </ogc-standard>
    OUTPUT

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes permission verifications" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface>
              <foreword id="A"><title>Preface</title>
          <permission model="ogc" id="A1" type="verification">
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
           <foreword id='A' displayorder='1'>
             <title>Preface</title>
             <table id='A1' class='modspec' type='recommendtest'>
               <thead>
                 <tr>
                   <th scope='colgroup' colspan='2'>
                     <p class='RecommendationTestTitle'>Permission test 1</p>
                   </th>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                <td>Identifier</td>
                <td><tt>/ogc/recommendation/wfs/2</tt></td>
                </tr>
                 <tr>
                   <td>Subject</td>
                   <td>user</td>
                 </tr>
                 <tr>
                   <td>Dependency</td>
                   <td>/ss/584/2015/level/1</td>
                 </tr>
                 <tr>
                   <td>Control-class</td>
                   <td>Technical</td>
                 </tr>
                 <tr>
                   <td>Priority</td>
                   <td>P0</td>
                 </tr>
                 <tr>
                   <td>Family</td>
                   <td>System and Communications Protection</td>
                 </tr>
                 <tr>
                   <td>Family</td>
                   <td>System and Communications Protocols</td>
                 </tr>
                 <tr>
                   <td colspan='2'>
                     <p id='_'>
                       I recommend#{' '}
                       <em>this</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr>
                   <td>A</td>
                   <td>B</td>
                 </tr>
                 <tr>
                   <td>C</td>
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

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
  .gsub(%r{^.*<body}m, "<body")
  .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes abstract tests" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface>
              <foreword id="A"><title>Preface</title>
          <permission model="ogc" id="A1" type="abstracttest">
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
              <foreword id="A" displayorder="1"><title>Preface</title>
          <table id="A1" type="recommendtest" class="modspec">
      <thead><tr><th scope="colgroup" colspan="2"><p class="RecommendationTestTitle">Abstract test 1</p></th></tr></thead>
        <tbody>
          <tr><td>Identifier</td><td><tt>/ogc/recommendation/wfs/2</tt></td></tr>
        <tr><td>Subject</td><td>user</td></tr><tr><td>Dependency</td><td>/ss/584/2015/level/1</td></tr><tr><td>Control-class</td><td>Technical</td></tr><tr><td>Priority</td><td>P0</td></tr><tr><td>Family</td><td>System and Communications Protection</td></tr><tr><td>Family</td><td>System and Communications Protocols</td></tr>

        <tr><td colspan="2">
          <p id="_">I recommend <em>this</em>.</p>
        </td></tr><tr><td>A</td><td>B</td></tr><tr><td>C</td><td>D</td></tr><tr><td colspan="2">
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

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
              .convert("test", input, true)
  .gsub(%r{^.*<body}m, "<body")
  .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes permission classes" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <permission model="ogc" id="A1" type="class" keep-with-next="true" keep-lines-together="true">
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <inherit>/ss/584/2015/level/2</inherit>
        <subject>user</subject>
        <permission model="ogc" id="A2">
        <identifier>/ogc/recommendation/wfs/10</identifier>
        </permission>
        <requirement model="ogc" id="A3">
        <identifier>Requirement 1</identifier>
        </requirement>
        <recommendation model="ogc" id="A4">
        <identifier>Recommendation 1</identifier>
        </recommendation>
      </permission>
      <permission model="ogc" id="B1">
        <identifier>/ogc/recommendation/wfs/10</identifier>
      </permission>
          </foreword></preface>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
          <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
        <preface>
          <foreword id='A' displayorder='1'>
            <title>Preface</title>
            <table id='A1' keep-with-next='true' keep-lines-together='true' class='modspec' type='recommendclass'>
              <thead>
                <tr>
                  <th scope='colgroup' colspan='2'>
                    <p class='RecommendationTitle'>Permissions class 1</p>
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Identifier</td>
                  <td><tt>/ogc/recommendation/wfs/2</tt></td>
                </tr>
                <tr>
                  <td>Target type</td>
                  <td>user</td>
                </tr>
                <tr>
                  <td>Dependency</td>
                  <td>/ss/584/2015/level/1</td>
                </tr>
                <tr>
                  <td>Dependency</td>
                  <td>/ss/584/2015/level/2</td>
                </tr>
                <tr>
                  <td>Permission</td>
                  <td>
                    <xref target='B1'>
                      Permission 1:
                      <tt>/ogc/recommendation/wfs/10</tt>
                    </xref>
                  </td>
                </tr>
                <tr>
                  <td>Requirement</td>
                  <td>
                    <xref target='A3'>
                      Requirement 1-1:
                      <tt>Requirement 1</tt>
                    </xref>
                  </td>
                </tr>
                <tr>
                  <td>Recommendation</td>
                  <td>
                    <xref target='A4'>
                      Recommendation 1-1:
                      <tt>Recommendation 1</tt>
                    </xref>
                  </td>
                </tr>
              </tbody>
            </table>
            <table id='B1' class='modspec' type='recommend'>
              <thead>
                <tr>
                  <th scope='colgroup' colspan='2'>
                    <p class='RecommendationTitle'>Permission 1</p>
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Identifier</td>
                  <td><tt>/ogc/recommendation/wfs/10</tt></td>
                </tr>
                <tr>
                  <td>Included in</td>
                  <td>
                    <xref target='A1'>
                      Permissions class 1:
                      <tt>/ogc/recommendation/wfs/2</tt>
                    </xref>
                  </td>
                </tr>
              </tbody>
            </table>
          </foreword>
        </preface>
      </ogc-standard>
    OUTPUT

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
            .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes conformance classes" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <permission model="ogc" id="A1" type="conformanceclass">
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
          <identifier>ABC</identifier>
          </permission>
          <permission model="ogc" id="B2">
        <identifier>Permission 1</identifier>
        </permission>
          </foreword></preface>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
      <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
         <preface>
           <foreword id='A' displayorder='1'>
             <title>Preface</title>
             <table id='A1' class='modspec' type='recommendclass'>
               <thead>
                 <tr>
                   <th scope='colgroup' colspan='2'>
                     <p class='RecommendationTitle'>Conformance class 1</p>
                   </th>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                   <td>Identifier</td>
                   <td><tt>/ogc/recommendation/wfs/2</tt></td>
                 </tr>
                 <tr>
                   <td>Subject</td>
                   <td>user</td>
                 </tr>
                 <tr>
                   <td>Requirements class</td>
                   <td>
                     <xref target='B'>ABC</xref>
                   </td>
                 </tr>
                 <tr>
                   <td>Dependency</td>
                   <td>/ss/584/2015/level/1</td>
                 </tr>
                 <tr>
                   <td>Dependency</td>
                   <td>
                     <xref target='B'>ABC</xref>
                   </td>
                 </tr>
                 <tr>
                   <td>Indirect Dependency</td>
                   <td>
                     <link target='http://www.example.com/'/>
                   </td>
                 </tr>
                 <tr>
                   <td>Indirect Dependency</td>
                   <td>
                     <xref target='B'>ABC</xref>
                   </td>
                 </tr>
                 <tr>
                   <td>Permission</td>
                   <td>
                     <xref target='B2'>
                       Permission 1:
                       <tt>Permission 1</tt>
                     </xref>
                   </td>
                 </tr>
                 <tr>
                   <td>Requirement</td>
                   <td>
                     <xref target='A3'>
                       Requirement 1-1:
                       <tt>Requirement 1</tt>
                     </xref>
                   </td>
                 </tr>
                 <tr>
                   <td>Recommendation</td>
                   <td>
                     <xref target='A4'>
                       Recommendation 1-1:
                       <tt>Recommendation 1</tt>
                     </xref>
                   </td>
                 </tr>
               </tbody>
             </table>
             <table id='B' class='modspec' type='recommendclass'>
               <thead>
                 <tr>
                   <th scope='colgroup' colspan='2'>
                     <p class='RecommendationTitle'>Conformance class 2</p>
                   </th>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                   <td>Identifier</td>
                   <td><tt>ABC</tt></td>
                 </tr>
               </tbody>
             </table>
             <table id='B2' class='modspec' type='recommend'>
        <thead>
          <tr>
            <th scope='colgroup' colspan='2'>
              <p class='RecommendationTitle'>Permission 1</p>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Identifier</td>
            <td><tt>Permission 1</tt></td>
          </tr>
          <tr>
            <td>Included in</td>
            <td>
              <xref target='A1'>
                Conformance class 1:
                <tt>/ogc/recommendation/wfs/2</tt>
              </xref>
            </td>
          </tr>
        </tbody>
      </table>
           </foreword>
         </preface>
       </ogc-standard>
    OUTPUT

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes conformance classes in French" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
              <bibdata><language>fr</language></bibdata>
          <preface><foreword id="A"><title>Preface</title>
          <permission model="ogc" id="A1" type="conformanceclass">
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
          <identifier>ABC</identifier>
          </permission>
          <permission model="ogc" id="B2">
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
           <foreword id='A' displayorder='1'>
             <title>Preface</title>
             <table id='A1' class='modspec' type='recommendclass'>
               <thead>
                 <tr>
                   <th scope='colgroup' colspan='2'>
                     <p class='RecommendationTitle'>Classe de confirmit&#xE9; 1</p>
                   </th>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                   <td>Identifiant</td>
                   <td><tt>/ogc/recommendation/wfs/2</tt></td>
                 </tr>
                 <tr>
                   <td>Sujet</td>
                   <td>user</td>
                 </tr>
                 <tr>
                   <td>Classe d&#x2019;exigences</td>
                   <td>
                     <xref target='B'>ABC</xref>
                   </td>
                 </tr>
                 <tr>
                   <td>D&#xE9;pendance</td>
                   <td>/ss/584/2015/level/1</td>
                 </tr>
                 <tr>
                   <td>D&#xE9;pendance</td>
                   <td>
                     <xref target='B'>ABC</xref>
                   </td>
                 </tr>
                 <tr>
                   <td>D&#xE9;pendance indirecte</td>
                   <td>
                     <link target='http://www.example.com/'/>
                   </td>
                 </tr>
                 <tr>
                   <td>D&#xE9;pendance indirecte</td>
                   <td>
                     <xref target='B'>ABC</xref>
                   </td>
                 </tr>
                 <tr>
                   <td>Autorisation</td>
                   <td>
                     <xref target='B2'>
                       Autorisation 1:
                       <tt>Permission 1</tt>
                     </xref>
                   </td>
                 </tr>
                 <tr>
                   <td>Exigence</td>
                   <td>
                     <xref target='A3'>
                       Exigence 1-1:
                       <tt>Requirement 1</tt>
                     </xref>
                   </td>
                 </tr>
                 <tr>
                   <td>Recommandation</td>
                   <td>
                     <xref target='A4'>
                       Recommandation 1-1:
                       <tt>Recommendation 1</tt>
                     </xref>
                   </td>
                 </tr>
               </tbody>
             </table>
             <table id='B' class='modspec' type='recommendclass'>
               <thead>
                 <tr>
                   <th scope='colgroup' colspan='2'>
                     <p class='RecommendationTitle'>Classe de confirmit&#xE9; 2</p>
                   </th>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                   <td>Identifiant</td>
                   <td><tt>ABC</tt></td>
                 </tr>
               </tbody>
             </table>
             <table id='B2' class='modspec' type='recommend'>
        <thead>
          <tr>
            <th scope='colgroup' colspan='2'>
              <p class='RecommendationTitle'>Autorisation 1</p>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Identifiant</td>
            <td><tt>Permission 1</tt></td>
          </tr>
          <tr>
            <td>Inclus dans</td>
            <td>
              <xref target='A1'>
                 Classe de confirmit&#xE9; 1:
                <tt>/ogc/recommendation/wfs/2</tt>
              </xref>
            </td>
          </tr>
        </tbody>
      </table>
           </foreword>
         </preface>
       </ogc-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
       .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")
       .gsub(%r{^.*<body}m, "<body")
       .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes requirement classes" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <requirement model="ogc" id="A1" type="class">
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <inherit>/ss/584/2015/level/2</inherit>
        <subject>user</subject>
        <permission model="ogc" id="A2">
        <identifier>Permission 1</identifier>
        </permission>
        <requirement model="ogc" id="A3">
        <identifier>Requirement 1</identifier>
        </requirement>
        <recommendation model="ogc" id="A4">
        <identifier>Recommendation 1</identifier>
        </recommendation>
      </requirement>
      <permission model="ogc" id="A5">
        <identifier>Permission 1</identifier>
        </permission>
          </foreword></preface>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
      <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
         <preface>
           <foreword id='A' displayorder='1'>
             <title>Preface</title>
             <table id='A1' class='modspec' type='recommendclass'>
               <thead>
                 <tr>
                   <th scope='colgroup' colspan='2'>
                     <p class='RecommendationTitle'>Requirements class 1</p>
                   </th>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                   <td>Identifier</td>
                   <td><tt>/ogc/recommendation/wfs/2</tt></td>
                 </tr>
                 <tr>
                   <td>Target type</td>
                   <td>user</td>
                 </tr>
                 <tr>
                   <td>Dependency</td>
                   <td>/ss/584/2015/level/1</td>
                 </tr>
                 <tr>
                   <td>Dependency</td>
                   <td>/ss/584/2015/level/2</td>
                 </tr>
                 <tr>
                   <td>Permission</td>
                   <td>
                     <xref target='A5'>
                       Permission 1:
                       <tt>Permission 1</tt>
                     </xref>
                   </td>
                 </tr>
                 <tr>
                   <td>Requirement</td>
                   <td>
                     <xref target='A3'>
                       Requirement 1-1:
                       <tt>Requirement 1</tt>
                     </xref>
                   </td>
                 </tr>
                 <tr>
                   <td>Recommendation</td>
                   <td>
                     <xref target='A4'>
                       Recommendation 1-1:
                       <tt>Recommendation 1</tt>
                     </xref>
                   </td>
                 </tr>
               </tbody>
             </table>
             <table id='A5' class='modspec' type='recommend'>
               <thead>
                 <tr>
                   <th scope='colgroup' colspan='2'>
                     <p class='RecommendationTitle'>Permission 1</p>
                   </th>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                   <td>Identifier</td>
                   <td><tt>Permission 1</tt></td>
                 </tr>
                 <tr>
                   <td>Included in</td>
                   <td>
                     <xref target='A1'>
                       Requirements class 1:
                       <tt>/ogc/recommendation/wfs/2</tt>
                     </xref>
                   </td>
                 </tr>
               </tbody>
             </table>
           </foreword>
         </preface>
       </ogc-standard>
    OUTPUT

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes recommendation classes" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <recommendation model="ogc" id="A1" type="class">
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <inherit>/ss/584/2015/level/2</inherit>
        <subject>user</subject>
        <permission model="ogc" id="A2">
        <identifier>Permission 1</identifier>
        </permission>
        <requirement model="ogc" id="A3">
        <identifier>Requirement 1</identifier>
        </requirement>
        <recommendation model="ogc" id="A4">
        <identifier>Recommendation 1</identifier>
        </recommendation>
      </recommendation>
          </foreword></preface>
          </ogc-standard>
    INPUT

    presxml = <<~OUTPUT
          <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
        <preface>
          <foreword id='A' displayorder='1'>
            <title>Preface</title>
            <table id='A1' class='modspec' type='recommendclass'>
              <thead>
                <tr>
                  <th scope='colgroup' colspan='2'>
                    <p class='RecommendationTitle'>Recommendations class 1</p>
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Identifier</td>
                  <td><tt>/ogc/recommendation/wfs/2</tt></td>
                </tr>
                <tr>
                  <td>Target type</td>
                  <td>user</td>
                </tr>
                <tr>
                  <td>Dependency</td>
                  <td>/ss/584/2015/level/1</td>
                </tr>
                <tr>
                  <td>Dependency</td>
                  <td>/ss/584/2015/level/2</td>
                </tr>
                <tr>
                  <td>Permission</td>
                  <td>
                    <xref target='A2'>
                      Permission 1-1:
                      <tt>Permission 1</tt>
                    </xref>
                  </td>
                </tr>
                <tr>
                  <td>Requirement</td>
                  <td>
                    <xref target='A3'>
                      Requirement 1-1:
                      <tt>Requirement 1</tt>
                    </xref>
                  </td>
                </tr>
                <tr>
                  <td>Recommendation</td>
                  <td>
                    <xref target='A4'>
                      Recommendation 1-1:
                      <tt>Recommendation 1</tt>
                    </xref>
                  </td>
                </tr>
              </tbody>
            </table>
          </foreword>
        </preface>
      </ogc-standard>
    OUTPUT

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
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
          <foreword id='A0' displayorder='1'>
            <title>Preface</title>
            <table id='A' unnumbered='true' class='modspec' type='recommend'>
              <thead>
                <tr>
                  <th scope='colgroup' colspan='2'>
                    <p class='RecommendationTitle'>Requirement: A New Requirement</p>
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Identifier</td>
                  <td><tt>/ogc/recommendation/wfs/2</tt></td>
                </tr>
                <tr>
                  <td>Subject</td>
                  <td>user</td>
                </tr>
                <tr>
                  <td>Dependency</td>
                  <td>/ss/584/2015/level/1</td>
                </tr>
                <tr>
                  <td colspan='2'>
                    <p id='_'>
                      I recommend
                      <em>this</em>
                      .
                    </p>
                  </td>
                </tr>
                <tr>
                  <td colspan='2'>
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

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes recommendations" do
    input = <<~INPUT
            <ogc-standard xmlns="https://standards.opengeospatial.org/document">
          <preface><foreword id="A"><title>Preface</title>
          <recommendation model="ogc" id="_">
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
          <foreword id='A' displayorder='1'>
            <title>Preface</title>
            <table id='_' class='modspec' type='recommend'>
              <thead>
                <tr>
                  <th scope='colgroup' colspan='2'>
                    <p class='RecommendationTitle'>Recommendation 1</p>
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Identifier</td>
                  <td><tt>/ogc/recommendation/wfs/2</tt></td>
                </tr>
                <tr>
                  <td>Subject</td>
                  <td>user</td>
                </tr>
                <tr>
                  <td>Dependency</td>
                  <td>/ss/584/2015/level/1</td>
                </tr>
                <tr>
                  <td colspan='2'>
                    <p id='_'>
                      I recommend
                      <em>this</em>
                      .
                    </p>
                  </td>
                </tr>
                <tr>
                  <td colspan='2'>
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

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(presxml)
  end
end
