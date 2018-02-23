require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "processes sections" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

      .Foreword

      == Introduction

      === Introduction Subsection

      === Patent Notice

      == Scope

      Text

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

      [appendix]
      == Annex

      === Annex A.1

      == Bibliography

      === Bibliography Subsection
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
       <introduction id="_" obligation="informative"><title>Introduction</title><subsection id="_" obligation="informative">
         <title>Introduction Subsection</title>
       </subsection>
       </introduction><sections>
       <clause id="_" obligation="normative">
         <title>Scope</title>
         <p id="_">Text</p>
       </clause>

       <terms id="_" obligation="normative">
         <title>Terms and Definitions</title>
         <term id="_">
         <preferred>Term1</preferred>
       </term>
       </terms>
       <terms id="_" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="_" obligation="normative">
         <title>Normal Terms</title>
         <term id="_">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <symbols-abbrevs id="_"/></terms>
       <symbols-abbrevs id="_"/>
       <clause id="_" obligation="normative"><title>Clause 4</title><subsection id="_" obligation="normative">
         <title>Introduction</title>
       </subsection>
       <subsection id="_" obligation="normative">
         <title>Clause 4.2</title>
       </subsection></clause>

       </sections><annex id="_" obligation="normative">
         <title>Annex</title>
         <subsection id="_" obligation="normative">
         <title>Annex A.1</title>
       </subsection>
       </annex><references id="_" obligation="informative">
         <title>Normative References</title>
       </references><references id="_" obligation="informative">
         <title>Bibliography</title>
         <references id="_" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </references>
       </iso-standard>
    OUTPUT
  end

  it "processes section obligations" do
     expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

      [obligation=informative]
      == Clause 1

      === Clause 1a

      [obligation=normative]
      == Clause 2

      [appendix,obligation=informative]
      == Annex
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
       <sections><clause id="_" obligation="informative">
         <title>Clause 1</title>
         <subsection id="_" obligation="informative">
         <title>Clause 1a</title>
       </subsection>
       </clause>
       <clause id="_" obligation="normative">
         <title>Clause 2</title>
       </clause>
       </sections><annex id="_" obligation="informative">
         <title>Annex</title>
       </annex>
       </iso-standard>
     OUTPUT
  end

    it "processes inline headers" do
     expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

      == Clause 1

      [%inline-header]
      === Clause 1a

      [appendix]
      == Annex A

      [%inline-header]
      === Clause Aa
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
       <sections><clause id="_" obligation="normative">
         <title>Clause 1</title>
         <subsection id="_" inline-header="true" obligation="normative">
         <title>Clause 1a</title>
       </subsection>
       </clause>
       </sections><annex id="_" obligation="normative">
         <title>Annex A</title>
         <subsection id="_" inline-header="true" obligation="normative">
         <title>Clause Aa</title>
       </subsection>
       </annex>
       </iso-standard>
     OUTPUT
    end

  it "processes blank headers" do
     expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

      == Clause 1

      === {blank}

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
       <sections>
         <clause id="_" obligation="normative">
         <title>Clause 1</title>
         <subsection id="_" obligation="normative">
         <title/>
       </subsection>
       </clause>
       </sections>
       </iso-standard>
     OUTPUT
  end

    it "processes term document sources" do
     expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~'OUTPUT'
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

      [source="iso1234,iso5678"]
      == Terms and Definitions

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
       <sections>
         <terms id="_" obligation="normative">
         <title>Terms and Definitions</title>
         <source type="inline" bibitemid="iso1234" citeas=""/>
         <source type="inline" bibitemid="iso5678" citeas=""/>
       </terms>
       </sections>
       </iso-standard>
     OUTPUT
    end

end
