require "spec_helper"

RSpec.describe Metanorma::Iso do
  it "processes amendment sections" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{AMD_BLANK_HDR}
      == Foreword

      Text

      == Introduction

      === Introduction Subsection

      == Scope

      Text

      == Acknowledgements

      == Normative References

      == Terms and Definitions

      === Term1

      == Terms, Definitions, Symbols and Abbreviated Terms

      === Normal Terms

      ==== Term2

      === Symbols and Abbreviated Terms

      == Symbols and Abbreviated Terms

      == Clause 4

      === Introduction

      === Clause 4.2

      == Terms and Definitions

      [appendix]
      == Annex

      === Annex A.1

      [%appendix]
      === Appendix 1

      == Bibliography

      === Bibliography Subsection
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR.sub(%r{<doctype>standard</doctype>}, '<doctype>amendment</doctype>').sub(%r{<stagename>International Standard</stagename>}, '<stagename/>')}
        <sections>
          <clause id="_" obligation="normative">
            <title>Foreword</title>
            <p id="_">Text</p>
          </clause>
          <clause id="_" obligation="normative">
            <title>Introduction</title>
            <clause id="_" obligation="normative">
              <title>Introduction Subsection</title>
            </clause>
          </clause>
          <clause id="_" obligation="normative">
            <title>Scope</title>
            <p id="_">Text</p>
          </clause>
          <clause id="_" obligation="normative">
            <title>Acknowledgements</title>
          </clause>
          <clause id="_" obligation="normative">
            <title>Normative References</title>
          </clause>
          <clause id="_" obligation="normative">
            <title>Terms and Definitions</title>
            <clause id="_" obligation="normative">
              <title>Term1</title>
            </clause>
          </clause>
          <clause id="_" obligation="normative">
            <title>Terms, Definitions, Symbols and Abbreviated Terms</title>
            <clause id="_" obligation="normative">
              <title>Normal Terms</title>
              <clause id="_" obligation="normative">
                <title>Term2</title>
              </clause>
            </clause>
            <clause id="_" obligation="normative">
              <title>Symbols and Abbreviated Terms</title>
            </clause>
          </clause>
          <clause id="_" obligation="normative">
            <title>Symbols and Abbreviated Terms</title>
          </clause>
          <clause id="_" obligation="normative">
            <title>Clause 4</title>
            <clause id="_" obligation="normative">
              <title>Introduction</title>
            </clause>
            <clause id="_" obligation="normative">
              <title>Clause 4.2</title>
            </clause>
          </clause>
          <clause id="_" obligation="normative">
            <title>Terms and Definitions</title>
          </clause>
          <clause id="_" obligation="normative">
            <title>Bibliography</title>
            <clause id="_" obligation="normative">
              <title>Bibliography Subsection</title>
            </clause>
          </clause>
        </sections>
        <annex id='_' obligation='normative'>
          <title>Annex</title>
          <clause id='_' obligation='normative'>
            <title>Annex A.1</title>
          </clause>
          <appendix id='_' obligation='normative'>
            <title>Appendix 1</title>
          </appendix>
        </annex>
      </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(input)
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes default metadata, amendment" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 17301
      :partnumber: 1
      :edition: 2
      :revdate: 2000-01-01
      :draft: 0.3.4
      :technical-committee: TC
      :technical-committee-number: 1
      :technical-committee-type: A
      :subcommittee: SC
      :subcommittee-number: 2
      :subcommittee-type: B
      :workgroup: WG
      :workgroup-number: 3
      :workgroup-type: C
      :technical-committee_2: TC1
      :technical-committee-number_2: 11
      :technical-committee-type_2: A1
      :subcommittee_2: SC1
      :subcommittee-number_2: 21
      :subcommittee-type_2: B1
      :workgroup_2: WG1
      :workgroup-number_2: 31
      :workgroup-type_2: C1
      :secretariat: SECRETARIAT
      :docstage: 10
      :docsubstage: 20
      :iteration: 3
      :language: en
      :title-intro-en: Introduction
      :title-main-en: Main Title -- Title
      :title-part-en: Title Part
      :title-intro-fr: Introduction Française
      :title-main-fr: Titre Principal
      :title-part-fr: Part du Titre
      :copyright-year: 2017
      :updates: ISO 17301-1:2016
      :created-date: 2016-05-01
      :amendment-number: 1
      :title-amendment-en: Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions
      :title-amendment-fr: Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport
      :doctype: amendment
      :updates-document-type: international-standard
    INPUT

    output = <<~OUTPUT
      <iso-standard type="semantic" version="#{Metanorma::Iso::VERSION}" xmlns="https://www.metanorma.org/ns/iso">
          <bibdata type="standard">
             <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part — Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
             <title language="en" format="text/plain" type="title-intro">Introduction</title>
             <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
             <title language="en" format="text/plain" type="title-part">Title Part</title>
             <title language="en" format="text/plain" type="title-amd">Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
             <title language="fr" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre — Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport</title>
             <title language="fr" format="text/plain" type="title-intro">Introduction Française</title>
             <title language="fr" format="text/plain" type="title-main">Titre Principal</title>
             <title language="fr" format="text/plain" type="title-part">Part du Titre</title>
             <title language="fr" format="text/plain" type="title-amd">Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport</title>
             <docidentifier type="ISO" primary="true">ISO 17301-1:2016/NP Amd 1.3:2017</docidentifier>
             <docidentifier type="iso-reference">ISO 17301-1:2016/NP Amd 1.3:2017(E)</docidentifier>
             <docidentifier type="URN">urn:iso:std:iso:17301:-1:ed-1:stage-10.20:amd:2017:v1</docidentifier>
             <docnumber>17301</docnumber>
             <date type="created">
                <on>2016-05-01</on>
             </date>
             <contributor>
                <role type="author"/>
                <organization>
                   <name>International Organization for Standardization</name>
                   <abbreviation>ISO</abbreviation>
                </organization>
             </contributor>
             <contributor>
                <role type="author">
                   <description>Technical committee</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <subdivision>
                         <name>TC</name>
                         <identifier>A 1</identifier>
                   </subdivision>
                </organization>
             </contributor>
             <contributor>
                <role type="author">
                   <description>Technical committee</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <subdivision>
                         <name>TC1</name>
                         <identifier>A1 11</identifier>
                   </subdivision>
                </organization>
             </contributor>
             <contributor>
                <role type="author">
                   <description>Subcommittee</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <subdivision>
                         <name>SC</name>
                         <identifier>B 2</identifier>
                   </subdivision>
                </organization>
             </contributor>
             <contributor>
                <role type="author">
                   <description>Subcommittee</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <subdivision>
                         <name>SC1</name>
                         <identifier>B1 21</identifier>
                   </subdivision>
                </organization>
             </contributor>
             <contributor>
                <role type="author">
                   <description>Workgroup</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <subdivision>
                         <name>WG</name>
                         <identifier>C 3</identifier>
                   </subdivision>
                </organization>
             </contributor>
             <contributor>
                <role type="author">
                   <description>Workgroup</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <subdivision>
                         <name>WG1</name>
                         <identifier>C1 31</identifier>
                   </subdivision>
                </organization>
             </contributor>
             <contributor>
                <role type="authorizer">
                   <description>Agency</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <abbreviation>ISO</abbreviation>
                </organization>
             </contributor>
             <contributor>
                <role type="publisher"/>
                <organization>
                   <name>International Organization for Standardization</name>
                   <abbreviation>ISO</abbreviation>
                </organization>
             </contributor>
             <contributor>
                <role type="authorizer">
                   <description>Technical committee</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <subdivision>
                         <name>TC</name>
                         <identifier>A 1</identifier>
                   </subdivision>
                </organization>
             </contributor>
             <contributor>
                <role type="authorizer">
                   <description>Technical committee</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <subdivision>
                         <name>TC1</name>
                         <identifier>A1 11</identifier>
                   </subdivision>
                </organization>
             </contributor>
             <contributor>
                <role type="authorizer">
                   <description>Subcommittee</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <subdivision>
                         <name>SC</name>
                         <identifier>B 2</identifier>
                   </subdivision>
                </organization>
             </contributor>
             <contributor>
                <role type="authorizer">
                   <description>Subcommittee</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <subdivision>
                         <name>SC1</name>
                         <identifier>B1 21</identifier>
                   </subdivision>
                </organization>
             </contributor>
             <contributor>
                <role type="authorizer">
                   <description>Workgroup</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <subdivision>
                         <name>WG</name>
                         <identifier>C 3</identifier>
                   </subdivision>
                </organization>
             </contributor>
             <contributor>
                <role type="authorizer">
                   <description>Workgroup</description>
                </role>
                <organization>
                   <name>International Organization for Standardization</name>
                   <subdivision>
                         <name>WG1</name>
                         <identifier>C1 31</identifier>
                   </subdivision>
                </organization>
             </contributor>
             <edition>2</edition>
             <version>
                <revision-date>2000-01-01</revision-date>
                <draft>0.3.4</draft>
             </version>
             <language>en</language>
             <script>Latn</script>
             <status>
                <stage abbreviation="NP">10</stage>
                <substage>20</substage>
                <iteration>3</iteration>
             </status>
             <copyright>
                <from>2017</from>
                <owner>
                   <organization>
                      <name>International Organization for Standardization</name>
                      <abbreviation>ISO</abbreviation>
                   </organization>
                </owner>
             </copyright>
             <ext>
                <doctype>amendment</doctype>
                <flavor>iso</flavor>
                <editorialgroup>
                   <agency>ISO</agency>
                   <technical-committee number="1" type="A">TC</technical-committee>
                   <technical-committee number="11" type="A1">TC1</technical-committee>
                   <subcommittee number="2" type="B">SC</subcommittee>
                   <subcommittee number="21" type="B1">SC1</subcommittee>
                   <workgroup number="3" type="C">WG</workgroup>
                   <workgroup number="31" type="C1">WG1</workgroup>
                   <secretariat>SECRETARIAT</secretariat>
                </editorialgroup>
                <approvalgroup>
                   <agency>ISO</agency>
                   <technical-committee number="1" type="A">TC</technical-committee>
                   <technical-committee number="11" type="A1">TC1</technical-committee>
                   <subcommittee number="2" type="B">SC</subcommittee>
                   <subcommittee number="21" type="B1">SC1</subcommittee>
                   <workgroup number="3" type="C">WG</workgroup>
                   <workgroup number="31" type="C1">WG1</workgroup>
                </approvalgroup>
                <structuredidentifier>
                   <project-number part="1" amendment="1" origyr="2016-05-01">17301</project-number>
                </structuredidentifier>
                <stagename abbreviation="NP AMD"/>
                <updates-document-type>international-standard</updates-document-type>
             </ext>
          </bibdata>
          <sections> </sections>
       </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(input)
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes metadata, amendment, stage 30" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 17301
      :partnumber: 1
      :doctype: amendment
      :docstage: 30
      :updates: ISO 17301-1:2030
      :amendment-number: 1
    INPUT
    output = <<~OUTPUT
      <iso-standard type="semantic" version="#{Metanorma::Iso::VERSION}" xmlns="https://www.metanorma.org/ns/iso">
        <bibdata type="standard">
          <docidentifier type="ISO" primary="true">ISO 17301-1:2030/CD Amd 1:#{Date.today.year}</docidentifier>
          <docidentifier type="iso-reference">ISO 17301-1:2030/CD Amd 1:#{Date.today.year}(E)</docidentifier>
          <docidentifier type='URN'>urn:iso:std:iso:17301:-1:ed-1:stage-30.00:amd:#{Date.today.year}:v1</docidentifier>
          <docnumber>17301</docnumber>
          <contributor>
            <role type="author"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
                      <contributor>
              <role type="authorizer"><description>Agency</description></role>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </contributor>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage abbreviation="CD">30</stage>
            <substage>00</substage>
          </status>
          <copyright>
            <from>#{Time.now.year}</from>
            <owner>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype>amendment</doctype>
                <flavor>iso</flavor>
            <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
            <structuredidentifier>
              <project-number amendment="1" part="1">17301</project-number>
            </structuredidentifier>
            <stagename  abbreviation="CD AMD"/>
          </ext>
        </bibdata>
        <sections/>
      </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(input)
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes metadata, amendment, stage 40" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 17301
      :partnumber: 1
      :doctype: amendment
      :docstage: 40
      :updates: ISO 17301-1:2030
      :amendment-number: 1
    INPUT
    output = <<~OUTPUT
      <iso-standard type="semantic" version="#{Metanorma::Iso::VERSION}" xmlns="https://www.metanorma.org/ns/iso">
        <bibdata type="standard">
          <docidentifier type="ISO" primary="true">ISO 17301-1:2030/DAM 1:#{Date.today.year}</docidentifier>
          <docidentifier type="iso-reference">ISO 17301-1:2030/DAM 1:#{Date.today.year}(E)</docidentifier>
          <docidentifier type='URN'>urn:iso:std:iso:17301:-1:ed-1:stage-40.00:amd:#{Date.today.year}:v1</docidentifier>
          <docnumber>17301</docnumber>
          <contributor>
            <role type="author"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
                      <contributor>
              <role type="authorizer"><description>Agency</description></role>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </contributor>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage abbreviation="DAMD">40</stage>
            <substage>00</substage>
          </status>
          <copyright>
            <from>#{Time.now.year}</from>
            <owner>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype>amendment</doctype>
                <flavor>iso</flavor>
            <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
            <structuredidentifier>
              <project-number amendment="1" part="1">17301</project-number>
            </structuredidentifier>
            <stagename abbreviation="DAM"/>
          </ext>
        </bibdata>
        <sections/>
      </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(input)
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes metadata, amendment, published" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 17301
      :partnumber: 1
      :doctype: amendment
      :updates: ISO 17301-1:2030
      :amendment-number: 1
    INPUT
    output = <<~OUTPUT
      <iso-standard type="semantic" version="#{Metanorma::Iso::VERSION}" xmlns="https://www.metanorma.org/ns/iso">
        <bibdata type="standard">
          <docidentifier type="ISO" primary="true">ISO 17301-1:2030/Amd 1:#{Date.today.year}</docidentifier>
          <docidentifier type="iso-reference">ISO 17301-1:2030/Amd 1:#{Date.today.year}(E)</docidentifier>
          <docidentifier type='URN'>urn:iso:std:iso:17301:-1:ed-1:stage-60.60:amd:#{Date.today.year}:v1</docidentifier>
          <docnumber>17301</docnumber>
          <contributor>
            <role type="author"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
                      <contributor>
              <role type="authorizer"><description>Agency</description></role>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </contributor>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage>60</stage>
            <substage>60</substage>
          </status>
          <copyright>
            <from>#{Time.now.year}</from>
            <owner>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype>amendment</doctype>
                <flavor>iso</flavor>
             <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
            <structuredidentifier>
              <project-number amendment="1" part="1">17301</project-number>
            </structuredidentifier>
            <stagename abbreviation="AMD"/>
          </ext>
        </bibdata>
        <sections/>
      </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(input)
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes metadata, corrigendum, stage 30" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 17301
      :partnumber: 1
      :doctype: technical-corrigendum
      :docstage: 30
      :updates: ISO 17301-1:2030
      :corrigendum-number: 3
    INPUT
    output = <<~OUTPUT
      <iso-standard type="semantic" version="#{Metanorma::Iso::VERSION}" xmlns="https://www.metanorma.org/ns/iso">
        <bibdata type="standard">
          <docidentifier type="ISO" primary="true">ISO 17301-1:2030/CD Cor 3:#{Date.today.year}</docidentifier>
          <docidentifier type="iso-reference">ISO 17301-1:2030/CD Cor 3:#{Date.today.year}(E)</docidentifier>
          <docidentifier type='URN'>urn:iso:std:iso:17301:-1:ed-1:stage-30.00:cor:#{Date.today.year}:v3</docidentifier>
          <docnumber>17301</docnumber>
          <contributor>
            <role type="author"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
                      <contributor>
              <role type="authorizer"><description>Agency</description></role>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </contributor>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage abbreviation="CD">30</stage>
            <substage>00</substage>
          </status>
          <copyright>
            <from>#{Time.now.year}</from>
            <owner>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype>technical-corrigendum</doctype>
                <flavor>iso</flavor>
             <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
            <structuredidentifier>
              <project-number corrigendum="3" part="1">17301</project-number>
            </structuredidentifier>
            <stagename abbreviation="CD COR"/>
          </ext>
        </bibdata>
        <sections/>
      </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(input)
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes metadata, corrigendum, stage 50" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 17301
      :partnumber: 1
      :doctype: technical-corrigendum
      :docstage: 50
      :updates: ISO 17301-1:2030
      :corrigendum-number: 3
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='https://www.metanorma.org/ns/iso'  type="semantic" version="#{Metanorma::Iso::VERSION}">
        <bibdata type='standard'>
          <docidentifier type='ISO' primary="true">ISO 17301-1:2030/FDCOR 3:#{Date.today.year}</docidentifier>
          <docidentifier type='iso-reference'>ISO 17301-1:2030/FDCOR 3:#{Date.today.year}(E)</docidentifier>
          <docidentifier type='URN'>urn:iso:std:iso:17301:-1:ed-1:stage-50.00:cor:#{Date.today.year}:v3</docidentifier>
          <docnumber>17301</docnumber>
          <contributor>
            <role type='author'/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type='publisher'/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
                      <contributor>
              <role type="authorizer"><description>Agency</description></role>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </contributor>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage abbreviation='FDCOR'>50</stage>
            <substage>00</substage>
          </status>
          <copyright>
            <from>#{Time.now.year}</from>
            <owner>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype>technical-corrigendum</doctype>
                <flavor>iso</flavor>
                        <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
            <structuredidentifier>
              <project-number part='1' corrigendum='3'>17301</project-number>
            </structuredidentifier>
            <stagename abbreviation="FDCOR"/>
          </ext>
        </bibdata>
        <sections/>
      </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(input)
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes metadata, corrigendum, published" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 17301
      :partnumber: 1
      :doctype: technical-corrigendum
      :updates: ISO 17301-1:2030
      :corrigendum-number: 3
    INPUT
    output = <<~OUTPUT
      <iso-standard type="semantic" version="#{Metanorma::Iso::VERSION}" xmlns="https://www.metanorma.org/ns/iso">
        <bibdata type="standard">
          <docidentifier type="ISO" primary="true">ISO 17301-1:2030/Cor 3:#{Date.today.year}</docidentifier>
          <docidentifier type="iso-reference">ISO 17301-1:2030/Cor 3:#{Date.today.year}(E)</docidentifier>
          <docidentifier type='URN'>urn:iso:std:iso:17301:-1:ed-1:stage-60.60:cor:#{Date.today.year}:v3</docidentifier>
          <docnumber>17301</docnumber>
          <contributor>
            <role type="author"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
                        <contributor>
              <role type="authorizer"><description>Agency</description></role>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </contributor>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage>60</stage>
            <substage>60</substage>
          </status>
          <copyright>
            <from>#{Time.now.year}</from>
            <owner>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype>technical-corrigendum</doctype>
                <flavor>iso</flavor>
                        <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
            <structuredidentifier>
              <project-number corrigendum="3" part="1">17301</project-number>
            </structuredidentifier>
            <stagename abbreviation="COR"/>
          </ext>
        </bibdata>
        <sections/>
      </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(input)
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes metadata, addendum" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 17301
      :partnumber: 1
      :doctype: addendum
      :updates: ISO 17301-1:2030
      :addendum-number: 3
      :title-addendum-en: Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions
      :title-addendum-fr: Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport
      :updates-document-type: international-standard
    INPUT
    output = <<~OUTPUT
      <iso-standard type="semantic" version="#{Metanorma::Iso::VERSION}" xmlns="https://www.metanorma.org/ns/iso">
        <bibdata type="standard">
          <title language="en" format="text/plain" type="title-add">Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
          <title language="fr" format="text/plain" type="title-add">Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport</title>
          <docidentifier type="ISO" primary="true">ISO 17301-1:2030/Add 3:#{Date.today.year}</docidentifier>
          <docidentifier type="iso-reference">ISO 17301-1:2030/Add 3:#{Date.today.year}(E)</docidentifier>
          <docidentifier type='URN'>urn:iso:std:iso:17301:-1:ed-1:stage-60.60:sup:iso:#{Date.today.year}:v3</docidentifier>
          <docidentifier type="iso-undated">ISO 17301-1:2030/Add 3</docidentifier>
          <docidentifier type="iso-with-lang">ISO 17301-1:2030/Add 3:2024(en)</docidentifier>
          <docnumber>17301</docnumber>
          <contributor>
            <role type="author"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
                        <contributor>
              <role type="authorizer"><description>Agency</description></role>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </contributor>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage>60</stage>
            <substage>60</substage>
          </status>
          <copyright>
            <from>#{Time.now.year}</from>
            <owner>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype>addendum</doctype>
            <flavor>iso</flavor>
            <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
            <structuredidentifier>
              <project-number addendum="3" part="1">17301</project-number>
            </structuredidentifier>
            <stagename abbreviation="ADD">Addendum</stagename>
          </ext>
        </bibdata>
        <sections/>
      </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(input)
    xml.at("//xmlns:metanorma-extension")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
