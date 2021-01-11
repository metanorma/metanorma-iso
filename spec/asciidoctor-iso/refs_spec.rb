require "spec_helper"
require "relaton_iso"
require "relaton_ietf"

RSpec.describe Asciidoctor::ISO do
  it "processes draft ISO reference" do
    mock_fdis
    #mock_isobib_get_123
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true, agree_to_terms: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ISOBIB_BLANK_HDR}
      == Clause
      <<iso123>>
      <<iso123>>
      A.footnote:[a footnote]
      <<fdis>>
      <<fdis>>

      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:--]]] footnote:[The standard is in press] _Standard_
      * [[[fdis,ISO/FDIS 17664-1]]] Title
    INPUT
       #{BLANK_HDR}
                <sections>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>Clause</title>
             <p id='_'>
               <eref type='inline' bibitemid='iso123' citeas='ISO 123:--'/>
               <fn reference='1'>The standard is in press</fn>
               <eref type='inline' bibitemid='iso123' citeas='ISO 123:--'/>
                A.
               <fn reference='2'>
                 <p id='_'>a footnote</p>
               </fn>
               <eref type='inline' bibitemid='fdis' citeas='ISO/FDIS 17664-1'/>
               <fn reference='3'>
                 <p id='_'>Under preparation. (Stage at the time of publication ISO/FDIS 17664-1).</p>
               </fn>
               <eref type='inline' bibitemid='fdis' citeas='ISO/FDIS 17664-1'/>
             </p>
           </clause>
         </sections>
         <bibliography>
           <references id='_' normative='true' obligation='informative'>
             <title>Normative references</title>
             <p id='_'>
               The following documents are referred to in the text in such a way that
               some or all of their content constitutes requirements of this document.
               For dated references, only the edition cited applies. For undated
               references, the latest edition of the referenced document (including any
               amendments) applies.
             </p>
             <bibitem id='iso123' type='standard'>
               <title format='text/plain'>Standard</title>
               <docidentifier type='ISO'>ISO 123:—</docidentifier>
               <docnumber>123</docnumber>
               <date type='published'>
                 <on>–</on>
               </date>
               <contributor>
                 <role type='publisher'/>
                 <organization>
                   <name>International Organization for Standardization</name>
                   <abbreviation>ISO</abbreviation>
                 </organization>
               </contributor>
               <note format='text/plain' type='Unpublished-Status'>The standard is in press</note>
             </bibitem>
             <bibitem id='fdis' type='standard'>
               <fetched>#{Date.today}</fetched>
               <title type='title-intro' format='text/plain' language='fr' script='Latn'>Traitement de produits de soins de santé</title>
               <title type='title-main' format='text/plain' language='fr' script='Latn'>
                 Informations relatives au traitement des dispositifs médicaux à
                 fournir par le fabricant du dispositif
               </title>
               <title type='title-part' format='text/plain' language='fr' script='Latn'>Partie 1: Titre manque</title>
               <title type='main' format='text/plain' language='fr' script='Latn'>
                 Traitement de produits de soins de santé — Informations relatives au
                 traitement des dispositifs médicaux à fournir par le fabricant du
                 dispositif — Partie 1: Titre manque
               </title>
               <uri type='src'>https://www.iso.org/standard/81720.html</uri>
               <uri type='rss'>https://www.iso.org/contents/data/standard/08/17/81720.detail.rss</uri>
               <docidentifier type='ISO'>ISO/FDIS 17664-1</docidentifier>
               <docidentifier type='URN'>urn:iso:std:iso-fdis:17664:-1:stage-50.00:ed-1:fr</docidentifier>
               <docnumber>17664</docnumber>
               <contributor>
                 <role type='publisher'/>
                 <organization>
                   <name>International Organization for Standardization</name>
                   <abbreviation>ISO</abbreviation>
                   <uri>www.iso.org</uri>
                 </organization>
               </contributor>
               <edition>1</edition>
               <note type='Unpublished-Status'>
                 <p id='_'>Under preparation. (Stage at the time of publication ISO/FDIS 17664-1).</p>
               </note>
               <language>en</language>
               <language>fr</language>
               <script>Latn</script>
               <status>
                 <stage>50</stage>
                 <substage>00</substage>
               </status>
               <copyright>
                 <from>unknown</from>
                 <owner>
                   <organization>
                     <name>ISO/FDIS</name>
                   </organization>
                 </owner>
               </copyright>
               <relation type='obsoletes'>
                 <bibitem type='standard'>
                   <formattedref format='text/plain'>ISO 17664:2017</formattedref>
                 </bibitem>
               </relation>
               <relation type='instance'>
                 <bibitem type='standard'>
                   <fetched>2020-11-03</fetched>
                   <title type='title-intro' format='text/plain' language='fr' script='Latn'>Traitement de produits de soins de santé</title>
                   <title type='title-main' format='text/plain' language='fr' script='Latn'>
                     Informations relatives au traitement des dispositifs médicaux à
                     fournir par le fabricant du dispositif
                   </title>
                   <title type='title-part' format='text/plain' language='fr' script='Latn'>Partie 1: Titre manque</title>
                   <title type='main' format='text/plain' language='fr' script='Latn'>
                     Traitement de produits de soins de santé — Informations relatives
                     au traitement des dispositifs médicaux à fournir par le fabricant
                     du dispositif — Partie 1: Titre manque
                   </title>
                   <uri type='src'>https://www.iso.org/standard/81720.html</uri>
                   <uri type='rss'>https://www.iso.org/contents/data/standard/08/17/81720.detail.rss</uri>
                   <docidentifier type='ISO'>ISO/FDIS 17664-1</docidentifier>
                   <docidentifier type='URN'>urn:iso:std:iso-fdis:17664:-1:stage-50.00:ed-1:fr</docidentifier>
                   <docnumber>17664</docnumber>
                   <contributor>
                     <role type='publisher'/>
                     <organization>
                       <name>International Organization for Standardization</name>
                       <abbreviation>ISO</abbreviation>
                       <uri>www.iso.org</uri>
                     </organization>
                   </contributor>
                   <edition>1</edition>
                   <note type='Unpublished-Status'>
                     <p id='_'>Under preparation. (Stage at the time of publication ISO/FDIS 17664-1).</p>
                   </note>
                   <language>en</language>
                   <language>fr</language>
                   <script>Latn</script>
                   <status>
                     <stage>50</stage>
                     <substage>00</substage>
                   </status>
                   <copyright>
                     <from>unknown</from>
                     <owner>
                       <organization>
                         <name>ISO/FDIS</name>
                       </organization>
                     </owner>
                   </copyright>
                   <relation type='obsoletes'>
                     <bibitem type='standard'>
                       <formattedref format='text/plain'>ISO 17664:2017</formattedref>
                     </bibitem>
                   </relation>
                   <place>Geneva</place>
                 </bibitem>
               </relation>
               <place>Geneva</place>
             </bibitem>
           </references>
         </bibliography>
       </iso-standard>
    OUTPUT
  end

  it "processes all-parts ISO reference" do
    #stub_fetch_ref(all_parts: true)

    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true, agree_to_terms: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      == Clause

      <<iso123>>

      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:1066 (all parts)]]] _Standard_
    INPUT
      #{BLANK_HDR}
      <sections>
  <clause id='_' inline-header='false' obligation='normative'>
    <title>Clause</title>
    <p id='_'>
      <eref type='inline' bibitemid='iso123' citeas='ISO 123:1066'/>
    </p>
  </clause>
