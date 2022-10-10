require "spec_helper"

RSpec.describe Metanorma::ISO do
  it "has a version number" do
    expect(Metanorma::ISO::VERSION).not_to be nil
  end

  it "processes default metadata" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    INPUT
    expect(xmlpp(output.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <?xml version="1.0" encoding="UTF-8"?>
        <iso-standard type="semantic" version="#{Metanorma::ISO::VERSION}" xmlns="https://www.metanorma.org/ns/iso">
          <bibdata type="standard">
            <title format="text/plain" language="en" type="main">Introduction — Main Title — Title — Title Part</title>
            <title format="text/plain" language="en" type="title-intro">Introduction</title>
            <title format="text/plain" language="en" type="title-main">Main Title — Title</title>
            <title format="text/plain" language="en" type="title-part">Title Part</title>
            <title format="text/plain" language="fr" type="main">Introduction Française — Titre Principal — Part du Titre</title>
            <title format="text/plain" language="fr" type="title-intro">Introduction Française</title>
            <title format="text/plain" language="fr" type="title-main">Titre Principal</title>
            <title format="text/plain" language="fr" type="title-part">Part du Titre</title>
            <docidentifier type="ISO">ISO/PreWD3 1000-1</docidentifier>
            <docidentifier type='iso-undated'>ISO/PreWD3 1000-1</docidentifier>
            <docidentifier type="iso-with-lang">ISO/PreWD3 1000-1(E)</docidentifier>
            <docidentifier type="iso-reference">ISO/PreWD3 1000-1:2000(E)</docidentifier>
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
              <stagename>Third working draft</stagename>
            </ext>
          </bibdata>
          <sections/>
        </iso-standard>
      OUTPUT
  end

  it "processes complex metadata" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
      :technical-committee: TC
      :technical-committee-number: 1
      :subcommittee: SC
      :subcommittee-number: 2
      :workgroup: WG
      :workgroup-number: 3
      :approval-technical-committee: TC
      :approval-technical-committee-number: 1
      :approval-subcommittee: SC
      :approval-subcommittee-number: 2
      :approval-workgroup: WG
      :approval-workgroup-number: 3
    INPUT
    expect(xmlpp(output.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
              <?xml version="1.0" encoding="UTF-8"?>
              <iso-standard type="semantic" version="#{Metanorma::ISO::VERSION}" xmlns="https://www.metanorma.org/ns/iso">
                <bibdata type="standard">
                  <docidentifier type='ISO'>IEC/IETF/ISO/TR 1000-1-1:2001</docidentifier>
                  <docidentifier type='iso-undated'>IEC/IETF/ISO/TR 1000-1-1</docidentifier>
                  <docidentifier type='iso-with-lang'>IEC/IETF/ISO/TR 1000-1-1:2001(X)</docidentifier>
                  <docidentifier type='iso-reference'>IEC/IETF/ISO/TR 1000-1-1:2001(X)</docidentifier>
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
                    <role type="publisher"/>
                    <organization>
                      <name>International Electrotechnical Commission</name>
                      <abbreviation>IEC</abbreviation>
                      <address>
          <formattedAddress>1 Infinity Loop + California</formattedAddress>
        </address>
        <phone>3333333</phone>
        <phone type='fax'>4444444</phone>
        <email>x@example.com</email>
        <uri>http://www.example.com</uri>
                    </organization>
                  </contributor>
                  <contributor>
                    <role type="publisher"/>
                    <organization>
                      <name>IETF</name>
                      <address>
          <formattedAddress>1 Infinity Loop + California</formattedAddress>
        </address>
        <phone>3333333</phone>
        <phone type='fax'>4444444</phone>
        <email>x@example.com</email>
        <uri>http://www.example.com</uri>
                    </organization>
                  </contributor>
                  <contributor>
                    <role type="publisher"/>
                    <organization>
                      <name>International Organization for Standardization</name>
                      <abbreviation>ISO</abbreviation>
                      <address>
          <formattedAddress>1 Infinity Loop + California</formattedAddress>
        </address>
        <phone>3333333</phone>
        <phone type='fax'>4444444</phone>
        <email>x@example.com</email>
        <uri>http://www.example.com</uri>
                    </organization>
                  </contributor>
                  <language>el</language>
                  <script>Grek</script>
                  <status>
                    <stage abbreviation="IS">60</stage>
                    <substage>60</substage>
                  </status>
                  <copyright>
                    <from>2001</from>
                    <owner>
                      <organization>
                        <name>IETF</name>
                        <address>
          <formattedAddress>1 Infinity Loop + California</formattedAddress>
        </address>
        <phone>3333333</phone>
        <phone type='fax'>4444444</phone>
        <email>x@example.com</email>
        <uri>http://www.example.com</uri>
                      </organization>
                    </owner>
                  </copyright>
                                    <copyright>
                    <from>2001</from>
                    <owner>
                      <organization>
                        <name>International Organization for Standardization</name>
                        <abbreviation>ISO</abbreviation>
                        <address>
          <formattedAddress>1 Infinity Loop + California</formattedAddress>
        </address>
        <phone>3333333</phone>
        <phone type='fax'>4444444</phone>
        <email>x@example.com</email>
        <uri>http://www.example.com</uri>
                      </organization>
                    </owner>
                  </copyright>
                  <ext>
                    <doctype>technical-report</doctype>
             <editorialgroup>
              <agency>IEC</agency>
              <agency>IETF</agency>
              <agency>ISO</agency>
               <technical-committee number='1' type='TC'>TC</technical-committee>
               <subcommittee number='2' type='SC'>SC</subcommittee>
               <workgroup number='3' type='WG'>WG</workgroup>
             </editorialgroup>
             <approvalgroup>
              <agency>ISO</agency>
               <technical-committee number='1' type='TC'>TC</technical-committee>
               <subcommittee number='2' type='SC'>SC</subcommittee>
               <workgroup number='3' type='WG'>WG</workgroup>
             </approvalgroup>
                    <structuredidentifier>
                      <project-number part="1" subpart="1">IEC/IETF/ISO 1000</project-number>
                    </structuredidentifier>
                    <stagename>International standard</stagename>
                  </ext>
                </bibdata>
                <sections/>
              </iso-standard>
      OUTPUT
  end

  it "processes tech specification identifier" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    expect(xmlpp(output.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
           <iso-standard xmlns='https://www.metanorma.org/ns/iso' type='semantic' version="#{Metanorma::ISO::VERSION}">
         <bibdata type='standard'>
           <docidentifier type='ISO'>ISO/FDTS 1000-1-1</docidentifier>
           <docidentifier type='iso-undated'>ISO/FDTS 1000-1-1</docidentifier>
           <docidentifier type='iso-with-lang'>ISO/FDTS 1000-1-1(E)</docidentifier>
           <docidentifier type='iso-reference'>ISO/FDTS 1000-1-1:2001(E)</docidentifier>
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
           <language>en</language>
           <script>Latn</script>
           <status>
             <stage abbreviation='FDTS TS'>50</stage>
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
                         <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
             <structuredidentifier>
               <project-number part='1' subpart='1'>ISO 1000</project-number>
             </structuredidentifier>
             <stagename>Final draft</stagename>
           </ext>
         </bibdata>
         <sections> </sections>
       </iso-standard>
    OUTPUT
  end

  it "processes Russian titles" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    expect(xmlpp(output.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <iso-standard xmlns='https://www.metanorma.org/ns/iso' type='semantic' version='#{Metanorma::ISO::VERSION}'>
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
            <docidentifier type='ISO'>ISO 1000-1:2000</docidentifier>
            <docidentifier type='iso-undated'>ISO 1000-1</docidentifier>
            <docidentifier type='iso-with-lang'>ISO 1000-1:2000(R)</docidentifier>
            <docidentifier type='iso-reference'>ISO 1000-1:2000(R)</docidentifier>
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
            <edition>2</edition>
            <version>
              <revision-date>2000-01-01</revision-date>
              <draft>0.3.4</draft>
            </version>
            <language>ru</language>
            <script>Cyrl</script>
            <status>
              <stage abbreviation='IS'>60</stage>
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
              <stagename>International standard</stagename>
            </ext>
          </bibdata>
          <sections> </sections>
        </iso-standard>
      OUTPUT
  end

  it "processes subdivisions" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :revdate: 2000-01
      :published-date: 1000-01
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
    expect(xmlpp(strip_guid(output
      .sub(%r{<boilerplate>.*</boilerplate>}m, ""))))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <iso-standard xmlns="https://www.metanorma.org/ns/iso"  type="semantic" version="#{Metanorma::ISO::VERSION}">
          <bibdata type='standard'>
            <docidentifier type='ISO'>SD 1000-1-1</docidentifier>
            <docidentifier type='iso-undated'>SD 1000-1-1</docidentifier>
            <docidentifier type='iso-with-lang'>SD 1000-1-1(X)</docidentifier>
            <docidentifier type='iso-reference'>SD 1000-1-1(X)</docidentifier>
            <docidentifier type='iso-tc'>2000</docidentifier>
            <docnumber>1000</docnumber>
            <date type='published'>
              <on>1000-01</on>
            </date>
            <contributor>
              <role type='author'/>
              <organization>
                <name>International Organization for Standardization</name>
                <subdivision>Subdivision</subdivision>
                <abbreviation>SD</abbreviation>
              </organization>
            </contributor>
            <contributor>
              <role type='publisher'/>
              <organization>
                <name>International Organization for Standardization</name>
                <subdivision>Subdivision</subdivision>
                <abbreviation>SD</abbreviation>
                <address>
                  <formattedAddress>1 Infinity Loop <br/>California</formattedAddress>
                </address>
                <phone>3333333</phone>
                <phone type='fax'>4444444</phone>
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
              <stage abbreviation='IS'>60</stage>
              <substage>60</substage>
            </status>
            <copyright>
              <from>#{Time.now.year}</from>
              <owner>
                <organization>
                  <name>International Organization for Standardization</name>
                  <subdivision>Subdivision</subdivision>
                  <abbreviation>SD</abbreviation>
                  <address>
                    <formattedAddress>1 Infinity Loop
                      <br/>
                      California</formattedAddress>
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
                          <editorialgroup>
             <agency>SD</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
              <structuredidentifier>
                <project-number part="1" subpart="1">SD 1000</project-number>
              </structuredidentifier>
              <stagename>International standard</stagename>
            </ext>
          </bibdata>
          <sections> </sections>
        </iso-standard>
      OUTPUT
  end

  it "defaults substage, defines iteration on stage 50" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    expect(xmlpp(output.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
              <iso-standard type="semantic" version="#{Metanorma::ISO::VERSION}" xmlns="https://www.metanorma.org/ns/iso">
                <bibdata type="standard">
                <docidentifier type='ISO'>ISO/FDIS 1000.2</docidentifier>
                <docidentifier type='iso-undated'>ISO/FDIS 1000.2</docidentifier>
        <docidentifier type='iso-with-lang'>ISO/FDIS 1000.2(F)</docidentifier>
        <docidentifier type='iso-reference'>ISO/FDIS 1000.2(F)</docidentifier>
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
                                <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
                    <structuredidentifier>
                      <project-number>ISO 1000</project-number>
                    </structuredidentifier>
                    <stagename>Final draft</stagename>
                  </ext>
                </bibdata>
                <sections/>
              </iso-standard>
      OUTPUT
  end

  it "defaults substage for stage 60" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :docstage: 60
    INPUT

    expect(xmlpp(output.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <iso-standard xmlns="https://www.metanorma.org/ns/iso"  type="semantic" version="#{Metanorma::ISO::VERSION}">
        <bibdata type="standard">
          <docidentifier type="ISO">ISO 1000</docidentifier>
          <docidentifier type='iso-undated'>ISO 1000</docidentifier>
          <docidentifier type='iso-with-lang'>ISO 1000(E)</docidentifier>
          <docidentifier type='iso-reference'>ISO 1000(E)</docidentifier>
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

          <language>en</language>
          <script>Latn</script>
          <status>
            <stage abbreviation="IS">60</stage>
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
                        <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
            <structuredidentifier>
              <project-number>ISO 1000</project-number>
            </structuredidentifier>
            <stagename>International standard</stagename>
          </ext>
        </bibdata>
        <sections/>
        </iso-standard>
      OUTPUT
  end

  it "populates metadata for PRF" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    expect(xmlpp(output.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <iso-standard xmlns="https://www.metanorma.org/ns/iso"  type="semantic" version="#{Metanorma::ISO::VERSION}">
          <bibdata type="standard">
            <docidentifier type="ISO">ISO 1000</docidentifier>
            <docidentifier type='iso-undated'>ISO 1000</docidentifier>
            <docidentifier type='iso-with-lang'>ISO 1000(E)</docidentifier>
            <docidentifier type='iso-reference'>ISO 1000(E)</docidentifier>
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
                          <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
              <structuredidentifier>
                <project-number>ISO 1000</project-number>
              </structuredidentifier>
              <stagename>Proof</stagename>
            </ext>
          </bibdata>
          <sections/>
        </iso-standard>
      OUTPUT
  end

  it "defaults metadata for DIR" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :doctype: directive
    INPUT

    expect(xmlpp(output.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <iso-standard xmlns="https://www.metanorma.org/ns/iso"  type="semantic" version="#{Metanorma::ISO::VERSION}">
          <bibdata type='standard'>
            <docidentifier type='ISO'>ISO DIR 1000</docidentifier>
            <docidentifier type='iso-undated'>ISO DIR 1000</docidentifier>
            <docidentifier type='iso-with-lang'>ISO DIR 1000(E)</docidentifier>
            <docidentifier type='iso-reference'>ISO DIR 1000(E)</docidentifier>
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
            <language>en</language>
            <script>Latn</script>
            <status>
              <stage abbreviation='IS'>60</stage>
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
                          <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
              <structuredidentifier>
                <project-number>ISO 1000</project-number>
              </structuredidentifier>
              <stagename>International standard</stagename>
            </ext>
          </bibdata>
          <sections> </sections>
        </iso-standard>
      OUTPUT
  end

  it "processes document relations" do
    VCR.use_cassette "docrels" do
      output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:
        :amends: ISO 123:2001;ISO 125
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
      INPUT
      expect(xmlpp(output.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
        .to be_equivalent_to xmlpp(<<~"OUTPUT")
          <iso-standard xmlns="https://www.metanorma.org/ns/iso"  type="semantic" version="#{Metanorma::ISO::VERSION}">
              <bibdata type='standard'>
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
              <language>en</language>
              <script>Latn</script>
              <status>
                <stage abbreviation='IS'>60</stage>
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
              <relation type='obsoletes'>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 1</docidentifier>
                </bibitem>
              </relation>
              <relation type='successorOf'>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 2</docidentifier>
                </bibitem>
              </relation>
              <relation type='manifestationOf'>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 3</docidentifier>
                </bibitem>
              </relation>
              <relation type='related'>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 4</docidentifier>
                </bibitem>
              </relation>
              <relation type='annotationOf'>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 3a</docidentifier>
                </bibitem>
              </relation>
              <relation type='updates'>
                <description>amends</description>
                <bibitem type='standard'>
                  <fetched/>
                  <title type='title-intro' format='text/plain' language='en' script='Latn'>Rubber latex</title>
                  <title type='title-main' format='text/plain' language='en' script='Latn'>Sampling</title>
                  <title type='main' format='text/plain' language='en' script='Latn'>Rubber latex&#8201;&#8212;&#8201;Sampling</title>
                  <title type='title-intro' format='text/plain' language='fr' script='Latn'>Latex de caoutchouc</title>
                  <title type='title-main' format='text/plain' language='fr' script='Latn'>Échantillonnage</title>
                  <title type='main' format='text/plain' language='fr' script='Latn'>Latex de caoutchouc — Échantillonnage</title>
                  <uri type='src'>https://www.iso.org/standard/23281.html</uri>
                  <uri type='obp'>https://www.iso.org/obp/ui/#!iso:std:23281:en</uri>
                  <uri type='rss'>https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</uri>
                  <docidentifier type='ISO' primary="true">ISO 123:2001</docidentifier>
                  <docidentifier type='URN'>urn:iso:std:iso:123:ed-3</docidentifier>
                  <docnumber>123</docnumber>
                  <date type='published'><on>2001-05</on></date>
                  <contributor>
                    <role type='publisher'/>
                    <organization>
                      <name>International Organization for Standardization</name>
                      <abbreviation>ISO</abbreviation>
                      <uri>www.iso.org</uri>
                    </organization>
                  </contributor>
                  <edition>3</edition>
                  <language>en</language>
                  <language>fr</language>
                  <script>Latn</script>
          <abstract format='text/plain' language='en' script='Latn'>
            This International Standard specifies procedures for sampling natural
            rubber latex concentrate and for sampling synthetic rubber latices and
            artificial latices. It is also suitable for sampling rubber latex
            contained in drums, tank cars or tanks. The procedures may also be
            used for sampling plastics dispersions.
          </abstract>
                  <abstract format='text/plain' language='fr' script='Latn'>
          La présente Norme internationale spécifie des méthodes
          d’échantillonnage pour des concentrés de latex de caoutchouc naturel
          et pour échantillonner des latex de caoutchouc synthétique et des
          latex artificiels. Elle s’applique également à l’échantillonnage de
          latex de caoutchouc contenus dans des fûts, citernes routières ou de
          stockage. Le mode opératoire peut aussi être utilisé pour
          l’échantillonnage de dispersions de plastiques.
        </abstract>
                  <status>
                    <stage>90</stage>
                    <substage>93</substage>
                  </status>
                  <copyright>
                    <from>2001</from>
                    <owner>
                      <organization>
                        <name>ISO</name>
                      </organization>
                    </owner>
                  </copyright>
                  <relation type='obsoletes'>
                    <bibitem type='standard'>
                      <formattedref format='text/plain'>ISO 123:1985</formattedref>
                      <docidentifier type='ISO' primary='true'>ISO 123:1985</docidentifier>
                    </bibitem>
                  </relation>
                  <place>Geneva</place>
                </bibitem>
              </relation>
                         <relation type='updates'>
               <description>amends</description>
               <bibitem type='standard'>
                 <fetched/>
                 <title type='title-intro' format='text/plain' language='en' script='Latn'>Natural rubber latex concentrate</title>
                 <title type='title-main' format='text/plain' language='en' script='Latn'>Determination of alkalinity</title>
                 <title type='main' format='text/plain' language='en' script='Latn'>
                   Natural rubber latex concentrate&#8201;&#8212;&#8201;Determination of
                   alkalinity
                 </title>
                 <title type='title-intro' format='text/plain' language='fr' script='Latn'>Latex concentr&#233; de caoutchouc naturel</title>
                 <title type='title-main' format='text/plain' language='fr' script='Latn'>D&#233;termination de l&#8217;alcalinit&#233;</title>
                 <title type='main' format='text/plain' language='fr' script='Latn'>
                   Latex concentr&#233; de caoutchouc
                   naturel&#8201;&#8212;&#8201;D&#233;termination de
                   l&#8217;alcalinit&#233;
                 </title>
                 <uri type='src'>https://www.iso.org/standard/72849.html</uri>
                 <uri type='obp'>https://www.iso.org/obp/ui/#!iso:std:72849:en</uri>
                 <uri type='rss'>https://www.iso.org/contents/data/standard/07/28/72849.detail.rss</uri>
                 <docidentifier type='ISO' primary="true">ISO 125</docidentifier>
                 <docidentifier type='URN'>urn:iso:std:iso:125:ed-7</docidentifier>
                 <docnumber>125</docnumber>
                 <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>International Organization for Standardization</name>
                     <abbreviation>ISO</abbreviation>
                     <uri>www.iso.org</uri>
                   </organization>
                 </contributor>
                 <edition>7</edition>
                 <language>en</language>
                 <language>fr</language>
                 <script>Latn</script>
                 <status>
                   <stage>60</stage>
                   <substage>60</substage>
                 </status>
                 <copyright>
                   <from>2020</from>
                   <owner>
                     <organization>
                       <name>ISO</name>
                     </organization>
                   </owner>
                 </copyright>
                 <relation type='obsoletes'>
                   <bibitem type='standard'>
                     <formattedref format='text/plain'>ISO 125:2011</formattedref>
                     <docidentifier type='ISO' primary='true'>ISO 125:2011</docidentifier>
                   </bibitem>
                 </relation>
                 <relation type='instance'>
                   <bibitem type='standard'>
                     <fetched/>
                     <title type='title-intro' format='text/plain' language='en' script='Latn'>Natural rubber latex concentrate</title>
                     <title type='title-main' format='text/plain' language='en' script='Latn'>Determination of alkalinity</title>
                     <title type='main' format='text/plain' language='en' script='Latn'>
                       Natural rubber latex concentrate&#8201;&#8212;&#8201;Determination
                       of alkalinity
                     </title>
                     <title type='title-intro' format='text/plain' language='fr' script='Latn'>Latex concentr&#233; de caoutchouc naturel</title>
                     <title type='title-main' format='text/plain' language='fr' script='Latn'>D&#233;termination de l&#8217;alcalinit&#233;</title>
                     <title type='main' format='text/plain' language='fr' script='Latn'>
                       Latex concentr&#233; de caoutchouc
                       naturel&#8201;&#8212;&#8201;D&#233;termination de
                       l&#8217;alcalinit&#233;
                     </title>
                     <uri type='src'>https://www.iso.org/standard/72849.html</uri>
                     <uri type='obp'>https://www.iso.org/obp/ui/#!iso:std:72849:en</uri>
                     <uri type='rss'>https://www.iso.org/contents/data/standard/07/28/72849.detail.rss</uri>
                     <docidentifier type='ISO' primary="true">ISO 125:2020</docidentifier>
                     <docidentifier type='URN'>urn:iso:std:iso:125:ed-7</docidentifier>
                     <docnumber>125</docnumber>
                     <date type='published'>
                       <on>2020-02</on>
                     </date>
                     <contributor>
                       <role type='publisher'/>
                       <organization>
                         <name>International Organization for Standardization</name>
                         <abbreviation>ISO</abbreviation>
                         <uri>www.iso.org</uri>
                       </organization>
                     </contributor>
                     <edition>7</edition>
                     <language>en</language>
                     <language>fr</language>
                     <script>Latn</script>
                     <abstract format='text/plain' language='en' script='Latn'>
                       This document specifies a method for the determination of the
                       alkalinity of natural rubber latex concentrate. The method is not
                       necessarily suitable for latices from natural sources other than
                       Hevea brasiliensis or for synthetic rubber latices, compounded
                       latex, vulcanized latex or artificial dispersions of rubber. NOTE
                       A method for the determination of the alkalinity of
                       polychloroprene latex is specified in ISO 13773.
                     </abstract>
                     <abstract format='text/plain' language='fr' script='Latn'>
                       Le pr&#233;sent document sp&#233;cifie une m&#233;thode de
                       d&#233;termination de l&#8217;alcalinit&#233; du latex
                       concentr&#233; de caoutchouc naturel. La m&#233;thode ne convient
                       pas n&#233;cessairement aux latex d&#8217;origine naturelle autres
                       que l&#8217;Hevea brasiliensis ou aux latex de caoutchouc de
                       synth&#232;se, aux latex formul&#233;s, aux latex vulcanis&#233;s
                       ou aux dispersions artificielles de caoutchouc. NOTE Une
                       m&#233;thode de d&#233;termination de l&#8217;alcalinit&#233; du
                       latex de polychloropr&#232;ne est sp&#233;cifi&#233;e dans
                       l&#8217;ISO 13773.
                     </abstract>
                     <status>
                       <stage>60</stage>
                       <substage>60</substage>
                     </status>
                     <copyright>
                       <from>2020</from>
                       <owner>
                         <organization>
                           <name>ISO</name>
                         </organization>
                       </owner>
                     </copyright>
                     <relation type='obsoletes'>
                       <bibitem type='standard'>
                         <formattedref format='text/plain'>ISO 125:2011</formattedref>
                         <docidentifier type='ISO' primary='true'>ISO 125:2011</docidentifier>
                       </bibitem>
                     </relation>
                     <place>Geneva</place>
                   </bibitem>
                 </relation>
                 <place>Geneva</place>
               </bibitem>
             </relation>
              <relation type='obsoletes'>
                <description>replaces</description>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 5</docidentifier>
                </bibitem>
              </relation>
              <relation type='obsoletes'>
                <description>supersedes</description>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 6</docidentifier>
                </bibitem>
              </relation>
              <relation type='updates'>
                <description>corrects</description>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 7</docidentifier>
                </bibitem>
              </relation>
              <relation type='isCitedIn'>
                <description>informatively cited in</description>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 8</docidentifier>
                </bibitem>
              </relation>
              <relation type='cites'>
                <description>informatively cites</description>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 9</docidentifier>
                </bibitem>
              </relation>
              <relation type='cites'>
                <description>normatively cites</description>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 11</docidentifier>
                </bibitem>
              </relation>
              <relation type='adoptedFrom'>
                <description>identical adopted from</description>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 12</docidentifier>
                </bibitem>
              </relation>
              <relation type='adoptedFrom'>
                <description>modified adopted from</description>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 13</docidentifier>
                </bibitem>
              </relation>
              <relation type='related'>
                <description>related directive</description>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 14</docidentifier>
                </bibitem>
              </relation>
              <relation type='related'>
                <description>related mandate</description>
                <bibitem>
                  <title>--</title>
                  <docidentifier>ABC 15</docidentifier>
                </bibitem>
              </relation>
              <ext>
                <doctype>standard</doctype>
                            <editorialgroup>
             <agency>ISO</agency>
            </editorialgroup>
            <approvalgroup>
             <agency>ISO</agency>
            </approvalgroup>
                <stagename>International standard</stagename>
              </ext>
            </bibdata>
            <sections> </sections>
             </iso-standard>
        OUTPUT
    end
  end

  it "reads scripts into blank HTML document" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{<script>})
  end

  it "uses default fonts" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
end
