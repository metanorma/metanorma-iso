require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "has a version number" do
    expect(Asciidoctor::ISO::VERSION).not_to be nil
  end

  it "processes a blank document" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
    INPUT
    <?xml version="1.0" encoding="UTF-8"?>
<iso-standard xmlns="http://riboseinc.com/isoxml">
<bibdata type="article">
  <title>
    <title-main language="en" format="text/plain"/>
  </title>
  <title>
    <title-main language="fr" format="text/plain"/>
  </title>
  <docidentifier>
    <project-number/>
  </docidentifier>
  <contributor>
    <role type="author"/>
    <organization>
      <name>ISO</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>ISO</name>
    </organization>
  </contributor>
  <language/>
  <script>Latn</script>
  <status>
    <stage>60</stage>
    <substage>60</substage>
  </status>
  <copyright>
    <from>2018</from>
    <owner>
      <organization>
        <name>ISO</name>
      </organization>
    </owner>
  </copyright>
  <editorialgroup>
    <technical-committee/>
    <subcommittee/>
    <workgroup/>
  </editorialgroup>
</bibdata><version/>
<sections/>
</iso-standard>
    OUTPUT
  end

  it "processes default metadata" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
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
             <name>ISO</name>
           </organization>
         </contributor>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>ISO</name>
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
               <name>ISO</name>
             </organization>
           </owner>
         </copyright>
         <editorialgroup>
           <technical-committee number="1" type="A">TC</technical-committee>
           <subcommittee number="2" type="B">SC</subcommittee>
           <workgroup number="3" type="C">WG</workgroup>
           <secretariat>SECRETARIAT</secretariat>
         </editorialgroup>
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
    expect(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true)).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :docnumber: 1000
      :partnumber: 1-1
      :tc-docnumber: 2000
    INPUT
           <?xml version="1.0" encoding="UTF-8"?>
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <bibdata type="article">
         <title>
           <title-main language="en" format="text/plain"/>
         </title>
         <title>
           <title-main language="fr" format="text/plain"/>
         </title>
         <docidentifier>
           <project-number part="1" subpart="1">1000</project-number>
           <tc-document-number>2000</tc-document-number>
         </docidentifier>
         <contributor>
           <role type="author"/>
           <organization>
             <name>ISO</name>
           </organization>
         </contributor>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>ISO</name>
           </organization>
         </contributor>
         <language/>
         <script>Latn</script>
         <status>
           <stage>60</stage>
           <substage>60</substage>
         </status>
         <copyright>
           <from>2018</from>
           <owner>
             <organization>
               <name>ISO</name>
             </organization>
           </owner>
         </copyright>
         <editorialgroup>
           <technical-committee/>
           <subcommittee/>
           <workgroup/>
         </editorialgroup>
       </bibdata><version/>
       <sections/>
       </iso-standard>
    OUTPUT
  end

end
