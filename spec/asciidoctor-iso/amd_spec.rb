require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::ISO do
  it "validates amendment document against distinct ISO XML schema" do
    FileUtils.rm_f "test.err"
  Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :doctype: amendment

  [change=mid-air]
  == Para
  INPUT
    expect(File.read("test.err")).to include 'value of attribute "change" is invalid; must be equal to'
end

    it "processes amendment sections" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    #{BLANK_HDR.sub(%r{<doctype>article</doctype>}, "<doctype>amendment</doctype>")}
  <sections>
    <clause id='_' obligation='normative'>
      <title>Foreword</title>
      <p id='_'>Text</p>
    </clause>
    <clause id='_' obligation='normative'>
      <title>Introduction</title>
      <clause id='_' obligation='normative'>
        <title>Introduction Subsection</title>
      </clause>
    </clause>
    <clause id='_' obligation='normative' type="scope">
      <title>Scope</title>
      <p id='_'>Text</p>
    </clause>
    <clause id='_' obligation='normative'>
      <title>Acknowledgements</title>
    </clause>
    <clause id='_' obligation='normative'>
      <title>Normative References</title>
    </clause>
    <clause id='_' obligation='normative'>
      <title>Terms and Definitions</title>
      <clause id='_' obligation='normative'>
        <title>Term1</title>
      </clause>
    </clause>
    <clause id='_' obligation='normative'>
      <title>Terms, Definitions, Symbols and Abbreviated Terms</title>
      <clause id='_' obligation='normative'>
        <title>Normal Terms</title>
        <clause id='_' obligation='normative'>
          <title>Term2</title>
        </clause>
      </clause>
      <clause id='_' obligation='normative'>
        <title>Symbols and Abbreviated Terms</title>
      </clause>
    </clause>
    <clause id='_' obligation='normative'>
      <title>Symbols and Abbreviated Terms</title>
    </clause>
    <clause id='_' obligation='normative'>
      <title>Clause 4</title>
      <clause id='_' obligation='normative'>
        <title>Introduction</title>
      </clause>
      <clause id='_' obligation='normative'>
        <title>Clause 4.2</title>
      </clause>
    </clause>
    <clause id='_' obligation='normative'>
      <title>Terms and Definitions</title>
    </clause>
    <clause id='_' obligation='normative'>
      <title>Bibliography</title>
      <clause id='_' obligation='normative'>
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
    end

      it "processes section attributes" do
     expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{AMD_BLANK_HDR}
      [change=delete,locality="clause=introduction,paragraph=4-7",inline-header="true"]
      == Clause 1

     INPUT
             #{BLANK_HDR.sub(%r{<doctype>article</doctype>}, "<doctype>amendment</doctype>")}
       <sections><clause id="_" obligation="normative"  change="delete" locality="clause=introduction,paragraph=4-7">
         <title>Clause 1</title>
       </clause>
       </sections>
       </iso-standard>
     OUTPUT
  end

  it "processes default metadata, amendment" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
      :library-ics: 1,2,3
      :copyright-year: 2017
      :updates: ISO 17301-1:2016
      :created-date: 2016-05-01
      :amendment-number: 1
      :title-amendment-en: Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions
      :title-amendment-fr: Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport
      :doctype: amendment
      :updates-document-type: international-standard
    INPUT
    <iso-standard xmlns='https://www.metanorma.org/ns/iso'>
  <bibdata type='standard'>
    <title language='en' format='text/plain' type='main'>Introduction — Main Title — Title — Title Part — Mass fraction of
       extraneous matter, milled rice (nonglutinous), sample dividers and
       recommendations relating to storage and transport conditions</title>
    <title language='en' format='text/plain' type='title-intro'>Introduction</title>
    <title language='en' format='text/plain' type='title-main'>Main Title — Title</title>
    <title language='en' format='text/plain' type='title-part'>Title Part</title>
    <title language='en' format='text/plain' type='title-amd'>
  Mass fraction of extraneous matter, milled rice (nonglutinous), sample
  dividers and recommendations relating to storage and transport conditions
</title>
<title language='fr' format='text/plain' type='main'>
  Introduction Française — Titre Principal — Part du Titre — Fraction
  massique de matière étrangère, riz usiné (non gluant), diviseurs
  d’échantillon et recommandations relatives aux conditions d’entreposage et
  de transport
</title>
    <title language='fr' format='text/plain' type='title-intro'>Introduction Française</title>
    <title language='fr' format='text/plain' type='title-main'>Titre Principal</title>
    <title language='fr' format='text/plain' type='title-part'>Part du Titre</title>
    <title language='fr' format='text/plain' type='title-amd'>
  Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs
  d’échantillon et recommandations relatives aux conditions d’entreposage et
  de transport
