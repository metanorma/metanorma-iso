require "spec_helper"
require "relaton/iso"
require "relaton/iec"
require "relaton/ietf"

RSpec.describe Metanorma::Iso do
  it "processes draft ISO reference" do
    mock_fdis_iso
    mock_fdis_iec
    input = <<~INPUT
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
      * [[[fdis,ISO/FDIS 17664-1:2020]]] Title
      * [[[fdis2,IEC PWI 100-44 ED1]]] Title
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
          <sections>
             <clause id="_" inline-header="false" obligation="normative">
                <title id="_">Clause</title>
                <p id="_">
                   <eref type="inline" bibitemid="iso123" citeas="ISO 123:--"/>
                   <fn id="_" reference="1">
                      <p id="_">The standard is in press</p>
                   </fn>
                   <eref type="inline" bibitemid="iso123" citeas="ISO 123:--"/>
                   A.
                   <fn id="_" reference="2">
                      <p id="_">a footnote</p>
                   </fn>
                   <eref type="inline" bibitemid="fdis" citeas="ISO 17664-1:—"/>
                   <fn id="_" reference="3">
                      <p id="_">Under preparation. Stage at the time of publication: ISO/FDIS 17664-1:#{Date.today.year}.</p>
                   </fn>
                   <eref type="inline" bibitemid="fdis" citeas="ISO 17664-1:—"/>
                </p>
             </clause>
          </sections>
          <bibliography>
             <references id="_" normative="true" obligation="informative">
                <title id="_">Normative references</title>
                <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                <bibitem anchor="iso123" id="_" type="standard">
                   <title format="text/plain">Standard</title>
                   <docidentifier type="ISO">ISO 123:—</docidentifier>
                   <docnumber>123</docnumber>
                   <date type="published">
                      <on>–</on>
                   </date>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                         <abbreviation>ISO</abbreviation>
                      </organization>
                   </contributor>
                   <note format="text/plain" type="Unpublished-Status">The standard is in press</note>
                   <language>en</language>
                   <script>Latn</script>
                </bibitem>
                <bibitem id="_" type="standard" anchor="fdis">
                   <fetched/>
                   <title type="title-intro" format="text/plain" language="fr" script="Latn">Traitement de produits de soins de santé</title>
                   <title type="title-main" format="text/plain" language="fr" script="Latn">Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif</title>
                   <title type="title-part" format="text/plain" language="fr" script="Latn">Partie 1: Titre manque</title>
                   <title type="main" format="text/plain" language="fr" script="Latn">Traitement de produits de soins de santé — Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif — Partie 1: Titre manque</title>
                   <uri type="src">https://www.iso.org/standard/81720.html</uri>
                   <uri type="rss">https://www.iso.org/contents/data/standard/08/17/81720.detail.rss</uri>
                   <docidentifier type="ISO">ISO 17664-1:—</docidentifier>
                   <docidentifier type="URN">urn:iso:std:iso-fdis:17664:-1:ed-1:fr</docidentifier>
                   <docnumber>17664</docnumber>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                         <abbreviation>ISO</abbreviation>
                         <uri>www.iso.org</uri>
                      </organization>
                   </contributor>
                   <edition>1</edition>
                   <note type="Unpublished-Status">
                      <p id="_">Under preparation. Stage at the time of publication: ISO/FDIS 17664-1:#{Date.today.year}.</p>
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
                   <place><city>Geneva</city></place>
                </bibitem>
                <bibitem id="_" type="standard" anchor="fdis2">
                   <fetched/>
                   <title type="title-intro" format="text/plain" language="fr" script="Latn">Traitement de produits de soins de santé</title>
                   <title type="title-main" format="text/plain" language="fr" script="Latn">Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif</title>
                   <title type="title-part" format="text/plain" language="fr" script="Latn">Partie 1: Titre manque</title>
                   <title type="main" format="text/plain" language="fr" script="Latn">Traitement de produits de soins de santé — Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif — Partie 1: Titre manque</title>
                   <uri type="src">https://www.iso.org/standard/81720.html</uri>
                   <uri type="rss">https://www.iso.org/contents/data/standard/08/17/81720.detail.rss</uri>
                   <docidentifier type="IEC">IEC 100-44:— ED1</docidentifier>
                   <docidentifier type="URN">urn:iso:std:iso-fdis:17664:-1:ed-1:fr</docidentifier>
                   <docnumber>17664</docnumber>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Electrotechnical Commission</name>
                         <abbreviation>IEC</abbreviation>
                         <uri>www.iso.org</uri>
                      </organization>
                   </contributor>
                   <edition>1</edition>
                   <note type="Unpublished-Status">
                      <p id="_">Under preparation. Stage at the time of publication: IEC PWI 100-44:#{Date.today.year} ED1.</p>
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
                   <place><city>Geneva</city></place>
                </bibitem>
             </references>
          </bibliography>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes all-parts ISO reference" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      == Clause

      <<iso123>>

      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:1066 (all parts)]]] _Standard_
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title id="_">Clause</title>
            <p id="_">
              <eref bibitemid="iso123" citeas="ISO&#xa0;123:1066" type="inline"/>
            </p>
          </clause>
        </sections>
        <bibliography>
          <references id="_" normative="true" obligation="informative">
            <title id="_">Normative references</title>
            <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
            <bibitem id="_" anchor="iso123" type="standard">
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
              <language>en</language>
              <script>Latn</script>
              <extent type="part">
                <referenceFrom>all</referenceFrom>
              </extent>
            </bibitem>
          </references>
        </bibliography>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes non-ISO reference in Normative References" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,XYZ 123:1066 (all parts)]]] _Standard_
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>

        </sections>
        <bibliography>
          <references id="_" normative="true" obligation="informative">
            <title id="_">Normative references</title>
            <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
            <bibitem id="_" anchor="iso123">
              <formattedref format="application/x-isodoc+xml">
                <em>Standard</em>
              </formattedref>
              <docidentifier>XYZ 123:1066 (all parts)</docidentifier>
              <docnumber>123:1066 (all parts)</docnumber>
              <language>en</language>
              <script>Latn</script>
            </bibitem>
          </references>
        </bibliography>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes non-ISO reference in Bibliography" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Bibliography

      * [[[iso123,1]]] _Standard_
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>

        </sections>
        <bibliography>
          <references id="_" normative="false" obligation="informative">
            <title id="_">Bibliography</title>
            <bibitem id="_" anchor="iso123">
              <formattedref format="application/x-isodoc+xml">
                <em>Standard</em>
              </formattedref>
              <docidentifier type="metanorma">[1]</docidentifier>
              <language>en</language>
              <script>Latn</script>
            </bibitem>
          </references>
        </bibliography>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "sort ISO references in Bibliography" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Bibliography

      * [[[iso1,ISO 8000-110]]]
      * [[[iso2,ISO 8000-61]]]
      * [[[iso3,ISO 8000-8]]]
      * [[[iso4,ISO 9]]]
    INPUT
    output = <<~OUTPUT
            #{BLANK_HDR}
              <sections> </sections>
        <bibliography>
          <references id='_' normative='false' obligation='informative'>
            <title id="_">Bibliography</title>
            <bibitem id="_" anchor="iso4" type='standard'>
              <docidentifier>ISO 9</docidentifier>
              <docnumber>9</docnumber>
              <contributor>
                <role type='publisher'/>
                <organization>
                  <name>International Organization for Standardization</name>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
              <language>en</language>
              <script>Latn</script>
            </bibitem>
            <bibitem id="_" anchor="iso3" type='standard'>
              <docidentifier>ISO 8000-8</docidentifier>
              <docnumber>8000-8</docnumber>
              <contributor>
                <role type='publisher'/>
                <organization>
                  <name>International Organization for Standardization</name>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
              <language>en</language>
              <script>Latn</script>
            </bibitem>
            <bibitem id="_" anchor="iso2" type='standard'>
              <docidentifier>ISO 8000-61</docidentifier>
              <docnumber>8000-61</docnumber>
              <contributor>
                <role type='publisher'/>
                <organization>
                  <name>International Organization for Standardization</name>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
              <language>en</language>
              <script>Latn</script>
            </bibitem>
            <bibitem id="_" anchor="iso1" type='standard'>
              <docidentifier>ISO 8000-110</docidentifier>
              <docnumber>8000-110</docnumber>
              <contributor>
                <role type='publisher'/>
                <organization>
                  <name>International Organization for Standardization</name>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
              <language>en</language>
              <script>Latn</script>
            </bibitem>
          </references>
        </bibliography>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "renders withdrawn and cancelled ISO references" do
    input = <<~INPUT
      #{LOCAL_CACHED_ISOBIB_BLANK_HDR}

      <<iso1,clause=1>>
      <<iso2,clause=1>>

      [bibliography]
      == Bibliography

      * [[[iso1,ISO 683-3:2019]]]
      * [[[iso2,ISO 31-0]]]
    INPUT
    output = <<~OUTPUT
        #{BLANK_HDR}
                 <preface>
          <foreword id="_" obligation="informative">
            <title id="_">Foreword</title>
            <p id="_">
              <eref type="inline" bibitemid="iso1" citeas="ISO 683-3:2019">
                <localityStack>
                  <locality type="clause">
                    <referenceFrom>1</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <fn id="_" reference="1">
                <p id="_">Cancelled and replaced by ISO 683-3:2022.</p>
              </fn>
              <eref type="inline" bibitemid="iso2" citeas="ISO 31-0">
                <localityStack>
                  <locality type="clause">
                    <referenceFrom>1</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <fn id="_" reference="2">
                <p id="_">Cancelled and replaced by ISO 80000-1:2009.</p>
              </fn>
            </p>
          </foreword>
        </preface>
        <sections/>
          <bibliography>
             <references id="_" normative="false" obligation="informative">
                <title id="_">Bibliography</title>
                <bibitem id="_" type="standard" anchor="iso2">
                   <fetched/>
                   <title language="en" script="Latn" type="title-main" format="text/plain">Quantities and units</title>
                   <title language="en" script="Latn" type="title-part" format="text/plain">Part 0: General principles</title>
                   <title language="en" script="Latn" type="main" format="text/plain">Quantities and units — Part 0: General principles</title>
                   <title language="fr" script="Latn" type="title-main" format="text/plain">Grandeurs et unités</title>
                   <title language="fr" script="Latn" type="title-part" format="text/plain">Partie 0: Principes généraux</title>
                   <title language="fr" script="Latn" type="main" format="text/plain">Grandeurs et unités — Partie 0: Principes généraux</title>
                   <uri type="src">https://www.iso.org/standard/3621.html</uri>
                   <uri type="rss">https://www.iso.org/contents/data/standard/00/36/3621.detail.rss</uri>
                   <docidentifier type="ISO" primary="true">ISO 31-0</docidentifier>
                   <docidentifier type="iso-reference">ISO 31-0(E)</docidentifier>
                   <docidentifier type="URN">urn:iso:std:iso:31:-0:stage-95.99</docidentifier>
                   <docnumber>31</docnumber>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                         <abbreviation>ISO</abbreviation>
                         <uri>www.iso.org</uri>
                      </organization>
                   </contributor>
                   <contributor>
                      <role type="author">
                         <description>committee</description>
                      </role>
                      <organization>
                         <name>International Organization for Standardization</name>
                         <subdivision type="technical-committee" subtype="TC">
                            <name>Quantities and units</name>
                            <identifier>ISO/TC 12</identifier>
                         </subdivision>
                         <abbreviation>ISO</abbreviation>
                      </organization>
                   </contributor>
                   <edition>3</edition>
                   <note type="Unpublished-Status">
                      <p id="_">Cancelled and replaced by ISO 80000-1:2009.</p>
                   </note>
                   <language>en</language>
                   <language>fr</language>
                   <script>Latn</script>
                   <status>
                      <stage>95</stage>
                      <substage>99</substage>
                   </status>
                   <copyright>
                      <from>1992</from>
                      <owner>
                         <organization>
                            <name>ISO</name>
                         </organization>
                      </owner>
                   </copyright>
                   <relation type="obsoletes">
                      <bibitem type="standard">
                         <formattedref>ISO 31-0:1981</formattedref>
                         <docidentifier type="ISO" primary="true">ISO 31-0:1981</docidentifier>
                      </bibitem>
                   </relation>
                   <relation type="updates">
                      <bibitem type="standard">
                         <formattedref>ISO 80000-1:2009</formattedref>
                         <docidentifier type="ISO" primary="true">ISO 80000-1:2009</docidentifier>
                         <date type="circulated">
                            <on>2009-11-17</on>
                         </date>
                      </bibitem>
                   </relation>
                   <relation type="updates">
                      <bibitem type="standard">
                         <formattedref>ISO 31-0:1992/Amd 1:1998</formattedref>
                         <docidentifier type="ISO" primary="true">ISO 31-0:1992/Amd 1:1998</docidentifier>
                         <date type="circulated">
                            <on>2009-11-17</on>
                         </date>
                      </bibitem>
                   </relation>
                   <relation type="updates">
                      <bibitem type="standard">
                         <formattedref>ISO 31-0:1992/Amd 2:2005</formattedref>
                         <docidentifier type="ISO" primary="true">ISO 31-0:1992/Amd 2:2005</docidentifier>
                         <date type="circulated">
                            <on>2009-11-17</on>
                         </date>
                      </bibitem>
                   </relation>
                   <relation type="instanceOf">
                      <bibitem type="standard">
                         <title language="en" script="Latn" type="title-main" format="text/plain">Quantities and units</title>
                         <title language="en" script="Latn" type="title-part" format="text/plain">Part 0: General principles</title>
                         <title language="en" script="Latn" type="main" format="text/plain">Quantities and units — Part 0: General principles</title>
                         <title language="fr" script="Latn" type="title-main" format="text/plain">Grandeurs et unités</title>
                         <title language="fr" script="Latn" type="title-part" format="text/plain">Partie 0: Principes généraux</title>
                         <title language="fr" script="Latn" type="main" format="text/plain">Grandeurs et unités — Partie 0: Principes généraux</title>
                         <uri type="src">https://www.iso.org/standard/3621.html</uri>
                         <uri type="rss">https://www.iso.org/contents/data/standard/00/36/3621.detail.rss</uri>
                         <docidentifier type="ISO" primary="true">ISO 31-0:1992</docidentifier>
                         <docidentifier type="iso-reference">ISO 31-0:1992(E)</docidentifier>
                         <docidentifier type="URN">urn:iso:std:iso:31:-0:stage-95.99</docidentifier>
                         <docnumber>31</docnumber>
                         <date type="published">
                            <on>1992-07</on>
                         </date>
                         <contributor>
                            <role type="publisher"/>
                            <organization>
                               <name>International Organization for Standardization</name>
                               <abbreviation>ISO</abbreviation>
                               <uri>www.iso.org</uri>
                            </organization>
                         </contributor>
                         <contributor>
                            <role type="author">
                               <description>committee</description>
                            </role>
                            <organization>
                               <name>International Organization for Standardization</name>
                               <subdivision type="technical-committee" subtype="TC">
                                  <name>Quantities and units</name>
                                  <identifier>ISO/TC 12</identifier>
                               </subdivision>
                               <abbreviation>ISO</abbreviation>
                            </organization>
                         </contributor>
                         <edition>3</edition>
                         <note type="Unpublished-Status">
                            <p id="_">Cancelled and replaced by ISO 80000-1:2009.</p>
                         </note>
                         <language>en</language>
                         <language>fr</language>
                         <script>Latn</script>
                         <abstract language="en" script="Latn">Gives general information about principles concerning physical quantities, equations, quantity and unit symbols, and coherent unit systems, especially the International System of Units, SI, including recommendations for printing symbols and numbers. Annex A includes a guide to terms used in names for physical quantities, Annex B a guide to the rounding of numbers, Annex C international organizations in the field of quantities and units.</abstract>
                         <abstract language="fr" script="Latn">Gives general information about principles concerning physical quantities, equations, quantity and unit symbols, and coherent unit systems, especially the International System of Units, SI, including recommendations for printing symbols and numbers. Annex A includes a guide to terms used in names for physical quantities, Annex B a guide to the rounding of numbers, Annex C international organizations in the field of quantities and units.</abstract>
                         <status>
                            <stage>95</stage>
                            <substage>99</substage>
                         </status>
                         <copyright>
                            <from>1992</from>
                            <owner>
                               <organization>
                                  <name>ISO</name>
                               </organization>
                            </owner>
                         </copyright>
                         <relation type="obsoletes">
                            <bibitem type="standard">
                               <formattedref>ISO 31-0:1981</formattedref>
                               <docidentifier type="ISO" primary="true">ISO 31-0:1981</docidentifier>
                            </bibitem>
                         </relation>
                         <relation type="updates">
                            <bibitem type="standard">
                               <formattedref>ISO 80000-1:2009</formattedref>
                               <docidentifier type="ISO" primary="true">ISO 80000-1:2009</docidentifier>
                               <date type="circulated">
                                  <on>2009-11-17</on>
                               </date>
                            </bibitem>
                         </relation>
                         <relation type="updates">
                            <bibitem type="standard">
                               <formattedref>ISO 31-0:1992/Amd 1:1998</formattedref>
                               <docidentifier type="ISO" primary="true">ISO 31-0:1992/Amd 1:1998</docidentifier>
                               <date type="circulated">
                                  <on>2009-11-17</on>
                               </date>
                            </bibitem>
                         </relation>
                         <relation type="updates">
                            <bibitem type="standard">
                               <formattedref>ISO 31-0:1992/Amd 2:2005</formattedref>
                               <docidentifier type="ISO" primary="true">ISO 31-0:1992/Amd 2:2005</docidentifier>
                               <date type="circulated">
                                  <on>2009-11-17</on>
                               </date>
                            </bibitem>
                         </relation>
                         <place>
                            <formattedPlace>Geneva</formattedPlace>
                         </place>
                      </bibitem>
                   </relation>
                   <place>
                      <formattedPlace>Geneva</formattedPlace>
                   </place>
                </bibitem>
                <bibitem id="_" type="standard" anchor="iso1">
                   <fetched/>
                   <title language="en" script="Latn" type="title-main" format="text/plain">Heat-treatable steels, alloy steels and free-cutting steels</title>
                   <title language="en" script="Latn" type="title-part" format="text/plain">Part 3: Case-hardening steels</title>
                   <title language="en" script="Latn" type="main" format="text/plain">Heat-treatable steels, alloy steels and free-cutting steels — Part 3: Case-hardening steels</title>
                   <title language="fr" script="Latn" type="title-main" format="text/plain">Aciers pour traitement thermique, aciers alliés et aciers pour décolletage</title>
                   <title language="fr" script="Latn" type="title-part" format="text/plain">Partie 3: Aciers pour cémentation</title>
                   <title language="fr" script="Latn" type="main" format="text/plain">Aciers pour traitement thermique, aciers alliés et aciers pour décolletage — Partie 3: Aciers pour cémentation</title>
                   <uri type="src">https://www.iso.org/standard/76389.html</uri>
                   <uri type="rss">https://www.iso.org/contents/data/standard/07/63/76389.detail.rss</uri>
                   <docidentifier type="ISO" primary="true">ISO 683-3:2019</docidentifier>
                   <docidentifier type="iso-reference">ISO 683-3:2019(E)</docidentifier>
                   <docidentifier type="URN">urn:iso:std:iso:683:-3:stage-95.99</docidentifier>
                   <docnumber>683</docnumber>
                   <date type="published">
                      <on>2019-01</on>
                   </date>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                         <abbreviation>ISO</abbreviation>
                         <uri>www.iso.org</uri>
                      </organization>
                   </contributor>
                   <contributor>
                      <role type="author">
                         <description>committee</description>
                      </role>
                      <organization>
                         <name>International Organization for Standardization</name>
                         <subdivision type="technical-committee" subtype="TC">
                            <name>Heat treatable and alloy steels</name>
                            <identifier>ISO/TC 17/SC 4</identifier>
                         </subdivision>
                         <abbreviation>ISO</abbreviation>
                      </organization>
                   </contributor>
                   <edition>3</edition>
                   <note type="Unpublished-Status">
                      <p id="_">Cancelled and replaced by ISO 683-3:2022.</p>
                   </note>
                   <language>en</language>
                   <language>fr</language>
                   <script>Latn</script>
                   <abstract language="en" script="Latn">This document specifies the technical delivery requirements for
       —          semi-finished products, hot formed, e.g. blooms, billets, slabs (see NOTE 1),
       —          bars (see NOTE 1),
       —          wire rod,
       —          finished flat products, and
       —          hammer or drop forgings (see NOTE 1)
       manufactured from the case-hardening non-alloy or alloy steels listed in Table 3 and supplied in one of the heat-treatment conditions given for the different types of products in Table 1 and in one of the surface conditions given in Table 2.
       The steels are, in general, intended for the manufacture of case-hardened machine parts.
       NOTE 1    Hammer-forged semi-finished products (blooms, billets, slabs, etc.), seamless rolled rings and hammer-forged bars are covered under semi-finished products or bars and not under the term “hammer and drop forgings”.
       NOTE 2    For International Standards relating to steels complying with the requirements for the chemical composition in Table 3, however, supplied in other product forms or treatment conditions than given above or intended for special applications, and for other related International Standards, see the Bibliography.
       In special cases, variations in these technical delivery requirements or additions to them can form the subject of an agreement at the time of enquiry and order (see 5.2 and Annex A).
       In addition to this document, the general technical delivery requirements of ISO 404 are applicable.</abstract>
                   <abstract language="fr" script="Latn">Le présent document spécifie les conditions techniques de livraison des
       —          demi-produits formés à chaud, comme par exemple les blooms, billettes et brames (voir NOTE 1);
       —          barres (voir NOTE 1);
       —          fils machine;
       —          produits plats finis; et
       —          pièces forgées par martelage ou estampage (voir NOTE 1)
       fabriqués à partir d’aciers alliés ou non alliés pour cémentation énumérés dans le Tableau 3 et livrés dans l’un des états de traitement thermique donnés pour les différents types de produits dans le Tableau 1 et dans l’un des états de surface donnés dans le Tableau 2.
       Les aciers sont en général destinés à la fabrication de pièces mécaniques cémentées.
       NOTE 1    Les produits semi-finis forgés par martelage (blooms, billettes, brames, etc.), les anneaux laminés sans soudure et les barres forgées par martelage figurent parmi les produits semi-finis ou les barres, et non sous l’appellation «pièces forgées par martelage ou estampage».
       NOTE 2    Pour les Normes internationales relatives aux aciers qui sont conformes aux exigences de composition chimique du Tableau 3, mais fournis sous d’autres formes de produits ou dans des états de traitement autres que ceux indiqués ci-dessus, ou qui sont destinés à des applications spéciales, ainsi que pour d’autres Normes internationales analogues, voir la Bibliographie.
       Dans certains cas particuliers, il est possible de déroger aux présentes conditions techniques de livraison ou d’en ajouter d’autres, à condition d’en convenir au moment de l’appel d’offres et de la commande (voir 5.2 et Annexe A).
       En complément du présent document, les conditions générales techniques de livraison de l’ISO 404 sont applicables.</abstract>
                   <status>
                      <stage>95</stage>
                      <substage>99</substage>
                   </status>
                   <copyright>
                      <from>2019</from>
                      <owner>
                         <organization>
                            <name>ISO</name>
                         </organization>
                      </owner>
                   </copyright>
                   <relation type="obsoletes">
                      <bibitem type="standard">
                         <formattedref>ISO 683-3:2016</formattedref>
                         <docidentifier type="ISO" primary="true">ISO 683-3:2016</docidentifier>
                      </bibitem>
                   </relation>
                   <relation type="updates">
                      <bibitem type="standard">
                         <formattedref>ISO 683-3:2022</formattedref>
                         <docidentifier type="ISO" primary="true">ISO 683-3:2022</docidentifier>
                         <date type="circulated">
                            <on>2022-01-21</on>
                         </date>
                      </bibitem>
                   </relation>
                   <place>
                      <city>Geneva</city>
                   </place>
                </bibitem>
             </references>
          </bibliography>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  private

  def mock_fdis_iso
    expect(Relaton::Iso::Bibliography).to receive(:get)
      .with("ISO/FDIS 17664-1", "2020", anything) do
      Relaton::Bib::Bibitem.from_xml(<<~"OUTPUT")
        <bibitem id="_" anchor="x" type="standard">
          <fetched>#{Date.today}</fetched>
          <title format="text/plain" language="fr" script="Latn" type="title-intro">Traitement de produits de soins de santé</title>
          <title format="text/plain" language="fr" script="Latn" type="title-main">Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif</title>
          <title format="text/plain" language="fr" script="Latn" type="title-part">Partie 1: Titre manque</title>
          <title format="text/plain" language="fr" script="Latn" type="main">Traitement de produits de soins de santé — Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif — Partie 1: Titre manque</title>
          <uri type="src">https://www.iso.org/standard/81720.html</uri>
          <uri type="rss">https://www.iso.org/contents/data/standard/08/17/81720.detail.rss</uri>
          <docidentifier type="ISO">ISO/FDIS 17664-1:2020</docidentifier>
          <docidentifier type="URN">urn:iso:std:iso-fdis:17664:-1:ed-1:fr</docidentifier>
          <docnumber>17664</docnumber>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
              <uri>www.iso.org</uri>
            </organization>
          </contributor>
          <edition>1</edition>
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
          <place><city>Geneva</city></place>
        </bibitem>
      OUTPUT
    end

    def mock_fdis_iec
      expect(Relaton::Iec::Bibliography).to receive(:get)
        .with("IEC PWI 100-44 ED1", nil, anything) do
        Relaton::Bib::Bibitem.from_xml(<<~"OUTPUT")
          <bibitem id="_" anchor="x" type="standard">
            <fetched>#{Date.today}</fetched>
            <title format="text/plain" language="fr" script="Latn" type="title-intro">Traitement de produits de soins de santé</title>
            <title format="text/plain" language="fr" script="Latn" type="title-main">Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif</title>
            <title format="text/plain" language="fr" script="Latn" type="title-part">Partie 1: Titre manque</title>
            <title format="text/plain" language="fr" script="Latn" type="main">Traitement de produits de soins de santé — Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif — Partie 1: Titre manque</title>
            <uri type="src">https://www.iso.org/standard/81720.html</uri>
            <uri type="rss">https://www.iso.org/contents/data/standard/08/17/81720.detail.rss</uri>
            <docidentifier type="IEC">IEC PWI 100-44 ED1</docidentifier>
            <docidentifier type="URN">urn:iso:std:iso-fdis:17664:-1:ed-1:fr</docidentifier>
            <docnumber>17664</docnumber>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>International Electrotechnical Commission</name>
                <abbreviation>IEC</abbreviation>
                <uri>www.iso.org</uri>
              </organization>
            </contributor>
            <edition>1</edition>
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
                        <place>
               <city>Geneva</city>
            </place>
          </bibitem>
        OUTPUT
      end
    end
  end
end
