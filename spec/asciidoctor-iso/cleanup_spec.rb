require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "removes empty text elements" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == {blank}
    INPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="normative"/>
        </sections>
      </iso-standard>
    OUTPUT
  end

  it "processes stem-only terms as admitted" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === stem:[t_90]

      stem:[t_91]

      Time
    INPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>
            #{TERM_BOILERPLATE}
            <term id="term-t90">
              <preferred>
                <stem type="MathML">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                    <msub>
                      <mrow>
                        <mi>t</mi></mrow>
                      <mrow>
                        <mn>90</mn>
                      </mrow>
                    </msub>
                  </math>
                </stem>
              </preferred>
              <admitted>
                <stem type="MathML">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                    <msub>
                      <mrow>
                        <mi>t</mi>
                      </mrow>
                      <mrow>
                        <mn>91</mn>
                      </mrow>
                    </msub>
                  </math>
                </stem>
              </admitted>
              <definition>
                <p id="_">Time</p>
              </definition>
            </term>
          </terms>
        </sections>
      </iso-standard>
    OUTPUT
  end

  it "moves term domains out of the term definition paragraph" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Tempus

      domain:[relativity] Time
    INPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>#{TERM_BOILERPLATE}

            <term id="term-tempus">
              <preferred>Tempus</preferred>
              <domain>relativity</domain>
              <definition>
                <p id="_">Time</p></definition>
            </term>
          </terms>
        </sections>
      </iso-standard>
    OUTPUT
  end

  it "permits multiple blocks in term definition paragraph" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :stem:
      :no-isobib:

      == Terms and Definitions

      === stem:[t_90]

      [stem]
      ++++
      t_A
      ++++

      This paragraph is extraneous
    INPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>
            #{TERM_BOILERPLATE}
            <term id="term-t90">
              <preferred>
                <stem type="MathML">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                    <msub>
                      <mrow>
                        <mi>t</mi></mrow>
                      <mrow>
                        <mn>90</mn>
                      </mrow>
                    </msub>
                  </math>
                </stem>
              </preferred>
              <definition>
                <formula id="_">
                  <stem type="MathML">
                    <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <msub>
                        <mrow>
                          <mi>t</mi>
                        </mrow>
                        <mrow>
                          <mi>A</mi>
                        </mrow>
                      </msub>
                    </math>
                  </stem>
                </formula>
                <p id="_">This paragraph is extraneous</p>
              </definition>
            </term>
          </terms>
        </sections>
       </iso-standard>
    OUTPUT
  end

  it "keeps any initial boilerplate from terms and definitions" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      I am boilerplate

      * So am I

      === Time

      This paragraph is extraneous
    INPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>#{TERM_BOILERPLATE}

            <p id="_">I am boilerplate</p>
            <ul id="_">
              <li>
                <p id="_">So am I</p></li>
            </ul>
            <term id="term-time">
              <preferred>Time</preferred>
              <definition>
                <p id="_">This paragraph is extraneous</p>
              </definition>
            </term>
          </terms>
        </sections>
      </iso-standard>
    OUTPUT
  end

  it "moves notes inside preceding blocks, if they are not at clause end, and the blocks are not delimited" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [stem]
      ++++
      r = 1 %
      r = 1 %
      ++++

      NOTE: That formula does not do much

      Indeed.
    INPUT
      #{BLANK_HDR}
        <sections>
          <formula id="_">
            <stem type="MathML">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <mi>r</mi>
                <mo>=</mo>
                <mn>1</mn>
                <mi>%</mi>
                <mi>r</mi>
                <mo>=</mo>
                <mn>1</mn>
                <mi>%</mi>
              </math>
            </stem>
            <note id="_">
              <p id="_">That formula does not do much</p>
            </note>
          </formula>
          <p id="_">Indeed.</p>
        </sections>
      </iso-standard>
    OUTPUT
  end

  it "does not move notes inside preceding blocks, if they are at clause end" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [source,ruby]
      [1...x].each do |y|
        puts y
      end

      NOTE: That loop does not do much
    INPUT
      #{BLANK_HDR}
        <sections>
          <sourcecode id="_" lang="ruby">[1...x].each do |y|
                 puts y
               end</sourcecode>
          <note id="_">
            <p id="_">That loop does not do much</p>
          </note>
        </sections>
      </iso-standard>
    OUTPUT
  end

  it "converts xrefs to references into erefs" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      <<iso216>>

      [bibliography]
      == Normative References
      * [[[iso216,ISO 216:2001]]], _Reference_
    INPUT
      #{BLANK_HDR}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">
              <eref bibitemid="iso216" citeas="ISO 216:2001" type="inline"/>
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
      </iso-standard>
    OUTPUT
  end

  it "extracts localities from erefs" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      <<iso216,whole,clause=3,example=9-11,locality:prelude=33,locality:entirety:the reference>>

      [bibliography]
      == Normative References
      * [[[iso216,ISO 216]]], _Reference_
    INPUT
      #{BLANK_HDR}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">
              <eref bibitemid="iso216" citeas="ISO 216" type="inline">
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
                </localityStack>the reference</eref>
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
      </iso-standard>
    OUTPUT
  end

  it "strips type from xrefs" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      <<iso216>>

      [bibliography]
      == Clause
      * [[[iso216,ISO 216]]], _Reference_
    INPUT
      #{BLANK_HDR}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">
              <eref bibitemid="iso216" citeas="ISO 216" type="inline"/>
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
      </iso-standard>
    OUTPUT
  end

  it "processes localities in term sources" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      [.source]
      <<ISO2191,section=1>>
    INPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>
            #{TERM_BOILERPLATE}
            <term id="term-term1">
              <preferred>Term1</preferred>
              <termsource status="identical">
                <origin bibitemid="ISO2191" citeas="" type="inline">
                  <localityStack>
                    <locality type="section">
                      <referenceFrom>1</referenceFrom></locality>
                  </localityStack>
                </origin>
              </termsource>
            </term>
          </terms>
        </sections>
      </iso-standard>
    OUTPUT
  end

  it "removes extraneous material from Normative References" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      This is extraneous information

      * [[[iso216,ISO 216]]], _Reference_
    INPUT
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
      </iso-standard>
    OUTPUT
  end

  it "inserts IDs into paragraphs" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      Paragraph
    INPUT
      #{BLANK_HDR}
        <sections>
          <p id="_">Paragraph</p>
        </sections>
      </iso-standard>
    OUTPUT
  end

  it "inserts IDs into notes" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [example]
      ====
      NOTE: This note has no ID
      ====
    INPUT
      #{BLANK_HDR}
        <sections>
          <example id="_">
            <note id="_">
              <p id="_">This note has no ID</p>
            </note>
          </example>
        </sections>
      </iso-standard>
    OUTPUT
  end

  it "moves table key inside table" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      |===
      |a |b |c
      |===

      Key

      a:: b
    INPUT
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
      </iso-standard>
    OUTPUT
  end

  it "processes headerrows attribute for table without header rows" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [headerrows=3]
      |===
      |a |b |c
      |a |b |c
      |a |b |c
      |a |b |c
      |===
    INPUT
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
      </iso-standard>
    OUTPUT
  end

  it "processes headerrows attribute for table with header rows" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [headerrows=3]
      |===
      |a |b |c

      |a |b |c
      |a |b |c
      |a |b |c
      |===
    INPUT
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
      </iso-standard>
    OUTPUT
  end

  it "moves table notes inside table" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      |===
      |a |b |c
      |===

      NOTE: Note 1

      NOTE: Note 2
    INPUT
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
      </iso-standard>
    OUTPUT
  end

  it "moves formula key inside formula" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [stem]
      ++++
      Formula
      ++++

      where

      a:: b
    INPUT
      #{BLANK_HDR}
        <sections>
          <formula id="_">
            <stem type="MathML">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <mi>F</mi>
                <mi>or</mi>
                <mi>μ</mi>
                <mi>l</mi>
                <mi>a</mi>
              </math>
            </stem>
            <dl id="_" key="true">
              <dt>a</dt>
              <dd>
                <p id="_">b</p>
              </dd>
            </dl>
          </formula>
        </sections>
      </iso-standard>
    OUTPUT
  end

  it "moves footnotes inside figures" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      image::spec/examples/rice_images/rice_image1.png[]

      footnote:[This is a footnote to a figure]

      footnote:[This is another footnote to a figure]
    INPUT
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
      </iso-standard>
    OUTPUT
  end

  it "moves figure key inside figure" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      image::spec/examples/rice_images/rice_image1.png[]

      Key

      a:: b
    INPUT
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
      </iso-standard>
    OUTPUT
  end

  it "numbers bibliographic notes and footnotes sequentially" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      footnote:[Footnote]

      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:--]]] footnote:[The standard is in press] _Standard_

      == Clause
      footnote:[Footnote2]
    INPUT
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
      </iso-standard>
    OUTPUT
  end

  it "defaults section obligations" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      == Clause
      Text

      [appendix]
      == Clause

      Text
    INPUT
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
      </iso-standard>
    OUTPUT
  end

  it "extends clause levels past 5" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
      </iso-standard>
    OUTPUT
  end

  it "reorders references in bibliography, and renumbers citations accordingly" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Clause 1</title>
            <p id="_">
              <eref bibitemid="ref1" citeas="ISO 123" type="inline"/>
              <eref bibitemid="ref1a" citeas="ISO 123-100" type="inline"/>
              <eref bibitemid="ref1b" citeas="ISO/TS 123-1" type="inline"/>
              <eref bibitemid="ref2" citeas="ISO/IEC 123" type="inline"/>
              <eref bibitemid="ref3" citeas="IEC 123" type="inline"/>
              <eref bibitemid="ref4" citeas="GB 123" type="inline"/>
              <eref bibitemid="ref5" citeas="[6]" type="inline"/>
              <eref bibitemid="ref6" citeas="[B]" type="inline"/>
              <eref bibitemid="ref7" citeas="[A]" type="inline"/>
              <xref target="ref8"/>
              <xref target="ref9"/>
              <eref bibitemid="ref10" citeas="ISO/IEC 123" type="inline"/>
            </p>
          </clause>
        </sections>
        <bibliography>
          <clause id="_" obligation="informative">
            <title>Bibliography</title>
            <references id="_" normative="false" obligation="informative">
              <title>Clause 1</title>
              <bibitem id="ref1" type="standard">
                <title format="text/plain">Standard ISO 123</title>
                <docidentifier>ISO 123</docidentifier>
                <docnumber>123</docnumber>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                  </organization>
                </contributor>
              </bibitem>
              <bibitem id="ref2" type="standard">
                <title format="text/plain">Standard ISO/IEC 123</title>
                <docidentifier>ISO/IEC 123</docidentifier>
                <docnumber>123</docnumber>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                  </organization>
                </contributor>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <name>International Electrotechnical Commission</name>
                    <abbreviation>IEC</abbreviation>
                  </organization>
                </contributor>
              </bibitem>
              <bibitem id="ref1b" type="standard">
                <title format="text/plain">Standard ISO 123</title>
                <docidentifier>ISO/TS 123-1</docidentifier>
                <docnumber>123-1</docnumber>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                  </organization>
                </contributor>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <name>TS</name>
                  </organization>
                </contributor>
              </bibitem>
              <bibitem id="ref1a" type="standard">
                <title format="text/plain">Standard ISO 123</title>
                <docidentifier>ISO 123-100</docidentifier>
                <docnumber>123-100</docnumber>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                  </organization>
                </contributor>
              </bibitem>
              <bibitem id="ref3" type="standard">
                <title format="text/plain">Standard IEC 123</title>
                <docidentifier>IEC 123</docidentifier>
                <docnumber>123</docnumber>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <name>International Electrotechnical Commission</name>
                    <abbreviation>IEC</abbreviation>
                  </organization>
                </contributor>
              </bibitem>
              <bibitem id="ref5">
                <formattedref format="application/x-isodoc+xml">
                  <em>Standard 10</em>
                </formattedref>
                <docidentifier type="metanorma">[6]</docidentifier>
              </bibitem>
              <bibitem id="ref6">
                <formattedref format="application/x-isodoc+xml">
                  <em>Standard 20</em>
                </formattedref>
                <docidentifier type="metanorma">[B]</docidentifier>
              </bibitem>
              <bibitem id="ref7">
                <formattedref format="application/x-isodoc+xml">
                  <em>Standard 30</em>
                </formattedref>
                <docidentifier type="metanorma">[A]</docidentifier>
              </bibitem>
              <bibitem id="ref4">
                <formattedref format="application/x-isodoc+xml">
                  <em>Standard GB 123</em>
                </formattedref>
                <docidentifier>GB 123</docidentifier>
                <docnumber>123</docnumber>
              </bibitem>
            </references>
            <references id="_" normative="false" obligation="informative">
              <bibitem id="ref11" type="standard">
                <title format="text/plain">Standard ISO 123</title>
                <docidentifier>ISO 123</docidentifier>
                <docnumber>123</docnumber>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                  </organization>
                </contributor>
              </bibitem>
              <bibitem id="ref10" type="standard">
                <title format="text/plain">Standard ISO/IEC 123</title>
                <docidentifier>ISO/IEC 123</docidentifier>
                <docnumber>123</docnumber>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                  </organization>
                </contributor>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <name>International Electrotechnical Commission</name>
                    <abbreviation>IEC</abbreviation>
                  </organization>
                </contributor>
              </bibitem>
              <bibitem id="ref13" type="standard">
                <title format="text/plain">Standard IEC 123</title>
                <docidentifier>IEC 123</docidentifier>
                <docnumber>123</docnumber>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <name>International Electrotechnical Commission</name>
                    <abbreviation>IEC</abbreviation>
                  </organization>
                </contributor>
              </bibitem>
              <bibitem id="ref15">
                <formattedref format="application/x-isodoc+xml">
                  <em>Standard 10</em>
                </formattedref>
                <docidentifier type="metanorma">[13]</docidentifier>
              </bibitem>
              <bibitem id="ref16">
                <formattedref format="application/x-isodoc+xml">
                  <em>Standard 20</em>
                </formattedref>
                <docidentifier type="metanorma">[B]</docidentifier>
              </bibitem>
              <bibitem id="ref17">
                <formattedref format="application/x-isodoc+xml">
                  <em>Standard 30</em>
                </formattedref>
                <docidentifier type="metanorma">[A]</docidentifier>
              </bibitem>
              <bibitem id="ref14">
                <formattedref format="application/x-isodoc+xml">
                  <em>Standard GB 123</em>
                </formattedref>
                <docidentifier>GB 123</docidentifier>
                <docnumber>123</docnumber>
              </bibitem>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    OUTPUT
  end
end
