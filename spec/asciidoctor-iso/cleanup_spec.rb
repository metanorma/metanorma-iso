require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "removes empty text elements" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      == {blank}
    INPUT
       #{BLANK_HDR}
              <sections>
         <clause id="_" inline-header="false" obligation="normative">
         
       </clause>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "processes stem-only terms as admitted" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === stem:[t_90]

      stem:[t_91]

      Time
    INPUT
       #{BLANK_HDR}
              <sections>
         <terms id="_" obligation="normative">
         <title>Terms and Definitions</title>
         <term id="_"><preferred><stem type="AsciiMath">t_90</stem></preferred><admitted><stem type="AsciiMath">t_91</stem></admitted>
       <definition><p id="_">Time</p></definition></term>
       </terms>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "moves term domains out of the term definition paragraph" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Tempus

      domain:[relativity] Time
    INPUT
       #{BLANK_HDR}
              <sections>
         <terms id="_" obligation="normative">
         <title>Terms and Definitions</title>
         <term id="_">
         <preferred>Tempus</preferred>
         <domain>relativity</domain><definition><p id="_"> Time</p></definition>
       </term>
       </terms>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "permits multiple blocks in term definition paragraph" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :stem:

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
         <title>Terms and Definitions</title>
         <term id="_"><preferred><stem type="AsciiMath">t_90</stem></preferred><definition><formula id="_">
         <stem type="AsciiMath">t_A</stem>
       </formula><p id="_">This paragraph is extraneous</p></definition>
       </term>
       </terms>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "strips any initial boilerplate from terms and definitions" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      I am boilerplate

      * So am I

      === Time

      This paragraph is extraneous
    INPUT
       #{BLANK_HDR}
              <sections>
         <terms id="_" obligation="normative"><title>Terms and Definitions</title>
     
       <term id="_">
       <preferred>Time</preferred>
         <definition><p id="_">This paragraph is extraneous</p></definition>
       </term></terms>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "moves notes inside preceding blocks, if they are not at clause end, and the blocks are not delimited" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
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
    <sections><formula id="_">
  <stem type="AsciiMath">r = 1 %
r = 1 %</stem>
<note id="_">
  <p id="_">That formula does not do much</p>
