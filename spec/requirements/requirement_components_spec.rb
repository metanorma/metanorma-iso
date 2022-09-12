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
           <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
         <preface>
           <foreword id='A' displayorder='1'>
             <title>Preface</title>
             <table id='_' class='modspec' type='recommend'>
               <name>Table 1 — Recommendation 1</name>
               <tbody>
                 <tr>
                   <td>Identifier</td>
                   <td>
                     <tt>/ogc/recommendation/wfs/2</tt>
                   </td>
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
                   <td>Statement</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>1</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A1'>
                   <td>Test purpose</td>
                   <td>
                     <p>TEST PURPOSE</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Statement</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>2</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A2'>
                   <td>Conditions</td>
                   <td>
                     <p>CONDITIONS</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Statement</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>3</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A3'>
                   <td>A</td>
                   <td>
                     <p>FIRST PART</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Statement</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>4</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A4'>
                   <td>B</td>
                   <td>
                     <p>SECOND PART</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Statement</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>5</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A5'>
                   <td>Test method</td>
                   <td>
                     <p>TEST METHOD</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Statement</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>6</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A6'>
                   <td>C</td>
                   <td>
                     <p>THIRD PART</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Statement</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>7</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A7'>
                   <td>Panda GHz express</td>
                   <td>
                     <p>PANDA PART</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Statement</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>8</em>
                       .
                     </p>
                   </td>
                 </tr>
               </tbody>
             </table>
           </foreword>
         </preface>
       </ogc-standard>
    OUTPUT

    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(presxml)
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
      <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
         <preface>
           <foreword id='A' displayorder='1'>
             <title>Preface</title>
             <table id='_' class='modspec' type='recommendclass'>
               <name>Table 1 — Recommendations class 1</name>
               <tbody>
                 <tr>
                   <td>Identifier</td>
                   <td>
                     <tt>/ogc/recommendation/wfs/2</tt>
                   </td>
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
                   <td>Description</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>1</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A1'>
                   <td>Test purpose</td>
                   <td>
                     <p>TEST PURPOSE</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Description</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>2</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A2'>
                   <td>Conditions</td>
                   <td>
                     <p>CONDITIONS</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Description</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>3</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A3'>
                   <td>A</td>
                   <td>
                     <p>FIRST PART</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Description</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>4</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A4'>
                   <td>B</td>
                   <td>
                     <p>SECOND PART</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Description</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>5</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A5'>
                   <td>Test method</td>
                   <td>
                     <p>TEST METHOD</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Description</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>6</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A6'>
                   <td>C</td>
                   <td>
                     <p>THIRD PART</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Description</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>7</em>
                       .
                     </p>
                   </td>
                 </tr>
                 <tr id='A7'>
                   <td>Panda GHz express</td>
                   <td>
                     <p>PANDA PART</p>
                   </td>
                 </tr>
                 <tr>
                   <td>Description</td>
                   <td>
                     <p id='_'>
                       I recommend
                       <em>8</em>
                       .
                     </p>
                   </td>
                 </tr>
               </tbody>
             </table>
           </foreword>
         </preface>
       </ogc-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(presxml)
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
          <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
        <preface>
          <foreword id='A' displayorder='1'>
            <title>Preface</title>
            <table id='A1' class='modspec' type='recommend'>
            <name>Table 1 — Requirement 1</name>
              <tbody>
                <tr>
                  <td>Test method type</td>
                  <td>
                    <p id='_'>Manual Inspection</p>
                  </td>
                </tr>
                <tr>
                  <td>Test method</td>
                  <td>
                    <p id='1'>
                      <ol class="steps">
                        <li>
                          <p id='2'>For each UML class defined or referenced in the Tunnel Package:</p>
                          <ol class="steps">
                            <li>
                              <p id='3'>
                                 Validate that the Implementation Specification
                                contains a data element which represents the same
                                concept as that defined for the UML class.
                              </p>
                            </li>
                            <li>
                              <p id='4'>
                                 Validate that the data element has the same
                                relationships with other elements as those defined for
                                the UML class. Validate that those relationships have
                                the same source, target, direction, roles, and
                                multiplicies as those documented in the Conceptual
                                Model.
                              </p>
                            </li>
                          </ol>
                        </li>
                      </ol>
                    </p>
                  </td>
                </tr>
              </tbody>
            </table>
          </foreword>
        </preface>
      </ogc-standard>
    PRESXML
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes bidirectional requirement/conformance tests" do
    input = <<~INPUT
          <ogc-standard xmlns="https://standards.opengeospatial.org/document">
      <preface>
          <foreword id="A"><title>Preface</title>
              <requirement model="ogc" id='A1' type="general">
              <identifier>/ogc/recommendation/wfs/1</identifier>
              </requirement>
              <requirement model="ogc" id='A2' type="verification">
              <identifier>/ogc/recommendation/wfs/2</identifier>
              <classification><tag>target</tag><value>/ogc/recommendation/wfs/1</value></classification>
              </requirement>
              <requirement model="ogc" id='A3' type="class">
              <identifier>/ogc/recommendation/wfs/3</identifier>
              </requirement>
              <requirement model="ogc" id='A4' type="conformanceclass">
              <identifier>/ogc/recommendation/wfs/4</identifier>
              <classification><tag>target</tag><value>/ogc/recommendation/wfs/3</value></classification>
              </requirement>
      </foreword></preface>
      </ogc-standard>
    INPUT
    presxml = <<~PRESXML
           <ogc-standard xmlns='https://standards.opengeospatial.org/document' type='presentation'>
         <preface>
           <foreword id='A' displayorder='1'>
             <title>Preface</title>
             <table id='A1' class='modspec' type='recommend'>
               <name>Table 1 — Requirement 1</name>
               <tbody>
                 <tr>
                   <td>Identifier</td>
                   <td>
                     <tt>/ogc/recommendation/wfs/1</tt>
                   </td>
                 </tr>
                 <tr>
                   <td>Conformance test</td>
                   <td>
                     <xref target='A2'>
                       Requirement test 1:
                       <tt>/ogc/recommendation/wfs/2</tt>
                     </xref>
                   </td>
                 </tr>
               </tbody>
             </table>
             <table id='A2' class='modspec' type='recommendtest'>
               <name>Table 2 — Requirement test 1</name>
               <tbody>
                 <tr>
                   <td>Identifier</td>
                   <td>
                     <tt>/ogc/recommendation/wfs/2</tt>
                   </td>
                 </tr>
                 <tr>
                   <td>Requirement</td>
                   <td>
                     <xref target='A1'>
                       Requirement 1:
                       <tt>/ogc/recommendation/wfs/1</tt>
                     </xref>
                   </td>
                 </tr>
               </tbody>
             </table>
             <table id='A3' class='modspec' type='recommendclass'>
               <name>Table 3 — Requirements class 1</name>
               <tbody>
                 <tr>
                   <td>Identifier</td>
                   <td>
                     <tt>/ogc/recommendation/wfs/3</tt>
                   </td>
                 </tr>
                 <tr>
                   <td>Conformance test</td>
                   <td>
                     <xref target='A4'>
                       Conformance class 1:
                       <tt>/ogc/recommendation/wfs/4</tt>
                     </xref>
                   </td>
                 </tr>
               </tbody>
             </table>
             <table id='A4' class='modspec' type='recommendclass'>
               <name>Table 4 — Conformance class 1</name>
               <tbody>
                 <tr>
                   <td>Identifier</td>
                   <td>
                     <tt>/ogc/recommendation/wfs/4</tt>
                   </td>
                 </tr>
                 <tr>
                   <td>Requirements class</td>
                   <td>
                     <xref target='A3'>
                       Requirements class 1:
                       <tt>/ogc/recommendation/wfs/3</tt>
                     </xref>
                   </td>
                 </tr>
               </tbody>
             </table>
           </foreword>
         </preface>
       </ogc-standard>
    PRESXML
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
  end
end
