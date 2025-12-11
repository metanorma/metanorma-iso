require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc::Iso::Metadata do
  it "processes IsoXML metadata" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
          <title format="text/plain" language="en" type="title-intro">Cereals and pulses H<sup>2</sup></title>
          <title format="text/plain" language="en" type="title-main">Specifications and test methods H<sup>2</sup></title>
          <title format="text/plain" language="en" type="title-part">Rice H<sup>2</sup></title>
          <title format="text/plain" language="en" type="title-complementary">Complement</title>
          <title format="text/plain" language="fr" type="title-intro">Céréales et légumineuses H<sup>2</sup></title>
          <title format="text/plain" language="fr" type="title-main">Spécification et méthodes d'essai H<sup>2</sup></title>
          <title format="text/plain" language="fr" type="title-part">Riz H<sup>2</sup></title>
          <title format="text/plain" language="fr" type="title-complementary">Complément</title>
          <docidentifier type="ISO">ISO/PreCD3 17301-1</docidentifier>
          <docidentifier type="iso-with-lang">ISO/PreCD3 17301-1 (E)</docidentifier>
          <docidentifier type="iso-reference">ISO/PreCD3 17301-1:2000 (E)</docidentifier>
          <docidentifier type="iso-tc">17301</docidentifier>
          <docidentifier type="iso-tc">17302</docidentifier>
          <docnumber>1730</docnumber>
          <date type="published">
            <on>2011</on>
          </date>
          <date type="accessed">
            <on>2012</on>
          </date>
          <date type="created">
            <from>2010</from>
            <to>2011</to>
          </date>
          <date type="activated">
            <on>2013</on>
          </date>
          <date type="obsoleted">
            <on>2014</on>
          </date>
          <edition>2</edition>
          <version>
            <revision-date>2016-05-01</revision-date>
            <draft>0.4</draft>
          </version>
          <contributor>
             <role type="author"/>
             <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="author">
                <description>committee</description>
             </role>
             <organization>
                <name>International Electrotechnical Commission</name>
                <subdivision type="Technical committee" subtype="TC">
                   <name>Electrical equipment in medical practice</name>
                   <identifier>TC 62</identifier>
                   <identifier type="full">IEC TC 62</identifier>
                </subdivision>
                <abbreviation>IEC</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="author">
                <description>committee</description>
             </role>
             <organization>
                <name>International Organization for Standardization</name>
                <subdivision type="Technical committee" subtype="TC">
                   <name>Quality management and corresponding general aspects for medical devices</name>
                   <identifier>TC 210</identifier>
                   <identifier type="full">TC 210/SC 62A/WG 62A1</identifier>
                </subdivision>
                <subdivision type="Subcommittee" subtype="SC">
                   <name>Common aspects of electrical equipment used in medical practice</name>
                   <identifier>SC 62A</identifier>
                </subdivision>
                <subdivision type="Workgroup" subtype="WG">
                   <name>Working group on defibulators</name>
                   <identifier>WG 62A1</identifier>
                </subdivision>
                <abbreviation>ISO</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="author">
                <description>committee</description>
             </role>
             <organization>
                <name>Institute of Electrical and Electronic Engineers</name>
                <subdivision type="Technical committee" subtype="TC">
                   <name>The committee</name>
                </subdivision>
                <abbreviation>IEEE</abbreviation>
             </organization>
          </contributor>
             <contributor>
      <role type="author">
         <description>secretariat</description>
      </role>
      <organization>
         <name>International Organization for Standardization</name>
         <subdivision type="Secretariat">
            <name>GB</name>
         </subdivision>
         <abbreviation>ISO</abbreviation>
      </organization>
   </contributor>
          <contributor>
             <role type="authorizer">
                <description>Agency</description>
             </role>
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
          <contributor>
             <role type="authorizer">
                <description>committee</description>
             </role>
             <organization>
                <name>International Electrotechnical Commission</name>
                <subdivision type="Technical committee" subtype="TC">
                   <name>Electrical equipment in medical practice</name>
                   <identifier>TC 62</identifier>
                   <identifier type="full">Approval IEC TC 62</identifier>
                </subdivision>
                <abbreviation>IEC</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="authorizer">
                <description>committee</description>
             </role>
             <organization>
                <name>International Organization for Standardization</name>
                <subdivision type="Technical committee" subtype="TC">
                   <name>Quality management and corresponding general aspects for medical devices</name>
                   <identifier>TC 210</identifier>
                   <identifier type="full">Approval TC 210/SC 62A/WG 62A1</identifier>
                </subdivision>
                <subdivision type="Subcommittee" subtype="SC">
                   <name>Common aspects of electrical equipment used in medical practice</name>
                   <identifier>SC 62A</identifier>
                </subdivision>
                <subdivision type="Workgroup" subtype="WG">
                   <name>Working group on defibulators</name>
                   <identifier>WG 62A1</identifier>
                </subdivision>
                <abbreviation>ISO</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="authorizer">
                <description>committee</description>
             </role>
             <organization>
                <name>Institute of Electrical and Electronic Engineers</name>
                <subdivision type="Technical committee" subtype="TC">
                   <name>The committee</name>
                </subdivision>
                <abbreviation>IEEE</abbreviation>
             </organization>
          </contributor>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage abbreviation="CD">30</stage>
            <substage>92</substage>
            <iteration>3</iteration>
          </status>
          <copyright>
            <from>2016</from>
            <owner>
              <organization>
                <abbreviation>ISO</abbreviation>
              </organization>
            </owner>
          </copyright>
          <keyword>kw2</keyword>
          <keyword>kw1</keyword>
          <ext>
            <doctype>international-standard</doctype>
            <horizontal>true</horizontal>
            <editorialgroup identifier="DEF">
              <technical-committee number="34">Food products</technical-committee>
              <subcommittee number="4">Cereals and pulses</subcommittee>
              <workgroup number="3">Rice Group</workgroup>
              <secretariat>GB</secretariat>
            </editorialgroup>
            <approvalgroup identifier="ABC">
              <technical-committee number="34a">Food products A</technical-committee>
              <subcommittee number="4a">Cereals and pulses A</subcommittee>
              <workgroup number="3a">Rice Group A</workgroup>
            </approvalgroup>
            <structuredidentifier>
              <project-number part="1">ISO/PreCD3 17301</project-number>
            </structuredidentifier>
            <stagename>Committee draft</stagename>
            <fast-track>true</fast-track>
          </ext>
        </bibdata>
        <metanorma-extension>
        <semantic-metadata>
        <stage-published>false</stage-published>
        </semantic-metadata>
        <presentation-metadata><name>document-scheme</name><value>1951</value></presentation-metadata>
        </metanorma-extension>
      </iso-standard>
    INPUT
    output =
      { accesseddate: "2012",
        activateddate: "2013",
        agency: "ISO",
        approvalgroup: "Approval IEC TC 62 and Approval TC 210/SC 62A/WG 62A1",
        authorizer: ["International Organization for Standardization", "International Electrotechnical Commission", "International Organization for Standardization", "Institute of Electrical and Electronic Engineers"],
        createddate: "2010&#x2013;2011",
        docnumber: "ISO/PreCD3 17301-1",
        docnumber_lang: "ISO/PreCD3 17301-1 (E)",
        docnumber_reference: "ISO/PreCD3 17301-1:2000 (E)",
        docnumeric: "1730",
        docsubtitle: "C&#xE9;r&#xE9;ales et l&#xE9;gumineuses H<sup>2</sup>&#xa0;&#x2014; Sp&#xE9;cification et m&#xE9;thodes d'essai H<sup>2</sup>&#xa0;&#x2014; Compl&#xE9;ment&#xa0;&#x2014; Partie&#xa0;1: Riz H<sup>2</sup>",
        docsubtitlecomplementary: "Compl&#xE9;ment",
        docsubtitleintro: "C&#xE9;r&#xE9;ales et l&#xE9;gumineuses H<sup>2</sup>",
        docsubtitlemain: "Sp&#xE9;cification et m&#xE9;thodes d'essai H<sup>2</sup>",
        docsubtitlepart: "Riz H<sup>2</sup>",
        docsubtitlepartlabel: "Partie&#xa0;1",
        doctitle: "Cereals and pulses H<sup>2</sup>&#xa0;&#x2014; Specifications and test methods H<sup>2</sup>&#xa0;&#x2014; Complement&#xa0;&#x2014; Part&#xa0;1: Rice H<sup>2</sup>",
        doctitlecomplementary: "Complement",
        doctitleintro: "Cereals and pulses H<sup>2</sup>",
        doctitlemain: "Specifications and test methods H<sup>2</sup>",
        doctitlepart: "Rice H<sup>2</sup>",
        doctitlepartlabel: "Part&#xa0;1",
        doctype: "International Standard",
        doctype_display: "International Standard",
        document_scheme: "1951",
        docyear: "2016",
        draft: "0.4",
        draftinfo: " (draft 0.4, 2016-05-01)",
        edition: "2",
        editorialgroup: "IEC TC 62 and TC 210/SC 62A/WG 62A1",
        fast_track: "true",
        horizontal: "true",
        keywords: ["kw2", "kw1"],
        lang: "en",
        obsoleteddate: "2014",
        "presentation_metadata_document-scheme": ["1951"],
        publisheddate: "2011",
        publisher: "International Organization for Standardization",
        revdate: "2016-05-01",
        revdate_monthyear: "May 2016",
        sc: "SC 62A",
        script: "Latn",
        secretariat: "GB",
        stage: "30",
        stage_int: 30,
        stageabbr: "CD",
        statusabbr: "PreCD3",
        substage_int: "92",
        tc: "TC 62",
        tc_docnumber: ["17301", "17302"],
        unpublished: true,
        wg: "WG 62A1" }
    expect(metadata(c.info(Nokogiri::XML(input),
                           nil))).to be_equivalent_to output
  end

  it "processes IsoXML metadata #2" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
            <title type="title-intro" language="en" format="text/plain">Cereals and pulses</title>
            <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
            <title type="title-part" language="en" format="text/plain">Rice</title>
          <docidentifier type="ISO">ISO/IEC/CD 17301-1-3</docidentifier>
          <docidentifier type="iso-with-lang">ISO/IEC/CD 17301-1-3 (E)</docidentifier>
          <docidentifier type="iso-reference">ISO/IEC/CD 17301-1-3 (E)</docidentifier>
          <docidentifier type="iso-tc">17301</docidentifier>
          <contributor>
            <role type="author"/>
            <organization>
              <name>ISO</name>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
             </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Electrotechnical Commission</name>
              <abbreviation>IEC</abbreviation>
            </organization>
          </contributor>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage abbreviation="IS">60</stage>
            <substage>92</substage>
          </status>
          <copyright>
            <from>2016</from>
            <owner>
              <organization>
                <name>International Organization for Standardization</name>
              </organization>
            </owner>
          </copyright>
          <relation type="obsoletes">
            <locality type="clause"><referenceFrom>3.1</referenceFrom></locality>
            <docidentifier>IEC 8121</docidentifier>
          </relation>
          <ext>
            <doctype>international-standard</doctype>
            <editorialgroup>
              <technical-committee number="34" type="ABC">Food products</technical-committee>
              <subcommittee number="4" type="DEF">Cereals and pulses</subcommittee>
              <workgroup number="3" type="GHI">Rice Group</workgroup>
            </editorialgroup>
            <approvalgroup>
              <technical-committee number="34" type="ABC">Food products</technical-committee>
              <workgroup number="3" type="GHI">Rice Group</workgroup>
            </approvalgroup>
            <ics><code>1.2.3</code></ics>
            <ics><code>1.2.3</code></ics>
            <structuredidentifier>
              <project-number part="1" subpart="3">ISO/IEC/CD 17301</project-number>
            </strucuredidentifier>
            <stagename>International standard</stagename>
          </ext>
        </bibdata>
      </iso-standard>
    INPUT
    output =
      { agency: "ISO/IEC",
        docnumber: "ISO/IEC/CD 17301-1-3",
        docnumber_lang: "ISO/IEC/CD 17301-1-3 (E)",
        docnumber_reference: "ISO/IEC/CD 17301-1-3 (E)",
        docsubtitlepartlabel: "Partie&#xa0;1&#x2013;3",
        doctitle: "Cereals and pulses&#xa0;&#x2014; Specifications and test methods&#xa0;&#x2014; Part&#xa0;1&#x2013;3: Rice",
        doctitleintro: "Cereals and pulses",
        doctitlemain: "Specifications and test methods",
        doctitlepart: "Rice",
        doctitlepartlabel: "Part&#xa0;1&#x2013;3",
        doctype: "International Standard",
        doctype_display: "International Standard",
        docyear: "2016",
        ics: "1.2.3, 1.2.3",
        lang: "en",
        obsoletes: "IEC 8121",
        obsoletes_part: "3.1",
        publisher: "International Organization for Standardization and International Electrotechnical Commission",
        script: "Latn",
        stage: "60",
        stage_int: 60,
        statusabbr: "IS",
        substage_int: "92",
        tc_docnumber: ["17301"],
        unpublished: false,
        }
    expect(metadata(c.info(Nokogiri::XML(input),
                           nil))).to be_equivalent_to output
  end

  it "processes IsoXML metadata in French" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <language>fr</language>
        </bibdata>
      </iso-standard>
    INPUT
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
            <title type="title-intro" language="en" format="text/plain">Cereals and pulses</title>
            <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
            <title type="title-part" language="en" format="text/plain">Rice</title>
            <title type="title-complementary" language="en" format="text/plain">Complement</title>
            <title type="title-intro" language="fr" format="text/plain">Céréales et légumineuses</title>
            <title type="title-main" language="fr" format="text/plain">Spécification et méthodes d'essai</title>
            <title type="title-part" language="fr" format="text/plain">Riz</title>
            <title type="title-complementary" language="fr" format="text/plain">Complément</title>
          <docidentifier type="ISO">ISO/IEC/CD 17301-1-3</docidentifier>
          <docidentifier type="iso-with-lang">ISO/IEC/CD 17301-1-3 (E)</docidentifier>
          <docidentifier type="iso-reference">ISO/IEC/CD 17301-1-3 (E)</docidentifier>
          <docidentifier type="iso-tc">17301</docidentifier>
          <contributor>
            <role type="author"/>
            <organization>
              <name>ISO</name>
            </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
             </organization>
          </contributor>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Electrotechnical Commission</name>
              <abbreviation>IEC</abbreviation>
            </organization>
          </contributor>
          <language>fr</language>
          <script>Latn</script>
          <status>
            <stage abbreviation="IS">60</stage>
            <substage>92</substage>
          </status>
          <copyright>
            <from>2016</from>
            <owner>
              <organization>
                <name>International Organization for Standardization</name>
              </organization>
            </owner>
          </copyright>
          <relation type="obsoletes">
            <locality type="clause"><referenceFrom>3.1</referenceFrom></locality>
            <docidentifier>IEC 8121</docidentifier>
          </relation>
          <ext>
            <doctype language="">international-standard</doctype>
            <doctype language="fr">Standard International</doctype>
            <editorialgroup>
              <technical-committee number="34" type="ABC">Food products</technical-committee>
              <subcommittee number="4" type="DEF">Cereals and pulses</subcommittee>
              <workgroup number="3" type="GHI">Rice Group</workgroup>
            </editorialgroup>
            <ics><code>1.2.3</code></ics>
            <ics><code>1.2.3</code></ics>
            <structuredidentifier>
              <project-number part="1" subpart="3">ISO/IEC/CD 17301</project-number>
            </strucuredidentifier>
            <stagename>International standard</stagename>
          </ext>
        </bibdata>
      </iso-standard>
    INPUT
    output =
      { agency: "ISO/IEC",
        docnumber: "ISO/IEC/CD 17301-1-3",
        docnumber_lang: "ISO/IEC/CD 17301-1-3 (E)",
        docnumber_reference: "ISO/IEC/CD 17301-1-3 (E)",
        docsubtitle: "Cereals and pulses&#xa0;&#x2014; Specifications and test methods&#xa0;&#x2014; Complement&#xa0;&#x2014; Part&#xa0;1&#x2013;3: Rice",
        docsubtitlecomplementary: "Complement",
        docsubtitleintro: "Cereals and pulses",
        docsubtitlemain: "Specifications and test methods",
        docsubtitlepart: "Rice",
        docsubtitlepartlabel: "Part&#xa0;1&#x2013;3",
        doctitle: "C&#xE9;r&#xE9;ales et l&#xE9;gumineuses&#xa0;&#x2014; Sp&#xE9;cification et m&#xE9;thodes d'essai&#xa0;&#x2014; Compl&#xE9;ment&#xa0;&#x2014; Partie&#xa0;1&#x2013;3: Riz",
        doctitlecomplementary: "Compl&#xE9;ment",
        doctitleintro: "C&#xe9;r&#xe9;ales et l&#xe9;gumineuses",
        doctitlemain: "Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai",
        doctitlepart: "Riz",
        doctitlepartlabel: "Partie&#xa0;1&#x2013;3",
        doctype: "International Standard",
        doctype_display: "Standard International",
        docyear: "2016",
        ics: "1.2.3, 1.2.3",
        lang: "fr",
        obsoletes: "IEC 8121",
        obsoletes_part: "3.1",
        publisher: "International Organization for Standardization et International Electrotechnical Commission",
        script: "Latn",
        stage: "60",
        stage_int: 60,
        statusabbr: "IS",
        substage_int: "92",
        tc_docnumber: ["17301"],
        unpublished: false,
        }
    expect(metadata(c.info(Nokogiri::XML(input),
                           nil))).to be_equivalent_to output
  end

  it "processes IsoXML metadata in Russian" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <language>ru</language>
        </bibdata>
      </iso-standard>
    INPUT
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
            <title type="title-intro" language="en" format="text/plain">Cereals and pulses</title>
            <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
            <title type="title-part" language="en" format="text/plain">Rice</title>
            <title format="text/plain" language="en" type="title-complementary">Complement</title>
            <title type="title-intro" language="fr" format="text/plain">Céréales et légumineuses</title>
            <title type="title-main" language="fr" format="text/plain">Spécification et méthodes d'essai</title>
            <title type="title-part" language="fr" format="text/plain">Riz</title>
            <title format="text/plain" language="fr" type="title-complementary">Complément</title>
            <title type="title-intro" language="ru" format="text/plain">Зерновые и бобовые</title>
            <title type="title-main" language="ru" format="text/plain">Технические характеристики и методы испытаний</title>
            <title type="title-part" language="ru" format="text/plain">Рис</title>
            <title format="text/plain" language="ru" type="title-complementary">Дополнение</title>
          <docidentifier type="ISO">ISO/IEC/CD 17301-1-3</docidentifier>
          <docidentifier type="iso-with-lang">ISO/IEC/CD 17301-1-3 (E)</docidentifier>
          <docidentifier type="iso-reference">ISO/IEC/CD 17301-1-3 (E)</docidentifier>
          <docidentifier type="iso-tc">17301</docidentifier>
          <contributor>
             <role type="author"/>
             <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="author">
                <description>committee</description>
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
             <role type="author">
                <description>committee</description>
             </role>
             <organization>
                <name>International Organization for Standardization</name>
                <subdivision type="Technical committee">
                   <name>Quality management and corresponding general aspects for medical devices</name>
                   <identifier>TC 210</identifier>
                   <identifier type="full">TC 210</identifier>
                </subdivision>
                <abbreviation>ISO</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="author">
                <description>committee</description>
             </role>
             <organization>
                <name>Institute of Electrical and Electronic Engineers</name>
                <subdivision type="Technical committee">
                   <name>The committee</name>
                </subdivision>
                <abbreviation>IEEE</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="authorizer">
                <description>Agency</description>
             </role>
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
          <contributor>
             <role type="authorizer">
                <description>committee</description>
             </role>
             <organization>
                <name>International Electrotechnical Commission</name>
                <subdivision type="Technical committee">
                   <name>Electrical equipment in medical practice</name>
                   <identifier>TC 62</identifier>
                   <identifier type="full">Approval IEC TC 62/SC 62A/WG 62A1</identifier>
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
                <description>committee</description>
             </role>
             <organization>
                <name>International Organization for Standardization</name>
                <subdivision type="Technical committee">
                   <name>Quality management and corresponding general aspects for medical devices</name>
                   <identifier>TC 210</identifier>
                   <identifier type="full">Approval TC 210</identifier>
                </subdivision>
                <abbreviation>ISO</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="authorizer">
                <description>committee</description>
             </role>
             <organization>
                <name>Institute of Electrical and Electronic Engineers</name>
                <subdivision type="Technical committee">
                   <name>The committee</name>
                </subdivision>
                <abbreviation>IEEE</abbreviation>
             </organization>
          </contributor>
          <language>ru</language>
          <script>Cyrl</script>
          <status>
            <stage abbreviation="IS">60</stage>
            <substage>92</substage>
          </status>
          <copyright>
            <from>2016</from>
            <owner>
              <organization>
                <name>International Organization for Standardization</name>
              </organization>
            </owner>
          </copyright>
          <relation type="obsoletes">
            <locality type="clause"><referenceFrom>3.1</referenceFrom></locality>
            <docidentifier>IEC 8121</docidentifier>
          </relation>
          <ext>
            <doctype language="">international-standard</doctype>
            <doctype language="fr">Standard International</doctype>
            <editorialgroup>
              <technical-committee number="34" type="ABC">Food products</technical-committee>
              <subcommittee number="4" type="DEF">Cereals and pulses</subcommittee>
              <workgroup number="3" type="GHI">Rice Group</workgroup>
            </editorialgroup>
            <ics><code>1.2.3</code></ics>
            <ics><code>1.2.3</code></ics>
            <structuredidentifier>
              <project-number part="1" subpart="3">ISO/IEC/CD 17301</project-number>
            </strucuredidentifier>
            <stagename>International standard</stagename>
          </ext>
        </bibdata>
      </iso-standard>
    INPUT
    output =
      { agency: "ISO",
        approvalgroup: "Approval IEC TC 62/SC 62A/WG 62A1 и Approval TC 210",
        authorizer: ["International Organization for Standardization", "International Electrotechnical Commission", "International Organization for Standardization", "Institute of Electrical and Electronic Engineers"],
        docnumber: "ISO/IEC/CD 17301-1-3",
        docnumber_lang: "ISO/IEC/CD 17301-1-3 (E)",
        docnumber_reference: "ISO/IEC/CD 17301-1-3 (E)",
        docsubtitle: "Cereals and pulses&#xa0;&#x2014; Specifications and test methods&#xa0;&#x2014; Complement&#xa0;&#x2014; Part&#xa0;1&#x2013;3: Rice",
        docsubtitlecomplementary: "Complement",
        docsubtitleintro: "Cereals and pulses",
        docsubtitlemain: "Specifications and test methods",
        docsubtitlepart: "Rice",
        docsubtitlepartlabel: "Part&#xa0;1&#x2013;3",
        doctitle: "Зерновые и бобовые&#xa0;&#x2014; Технические характеристики и методы испытаний&#xa0;&#x2014; Дополнение&#xa0;&#x2014; Часть&#xa0;1&#x2013;3: Рис",
        doctitlecomplementary: "Дополнение",
        doctitleintro: "Зерновые и бобовые",
        doctitlemain: "Технические характеристики и методы испытаний",
        doctitlepart: "Рис",
        doctitlepartlabel: "Часть&#xa0;1&#x2013;3",
        doctype: "International Standard",
        doctype_display: "International Standard",
        docyear: "2016",
        editorialgroup: "IEC TC 62/SC 62A/WG 62A1 и TC 210",
        ics: "1.2.3, 1.2.3",
        lang: "ru",
        obsoletes: "IEC 8121",
        obsoletes_part: "3.1",
        publisher: "International Organization for Standardization",
        sc: "SC 62A",
        script: "Cyrl",
        stage: "60",
        stage_int: 60,
        statusabbr: "IS",
        substage_int: "92",
        tc: "TC 62",
        tc_docnumber: ["17301"],
        unpublished: false,
        wg: "WG 62A1" }
    expect(metadata(c.info(Nokogiri::XML(input), nil)))
      .to be_equivalent_to output
  end

  it "warns of missing Secretariat" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
              <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
              <status><stage abbreviation="CD">30</stage></status>
              <date type="published">2000</date>
              <contributor><role><description>committee</description></role></contributor>
          </bibdata>
          <metanorma-extension>
          <semantic-metadata>
          <stage-published>false</stage-published>
          </semantic-metadata>
          </metanorma-extension>
          <sections>
            <clause id="C">
              <title>Clause 1</title>
            </clause>
          </sections>
          <annotation-container>
          <annotation reviewer="Me" from="C" to="C" date="1">Hello</review>
          </annotation-container>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata type="standard">
             <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
             <status>
                <stage abbreviation="CD" language="">30</stage>
                <stage abbreviation="CD" language="en">Committee draft</stage>
             </status>
             <date type="published">2000</date>
              <contributor><role><description>committee</description></role></contributor>
          </bibdata>
            <metanorma-extension>
                <semantic-metadata>
                  <stage-published>false</stage-published>
                </semantic-metadata>
            </metanorma-extension>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <p class="zzSTDTitle1" displayorder="2">
                <span class="boldtitle">Specifications and test methods</span>
             </p>
             <clause id="C" displayorder="3">
                <fmt-annotation-start id="_" source="C" target="_" end="C" author="" date="#{Date.today}"/>
                <fmt-annotation-start id="_" source="C" target="_" end="C" author="" date="1"/>
                <title id="_">
                   Clause 1
                   <fmt-annotation-end id="_" source="C" target="_" start="C" author="" date="1"/>
                   <fmt-annotation-end id="_" source="C" target="_" start="C" author="" date="#{Date.today}"/>
                </title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="C">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 1</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="C">1</semx>
                </fmt-xref-label>
             </clause>
          </sections>
          <annotation-container>
             <annotation date="#{Date.today}" reviewer="Metanorma" id="_" from="C" to="C">
                <p>
                   <strong>Metadata warnings:</strong>
                </p>
                <p>Secretariat is missing.</p>
             </annotation>
             <fmt-annotation-body date="#{Date.today}" reviewer="Metanorma" id="_" from="_" to="_">
                <semx element="annotation" source="_">
                   <p>
                      <strong>Metadata warnings:</strong>
                   </p>
                   <p>Secretariat is missing.</p>
                </semx>
             </fmt-annotation-body>
             <annotation reviewer="Me" from="C" to="C" date="1" id="_">Hello</annotation>
             <fmt-annotation-body reviewer="Me" from="_" to="_" date="1" id="_">
                <semx element="annotation" source="_">Hello</semx>
             </fmt-annotation-body>
          </annotation-container>
       </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml.at("//xmlns:localized-strings")&.remove
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "warns of missing publication date" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
              <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
              <status><stage abbreviation="CD">30</stage></status>
              <contributor><role><description>committee</description></role></contributor>
              <contributor>
              <role><description>secretariat</description></role>
              </contributor>
          </bibdata>
          <metanorma-extension>
          <semantic-metadata>
          <stage-published>false</stage-published>
          </semantic-metadata>
          </metanorma-extension>
          <sections>
            <clause id="C">
              <title>Clause 1</title>
            </clause>
          </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata type="standard">
             <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
             <status>
                <stage abbreviation="CD" language="">30</stage>
                <stage abbreviation="CD" language="en">Committee draft</stage>
             </status>
              <contributor><role><description>committee</description></role></contributor>
              <contributor>
              <role><description>secretariat</description></role>
              </contributor>
          </bibdata>
            <metanorma-extension>
                <semantic-metadata>
                  <stage-published>false</stage-published>
                </semantic-metadata>
            </metanorma-extension>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <p class="zzSTDTitle1" displayorder="2">
                <span class="boldtitle">Specifications and test methods</span>
             </p>
             <clause id="C" displayorder="3">
                <fmt-annotation-start id="_" source="C" target="_" end="C" author="" date="#{Date.today}"/>
                <title id="_">
                   Clause 1
                   <fmt-annotation-end id="_" source="C" target="_" start="C" author="" date="#{Date.today}"/>
                </title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="C">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 1</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="C">1</semx>
                </fmt-xref-label>
             </clause>
          </sections>
          <annotation-container>
             <annotation date="#{Date.today}" reviewer="Metanorma" id="_" from="C" to="C">
                <p>
                   <strong>Metadata warnings:</strong>
                </p>
                <p>Document date is missing.</p>
             </annotation>
             <fmt-annotation-body date="#{Date.today}" reviewer="Metanorma" id="_" from="_" to="_">
                <semx element="annotation" source="_">
                   <p>
                      <strong>Metadata warnings:</strong>
                   </p>
                   <p>Document date is missing.</p>
                </semx>
             </fmt-annotation-body>
          </annotation-container>
       </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml.at("//xmlns:localized-strings")&.remove
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "warns of missing editorial groups" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
              <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
              <status><stage abbreviation="CD">30</stage></status>
              <date type="published">2000</date>
              <contributor>
              <role><description>secretariat</description></role>
              </contributor>
          </bibdata>
          <metanorma-extension>
          <semantic-metadata>
          <stage-published>false</stage-published>
          </semantic-metadata>
          </metanorma-extension>
          <sections>
            <clause id="C">
              <title>Clause 1</title>
            </clause>
          </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata type="standard">
             <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
             <status>
                <stage abbreviation="CD" language="">30</stage>
                <stage abbreviation="CD" language="en">Committee draft</stage>
             </status>
             <date type="published">2000</date>
              <contributor>
              <role><description>secretariat</description></role>
              </contributor>
          </bibdata>
            <metanorma-extension>
                <semantic-metadata>
                  <stage-published>false</stage-published>
                </semantic-metadata>
            </metanorma-extension>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <p class="zzSTDTitle1" displayorder="2">
                <span class="boldtitle">Specifications and test methods</span>
             </p>
             <clause id="C" displayorder="3">
                <fmt-annotation-start id="_" source="C" target="_" end="C" author="" date="#{Date.today}"/>
                <title id="_">
                   Clause 1
                   <fmt-annotation-end id="_" source="C" target="_" start="C" author="" date="#{Date.today}"/>
                </title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="C">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 1</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="C">1</semx>
                </fmt-xref-label>
             </clause>
          </sections>
          <annotation-container>
             <annotation date="#{Date.today}" reviewer="Metanorma" id="_" from="C" to="C">
                <p>
                   <strong>Metadata warnings:</strong>
                </p>
                <p>Editorial groups are missing.</p>
             </annotation>
             <fmt-annotation-body date="#{Date.today}" reviewer="Metanorma" id="_" from="_" to="_">
                <semx element="annotation" source="_">
                   <p>
                      <strong>Metadata warnings:</strong>
                   </p>
                   <p>Editorial groups are missing.</p>
                </semx>
             </fmt-annotation-body>
          </annotation-container>
       </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml.at("//xmlns:localized-strings")&.remove
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "does not warn of missing metadata in compliant document" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
              <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
              <status><stage abbreviation="CD">30</stage></status>
              <date type="published">2000</date>
              <contributor><role><description>secretariat</description></role></contributor>
          </bibdata>
          <sections>
            <clause>
              <title>Clause 1</title>
            </clause>
          </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata type="standard">
             <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
             <status>
                <stage abbreviation="CD" language="">30</stage>
                <stage abbreviation="CD" language="en">Committee draft</stage>
             </status>
             <date type="published">2000</date>
              <contributor><role><description>secretariat</description></role></contributor>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <p class="zzSTDTitle1" displayorder="2">
                <span class="boldtitle">Specifications and test methods</span>
             </p>
             <clause id="_" displayorder="3">
                <title id="_">Clause 1</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 1</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
             </clause>
          </sections>
       </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml.at("//xmlns:localized-strings")&.remove
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "does not warn of missing metadata in published document" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
              <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
              <status><stage abbreviation="CD">90</stage></status>
              <contributor><role><description>secretariat</description></role></contributor>
          </bibdata>
          <sections>
            <clause>
              <title>Clause 1</title>
            </clause>
          </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata type="standard">
             <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
             <status>
                <stage abbreviation="CD" language="">90</stage>
                <stage abbreviation="CD" language="en">Review</stage>
             </status>
              <contributor><role><description>secretariat</description></role></contributor>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <p class="zzSTDTitle1" displayorder="2">
                <span class="boldtitle">Specifications and test methods</span>
             </p>
             <clause id="_" displayorder="3">
                <title id="_">Clause 1</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 1</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
             </clause>
          </sections>
       </iso-standard>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml.at("//xmlns:localized-strings")&.remove
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