</title>
    <docidentifier type='ISO'>ISO 17301-1:2016/PreNP Amd 1</docidentifier>
    <docidentifier type='iso-with-lang'>ISO 17301-1:2016/PreNP Amd 1(E)</docidentifier>
    <docidentifier type='iso-reference'>ISO 17301-1:2016/PreNP Amd 1:2017(E)</docidentifier>
    <docnumber>17301</docnumber>
    <date type='created'>
      <on>2016-05-01</on>
    </date>
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
    <language>en</language>
    <script>Latn</script>
    <status>
      <stage abbreviation='NP'>10</stage>
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
      <editorialgroup>
        <technical-committee number='1' type='A'>TC</technical-committee>
        <technical-committee number='11' type='A1'>TC1</technical-committee>
        <subcommittee number='2' type='B'>SC</subcommittee>
        <subcommittee number='21' type='B1'>SC1</subcommittee>
        <workgroup number='3' type='C'>WG</workgroup>
        <workgroup number='31' type='C1'>WG1</workgroup>
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
        <project-number part='1' amendment='1' origyr='2016-05-01'>17301</project-number>
      </structuredidentifier>
      <stagename>New work item proposal</stagename>
      <updates-document-type>international-standard</updates-document-type>
    </ext>
  </bibdata>
  <sections/>
</iso-standard>
OUTPUT
  end

    it "processes metadata, amendment" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
 <iso-standard xmlns='https://www.metanorma.org/ns/iso'>
   <bibdata type='standard'>
     <docidentifier type='ISO'>ISO 17301-1:2030/CD Amd 1</docidentifier>
     <docidentifier type='iso-with-lang'>ISO 17301-1:2030/CD Amd 1(E)</docidentifier>
     <docidentifier type='iso-reference'>ISO 17301-1:2030/CD Amd 1(E)</docidentifier>
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
     <language>en</language>
     <script>Latn</script>
     <status>
       <stage abbreviation='CD'>30</stage>
       <substage>00</substage>
     </status>
     <copyright>
       <from>2020</from>
       <owner>
         <organization>
           <name>International Organization for Standardization</name>
           <abbreviation>ISO</abbreviation>
         </organization>
       </owner>
     </copyright>
     <ext>
       <doctype>amendment</doctype>
       <editorialgroup>
         <technical-committee/>
         <subcommittee/>
         <workgroup/>
       </editorialgroup>
       <structuredidentifier>
         <project-number part='1' amendment='1'>17301</project-number>
       </structuredidentifier>
       <stagename>Committee draft</stagename>
     </ext>
   </bibdata>
   <sections/>
 </iso-standard>
OUTPUT
  end

    it "processes metadata, amendment" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
<iso-standard xmlns='https://www.metanorma.org/ns/iso'>
         <bibdata type='standard'>
           <docidentifier type='ISO'>ISO 17301-1:2030/DAmd 1</docidentifier>
           <docidentifier type='iso-with-lang'>ISO 17301-1:2030/DAmd 1(E)</docidentifier>
           <docidentifier type='iso-reference'>ISO 17301-1:2030/DAmd 1(E)</docidentifier>
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
           <language>en</language>
           <script>Latn</script>
           <status>
             <stage abbreviation='D'>40</stage>
             <substage>00</substage>
           </status>
           <copyright>
             <from>2020</from>
             <owner>
               <organization>
                 <name>International Organization for Standardization</name>
                 <abbreviation>ISO</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype>amendment</doctype>
             <editorialgroup>
               <technical-committee/>
               <subcommittee/>
               <workgroup/>
             </editorialgroup>
             <structuredidentifier>
               <project-number part='1' amendment='1'>17301</project-number>
             </structuredidentifier>
             <stagename>Draft</stagename>
           </ext>
         </bibdata>
         <sections/>
       </iso-standard>
OUTPUT
  end

      it "processes metadata, amendment" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
