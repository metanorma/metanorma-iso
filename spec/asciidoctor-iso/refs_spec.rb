require "spec_helper"
require "relaton_iso"
require "relaton_ietf"

RSpec.describe Asciidoctor::ISO do
  it "processes draft ISO reference" do
    #stub_fetch_ref no_year: true, note: "The standard is in press"

    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:--]]] footnote:[The standard is in press] _Standard_
    INPUT
       #{BLANK_HDR}
       <sections>
              </sections><bibliography><references id="_" obligation="informative" normative="true">
         <title>Normative References</title>
         <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
         <bibitem id="iso123" type="standard">
         <title format="text/plain">Standard</title>
         <docidentifier>ISO 123:—</docidentifier>
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
         <note format="text/plain" type="ISO DATE">The standard is in press</note>
       </bibitem>
       </references>
       </bibliography>
       </iso-standard>
    OUTPUT
  end

  it "processes all-parts ISO reference" do
    #stub_fetch_ref(all_parts: true)

    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
        <title>Normative References</title>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,XYZ 123:1066 (all parts)]]] _Standard_
    INPUT
       #{BLANK_HDR}
              <sections>

       </sections><bibliography><references id="_" obligation="informative" normative="true">
         <title>Normative References</title>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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

      private

    def mock_isobib_get_123
      expect(Isobib::IsoBibliography).to receive(:get).with("ISO 123", nil, {}) do
        IsoBibItem::XMLParser.from_xml(<<~"OUTPUT")
        <bibitem type=\"international-standard\" id=\"ISO123\">\n  <fetched>#{Date.today}</fetched>\n<title format=\"text/plain\" language=\"en\" script=\"Latn\">Rubber latex -- Sampling</title>\n  <title format=\"text/plain\" language=\"fr\" script=\"Latn\">Latex de caoutchouc -- ?chantillonnage</title>\n  <uri type=\"src\">https://www.iso.org/standard/23281.html</uri>\n  <uri type=\"obp\">https://www.iso.org/obp/ui/#!iso:std:23281:en</uri>\n  <uri type=\"rss\">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</uri>\n  <docidentifier type="ISO">ISO 123:2001</docidentifier>\n  <date type=\"published\">\n    <on>2001</on>\n  </date>\n  <contributor>\n    <role type=\"publisher\"/>\n    <organization>\n      <name>International Organization for Standardization</name>\n      <abbreviation>ISO</abbreviation>\n      <uri>www.iso.org</uri>\n    </organization>\n  </contributor>\n  <edition>3</edition>\n  <language>en</language>\n  <language>fr</language>\n  <script>Latn</script>\n  <status>Published</status>\n  <copyright>\n    <from>2001</from>\n    <owner>\n      <organization>\n        <name>ISO</name>\n        <abbreviation></abbreviation>\n      </organization>\n    </owner>\n  </copyright>\n  <relation type=\"obsoletes\">\n    <bibitem>\n      <formattedref>ISO 123:1985</formattedref>\n      </bibitem>\n  </relation>\n  <relation type=\"updates\">\n    <bibitem>\n      <formattedref>ISO 123:2001</formattedref>\n      </bibitem>\n  </relation>\n</bibitem>
        OUTPUT
      end
    end

    def mock_isobib_get_124
      expect(Isobib::IsoBibliography).to receive(:get).with("ISO 124", "2014", {}) do
        IsoBibItem::XMLParser.from_xml(<<~"OUTPUT")
                 <bibitem type="international-standard" id="iso124">
      <fetched>#{Date.today}</fetched>
         <title format="text/plain" language="en" script="Latn">Latex, rubber -- Determination of total solids content</title>
         <title format="text/plain" language="fr" script="Latn">Latex de caoutchouc -- Détermination des matières solides totales</title>
         <uri type="src">https://www.iso.org/standard/61884.html</uri>
         <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:61884:en</uri>
         <uri type="rss">https://www.iso.org/contents/data/standard/06/18/61884.detail.rss</uri>
         <docidentifier type="ISO">ISO 124:2014</docidentifier>
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
           </bibitem>
         </relation>
        <ics>
          <code>83.040.10</code>
          <text>Latex and raw rubber</text>
        </ics>
      </bibitem>
        OUTPUT
      end
    end

    def mock_isobib_get_iec12382
      expect(Isobib::IsoBibliography).to receive(:get).with("ISO/IEC TR 12382", "1992", {}) do
      IsoBibItem::XMLParser.from_xml(<<~"OUTPUT")
      <bibitem type="international-standard" id="iso123">
      <fetched>#{Date.today}</fetched>
         <title format="text/plain" language="en" script="Latn">Permuted index of the vocabulary of information technology</title>
         <title format="text/plain" language="fr" script="Latn">Index permuté du vocabulaire des technologies de l'information</title>
         <uri type="src">https://www.iso.org/standard/21071.html</uri>
         <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:21071:en</uri>
         <uri type="rss">https://www.iso.org/contents/data/standard/02/10/21071.detail.rss</uri>
         <docidentifier type="ISO">ISO/IEC 12382:1992</docidentifier>
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

end
