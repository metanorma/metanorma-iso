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

      Text

      == Terms, Definitions, Symbols and Abbreviated Terms

      === Normal Terms

      === Symbols and Abbreviated Terms

      == Symbols and Abbreviated Terms

      == Clause 4

      === Introduction

      === Clause 4.2

      [appendix]
      == Annex

      === Annex A.1

      == Bibliography
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

       </terms>
       <terms id="_" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><term id="_">
         <preferred>Normal Terms</preferred>
       </term>
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

end
