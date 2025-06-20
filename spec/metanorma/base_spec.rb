require "spec_helper"
RSpec.describe Metanorma::Iso do
  it "has a version number" do
    expect(Metanorma::Iso::VERSION).not_to be nil
  end

  it "processes default metadata" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
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
      :approval-technical-committee: TCa
      :approval-technical-committee-number: 1a
      :approval-technical-committee-type: Aa
      :approval-subcommittee: SCa
      :approval-subcommittee-number: 2a
      :approval-subcommittee-type: Ba
      :approval-workgroup: WGa
      :approval-workgroup-number: 3a
      :approval-workgroup-type: Ca
      :approval-technical-committee_2: TC1a
      :approval-technical-committee-number_2: 11a
      :approval-technical-committee-type_2: A1a
      :approval-subcommittee_2: SC1a
      :approval-subcommittee-number_2: 21a
      :approval-subcommittee-type_2: B1a
      :approval-workgroup_2: WG1a
      :approval-workgroup-number_2: 31a
      :approval-workgroup-type_2: C1a
      :approval-agency: ISO/IEC
      :docstage: 20
      :docsubstage: 20
      :iteration: 3
      :language: en
      :title-intro-en: Introduction
      :title-main-en: Main Title -- Title
      :title-part-en: Title Part
      :title-intro-fr: Introduction Française
      :title-main-fr: Titre Principal
      :title-part-fr: Part du Titre
      :copyright-year: 2000
      :horizontal: true
      :fast-track: true
      :price-code: XC
      :iso-cen-parallel:
    INPUT
    output = <<~OUTPUT
      <bibdata type="standard">
        <title format="text/plain" language="en" type="main">Introduction — Main Title — Title — Title Part</title>
        <title format="text/plain" language="en" type="title-intro">Introduction</title>
        <title format="text/plain" language="en" type="title-main">Main Title — Title</title>
        <title format="text/plain" language="en" type="title-part">Title Part</title>
        <title format="text/plain" language="fr" type="main">Introduction Française — Titre Principal — Part du Titre</title>
        <title format="text/plain" language="fr" type="title-intro">Introduction Française</title>
        <title format="text/plain" language="fr" type="title-main">Titre Principal</title>
        <title format="text/plain" language="fr" type="title-part">Part du Titre</title>
        <docidentifier type="ISO" primary="true">ISO/WD 1000-1.3:2000</docidentifier>
        <docidentifier type="iso-reference">ISO/WD 1000-1.3:2000(E)</docidentifier>
        <docidentifier type='URN'>urn:iso:std:iso:1000:-1:stage-20.20.v3:en</docidentifier>
        <docidentifier type='iso-undated'>ISO/WD 1000-1.3</docidentifier>
        <docidentifier type="iso-with-lang">ISO/WD 1000-1.3:2000(en)</docidentifier>
        <docnumber>1000</docnumber>
                   <contributor>
           <role type="author"/>
           <organization>
             <name>International Organization for Standardization</name>
             <abbreviation>ISO</abbreviation>
           </organization>
         </contributor>
         <contributor>
           <role type="author"><description>Technical committee</description></role>
           <organization>
             <name>International Organization for Standardization</name>
             <subdivision><name>TC</name>
             <identifier>A 1</identifier>
             </subdivision>
           </organization>
         </contributor>
         <contributor>
         <role type="author"><description>Technical committee</description></role>
           <organization>
             <name>International Organization for Standardization</name>
             <subdivision><name>TC1</name>
             <identifier>A1 11</identifier>
             </subdivision>
           </organization>
         </contributor>
         <contributor>
           <role type="author"><description>Subcommittee</description></role>
           <organization>
             <name>International Organization for Standardization</name>
             <subdivision><name>SC</name>
             <identifier>B 2</identifier>
             </subdivision>
           </organization>
         </contributor>
         <contributor>
           <role type="author"><description>Subcommittee</description></role>
           <organization>
             <name>International Organization for Standardization</name>
             <subdivision><name>SC1</name>
             <identifier>B1 21</identifier>
             </subdivision>
           </organization>
         </contributor>
         <contributor>
           <role type="author"><description>Workgroup</description></role>
           <organization>
             <name>International Organization for Standardization</name>
             <subdivision><name>WG</name>
             <identifier>C 3</identifier>
             </subdivision>
           </organization>
         </contributor>
         <contributor>
           <role type="author"><description>Workgroup</description></role>
           <organization>
             <name>International Organization for Standardization</name>
             <subdivision><name>WG1</name>
             <identifier>C1 31</identifier>
             </subdivision>
           </organization>
         </contributor>
         <contributor>
           <role type="authorizer"><description>Agency</description></role>
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
         <role type="authorizer"><description>Technical committee</description></role>
           <organization>
             <name>ISO/IEC</name>
             <subdivision><name>TCa</name>
             <identifier>Aa 1a</identifier>
             </subdivision>
           </organization>
         </contributor>
         <contributor>
         <role type="authorizer"><description>Technical committee</description></role>
           <organization>
             <name>ISO/IEC</name>
             <subdivision><name>TC1a</name>
             <identifier>A1a 11a</identifier>
             </subdivision>
           </organization>
         </contributor>
         <contributor>
           <role type="authorizer"><description>Subcommittee</description></role>
           <organization>
             <name>ISO/IEC</name>
             <subdivision><name>SCa</name>
             <identifier>Ba 2a</identifier>
             </subdivision>
           </organization>
         </contributor>
         <contributor>
           <role type="authorizer"><description>Subcommittee</description></role>
           <organization>
             <name>ISO/IEC</name>
             <subdivision><name>SC1a</name>
             <identifier>B1a 21a</identifier>
             </subdivision>
           </organization>
         </contributor>
         <contributor>
           <role type="authorizer"><description>Workgroup</description></role>
           <organization>
             <name>ISO/IEC</name>
             <subdivision><name>WGa</name>
             <identifier>Ca 3a</identifier>
             </subdivision>
           </organization>
         </contributor>
         <contributor>
           <role type="authorizer"><description>Workgroup</description></role>
           <organization>
             <name>ISO/IEC</name>
             <subdivision><name>WG1a</name>
             <identifier>C1a 31a</identifier>
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
          <stage abbreviation="WD">20</stage>
          <substage>20</substage>
          <iteration>3</iteration>
        </status>
        <copyright>
          <from>2000</from>
          <owner>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype>standard</doctype>
          <flavor>iso</flavor>
          <horizontal>true</horizontal>
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
            <agency>IEC</agency>
            <technical-committee number="1a" type="Aa">TCa</technical-committee>
            <technical-committee number="11a" type="A1a">TC1a</technical-committee>
            <subcommittee number="2a" type="Ba">SCa</subcommittee>
            <subcommittee number="21a" type="B1a">SC1a</subcommittee>
            <workgroup number="3a" type="Ca">WGa</workgroup>
            <workgroup number="31a" type="C1a">WG1a</workgroup>
          </approvalgroup>
          <structuredidentifier>
            <project-number part="1">ISO 1000</project-number>
          </structuredidentifier>
          <stagename abbreviation="WD">Working Draft International Standard</stagename>
          <fast-track>true</fast-track>
          <price-code>XC</price-code>
          <iso-cen-parallel>true</iso-cen-parallel>
        </ext>
      </bibdata>
    OUTPUT
    xml = xml.at("//xmlns:bibdata")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes complex metadata" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~"INPUT", *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :partnumber: 1-1
      :tc-docnumber: 2000, 2003
      :language: el
      :script: Grek
      :publisher: IEC;IETF;ISO
      :copyright-holder: IETF;ISO
      :copyright-year: 2001
      :doctype: technical-report
      :pub-address: 1 Infinity Loop + \
      California
      :pub-phone: 3333333
      :pub-fax: 4444444
      :pub-email: x@example.com
      :pub-uri: http://www.example.com
      :docstage:
      :docsubstage:
      :technical-committee: Techcomm
      :technical-committee-number: 1
      :subcommittee: Subcommitt
      :subcommittee-number: 2
      :workgroup: Workg
      :workgroup-number: 3
      :approval-technical-committee: ApprovTechcom
      :approval-technical-committee-number: 1
      :approval-subcommittee: ApprovSubcom
      :approval-subcommittee-number: 2
      :approval-workgroup: ApprovWorkg
      :approval-workgroup-number: 3
      :title-main-en: Main Title -- Title
      :title-complementary-en: Title Complement
      :title-main-fr: Titre Principal
      :title-complementary-fr: Complement du Titre
    INPUT
    output = <<~OUTPUT
           <bibdata type="standard">
             <title language="en" format="text/plain" type="main">Main Title — Title — Title Complement</title>
            <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
            <title language="en" format="text/plain" type="title-complementary">Title Complement</title>
            <title language="fr" format="text/plain" type="main">Titre Principal — Complement du Titre</title>
            <title language="fr" format="text/plain" type="title-main">Titre Principal</title>
            <title language="fr" format="text/plain" type="title-complementary">Complement du Titre</title>
             <docidentifier type='ISO' primary="true">IEC/IETF/ISO TR 1000-1-1:2001</docidentifier>
             <docidentifier type='iso-reference'>IEC/IETF/ISO TR 1000-1-1:2001()</docidentifier>
             <docidentifier type='URN'>urn:iso:std:iec-ietf-iso:tr:1000:-1-1:stage-60.60:el</docidentifier>
             <docidentifier type='iso-undated'>IEC/IETF/ISO TR 1000-1-1</docidentifier>
             <docidentifier type='iso-with-lang'>IEC/IETF/ISO TR 1000-1-1:2001(el)</docidentifier>
             <docidentifier type="iso-tc">2000</docidentifier>
             <docidentifier type="iso-tc">2003</docidentifier>
             <docnumber>1000</docnumber>
                        <contributor>
          <role type="author"/>
          <organization>
            <name>International Electrotechnical Commission</name>
            <abbreviation>IEC</abbreviation>
          </organization>
        </contributor>
        <contributor>
          <role type="author"/>
          <organization>
            <name>IETF</name>
          </organization>
        </contributor>
        <contributor>
          <role type="author"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <contributor>
        <role type="author"><description>Technical committee</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <subdivision><name>Techcomm</name>
            <identifier>TC 1</identifier>
            </subdivision>
          </organization>
        </contributor>
        <contributor>
          <role type="author"><description>Subcommittee</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <subdivision><name>Subcommitt</name>
            <identifier>SC 2</identifier>
            </subdivision>
          </organization>
        </contributor>
        <contributor>
          <role type="author"><description>Workgroup</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <subdivision><name>Workg</name>
            <identifier>WG 3</identifier>
            </subdivision>
          </organization>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Electrotechnical Commission</name>
            <abbreviation>IEC</abbreviation>
          </organization>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>IETF</name>
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
        <role type="authorizer"><description>Technical committee</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <subdivision><name>ApprovTechcom</name>
            <identifier>TC 1</identifier>
            </subdivision>
          </organization>
        </contributor>
        <contributor>
          <role type="authorizer"><description>Subcommittee</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <subdivision><name>ApprovSubcom</name>
            <identifier>SC 2</identifier>
            </subdivision>
          </organization>
        </contributor>
        <contributor>
          <role type="authorizer"><description>Workgroup</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <subdivision><name>ApprovWorkg</name>
            <identifier>WG 3</identifier>
            </subdivision>
          </organization>
        </contributor>
        <contributor>
          <role type="authorizer"><description>Agency</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
             <language>el</language>
             <script>Grek</script>
             <status>
               <stage>60</stage>
               <substage>60</substage>
             </status>
             <copyright>
               <from>2001</from>
               <owner>
                 <organization>
                   <name>IETF</name>
                 </organization>
               </owner>
             </copyright>
                               <copyright>
               <from>2001</from>
               <owner>
                 <organization>
                   <name>International Organization for Standardization</name>
                   <abbreviation>ISO</abbreviation>
                 </organization>
               </owner>
             </copyright>
             <ext>
               <doctype>technical-report</doctype>
                <flavor>iso</flavor>
        <editorialgroup>
         <agency>IEC</agency>
         <agency>IETF</agency>
         <agency>ISO</agency>
                        <technical-committee number="1" type="TC">Techcomm</technical-committee>
            <subcommittee number="2" type="SC">Subcommitt</subcommittee>
            <workgroup number="3" type="WG">Workg</workgroup>
          </editorialgroup>
          <approvalgroup>
            <agency>ISO</agency>
            <technical-committee number="1" type="TC">ApprovTechcom</technical-committee>
            <subcommittee number="2" type="SC">ApprovSubcom</subcommittee>
            <workgroup number="3" type="WG">ApprovWorkg</workgroup>
          </approvalgroup>
          <structuredidentifier>
            <project-number part="1" subpart="1">IEC/IETF/ISO 1000</project-number>
          </structuredidentifier>
          <stagename abbreviation="TR">Technical Report</stagename>
        </ext>
      </bibdata>
    OUTPUT
    xml = xml.at("//xmlns:bibdata")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes full publisher names" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~"INPUT", *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :publisher: International Organization for Standardization; International Electrotechnical Commission
      :doctype: technical-report
    INPUT
    output = <<~OUTPUT
          <bibdata type="standard">
        <docidentifier type="ISO" primary="true">ISO/IEC TR 1000:#{Date.today.year}</docidentifier>
        <docidentifier type="iso-reference">ISO/IEC TR 1000:#{Date.today.year}(E)</docidentifier>
        <docidentifier type="URN">urn:iso:std:iso-iec:tr:1000:stage-60.60:en</docidentifier>
        <docidentifier type="iso-undated">ISO/IEC TR 1000</docidentifier>
        <docidentifier type="iso-with-lang">ISO/IEC TR 1000:#{Date.today.year}(en)</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type="author"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <contributor>
          <role type="author"/>
          <organization>
            <name>International Electrotechnical Commission</name>
            <abbreviation>IEC</abbreviation>
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
          <role type="publisher"/>
          <organization>
            <name>International Electrotechnical Commission</name>
            <abbreviation>IEC</abbreviation>
          </organization>
        </contributor>
        <language>en</language>
        <script>Latn</script>
        <status>
          <stage>60</stage>
          <substage>60</substage>
        </status>
        <copyright>
          <from>#{Date.today.year}</from>
          <owner>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </owner>
        </copyright>
        <copyright>
          <from>#{Date.today.year}</from>
          <owner>
            <organization>
              <name>International Electrotechnical Commission</name>
              <abbreviation>IEC</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype>technical-report</doctype>
                <flavor>iso</flavor>
          <editorialgroup>
            <agency>ISO</agency>
            <agency>IEC</agency>
          </editorialgroup>
          <approvalgroup>
            <agency>ISO</agency>
          </approvalgroup>
          <structuredidentifier>
            <project-number>ISO/IEC 1000</project-number>
          </structuredidentifier>
          <stagename abbreviation="TR">Technical Report</stagename>
        </ext>
      </bibdata>
    OUTPUT
    xml = xml.at("//xmlns:bibdata")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes committee type of Other" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :technical-committee: Techcomm
      :technical-committee-number: 1
      :technical-committee-type: Other
      :subcommittee: Subcommitt
      :subcommittee-number: 2
      :subcommittee-type: Other
      :workgroup: Workg
      :workgroup-number: 3
      :workgroup-type: Other
      :approval-technical-committee: ApprovTechcom
      :approval-technical-committee-number: 1
      :approval-technical-committee-type: Other
      :approval-subcommittee: ApprovSubcom
      :approval-subcommittee-number: 2
      :approval-subcommittee-type: Other
      :approval-workgroup: ApprovWorkg
      :approval-workgroup-number: 3
      :approval-workgroup-type: Other
    INPUT
    output = <<~OUTPUT
            <bibdata type="standard">
        <docidentifier type="ISO" primary="true">ISO 1000:#{Date.today.year}</docidentifier>
        <docidentifier type="iso-reference">ISO 1000:#{Date.today.year}(E)</docidentifier>
        <docidentifier type="URN">urn:iso:std:iso:1000:stage-60.60:en</docidentifier>
        <docidentifier type="iso-undated">ISO 1000</docidentifier>
        <docidentifier type="iso-with-lang">ISO 1000:#{Date.today.year}(en)</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type="author"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <contributor>
        <role type="author"><description>Technical committee</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <subdivision><name>Techcomm</name>
            <identifier>1</identifier>
            </subdivision>
          </organization>
        </contributor>
        <contributor>
          <role type="author"><description>Subcommittee</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <subdivision><name>Subcommitt</name>
            <identifier>2</identifier>
            </subdivision>
          </organization>
        </contributor>
        <contributor>
          <role type="author"><description>Workgroup</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <subdivision><name>Workg</name>
            <identifier>3</identifier>
            </subdivision>
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
        <role type="authorizer"><description>Technical committee</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <subdivision><name>ApprovTechcom</name>
            <identifier>1</identifier>
            </subdivision>
          </organization>
        </contributor>
        <contributor>
          <role type="authorizer"><description>Subcommittee</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <subdivision><name>ApprovSubcom</name>
            <identifier>2</identifier>
            </subdivision>
          </organization>
        </contributor>
        <contributor>
          <role type="authorizer"><description>Workgroup</description></role>
          <organization>
            <name>International Organization for Standardization</name>
            <subdivision><name>ApprovWorkg</name>
            <identifier>3</identifier>
            </subdivision>
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
          <from>#{Date.today.year}</from>
          <owner>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype>standard</doctype>
                <flavor>iso</flavor>
          <editorialgroup>
            <agency>ISO</agency>
            <technical-committee number="1" type="Other">Techcomm</technical-committee>
            <subcommittee number="2" type="Other">Subcommitt</subcommittee>
            <workgroup number="3" type="Other">Workg</workgroup>
          </editorialgroup>
          <approvalgroup>
            <agency>ISO</agency>
            <technical-committee number="1" type="Other">ApprovTechcom</technical-committee>
            <subcommittee number="2" type="Other">ApprovSubcom</subcommittee>
            <workgroup number="3" type="Other">ApprovWorkg</workgroup>
          </approvalgroup>
          <structuredidentifier>
            <project-number>ISO 1000</project-number>
          </structuredidentifier>
          <stagename>International Standard</stagename>
        </ext>
      </bibdata>
    OUTPUT
    xml = xml.at("//xmlns:bibdata")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "supplies missing committee attributes" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :technical-committee-number: 1
      :technical-committee-type: Other
      :subcommittee-number: 2
      :subcommittee-type: Other
      :workgroup-number: 3
      :workgroup-type: Other
      :approval-technical-committee-number: 1
      :approval-technical-committee-type: Other
      :approval-subcommittee-number: 2
      :approval-subcommittee-type: Other
      :approval-workgroup-number: 3
      :approval-workgroup-type: Other
    INPUT
    output = <<~OUTPUT
      <bibdata type="standard">
        <docidentifier type="ISO" primary="true">ISO 1000:#{Date.today.year}</docidentifier>
        <docidentifier type="iso-reference">ISO 1000:#{Date.today.year}(E)</docidentifier>
        <docidentifier type="URN">urn:iso:std:iso:1000:stage-60.60:en</docidentifier>
        <docidentifier type="iso-undated">ISO 1000</docidentifier>
        <docidentifier type="iso-with-lang">ISO 1000:#{Date.today.year}(en)</docidentifier>
        <docnumber>1000</docnumber>
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
                      <identifier>1</identifier>
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
                      <identifier>2</identifier>
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
                      <identifier>3</identifier>
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
                      <identifier>1</identifier>
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
                      <identifier>2</identifier>
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
                      <identifier>3</identifier>
                </subdivision>
             </organization>
          </contributor>
          <language>en</language>
          <script>Latn</script>
          <status>
             <stage>60</stage>
             <substage>60</substage>
          </status>
          <copyright>
             <from>#{Date.today.year}</from>
             <owner>
                <organization>
                   <name>International Organization for Standardization</name>
                   <abbreviation>ISO</abbreviation>
                </organization>
             </owner>
          </copyright>
          <ext>
             <doctype>standard</doctype>
                <flavor>iso</flavor>
             <editorialgroup>
                <agency>ISO</agency>
                <technical-committee number="1" type="Other"/>
                <subcommittee number="2" type="Other"/>
                <workgroup number="3" type="Other"/>
             </editorialgroup>
             <approvalgroup>
                <agency>ISO</agency>
                <technical-committee number="1" type="Other"/>
                <subcommittee number="2" type="Other"/>
                <workgroup number="3" type="Other"/>
             </approvalgroup>
             <structuredidentifier>
                <project-number>ISO 1000</project-number>
             </structuredidentifier>
             <stagename>International Standard</stagename>
          </ext>
       </bibdata>
    OUTPUT
    xml = xml.at("//xmlns:bibdata")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes tech specification identifier" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :partnumber: 1-1
      :copyright-year: 2001
      :doctype: technical-specification
      :docstage: 50
      :docsubstage:
    INPUT
    output = <<~OUTPUT
      <bibdata type='standard'>
        <docidentifier type='ISO' primary="true">ISO/FDTS 1000-1-1:2001</docidentifier>
        <docidentifier type='iso-reference'>ISO/FDTS 1000-1-1:2001(E)</docidentifier>
        <docidentifier type='URN'>urn:iso:std:iso:ts:1000:-1-1:stage-50.00:en</docidentifier>
        <docidentifier type='iso-undated'>ISO/FDTS 1000-1-1</docidentifier>
        <docidentifier type='iso-with-lang'>ISO/FDTS 1000-1-1:2001(en)</docidentifier>
        <docnumber>1000</docnumber>
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
          <stage abbreviation='FDTS'>50</stage>
          <substage>00</substage>
        </status>
        <copyright>
          <from>2001</from>
          <owner>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype>technical-specification</doctype>
                <flavor>iso</flavor>
                      <editorialgroup>
          <agency>ISO</agency>
         </editorialgroup>
         <approvalgroup>
          <agency>ISO</agency>
         </approvalgroup>
          <structuredidentifier>
            <project-number part='1' subpart='1'>ISO 1000</project-number>
          </structuredidentifier>
          <stagename abbreviation="FDTS">Final Draft Technical Specification</stagename>
        </ext>
      </bibdata>
    OUTPUT
    xml = xml.at("//xmlns:bibdata")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes committee document metadata" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :partnumber: 1
      :edition: 2
      :technical-committee: TC
      :technical-committee-number: 1
      :technical-committee-type: A
      :subcommittee: SC
      :subcommittee-number: 2
      :subcommittee-type: B
      :workgroup: WG
      :workgroup-number: 3
      :workgroup-type: C
      :secretariat: SECRETARIAT
      :IGNORE-docstage: 20
      :IGNORE-docsubstage: 20
      :iteration: 3
      :language: en
      :title-main-en: Main Title -- Title
      :title-part-en: Title Part
      :title-main-fr: Titre Principal
      :title-part-fr: Part du Titre
      :copyright-year: 2000
      :doctype: committee-document
    INPUT
    output = <<~OUTPUT
      <docidentifier type="ISO" primary="true">ISO/A 1/B 2/C 3 N1000</docidentifier>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
    xml = xml.xpath("//xmlns:bibdata/xmlns:docidentifier")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input1 = input.gsub(/:technical-committee-type:.+?[\r\n]+/m, "")
      .gsub(/:subcommittee-type:.+?[\r\n]+/m, "")
      .gsub(/:workgroup-type:.+?[\r\n]+/m, "")
    output = <<~OUTPUT
      <docidentifier type="ISO" primary="true">ISO/TC 1/SC 2/WG 3 N1000</docidentifier>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input1, *OPTIONS))
    xml = xml.xpath("//xmlns:bibdata/xmlns:docidentifier")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input1 = input.gsub(/:technical-committee-type:.+?[\r\n]+/m, "")
      .gsub(/:subcommittee-type:.+?[\r\n]+/m, "")
    output = <<~OUTPUT
      <docidentifier type="ISO" primary="true">ISO/TC 1/SC 2/C 3 N1000</docidentifier>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input1, *OPTIONS))
    xml = xml.xpath("//xmlns:bibdata/xmlns:docidentifier")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input2 = input.gsub(/:workgroup.+?[\r\n]+/m, "")
    output = <<~OUTPUT
      <docidentifier type="ISO" primary="true">ISO/A 1/B 2 N1000</docidentifier>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input2, *OPTIONS))
    xml = xml.xpath("//xmlns:bibdata/xmlns:docidentifier")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input2 = input.gsub(/:subcommittee.+?[\r\n]+/m, "")
      .gsub(/:workgroup.+?[\r\n]+/m, "")
    output = <<~OUTPUT
      <docidentifier type="ISO" primary="true">ISO/A 1 N1000</docidentifier>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input2, *OPTIONS))
    xml = xml.xpath("//xmlns:bibdata/xmlns:docidentifier")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
    output = <<~OUTPUT
      <docidentifier type="ISO" primary="true">ISO/A 1 N1000</docidentifier>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input2, *OPTIONS))
    xml = xml.xpath("//xmlns:bibdata/xmlns:docidentifier")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes Russian titles" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :partnumber: 1
      :edition: 2
      :revdate: 2000-01-01
      :draft: 0.3.4
      :language: ru
      :title-intro-en: Introduction
      :title-main-en: Main Title -- Title
      :title-part-en: Title Part
      :title-intro-fr: Introduction Française
      :title-main-fr: Titre Principal
      :title-part-fr: Part du Titre
      :title-intro-ru: Introdukcija Russkaja
      :title-main-ru: Titel Principalnyj
      :title-part-ru: Partija Titel
      :copyright-year: 2000
      :horizontal: true
    INPUT
    output = <<~OUTPUT
      <bibdata type='standard'>
        <title language='en' format='text/plain' type='main'>
          Introduction&#8201;&#8212;&#8201;Main
          Title&#8201;&#8212;&#8201;Title&#8201;&#8212;&#8201;Title Part
        </title>
        <title language='en' format='text/plain' type='title-intro'>Introduction</title>
        <title language='en' format='text/plain' type='title-main'>Main Title&#8201;&#8212;&#8201;Title</title>
        <title language='en' format='text/plain' type='title-part'>Title Part</title>
        <title language='ru' format='text/plain' type='main'>
          Introdukcija Russkaja&#8201;&#8212;&#8201;Titel
          Principalnyj&#8201;&#8212;&#8201;Partija Titel
        </title>
        <title language='ru' format='text/plain' type='title-intro'>Introdukcija Russkaja</title>
        <title language='ru' format='text/plain' type='title-main'>Titel Principalnyj</title>
        <title language='ru' format='text/plain' type='title-part'>Partija Titel</title>
        <title language='fr' format='text/plain' type='main'>
          Introduction Fran&#231;aise&#8201;&#8212;&#8201;Titre
          Principal&#8201;&#8212;&#8201;Part du Titre
        </title>
        <title language='fr' format='text/plain' type='title-intro'>Introduction Fran&#231;aise</title>
        <title language='fr' format='text/plain' type='title-main'>Titre Principal</title>
        <title language='fr' format='text/plain' type='title-part'>Part du Titre</title>
        <docidentifier type='ISO' primary="true">ISO 1000-1:2000</docidentifier>
        <docidentifier type='iso-reference'>ISO 1000-1:2000(R)</docidentifier>
        <docidentifier type='URN'>urn:iso:std:iso:1000:-1:stage-60.60:ru</docidentifier>
        <docidentifier type='iso-undated'>ISO 1000-1</docidentifier>
        <docidentifier type='iso-with-lang'>ISO 1000-1:2000(ru)</docidentifier>
        <docnumber>1000</docnumber>
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
        <edition>2</edition>
        <version>
          <revision-date>2000-01-01</revision-date>
          <draft>0.3.4</draft>
        </version>
        <language>ru</language>
        <script>Cyrl</script>
        <status>
          <stage>60</stage>
          <substage>60</substage>
        </status>
        <copyright>
          <from>2000</from>
          <owner>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype>standard</doctype>
                <flavor>iso</flavor>
          <horizontal>true</horizontal>
                      <editorialgroup>
         <agency>ISO</agency>
        </editorialgroup>
        <approvalgroup>
         <agency>ISO</agency>
        </approvalgroup>
          <structuredidentifier>
            <project-number part='1'>ISO 1000</project-number>
          </structuredidentifier>
          <stagename>International Standard</stagename>
        </ext>
      </bibdata>
    OUTPUT
    xml = xml.at("//xmlns:bibdata")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes subdivisions; override docidentifier" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~"INPUT", *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :revdate: 2000-01
      :published-date: 1000-01
      :docidentifier: OVERRIDE
      :docnumber: 1000
      :partnumber: 1-1
      :tc-docnumber: 2000
      :language: el
      :script: Grek
      :subdivision: Subdivision
      :subdivision-abbr: SD
      :doctype: This is a DocType
      :pub-address: 1 Infinity Loop + \\
      California
      :pub-phone: 3333333
      :pub-fax: 4444444
      :pub-email: x@example.com
      :pub-uri: http://www.example.com
    INPUT
    output = <<~OUTPUT
      <bibdata type="standard">
         <docidentifier type="ISO" primary="true">OVERRIDE</docidentifier>
         <docidentifier type="iso-tc">2000</docidentifier>
         <docnumber>1000</docnumber>
         <date type="published">
           <on>1000-01</on>
         </date>
         <contributor>
           <role type="author"/>
           <organization>
             <name>International Organization for Standardization</name>
             <subdivision>
               <name>Subdivision</name>
               <abbreviation>SD</abbreviation>
             </subdivision>
             <abbreviation>ISO</abbreviation>
             <address>
               <formattedAddress>1 Infinity Loop<br/>California</formattedAddress>
             </address>
             <phone>3333333</phone>
             <phone type="fax">4444444</phone>
             <email>x@example.com</email>
             <uri>http://www.example.com</uri>
           </organization>
         </contributor>
         <contributor>
           <role type="authorizer">
             <description>Agency</description>
           </role>
           <organization>
             <name>International Organization for Standardization</name>
             <subdivision>
               <name>Subdivision</name>
               <abbreviation>SD</abbreviation>
             </subdivision>
             <abbreviation>ISO</abbreviation>
           </organization>
         </contributor>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>International Organization for Standardization</name>
             <subdivision>
               <name>Subdivision</name>
               <abbreviation>SD</abbreviation>
             </subdivision>
             <abbreviation>ISO</abbreviation>
             <address>
               <formattedAddress>1 Infinity Loop<br/>California</formattedAddress>
             </address>
             <phone>3333333</phone>
             <phone type="fax">4444444</phone>
             <email>x@example.com</email>
             <uri>http://www.example.com</uri>
           </organization>
         </contributor>
         <version>
           <revision-date>2000-01</revision-date>
         </version>
         <language>el</language>
         <script>Grek</script>
         <status>
           <stage>60</stage>
           <substage>60</substage>
         </status>
         <copyright>
           <from>#{Date.today.year}</from>
           <owner>
             <organization>
               <name>International Organization for Standardization</name>
               <subdivision>
                 <name>Subdivision</name>
                 <abbreviation>SD</abbreviation>
               </subdivision>
               <abbreviation>ISO</abbreviation>
               <address>
                 <formattedAddress>1 Infinity Loop<br/>California</formattedAddress>
               </address>
               <phone>3333333</phone>
               <phone type="fax">4444444</phone>
               <email>x@example.com</email>
               <uri>http://www.example.com</uri>
             </organization>
           </owner>
         </copyright>
         <ext>
           <doctype>this-is-a-doctype</doctype>
                <flavor>iso</flavor>
           <editorialgroup>
             <agency>ISO</agency>
           </editorialgroup>
           <approvalgroup>
             <agency>ISO</agency>
           </approvalgroup>
           <structuredidentifier>
             <project-number part="1" subpart="1">SD 1000</project-number>
           </structuredidentifier>
           <stagename>International Standard</stagename>
         </ext>
       </bibdata>
    OUTPUT
    xml = xml.at("//xmlns:bibdata")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "defaults substage, defines iteration on stage 50" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :docstage: 50
      :language: fr
      :doctype: international-standard
      :iteration: 2
    INPUT
    output = <<~OUTPUT
              <bibdata type="standard">
              <docidentifier type='ISO' primary="true">ISO/FDIS 1000.2:#{Date.today.year}</docidentifier>
      <docidentifier type='iso-reference'>ISO/FDIS 1000.2:#{Date.today.year}(F)</docidentifier>
             <docidentifier type='URN'>urn:iso:std:iso:1000:stage-50.00.v2:fr</docidentifier>
              <docidentifier type='iso-undated'>ISO/FDIS 1000.2</docidentifier>
      <docidentifier type='iso-with-lang'>ISO/FDIS 1000.2:#{Date.today.year}(fr)</docidentifier>
                <docnumber>1000</docnumber>
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
                <language>fr</language>
                <script>Latn</script>
                <status>
                  <stage abbreviation="FDIS">50</stage>
                  <substage>00</substage>
                  <iteration>2</iteration>
                </status>
                <copyright>
                  <from>#{Date.today.year}</from>
                  <owner>
                    <organization>
                      <name>International Organization for Standardization</name>
                      <abbreviation>ISO</abbreviation>
                    </organization>
                  </owner>
                </copyright>
                <ext>
                  <doctype>international-standard</doctype>
                <flavor>iso</flavor>
                              <editorialgroup>
           <agency>ISO</agency>
          </editorialgroup>
          <approvalgroup>
           <agency>ISO</agency>
          </approvalgroup>
                  <structuredidentifier>
                    <project-number>ISO 1000</project-number>
                  </structuredidentifier>
                  <stagename abbreviation="FDIS">Final Draft International Standard</stagename>
                </ext>
              </bibdata>
    OUTPUT
    xml = xml.at("//xmlns:bibdata")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "defaults substage for stage 60" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :docstage: 60
    INPUT

    output = <<~OUTPUT
      <bibdata type="standard">
        <docidentifier type="ISO" primary="true">ISO 1000:#{Date.today.year}</docidentifier>
        <docidentifier type='iso-reference'>ISO 1000:#{Date.today.year}(E)</docidentifier>
        <docidentifier type='URN'>urn:iso:std:iso:1000:stage-60.60:en</docidentifier>
        <docidentifier type='iso-undated'>ISO 1000</docidentifier>
        <docidentifier type='iso-with-lang'>ISO 1000:#{Date.today.year}(en)</docidentifier>
        <docnumber>1000</docnumber>
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
          <from>#{Date.today.year}</from>
          <owner>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype>standard</doctype>
                <flavor>iso</flavor>
                      <editorialgroup>
           <agency>ISO</agency>
          </editorialgroup>
          <approvalgroup>
           <agency>ISO</agency>
          </approvalgroup>
          <structuredidentifier>
            <project-number>ISO 1000</project-number>
          </structuredidentifier>
          <stagename>International Standard</stagename>
        </ext>
      </bibdata>
    OUTPUT
    xml = xml.at("//xmlns:bibdata")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "populates metadata for PRF" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :docstage: 60
      :docsubstage: 00
    INPUT
    output = <<~OUTPUT
      <bibdata type="standard">
        <docidentifier type="ISO" primary="true">ISO/PRF 1000:#{Date.today.year}</docidentifier>
        <docidentifier type='iso-reference'>ISO/PRF 1000:#{Date.today.year}(E)</docidentifier>
        <docidentifier type='URN'>urn:iso:std:iso:1000:stage-draft:en</docidentifier>
        <docidentifier type='iso-undated'>ISO/PRF 1000</docidentifier>
        <docidentifier type='iso-with-lang'>ISO/PRF 1000:#{Date.today.year}(en)</docidentifier>
        <docnumber>1000</docnumber>
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
          <stage abbreviation="PRF">60</stage>
          <substage>00</substage>
        </status>
        <copyright>
          <from>#{Date.today.year}</from>
          <owner>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype>standard</doctype>
                <flavor>iso</flavor>
                      <editorialgroup>
         <agency>ISO</agency>
        </editorialgroup>
        <approvalgroup>
         <agency>ISO</agency>
        </approvalgroup>
          <structuredidentifier>
            <project-number>ISO 1000</project-number>
          </structuredidentifier>
          <stagename abbreviation="PRF">Proof of a new International Standard</stagename>
        </ext>
      </bibdata>
    OUTPUT
    xml = xml.at("//xmlns:bibdata")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "defaults metadata for DIR" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :doctype: directive
    INPUT

    output = <<~OUTPUT
      <bibdata type='standard'>
        <docidentifier type='ISO' primary="true">ISO DIR 1000:#{Date.today.year}</docidentifier>
        <docidentifier type='iso-reference'>ISO DIR 1000:#{Date.today.year}(E)</docidentifier>
        <docidentifier type='URN'>urn:iso:doc:iso:dir:1000:#{Date.today.year}</docidentifier>
        <docidentifier type='iso-undated'>ISO DIR 1000</docidentifier>
        <docidentifier type='iso-with-lang'>ISO DIR 1000:#{Date.today.year}(en)</docidentifier>
        <docnumber>1000</docnumber>
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
          <stage>60</stage>
          <substage>60</substage>
        </status>
        <copyright>
          <from>#{Time.new.year}</from>
          <owner>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype>directive</doctype>
                <flavor>iso</flavor>
                      <editorialgroup>
         <agency>ISO</agency>
        </editorialgroup>
        <approvalgroup>
         <agency>ISO</agency>
        </approvalgroup>
          <structuredidentifier>
            <project-number>ISO 1000</project-number>
          </structuredidentifier>
          <stagename abbreviation="DIR">Directives</stagename>
        </ext>
      </bibdata>
    OUTPUT
    xml = xml.at("//xmlns:bibdata")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes document relations" do
      xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:
        :amends: ISO 123:2001;ISO 124
        :obsoletes: ABC 1
        :successor-of: ABC 2
        :manifestation-of: ABC 3
        :annotation-of: ABC 3a
        :related: ABC 4
        :replaces: ABC 5
        :supersedes: ABC 6
        :corrects: ABC 7
        :informatively-cited-in: ABC 8
        :informatively-cites: ABC 9
        :normatively-cited-in: ABC 10
        :normatively-cites: ABC 11
        :identical-adopted-from: ABC 12
        :modified-adopted-from: ABC 13
        :related-directive: ABC 14
        :related-mandate: ABC 15
        :has-draft: ABC 16
        :local-cache: spec/relatondb
      INPUT
      output = <<~OUTPUT
        <bibdata type="standard">
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
            <from>#{Date.today.year}</from>
            <owner>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </owner>
          </copyright>
          <relation type="obsoletes">
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 1</docidentifier>
            </bibitem>
          </relation>
          <relation type="successorOf">
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 2</docidentifier>
            </bibitem>
          </relation>
          <relation type="manifestationOf">
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 3</docidentifier>
            </bibitem>
          </relation>
          <relation type="related">
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 4</docidentifier>
            </bibitem>
          </relation>
          <relation type="annotationOf">
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 3a</docidentifier>
            </bibitem>
          </relation>
          <relation type="updates">
            <description>amends</description>
            <bibitem type="standard">
              <docidentifier type="iso-reference">ISO 123:2001(E)</docidentifier>
            </bibitem>
          </relation>
          <relation type="updates">
            <description>amends</description>
            <bibitem type="standard">
              <docidentifier type="iso-reference">ISO 124(E)</docidentifier>
            </bibitem>
          </relation>
          <relation type="obsoletes">
            <description>replaces</description>
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 5</docidentifier>
            </bibitem>
          </relation>
          <relation type="obsoletes">
            <description>supersedes</description>
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 6</docidentifier>
            </bibitem>
          </relation>
          <relation type="updates">
            <description>corrects</description>
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 7</docidentifier>
            </bibitem>
          </relation>
          <relation type="isCitedIn">
            <description>informatively cited in</description>
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 8</docidentifier>
            </bibitem>
          </relation>
          <relation type="cites">
            <description>informatively cites</description>
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 9</docidentifier>
            </bibitem>
          </relation>
          <relation type="cites">
            <description>normatively cites</description>
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 11</docidentifier>
            </bibitem>
          </relation>
          <relation type="adoptedFrom">
            <description>identical adopted from</description>
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 12</docidentifier>
            </bibitem>
          </relation>
          <relation type="adoptedFrom">
            <description>modified adopted from</description>
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 13</docidentifier>
            </bibitem>
          </relation>
          <relation type="related">
            <description>related directive</description>
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 14</docidentifier>
            </bibitem>
          </relation>
          <relation type="related">
            <description>related mandate</description>
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 15</docidentifier>
            </bibitem>
          </relation>
          <relation type="hasDraft">
            <bibitem>
              <title>--</title>
              <docidentifier>ABC 16</docidentifier>
            </bibitem>
           </relation>
          <ext>
            <doctype>standard</doctype>
                <flavor>iso</flavor>
            <editorialgroup>
              <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
              <agency>ISO</agency>
            </approvalgroup>
            <stagename>International Standard</stagename>
          </ext>
        </bibdata>
      OUTPUT
      xml = xml.at("//xmlns:bibdata")
      xml.xpath("//xmlns:docidentifier[@type='iso-reference']").each do |x|
        x.xpath(".//following-sibling::*").each(&:remove)
        x.xpath(".//preceding-sibling::*").each(&:remove)
      end
      expect(Xml::C14n.format(strip_guid(xml.to_xml)))
        .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes adopted-from identifiers, CEN identifiers" do
      xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:
        :no-isobib:
        :docnumber: 31
        :language: fr
        :doctype: international-standard
        :adopted-from: ISO 31-0
        :publisher: CEN
        :local-cache: spec/relatondb
      INPUT
      output = <<~OUTPUT
        <bibdata type="standard">
          <docidentifier type="CEN" primary="true">CEN ISO 31-0</docidentifier>
          <docnumber>31</docnumber>
          <contributor>
            <role type="author"/>
            <organization>
              <name>CEN</name>
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
              <name>CEN</name>
            </organization>
          </contributor>
          <language>fr</language>
          <script>Latn</script>
          <status>
            <stage>60</stage>
            <substage>60</substage>
          </status>
          <copyright>
            <from>#{Date.today.year}</from>
            <owner>
              <organization>
                <name>CEN</name>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype>international-standard</doctype>
                <flavor>iso</flavor>
            <editorialgroup>
              <agency>CEN</agency>
            </editorialgroup>
            <approvalgroup>
              <agency>ISO</agency>
            </approvalgroup>
            <structuredidentifier>
              <project-number>CEN 31</project-number>
            </structuredidentifier>
          </ext>
        </bibdata>
      OUTPUT
      xml = xml.at("//xmlns:bibdata")
      xml.xpath("//xmlns:docidentifier[@type='iso-reference']").each do |x|
        x.xpath(".//following-sibling::*").each(&:remove)
        x.xpath(".//preceding-sibling::*").each(&:remove)
      end
      expect(Xml::C14n.format(strip_guid(xml.to_xml)))
        .to be_equivalent_to Xml::C14n.format(output)
  end

  it "reads scripts into blank HTML document" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{<script>}i)
  end

  it "uses default fonts" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html)
      .to match(%r[blockquote[^{]+\{[^{]+font-family: "Cambria", serif;]m)
    expect(html)
      .to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Cambria", serif;]m)
  end

  it "uses default fonts for alt doc" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :no-pdf:
    INPUT
    html = File.read("test_alt.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^{]+font-family: "Space Mono", monospace;]m)
    expect(html)
      .to match(%r[blockquote[^{]+\{[^{]+font-family: "Lato", sans-serif;]m)
    expect(html)
      .to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Lato", sans-serif;]m)
  end

  it "uses Chinese fonts" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :script: Hans
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html)
      .to match(%r[blockquote[^{]+\{[^{]+font-family: "Source Han Sans", serif;]m)
    expect(html)
      .to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Source Han Sans", sans-serif;]m)
  end

  it "uses specified fonts" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Andale Mono
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html)
      .to match(%r[blockquote[^{]+\{[^{]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: Comic Sans;]m)
  end

  it "strips MS-specific CSS" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :no-pdf:
    INPUT
    word = File.read("test.doc", encoding: "utf-8")
    html = File.read("test.html", encoding: "utf-8")
    expect(word).to match(%r[mso-style-name: "Intro Title";]m)
    expect(html).not_to match(%r[mso-style-name: "Intro Title";]m)
  end

  it "populates document-scheme metadata" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :document-scheme: DOCUMENT-SCHEME
    INPUT
    output = <<~OUTPUT
      <metanorma-extension>
         <presentation-metadata>
           <name>document-scheme</name>
           <value>DOCUMENT-SCHEME</value>
         </presentation-metadata>
         <presentation-metadata>
           <name>TOC Heading Levels</name>
           <value>2</value>
         </presentation-metadata>
         <presentation-metadata>
           <name>HTML TOC Heading Levels</name>
           <value>2</value>
         </presentation-metadata>
         <presentation-metadata>
           <name>DOC TOC Heading Levels</name>
           <value>3</value>
         </presentation-metadata>
         <presentation-metadata>
           <name>PDF TOC Heading Levels</name>
           <value>3</value>
         </presentation-metadata>
       </metanorma-extension>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(Asciidoctor
      .convert(input, *OPTIONS))
      .at("//xmlns:metanorma-extension").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input.sub!(":document-scheme: DOCUMENT-SCHEME",
               ":copyright-year: 1960")
    output.sub!("DOCUMENT-SCHEME", "1951")
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(Asciidoctor
      .convert(input, *OPTIONS))
      .at("//xmlns:metanorma-extension").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input.sub!(":copyright-year: 1960", ":copyright-year: 1973")
    output.sub!("<value>1951</value>", "<value>1972</value>")
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(Asciidoctor
      .convert(input, *OPTIONS))
      .at("//xmlns:metanorma-extension").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input.sub!(":copyright-year: 1973", ":copyright-year: 1980")
    output.sub!("<value>1972</value>", "<value>1979</value>")
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(Asciidoctor
      .convert(input, *OPTIONS))
      .at("//xmlns:metanorma-extension").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input.sub!(":copyright-year: 1980", ":copyright-year: 1988")
    output.sub!("<value>1979</value>", "<value>1987</value>")
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(Asciidoctor
      .convert(input, *OPTIONS))
      .at("//xmlns:metanorma-extension").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input.sub!(":copyright-year: 1988", ":copyright-year: 1990")
    output.sub!("<value>1987</value>", "<value>1989</value>")
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(Asciidoctor
      .convert(input, *OPTIONS))
      .at("//xmlns:metanorma-extension").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input.sub!(":copyright-year: 1990", ":copyright-year: 2012")
    output.sub!("<value>1989</value>", "<value>2012</value>")
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(Asciidoctor
      .convert(input, *OPTIONS))
      .at("//xmlns:metanorma-extension").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input.sub!(":copyright-year: 2012", ":copyright-year: 2014")
    output.sub!("<value>2012</value>", "<value>2013</value>")
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(Asciidoctor
      .convert(input, *OPTIONS))
      .at("//xmlns:metanorma-extension").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input.sub!(":copyright-year: 2014", ":copyright-year: 2025")
    output.sub!("<value>2013</value>", "<value>2024</value>")
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(Asciidoctor
      .convert(input, *OPTIONS))
      .at("//xmlns:metanorma-extension").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input.sub!(":copyright-year: 2014", "")
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(Asciidoctor
      .convert(input, *OPTIONS))
      .at("//xmlns:metanorma-extension").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

  end
end