</sections>
      <bibliography><references id="_" obligation="informative" normative="true">
        <title>Normative references</title>
        <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
        <bibitem id="iso123" type="standard">
         <title format="text/plain">Standard</title>
         <docidentifier>ISO 123:1066 (all parts)</docidentifier>
         <docnumber>123</docnumber>
         <date type="published">
           <on>1066</on>
         </date>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>International Organization for Standardization</name>
             <abbreviation>ISO</abbreviation>
           </organization>
         </contributor>
         <extent type="part"><referenceFrom>all</referenceFrom></extent>
       </bibitem>
      </references>
      </bibliography>
      </iso-standard>
    OUTPUT
  end

  it "processes non-ISO reference in Normative References" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true, agree_to_terms: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,XYZ 123:1066 (all parts)]]] _Standard_
    INPUT
       #{BLANK_HDR}
              <sections>

       </sections><bibliography><references id="_" obligation="informative" normative="true">
         <title>Normative references</title>
         <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
         <bibitem id="iso123">
         <formattedref format="application/x-isodoc+xml">
           <em>Standard</em>
         </formattedref>
         <docidentifier>XYZ 123:1066 (all parts)</docidentifier>
         <docnumber>123:1066 (all parts)</docnumber>
       </bibitem>
       </references>
       </bibliography>
       </iso-standard>
    OUTPUT
  end

  it "processes non-ISO reference in Bibliography" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true, agree_to_terms: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Bibliography

      * [[[iso123,1]]] _Standard_
    INPUT
       #{BLANK_HDR}
              <sections>

       </sections><bibliography><references id="_" obligation="informative" normative="false">
         <title>Bibliography</title>
         <bibitem id="iso123">
         <formattedref format="application/x-isodoc+xml">
           <em>Standard</em>
         </formattedref>
         <docidentifier type="metanorma">[1]</docidentifier>
       </bibitem>
       </references>
       </bibliography>
       </iso-standard>
    OUTPUT
  end

      private

    def mock_isobib_get_123
      expect(RelatonIso::IsoBibliography).to receive(:get).with("ISO 123", nil, {:lang=>"en", :title=>"Title", :usrlbl=>nil}) do
      RelatonIsoBib::XMLParser.from_xml(<<~"OUTPUT")
        <bibitem type=\"international-standard\" id=\"ISO123\">\n  <fetched>#{Date.today}</fetched>\n<title format=\"text/plain\" language=\"en\" script=\"Latn\">Rubber latex -- Sampling</title>\n  <title format=\"text/plain\" language=\"fr\" script=\"Latn\">Latex de caoutchouc -- ?chantillonnage</title>\n  <uri type=\"src\">https://www.iso.org/standard/23281.html</uri>\n  <uri type=\"obp\">https://www.iso.org/obp/ui/#!iso:std:23281:en</uri>\n  <uri type=\"rss\">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</uri>\n  <docidentifier type="ISO">ISO 123:2001</docidentifier>\n  <date type=\"published\">\n    <on>2001</on>\n  </date>\n  <contributor>\n    <role type=\"publisher\"/>\n    <organization>\n      <name>International Organization for Standardization</name>\n      <abbreviation>ISO</abbreviation>\n      <uri>www.iso.org</uri>\n    </organization>\n  </contributor>\n  <edition>3</edition>\n  <language>en</language>\n  <language>fr</language>\n  <script>Latn</script>\n  <status>Published</status>\n  <copyright>\n    <from>2001</from>\n    <owner>\n      <organization>\n        <name>ISO</name>\n        <abbreviation></abbreviation>\n      </organization>\n    </owner>\n  </copyright>\n  <relation type=\"obsoletes\">\n    <bibitem>\n      <formattedref>ISO 123:1985</formattedref>\n      </bibitem>\n  </relation>\n  <relation type=\"updates\">\n    <bibitem>\n      <formattedref>ISO 123:2001</formattedref>\n      </bibitem>\n  </relation>\n</bibitem>
        OUTPUT
      end
    end

       def mock_rfcbib_get_rfc8341
      expect(IETFBib::RfcBibliography).to receive(:get).with("RFC 8341", nil, {}) do
      IETFBib::XMLParser.from_xml(<<~"OUTPUT")
      <bibitem id="RFC8341">
      <fetched>#{Date.today}</fetched>
  <title format="text/plain" language="en" script="Latn">Network Configuration Access Control Model</title>
  <docidentifier type="IETF">RFC 8341</docidentifier>
  <date type="published">
    <on>2018</on>
  </date>
  <status>published</status>
