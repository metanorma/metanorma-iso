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
      <foreword displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N1">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N1">1</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="N1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="N2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N2">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N2">(??)</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="N2">(??)</semx>
                </fmt-xref>
             </semx>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N">2</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="N">2</semx>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="note1">3</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="note1">3</semx>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="note2">4</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="note2">4</semx>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AN">1</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AN">1</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="Anote1">(??)</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="Anote1">(??)</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote2">2</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote2">2</semx>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
       <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="N1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="N2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N2">(??)</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="N2">(??)</semx>
                 </fmt-xref>
              </semx>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N">2</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="N">2</semx>
                 </fmt-xref>
              </semx>
              <xref target="note1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="note1">3</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="note1">3</semx>
                 </fmt-xref>
              </semx>
              <xref target="note2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="note2">4</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="note2">4</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
       <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1" style="modspec" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N1" style="modspec">
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-caption-delim">: </span>
                    <semx element="title" source="N1">First</semx>
                 </fmt-xref>
              </semx>
              <xref target="N2" style="modspec" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N2" style="modspec">
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="N2">(??)</semx>
                    <span class="fmt-caption-delim">: </span>
                    <semx element="title" source="N2">Second</semx>
                 </fmt-xref>
              </semx>
              <xref target="N" style="modspec" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N" style="modspec">
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="N">2</semx>
                    <span class="fmt-caption-delim">: </span>
                    <semx element="title" source="N">Third</semx>
                 </fmt-xref>
              </semx>
              <xref target="note1" style="modspec" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note1" style="modspec">
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="note1">3</semx>
                    <span class="fmt-caption-delim">: </span>
                    <semx element="title" source="note1">Fourth</semx>
                 </fmt-xref>
              </semx>
              <xref target="note2" style="modspec" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note2" style="modspec">
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="note2">4</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN" style="modspec" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN" style="modspec">
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                    <span class="fmt-caption-delim">: </span>
                    <semx element="title" source="AN">Fifth</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote1" style="modspec" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote1" style="modspec">
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                    <span class="fmt-caption-delim">: </span>
                    <semx element="title" source="Anote1">Sixth</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote2" style="modspec" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote2" style="modspec">
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
       <foreword displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N1a" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N1a">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N1">1</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="N1a">1 A</semx>
                </fmt-xref>
             </semx>
             <xref target="N1b" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N1b">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N1">1</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="N1b">1 B</semx>
                </fmt-xref>
             </semx>
             <xref target="N2a" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N2a">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N2">(??)</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="N2a"> A</semx>
                </fmt-xref>
             </semx>
             <xref target="N2b" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N2b">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N2">(??)</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="N2b"> B</semx>
                </fmt-xref>
             </semx>
             <xref target="Na" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Na">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N">2</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="Na">2 A</semx>
                </fmt-xref>
             </semx>
             <xref target="Nb" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Nb">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N">2</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="Nb">2 B</semx>
                </fmt-xref>
             </semx>
             <xref target="note1a" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1a">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="note1">3</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="note1a">3 A</semx>
                </fmt-xref>
             </semx>
             <xref target="note1b" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1b">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="note1">3</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="note1b">3 B</semx>
                </fmt-xref>
             </semx>
             <xref target="note2a" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2a">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="note2">4</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="note2a">4 A</semx>
                </fmt-xref>
             </semx>
             <xref target="note2b" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2b">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="note2">4</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="note2b">4 B</semx>
                </fmt-xref>
             </semx>
             <xref target="ANa" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="ANa">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AN">1</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="ANa">A.1 A</semx>
                </fmt-xref>
             </semx>
             <xref target="ANb" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="ANb">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AN">1</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="ANb">A.1 B</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote1a" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1a">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="Anote1">(??)</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="Anote1a">A. A</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote1b" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1b">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="Anote1">(??)</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="Anote1b">A. B</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote2a" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2a">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote2">2</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="Anote2a">A.2 A</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote2b" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2b">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote2">2</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Requirement</span>
                   <semx element="autonum" source="Anote2b">A.2 B</semx>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
       <foreword displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N1">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N1">1</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Conformance test</span>
                   <semx element="autonum" source="N1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="N2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N2">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N2">(??)</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Conformance test</span>
                   <semx element="autonum" source="N2">(??)</semx>
                </fmt-xref>
             </semx>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N">2</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Conformance test</span>
                   <semx element="autonum" source="N">2</semx>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="note1">3</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Conformance test</span>
                   <semx element="autonum" source="note1">3</semx>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="note2">4</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Conformance test</span>
                   <semx element="autonum" source="note2">4</semx>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AN">1</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Conformance test</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AN">1</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="Anote1">(??)</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Conformance test</span>
                   <semx element="autonum" source="Anote1">(??)</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote2">2</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Conformance test</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote2">2</semx>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
       <foreword displayorder="2">
          <title id="_">Avant-propos</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Avant-propos</semx>
          </fmt-title>
          <p>
             <xref target="N1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N1">
                   <span class="fmt-element-name">Tableau</span>
                   <semx element="autonum" source="N1">1</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Test de conformité</span>
                   <semx element="autonum" source="N1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="N2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N2">
                   <span class="fmt-element-name">Tableau</span>
                   <semx element="autonum" source="N2">(??)</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Test de conformité</span>
                   <semx element="autonum" source="N2">(??)</semx>
                </fmt-xref>
             </semx>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="fmt-element-name">Tableau</span>
                   <semx element="autonum" source="N">2</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Test de conformité</span>
                   <semx element="autonum" source="N">2</semx>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-element-name">Tableau</span>
                   <semx element="autonum" source="note1">3</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Test de conformité</span>
                   <semx element="autonum" source="note1">3</semx>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-element-name">Tableau</span>
                   <semx element="autonum" source="note2">4</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Test de conformité</span>
                   <semx element="autonum" source="note2">4</semx>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="fmt-element-name">Tableau</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AN">1</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Test de conformité</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AN">1</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="fmt-element-name">Tableau</span>
                   <semx element="autonum" source="Anote1">(??)</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Test de conformité</span>
                   <semx element="autonum" source="Anote1">(??)</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="fmt-element-name">Tableau</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote2">2</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Test de conformité</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote2">2</semx>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
       <foreword displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N1">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N1">1</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Recommendation</span>
                   <semx element="autonum" source="N1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="N2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N2">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N2">(??)</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Recommendation</span>
                   <semx element="autonum" source="N2">(??)</semx>
                </fmt-xref>
             </semx>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="N">2</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Recommendation</span>
                   <semx element="autonum" source="N">2</semx>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="note1">3</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Recommendation</span>
                   <semx element="autonum" source="note1">3</semx>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="note2">4</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Recommendation</span>
                   <semx element="autonum" source="note2">4</semx>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AN">1</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Recommendation</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AN">1</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="Anote1">(??)</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Recommendation</span>
                   <semx element="autonum" source="Anote1">(??)</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote2">2</semx>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Recommendation</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote2">2</semx>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="N1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="N2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N2">(??)</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="N2">(??)</semx>
                 </fmt-xref>
              </semx>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N">2</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="N">2</semx>
                 </fmt-xref>
              </semx>
              <xref target="note1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="note1">3</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="note1">3</semx>
                 </fmt-xref>
              </semx>
              <xref target="note2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="note2">4</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="note2">4</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
       <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="N1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="N2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N2">(??)</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="N2">(??)</semx>
                 </fmt-xref>
              </semx>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N">2</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="N">2</semx>
                 </fmt-xref>
              </semx>
              <xref target="note1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="note1">3</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="note1">3</semx>
                 </fmt-xref>
              </semx>
              <xref target="note2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="note2">4</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="note2">4</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="N1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="N2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N2">(??)</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="N2">(??)</semx>
                 </fmt-xref>
              </semx>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N">2</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="N">2</semx>
                 </fmt-xref>
              </semx>
              <xref target="note1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="note1">3</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="note1">3</semx>
                 </fmt-xref>
              </semx>
              <xref target="note2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="note2">4</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="note2">4</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="N1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="N2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="N2">1-1</semx>
                 </fmt-xref>
              </semx>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="N">1-1-1</semx>
                 </fmt-xref>
              </semx>
              <xref target="Q1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Q1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="Q1">1-1</semx>
                 </fmt-xref>
              </semx>
              <xref target="R1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="R1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Recommendation</span>
                    <semx element="autonum" source="R1">1-1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Permission</span>
                    <semx element="autonum" source="AN2">A.1-1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance test</span>
                    <semx element="autonum" source="AN">A.1-1-1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AQ1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AQ1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Requirement</span>
                    <semx element="autonum" source="AQ1">A.1-1</semx>
                 </fmt-xref>
              </semx>
              <xref target="AR1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AR1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="Axyz">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Recommendation</span>
                    <semx element="autonum" source="AR1">A.1-1</semx>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Abstract test</span>
                    <semx element="autonum" source="N1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="N2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N2">(??)</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Abstract test</span>
                    <semx element="autonum" source="N2">(??)</semx>
                 </fmt-xref>
              </semx>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N">2</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Abstract test</span>
                    <semx element="autonum" source="N">2</semx>
                 </fmt-xref>
              </semx>
              <xref target="note1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="note1">3</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Abstract test</span>
                    <semx element="autonum" source="note1">3</semx>
                 </fmt-xref>
              </semx>
              <xref target="note2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="note2">4</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Abstract test</span>
                    <semx element="autonum" source="note2">4</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Abstract test</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Abstract test</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Abstract test</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N1">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance class</span>
                    <semx element="autonum" source="N1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="N2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N2">(??)</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance class</span>
                    <semx element="autonum" source="N2">(??)</semx>
                 </fmt-xref>
              </semx>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="N">2</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance class</span>
                    <semx element="autonum" source="N">2</semx>
                 </fmt-xref>
              </semx>
              <xref target="note1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="note1">3</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance class</span>
                    <semx element="autonum" source="note1">3</semx>
                 </fmt-xref>
              </semx>
              <xref target="note2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="note2">4</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance class</span>
                    <semx element="autonum" source="note2">4</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance class</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="AN">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote1">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance class</span>
                    <semx element="autonum" source="Anote1">(??)</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote2">
                    <span class="fmt-element-name">Table</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Conformance class</span>
                    <semx element="autonum" source="annex1">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Anote2">2</semx>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
