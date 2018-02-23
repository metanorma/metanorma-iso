require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "processes simple lists" do
    output = Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

      * List 1
      * List 2
      * List 3

      . List A
      . List B
      . List C

      List D:: List E
      List F:: List G

    INPUT
    expect(strip_guid(output)).to be_equivalent_to <<~'OUTPUT'
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
         <ul id="_">
         <li>
           <p id="_">List 1</p>
         </li>
         <li>
           <p id="_">List 2</p>
         </li>
         <li>
           <p id="_">List 3</p>
           <ol id="_" type="arabic">
         <li>
           <p id="_">List A</p>
         </li>
         <li>
           <p id="_">List B</p>
         </li>
         <li>
           <p id="_">List C</p>
           <dl id="_">
         <dt>List D</dt>
         <dd>
           <p id="_">List E</p>
         </dd>
         <dt>List F</dt>
         <dd>
           <p id="_">List G</p>
         </dd>
       </dl>
         </li>
       </ol>
         </li>
       </ul>
       </sections>
       </iso-standard>
    OUTPUT
  end

    it "processes complex lists" do
    output = Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

      [[id]]
      * First
      * Second
      +
      --
      entry1

      entry2
      --

      [[id1]]
      [loweralpha]
      . First
      . Second
      [upperalpha]
      .. Third
      .. Fourth
      . Fifth
      . Sixth

      [lowerroman]
      . A
      . B
      [upperroman]
      .. C
      .. D
      [arabic]
      ... E
      ... F


      Notes1::
      Notes::  Note 1.
      +
      Note 2.
      +
      Note 3.

    INPUT
    expect(strip_guid(output)).to be_equivalent_to <<~'OUTPUT'
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
       <sections><ul id="id">
         <li>
           <p id="_">First</p>
         </li>
         <li><p id="_">Second</p><p id="_">entry1</p>
       <p id="_">entry2</p></li>
       </ul>
       <ol id="id1" type="alphabet">
         <li>
           <p id="_">First</p>
         </li>
         <li>
           <p id="_">Second</p>
           <ol id="_" type="alphabet_upper">
         <li>
           <p id="_">Third</p>
         </li>
         <li>
           <p id="_">Fourth</p>
         </li>
       </ol>
         </li>
         <li>
           <p id="_">Fifth</p>
         </li>
         <li>
           <p id="_">Sixth</p>
         </li>
       </ol>
       <ol id="_" type="roman">
         <li>
           <p id="_">A</p>
         </li>
         <li>
           <p id="_">B</p>
           <ol id="_" type="roman_upper">
         <li>
           <p id="_">C</p>
         </li>
         <li>
           <p id="_">D</p>
           <ol id="_" type="arabic">
         <li>
           <p id="_">E</p>
         </li>
         <li>
           <p id="_">F</p>
           <dl id="_">
         <dt>Notes1</dt>
         <dd/>
         <dt>Notes</dt>
         <dd><p id="_">Note 1.</p><p id="_">Note 2.</p>
       <p id="_">Note 3.</p></dd>
       </dl>
         </li>
       </ol>
         </li>
       </ol>
         </li>
       </ol></sections>
       </iso-standard>
       OUTPUT
    end
end