</note></formula>

       <p id="_">Indeed.</p></sections>
       </iso-standard>
    OUTPUT
  end

  it "does not move notes inside preceding blocks, if they are at clause end" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [source,ruby]
      [1...x].each do |y|
        puts y
      end

      NOTE: That loop does not do much
    INPUT
       #{BLANK_HDR}
              <sections><sourcecode id="_">[1...x].each do |y|
         puts y
       end</sourcecode>
       <note id="_">
         <p id="_">That loop does not do much</p>
       </note></sections>
       </iso-standard>
    OUTPUT
  end

  it "converts xrefs to references into erefs" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      <<iso216>>
 
      [bibliography]     
      == Normative References
      * [[[iso216,ISO 216:2001]]], _Reference_
    INPUT
       #{BLANK_HDR}
              <preface><foreword obligation="informative">
         <title>Foreword</title>
         <p id="_">
         <eref type="inline" bibitemid="iso216" citeas="ISO 216: 2001"/>
       </p>
       </foreword></preface><sections>
       </sections><bibliography><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso216" type="standard">
         <title format="text/plain">Reference</title>
         <docidentifier>ISO 216</docidentifier>
         <date type="published">
           <from>2001</from>
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
       </bibliography
       </iso-standard>
    OUTPUT
  end

  it "extracts localities from erefs" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      <<iso216,whole,clause 3,example 9-11,locality:prelude 33,locality:entirety:the reference>>

      [bibliography]
      == Normative References
      * [[[iso216,ISO 216]]], _Reference_
    INPUT
       #{BLANK_HDR}
       <preface>
       <foreword obligation="informative">
         <title>Foreword</title>
         <p id="_">
         <eref type="inline" bibitemid="iso216" citeas="ISO 216"><locality type="whole"/><locality type="clause"><referenceFrom>3</referenceFrom></locality><locality type="example"><referenceFrom>9</referenceFrom><referenceTo>11</referenceTo></locality><locality type="locality:prelude"><referenceFrom>33</referenceFrom></locality><locality type="locality:entirety"/>the reference</eref>
       </p>
       </foreword></preface><sections>
       </sections><bibliography><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso216" type="standard">
         <title format="text/plain">Reference</title>
         <docidentifier>ISO 216</docidentifier>
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
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      <<iso216>>
 
      [bibliography]
      == Clause
      * [[[iso216,ISO 216]]], _Reference_
    INPUT
       #{BLANK_HDR}
       <preface>
       <foreword obligation="informative">
         <title>Foreword</title>
         <p id="_">
         <eref type="inline" bibitemid="iso216" citeas=""/>
       </p>
       </foreword></preface><sections>
       <clause id="_" inline-header="false" obligation="normative">
         <title>Clause</title>
         <ul id="_">
         <li>
           <ref id="iso216">[ISO 216]</ref><p id="_">, <em>Reference</em></p>
         </li>
       </ul>
       </clause></sections>
       </iso-standard>
    OUTPUT
  end

  it "processes localities in term sources" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      [.source]
      <<ISO2191,section 1>>
      INPUT
              #{BLANK_HDR}
       <sections>
         <terms id="_" obligation="normative">
         <title>Terms and Definitions</title>
         <term id="_">
         <preferred>Term1</preferred>
         <termsource status="identical">
         <origin bibitemid="ISO2191" type="inline" citeas=""><locality type="section"><referenceFrom>1</referenceFrom></locality></origin>
       </termsource>
       </term>
       </terms>
       </sections>
       </iso-standard>
      OUTPUT
  end

  it "removes extraneous material from Normative References" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      This is extraneous information

      * [[[iso216,ISO 216]]], _Reference_
    INPUT
       #{BLANK_HDR}
              <sections>
         
       </sections><bibliography><references id="_" obligation="informative"><title>Normative References</title>
       <bibitem id="iso216" type="standard">
         <title format="text/plain">Reference</title>
         <docidentifier>ISO 216</docidentifier>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>International Organization for Standardization</name>
             <abbreviation>ISO</abbreviation>
           </organization>
         </contributor>
       </bibitem></references>
       </bibliography>
       </iso-standard>
    OUTPUT
  end

  it "inserts IDs into paragraphs" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
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
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
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
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      |===
      |a |b |c
      |===
      
      Key

      a:: b
    INPUT
       #{BLANK_HDR}
       <sections><table id="_">
         <tbody>
           <tr>
             <td align="left">a</td>
             <td align="left">b</td>
             <td align="left">c</td>
           </tr>
         </tbody>
       <dl id="_">
         <dt>a</dt>
         <dd>
           <p id="_">b</p>
         </dd>
       </dl></table>
     
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "processes headerrows attribute for table without header rows" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
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
             <table id="_"><thead><tr>
             <td align="left">a</td>
             <td align="left">b</td>
             <td align="left">c</td>
           </tr><tr>
             <td align="left">a</td>
             <td align="left">b</td>
             <td align="left">c</td>
           </tr><tr>
             <td align="left">a</td>
             <td align="left">b</td>
             <td align="left">c</td>
           </tr></thead>
         <tbody>
           <tr>
             <td align="left">a</td>
             <td align="left">b</td>
             <td align="left">c</td>
           </tr>
         </tbody>
       </table>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "processes headerrows attribute for table with header rows" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
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
             <th align="left">a</th>
             <th align="left">b</th>
             <th align="left">c</th>
           </tr>
         <tr>
             <td align="left">a</td>
             <td align="left">b</td>
             <td align="left">c</td>
           </tr><tr>
             <td align="left">a</td>
             <td align="left">b</td>
             <td align="left">c</td>
           </tr></thead>
         <tbody>


           <tr>
             <td align="left">a</td>
             <td align="left">b</td>
             <td align="left">c</td>
           </tr>
         </tbody>
       </table>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "moves table notes inside table" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      |===
      |a |b |c
      |===
      
      NOTE: Note 1

      NOTE: Note 2
    INPUT
       #{BLANK_HDR}
              <sections><table id="_">
         <tbody>
           <tr>
             <td align="left">a</td>
             <td align="left">b</td>
             <td align="left">c</td>
           </tr>
         </tbody>
       <note id="_">
         <p id="_">Note 1</p>
       </note><note id="_">
         <p id="_">Note 2</p>
       </note></table>
     
       </sections>
    OUTPUT
  end

  it "moves formula key inside formula" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [stem]
      ++++
      Formula
      ++++

      where

      a:: b
    INPUT
       #{BLANK_HDR}
       <sections><formula id="_">
         <stem type="AsciiMath">Formula</stem>
       <dl id="_">
         <dt>a</dt>
         <dd>
           <p id="_">b</p>
         </dd>
       </dl></formula>
     
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "moves footnotes inside figures" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      image::spec/examples/rice_images/rice_image1.png[]

      footnote:[This is a footnote to a figure]

      footnote:[This is another footnote to a figure]
    INPUT
       #{BLANK_HDR}
       <sections><figure id="_">
         <image src="spec/examples/rice_images/rice_image1.png" id="_" imagetype="PNG"/>
       <fn reference="a">
         <p id="_">This is a footnote to a figure</p>
       </fn><fn reference="b">
         <p id="_">This is another footnote to a figure</p>
       </fn></figure>
     
       </sections>

       </iso-standard>
    OUTPUT
  end

  it "moves figure key inside figure" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      image::spec/examples/rice_images/rice_image1.png[]

      Key

      a:: b
    INPUT
       #{BLANK_HDR}
       <sections><figure id="_">
         <image src="spec/examples/rice_images/rice_image1.png" id="_" imagetype="PNG"/>
       <dl id="_">
         <dt>a</dt>
         <dd>
           <p id="_">b</p>
         </dd>
       </dl></figure>
     
       </sections>

       </iso-standard>
    OUTPUT
  end

  it "processes subfigures" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [[figureC-2]]
      .Stages of gelatinization
      ====
      .Initial stages: No grains are fully gelatinized (ungelatinized starch granules are visible inside the kernels)
      image::spec/examples/rice_images/rice_image3_1.png[]
      
      .Intermediate stages: Some fully gelatinized kernels are visible
      image::spec/examples/rice_images/rice_image3_2.png[]
      
      .Final stages: All kernels are fully gelatinized
      image::spec/examples/rice_images/rice_image3_3.png[]
      ====
    INPUT
       #{BLANK_HDR}
              <sections>
         <figure id="figureC-2"><figure id="_">
         <name>Initial stages: No grains are fully gelatinized (ungelatinized starch granules are visible inside the kernels)</name>
         <image src="spec/examples/rice_images/rice_image3_1.png" id="_" imagetype="PNG"/>
       </figure>
       <figure id="_">
         <name>Intermediate stages: Some fully gelatinized kernels are visible</name>
         <image src="spec/examples/rice_images/rice_image3_2.png" id="_" imagetype="PNG"/>
       </figure>
       <figure id="_">
         <name>Final stages: All kernels are fully gelatinized</name>
         <image src="spec/examples/rice_images/rice_image3_3.png" id="_" imagetype="PNG"/>
       </figure></figure>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "numbers bibliographic notes and footnotes sequentially" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      footnote:[Footnote]

      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:--]]] footnote:[The standard is in press] _Standard_

      == Clause
      footnote:[Footnote2]
    INPUT
       #{BLANK_HDR}
       <preface><foreword obligation="informative">
         <title>Foreword</title>
         <p id="_"><fn reference="1">
         <p id="_">Footnote</p>
       </fn>
       </p>
       </foreword></preface><sections>
     
       <clause id="_" inline-header="false" obligation="normative">
         <title>Clause</title>
         <p id="_"><fn reference="3">
         <p id="_">Footnote2</p>
       </fn>
       </p>
       </clause></sections><bibliography><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso123" type="standard">
         <title format="text/plain">Standard</title>
         <docidentifier>ISO 123</docidentifier>
         <date type="published"><from>--</from></date>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>International Organization for Standardization</name>
             <abbreviation>ISO</abbreviation>
           </organization>
         </contributor>
         <note format="text/plain" reference="2">ISO DATE: The standard is in press</note>
       </bibitem>
       </references>
       </bibliography>
       </iso-standard>
    OUTPUT
  end

  it "defaults section obligations" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}

      == Clause
      Text

      [appendix]
      == Clause

      Text
    INPUT
       #{BLANK_HDR}
       <sections><clause id="_" inline-header="false" obligation="normative">
         <title>Clause</title>
         <p id="_">Text</p>
       </clause>
       </sections><annex id="_" inline-header="false" obligation="normative">
         <title>Clause</title>
         <p id="_">Text</p>
       </annex>
       </iso-standard>
    OUTPUT
  end






end
