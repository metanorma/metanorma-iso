require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "removes empty text elements" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

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
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

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
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

      == Terms and Definitions

      === stem:[t_90]

      domain:[relativity] Time
    INPUT
       #{BLANK_HDR}
              <sections>
         <terms id="_" obligation="normative">
         <title>Terms and Definitions</title>
         <term id="_">
         <preferred>
           <stem type="AsciiMath">t_90</stem>
         </preferred>
         <domain>relativity</domain><definition><p id="_"> Time</p></definition>
       </term>
       </terms>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "permits multiple blocks in term definition paragraph" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
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
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :stem:

      == Terms and Definitions

      I am boilerplate

      * So am I

      === stem:[t_90]

      This paragraph is extraneous
    INPUT
       #{BLANK_HDR}
              <sections>
         <terms id="_" obligation="normative"><title>Terms and Definitions</title>
     
       <term id="_">
         <preferred>
           <stem type="AsciiMath">t_90</stem>
         </preferred>
         <definition><p id="_">This paragraph is extraneous</p></definition>
       </term></terms>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "moves notes inside preceding blocks, if they are not at clause end" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :stem:

      [source,ruby]
      [1...x].each do |y|
        puts y
      end

      NOTE: That loop does not do much

      Indeed.
    INPUT
       #{BLANK_HDR}
       <sections><sourcecode id="_">[1...x].each do |y|
         puts y
       end<note id="_">
         <p id="_">That loop does not do much</p>
       </note></sourcecode>
     
       <p id="_">Indeed.</p></sections>
       </iso-standard>
    OUTPUT
  end

  it "does not move notes inside preceding blocks, if they are at clause end" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :stem:

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
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :stem:

      <<iso216>>
 
      [bibliography]     
      == Normative References
      * [[[iso216,ISO 216:2001]]], _Reference_
    INPUT
       #{BLANK_HDR}
              <foreword obligation="informative">
         <title>Foreword</title>
         <p id="_">
         <eref type="inline" bibitemid="iso216" citeas="ISO 216: 2001"/>
       </p>
       </foreword><sections>
       </sections><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso216" type="standard">
         <title format="text/plain">Reference</title>
         <docidentifier>ISO 216</docidentifier>
         <date type="published">2001</date>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>ISO</name>
           </organization>
         </contributor>
       </bibitem>
       </references>
       </iso-standard>
    OUTPUT
  end

  it "extracts localities from erefs" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :stem:

      <<iso216,whole,clause 3,example 9-11:the reference>>

      [bibliography]
      == Normative References
      * [[[iso216,ISO 216]]], _Reference_
    INPUT
       #{BLANK_HDR}
       <foreword obligation="informative">
         <title>Foreword</title>
         <p id="_">
         <eref type="inline" bibitemid="iso216" citeas="ISO 216"><locality type="whole"/><locality type="clause"><referenceFrom>3</referenceFrom></locality><locality type="example"><referenceFrom>9</referenceFrom><referenceTo>11</referenceTo></locality>the reference</eref>
       </p>
       </foreword><sections>
       </sections><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso216" type="standard">
         <title format="text/plain">Reference</title>
         <docidentifier>ISO 216</docidentifier>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>ISO</name>
           </organization>
         </contributor>
       </bibitem>
       </references>
       </iso-standard>
    OUTPUT
  end


  it "strips type from xrefs" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :stem:

      <<iso216>>
 
      == Clause
      * [[iso216,ISO 216]], _Reference_
    INPUT
       #{BLANK_HDR}
              <foreword obligation="informative">
         <title>Foreword</title>
         <p id="_">
         <xref target="iso216"/>
       </p>
       </foreword><sections>
       <clause id="_" inline-header="false" obligation="normative">
         <title>Clause</title>
         <ul id="_">
         <li>
           <p id="_"><bookmark id="iso216"/>, <em>Reference</em></p>
         </li>
       </ul>
       </clause></sections>
       </iso-standard>
    OUTPUT
  end

  it "processes localities in term sources" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

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
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :stem:

      [bibliography]
      == Normative References

      This is extraneous information

      * [[[iso216,ISO 216]]], _Reference_
    INPUT
       #{BLANK_HDR}
              <sections>
         
       </sections><references id="_" obligation="informative"><title>Normative References</title>
       <bibitem id="iso216" type="standard">
         <title format="text/plain">Reference</title>
         <docidentifier>ISO 216</docidentifier>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>ISO</name>
           </organization>
         </contributor>
       </bibitem></references>
       </iso-standard>
    OUTPUT
  end






end