<iso-standard xmlns='https://www.metanorma.org/ns/iso'>
         <bibdata type='standard'>
           <docidentifier type='ISO'>ISO 17301-1:2030/Amd 1</docidentifier>
           <docidentifier type='iso-with-lang'>ISO 17301-1:2030/Amd 1(E)</docidentifier>
           <docidentifier type='iso-reference'>ISO 17301-1:2030/Amd 1(E)</docidentifier>
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
           <language>en</language>
           <script>Latn</script>
           <status>
             <stage abbreviation='IS'>60</stage>
             <substage>60</substage>
           </status>
           <copyright>
             <from>2020</from>
             <owner>
               <organization>
                 <name>International Organization for Standardization</name>
                 <abbreviation>ISO</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype>amendment</doctype>
             <editorialgroup>
               <technical-committee/>
               <subcommittee/>
               <workgroup/>
             </editorialgroup>
             <structuredidentifier>
               <project-number part='1' amendment='1'>17301</project-number>
             </structuredidentifier>
             <stagename>International standard</stagename>
           </ext>
         </bibdata>
         <sections/>
       </iso-standard>
OUTPUT
  end

  it "processes metadata, corrigendum" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
<iso-standard xmlns='https://www.metanorma.org/ns/iso'>
  <bibdata type='standard'>
    <docidentifier type='ISO'>ISO 17301-1:2030/CD Cor.3</docidentifier>
    <docidentifier type='iso-with-lang'>ISO 17301-1:2030/CD Cor.3(E)</docidentifier>
    <docidentifier type='iso-reference'>ISO 17301-1:2030/CD Cor.3(E)</docidentifier>
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
    <language>en</language>
    <script>Latn</script>
    <status>
      <stage abbreviation='CD'>30</stage>
      <substage>00</substage>
    </status>
    <copyright>
      <from>2020</from>
      <owner>
        <organization>
          <name>International Organization for Standardization</name>
          <abbreviation>ISO</abbreviation>
        </organization>
      </owner>
    </copyright>
    <ext>
      <doctype>technical-corrigendum</doctype>
      <editorialgroup>
        <technical-committee/>
        <subcommittee/>
        <workgroup/>
      </editorialgroup>
      <structuredidentifier>
        <project-number part='1' corrigendum='3'>17301</project-number>
      </structuredidentifier>
      <stagename>Committee draft</stagename>
    </ext>
  </bibdata>
  <sections/>
</iso-standard>
OUTPUT
  end

    it "processes metadata, corrigendum" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
<iso-standard xmlns='https://www.metanorma.org/ns/iso'>
  <bibdata type='standard'>
    <docidentifier type='ISO'>ISO 17301-1:2030/FDCor.3</docidentifier>
    <docidentifier type='iso-with-lang'>ISO 17301-1:2030/FDCor.3(E)</docidentifier>
    <docidentifier type='iso-reference'>ISO 17301-1:2030/FDCor.3(E)</docidentifier>
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
    <language>en</language>
    <script>Latn</script>
    <status>
      <stage abbreviation='FD'>50</stage>
      <substage>00</substage>
    </status>
    <copyright>
      <from>2020</from>
      <owner>
        <organization>
          <name>International Organization for Standardization</name>
          <abbreviation>ISO</abbreviation>
        </organization>
      </owner>
    </copyright>
    <ext>
      <doctype>technical-corrigendum</doctype>
      <editorialgroup>
        <technical-committee/>
        <subcommittee/>
        <workgroup/>
      </editorialgroup>
      <structuredidentifier>
        <project-number part='1' corrigendum='3'>17301</project-number>
      </structuredidentifier>
      <stagename>Final draft</stagename>
    </ext>
  </bibdata>
  <sections/>
</iso-standard>
OUTPUT
  end

      it "processes metadata, corrigendum" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
<iso-standard xmlns='https://www.metanorma.org/ns/iso'>
         <bibdata type='standard'>
           <docidentifier type='ISO'>ISO 17301-1:2030/Cor.3</docidentifier>
           <docidentifier type='iso-with-lang'>ISO 17301-1:2030/Cor.3(E)</docidentifier>
           <docidentifier type='iso-reference'>ISO 17301-1:2030/Cor.3(E)</docidentifier>
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
           <language>en</language>
           <script>Latn</script>
           <status>
             <stage abbreviation='IS'>60</stage>
             <substage>60</substage>
           </status>
           <copyright>
             <from>2020</from>
             <owner>
               <organization>
                 <name>International Organization for Standardization</name>
                 <abbreviation>ISO</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype>technical-corrigendum</doctype>
             <editorialgroup>
               <technical-committee/>
               <subcommittee/>
               <workgroup/>
             </editorialgroup>
             <structuredidentifier>
               <project-number part='1' corrigendum='3'>17301</project-number>
             </structuredidentifier>
             <stagename>International standard</stagename>
           </ext>
         </bibdata>
         <sections/>
       </iso-standard>
OUTPUT
  end



end
