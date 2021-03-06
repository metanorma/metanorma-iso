require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "has a version number" do
    expect(Metanorma::ISO::VERSION).not_to be nil
  end

  it "processes a blank document" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections/>
      </iso-standard>
    OUTPUT
    expect(xmlpp(Asciidoctor.convert(input, *OPTIONS)))
      .to be_equivalent_to xmlpp(output)
  end

  it "converts a blank document" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections/>
      </iso-standard>
    OUTPUT
    expect(xmlpp(Asciidoctor.convert(input, *OPTIONS)))
      .to be_equivalent_to xmlpp(output)
    expect(File.exist?("test_alt.html")).to be true
    expect(File.exist?("test.html")).to be true
    expect(File.exist?("test.doc")).to be true
    expect(File.exist?("test.pdf")).to be true
    expect(File.exist?("htmlstyle.css")).to be false
  end

  it "converts a blank document in French" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :no-pdf:
      :language: fr
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR_FR}
        <sections/>
      </iso-standard>
    OUTPUT
    expect(xmlpp(Asciidoctor.convert(input, *OPTIONS)))
      .to be_equivalent_to xmlpp(output)
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
      :library-ics: 1,2,3
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
              <doctype>article</doctype>
              <horizontal>true</horizontal>
              <editorialgroup>
                <technical-committee number="1" type="A">TC</technical-committee>
                <technical-committee number="11" type="A1">TC1</technical-committee>
                <subcommittee number="2" type="B">SC</subcommittee>
                <subcommittee number="21" type="B1">SC1</subcommittee>
                <workgroup number="3" type="C">WG</workgroup>
                <workgroup number="31" type="C1">WG1</workgroup>
                <secretariat>SECRETARIAT</secretariat>
              </editorialgroup>
              <ics>
                <code>1</code>
              </ics>
              <ics>
                <code>2</code>
              </ics>
              <ics>
                <code>3</code>
              </ics>
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
      :copyright-holder: ISO;IETF
      :copyright-year: 2001
      :doctype: technical-report
      :pub-address: 1 Infinity Loop + \
      California
      :pub-phone: 3333333
      :pub-fax: 4444444
      :pub-email: x@example.com
      :pub-uri: http://www.example.com
    INPUT
    expect(xmlpp(output.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
                      <?xml version="1.0" encoding="UTF-8"?>
                      <iso-standard type="semantic" version="#{Metanorma::ISO::VERSION}" xmlns="https://www.metanorma.org/ns/iso">
                        <bibdata type="standard">
                          <docidentifier type="ISO">ISO/IEC/IETF/TR 1000-1-1:2001</docidentifier>
                          <docidentifier type="iso-with-lang">ISO/IEC/IETF/TR 1000-1-1:2001(X)</docidentifier>
                          <docidentifier type="iso-reference">ISO/IEC/IETF/TR 1000-1-1:2001(X)</docidentifier>
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
                                <name>International Organization for Standardization</name>
                                <abbreviation>ISO</abbreviation>
                                <address>
                  <formattedAddress>1 Infinity Loop + California</formattedAddress>
                </address>
                <phone>3333333</phone>
                <phone type='fax'>4444444</phone>
                <email>x@example.com</email>
                <uri>http://www.example.com</uri>
        #{'        '}
                              </organization>
                            </owner>
                          </copyright>
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
                          <ext>
                            <doctype>technical-report</doctype>
                            <editorialgroup>
                              <technical-committee/>
                              <subcommittee/>
                              <workgroup/>
                            </editorialgroup>
                            <structuredidentifier>
                              <project-number part="1" subpart="1">ISO/IEC/IETF 1000</project-number>
                            </structuredidentifier>
                            <stagename>International standard</stagename>
                          </ext>
                        </bibdata>
                        <sections/>
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
                <technical-committee/>
                <subcommittee/>
                <workgroup/>
              </editorialgroup>
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
                      <technical-committee/>
                      <subcommittee/>
                      <workgroup/>
                    </editorialgroup>
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
            <doctype>article</doctype>
            <editorialgroup>
              <technical-committee/>
              <subcommittee/>
              <workgroup/>
            </editorialgroup>
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
              <doctype>article</doctype>
              <editorialgroup>
                <technical-committee/>
                <subcommittee/>
                <workgroup/>
              </editorialgroup>
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
              <from>2021</from>
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
                <technical-committee/>
                <subcommittee/>
                <workgroup/>
              </editorialgroup>
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
