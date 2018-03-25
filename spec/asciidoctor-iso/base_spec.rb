require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "has a version number" do
    expect(Asciidoctor::ISO::VERSION).not_to be nil
  end

  it "generates output for the Rice document" do
    system "cd spec/examples; rm -f rice.doc; rm -f rice.html; asciidoctor --trace -b iso -r 'asciidoctor-iso' rice.adoc; cd ../.."
    expect(File.exist?("spec/examples/rice.doc")).to be true
    expect(File.exist?("spec/examples/rice.html")).to be true
  end

  it "processes a blank document" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT
    #{BLANK_HDR}
<sections/>
</iso-standard>
    OUTPUT
  end

  it "converts a blank document" do
    system "rm -f test.doc"
    expect(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    #{BLANK_HDR}
<sections/>
</iso-standard>
    OUTPUT
    expect(File.exist?("test.doc")).to be true
  end

  it "processes default metadata" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :partnumber: 1
      :edition: 2
      :revdate: 2000-01-01
      :draft: 3.4
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
      :copyright-year: 2001
      :docstage: 10
      :docsubstage: 20
      :language: en
      :title-intro-en: Introduction
      :title-main-en: Main Title
      :title-part-en: Title Part
      :title-intro-fr: Introduction Française
      :title-main-fr: Titre Principal
      :title-part-fr: Part du Titre
      :library-ics: 1,2,3
    INPUT
           <?xml version="1.0" encoding="UTF-8"?>
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <bibdata type="article">
         <title>
           <title-intro language="en" format="text/plain">Introduction</title-intro>
           <title-main language="en" format="text/plain">Main Title</title-main>
           <title-part language="en" format="text/plain">Title Part</title-part>
         </title>
         <title>
           <title-intro language="fr" format="text/plain">Introduction Française</title-intro>
           <title-main language="fr" format="text/plain">Titre Principal</title-main>
           <title-part language="fr" format="text/plain">Part du Titre</title-part>
         </title>
         <docidentifier>
           <project-number part="1">1000</project-number>
         </docidentifier>
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
           <stage>10</stage>
           <substage>20</substage>
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
         <editorialgroup>
           <technical-committee number="1" type="A">TC</technical-committee>
           <subcommittee number="2" type="B">SC</subcommittee>
           <workgroup number="3" type="C">WG</workgroup>
           <secretariat>SECRETARIAT</secretariat>
         </editorialgroup>
         <ics>1</ics>
         <ics>2</ics>
         <ics>3</ics>
       </bibdata><version>
         <edition>2</edition>
         <revision-date>2000-01-01</revision-date>
         <draft>3.4</draft>
       </version>
       <sections/>
       </iso-standard>
    OUTPUT
  end


  it "processes complex metadata" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :partnumber: 1-1
      :tc-docnumber: 2000
      :language: el
      :script: Grek
      :publisher: IEC,IETF
    INPUT
           <?xml version="1.0" encoding="UTF-8"?>
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <bibdata type="article">
         <title>

         </title>
         <title>

         </title>
         <docidentifier>
           <project-number part="1" subpart="1">1000</project-number>
           <tc-document-number>2000</tc-document-number>
         </docidentifier>
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
         <language>el</language>
         <script>Grek</script>
         <status>
           <stage>60</stage>
           <substage>60</substage>
         </status>
         <copyright>
           <from>2018</from>
           <owner>
             <organization>
             <name>International Electrotechnical Commission</name>
             <abbreviation>IEC</abbreviation>
             </organization>
           </owner>
         </copyright>
         <copyright>
           <from>2018</from>
           <owner>
             <organization>
               <name>IETF</name>
             </organization>
           </owner>
         </copyright>
         <editorialgroup>
           <technical-committee/>
           <subcommittee/>
           <workgroup/>
         </editorialgroup>
       </bibdata>
       <sections/>
       </iso-standard>
    OUTPUT
  end

  it "uses default fonts" do
    system "rm -f test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    html = File.read("test.html")
    expect(html).to match(%r[p\.Sourcecode[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[p\.Biblio[^{]+\{[^{]+font-family: "Cambria", serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Cambria", serif;]m)
  end

  it "uses Chinese fonts" do
    system "rm -f test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
    INPUT
    html = File.read("test.html")
    expect(html).to match(%r[p\.Sourcecode[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[p\.Biblio[^{]+\{[^{]+font-family: "SimSun", serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "SimHei", sans-serif;]m)
  end

  it "uses specified fonts" do
    system "rm -f test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Andale Mono
    INPUT
    html = File.read("test.html")
    expect(html).to match(%r[p\.Sourcecode[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html).to match(%r[p\.Biblio[^{]+\{[^{]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: Comic Sans;]m)
  end

  it "strips MS-specific CSS" do
    system "rm -f test.html"
    system "rm -f test.doc"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    word = File.read("test.doc", encoding: "utf-8")
    html = File.read("test.html", encoding: "utf-8")
    expect(word).to match(%r[mso-style-name: "Intro Title";]m)
    expect(html).not_to match(%r[mso-style-name: "Intro Title";]m)
  end


end
