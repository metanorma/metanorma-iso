require "spec_helper"

RSpec.describe Metanorma::Requirements::Iso::Modspec do
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
                <td style="text-align: left;">Object</td>
                <td style="text-align: left;">Value</td>
                <td style="text-align: left;">Accomplished</td>
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
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <permission model="ogc" type="abstracttest" autonum="1" original-id="A1" id="_">
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
                               <td style="text-align: left;">Object</td>
                               <td style="text-align: left;">Value</td>
                               <td style="text-align: left;">Accomplished</td>
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
                   <measurement-target exclude="false" original-id="_">
                      <p original-id="_">The measurement target shall be measured as:</p>
                      <formula autonum="1" original-id="B">
                         <stem type="AsciiMath">r/1 = 0</stem>
                      </formula>
                   </measurement-target>
                   <verification exclude="false" original-id="_">
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
                   <fmt-provision id="_">
                      <table id="A1" type="recommendtest" class="modspec" autonum="1">
                         <fmt-name id="_">
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
                               <td colspan="2">
                                  <semx element="measurement-target" source="_">
                                     <p id="_">The measurement target shall be measured as:</p>
                                     <formula id="B" autonum="1">
                                        <fmt-name id="_">
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
                                        <stem type="AsciiMath" id="_">r/1 = 0</stem>
                                        <fmt-stem type="AsciiMath">
                                           <semx element="stem" source="_">r/1 = 0</semx>
                                        </fmt-stem>
                                     </formula>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <td colspan="2">
                                  <semx element="verification" source="_">
                                     <p id="_">The following code will be run for verification:</p>
                                     <sourcecode id="_" autonum="2">
                                        CoreRoot(success): HttpResponse if (success) recommendation(label: success-response) end
                                        <fmt-sourcecode id="_" autonum="2">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </fmt-sourcecode>
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

    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
              .convert("test", input, true)
  .gsub(%r{^.*<body}m, "<body")
  .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(presxml)
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
                <fmt-title depth="1" id="_">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <permission model="ogc" id="_" type="class" keep-with-next="true" keep-lines-together="true" autonum="1" original-id="A1">
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
                   <permission model="ogc" autonum="1-1" original-id="A2">
                      <title>First #1</title>
                      <identifier id="_">/ogc/recommendation/wfs/10</identifier>
                   </permission>
                   <requirement model="ogc" autonum="1-1" original-id="A3">
                      <title>First #2</title>
                      <identifier id="_">Requirement 1</identifier>
                   </requirement>
                   <recommendation model="ogc" autonum="1-1" original-id="A4">
                      <title>First #3</title>
                      <identifier id="_">Recommendation 1</identifier>
                   </recommendation>
                   <fmt-provision id="_">
                      <table id="A1" keep-with-next="true" keep-lines-together="true" type="recommendclass" class="modspec" autonum="1">
                         <fmt-name id="_">
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
                                     <xref target="B1" id="_">
                                        <span class="fmt-element-name">Permission</span>
                                        <semx element="autonum" source="B1">1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="B1">Second</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="B1">
                                           <span class="fmt-element-name">Permission</span>
                                           <semx element="autonum" source="B1">1</semx>
                                           <span class="fmt-caption-delim">: </span>
                                           <semx element="title" source="B1">Second</semx>
                                        </fmt-xref>
                                     </semx>
                                  </span>
                                  <br/>
                                  <bookmark id="A3"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A3" id="_">
                                        <span class="fmt-element-name">Requirement</span>
                                        <semx element="autonum" source="A3">1-1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A3">First #2</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="A3">
                                           <span class="fmt-element-name">Requirement</span>
                                           <semx element="autonum" source="A3">1-1</semx>
                                           <span class="fmt-caption-delim">: </span>
                                           <semx element="title" source="A3">First #2</semx>
                                        </fmt-xref>
                                     </semx>
                                  </span>
                                  <br/>
                                  <bookmark id="A4"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A4" id="_">
                                        <span class="fmt-element-name">Recommendation</span>
                                        <semx element="autonum" source="A4">1-1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A4">First #3</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="A4">
                                           <span class="fmt-element-name">Recommendation</span>
                                           <semx element="autonum" source="A4">1-1</semx>
                                           <span class="fmt-caption-delim">: </span>
                                           <semx element="title" source="A4">First #3</semx>
                                        </fmt-xref>
                                     </semx>
                                  </span>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
                <permission model="ogc" id="_" autonum="1" original-id="B1">
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
                   <fmt-provision id="_">
                      <table id="B1" type="recommend" class="modspec" autonum="2">
                         <fmt-name id="_">
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
                                  <xref target="A1" id="_">
                                     <span class="fmt-element-name">Permissions class</span>
                                     <semx element="autonum" source="A1">1</semx>
                                     <span class="fmt-caption-delim">: </span>
                                     <semx element="title" source="A1">First</semx>
                                  </xref>
                                  <semx element="xref" source="_">
                                     <fmt-xref target="A1">
                                        <span class="fmt-element-name">Permissions class</span>
                                        <semx element="autonum" source="A1">1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A1">First</semx>
                                     </fmt-xref>
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

    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
            .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(presxml)
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
                <fmt-title depth="1" id="_">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <permission model="ogc" id="_" type="conformanceclass" autonum="1" original-id="A1">
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
                   <permission model="ogc" autonum="1-1" original-id="A2">
                      <identifier id="_">Permission 1</identifier>
                   </permission>
                   <requirement model="ogc" autonum="1-1" original-id="A3">
                      <identifier id="_">Requirement 1</identifier>
                   </requirement>
                   <recommendation model="ogc" autonum="1-1" original-id="A4">
                      <identifier id="_">Recommendation 1</identifier>
                   </recommendation>
                   <fmt-provision id="_">
                      <table id="A1" type="recommendclass" class="modspec" autonum="1">
                         <fmt-name id="_">
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
                                  <xref target="B" id="_">
                                     <span class="fmt-element-name">Conformance class</span>
                                     <semx element="autonum" source="B">2</semx>
                                     <span class="fmt-caption-delim">: </span>
                                     <semx element="title" source="B">Second</semx>
                                  </xref>
                                  <semx element="xref" source="_">
                                     <fmt-xref target="B">
                                        <span class="fmt-element-name">Conformance class</span>
                                        <semx element="autonum" source="B">2</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="B">Second</semx>
                                     </fmt-xref>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Prerequisites</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                                  <br/>
                                  <xref target="B" id="_">
                                     <span class="fmt-element-name">Conformance class</span>
                                     <semx element="autonum" source="B">2</semx>
                                     <span class="fmt-caption-delim">: </span>
                                     <semx element="title" source="B">Second</semx>
                                  </xref>
                                  <semx element="xref" source="_">
                                     <fmt-xref target="B">
                                        <span class="fmt-element-name">Conformance class</span>
                                        <semx element="autonum" source="B">2</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="B">Second</semx>
                                     </fmt-xref>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Indirect prerequisites</th>
                               <td>
                                  <semx element="value" source="_">
                                     <link target="http://www.example.com/" id="_"/>
                                     <semx element="link" source="_">
                                        <fmt-link target="http://www.example.com/"/>
                                     </semx>
                                  </semx>
                                  <br/>
                                  <xref target="B" id="_">
                                     <span class="fmt-element-name">Conformance class</span>
                                     <semx element="autonum" source="B">2</semx>
                                     <span class="fmt-caption-delim">: </span>
                                     <semx element="title" source="B">Second</semx>
                                  </xref>
                                  <semx element="xref" source="_">
                                     <fmt-xref target="B">
                                        <span class="fmt-element-name">Conformance class</span>
                                        <semx element="autonum" source="B">2</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="B">Second</semx>
                                     </fmt-xref>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Conformance tests</th>
                               <td>
                                  <bookmark id="A2"/>
                                  <span class="fmt-caption-label">
                                     <xref target="B2" id="_">
                                        <span class="fmt-element-name">Permission</span>
                                        <semx element="autonum" source="B2">1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="B2">Third</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="B2">
                                           <span class="fmt-element-name">Permission</span>
                                           <semx element="autonum" source="B2">1</semx>
                                           <span class="fmt-caption-delim">: </span>
                                           <semx element="title" source="B2">Third</semx>
                                        </fmt-xref>
                                     </semx>
                                  </span>
                                  <br/>
                                  <bookmark id="A3"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A3" id="_">
                                        <span class="fmt-element-name">Requirement</span>
                                        <semx element="autonum" source="A3">1-1</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="A3">
                                           <span class="fmt-element-name">Requirement</span>
                                           <semx element="autonum" source="A3">1-1</semx>
                                        </fmt-xref>
                                     </semx>
                                  </span>
                                  <br/>
                                  <bookmark id="A4"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A4" id="_">
                                        <span class="fmt-element-name">Recommendation</span>
                                        <semx element="autonum" source="A4">1-1</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="A4">
                                           <span class="fmt-element-name">Recommendation</span>
                                           <semx element="autonum" source="A4">1-1</semx>
                                        </fmt-xref>
                                     </semx>
                                  </span>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
                <permission model="ogc" id="_" type="conformanceclass" autonum="2" original-id="B">
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
                   <fmt-provision id="_">
                      <table id="B" type="recommendclass" class="modspec" autonum="2">
                         <fmt-name id="_">
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
                <permission model="ogc" id="_" autonum="1" original-id="B2">
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
                   <fmt-provision id="_">
                      <table id="B2" type="recommend" class="modspec" autonum="3">
                         <fmt-name id="_">
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
                                  <xref target="A1" id="_">
                                     <span class="fmt-element-name">Conformance class</span>
                                     <semx element="autonum" source="A1">1</semx>
                                     <span class="fmt-caption-delim">: </span>
                                     <semx element="title" source="A1">First</semx>
                                  </xref>
                                  <semx element="xref" source="_">
                                     <fmt-xref target="A1">
                                        <span class="fmt-element-name">Conformance class</span>
                                        <semx element="autonum" source="A1">1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A1">First</semx>
                                     </fmt-xref>
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

    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(presxml)
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
                <fmt-title depth="1" id="_">Sommaire</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <permission model="ogc" id="_" type="conformanceclass" autonum="1" original-id="A1">
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
                   <permission model="ogc" autonum="1-1" original-id="A2">
                      <identifier id="_">Permission 1</identifier>
                   </permission>
                   <requirement model="ogc" autonum="1-1" original-id="A3">
                      <identifier id="_">Requirement 1</identifier>
                   </requirement>
                   <recommendation model="ogc" autonum="1-1" original-id="A4">
                      <identifier id="_">Recommendation 1</identifier>
                   </recommendation>
                   <fmt-provision id="_">
                      <table id="A1" type="recommendclass" class="modspec" autonum="1">
                         <fmt-name id="_">
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
                                  <xref target="B" id="_">
                                     <span class="fmt-element-name">Classe de confirmité</span>
                                     <semx element="autonum" source="B">2</semx>
                                     <span class="fmt-caption-delim"> : </span>
                                     <semx element="title" source="B">Second</semx>
                                  </xref>
                                  <semx element="xref" source="_">
                                     <fmt-xref target="B">
                                        <span class="fmt-element-name">Classe de confirmité</span>
                                        <semx element="autonum" source="B">2</semx>
                                        <span class="fmt-caption-delim"> : </span>
                                        <semx element="title" source="B">Second</semx>
                                     </fmt-xref>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Prérequis</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                                  <br/>
                                  <xref target="B" id="_">
                                     <span class="fmt-element-name">Classe de confirmité</span>
                                     <semx element="autonum" source="B">2</semx>
                                     <span class="fmt-caption-delim"> : </span>
                                     <semx element="title" source="B">Second</semx>
                                  </xref>
                                  <semx element="xref" source="_">
                                     <fmt-xref target="B">
                                        <span class="fmt-element-name">Classe de confirmité</span>
                                        <semx element="autonum" source="B">2</semx>
                                        <span class="fmt-caption-delim"> : </span>
                                        <semx element="title" source="B">Second</semx>
                                     </fmt-xref>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Prérequis indirect</th>
                               <td>
                                  <semx element="value" source="_">
                                     <link target="http://www.example.com/" id="_"/>
                                     <semx element="link" source="_">
                                        <fmt-link target="http://www.example.com/"/>
                                     </semx>
                                  </semx>
                                  <br/>
                                  <xref target="B" id="_">
                                     <span class="fmt-element-name">Classe de confirmité</span>
                                     <semx element="autonum" source="B">2</semx>
                                     <span class="fmt-caption-delim"> : </span>
                                     <semx element="title" source="B">Second</semx>
                                  </xref>
                                  <semx element="xref" source="_">
                                     <fmt-xref target="B">
                                        <span class="fmt-element-name">Classe de confirmité</span>
                                        <semx element="autonum" source="B">2</semx>
                                        <span class="fmt-caption-delim"> : </span>
                                        <semx element="title" source="B">Second</semx>
                                     </fmt-xref>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Tests de conformité</th>
                               <td>
                                  <bookmark id="A2"/>
                                  <span class="fmt-caption-label">
                                     <xref target="B2" id="_">
                                        <span class="fmt-element-name">Autorisation</span>
                                        <semx element="autonum" source="B2">1</semx>
                                        <span class="fmt-caption-delim"> : </span>
                                        <semx element="title" source="B2">Third</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="B2">
                                           <span class="fmt-element-name">Autorisation</span>
                                           <semx element="autonum" source="B2">1</semx>
                                           <span class="fmt-caption-delim"> : </span>
                                           <semx element="title" source="B2">Third</semx>
                                        </fmt-xref>
                                     </semx>
                                  </span>
                                  <br/>
                                  <bookmark id="A3"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A3" id="_">
                                        <span class="fmt-element-name">Exigence</span>
                                        <semx element="autonum" source="A3">1-1</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="A3">
                                           <span class="fmt-element-name">Exigence</span>
                                           <semx element="autonum" source="A3">1-1</semx>
                                        </fmt-xref>
                                     </semx>
                                  </span>
                                  <br/>
                                  <bookmark id="A4"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A4" id="_">
                                        <span class="fmt-element-name">Recommandation</span>
                                        <semx element="autonum" source="A4">1-1</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="A4">
                                           <span class="fmt-element-name">Recommandation</span>
                                           <semx element="autonum" source="A4">1-1</semx>
                                        </fmt-xref>
                                     </semx>
                                  </span>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </permission>
                <permission model="ogc" id="_" type="conformanceclass" autonum="2" original-id="B">
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
                   <fmt-provision id="_">
                      <table id="B" type="recommendclass" class="modspec" autonum="2">
                         <fmt-name id="_">
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
                <permission model="ogc" id="_" autonum="1" original-id="B2">
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
                   <fmt-provision id="_">
                      <table id="B2" type="recommend" class="modspec" autonum="3">
                         <fmt-name id="_">
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
                                  <xref target="A1" id="_">
                                     <span class="fmt-element-name">Classe de confirmité</span>
                                     <semx element="autonum" source="A1">1</semx>
                                     <span class="fmt-caption-delim"> : </span>
                                     <semx element="title" source="A1">First</semx>
                                  </xref>
                                  <semx element="xref" source="_">
                                     <fmt-xref target="A1">
                                        <span class="fmt-element-name">Classe de confirmité</span>
                                        <semx element="autonum" source="A1">1</semx>
                                        <span class="fmt-caption-delim"> : </span>
                                        <semx element="title" source="A1">First</semx>
                                     </fmt-xref>
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
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
       .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")
       .gsub(%r{^.*<body}m, "<body")
       .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(presxml)
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
                <fmt-title depth="1" id="_">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <requirement model="ogc" id="_" type="class" autonum="1" original-id="A1">
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
                   <permission model="ogc" autonum="1-1" original-id="A2">
                      <title>First #1</title>
                      <identifier id="_">Permission 1</identifier>
                   </permission>
                   <fmt-provision id="_">
                      <table id="A1" type="recommendclass" class="modspec" autonum="1">
                         <fmt-name id="_">
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
                                     <xref target="A5" id="_">
                                        <span class="fmt-element-name">Permission</span>
                                        <semx element="autonum" source="A5">1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A5">Second</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="A5">
                                           <span class="fmt-element-name">Permission</span>
                                           <semx element="autonum" source="A5">1</semx>
                                           <span class="fmt-caption-delim">: </span>
                                           <semx element="title" source="A5">Second</semx>
                                        </fmt-xref>
                                     </semx>
                                  </span>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                   </fmt-provision>
                </requirement>
                <permission model="ogc" id="_" autonum="1" original-id="A5">
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
                   <fmt-provision id="_">
                      <table id="A5" type="recommend" class="modspec" autonum="2">
                         <fmt-name id="_">
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
                                  <xref target="A1" id="_">
                                     <span class="fmt-element-name">Requirements class</span>
                                     <semx element="autonum" source="A1">1</semx>
                                     <span class="fmt-caption-delim">: </span>
                                     <semx element="title" source="A1">First</semx>
                                  </xref>
                                  <semx element="xref" source="_">
                                     <fmt-xref target="A1">
                                        <span class="fmt-element-name">Requirements class</span>
                                        <semx element="autonum" source="A1">1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A1">First</semx>
                                     </fmt-xref>
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

    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(presxml)
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
                <fmt-title depth="1" id="_">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Preface</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Preface</semx>
                </fmt-title>
                <recommendation model="ogc" id="_" type="class" autonum="1" original-id="A1">
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
                   <permission model="ogc" autonum="1-1" original-id="A2">
                      <title>First #1</title>
                      <identifier id="_">Permission 1</identifier>
                   </permission>
                   <requirement model="ogc" autonum="1-1" original-id="A3">
                      <title>First #2</title>
                      <identifier id="_">Requirement 1</identifier>
                   </requirement>
                   <recommendation model="ogc" autonum="1-1" original-id="A4">
                      <title>First #3</title>
                      <identifier id="_">Recommendation 1</identifier>
                   </recommendation>
                   <fmt-provision id="_">
                      <table id="A1" type="recommendclass" class="modspec" autonum="1">
                         <fmt-name id="_">
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
                                     <xref target="A2" id="_">
                                        <span class="fmt-element-name">Permission</span>
                                        <semx element="autonum" source="A2">1-1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A2">First #1</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="A2">
                                           <span class="fmt-element-name">Permission</span>
                                           <semx element="autonum" source="A2">1-1</semx>
                                           <span class="fmt-caption-delim">: </span>
                                           <semx element="title" source="A2">First #1</semx>
                                        </fmt-xref>
                                     </semx>
                                  </span>
                                  <br/>
                                  <bookmark id="A3"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A3" id="_">
                                        <span class="fmt-element-name">Requirement</span>
                                        <semx element="autonum" source="A3">1-1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A3">First #2</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="A3">
                                           <span class="fmt-element-name">Requirement</span>
                                           <semx element="autonum" source="A3">1-1</semx>
                                           <span class="fmt-caption-delim">: </span>
                                           <semx element="title" source="A3">First #2</semx>
                                        </fmt-xref>
                                     </semx>
                                  </span>
                                  <br/>
                                  <bookmark id="A4"/>
                                  <span class="fmt-caption-label">
                                     <xref target="A4" id="_">
                                        <span class="fmt-element-name">Recommendation</span>
                                        <semx element="autonum" source="A4">1-1</semx>
                                        <span class="fmt-caption-delim">: </span>
                                        <semx element="title" source="A4">First #3</semx>
                                     </xref>
                                     <semx element="xref" source="_">
                                        <fmt-xref target="A4">
                                           <span class="fmt-element-name">Recommendation</span>
                                           <semx element="autonum" source="A4">1-1</semx>
                                           <span class="fmt-caption-delim">: </span>
                                           <semx element="title" source="A4">First #3</semx>
                                        </fmt-xref>
                                     </semx>
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

    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(presxml)
  end
end
