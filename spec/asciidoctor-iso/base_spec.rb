require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::ISO do
  it "has a version number" do
    expect(Metanorma::ISO::VERSION).not_to be nil
  end

  #it "generates output for the Rice document" do
    #FileUtils.rm_f %w(spec/examples/rice.xml spec/examples/rice.doc spec/examples/rice.html spec/examples/rice_alt.html)
    #FileUtils.cd "spec/examples"
    #Asciidoctor.convert_file "rice.adoc", {:attributes=>{"backend"=>"iso"}, :safe=>0, :header_footer=>true, :requires=>["metanorma-iso"], :failure_level=>4, :mkdirs=>true, :to_file=>nil}
    #FileUtils.cd "../.."
    #expect(File.exist?("spec/examples/rice.xml"))).to be true
    #expect(File.exist?("spec/examples/rice.doc"))).to be true
    #expect(File.exist?("spec/examples/rice.html"))).to be true
    #expect(File.exist?("spec/examples/rice_alt.html"))).to be true
  #end

  it "processes a blank document" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    #{ASCIIDOC_BLANK_HDR}
    INPUT
    #{BLANK_HDR}
<sections/>
</iso-standard>
    OUTPUT
  end

  it "converts a blank document" do
    FileUtils.rm_f "test.doc"
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :no-pdf:
    INPUT
    #{BLANK_HDR}
<sections/>
</iso-standard>
    OUTPUT
    expect(File.exist?("test.doc")).to be true
    expect(File.exist?("htmlstyle.css")).to be false
  end

  it "processes default metadata" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    INPUT
           <?xml version="1.0" encoding="UTF-8"?>
       <iso-standard xmlns="https://www.metanorma.org/ns/iso"  type="semantic" version="#{Metanorma::ISO::VERSION}">
       <bibdata type="standard">
   <title language="en" format="text/plain" type="main">Introduction — Main Title — Title — Title Part</title>
   <title language="en" format="text/plain" type="title-intro">Introduction</title>
   <title language="en" format="text/plain" type="title-main">Main Title — Title</title>
   <title language="en" format="text/plain" type="title-part">Title Part</title>
   <title language="fr" format="text/plain" type="main">Introduction Française — Titre Principal — Part du Titre</title>
   <title language="fr" format="text/plain" type="title-intro">Introduction Française</title>
   <title language="fr" format="text/plain" type="title-main">Titre Principal</title>
   <title language="fr" format="text/plain" type="title-part">Part du Titre</title>
         <docidentifier type="ISO">ISO/PreWD3 1000-1</docidentifier>
         <docidentifier type='iso-with-lang'>ISO/PreWD3 1000-1(E)</docidentifier>
         <docidentifier type='iso-reference'>ISO/PreWD3 1000-1:2000(E)</docidentifier>
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
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
      :publisher: IEC,IETF,ISO
      :copyright-holder: ISO,IETF
      :copyright-year: 2001
      :doctype: technical-report
      :pub-address: 1 Infinity Loop + \
      California
      :pub-phone: 3333333
      :pub-fax: 4444444
      :pub-email: x@example.com
      :pub-uri: http://www.example.com
    INPUT
           <?xml version="1.0" encoding="UTF-8"?>
       <iso-standard xmlns="https://www.metanorma.org/ns/iso"  type="semantic" version="#{Metanorma::ISO::VERSION}">
       <bibdata type="standard">
         <docidentifier type="ISO">ISO/IEC/IETF/TR 1000-1-1:2001</docidentifier>
         <docidentifier type='iso-with-lang'>ISO/IEC/IETF/TR 1000-1-1:2001(X)</docidentifier>
         <docidentifier type='iso-reference'>ISO/IEC/IETF/TR 1000-1-1:2001(X)</docidentifier>
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
             </organization>
           </owner>
         </copyright>
         <copyright>
           <from>2001</from>
           <owner>
             <organization>
               <name>IETF</name>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, "")))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
        <address>
          <formattedAddress>1 Infinity Loop <br/>California</formattedAddress>
        </address>
        <phone>3333333</phone>
        <phone type='fax'>4444444</phone>
        <email>x@example.com</email>
        <uri>http://www.example.com</uri>
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
      <from>2020</from>
      <owner>
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
        <project-number part='1' subpart='1'>SD 1000</project-number>
      </structuredidentifier>
      <stagename>International standard</stagename>
    </ext>
  </bibdata>
  <sections> </sections>
</iso-standard>

OUTPUT
     end

    it "defaults substage, defines iteration on stage 50, gives stage 50 on technical specification" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :docstage: 50
      :language: fr
      :doctype: technical-specification
      :iteration: 2
    INPUT
    <iso-standard xmlns="https://www.metanorma.org/ns/iso"  type="semantic" version="#{Metanorma::ISO::VERSION}">
<bibdata type="standard">
  <docidentifier type="ISO">ISO/DTS 1000.2</docidentifier>
  <docidentifier type='iso-with-lang'>ISO/DTS 1000.2(F)</docidentifier>
  <docidentifier type='iso-reference'>ISO/DTS 1000.2(F)</docidentifier>
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
    <stage abbreviation="D">50</stage>
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
    <doctype>technical-specification</doctype>
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
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :docstage: 60
    INPUT
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
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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


  it "reads scripts into blank HTML document" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
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
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[blockquote[^{]+\{[^{]+font-family: "Cambria", serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Cambria", serif;]m)
  end

  it "uses default fonts for alt doc" do
    FileUtils.rm_f "test_alt.html"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :no-pdf:
    INPUT
    html = File.read("test_alt.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: "Space Mono", monospace;]m)
    expect(html).to match(%r[blockquote[^{]+\{[^{]+font-family: "Lato", sans-serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Lato", sans-serif;]m)
  end

  it "uses Chinese fonts" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :script: Hans
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[blockquote[^{]+\{[^{]+font-family: "SimSun", serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "SimHei", sans-serif;]m)
  end

  it "uses specified fonts" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
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
    expect(html).to match(%r[blockquote[^{]+\{[^{]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: Comic Sans;]m)
  end

  it "strips MS-specific CSS" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
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
