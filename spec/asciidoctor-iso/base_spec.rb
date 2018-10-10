require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::ISO do
  it "has a version number" do
    expect(Metanorma::ISO::VERSION).not_to be nil
  end

  it "generates output for the Rice document" do
    FileUtils.rm_f %w(spec/examples/rice.xml spec/examples/rice.doc spec/examples/rice.html spec/examples/rice_alt.html)
    #system "cd spec/examples; asciidoctor --trace -b iso -r 'metanorma-iso' rice.adoc; cd ../.."
    FileUtils.cd "spec/examples"
    Asciidoctor.convert_file "rice.adoc", {:attributes=>{"backend"=>"iso"}, :safe=>0, :header_footer=>true, :requires=>["metanorma-iso"], :failure_level=>4, :mkdirs=>true, :to_file=>nil}
    FileUtils.cd "../.."
    expect(File.exist?("spec/examples/rice.xml")).to be true
    expect(File.exist?("spec/examples/rice.doc")).to be true
    expect(File.exist?("spec/examples/rice.html")).to be true
    expect(File.exist?("spec/examples/rice_alt.html")).to be true
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
    FileUtils.rm_f "test.doc"
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
    expect(File.exist?("htmlstyle.css")).to be false
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
      :copyright-year: 2001
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
      :library-ics: 1,2,3
    INPUT
           <?xml version="1.0" encoding="UTF-8"?>
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <bibdata type="article">
         <title>
           <title-intro language="en" format="text/plain">Introduction</title-intro>
           <title-main language="en" format="text/plain">Main Title — Title</title-main>
           <title-part language="en" format="text/plain">Title Part</title-part>
         </title>
         <title>
           <title-intro language="fr" format="text/plain">Introduction Française</title-intro>
           <title-main language="fr" format="text/plain">Titre Principal</title-main>
           <title-part language="fr" format="text/plain">Part du Titre</title-part>
         </title>
         <docidentifier>
           <project-number part="1">ISO 1000</project-number>
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
           <iteration>3</iteration>
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
      :publisher: IEC,IETF,ISO
    INPUT
           <?xml version="1.0" encoding="UTF-8"?>
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <bibdata type="article">
         <title>

         </title>
         <title>

         </title>
         <docidentifier>
           <project-number part="1" subpart="1">ISO/IEC/IETF 1000</project-number>
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
         <copyright>
           <from>2018</from>
           <owner>
             <organization>
               <name>International Organization for Standardization</name>
               <abbreviation>ISO</abbreviation>
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

  it "reads scripts into blank HTML document" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
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
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
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
    INPUT
    html = File.read("test_alt.html", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^{]+font-family: "Space Mono", monospace;]m)
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
      :script: Hans
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
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
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Andale Mono
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^{]+font-family: Andale Mono;]m)
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
    INPUT
    word = File.read("test.doc", encoding: "utf-8")
    html = File.read("test.html", encoding: "utf-8")
    expect(word).to match(%r[mso-style-name: "Intro Title";]m)
    expect(html).not_to match(%r[mso-style-name: "Intro Title";]m)
  end


end
