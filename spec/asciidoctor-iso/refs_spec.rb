require "spec_helper"

RSpec.describe Asciidoctor::ISO do
    it "processes simple ISO reference" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123]]] _Standard_
    INPUT
      #{BLANK_HDR}
      <sections>
      </sections><bibliography><references id="_" obligation="informative">
        <title>Normative References</title>
        <bibitem id="iso123" type="standard">
         <title format="text/plain">Standard</title>
         <docidentifier>ISO 123</docidentifier>
         <contributor>
           <role type="publisher"/>
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
  end

  it "processes simple ISO reference with date range" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:1066-1067]]] _Standard_
    INPUT
      #{BLANK_HDR}
      <sections>
      </sections><bibliography><references id="_" obligation="informative">
        <title>Normative References</title>
        <bibitem id="iso123" type="standard">
          <title format="text/plain">Standard</title>
  <docidentifier>ISO 123</docidentifier>
  <date type="published">
    <from>1066</from>
    <to>1067</to>
  </date>
  <contributor>
    <role type="publisher"/>
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
  end


  it "fetches simple ISO reference" do
    #stub_fetch_ref
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123]]] _Standard_
    INPUT
      #{BLANK_HDR}
      <sections>
      </sections><bibliography><references id="_" obligation="informative">
        <title>Normative References</title>
        <bibitem type="international-standard" id="iso123">
        <title format="text/plain" language="en" script="Latn">Rubber latex -- Sampling</title>
        <title format="text/plain" language="fr" script="Latn">Latex de caoutchouc -- Échantillonnage</title>
        <source type="src">https://www.iso.org/standard/23281.html</source>
        <source type="obp">https://www.iso.org/obp/ui/#!iso:std:23281:en</source>
        <source type="rss">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</source>
        <docidentifier>ISO 123</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
            <uri>www.iso.org</uri>
          </organization>
        </contributor>
        <edition>3</edition>
        <language>en</language>
        <language>fr</language>
        <script>Latn</script>
        <status>Published</status>
        <copyright>
          <from>2001</from>
          <owner>
            <organization>
              <name>ISO</name>
              <abbreviation/>
            </organization>
          </owner>
        </copyright>
        <relation type="obsoletes">
          <bibitem>
            <formattedref>ISO 123:1985</formattedref>
            <docidentifier>ISO 123:1985</docidentifier>
          </bibitem>
        </relation>
        <relation type="updates">
          <bibitem>
            <formattedref>ISO 123:2001</formattedref>
            <docidentifier>ISO 123:2001</docidentifier>
          </bibitem>
        </relation>
        <ics>
          <code>83.040.10</code>
          <text>Latex and raw rubber</text>
        </ics>
        <relation type="instance">
  <bibitem type="international-standard" id="ISO123">
    <title format="text/plain" language="en" script="Latn">Rubber latex -- Sampling</title>
        <title format="text/plain" language="fr" script="Latn">Latex de caoutchouc -- Échantillonnage</title>
    <source type="src">https://www.iso.org/standard/23281.html</source>
    <source type="obp">https://www.iso.org/obp/ui/#!iso:std:23281:en</source>
    <source type="rss">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</source>
    <docidentifier>ISO 123</docidentifier>
    <date type="published">
      <on>2001</on>
    </date>
    <contributor>
      <role type="publisher"/>
      <organization>
        <name>International Organization for Standardization</name>
        <abbreviation>ISO</abbreviation>
        <uri>www.iso.org</uri>
      </organization>
    </contributor>
    <edition>3</edition>
    <language>en</language>
    <language>fr</language>
    <script>Latn</script>
    <status>Published</status>
    <copyright>
      <from>2001</from>
      <owner>
        <organization>
          <name>ISO</name>
          <abbreviation/>
        </organization>
      </owner>
    </copyright>
    <relation type="obsoletes">
      <bibitem>
        <formattedref>ISO 123:1985</formattedref>
        <docidentifier>ISO 123:1985</docidentifier>
      </bibitem>
    </relation>
    <relation type="updates">
      <bibitem>
        <formattedref>ISO 123:2001</formattedref>
        <docidentifier>ISO 123:2001</docidentifier>
      </bibitem>
    </relation>
    <ics>
      <code>83.040.10</code>
      <text>Latex and raw rubber</text>
    </ics>
  </bibitem>
