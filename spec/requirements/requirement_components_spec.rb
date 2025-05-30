require "spec_helper"

RSpec.describe Metanorma::Requirements::Iso::Modspec do
  it "processes requirement components" do
    input = <<~INPUT
      <ogc-standard xmlns="https://standards.opengeospatial.org/document">
        <preface><foreword id="A"><title>Preface</title>
        <recommendation model="ogc" id="_">
      <identifier>/ogc/recommendation/wfs/2</identifier>
      <inherit>/ss/584/2015/level/1</inherit>
      <subject>user</subject>
      <description><p id="_">I recommend <em>1</em>.</p></description>
      <component class="test-purpose" id="A1"><p>TEST PURPOSE</p></component>
      <description><p id="_">I recommend <em>2</em>.</p></description>
      <component class="guidance" id="A7"><p>GUIDANCE #1</p></component>
      <description><p id="_">I recommend <em>2a</em>.</p></description>
      <component class="conditions" id="A2"><p>CONDITIONS</p></component>
      <description><p id="_">I recommend <em>3</em>.</p></description>
      <component class="part" id="A3"><p>FIRST PART</p></component>
      <description><p id="_">I recommend <em>4</em>.</p></description>
      <component class="part" id="A4"><p>SECOND PART</p></component>
      <description><p id="_">I recommend <em>5</em>.</p></description>
      <component class="test-method" id="A5"><p>TEST METHOD</p></component>
      <description><p id="_">I recommend <em>6</em>.</p></description>
      <component class="part" id="A6"><p>THIRD PART</p></component>
      <description><p id="_">I recommend <em>7</em>.</p></description>
      <component class="guidance" id="A8"><p>GUIDANCE #2</p></component>
      <description><p id="_">I recommend <em>7a</em>.</p></description>
      <component class="panda GHz express" id="A7"><p>PANDA PART</p></component>
      <description><p id="_">I recommend <em>8</em>.</p></description>
      </recommendation>
      </foreword>
      </preface>
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
                <recommendation model="ogc" autonum="1" original-id="_">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Recommendation</span>
                      <semx element="autonum" source="_">1</semx>
                      :
                      <tt>
                         <xref style="id" target="_">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <subject id="_">user</subject>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>1</em>
                         .
                      </p>
                   </description>
                   <component class="test-purpose" original-id="A1">
                      <p>TEST PURPOSE</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>2</em>
                         .
                      </p>
                   </description>
                   <component class="guidance" original-id="A7">
                      <p>GUIDANCE #1</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>2a</em>
                         .
                      </p>
                   </description>
                   <component class="conditions" original-id="A2">
                      <p>CONDITIONS</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>3</em>
                         .
                      </p>
                   </description>
                   <component class="part" original-id="A3">
                      <p>FIRST PART</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>4</em>
                         .
                      </p>
                   </description>
                   <component class="part" original-id="A4">
                      <p>SECOND PART</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>5</em>
                         .
                      </p>
                   </description>
                   <component class="test-method" original-id="A5">
                      <p>TEST METHOD</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>6</em>
                         .
                      </p>
                   </description>
                   <component class="part" original-id="A6">
                      <p>THIRD PART</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>7</em>
                         .
                      </p>
                   </description>
                   <component class="guidance" id="A8">
                      <p>GUIDANCE #2</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>7a</em>
                         .
                      </p>
                   </description>
                   <component class="panda GHz express" original-id="A7">
                      <p>PANDA PART</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>8</em>
                         .
                      </p>
                   </description>
                   <fmt-provision id="_">
                      <table id="_" type="recommend" class="modspec" autonum="1">
                         <fmt-name id="_">
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="_">1</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Recommendation</span>
                                  <semx element="autonum" source="_">1</semx>
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
                               <th>Statement</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>1</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A1">
                               <th>Test purpose</th>
                               <td>
                                  <semx element="component" source="A1">
                                     <p>TEST PURPOSE</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Statements</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>2</em>
                                        .
                                     </p>
                                  </semx>
                                  <br/>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>2a</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A2">
                               <th>Conditions</th>
                               <td>
                                  <semx element="component" source="A2">
                                     <p>CONDITIONS</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Statement</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>3</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A3">
                               <th>A</th>
                               <td>
                                  <semx element="component" source="A3">
                                     <p>FIRST PART</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Statement</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>4</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A4">
                               <th>B</th>
                               <td>
                                  <semx element="component" source="A4">
                                     <p>SECOND PART</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Statement</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>5</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A5">
                               <th>Test method</th>
                               <td>
                                  <semx element="component" source="A5">
                                     <p>TEST METHOD</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Statement</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>6</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A6">
                               <th>C</th>
                               <td>
                                  <semx element="component" source="A6">
                                     <p>THIRD PART</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Statements</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>7</em>
                                        .
                                     </p>
                                  </semx>
                                  <br/>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>7a</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A7">
                               <th>Panda GHz express</th>
                               <td>
                                  <semx element="component" source="A7">
                                     <p>PANDA PART</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Statement</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>8</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A7">
                               <th>Guidance</th>
                               <td>
                                  <semx element="component" source="A7">
                                     <p>GUIDANCE #1</p>
                                  </semx>
                                  <br/>
                                  <semx element="component" source="A8">
                                     <p>GUIDANCE #2</p>
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

    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes requirement components for recommendation classes" do
    input = <<~INPUT
              <ogc-standard xmlns="https://standards.opengeospatial.org/document">
        <preface><foreword id="A"><title>Preface</title>
        <recommendation model="ogc" id="_" type="class">
      <identifier>/ogc/recommendation/wfs/2</identifier>
      <inherit>/ss/584/2015/level/1</inherit>
      <subject>user</subject>
      <description><p id="_">I recommend <em>1</em>.</p></description>
      <component class="test-purpose" id="A1"><p>TEST PURPOSE</p></component>
      <description><p id="_">I recommend <em>2</em>.</p></description>
      <component class="conditions" id="A2"><p>CONDITIONS</p></component>
      <description><p id="_">I recommend <em>3</em>.</p></description>
      <component class="part" id="A3"><p>FIRST PART</p></component>
      <description><p id="_">I recommend <em>4</em>.</p></description>
      <component class="part" id="A4"><p>SECOND PART</p></component>
      <description><p id="_">I recommend <em>5</em>.</p></description>
      <component class="test-method" id="A5"><p>TEST METHOD</p></component>
      <description><p id="_">I recommend <em>6</em>.</p></description>
      <component class="part" id="A6"><p>THIRD PART</p></component>
      <description><p id="_">I recommend <em>7</em>.</p></description>
      <component class="panda GHz express" id="A7"><p>PANDA PART</p></component>
      <description><p id="_">I recommend <em>8</em>.</p></description>
      </recommendation>
      </foreword>
      </preface>
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
                <recommendation model="ogc" type="class" autonum="1" original-id="_">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Recommendations class</span>
                      <semx element="autonum" source="_">1</semx>
                      :
                      <tt>
                         <xref style="id" target="_">
                            <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                         </xref>
                      </tt>
                   </fmt-xref-label>
                   <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <subject id="_">user</subject>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>1</em>
                         .
                      </p>
                   </description>
                   <component class="test-purpose" original-id="A1">
                      <p>TEST PURPOSE</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>2</em>
                         .
                      </p>
                   </description>
                   <component class="conditions" original-id="A2">
                      <p>CONDITIONS</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>3</em>
                         .
                      </p>
                   </description>
                   <component class="part" original-id="A3">
                      <p>FIRST PART</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>4</em>
                         .
                      </p>
                   </description>
                   <component class="part" original-id="A4">
                      <p>SECOND PART</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>5</em>
                         .
                      </p>
                   </description>
                   <component class="test-method" original-id="A5">
                      <p>TEST METHOD</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>6</em>
                         .
                      </p>
                   </description>
                   <component class="part" original-id="A6">
                      <p>THIRD PART</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>7</em>
                         .
                      </p>
                   </description>
                   <component class="panda GHz express" original-id="A7">
                      <p>PANDA PART</p>
                   </component>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>8</em>
                         .
                      </p>
                   </description>
                   <fmt-provision id="_">
                      <table id="_" type="recommendclass" class="modspec" autonum="1">
                         <fmt-name id="_">
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="_">1</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Recommendations class</span>
                                  <semx element="autonum" source="_">1</semx>
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
                               <th>Prerequisite</th>
                               <td>
                                  <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Description</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>1</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A1">
                               <th>Test purpose</th>
                               <td>
                                  <semx element="component" source="A1">
                                     <p>TEST PURPOSE</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Description</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>2</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A2">
                               <th>Conditions</th>
                               <td>
                                  <semx element="component" source="A2">
                                     <p>CONDITIONS</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Description</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>3</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A3">
                               <th>A</th>
                               <td>
                                  <semx element="component" source="A3">
                                     <p>FIRST PART</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Description</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>4</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A4">
                               <th>B</th>
                               <td>
                                  <semx element="component" source="A4">
                                     <p>SECOND PART</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Description</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>5</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A5">
                               <th>Test method</th>
                               <td>
                                  <semx element="component" source="A5">
                                     <p>TEST METHOD</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Description</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>6</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A6">
                               <th>C</th>
                               <td>
                                  <semx element="component" source="A6">
                                     <p>THIRD PART</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Description</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>7</em>
                                        .
                                     </p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="A7">
                               <th>Panda GHz express</th>
                               <td>
                                  <semx element="component" source="A7">
                                     <p>PANDA PART</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr>
                               <th>Description</th>
                               <td>
                                  <semx element="description" source="_">
                                     <p id="_">
                                        I recommend
                                        <em>8</em>
                                        .
                                     </p>
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

  it "processes nested requirement steps" do
    input = <<~INPUT
                <ogc-standard xmlns="https://standards.opengeospatial.org/document">
            <preface>
                <foreword id="A"><title>Preface</title>
                    <requirement model="ogc" id='A1'>
        <component exclude='false' class='test method type'>
          <p id='_'>Manual Inspection</p>
        </component>
        <component exclude='false' class='test-method'>
          <p id='1'>
            <component exclude='false' class='step'>
              <p id='2'>For each UML class defined or referenced in the Tunnel Package:</p>
              <component exclude='false' class='step'>
                <p id='3'>
                  Validate that the Implementation Specification contains a data
                  element which represents the same concept as that defined for
                  the UML class.
                </p>
              </component>
              <component exclude='false' class='step'>
                <p id='4'>
                  Validate that the data element has the same relationships with
                  other elements as those defined for the UML class. Validate that
                  those relationships have the same source, target, direction,
                  roles, and multiplicies as those documented in the Conceptual
                  Model.
                </p>
              </component>
            </component>
          </p>
        </component>
      </requirement>
            </foreword></preface>
            </ogc-standard>
    INPUT
    presxml = <<~PRESXML
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
                <requirement model="ogc" autonum="1" original-id="A1">
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="A1">1</semx>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Requirement</span>
                      <semx element="autonum" source="A1">1</semx>
                   </fmt-xref-label>
                   <component exclude="false" class="test method type" original-id="_">
                      <p original-id="_">Manual Inspection</p>
                   </component>
                   <component exclude="false" class="test-method" original-id="_">
                      <p original-id="1">
                         <component exclude="false" class="step" id="_">
                            <p id="2">For each UML class defined or referenced in the Tunnel Package:</p>
                            <component exclude="false" class="step" id="_">
                               <p id="3">
                   Validate that the Implementation Specification contains a data
                   element which represents the same concept as that defined for
                   the UML class.
                 </p>
                            </component>
                            <component exclude="false" class="step" id="_">
                               <p id="4">
                   Validate that the data element has the same relationships with
                   other elements as those defined for the UML class. Validate that
                   those relationships have the same source, target, direction,
                   roles, and multiplicies as those documented in the Conceptual
                   Model.
                 </p>
                            </component>
                         </component>
                      </p>
                   </component>
                   <fmt-provision id="_">
                      <table id="A1" type="recommend" class="modspec" autonum="1">
                         <fmt-name id="_">
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="A1">1</semx>
                            </span>
                            <span class="fmt-caption-delim"> — </span>
                            <semx element="name" source="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Requirement</span>
                                  <semx element="autonum" source="A1">1</semx>
                               </span>
                            </semx>
                         </fmt-name>
                         <tbody>
                            <tr id="_">
                               <th>Test method type</th>
                               <td>
                                  <semx element="component" source="_">
                                     <p id="_">Manual Inspection</p>
                                  </semx>
                               </td>
                            </tr>
                            <tr id="_">
                               <th>Test method</th>
                               <td>
                                  <semx element="component" source="_">
                                     <p id="1">
                                        <ol class="steps">
                                           <li>
                                              <semx element="component" source="_">
                                                 <p original-id="2">For each UML class defined or referenced in the Tunnel Package:</p>
                                                 <ol class="steps">
                                                    <li>
                                                       <semx element="component" source="_">
                                                          <p original-id="3">
                   Validate that the Implementation Specification contains a data
                   element which represents the same concept as that defined for
                   the UML class.
                 </p>
                                                       </semx>
                                                    </li>
                                                    <li>
                                                       <semx element="component" source="_">
                                                          <p original-id="4">
                   Validate that the data element has the same relationships with
                   other elements as those defined for the UML class. Validate that
                   those relationships have the same source, target, direction,
                   roles, and multiplicies as those documented in the Conceptual
                   Model.
                 </p>
                                                       </semx>
                                                    </li>
                                                 </ol>
                                              </semx>
                                           </li>
                                        </ol>
                                     </p>
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
    PRESXML
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes bidirectional requirement/conformance tests" do
    input = <<~INPUT
          <ogc-standard xmlns="https://standards.opengeospatial.org/document">
      <preface>
          <foreword id="A"><title>Preface</title>
              <requirement model="ogc" id='A1' type="general">
              <title>First</title>
              <identifier>/ogc/recommendation/wfs/1</identifier>
              </requirement>
              <requirement model="ogc" id='A2' type="verification">
              <title>Second</title>
              <identifier>/ogc/recommendation/wfs/2</identifier>
              <classification><tag>target</tag><value>/ogc/recommendation/wfs/1</value></classification>
              </requirement>
              <requirement model="ogc" id='A3' type="class">
              <title>Third</title>
              <identifier>/ogc/recommendation/wfs/3</identifier>
              </requirement>
              <requirement model="ogc" id='A4' type="conformanceclass">
              <title>Fourth</title>
              <identifier>/ogc/recommendation/wfs/4</identifier>
              <classification><tag>target</tag><value>/ogc/recommendation/wfs/3</value></classification>
              </requirement>
      </foreword></preface>
      </ogc-standard>
    INPUT
    presxml = <<~PRESXML
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
                 <requirement model="ogc" type="general" autonum="1" original-id="A1">
                    <fmt-xref-label>
                       <span class="fmt-element-name">Table</span>
                       <semx element="autonum" source="A1">1</semx>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Requirement</span>
                       <semx element="autonum" source="A1">1</semx>
                       :
                       <tt>
                          <xref style="id" target="A1">
                             <semx element="identifier" source="_">/ogc/recommendation/wfs/1</semx>
                          </xref>
                       </tt>
                    </fmt-xref-label>
                    <title>First</title>
                    <identifier id="_">/ogc/recommendation/wfs/1</identifier>
                    <fmt-provision id="_">
                       <table id="A1" type="recommend" class="modspec" autonum="1">
                          <fmt-name id="_">
                             <span class="fmt-caption-label">
                                <span class="fmt-element-name">Table</span>
                                <semx element="autonum" source="A1">1</semx>
                             </span>
                             <span class="fmt-caption-delim"> — </span>
                             <semx element="name" source="_">
                                <span class="fmt-caption-label">
                                   <span class="fmt-element-name">Requirement</span>
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
                                      <semx element="identifier" source="_">/ogc/recommendation/wfs/1</semx>
                                   </tt>
                                </td>
                             </tr>
                             <tr>
                                <th>Conformance test</th>
                                <td>
                                   <xref target="A2" id="_">
                                      <span class="fmt-element-name">Conformance test</span>
                                      <semx element="autonum" source="A2">1</semx>
                                      <span class="fmt-caption-delim">: </span>
                                      <semx element="title" source="A2">Second</semx>
                                   </xref>
                                   <semx element="xref" source="_">
                                      <fmt-xref target="A2">
                                         <span class="fmt-element-name">Conformance test</span>
                                         <semx element="autonum" source="A2">1</semx>
                                         <span class="fmt-caption-delim">: </span>
                                         <semx element="title" source="A2">Second</semx>
                                      </fmt-xref>
                                   </semx>
                                </td>
                             </tr>
                          </tbody>
                       </table>
                    </fmt-provision>
                 </requirement>
                 <requirement model="ogc" type="verification" autonum="1" original-id="A2">
                    <fmt-xref-label>
                       <span class="fmt-element-name">Table</span>
                       <semx element="autonum" source="A2">2</semx>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Conformance test</span>
                       <semx element="autonum" source="A2">1</semx>
                       :
                       <tt>
                          <xref style="id" target="A2">
                             <semx element="identifier" source="_">/ogc/recommendation/wfs/2</semx>
                          </xref>
                       </tt>
                    </fmt-xref-label>
                    <title>Second</title>
                    <identifier id="_">/ogc/recommendation/wfs/2</identifier>
                    <classification>
                       <tag>target</tag>
                       <value id="_">/ogc/recommendation/wfs/1</value>
                    </classification>
                    <fmt-provision id="_">
                       <table id="A2" type="recommendtest" class="modspec" autonum="2">
                          <fmt-name id="_">
                             <span class="fmt-caption-label">
                                <span class="fmt-element-name">Table</span>
                                <semx element="autonum" source="A2">2</semx>
                             </span>
                             <span class="fmt-caption-delim"> — </span>
                             <semx element="name" source="_">
                                <span class="fmt-caption-label">
                                   <span class="fmt-element-name">Conformance test</span>
                                   <semx element="autonum" source="A2">1</semx>
                                   <span class="fmt-caption-delim">: </span>
                                   <semx element="title" source="A2">Second</semx>
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
                                <th>Requirement</th>
                                <td>
                                   <xref target="A1" id="_">
                                      <span class="fmt-element-name">Requirement</span>
                                      <semx element="autonum" source="A1">1</semx>
                                      <span class="fmt-caption-delim">: </span>
                                      <semx element="title" source="A1">First</semx>
                                   </xref>
                                   <semx element="xref" source="_">
                                      <fmt-xref target="A1">
                                         <span class="fmt-element-name">Requirement</span>
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
                 </requirement>
                 <requirement model="ogc" type="class" autonum="1" original-id="A3">
                    <fmt-xref-label>
                       <span class="fmt-element-name">Table</span>
                       <semx element="autonum" source="A3">3</semx>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Requirements class</span>
                       <semx element="autonum" source="A3">1</semx>
                       :
                       <tt>
                          <xref style="id" target="A3">
                             <semx element="identifier" source="_">/ogc/recommendation/wfs/3</semx>
                          </xref>
                       </tt>
                    </fmt-xref-label>
                    <title>Third</title>
                    <identifier id="_">/ogc/recommendation/wfs/3</identifier>
                    <fmt-provision id="_">
                       <table id="A3" type="recommendclass" class="modspec" autonum="3">
                          <fmt-name id="_">
                             <span class="fmt-caption-label">
                                <span class="fmt-element-name">Table</span>
                                <semx element="autonum" source="A3">3</semx>
                             </span>
                             <span class="fmt-caption-delim"> — </span>
                             <semx element="name" source="_">
                                <span class="fmt-caption-label">
                                   <span class="fmt-element-name">Requirements class</span>
                                   <semx element="autonum" source="A3">1</semx>
                                   <span class="fmt-caption-delim">: </span>
                                   <semx element="title" source="A3">Third</semx>
                                </span>
                             </semx>
                          </fmt-name>
                          <tbody>
                             <tr>
                                <th>Identifier</th>
                                <td>
                                   <tt>
                                      <semx element="identifier" source="_">/ogc/recommendation/wfs/3</semx>
                                   </tt>
                                </td>
                             </tr>
                             <tr>
                                <th>Conformance class</th>
                                <td>
                                   <xref target="A4" id="_">
                                      <span class="fmt-element-name">Conformance class</span>
                                      <semx element="autonum" source="A4">1</semx>
                                      <span class="fmt-caption-delim">: </span>
                                      <semx element="title" source="A4">Fourth</semx>
                                   </xref>
                                   <semx element="xref" source="_">
                                      <fmt-xref target="A4">
                                         <span class="fmt-element-name">Conformance class</span>
                                         <semx element="autonum" source="A4">1</semx>
                                         <span class="fmt-caption-delim">: </span>
                                         <semx element="title" source="A4">Fourth</semx>
                                      </fmt-xref>
                                   </semx>
                                </td>
                             </tr>
                          </tbody>
                       </table>
                    </fmt-provision>
                 </requirement>
                 <requirement model="ogc" type="conformanceclass" autonum="1" original-id="A4">
                    <fmt-xref-label>
                       <span class="fmt-element-name">Table</span>
                       <semx element="autonum" source="A4">4</semx>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Conformance class</span>
                       <semx element="autonum" source="A4">1</semx>
                       :
                       <tt>
                          <xref style="id" target="A4">
                             <semx element="identifier" source="_">/ogc/recommendation/wfs/4</semx>
                          </xref>
                       </tt>
                    </fmt-xref-label>
                    <title>Fourth</title>
                    <identifier id="_">/ogc/recommendation/wfs/4</identifier>
                    <classification>
                       <tag>target</tag>
                       <value id="_">/ogc/recommendation/wfs/3</value>
                    </classification>
                    <fmt-provision id="_">
                       <table id="A4" type="recommendclass" class="modspec" autonum="4">
                          <fmt-name id="_">
                             <span class="fmt-caption-label">
                                <span class="fmt-element-name">Table</span>
                                <semx element="autonum" source="A4">4</semx>
                             </span>
                             <span class="fmt-caption-delim"> — </span>
                             <semx element="name" source="_">
                                <span class="fmt-caption-label">
                                   <span class="fmt-element-name">Conformance class</span>
                                   <semx element="autonum" source="A4">1</semx>
                                   <span class="fmt-caption-delim">: </span>
                                   <semx element="title" source="A4">Fourth</semx>
                                </span>
                             </semx>
                          </fmt-name>
                          <tbody>
                             <tr>
                                <th>Identifier</th>
                                <td>
                                   <tt>
                                      <semx element="identifier" source="_">/ogc/recommendation/wfs/4</semx>
                                   </tt>
                                </td>
                             </tr>
                             <tr>
                                <th>Requirements class</th>
                                <td>
                                   <xref target="A3" id="_">
                                      <span class="fmt-element-name">Requirements class</span>
                                      <semx element="autonum" source="A3">1</semx>
                                      <span class="fmt-caption-delim">: </span>
                                      <semx element="title" source="A3">Third</semx>
                                   </xref>
                                   <semx element="xref" source="_">
                                      <fmt-xref target="A3">
                                         <span class="fmt-element-name">Requirements class</span>
                                         <semx element="autonum" source="A3">1</semx>
                                         <span class="fmt-caption-delim">: </span>
                                         <semx element="title" source="A3">Third</semx>
                                      </fmt-xref>
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
    PRESXML
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end
end
