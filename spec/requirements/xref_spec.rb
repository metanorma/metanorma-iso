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
          <title>First</title>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <requirement model="ogc" id="note1">
          <title>Second</title>
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
          <title>Third</title>
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
      <foreword displayorder='1'>
         <p>
           <xref target='N1'>
             Table 1, Requirement 1
           </xref>
           <xref target='N2'>
             Table (??), Requirement (??)
           </xref>
           <xref target='N'>
             Table 2, Requirement 2
           </xref>
           <xref target='note1'>
             Table 3, Requirement 3
           </xref>
           <xref target='note2'>
             Table 4, Requirement 4
           </xref>
           <xref target='AN'>
             Table A.1, Requirement A.1
           </xref>
           <xref target='Anote1'>
             Table (??), Requirement (??)
           </xref>
           <xref target='Anote2'>
             Table A.2, Requirement A.2
           </xref>
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
          <title>First</title>
          <identifier>/ogc/req3</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <requirement model="ogc" id="note1">
          <title>Second</title>
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
          <title>Third</title>
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
      <foreword displayorder='1'>
         <p>
           <xref target='N1'>
             Table 1, Requirement 1
           </xref>
           <xref target='N2'>
             Table (??), Requirement (??)
           </xref>
           <xref target='N'>
             Table 2, Requirement 2
           </xref>
           <xref target='note1'>
             Table 3, Requirement 3
           </xref>
           <xref target='note2'>
             Table 4, Requirement 4
           </xref>
           <xref target='AN'>
             Table A.1, Requirement A.1
           </xref>
           <xref target='Anote1'>
             Table (??), Requirement (??)
           </xref>
           <xref target='Anote2'>
             Table A.2, Requirement A.2
           </xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "cross-references requirements with modspec style" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
          <p>
          <xref target="N1" style="modspec"/>
          <xref target="N2" style="modspec"/>
          <xref target="N" style="modspec"/>
          <xref target="note1" style="modspec"/>
          <xref target="note2" style="modspec"/>
          <xref target="AN" style="modspec"/>
          <xref target="Anote1" style="modspec"/>
          <xref target="Anote2" style="modspec"/>
          </p>
          </foreword>
          <introduction id="intro">
          <requirement model="ogc" id="N1">
          <identifier>/ogc/req1</identifier>
          <title>First</title>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <clause id="xyz"><title>Preparatory</title>
          <requirement model="ogc" id="N2" unnumbered="true">
          <title>Second</title>
          <identifier>/ogc/req2</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <requirement model="ogc" id="N">
          <title>Third</title>
          <identifier>/ogc/req3</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p><xref target="N" style="modspec"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <requirement model="ogc" id="note1">
          <title>Fourth</title>
          <identifier>/ogc/req4</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          <requirement model="ogc" id="note2">
          <identifier>/ogc/req5</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
        <p>    <xref target="note1" style="modspec"/> <xref target="note2" style="modspec"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <requirement model="ogc" id="AN">
          <title>Fifth</title>
          <identifier>/ogc/req6</identifier>
        <stem type="AsciiMath">r = 1 %</stem>
        </requirement>
          </clause>
          <clause id="annex1b">
          <requirement model="ogc" id="Anote1" unnumbered="true">
          <identifier>/ogc/req7</identifier>
          <title>Sixth</title>
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
           <xref target="N1" style="modspec">
             Requirement 1: First
           </xref>
           <xref target="N2" style="modspec">
             Requirement (??): Second
           </xref>
           <xref target="N" style="modspec">
             Requirement 2: Third
           </xref>
           <xref target="note1" style="modspec">
             Requirement 3: Fourth
           </xref>
           <xref target="note2" style="modspec">
             Requirement 4
           </xref>
           <xref target="AN" style="modspec">
             Requirement A.1: Fifth
           </xref>
           <xref target="Anote1" style="modspec">
             Requirement (??): Sixth
           </xref>
           <xref target="Anote2" style="modspec">
             Requirement A.2
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
           <xref target='N1a'>Table 1, Requirement 1 A</xref>
           <xref target='N1b'>Table 1, Requirement 1 B</xref>
           <xref target='N2a'>Table (??), Requirement A</xref>
           <xref target='N2b'>Table (??), Requirement B</xref>
           <xref target='Na'>Table 2, Requirement 2 A</xref>
           <xref target='Nb'>Table 2, Requirement 2 B</xref>
           <xref target='note1a'>Table 3, Requirement 3 A</xref>
           <xref target='note1b'>Table 3, Requirement 3 B</xref>
           <xref target='note2a'>Table 4, Requirement 4 A</xref>
           <xref target='note2b'>Table 4, Requirement 4 B</xref>
           <xref target='ANa'>Table A.1, Requirement A.1 A</xref>
           <xref target='ANb'>Table A.1, Requirement A.1 B</xref>
           <xref target='Anote1a'>Table (??), Requirement A. A</xref>
           <xref target='Anote1b'>Table (??), Requirement A. B</xref>
           <xref target='Anote2a'>Table A.2, Requirement A.2 A</xref>
           <xref target='Anote2b'>Table A.2, Requirement A.2 B</xref>
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
      <foreword displayorder='1'>
         <p>
           <xref target='N1'>
             Table 1, Conformance test 1
           </xref>
           <xref target='N2'>
             Table (??), Conformance test (??)
           </xref>
           <xref target='N'>
             Table 2, Conformance test 2
           </xref>
           <xref target='note1'>
             Table 3, Conformance test 3
           </xref>
           <xref target='note2'>
             Table 4, Conformance test 4
           </xref>
           <xref target='AN'>
             Table A.1, Conformance test A.1
           </xref>
           <xref target='Anote1'>
             Table (??), Conformance test (??)
           </xref>
           <xref target='Anote2'>
             Table A.2, Conformance test A.2
           </xref>
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
           <xref target='N1'>
             Tableau 1, Test de conformité 1
           </xref>
           <xref target='N2'>
             Tableau (??), Test de conformité (??)
           </xref>
           <xref target='N'>
             Tableau 2, Test de conformité 2
           </xref>
           <xref target='note1'>
             Tableau 3, Test de conformité 3
           </xref>
           <xref target='note2'>
             Tableau 4, Test de conformité 4
           </xref>
           <xref target='AN'>
             Tableau A.1, Test de conformité A.1
           </xref>
           <xref target='Anote1'>
             Tableau (??), Test de conformité (??)
           </xref>
           <xref target='Anote2'>
             Tableau A.2, Test de conformité A.2
           </xref>
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
      <foreword displayorder='1'>
         <p>
           <xref target='N1'>
             Table 1, Recommendation 1
           </xref>
           <xref target='N2'>
             Table (??), Recommendation (??)
           </xref>
           <xref target='N'>
             Table 2, Recommendation 2
           </xref>
           <xref target='note1'>
             Table 3, Recommendation 3
           </xref>
           <xref target='note2'>
             Table 4, Recommendation 4
           </xref>
           <xref target='AN'>
             Table A.1, Recommendation A.1
           </xref>
           <xref target='Anote1'>
             Table (??), Recommendation (??)
           </xref>
           <xref target='Anote2'>
             Table A.2, Recommendation A.2
           </xref>
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
      <foreword displayorder='1'>
         <p>
           <xref target='N1'>
             Table 1, Conformance test 1
           </xref>
           <xref target='N2'>
             Table (??), Conformance test (??)
           </xref>
           <xref target='N'>
             Table 2, Conformance test 2
           </xref>
           <xref target='note1'>
             Table 3, Conformance test 3
           </xref>
           <xref target='note2'>
             Table 4, Conformance test 4
           </xref>
           <xref target='AN'>
             Table A.1, Conformance test A.1
           </xref>
           <xref target='Anote1'>
             Table (??), Conformance test (??)
           </xref>
           <xref target='Anote2'>
             Table A.2, Conformance test A.2
           </xref>
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
      <foreword displayorder='1'>
         <p>
           <xref target='N1'>
             Table 1, Permission 1
           </xref>
           <xref target='N2'>
             Table (??), Permission (??)
           </xref>
           <xref target='N'>
             Table 2, Permission 2
           </xref>
           <xref target='note1'>
             Table 3, Permission 3
           </xref>
           <xref target='note2'>
             Table 4, Permission 4
           </xref>
           <xref target='AN'>
             Table A.1, Permission A.1
           </xref>
           <xref target='Anote1'>
             Table (??), Permission (??)
           </xref>
           <xref target='Anote2'>
             Table A.2, Permission A.2
           </xref>
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
      <foreword displayorder='1'>
         <p>
           <xref target='N1'>
             Table 1, Conformance test 1
           </xref>
           <xref target='N2'>
             Table (??), Conformance test (??)
           </xref>
           <xref target='N'>
             Table 2, Conformance test 2
           </xref>
           <xref target='note1'>
             Table 3, Conformance test 3
           </xref>
           <xref target='note2'>
             Table 4, Conformance test 4
           </xref>
           <xref target='AN'>
             Table A.1, Conformance test A.1
           </xref>
           <xref target='Anote1'>
             Table (??), Conformance test (??)
           </xref>
           <xref target='Anote2'>
             Table A.2, Conformance test A.2
           </xref>
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
      <foreword displayorder='1'>
         <p>
           <xref target='N1'>
             Table 1, Permission 1
           </xref>
           <xref target='N2'>Table 1, Conformance test 1-1</xref>
           <xref target='N'>Table 1, Permission 1-1-1</xref>
           <xref target='Q1'>Table 1, Requirement 1-1</xref>
           <xref target='R1'>Table 1, Recommendation 1-1</xref>
           <xref target='AN1'>
             Table A.1, Conformance test A.1
           </xref>
           <xref target='AN2'>Table A.1, Permission A.1-1</xref>
           <xref target='AN'>Table A.1, Conformance test A.1-1-1</xref>
           <xref target='AQ1'>Table A.1, Requirement A.1-1</xref>
           <xref target='AR1'>Table A.1, Recommendation A.1-1</xref>
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
      <foreword displayorder='1'>
         <p>
           <xref target='N1'>
             Table 1, Abstract test 1
           </xref>
           <xref target='N2'>
             Table (??), Abstract test (??)
           </xref>
           <xref target='N'>
             Table 2, Abstract test 2
           </xref>
           <xref target='note1'>
             Table 3, Abstract test 3
           </xref>
           <xref target='note2'>
             Table 4, Abstract test 4
           </xref>
           <xref target='AN'>
             Table A.1, Abstract test A.1
           </xref>
           <xref target='Anote1'>
             Table (??), Abstract test (??)
           </xref>
           <xref target='Anote2'>
             Table A.2, Abstract test A.2
           </xref>
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
      <foreword displayorder='1'>
         <p>
           <xref target='N1'>
             Table 1, Conformance class 1
           </xref>
           <xref target='N2'>
             Table (??), Conformance class (??)
           </xref>
           <xref target='N'>
             Table 2, Conformance class 2
           </xref>
           <xref target='note1'>
             Table 3, Conformance class 3
           </xref>
           <xref target='note2'>
             Table 4, Conformance class 4
           </xref>
           <xref target='AN'>
             Table A.1, Conformance class A.1
           </xref>
           <xref target='Anote1'>
             Table (??), Conformance class (??)
           </xref>
           <xref target='Anote2'>
             Table A.2, Conformance class A.2
           </xref>
         </p>
       </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end
end
