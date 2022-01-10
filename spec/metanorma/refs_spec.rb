require "spec_helper"
require "relaton_iso"
require "relaton_ietf"

RSpec.describe Metanorma::ISO do
  it "processes draft ISO reference" do
    mock_fdis
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
      * [[[fdis,ISO/FDIS 17664-1]]] Title
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Clause</title>
            <p id="_">
              <eref bibitemid="iso123" citeas="ISO 123:--" type="inline"/>
              <fn reference="1"><p id="_">The standard is in press</p></fn>
              <eref bibitemid="iso123" citeas="ISO 123:--" type="inline"/>A.
              <fn reference="2">
                <p id="_">a footnote</p></fn>
              <eref bibitemid="fdis" citeas="ISO/FDIS 17664-1" type="inline"/>
              <fn reference="3">
                <p id="_">Under preparation. (Stage at the time of publication ISO/FDIS 17664-1).</p>
              </fn>
              <eref bibitemid="fdis" citeas="ISO/FDIS 17664-1" type="inline"/>
            </p>
          </clause>
        </sections>
        <bibliography>
          <references id="_" normative="true" obligation="informative">
            <title>Normative references</title>
            <p id="_">The following documents are referred to in the text in such a way that
                       some or all of their content constitutes requirements of this document.
                       For dated references, only the edition cited applies. For undated
                       references, the latest edition of the referenced document (including any
                       amendments) applies.
                     </p>
            <bibitem id="iso123" type="standard">
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
            </bibitem>
            <bibitem id="fdis" type="standard">
              <fetched>#{Date.today}</fetched>
              <title format="text/plain" language="fr" script="Latn" type="title-intro">Traitement de produits de soins de santé</title>
              <title format="text/plain" language="fr" script="Latn" type="title-main">Informations relatives au traitement des dispositifs médicaux à
                         fournir par le fabricant du dispositif
                       </title>
              <title format="text/plain" language="fr" script="Latn" type="title-part">Partie 1: Titre manque</title>
              <title format="text/plain" language="fr" script="Latn" type="main">Traitement de produits de soins de santé — Informations relatives au
                         traitement des dispositifs médicaux à fournir par le fabricant du
                         dispositif — Partie 1: Titre manque
                       </title>
              <uri type="src">https://www.iso.org/standard/81720.html</uri>
              <uri type="rss">https://www.iso.org/contents/data/standard/08/17/81720.detail.rss</uri>
              <docidentifier type="ISO">ISO/FDIS 17664-1</docidentifier>
              <docidentifier type="URN">urn:iso:std:iso-fdis:17664:-1:stage-50.00:ed-1:fr</docidentifier>
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
                <p id="_">Under preparation. (Stage at the time of publication ISO/FDIS 17664-1).</p>
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
              <relation type="obsoletes">
                <bibitem type="standard">
                  <formattedref format="text/plain">ISO 17664:2017</formattedref>
                </bibitem>
              </relation>
              <relation type="instance">
                <bibitem type="standard">
                  <fetched>2020-11-03</fetched>
                  <title format="text/plain" language="fr" script="Latn" type="title-intro">Traitement de produits de soins de santé</title>
                  <title format="text/plain" language="fr" script="Latn" type="title-main">Informations relatives au traitement des dispositifs médicaux à
                             fournir par le fabricant du dispositif
                           </title>
                  <title format="text/plain" language="fr" script="Latn" type="title-part">Partie 1: Titre manque</title>
                  <title format="text/plain" language="fr" script="Latn" type="main">Traitement de produits de soins de santé — Informations relatives
                             au traitement des dispositifs médicaux à fournir par le fabricant
                             du dispositif — Partie 1: Titre manque
                           </title>
                  <uri type="src">https://www.iso.org/standard/81720.html</uri>
                  <uri type="rss">https://www.iso.org/contents/data/standard/08/17/81720.detail.rss</uri>
                  <docidentifier type="ISO">ISO/FDIS 17664-1</docidentifier>
                  <docidentifier type="URN">urn:iso:std:iso-fdis:17664:-1:stage-50.00:ed-1:fr</docidentifier>
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
                    <p id="_">Under preparation. (Stage at the time of publication ISO/FDIS 17664-1).</p>
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
                  <relation type="obsoletes">
                    <bibitem type="standard">
                      <formattedref format="text/plain">ISO 17664:2017</formattedref>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
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
            <title>Clause</title>
            <p id="_">
              <eref bibitemid="iso123" citeas="ISO 123:1066" type="inline"/>
            </p>
          </clause>
        </sections>
        <bibliography>
          <references id="_" normative="true" obligation="informative">
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
              <extent type="part">
                <referenceFrom>all</referenceFrom>
              </extent>
            </bibitem>
          </references>
        </bibliography>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "sort ISO references in Bibliography" do
    VCR.use_cassette "sortrefs" do
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
              <title>Bibliography</title>
              <bibitem id='iso4' type='standard'>
                <docidentifier>ISO 9</docidentifier>
                <docnumber>9</docnumber>
                <contributor>
                  <role type='publisher'/>
                  <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                  </organization>
                </contributor>
              </bibitem>
              <bibitem id='iso3' type='standard'>
                <docidentifier>ISO 8000-8</docidentifier>
                <docnumber>8000-8</docnumber>
                <contributor>
                  <role type='publisher'/>
                  <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                  </organization>
                </contributor>
              </bibitem>
              <bibitem id='iso2' type='standard'>
                <docidentifier>ISO 8000-61</docidentifier>
                <docnumber>8000-61</docnumber>
                <contributor>
                  <role type='publisher'/>
                  <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                  </organization>
                </contributor>
              </bibitem>
              <bibitem id='iso1' type='standard'>
                <docidentifier>ISO 8000-110</docidentifier>
                <docnumber>8000-110</docnumber>
                <contributor>
                  <role type='publisher'/>
                  <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                  </organization>
                </contributor>
              </bibitem>
            </references>
          </bibliography>
        </iso-standard>
      OUTPUT
      expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
        .to be_equivalent_to xmlpp(output)
    end
  end

  private

  def mock_fdis
    expect(RelatonIso::IsoBibliography).to receive(:get)
      .with("ISO/FDIS 17664-1", nil, code: "ISO/FDIS 17664-1",
                                     lang: "en", match: anything, ord: anything,
                                     process: 1, year: nil,
                                     title: "Title", usrlbl: nil) do
      RelatonIsoBib::XMLParser.from_xml(<<~"OUTPUT")
        <bibitem id="x" type="standard">
          <fetched>#{Date.today}</fetched>
          <title format="text/plain" language="fr" script="Latn" type="title-intro">Traitement de produits de soins de santé</title>
          <title format="text/plain" language="fr" script="Latn" type="title-main">Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif</title>
          <title format="text/plain" language="fr" script="Latn" type="title-part">Partie 1: Titre manque</title>
          <title format="text/plain" language="fr" script="Latn" type="main">Traitement de produits de soins de santé — Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif — Partie 1: Titre manque</title>
          <uri type="src">https://www.iso.org/standard/81720.html</uri>
          <uri type="rss">https://www.iso.org/contents/data/standard/08/17/81720.detail.rss</uri>
          <docidentifier type="ISO">ISO/FDIS 17664-1</docidentifier>
          <docidentifier type="URN">urn:iso:std:iso-fdis:17664:-1:stage-50.00:ed-1:fr</docidentifier>
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
          <relation type="obsoletes">
            <bibitem type="standard">
              <formattedref format="text/plain">ISO 17664:2017</formattedref>
            </bibitem>
          </relation>
          <relation type="instance">
            <bibitem type="standard">
              <fetched>2020-11-03</fetched>
              <title format="text/plain" language="fr" script="Latn" type="title-intro">Traitement de produits de soins de santé</title>
              <title format="text/plain" language="fr" script="Latn" type="title-main">Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif</title>
              <title format="text/plain" language="fr" script="Latn" type="title-part">Partie 1: Titre manque</title>
              <title format="text/plain" language="fr" script="Latn" type="main">Traitement de produits de soins de santé — Informations relatives au traitement des dispositifs médicaux à fournir par le fabricant du dispositif — Partie 1: Titre manque</title>
              <uri type="src">https://www.iso.org/standard/81720.html</uri>
              <uri type="rss">https://www.iso.org/contents/data/standard/08/17/81720.detail.rss</uri>
              <docidentifier type="ISO">ISO/FDIS 17664-1</docidentifier>
              <docidentifier type="URN">urn:iso:std:iso-fdis:17664:-1:stage-50.00:ed-1:fr</docidentifier>
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
              <relation type="obsoletes">
                <bibitem type="standard">
                  <formattedref format="text/plain">ISO 17664:2017</formattedref>
                </bibitem>
              </relation>
              <place>Geneva</place>
            </bibitem>
          </relation>
          <place>Geneva</place>
        </bibitem>
      OUTPUT
    end
  end
end