</relation>
      </bibitem>
      </references>
      </bibliography>
      </iso-standard>
    OUTPUT
  end

    it "fetches simple ISO reference" do
    system "mv ~/.relaton-bib.json ~/.relaton-bib.json1"
    system "rm -f test.relation.json"
    Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)
      #{CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123]]] _Standard_
    INPUT
    system "mv ~/.relaton-bib.json1 ~/.relaton-bib.json"
    end


  it "processes simple IEC reference" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,IEC 123]]] _Standard_
    INPUT
       #{BLANK_HDR}
              <sections>
       </sections><bibliography><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso123" type="standard">
         <title format="text/plain">Standard</title>
         <docidentifier>IEC 123</docidentifier>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>International Electrotechnical Commission</name>
             <abbreviation>IEC</abbreviation>
           </organization>
         </contributor>
       </bibitem>
       </references>
       </bibliography>
       </iso-standard>
    OUTPUT
  end

  it "processes dated ISO reference and joint ISO/IEC references" do
    #stub_fetch_ref

    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO/IEC TR 12382:1992]]] _Standard_
      * [[[iso124,ISO 124:2014]]] _Standard_
    INPUT
      #{BLANK_HDR}
      <sections>

      </sections><bibliography><references id="_" obligation="informative">
        <title>Normative References</title>
        <bibitem type="international-standard" id="iso123">
         <title format="text/plain" language="en" script="Latn">Permuted index of the vocabulary of information technology</title>
         <title format="text/plain" language="fr" script="Latn">Index permuté du vocabulaire des technologies de l'information</title>
         <source type="src">https://www.iso.org/standard/21071.html</source>
         <source type="obp">https://www.iso.org/obp/ui/#!iso:std:21071:en</source>
         <source type="rss">https://www.iso.org/contents/data/standard/02/10/21071.detail.rss</source>
         <docidentifier>ISO/IEC 12382</docidentifier>
         <date type="published">
           <on>1992</on>
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
           <role type="publisher"/>
           <organization>
             <name>International Electrotechnical Commission</name>
             <abbreviation>IEC</abbreviation>
             <uri>www.iec.ch</uri>
           </organization>
         </contributor>
         <edition>2</edition>
         <language>en</language>
         <language>fr</language>
         <script>Latn</script>
         <abstract format="plain" language="en" script="Latn">Contains a permuted index of all terms included in the parts 1 - 28 of ISO 2382. If any of these parts has been revised, the present TR refers to the revision.</abstract>
         <status>Published</status>
         <copyright>
           <from>1992</from>
           <owner>
             <organization>
               <name>ISO/IEC</name>
               <abbreviation/>
             </organization>
           </owner>
         </copyright>
         <relation type="updates">
           <bibitem>
             <formattedref>ISO/IEC TR 12382:1992</formattedref>
             <docidentifier>ISO/IEC TR 12382:1992</docidentifier>
           </bibitem>
         </relation>
        <ics>
          <code>35.020</code>
          <text>Information technology (IT) in general</text>
        </ics>
        <ics>
          <code>01.040.35</code>
          <text>Information technology (Vocabularies)</text>
        </ics>
       </bibitem>
         <bibitem type="international-standard" id="iso124">
         <title format="text/plain" language="en" script="Latn">Latex, rubber -- Determination of total solids content</title>
         <title format="text/plain" language="fr" script="Latn">Latex de caoutchouc -- Détermination des matières solides totales</title>
         <source type="src">https://www.iso.org/standard/61884.html</source>
         <source type="obp">https://www.iso.org/obp/ui/#!iso:std:61884:en</source>
         <source type="rss">https://www.iso.org/contents/data/standard/06/18/61884.detail.rss</source>
         <docidentifier>ISO 124</docidentifier>
         <date type="published">
           <on>2014</on>
         </date>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>International Organization for Standardization</name>
             <abbreviation>ISO</abbreviation>
             <uri>www.iso.org</uri>
           </organization>
         </contributor>
         <edition>7</edition>
         <language>en</language>
         <language>fr</language>
         <script>Latn</script>
         <abstract format="plain" language="en" script="Latn">ISO 124:2014 specifies methods for the determination of the total solids content of natural rubber field and concentrated latices and synthetic rubber latex. These methods are not necessarily suitable for latex from natural sources other than the Hevea brasiliensis, for vulcanized latex, for compounded latex, or for artificial dispersions of rubber.</abstract>
         <abstract format="plain" language="fr" script="Latn">L'ISO 124:2014 spécifie des méthodes pour la détermination des matières solides totales dans le latex de plantation, le latex de concentré de caoutchouc naturel et le latex de caoutchouc synthétique. Ces méthodes ne conviennent pas nécessairement au latex d'origine naturelle autre que celui de l'Hevea brasiliensis, au latex vulcanisé, aux mélanges de latex, ou aux dispersions artificielles de caoutchouc.</abstract>
         <status>Published</status>
         <copyright>
           <from>2014</from>
           <owner>
             <organization>
               <name>ISO</name>
               <abbreviation/>
             </organization>
           </owner>
         </copyright>
         <relation type="obsoletes">
           <bibitem>
             <formattedref>ISO 124:2011</formattedref>
             <docidentifier>ISO 124:2011</docidentifier>
           </bibitem>
         </relation>
        <ics>
          <code>83.040.10</code>
          <text>Latex and raw rubber</text>
        </ics>
      </bibitem>
      </references>
      </bibliography>
      </iso-standard>
    OUTPUT
  end

  it "processes draft ISO reference" do
    #stub_fetch_ref no_year: true, note: "The standard is in press"

    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:--]]] footnote:[The standard is in press] _Standard_
    INPUT
       #{BLANK_HDR}
       <sections>
              </sections><bibliography><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso123" type="standard">
         <title format="text/plain">Standard</title>
         <docidentifier>ISO 123</docidentifier>
         <date type="published">
           <on>--</on>
         </date>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>International Organization for Standardization</name>
             <abbreviation>ISO</abbreviation>
           </organization>
         </contributor>
         <note format="text/plain" reference="1">ISO DATE: The standard is in press</note>
       </bibitem>
       </references>
       </bibliography>
       </iso-standard>
    OUTPUT
  end

  it "processes all-parts ISO reference" do
    #stub_fetch_ref(all_parts: true)

    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:1066 (all parts)]]] _Standard_
    INPUT
      #{BLANK_HDR}
      <sections>
      </sections><bibliography><references id="_" obligation="informative">
        <title>Normative References</title>
        <bibitem id="iso123" type="standard">
         <title format="text/plain">Standard</title>
         <docidentifier>ISO 123</docidentifier>
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
         <allParts>true</allParts>
       </bibitem>
      </references>
      </bibliography>
      </iso-standard>
    OUTPUT
  end

  it "processes non-ISO reference in Normative References" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,XYZ 123:1066 (all parts)]]] _Standard_
    INPUT
       #{BLANK_HDR}
              <sections>

       </sections><bibliography><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso123">
         <formattedref format="application/x-isodoc+xml">
           <em>Standard</em>
         </formattedref>
         <docidentifier>XYZ 123:1066 (all parts)</docidentifier>
       </bibitem>
       </references>
       </bibliography>
       </iso-standard>
    OUTPUT
  end

  it "processes non-ISO reference in Bibliography" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Bibliography

      * [[[iso123,1]]] _Standard_
    INPUT
       #{BLANK_HDR}
              <sections>

       </sections><bibliography><references id="_" obligation="informative">
         <title>Bibliography</title>
         <bibitem id="iso123">
         <formattedref format="application/x-isodoc+xml">
           <em>Standard</em>
         </formattedref>
         <docidentifier>[1]</docidentifier>
       </bibitem>
       </references>
       </bibliography>
       </iso-standard>
    OUTPUT
  end

  it "process ISO reference without an Internet connection" do
    expect(Isobib::IsoBibliography).to receive(:search).with("ISO 123") do
      raise Algolia::AlgoliaProtocolError.new "getaddrinfo", "nodename nor servname provided, or not known (JCL49WV5AR-dsn.algolia.net:443)"
    end.at_least :once
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123]]] _Standard_
    INPUT
      <?xml version="1.0" encoding="UTF-8"?>
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata type="article">
        <title>

        </title>
        <title>

        </title>
        <docidentifier>
          <project-number>ISO </project-number>
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

        <script>Latn</script>
        <status>
          <stage>60</stage>
          <substage>60</substage>
        </status>
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
      <sections>

      </sections><bibliography><references id="_" obligation="informative">
        <title>Normative References</title>
        <bibitem id="iso123" type="standard">
        <title format="text/plain">Standard</title>
        <docidentifier>ISO 123</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography>
      </iso-standard>
    OUTPUT
  end
end
