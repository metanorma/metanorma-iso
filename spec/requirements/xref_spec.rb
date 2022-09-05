require "spec_helper"

RSpec.describe Metanorma::Requirements::Iso::Modspec do
  it "cross-references requirements" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          </p>
          </foreword>
          <introduction id="intro">
          <requirement model="ogc" id="N1">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <clause id="xyz"><title>Preparatory</title>
          <requirement model="ogc" id="N2" unnumbered="true">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <requirement model="ogc" id="N">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <requirement model="ogc" id="note1">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement model="ogc" id="note2">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <requirement model="ogc" id="AN">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          <clause id="annex1b">
          <requirement model="ogc" id="Anote1" unnumbered="true">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement model="ogc" id="Anote2">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="1">
        <p>
          <xref target='N1'>Introduction, Requirement 1</xref>
          <xref target='N2'>Preparatory, Requirement (??)</xref>
          <xref target='N'>Clause 1, Requirement 2</xref>
          <xref target='note1'>Clause 3.1, Requirement 3</xref>
          <xref target='note2'>Clause 3.1, Requirement 4</xref>
          <xref target='AN'>Requirement A.1</xref>
          <xref target='Anote1'>Requirement (??)</xref>
          <xref target='Anote2'>Requirement A.2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references requirements with labels" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          </p>
          </foreword>
          <introduction id="intro">
          <requirement model="ogc" id="N1">
          <identifier>/ogc/req1</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <clause id="xyz"><title>Preparatory</title>
          <requirement model="ogc" id="N2" unnumbered="true">
          <identifier>/ogc/req2</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <requirement model="ogc" id="N">
          <identifier>/ogc/req3</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <requirement model="ogc" id="note1">
          <identifier>/ogc/req4</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement model="ogc" id="note2">
          <identifier>/ogc/req5</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <requirement model="ogc" id="AN">
          <identifier>/ogc/req6</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          <clause id="annex1b">
          <requirement model="ogc" id="Anote1" unnumbered="true">
          <identifier>/ogc/req7</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement model="ogc" id="Anote2">
          <identifier>/ogc/req8</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="1">
              <p>
                   <xref target='N1'>
           Introduction, Requirement 1:
           <tt>/ogc/req1</tt>
         </xref>
         <xref target='N2'>
           Preparatory, Requirement (??):
           <tt>/ogc/req2</tt>
         </xref>
         <xref target='N'>
           Clause 1, Requirement 2:
           <tt>/ogc/req3</tt>
         </xref>
         <xref target='note1'>
           Clause 3.1, Requirement 3:
           <tt>/ogc/req4</tt>
         </xref>
         <xref target='note2'>
           Clause 3.1, Requirement 4:
           <tt>/ogc/req5</tt>
         </xref>
         <xref target='AN'>
           Requirement A.1:
           <tt>/ogc/req6</tt>
         </xref>
         <xref target='Anote1'>
           Requirement (??):
           <tt>/ogc/req7</tt>
         </xref>
         <xref target='Anote2'>
           Requirement A.2:
           <tt>/ogc/req8</tt>
         </xref>
              </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references requirement parts" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
          <p>
          <xref target="N1a"/>
          <xref target="N1b"/>
          <xref target="N2a"/>
          <xref target="N2b"/>
          <xref target="Na"/>
          <xref target="Nb"/>
          <xref target="note1a"/>
          <xref target="note1b"/>
          <xref target="note2a"/>
          <xref target="note2b"/>
          <xref target="ANa"/>
          <xref target="ANb"/>
          <xref target="Anote1a"/>
          <xref target="Anote1b"/>
          <xref target="Anote2a"/>
          <xref target="Anote2b"/>
          </p>
          </foreword>
          <introduction id="intro">
          <requirement model="ogc" id="N1">
        <stem type="AsciiMath">r = 1 %</stem>
        <component class="part" id="N1a"/>
        <component class="part" id="N1b"/>
        </requirement>
        <clause id="xyz"><title>Preparatory</title>
          <requirement model="ogc" id="N2" unnumbered="true">
        <stem type="AsciiMath">r = 1 %</stem>
        <component class="part" id="N2a"/>
        <component class="part" id="N2b"/>
        </requirement>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <requirement model="ogc" id="N">
        <stem type="AsciiMath">r = 1 %</stem>
        <component class="part" id="Na"/>
        <component class="part" id="Nb"/>
        </requirement>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <requirement model="ogc" id="note1">
        <stem type="AsciiMath">r = 1 %</stem>
        <component class="part" id="note1a"/>
        <component class="part" id="note1b"/>
        </requirement>
          <requirement model="ogc" id="note2">
        <stem type="AsciiMath">r = 1 %</stem>
        <component class="part" id="note2a"/>
        <component class="part" id="note2b"/>
        </requirement>
        <p>    <xref target="note1a"/> <xref target="note2b"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <requirement model="ogc" id="AN">
        <stem type="AsciiMath">r = 1 %</stem>
        <component class="part" id="ANa"/>
        <component class="part" id="ANb"/>
        </requirement>
          </clause>
          <clause id="annex1b">
          <requirement model="ogc" id="Anote1" unnumbered="true">
        <stem type="AsciiMath">r = 1 %</stem>
        <component class="part" id="Anote1a"/>
        <component class="part" id="Anote1b"/>
        </requirement>
          <requirement model="ogc" id="Anote2">
        <stem type="AsciiMath">r = 1 %</stem>
        <component class="part" id="Anote2a"/>
        <component class="part" id="Anote2b"/>
        </requirement>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder='1'>
        <p>
          <xref target='N1a'>Introduction, Requirement 1 A</xref>
          <xref target='N1b'>Introduction, Requirement 1 B</xref>
          <xref target='N2a'>Preparatory, Requirement A</xref>
          <xref target='N2b'>Preparatory, Requirement B</xref>
          <xref target='Na'>Clause 1, Requirement 2 A</xref>
          <xref target='Nb'>Clause 1, Requirement 2 B</xref>
          <xref target='note1a'>Clause 3.1, Requirement 3 A</xref>
          <xref target='note1b'>Clause 3.1, Requirement 3 B</xref>
          <xref target='note2a'>Clause 3.1, Requirement 4 A</xref>
          <xref target='note2b'>Clause 3.1, Requirement 4 B</xref>
          <xref target='ANa'>Requirement A.1 A</xref>
          <xref target='ANb'>Requirement A.1 B</xref>
          <xref target='Anote1a'>Requirement A. A</xref>
          <xref target='Anote1b'>Requirement A. B</xref>
          <xref target='Anote2a'>Requirement A.2 A</xref>
          <xref target='Anote2b'>Requirement A.2 B</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references requirement tests" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          </p>
          </foreword>
          <introduction id="intro">
          <requirement model="ogc" id="N1" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <clause id="xyz"><title>Preparatory</title>
          <requirement model="ogc" id="N2" unnumbered="true" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <requirement model="ogc" id="N" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <requirement model="ogc" id="note1" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement model="ogc" id="note2" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <requirement model="ogc" id="AN" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          <clause id="annex1b">
          <requirement model="ogc" id="Anote1" unnumbered="true" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement model="ogc" id="Anote2" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="1">
        <p>
          <xref target='N1'>Introduction, Requirement test 1</xref>
          <xref target='N2'>Preparatory, Requirement test (??)</xref>
          <xref target='N'>Clause 1, Requirement test 2</xref>
          <xref target='note1'>Clause 3.1, Requirement test 3</xref>
          <xref target='note2'>Clause 3.1, Requirement test 4</xref>
          <xref target='AN'>Requirement test A.1</xref>
          <xref target='Anote1'>Requirement test (??)</xref>
          <xref target='Anote2'>Requirement test A.2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references requirement tests in French" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <bibdata><language>fr</language></bibdata>
                  <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          </p>
          </foreword>
          <introduction id="intro">
          <requirement model="ogc" id="N1" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <clause id="xyz"><title>Preparatory</title>
          <requirement model="ogc" id="N2" unnumbered="true" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <requirement model="ogc" id="N" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <requirement model="ogc" id="note1" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement model="ogc" id="note2" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <requirement model="ogc" id="AN" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          <clause id="annex1b">
          <requirement model="ogc" id="Anote1" unnumbered="true" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement model="ogc" id="Anote2" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder='1'>
         <p>
           <xref target='N1'>Introduction, Test d&#x2019;exigence 1</xref>
           <xref target='N2'>Preparatory, Test d&#x2019;exigence (??)</xref>
           <xref target='N'>Article 1, Test d&#x2019;exigence 2</xref>
           <xref target='note1'>Article 3.1, Test d&#x2019;exigence 3</xref>
           <xref target='note2'>Article 3.1, Test d&#x2019;exigence 4</xref>
           <xref target='AN'>Test d&#x2019;exigence A.1</xref>
           <xref target='Anote1'>Test d&#x2019;exigence (??)</xref>
           <xref target='Anote2'>Test d&#x2019;exigence A.2</xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references recommendations" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          </p>
          </foreword>
          <introduction id="intro">
          <recommendation model="ogc" id="N1">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
        <clause id="xyz"><title>Preparatory</title>
          <recommendation model="ogc" id="N2" unnumbered="true">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <recommendation model="ogc" id="N">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <recommendation model="ogc" id="note1">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          <recommendation model="ogc" id="note2">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <recommendation model="ogc" id="AN">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          </clause>
          <clause id="annex1b">
          <recommendation model="ogc" id="Anote1" unnumbered="true">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          <recommendation model="ogc" id="Anote2">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="1">
        <p>
          <xref target='N1'>Introduction, Recommendation 1</xref>
          <xref target='N2'>Preparatory, Recommendation (??)</xref>
          <xref target='N'>Clause 1, Recommendation 2</xref>
          <xref target='note1'>Clause 3.1, Recommendation 3</xref>
          <xref target='note2'>Clause 3.1, Recommendation 4</xref>
          <xref target='AN'>Recommendation A.1</xref>
          <xref target='Anote1'>Recommendation (??)</xref>
          <xref target='Anote2'>Recommendation A.2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references recommendation tests" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          </p>
          </foreword>
          <introduction id="intro">
          <recommendation model="ogc" id="N1" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
        <clause id="xyz"><title>Preparatory</title>
          <recommendation model="ogc" id="N2" unnumbered="true" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <recommendation model="ogc" id="N" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <recommendation model="ogc" id="note1" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          <recommendation model="ogc" id="note2" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <recommendation model="ogc" id="AN" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          </clause>
          <clause id="annex1b">
          <recommendation model="ogc" id="Anote1" unnumbered="true" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          <recommendation model="ogc" id="Anote2" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </recommendation>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="1">
        <p>
          <xref target='N1'>Introduction, Recommendation test 1</xref>
          <xref target='N2'>Preparatory, Recommendation test (??)</xref>
          <xref target='N'>Clause 1, Recommendation test 2</xref>
          <xref target='note1'>Clause 3.1, Recommendation test 3</xref>
          <xref target='note2'>Clause 3.1, Recommendation test 4</xref>
          <xref target='AN'>Recommendation test A.1</xref>
          <xref target='Anote1'>Recommendation test (??)</xref>
          <xref target='Anote2'>Recommendation test A.2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references permissions" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          </p>
          </foreword>
          <introduction id="intro">
          <permission model="ogc" id="N1">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <clause id="xyz"><title>Preparatory</title>
          <permission model="ogc" id="N2" unnumbered="true">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <permission model="ogc" id="N">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <permission model="ogc" id="note1">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          <permission model="ogc" id="note2">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <permission model="ogc" id="AN">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          </clause>
          <clause id="annex1b">
          <permission model="ogc" id="Anote1" unnumbered="true">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          <permission model="ogc" id="Anote2">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="1">
        <p>
          <xref target='N1'>Introduction, Permission 1</xref>
          <xref target='N2'>Preparatory, Permission (??)</xref>
          <xref target='N'>Clause 1, Permission 2</xref>
          <xref target='note1'>Clause 3.1, Permission 3</xref>
          <xref target='note2'>Clause 3.1, Permission 4</xref>
          <xref target='AN'>Permission A.1</xref>
          <xref target='Anote1'>Permission (??)</xref>
          <xref target='Anote2'>Permission A.2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references permission tests" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          </p>
          </foreword>
          <introduction id="intro">
          <permission model="ogc" id="N1" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <clause id="xyz"><title>Preparatory</title>
          <permission model="ogc" id="N2" unnumbered="true" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <permission model="ogc" id="N" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <permission model="ogc" id="note1" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          <permission model="ogc" id="note2" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <permission model="ogc" id="AN" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          </clause>
          <clause id="annex1b">
          <permission model="ogc" id="Anote1" unnumbered="true" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          <permission model="ogc" id="Anote2" type="verification">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="1">
        <p>
          <xref target='N1'>Introduction, Permission test 1</xref>
          <xref target='N2'>Preparatory, Permission test (??)</xref>
          <xref target='N'>Clause 1, Permission test 2</xref>
          <xref target='note1'>Clause 3.1, Permission test 3</xref>
          <xref target='note2'>Clause 3.1, Permission test 4</xref>
          <xref target='AN'>Permission test A.1</xref>
          <xref target='Anote1'>Permission test (??)</xref>
          <xref target='Anote2'>Permission test A.2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "labels and cross-references nested requirements" do
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <preface>
      <foreword>
      <p>
      <xref target="N1"/>
      <xref target="N2"/>
      <xref target="N"/>
      <xref target="Q1"/>
      <xref target="R1"/>
      <xref target="AN1"/>
      <xref target="AN2"/>
      <xref target="AN"/>
      <xref target="AQ1"/>
      <xref target="AR1"/>
      </p>
      </foreword>
      </preface>
      <sections>
      <clause id="xyz"><title>Preparatory</title>
      <permission model="ogc" id="N1">
      <permission model="ogc" id="N2" type="verification">
      <permission model="ogc" id="N">
      </permission>
      </permission>
      <requirement model="ogc" id="Q1">
      </requirement>
      <recommendation model="ogc" id="R1">
      </recommendation>
      <permission model="ogc" id="N3" type="verification"/>
      <permission model="ogc" id="N4"/>
      </permission>
      </clause>
      </sections>
      <annex id="Axyz"><title>Preparatory</title>
      <permission model="ogc" id="AN1" type="verification">
      <permission model="ogc" id="AN2">
      <permission model="ogc" id="AN" type="verification">
      </permission>
      </permission>
      <requirement model="ogc" id="AQ1">
      </requirement>
      <recommendation model="ogc" id="AR1">
      </recommendation>
      <permission model="ogc" id="AN3" type="verification"/>
      <permission model="ogc" id="AN4"/>
      </permission>
      </annex>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="1">
        <p>
          <xref target='N1'>Clause 1, Permission 1</xref>
          <xref target='N2'>Clause 1, Permission test 1-1</xref>
          <xref target='N'>Clause 1, Permission 1-1-1</xref>
          <xref target='Q1'>Clause 1, Requirement 1-1</xref>
          <xref target='R1'>Clause 1, Recommendation 1-1</xref>
          <xref target='AN1'>Permission test A.1</xref>
          <xref target='AN2'>Permission A.1-1</xref>
          <xref target='AN'>Permission test A.1-1-1</xref>
          <xref target='AQ1'>Requirement A.1-1</xref>
          <xref target='AR1'>Recommendation A.1-1</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references abstract tests" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          </p>
          </foreword>
          <introduction id="intro">
          <permission model="ogc" id="N1" type="abstracttest">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <clause id="xyz"><title>Preparatory</title>
          <permission model="ogc" id="N2" unnumbered="true" type="abstracttest">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <permission model="ogc" id="N" type="abstracttest">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <permission model="ogc" id="note1" type="abstracttest">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          <permission model="ogc" id="note2" type="abstracttest">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <permission model="ogc" id="AN" type="abstracttest">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          </clause>
          <clause id="annex1b">
          <permission model="ogc" id="Anote1" unnumbered="true" type="abstracttest">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          <permission model="ogc" id="Anote2" type="abstracttest">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="1">
        <p>
          <xref target='N1'>Introduction, Abstract test 1</xref>
          <xref target='N2'>Preparatory, Abstract test (??)</xref>
          <xref target='N'>Clause 1, Abstract test 2</xref>
          <xref target='note1'>Clause 3.1, Abstract test 3</xref>
          <xref target='note2'>Clause 3.1, Abstract test 4</xref>
          <xref target='AN'>Abstract test A.1</xref>
          <xref target='Anote1'>Abstract test (??)</xref>
          <xref target='Anote2'>Abstract test A.2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references conformance classes" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2"/>
          <xref target="AN"/>
          <xref target="Anote1"/>
          <xref target="Anote2"/>
          </p>
          </foreword>
          <introduction id="intro">
          <permission model="ogc" id="N1" type="conformanceclass">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <clause id="xyz"><title>Preparatory</title>
          <permission model="ogc" id="N2" unnumbered="true" type="conformanceclass">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <permission model="ogc" id="N" type="conformanceclass">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <permission model="ogc" id="note1" type="conformanceclass">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          <permission model="ogc" id="note2" type="conformanceclass">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
        <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <permission model="ogc" id="AN" type="conformanceclass">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          </clause>
          <clause id="annex1b">
          <permission model="ogc" id="Anote1" unnumbered="true" type="conformanceclass">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          <permission model="ogc" id="Anote2" type="conformanceclass">
        <stem type="AsciiMath">r = 1 %</stem>
        </permission>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="1">
        <p>
          <xref target='N1'>Introduction, Conformance class 1</xref>
          <xref target='N2'>Preparatory, Conformance class (??)</xref>
          <xref target='N'>Clause 1, Conformance class 2</xref>
          <xref target='note1'>Clause 3.1, Conformance class 3</xref>
          <xref target='note2'>Clause 3.1, Conformance class 4</xref>
          <xref target='AN'>Conformance class A.1</xref>
          <xref target='Anote1'>Conformance class (??)</xref>
          <xref target='Anote2'>Conformance class A.2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end
end