</bibitem>
OUTPUT
    end
end

   def mock_fdis
     expect(RelatonIso::IsoBibliography).to receive(:get).with("ISO/FDIS 17664-1", nil, {:lang=>"en", :title=>"Title", :usrlbl=>nil}) do
      RelatonIsoBib::XMLParser.from_xml(<<~"OUTPUT")
     <bibitem id="x" type="standard">  <fetched>#{Date.today}</fetched>  <title type="title-intro" format="text/plain" language="fr" script="Latn">Traitement de produits de soins de santé</title>  <title type="title-main" format="text/plain" language="fr" script="Latn">Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif</title>  <title type="title-part" format="text/plain" language="fr" script="Latn">Partie 1: Titre manque</title>  <title type="main" format="text/plain" language="fr" script="Latn">Traitement de produits de soins de santé — Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif — Partie 1: Titre manque</title>  <uri type="src">https://www.iso.org/standard/81720.html</uri>  <uri type="rss">https://www.iso.org/contents/data/standard/08/17/81720.detail.rss</uri>  <docidentifier type="ISO">ISO/FDIS 17664-1</docidentifier>  <docidentifier type="URN">urn:iso:std:iso-fdis:17664:-1:stage-50.00:ed-1:fr</docidentifier>  <docnumber>17664</docnumber>  <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>  <edition>1</edition>  <language>en</language>  <language>fr</language>  <script>Latn</script>  <status>    <stage>50</stage>    <substage>00</substage>  </status>  <copyright>    <from>unknown</from>    <owner>      <organization>        <name>ISO/FDIS</name>      </organization>    </owner>  </copyright>  <relation type="obsoletes">    <bibitem type="standard">      <formattedref format="text/plain">ISO 17664:2017</formattedref>    </bibitem>  </relation>  <relation type="instance">    <bibitem type="standard">      <fetched>2020-11-03</fetched>      <title type="title-intro" format="text/plain" language="fr" script="Latn">Traitement de produits de soins de santé</title>      <title type="title-main" format="text/plain" language="fr" script="Latn">Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif</title>      <title type="title-part" format="text/plain" language="fr" script="Latn">Partie 1: Titre manque</title>      <title type="main" format="text/plain" language="fr" script="Latn">Traitement de produits de soins de santé — Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif — Partie 1: Titre manque</title>      <uri type="src">https://www.iso.org/standard/81720.html</uri>      <uri type="rss">https://www.iso.org/contents/data/standard/08/17/81720.detail.rss</uri>      <docidentifier type="ISO">ISO/FDIS 17664-1</docidentifier>      <docidentifier type="URN">urn:iso:std:iso-fdis:17664:-1:stage-50.00:ed-1:fr</docidentifier>      <docnumber>17664</docnumber>      <contributor>        <role type="publisher"/>        <organization>          <name>International Organization for Standardization</name>          <abbreviation>ISO</abbreviation>          <uri>www.iso.org</uri>        </organization>      </contributor>      <edition>1</edition>      <language>en</language>      <language>fr</language>      <script>Latn</script>      <status>        <stage>50</stage>        <substage>00</substage>      </status>      <copyright>        <from>unknown</from>        <owner>          <organization>            <name>ISO/FDIS</name>          </organization>        </owner>      </copyright>      <relation type="obsoletes">        <bibitem type="standard">          <formattedref format="text/plain">ISO 17664:2017</formattedref>        </bibitem>      </relation>      <place>Geneva</place>    </bibitem>  </relation>  <place>Geneva</place></bibitem>
     OUTPUT
   end
   end

end
