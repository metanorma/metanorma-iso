require "spec_helper"

RSpec.describe Metanorma::Iso do
  it "removes empty text elements" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == {blank}
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="normative"/>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "moves term domains out of the term definition paragraph" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Tempus

      domain:[relativity] Time
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>#{TERM_BOILERPLATE}

            <term id="term-_lt_relativity_gt_-Tempus">
              <preferred><expression><name>Tempus</name></expression></preferred>
              <domain>relativity</domain>
              <definition><verbal-definition>
                <p id="_">Time</p></verbal-definition></definition>
            </term>
          </terms>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "permits multiple blocks in term definition paragraph" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :stem:
      :no-isobib:

      == Terms and Definitions

      === stem:[t_90]

      [.definition]
      --
      [stem]
      ++++
      t_A
      ++++

      This paragraph is extraneous
      --
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>
            #{TERM_BOILERPLATE}
                         <term id="term-t_90">
               <preferred>
                 <letter-symbol>
                   <name>
                     <stem type="MathML" block="false">
                       <math xmlns="http://www.w3.org/1998/Math/MathML">
                         <mstyle displaystyle="false">
                           <msub>
                             <mi>t</mi>
                             <mn>90</mn>
                           </msub>
                         </mstyle>
                       </math>
                       <asciimath>t_90</asciimath>
                     </stem>
                   </name>
                 </letter-symbol>
               </preferred>
               <definition>
                 <verbal-definition>
                   <formula id="_">
                     <stem type="MathML" block="true">
                       <math xmlns="http://www.w3.org/1998/Math/MathML">
                         <mstyle displaystyle="true">
                           <msub>
                             <mi>t</mi>
                             <mi>A</mi>
                           </msub>
                         </mstyle>
                       </math>
                       <asciimath>t_A</asciimath>
                     </stem>
                   </formula>
                   <p id="_">This paragraph is extraneous</p>
                 </verbal-definition>
               </definition>
             </term>
           </terms>
         </sections>
       </metanorma>
    OUTPUT

    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes initial boilerplate in Asciidoc without succumbing to recursion" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      I am boilerplate

      * So am I

      === Time

      This paragraph is extraneous
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>#{TERM_BOILERPLATE}

            <p id="_">I am boilerplate</p>
            <ul id="_">
              <li>
                <p id="_">So am I</p></li>
            </ul>
            <term id="term-Time">
              <preferred><expression><name>Time</name></expression></preferred>
              <definition><verbal-definition>
                <p id="_">This paragraph is extraneous</p>
              </verbal-definition></definition>
            </term>
          </terms>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "keeps any initial boilerplate from terms and definitions" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      I am boilerplate

      * So am I

      === Time

      This paragraph is extraneous
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>#{TERM_BOILERPLATE}

            <p id="_">I am boilerplate</p>
            <ul id="_">
              <li>
                <p id="_">So am I</p></li>
            </ul>
            <term id="term-Time">
              <preferred><expression><name>Time</name></expression></preferred>
              <definition><verbal-definition>
                <p id="_">This paragraph is extraneous</p>
              </verbal-definition></definition>
            </term>
          </terms>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "converts xrefs to references into erefs" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      <<iso216>>

      [bibliography]
      == Normative References
      * [[[iso216,ISO 216:2001]]], _Reference_
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">
              <eref bibitemid="iso216" citeas="ISO&#xa0;216:2001" type="inline"/>
            </p>
          </foreword>
        </preface>
        <sections>
        </sections>
        <bibliography>
          <references id="_" normative="true" obligation="informative">
            <title>Normative references</title>
            <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
            <bibitem id="iso216" type="standard">
              <title format="text/plain">Reference</title>
              <docidentifier>ISO 216:2001</docidentifier>
              <docnumber>216</docnumber>
              <date type="published">
                <on>2001</on>
              </date>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>International Organization for Standardization</name>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
            </bibitem>
          </references>
        </bibliography>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "extracts localities from erefs" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      <<iso216,whole,clause=3,example=9-11,locality:prelude=33,locality:entirety:the reference>>

      [bibliography]
      == Normative References
      * [[[iso216,ISO 216]]], _Reference_
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">
              <eref bibitemid="iso216" citeas="ISO&#xa0;216" type="inline">
                <localityStack>
                  <locality type="whole"/>
                  <locality type="clause">
                    <referenceFrom>3</referenceFrom>
                  </locality>
                  <locality type="example">
                    <referenceFrom>9</referenceFrom>
                    <referenceTo>11</referenceTo>
                  </locality>
                  <locality type="locality:prelude">
                    <referenceFrom>33</referenceFrom>
                  </locality>
                  <locality type="locality:entirety"/>
                </localityStack><display-text>the reference</display-text></eref>
            </p>
          </foreword>
        </preface>
        <sections>
        </sections>
        <bibliography>
          <references id="_" normative="true" obligation="informative">
            <title>Normative references</title>
            <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
            <bibitem id="iso216" type="standard">
              <title format="text/plain">Reference</title>
              <docidentifier>ISO 216</docidentifier>
              <docnumber>216</docnumber>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>International Organization for Standardization</name>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
            </bibitem>
          </references>
        </bibliography>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "strips type from xrefs" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      <<iso216>>

      [bibliography]
      == Clause
      * [[[iso216,ISO 216]]], _Reference_
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">
              <eref bibitemid="iso216" citeas="ISO&#xa0;216" type="inline"/>
            </p>
          </foreword>
        </preface>
        <sections>
        </sections>
        <bibliography>
          <references id="_" normative="false" obligation="informative">
            <title>Bibliography</title>
            <bibitem id="iso216" type="standard">
              <title format="text/plain">Reference</title>
              <docidentifier>ISO 216</docidentifier>
              <docnumber>216</docnumber>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>International Organization for Standardization</name>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
            </bibitem>
          </references>
        </bibliography>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes localities in term sources" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      Definition

      [.source]
      <<ISO2191,section=1>>
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>
            #{TERM_BOILERPLATE}
            <term id="term-Term1">
              <preferred><expression><name>Term1</name></expression></preferred>
                      <definition>
          <verbal-definition>
            <p id='_'>Definition</p>
          </verbal-definition>
        </definition>
        <source status='identical' type='authoritative'>
                <origin bibitemid="ISO2191" citeas="" type="inline">
                  <localityStack>
                    <locality type="section">
                      <referenceFrom>1</referenceFrom></locality>
                  </localityStack>
                </origin>
              </source>
            </term>
          </terms>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "removes extraneous material from Normative References" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      This is extraneous information

      * [[[iso216,ISO 216]]], _Reference_
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections></sections>
        <bibliography>
          <references id="_" normative="true" obligation="informative">
            <title>Normative references</title>
            <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
            <bibitem id="iso216" type="standard">
              <title format="text/plain">Reference</title>
              <docidentifier>ISO 216</docidentifier>
              <docnumber>216</docnumber>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>International Organization for Standardization</name>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
            </bibitem>
          </references>
        </bibliography>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "moves table key inside table" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      |===
      |a |b |c
      |===

      Key

      a:: b
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <table id="_">
            <tbody>
              <tr>
                <td align="left" valign="top">a</td>
                <td align="left" valign="top">b</td>
                <td align="left" valign="top">c</td>
              </tr>
            </tbody>
            <dl id="_" key="true">
              <dt>a</dt>
              <dd>
                <p id="_">b</p>
              </dd>
            </dl>
          </table>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes headerrows attribute for table without header rows" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [headerrows=3]
      |===
      |a |b |c
      |a |b |c
      |a |b |c
      |a |b |c
      |===
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <table id="_">
            <thead>
              <tr>
                <th align="left" valign="top">a</th>
                <th align="left" valign="top">b</th>
                <th align="left" valign="top">c</th>
              </tr>
              <tr>
                <th align="left" valign="top">a</th>
                <th align="left" valign="top">b</th>
                <th align="left" valign="top">c</th>
              </tr>
              <tr>
                <th align="left" valign="top">a</th>
                <th align="left" valign="top">b</th>
                <th align="left" valign="top">c</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td align="left" valign="top">a</td>
                <td align="left" valign="top">b</td>
                <td align="left" valign="top">c</td>
              </tr>
            </tbody>
          </table>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes headerrows attribute for table with header rows" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [headerrows=3]
      |===
      |a |b |c

      |a |b |c
      |a |b |c
      |a |b |c
      |===
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <table id="_">
            <thead>
              <tr>
                <th align="left" valign="top">a</th>
                <th align="left" valign="top">b</th>
                <th align="left" valign="top">c</th>
              </tr>
              <tr>
                <th align="left" valign="top">a</th>
                <th align="left" valign="top">b</th>
                <th align="left" valign="top">c</th>
              </tr>
              <tr>
                <th align="left" valign="top">a</th>
                <th align="left" valign="top">b</th>
                <th align="left" valign="top">c</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td align="left" valign="top">a</td>
                <td align="left" valign="top">b</td>
                <td align="left" valign="top">c</td>
              </tr>
            </tbody>
          </table>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "moves table notes inside table" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      |===
      |a |b |c
      |===

      NOTE: Note 1

      NOTE: Note 2
    INPUT
    output = <<~OUTPUT
       #{BLANK_HDR}
        <sections>
          <table id="_">
            <tbody>
              <tr>
                <td align="left" valign="top">a</td>
                <td align="left" valign="top">b</td>
                <td align="left" valign="top">c</td>
              </tr>
            </tbody>
            <note id="_">
              <p id="_">Note 1</p>
            </note>
            <note id="_">
              <p id="_">Note 2</p>
            </note>
          </table>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "moves formula key inside formula" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [stem]
      ++++
      Formula
      ++++

      where

      a:: b
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <formula id="_">
            <stem type="MathML" block="true">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <mstyle displaystyle="true">
                   <mi>F</mi>
                   <mi>o</mi>
                   <mstyle mathvariant="normal">
                     <munder>
                       <mi>a</mi>
                       <mo>̲</mo>
                     </munder>
                   </mstyle>
                 </mstyle>
              </math>
              <asciimath>Formula</asciimath>
            </stem>
            <dl id="_" key="true">
              <dt>a</dt>
              <dd>
                <p id="_">b</p>
              </dd>
            </dl>
          </formula>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "moves footnotes inside figures" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      image::spec/examples/rice_images/rice_image1.png[]

      footnote:[This is a footnote to a figure]

      footnote:[This is another footnote to a figure]
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <figure id="_">
            <image height="auto" id="_" mimetype="image/png" src="spec/examples/rice_images/rice_image1.png" width="auto"/>
            <fn reference="a">
              <p id="_">This is a footnote to a figure</p>
            </fn>
            <fn reference="b">
              <p id="_">This is another footnote to a figure</p>
            </fn>
          </figure>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "moves figure key inside figure" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      image::spec/examples/rice_images/rice_image1.png[]

      Key

      a:: b
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <figure id="_">
            <image height="auto" id="_" mimetype="image/png" src="spec/examples/rice_images/rice_image1.png" width="auto"/>
            <dl id="_" key="true">
              <dt>a</dt>
              <dd>
                <p id="_">b</p>
              </dd>
            </dl>
          </figure>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "numbers bibliographic notes and footnotes sequentially" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      footnote:[Footnote]

      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:--]]] footnote:[The standard is in press] _Standard_

      == Clause
      footnote:[Footnote2]
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">
              <fn reference="1">
                <p id="_">Footnote</p>
              </fn>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Clause</title>
            <p id="_">
              <fn reference="2">
                <p id="_">Footnote2</p>
              </fn>
            </p>
          </clause>
        </sections>
        <bibliography>
          <references id="_" normative="true" obligation="informative">
            <title>Normative references</title>
            <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
            <bibitem id="iso123" type="standard">
              <title format="text/plain">Standard</title>
              <docidentifier>ISO 123:—</docidentifier>
              <docnumber>123</docnumber>
              <date type="published">
                <on>–</on>
              </date>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>International Organization for Standardization</name>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
              <note format="text/plain" type="Unpublished-Status">The standard is in press</note>
            </bibitem>
          </references>
        </bibliography>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "defaults section obligations" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      == Clause
      Text

      [appendix]
      == Clause

      Text
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Clause</title>
            <p id="_">Text</p>
          </clause>
        </sections>
        <annex id="_" inline-header="false" obligation="normative">
          <title>Clause</title>
          <p id="_">Text</p>
        </annex>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "extends clause levels past 5" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      == Clause1

      === Clause2

      ==== Clause3

      ===== Clause4

      ====== Clause 5

      [level=6]
      ====== Clause 6

      [level=7]
      ====== Clause 7A

      [level=7]
      ====== Clause 7B

      [level=6]
      ====== Clause 6B

      ====== Clause 5B

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Clause1</title>
            <clause id="_" inline-header="false" obligation="normative">
              <title>Clause2</title>
              <clause id="_" inline-header="false" obligation="normative">
                <title>Clause3</title>
                <clause id="_" inline-header="false" obligation="normative">
                  <title>Clause4</title>
                  <clause id="_" inline-header="false" obligation="normative">
                    <title>Clause 5</title>
                    <clause id="_" inline-header="false" obligation="normative">
                      <title>Clause 6</title>
                      <clause id="_" inline-header="false" obligation="normative">
                        <title>Clause 7A</title>
                      </clause>
                      <clause id="_" inline-header="false" obligation="normative">
                        <title>Clause 7B</title>
                      </clause>
                    </clause>
                    <clause id="_" inline-header="false" obligation="normative">
                      <title>Clause 6B</title>
                    </clause>
                  </clause>
                  <clause id="_" inline-header="false" obligation="normative">
                    <title>Clause 5B</title>
                  </clause>
                </clause>
              </clause>
            </clause>
          </clause>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "reorders references in bibliography, and renumbers citations accordingly" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      == Clause 1
      <<ref1>>
      <<ref1a>>
      <<ref1b>>
      <<ref2>>
      <<ref3>>
      <<ref4>>
      <<ref5>>
      <<ref6>>
      <<ref7>>
      <<ref8>>
      <<ref9>>
      <<ref10>>

      [bibliography]
      == Bibliography

      [bibliography]
      === Clause 1
      * [[[ref3,IEC 123]]], _Standard IEC 123_
      * [[[ref5,20]]], _Standard 10_
      * [[[ref1,ISO 123]]], _Standard ISO 123_
      * [[[ref1a,ISO 123-100]]], _Standard ISO 123_
      * [[[ref1b,ISO/TS 123-1]]], _Standard ISO 123_
      * [[[ref4,GB 123]]], _Standard GB 123_
      * [[[ref2,ISO/IEC 123]]], _Standard ISO/IEC 123_
      * [[[ref6,(B)]]], _Standard 20_
      * [[[ref7,(A)]]], _Standard 30_

      [bibliography]
      === {blank}
      * [[[ref15,20]]], _Standard 10_
      * [[[ref14,GB 123]]], _Standard GB 123_
      * [[[ref13,IEC 123]]], _Standard IEC 123_
      * [[[ref11,ISO 123]]], _Standard ISO 123_
      * [[[ref10,ISO/IEC 123]]], _Standard ISO/IEC 123_
      * [[[ref16,(B)]]], _Standard 20_
      * [[[ref17,(A)]]], _Standard 30_
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
               <sections>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>Clause 1</title>
             <p id='_'>
               <eref type='inline' bibitemid='ref1' citeas='ISO&#xa0;123'/>
               <eref type='inline' bibitemid='ref1a' citeas='ISO&#xa0;123-100'/>
               <eref type='inline' bibitemid='ref1b' citeas='ISO/TS&#xa0;123-1'/>
               <eref type='inline' bibitemid='ref2' citeas='ISO/IEC&#xa0;123'/>
               <eref type='inline' bibitemid='ref3' citeas='IEC&#xa0;123'/>
               <eref type='inline' bibitemid='ref4' citeas='GB&#xa0;123'/>
               <eref type='inline' bibitemid='ref5' citeas='[7]'/>
               <eref type='inline' bibitemid='ref6' citeas='[B]'/>
               <eref type='inline' bibitemid='ref7' citeas='[A]'/>
               <xref target='ref8'/>
               <xref target='ref9'/>
               <eref type='inline' bibitemid='ref10' citeas='ISO/IEC&#xa0;123'/>
             </p>
           </clause>
         </sections>
         <bibliography>
           <clause id='_' obligation='informative'>
             <title>Bibliography</title>
             <references id='_' normative='false' obligation='informative'>
               <title>Clause 1</title>
               <bibitem id='ref1' type='standard'>
                 <title format='text/plain'>Standard ISO 123</title>
                 <docidentifier>ISO 123</docidentifier>
                 <docnumber>123</docnumber>
                 <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>International Organization for Standardization</name>
                     <abbreviation>ISO</abbreviation>
                   </organization>
                 </contributor>
               </bibitem>
               <bibitem id='ref2' type='standard'>
                 <title format='text/plain'>Standard ISO/IEC 123</title>
                 <docidentifier>ISO/IEC 123</docidentifier>
                 <docnumber>123</docnumber>
                 <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>International Organization for Standardization</name>
                     <abbreviation>ISO</abbreviation>
                   </organization>
                 </contributor>
                 <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>International Electrotechnical Commission</name>
                     <abbreviation>IEC</abbreviation>
                   </organization>
                 </contributor>
               </bibitem>
               <bibitem id='ref1b' type='standard'>
                 <title format='text/plain'>Standard ISO 123</title>
                 <docidentifier>ISO/TS 123-1</docidentifier>
                 <docnumber>123-1</docnumber>
                 <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>International Organization for Standardization</name>
                     <abbreviation>ISO</abbreviation>
                   </organization>
                 </contributor>
                 <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>TS</name>
                   </organization>
                 </contributor>
               </bibitem>
               <bibitem id='ref1a' type='standard'>
                 <title format='text/plain'>Standard ISO 123</title>
                 <docidentifier>ISO 123-100</docidentifier>
                 <docnumber>123-100</docnumber>
                 <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>International Organization for Standardization</name>
                     <abbreviation>ISO</abbreviation>
                   </organization>
                 </contributor>
               </bibitem>
               <bibitem id='ref3' type='standard'>
                 <title format='text/plain'>Standard IEC 123</title>
                 <docidentifier>IEC 123</docidentifier>
                 <docnumber>123</docnumber>
                 <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>International Electrotechnical Commission</name>
                     <abbreviation>IEC</abbreviation>
                   </organization>
                 </contributor>
               </bibitem>
               <bibitem id='ref4'>
                 <formattedref format='application/x-isodoc+xml'>
                   <em>Standard GB 123</em>
                 </formattedref>
                 <docidentifier>GB 123</docidentifier>
                 <docnumber>123</docnumber>
               </bibitem>
               <bibitem id='ref5'>
                 <formattedref format='application/x-isodoc+xml'>
                   <em>Standard 10</em>
                 </formattedref>
                 <docidentifier type='metanorma'>[7]</docidentifier>
               </bibitem>
               <bibitem id='ref7'>
                 <formattedref format='application/x-isodoc+xml'>
                   <em>Standard 30</em>
                 </formattedref>
                 <docidentifier type='metanorma'>[A]</docidentifier>
               </bibitem>
               <bibitem id='ref6'>
                 <formattedref format='application/x-isodoc+xml'>
                   <em>Standard 20</em>
                 </formattedref>
                 <docidentifier type='metanorma'>[B]</docidentifier>
               </bibitem>
             </references>
             <references id='_' normative='false' obligation='informative'>
               <bibitem id='ref11' type='standard'>
                 <title format='text/plain'>Standard ISO 123</title>
                 <docidentifier>ISO 123</docidentifier>
                 <docnumber>123</docnumber>
                 <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>International Organization for Standardization</name>
                     <abbreviation>ISO</abbreviation>
                   </organization>
                 </contributor>
               </bibitem>
               <bibitem id='ref10' type='standard'>
                 <title format='text/plain'>Standard ISO/IEC 123</title>
                 <docidentifier>ISO/IEC 123</docidentifier>
                 <docnumber>123</docnumber>
                 <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>International Organization for Standardization</name>
                     <abbreviation>ISO</abbreviation>
                   </organization>
                 </contributor>
                 <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>International Electrotechnical Commission</name>
                     <abbreviation>IEC</abbreviation>
                   </organization>
                 </contributor>
               </bibitem>
               <bibitem id='ref13' type='standard'>
                 <title format='text/plain'>Standard IEC 123</title>
                 <docidentifier>IEC 123</docidentifier>
                 <docnumber>123</docnumber>
                 <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>International Electrotechnical Commission</name>
                     <abbreviation>IEC</abbreviation>
                   </organization>
                 </contributor>
               </bibitem>
               <bibitem id='ref14'>
                 <formattedref format='application/x-isodoc+xml'>
                   <em>Standard GB 123</em>
                 </formattedref>
                 <docidentifier>GB 123</docidentifier>
                 <docnumber>123</docnumber>
               </bibitem>
               <bibitem id='ref15'>
                 <formattedref format='application/x-isodoc+xml'>
                   <em>Standard 10</em>
                 </formattedref>
                 <docidentifier type='metanorma'>[14]</docidentifier>
               </bibitem>
               <bibitem id='ref17'>
                 <formattedref format='application/x-isodoc+xml'>
                   <em>Standard 30</em>
                 </formattedref>
                 <docidentifier type='metanorma'>[A]</docidentifier>
               </bibitem>
               <bibitem id='ref16'>
                 <formattedref format='application/x-isodoc+xml'>
                   <em>Standard 20</em>
                 </formattedref>
                 <docidentifier type='metanorma'>[B]</docidentifier>
               </bibitem>
             </references>
           </clause>
         </bibliography>
       </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  context "terms & definitions boilerplate" do
    it "places normal terms & definitions boilerplate in flat clause" do
      input = <<~INPUT
        #{ASCIIDOC_BLANK_HDR}

        == Terms and definitions

        === Term1
      INPUT
      output = <<~OUTPUT
        #{BLANK_HDR}
        <sections>
          <terms id='_' obligation='normative'>
            <title>Terms and definitions</title>
            <p id='_'>For the purposes of this document, the following terms and definitions apply.</p>
            <p id='_'>
              ISO and IEC maintain terminology databases for use in standardization
              at the following addresses:
            </p>
            <ul id='_'>
              <li>
                <p id='_'>
                  ISO Online browsing platform: available at
                  <link target='https://www.iso.org/obp'/>
                </p>
              </li>
              <li>
                <p id='_'>
                  IEC Electropedia: available at
                  <link target='https://www.electropedia.org'/>
                </p>
              </li>
            </ul>
            <term id='term-Term1'>
              <preferred><expression><name>Term1</name></expression></preferred>
            </term>
          </terms>
        </sections>
        </metanorma>
      OUTPUT
      expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to Xml::C14n.format(output)
    end

    it "places normal terms & definitions boilerplate in multi-clause" do
      input = <<~INPUT
        #{ASCIIDOC_BLANK_HDR}

        == Terms and definitions

        === Normal Terms

        ==== Term1

        === Abnormal terms

        ==== Term 2
      INPUT
      output = <<~OUTPUT
        #{BLANK_HDR}
          <sections>
            <clause id='_' obligation='normative' type="terms">
              <title>Terms and definitions</title>
              <p id='_'>For the purposes of this document, the following terms and definitions apply.</p>
              <p id='_'>
                ISO and IEC maintain terminology databases for use in standardization
                at the following addresses:
              </p>
              <ul id='_'>
                <li>
                  <p id='_'>
                    ISO Online browsing platform: available at
                    <link target='https://www.iso.org/obp'/>
                  </p>
                </li>
                <li>
                  <p id='_'>
                    IEC Electropedia: available at
                    <link target='https://www.electropedia.org'/>
                  </p>
                </li>
              </ul>
              <terms id='_' obligation='normative'>
                <title>Normal Terms</title>
                <term id='term-Term1'>
                  <preferred><expression><name>Term1</name></expression></preferred>
                </term>
              </terms>
              <terms id='_' obligation='normative'>
                <title>Abnormal terms</title>
                <term id='term-Term-2'>
                  <preferred><expression><name>Term 2</name></expression></preferred>
                </term>
              </terms>
            </clause>
          </sections>
        </metanorma>
      OUTPUT
      expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to Xml::C14n.format(output)
    end

    it "places normal terms & definitions boilerplate in single clause that excludes symbols" do
      input = <<~INPUT
        #{ASCIIDOC_BLANK_HDR}

        == Terms, definitions, symbols and abbreviated terms

        === Terms and definitions

        ==== Normal Terms

        ===== Term1

        ==== Abnormal terms

        ===== Term 2

        === Symbols and abbreviated terms
      INPUT
      output = <<~OUTPUT
        #{BLANK_HDR}
          <sections>
            <clause id='_' obligation='normative' type="terms">
              <title>Terms, definitions, symbols and abbreviated terms</title>
              <clause id='_' obligation='normative' type="terms">
                <title>Terms and definitions</title>
                <p id='_'>For the purposes of this document, the following terms and definitions apply.</p>
                <p id='_'>
                  ISO and IEC maintain terminology databases for use in
                  standardization at the following addresses:
                </p>
                <ul id='_'>
                  <li>
                    <p id='_'>
                      ISO Online browsing platform: available at
                      <link target='https://www.iso.org/obp'/>
                    </p>
                  </li>
                  <li>
                    <p id='_'>
                      IEC Electropedia: available at
                      <link target='https://www.electropedia.org'/>
                    </p>
                  </li>
                </ul>
                <terms id='_' obligation='normative'>
                  <title>Normal Terms</title>
                  <term id='term-Term1'>
                    <preferred><expression><name>Term1</name></expression></preferred>
                  </term>
                </terms>
                <terms id='_' obligation='normative'>
                  <title>Abnormal terms</title>
                  <term id='term-Term-2'>
                    <preferred><expression><name>Term 2</name></expression></preferred>
                  </term>
                </terms>
              </clause>
              <definitions id='_' obligation='normative'>
                <title>Symbols and abbreviated terms</title>
              </definitions>
            </clause>
          </sections>
        </metanorma>
      OUTPUT
      expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to Xml::C14n.format(output)
    end

    it "places normal terms & definitions boilerplate in first of multiple clauses that excludes symbols" do
      input = <<~INPUT
        #{ASCIIDOC_BLANK_HDR}

        == Terms, definitions, symbols and abbreviated terms

        === Terms and definitions

        ==== Term1

        [heading=terms]
        === Other Terms

        ==== Term 2

        === Symbols and abbreviated terms
      INPUT
      output = <<~OUTPUT
        #{BLANK_HDR}
          <sections>
            <clause id='_' obligation='normative' type="terms">
              <title>Terms, definitions, symbols and abbreviated terms</title>
              <terms id='_' obligation='normative'>
                <title>Terms and definitions</title>
                <p id='_'>For the purposes of this document, the following terms and definitions apply.</p>
                <p id='_'>
                  ISO and IEC maintain terminology databases for use in
                  standardization at the following addresses:
                </p>
                <ul id='_'>
                  <li>
                    <p id='_'>
                      ISO Online browsing platform: available at
                      <link target='https://www.iso.org/obp'/>
                    </p>
                  </li>
                  <li>
                    <p id='_'>
                      IEC Electropedia: available at
                      <link target='https://www.electropedia.org'/>
                    </p>
                  </li>
                </ul>
                <term id='term-Term1'>
                  <preferred><expression><name>Term1</name></expression></preferred>
                </term>
              </terms>
              <terms id='_' obligation='normative'>
                <title>Other Terms</title>
                <term id='term-Term-2'>
                  <preferred><expression><name>Term 2</name></expression></preferred>
                </term>
              </terms>
              <definitions id='_' obligation='normative'>
                <title>Symbols and abbreviated terms</title>
              </definitions>
            </clause>
          </sections>
        </metanorma>
      OUTPUT
      expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to Xml::C14n.format(output)
    end

    it "places normal terms & definitions boilerplate at root if first of multiple clauses that excludes symbols is preceded by clause" do
      input = <<~INPUT
        #{ASCIIDOC_BLANK_HDR}

        == Terms, definitions, symbols and abbreviated terms

        [.nonterm]
        === Prefatory clause

        === Terms and definitions

        ==== Term1

        [heading=terms]
        === Other Terms

        ==== Term 2

        === Symbols and abbreviated terms
      INPUT
      output = <<~OUTPUT
        #{BLANK_HDR}
         <sections>
            <clause id="_" obligation="normative" type="terms">
              <title>Terms, definitions, symbols and abbreviated terms</title>
                <p id="_">For the purposes of this document,
            the following terms and definitions apply.</p>
                <p id="_">ISO and IEC maintain terminology databases for use in
        standardization at the following addresses:</p>
                <ul id="_">
                  <li>
                    <p id="_">ISO Online browsing platform: available at
          <link target="https://www.iso.org/obp"/></p>
                  </li>
                  <li>
                    <p id="_">IEC Electropedia: available at
        <link target="https://www.electropedia.org"/></p>
                  </li>
                </ul>
                <clause id="_" inline-header="false" obligation="normative">
                  <title>Prefatory clause</title>
                </clause>
              <terms id="_" obligation="normative">
                <title>Terms and definitions</title>
                <term id="term-Term1">
                  <preferred>
                    <expression>
                      <name>Term1</name>
                    </expression>
                  </preferred>
                </term>
              </terms>
              <terms id="_" obligation="normative">
                <title>Other Terms</title>
                <term id="term-Term-2">
                  <preferred>
                    <expression>
                      <name>Term 2</name>
                    </expression>
                  </preferred>
                </term>
              </terms>
              <definitions id="_" obligation="normative">
                <title>Symbols and abbreviated terms</title>
              </definitions>
            </clause>
          </sections>
        </metanorma>
      OUTPUT
      expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to Xml::C14n.format(output)
    end

    it "places boilerplate in Normative References subclause" do
      input = <<~INPUT
        #{ASCIIDOC_BLANK_HDR}

        [type=section]
        == General

        [heading=scope]
        === Scope

        This part of ISO 7005 for a single of flanges

        [bibliography,heading=normative references]
        === Normative references
      INPUT
      output = <<~OUTPUT
        #{BLANK_HDR}
        <sections>
            <clause id="_" type="section" inline-header="false" obligation="normative">
              <title>General</title>
              <clause id="_" type="scope" inline-header="false" obligation="normative">
                <title>Scope</title>
                <p id="_">This part of ISO 7005 for a single of flanges</p>
              </clause>
              <references id="_" normative="true" obligation="informative">
                <title>Normative references</title>
                <p id="_">There are no normative references in this document.</p>
              </references>
            </clause>
          </sections>
        </metanorma>
      OUTPUT
      expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to Xml::C14n.format(output)
    end

    it "places user-defined boilerplate in Normative References subclause" do
      input = <<~INPUT
        #{ASCIIDOC_BLANK_HDR}

        [type=section]
        == General

        [heading=scope]
        === Scope

        This part of ISO 7005 for a single of flanges

        [bibliography,heading=normative references]
        === Normative references

        [.boilerplate]
        --
        The following standards contain provisions
        --
      INPUT
      output = <<~OUTPUT
        #{BLANK_HDR}
        <sections>
            <clause id="_" type="section" inline-header="false" obligation="normative">
              <title>General</title>
              <clause id="_" type="scope" inline-header="false" obligation="normative">
                <title>Scope</title>
                <p id="_">This part of ISO 7005 for a single of flanges</p>
              </clause>
              <references id="_" normative="true" obligation="informative">
                <title>Normative references</title>
                <p id="_">The following standards contain provisions</p>
              </references>
            </clause>
          </sections>
        </metanorma>
      OUTPUT
      expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to Xml::C14n.format(output)
    end

    it "modifies normal terms & definitions boilerplate in vocabulary document" do
      input = <<~INPUT
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:
        :no-isobib:
        :docsubtype: vocabulary

        == Terms and definitions

        === Term1
      INPUT
      output = <<~OUTPUT
        #{BLANK_HDR.sub(%r{</doctype>}, '</doctype><subdoctype>vocabulary</subdoctype>')}
        <sections>
          <terms id='_' obligation='normative'>
            <title>Terms and definitions</title>
            <p id='_'>
              ISO and IEC maintain terminology databases for use in standardization
              at the following addresses:
            </p>
            <ul id='_'>
              <li>
                <p id='_'>
                  ISO Online browsing platform: available at
                  <link target='https://www.iso.org/obp'/>
                </p>
              </li>
              <li>
                <p id='_'>
                  IEC Electropedia: available at
                  <link target='https://www.electropedia.org'/>
                </p>
              </li>
            </ul>
            <term id='term-Term1'>
              <preferred><expression><name>Term1</name></expression></preferred>
            </term>
          </terms>
        </sections>
        </metanorma>
      OUTPUT
      expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to Xml::C14n.format(output)
    end

    it "does not allows subterms outside of vocabulary document" do
      input = <<~INPUT
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:
        :no-isobib:

        == Terms and definitions

        === Term1

        === Term2

        ==== Term2a
      INPUT
      output = <<~OUTPUT
         #{BLANK_HDR}
         <sections>
            <terms id='_' obligation='normative'>
              <title>Terms and definitions</title>
              <p id='_'>For the purposes of this document, the following terms and definitions apply.</p>
              <p id='_'>
                ISO and IEC maintain terminology databases for use in standardization at
                the following addresses:
              </p>
              <ul id='_'>
                <li>
                  <p id='_'>
                    ISO Online browsing platform: available at
                    <link target='https://www.iso.org/obp'/>
                  </p>
                </li>
                <li>
                  <p id='_'>
                    IEC Electropedia: available at
                    <link target='https://www.electropedia.org'/>
                  </p>
                </li>
              </ul>
              <term id='term-Term1'>
                <preferred>
                  <expression>
                    <name>Term1</name>
                  </expression>
                </preferred>
              </term>
              <terms id='_' obligation='normative'>
                <title>Term2</title>
                <term id='term-Term2a'>
                  <preferred>
                    <expression>
                      <name>Term2a</name>
                    </expression>
                  </preferred>
                </term>
              </terms>
            </terms>
          </sections>
        </metanorma>
      OUTPUT
      expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to Xml::C14n.format(output)
    end

    it "allows subterms in document" do
      input = <<~INPUT
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:
        :no-isobib:

        == Terms and definitions

        === Term1

        === Term2-Hierarchical

        Definition

        ==== Term2a

        === Term3-Grouping

        ==== Term3a

        [.grouping]
        === Term4-Hierarchical

        Definition

        ==== Term4a

      INPUT
      output = <<~OUTPUT
         #{BLANK_HDR}
                  <sections>
            <terms id="_" obligation="normative">
              <title>Terms and definitions</title>
                 <p id="_">For the purposes of this document,
            the following terms and definitions apply.</p>
              <p id="_">ISO and IEC maintain terminology databases for use in
            standardization at the following addresses:</p>
              <ul id="_">
                <li>
                  <p id="_">ISO Online browsing platform: available at
          <link target="https://www.iso.org/obp"/></p>
                </li>
                <li>
                  <p id="_">IEC Electropedia: available at
        <link target="https://www.electropedia.org"/></p>
                </li>
              </ul>
              <term id="term-Term1">
                <preferred>
                  <expression>
                    <name>Term1</name>
                  </expression>
                </preferred>
              </term>
              <term id="term-Term2-Hierarchical">
                <preferred>
                  <expression>
                    <name>Term2-Hierarchical</name>
                  </expression>
                </preferred>
                <definition>
                  <verbal-definition>
                    <p id="_">Definition</p>
                  </verbal-definition>
                </definition>
                <term id="term-Term2a">
                  <preferred>
                    <expression>
                      <name>Term2a</name>
                    </expression>
                  </preferred>
                </term>
              </term>
              <terms id="_" obligation="normative">
                <title>Term3-Grouping</title>
                <term id="term-Term3a">
                  <preferred>
                    <expression>
                      <name>Term3a</name>
                    </expression>
                  </preferred>
                </term>
              </terms>
              <terms id="_" obligation="normative">
                <title>Term4-Hierarchical</title>
                <p id="_">Definition</p>
                <term id="term-Term4a">
                  <preferred>
                    <expression>
                      <name>Term4a</name>
                    </expression>
                  </preferred>
                </term>
              </terms>
            </terms>
          </sections>
        </metanorma>
      OUTPUT
      expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to Xml::C14n.format(output)
    end
  end

  private

  def mock_fdis
    expect(RelatonIso::IsoBibliography).to receive(:get)
      .with("ISO/FDIS 17664-1", nil, anything)
      .and_return("spec/assets/boilerplate.adoc")
  end
end
