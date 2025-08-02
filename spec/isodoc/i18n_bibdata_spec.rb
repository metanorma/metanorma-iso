require "spec_helper"

RSpec.describe IsoDoc do
  it "changes i18n of reference_number based on document scheme" do
    input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>fr</language>
      <script>Latn</script>
      <status>
      <stage>published</stage>
      <substage>withdrawn</substage>
      </status>
      <edition>2</edition>
      <ext>
      <doctype>brochure</doctype>
      </ext>
      </bibdata>
      <metanorma-extension>
      <presentation-metadata><name>document-scheme</name><value>2024</value></presentation-metadata>
      </metanorma-extension>
      <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <localized-string key="reference_number" language="fr">Numéro de référence</localized-string>
    OUTPUT
    edn = <<~OUTPUT
      <edition language="fr">deuxi&#xE8;me &#xE9;dition</edition>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
    expect(xml.at("//xmlns:localized-string[@key = 'reference_number']").to_xml)
      .to be_equivalent_to output
    expect(xml.at("//xmlns:edition[@language = 'fr']").to_xml)
      .to be_equivalent_to edn

    output = <<~OUTPUT
      <localized-string key="reference_number" language="fr">Réf. №</localized-string>
    OUTPUT
    edn = <<~OUTPUT
      <edition language="fr">2<sup>e</sup> &#xC9;DITION</edition>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub("2024", "1951"), true))
    expect(xml.at("//xmlns:localized-string[@key = 'reference_number']").to_xml)
      .to be_equivalent_to output
    expect(xml.at("//xmlns:edition[@language = 'fr']").to_xml)
      .to be_equivalent_to edn
  end

  it "changes i18n of contributor role description" do
    input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
           <contributor>
             <role type="author">
                <description>Technical committee</description>
             </role>
             <organization>
                <name>International Electrotechnical Commission</name>
                <subdivision type="Technical committee">
                   <name>Electrical equipment in medical practice</name>
                   <identifier>TC 62</identifier>
                   <identifier type="full">IEC TC 62/SC 62A/WG 62A1</identifier>
                </subdivision>
                <subdivision type="Subcommittee">
                   <name>Common aspects of electrical equipment used in medical practice</name>
                   <identifier>SC 62A</identifier>
                </subdivision>
                <subdivision type="Workgroup">
                   <name>Working group on defibulators</name>
                   <identifier>WG 62A1</identifier>
                </subdivision>
                <abbreviation>IEC</abbreviation>
             </organization>
          </contributor>
         <contributor>
             <role type="authorizer">
                <description>Technical committee</description>
             </role>
             <organization>
                <name>International Electrotechnical Commission</name>
                <subdivision type="Technical committee">
                   <name>Electrical equipment in medical practice</name>
                   <identifier>TC 62</identifier>
                   <identifier type="full">IEC TC 62/SC 62A/WG 62A1</identifier>
                </subdivision>
                <subdivision type="Subcommittee">
                   <name>Common aspects of electrical equipment used in medical practice</name>
                   <identifier>SC 62A</identifier>
                </subdivision>
                <subdivision type="Workgroup">
                   <name>Working group on defibulators</name>
                   <identifier>WG 62A1</identifier>
                </subdivision>
                <abbreviation>IEC</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="authorizer">
                <description>Subcommittee</description>
             </role>
             <organization>
                <name>International Electrotechnical Commission</name>
                <subdivision type="Technical committee">
                   <name>Electrical equipment in medical practice</name>
                   <identifier>TC 62</identifier>
                   <identifier type="full">IEC TC 62/SC 62A/WG 62A1</identifier>
                </subdivision>
                <subdivision type="Subcommittee">
                   <name>Common aspects of electrical equipment used in medical practice</name>
                   <identifier>SC 62A</identifier>
                </subdivision>
                <subdivision type="Workgroup">
                   <name>Working group on defibulators</name>
                   <identifier>WG 62A1</identifier>
                </subdivision>
                <abbreviation>IEC</abbreviation>
             </organization>
          </contributor>
      <language>fr</language>
      <script>Latn</script>
      <status>
      <stage>published</stage>
      <substage>withdrawn</substage>
      </status>
      <edition>2</edition>
      <ext>
      <doctype>brochure</doctype>
      </ext>
      </bibdata>
      <metanorma-extension>
      <presentation-metadata><name>document-scheme</name><value>2024</value></presentation-metadata>
      </metanorma-extension>
      <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <x><role type="author">
            <description language="">Technical committee</description><description language="fr">Comit&#xE9; technique</description>
         </role><role type="authorizer">
            <description language="">Technical committee</description><description language="fr">Comit&#xE9; technique</description>
         </role><role type="authorizer">
            <description>Subcommittee</description>
         </role></x>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
    expect("<x>#{xml.xpath('//xmlns:bibdata/xmlns:contributor/xmlns:role')
      .to_xml}</x>")
      .to be_equivalent_to output
  end

  it "add edition replacement text" do
    input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>fr</language>
      <script>Latn</script>
      <status>
      <stage>published</stage>
      <substage>withdrawn</substage>
      </status>
      <edition>2</edition>
      <ext>
      <doctype>brochure</doctype>
      </ext>
      </bibdata>
      <metanorma-extension>
      <presentation-metadata><name>document-scheme</name><value>1951</value></presentation-metadata>
      </metanorma-extension>
      <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
      </sections>
      </iso-standard>
    INPUT

    edn = <<~OUTPUT
      <edn-replacement>Cette deuxi&#xE8;me &#xE9;dition annule et remplace la premi&#xE8;re &#xE9;dition</edn-replacement>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
    expect(xml.at("//xmlns:edn-replacement").to_xml).to be_equivalent_to edn

    edn = <<~OUTPUT
      <edn-replacement>Настоящее второе издание заменяет первое издание</edn-replacement>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input
        .sub("<language>fr</language>", "<language>ru</language>")
        .sub("<script>Latn</script>", "<script>Cyrl</script>"), true))
    expect(xml.at("//xmlns:edn-replacement").to_xml).to be_equivalent_to edn

    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub("1951", "2024"), true))
    expect(xml.at("//xmlns:edn-replacement")).to be_nil

    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input
        .sub("<edition>2</edition>", "<edition>1</edition>"), true))
    expect(xml.at("//xmlns:edn-replacement"))
      .to be_nil
  end

  it "add printing number text" do
    input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>en</language>
      <script>Latn</script>
      <edition>2</edition>
      <ext>
      <doctype>brochure</doctype>
      </ext>
      </bibdata>
      <metanorma-extension>
      <presentation-metadata><name>document-scheme</name><value>1951</value></presentation-metadata>
      <presentation-metadata><printing-date>2</printing-date>value></presentation-metadata>
      <presentation-metadata><printing-date>1965-12-01</printing-date>value></presentation-metadata>
      </metanorma-extension>
      <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
      </sections>
      </iso-standard>
    INPUT

    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
    expect(xml.at("//xmlns:date-printing").to_xml)
      .to be_equivalent_to "<date-printing>Date of the second printing</date-printing>"

    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input
        .sub("<language>en</language>", "<language>fr</language>"), true))
    expect(xml.at("//xmlns:date-printing").to_xml)
      .to be_equivalent_to "<date-printing>Date de la deuxi&#xE8;me impression</date-printing>"

    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input
        .sub("<language>en</language>", "<language>ru</language>")
        .sub("<script>Latn</script>", "<script>Cyrl</script>"), true))
    expect(xml.at("//xmlns:date-printing").to_xml)
      .to be_equivalent_to "<date-printing>&#x414;&#x430;&#x442;&#x430; &#x432;&#x442;&#x43E;&#x440;&#x43E;&#x439; &#x43F;&#x435;&#x447;&#x430;&#x442;&#x438;</date-printing>"

    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
     .new(presxml_options)
     .convert("test", input
       .sub("<language>en</language>", "<language>ja</language>")
       .sub("<script>Latn</script>", "<script>Japn</script>"), true))
    expect(xml.at("//xmlns:date-printing")).to be_nil
  end

  it "add draft stage name variants" do
    input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>en</language>
      <script>Latn</script>
      <status>
            <stage abbreviation="CD">40</stage>
      </status>
      <ext>
      <doctype>technical-report</doctype>
      </ext>
      </bibdata>
      <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
      </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <bibdata>
          <language current="true">en</language>
          <script current="true">Latn</script>
          <status>
             <stage abbreviation="CD" language="">40</stage>
             <stage abbreviation="CD" language="en">Draft Technical Report</stage>
             <stage abbreviation="CD" language="en" type="firstpage">DRAFT Technical Report</stage>
             <stage abbreviation="CD" language="en" type="coverpage">
                DRAFT
                <br/>
                Technical Report
             </stage>
          </status>
          <ext>
             <doctype language="">technical-report</doctype>
             <doctype language="en">Technical Report</doctype>
          </ext>
       </bibdata>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new({}).convert("test", input, true))
      .at("//xmlns:bibdata").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
    presxml = <<~OUTPUT
      <bibdata>
         <language current="true">fr</language>
         <script current="true">Latn</script>
         <status>
            <stage abbreviation="CD" language="">40</stage>
            <stage abbreviation="CD" language="fr">Projet Rapport technique</stage>
            <stage abbreviation="CD" language="fr" type="firstpage">PROJET de Rapport technique</stage>
            <stage abbreviation="CD" language="fr" type="coverpage">
               PROJET
               <br/>
               Rapport technique
            </stage>
         </status>
         <ext>
            <doctype language="">technical-report</doctype>
            <doctype language="fr">Rapport technique</doctype>
         </ext>
      </bibdata>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new({}).convert("test", input.sub("<language>en</language>",
                                         "<language>fr</language>"), true))
      .at("//xmlns:bibdata").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
    presxml = <<~OUTPUT
      <bibdata>
         <language current="true">de</language>
         <script current="true">Latn</script>
         <status>
            <stage abbreviation="CD" language="">40</stage>
            <stage abbreviation="CD" language="de">Entwurf des technischen Berichts</stage>
            <stage abbreviation="CD" language="de" type="firstpage">ENTWURF des technischen Berichts</stage>
            <stage abbreviation="CD" language="de" type="coverpage">
               ENTWURF
               <br/>
               des technischen Berichts
            </stage>
         </status>
         <ext>
            <doctype language="">technical-report</doctype>
            <doctype language="de">Technischer Bericht</doctype>
         </ext>
      </bibdata>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new({}).convert("test", input.sub("<language>en</language>",
                                         "<language>de</language>"), true))
      .at("//xmlns:bibdata").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
  end
end
