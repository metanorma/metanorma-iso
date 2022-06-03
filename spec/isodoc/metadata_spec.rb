require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc::Iso::Metadata do
  it "processes IsoXML metadata" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~"INPUT", "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
          <title format="text/plain" language="en" type="title-intro">Cereals and pulses</title>
          <title format="text/plain" language="en" type="title-main">Specifications and test methods</title>
          <title format="text/plain" language="en" type="title-part">Rice</title>
          <title format="text/plain" language="fr" type="title-intro">Céréales et légumineuses</title>
          <title format="text/plain" language="fr" type="title-main">Spécification et méthodes d'essai</title>
          <title format="text/plain" language="fr" type="title-part">Riz</title>
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
            <editorialgroup>
              <technical-committee number="34">Food products</technical-committee>
              <subcommittee number="4">Cereals and pulses</subcommittee>
              <workgroup number="3">Rice Group</workgroup>
              <secretariat>GB</secretariat>
            </editorialgroup>
            <approvalgroup>
              <technical-committee number="34a">Food products A</technical-committee>
              <subcommittee number="4a">Cereals and pulses A</subcommittee>
              <workgroup number="3a">Rice Group A</workgroup>
            </approvalgroup>
            <structuredidentifier>
              <project-number part="1">ISO/PreCD3 17301</project-number>
            </structuredidentifier>
            <stagename>Committee draft</stagename>
          </ext>
        </bibdata>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      {:accesseddate=>"2012",
      :activateddate=>"2013",
      :agency=>"ISO",
      :approvalgroup=>["TC 34a", "SC 4a", "WG 3a"],
      :createddate=>"2010&#x2013;2011",
      :docnumber=>"ISO/PreCD3 17301-1",
      :docnumber_lang=>"ISO/PreCD3 17301-1 (E)",
      :docnumber_reference=>"ISO/PreCD3 17301-1:2000 (E)",
      :docnumeric=>"1730",
      :docsubtitle=>"C&#xe9;r&#xe9;ales et l&#xe9;gumineuses&#xa0;&#x2014; Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai&#xa0;&#x2014; Partie&#xa0;1: Riz",
      :docsubtitleintro=>"C&#xe9;r&#xe9;ales et l&#xe9;gumineuses",
      :docsubtitlemain=>"Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai",
      :docsubtitlepart=>"Riz",
      :docsubtitlepartlabel=>"Partie&#xa0;1",
      :doctitle=>"Cereals and pulses&#xa0;&#x2014; Specifications and test methods&#xa0;&#x2014; Part&#xa0;1: Rice",
      :doctitleintro=>"Cereals and pulses",
      :doctitlemain=>"Specifications and test methods",
      :doctitlepart=>"Rice",
      :doctitlepartlabel=>"Part&#xa0;1",
      :doctype=>"International Standard",
      :doctype_display=>"International Standard",
      :docyear=>"2016",
      :draft=>"0.4",
      :draftinfo=>" (draft 0.4, 2016-05-01)",
      :edition=>"2",
      :editorialgroup=>["TC 34", "SC 4", "WG 3"],
      :horizontal=>"true",
      :keywords=>["kw2", "kw1"],
      :lang=>"en",
      :obsoleteddate=>"2014",
      :publisheddate=>"2011",
      :publisher=>"International Organization for Standardization",
      :revdate=>"2016-05-01",
      :revdate_monthyear=>"May 2016",
      :sc=>"SC 4",
      :script=>"Latn",
      :secretariat=>"GB",
      :stage=>"30",
      :stage_int=>30,
      :stageabbr=>"CD",
      :statusabbr=>"PreCD3",
      :substage_int=>"92",
      :tc=>"TC 34",
      :tc_docnumber=>["17301", "17302"],
      :unpublished=>true,
      :wg=>"WG 3"}
    OUTPUT
    expect(metadata(c.info(Nokogiri::XML(input),
                           nil))).to be_equivalent_to output
  end

  it "processes IsoXML metadata #2" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~"INPUT", "test", false)
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
              <subcommittee number="4" type="DEF">Cereals and pulses</subcommittee>
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
    output = <<~OUTPUT
      {:agency=>"ISO/IEC",
      :approvalgroup=>["ABC 34", "DEF 4", "GHI 3"],
      :docnumber=>"ISO/IEC/CD 17301-1-3",
      :docnumber_lang=>"ISO/IEC/CD 17301-1-3 (E)",
      :docnumber_reference=>"ISO/IEC/CD 17301-1-3 (E)",
      :docsubtitlepartlabel=>"Partie&#xa0;1&#x2013;3",
      :doctitle=>"Cereals and pulses&#xa0;&#x2014; Specifications and test methods&#xa0;&#x2014; Part&#xa0;1&#x2013;3: Rice",
      :doctitleintro=>"Cereals and pulses",
      :doctitlemain=>"Specifications and test methods",
      :doctitlepart=>"Rice",
      :doctitlepartlabel=>"Part&#xa0;1&#x2013;3",
      :doctype=>"International Standard",
      :doctype_display=>"International Standard",
      :docyear=>"2016",
      :editorialgroup=>["ABC 34", "DEF 4", "GHI 3"],
      :ics=>"1.2.3, 1.2.3",
      :lang=>"en",
      :obsoletes=>"IEC 8121",
      :obsoletes_part=>"3.1",
      :publisher=>"International Organization for Standardization and International Electrotechnical Commission",
      :sc=>"DEF 4",
      :script=>"Latn",
      :stage=>"60",
      :stage_int=>60,
      :statusabbr=>"IS",
      :substage_int=>"92",
      :tc=>"ABC 34",
      :tc_docnumber=>["17301"],
      :unpublished=>false,
      :wg=>"GHI 3"}
    OUTPUT
    expect(metadata(c.info(Nokogiri::XML(input),
                           nil))).to be_equivalent_to output
  end

  it "processes IsoXML metadata in French" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~"INPUT", "test", false)
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
            <title type="title-intro" language="fr" format="text/plain">Céréales et légumineuses</title>
            <title type="title-main" language="fr" format="text/plain">Spécification et méthodes d'essai</title>
            <title type="title-part" language="fr" format="text/plain">Riz</title>
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
    output = <<~OUTPUT
      {:agency=>"ISO/IEC",
      :docnumber=>"ISO/IEC/CD 17301-1-3",
      :docnumber_lang=>"ISO/IEC/CD 17301-1-3 (E)",
      :docnumber_reference=>"ISO/IEC/CD 17301-1-3 (E)",
      :docsubtitle=>"Cereals and pulses&#xa0;&#x2014; Specifications and test methods&#xa0;&#x2014; Part&#xa0;1&#x2013;3: Rice",
      :docsubtitleintro=>"Cereals and pulses",
      :docsubtitlemain=>"Specifications and test methods",
      :docsubtitlepart=>"Rice",
      :docsubtitlepartlabel=>"Part&#xa0;1&#x2013;3",
      :doctitle=>"C&#xe9;r&#xe9;ales et l&#xe9;gumineuses&#xa0;&#x2014; Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai&#xa0;&#x2014; Partie&#xa0;1&#x2013;3: Riz",
      :doctitleintro=>"C&#xe9;r&#xe9;ales et l&#xe9;gumineuses",
      :doctitlemain=>"Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai",
      :doctitlepart=>"Riz",
      :doctitlepartlabel=>"Partie&#xa0;1&#x2013;3",
      :doctype=>"International Standard",
      :doctype_display=>"Standard International",
      :docyear=>"2016",
      :editorialgroup=>["ABC 34", "DEF 4", "GHI 3"],
      :ics=>"1.2.3, 1.2.3",
      :lang=>"fr",
      :obsoletes=>"IEC 8121",
      :obsoletes_part=>"3.1",
      :publisher=>"International Organization for Standardization et International Electrotechnical Commission",
      :sc=>"DEF 4",
      :script=>"Latn",
      :stage=>"60",
      :stage_int=>60,
      :statusabbr=>"IS",
      :substage_int=>"92",
      :tc=>"ABC 34",
      :tc_docnumber=>["17301"],
      :unpublished=>false,
      :wg=>"GHI 3"}
    OUTPUT
    expect(metadata(c.info(Nokogiri::XML(input),
                           nil))).to be_equivalent_to output
  end

  it "processes IsoXML metadata in Russian" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~"INPUT", "test", false)
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
            <title type="title-intro" language="fr" format="text/plain">Céréales et légumineuses</title>
            <title type="title-main" language="fr" format="text/plain">Spécification et méthodes d'essai</title>
            <title type="title-part" language="fr" format="text/plain">Riz</title>
            <title type="title-intro" language="ru" format="text/plain">Зерновые и бобовые</title>
            <title type="title-main" language="ru" format="text/plain">Технические характеристики и методы испытаний</title>
            <title type="title-part" language="ru" format="text/plain">Рис</title>
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
    output = <<~OUTPUT
      {:agency=>"ISO/IEC",
      :docnumber=>"ISO/IEC/CD 17301-1-3",
      :docnumber_lang=>"ISO/IEC/CD 17301-1-3 (E)",
      :docnumber_reference=>"ISO/IEC/CD 17301-1-3 (E)",
      :docsubtitle=>"Cereals and pulses&#xa0;&#x2014; Specifications and test methods&#xa0;&#x2014; Part&#xa0;1&#x2013;3: Rice",
      :docsubtitleintro=>"Cereals and pulses",
      :docsubtitlemain=>"Specifications and test methods",
      :docsubtitlepart=>"Rice",
      :docsubtitlepartlabel=>"Part&#xa0;1&#x2013;3",
      :doctitle=>"&#x417;&#x435;&#x440;&#x43d;&#x43e;&#x432;&#x44b;&#x435; &#x438; &#x431;&#x43e;&#x431;&#x43e;&#x432;&#x44b;&#x435;&#xa0;&#x2014; &#x422;&#x435;&#x445;&#x43d;&#x438;&#x447;&#x435;&#x441;&#x43a;&#x438;&#x435; &#x445;&#x430;&#x440;&#x430;&#x43a;&#x442;&#x435;&#x440;&#x438;&#x441;&#x442;&#x438;&#x43a;&#x438; &#x438; &#x43c;&#x435;&#x442;&#x43e;&#x434;&#x44b; &#x438;&#x441;&#x43f;&#x44b;&#x442;&#x430;&#x43d;&#x438;&#x439;&#xa0;&#x2014; Часть&#xa0;1&#x2013;3: &#x420;&#x438;&#x441;",
      :doctitleintro=>"&#x417;&#x435;&#x440;&#x43d;&#x43e;&#x432;&#x44b;&#x435; &#x438; &#x431;&#x43e;&#x431;&#x43e;&#x432;&#x44b;&#x435;",
      :doctitlemain=>"&#x422;&#x435;&#x445;&#x43d;&#x438;&#x447;&#x435;&#x441;&#x43a;&#x438;&#x435; &#x445;&#x430;&#x440;&#x430;&#x43a;&#x442;&#x435;&#x440;&#x438;&#x441;&#x442;&#x438;&#x43a;&#x438; &#x438; &#x43c;&#x435;&#x442;&#x43e;&#x434;&#x44b; &#x438;&#x441;&#x43f;&#x44b;&#x442;&#x430;&#x43d;&#x438;&#x439;",
      :doctitlepart=>"&#x420;&#x438;&#x441;",
      :doctitlepartlabel=>"Часть&#xa0;1&#x2013;3",
      :doctype=>"International Standard",
      :doctype_display=>"International Standard",
      :docyear=>"2016",
      :editorialgroup=>["ABC 34", "DEF 4", "GHI 3"],
      :ics=>"1.2.3, 1.2.3",
      :lang=>"ru",
      :obsoletes=>"IEC 8121",
      :obsoletes_part=>"3.1",
      :publisher=>"International Organization for Standardization &#x438; International Electrotechnical Commission",
      :sc=>"DEF 4",
      :script=>"Latn",
      :stage=>"60",
      :stage_int=>60,
      :statusabbr=>"IS",
      :substage_int=>"92",
      :tc=>"ABC 34",
      :tc_docnumber=>["17301"],
      :unpublished=>false,
      :wg=>"GHI 3"}
    OUTPUT
    expect(metadata(c.info(Nokogiri::XML(input),
                           nil))).to be_equivalent_to output
  end

  it "warns of missing Secretariat" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
              <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
              <status><stage abbreviation="CD">30</stage></status>
              <date type="published">2000</date>
              <ext>
                <editorialgroup>
                </editorialgroup>
              </ext>
          </bibdata>
          <sections>
            <clause>
              <title>Clause 1</title>
            </clause>
          </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <sections>
        <clause displayorder="1">
          <title depth="1">
            <review date="2022-06-03" reviewer="Metanorma" id="_">
              <p>
                <strong>
                  Metadata warnings:
                  <strong/>
                  <p>Secretariat is missing.</p>
                </strong>
              </p>
            </review>
            Clause 1
          </title>
        </clause>
      </sections>
    OUTPUT
    expect(strip_guid(xmlpp(Nokogiri::XML(
      IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true),
    )
  .at("//xmlns:sections")
      .to_xml)))
      .to be_equivalent_to xmlpp(output)
  end

  it "warns of missing publication date" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
              <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
              <status><stage abbreviation="CD">30</stage></status>
              <ext>
                <editorialgroup>
                </editorialgroup>
                <secretariat>BSI</secretariat>
              </ext>
          </bibdata>
          <sections>
            <clause>
              <title>Clause 1</title>
            </clause>
          </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <sections>
        <clause displayorder="1">
          <title depth="1">
            <review date="2022-06-03" reviewer="Metanorma" id="_">
              <p>
                <strong>
                  Metadata warnings:
                  <strong/>
                  <p>Document date is missing.</p>
                </strong>
              </p>
            </review>
            Clause 1
          </title>
        </clause>
      </sections>
    OUTPUT
    expect(strip_guid(xmlpp(Nokogiri::XML(
      IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true),
    )
  .at("//xmlns:sections")
      .to_xml)))
      .to be_equivalent_to xmlpp(output)
  end

  it "warns of missing editorial groups" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
              <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
              <status><stage abbreviation="CD">30</stage></status>
              <date type="published">2000</date>
              <ext>
                <secretariat>BSI</secretariat>
              </ext>
          </bibdata>
          <sections>
            <clause>
              <title>Clause 1</title>
            </clause>
          </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <sections>
        <clause displayorder="1">
          <title depth="1">
            <review date="2022-06-03" reviewer="Metanorma" id="_">
              <p>
                <strong>
                  Metadata warnings:
                  <strong/>
                  <p>Editorial groups are missing.</p>
                </strong>
              </p>
            </review>
            Clause 1
          </title>
        </clause>
      </sections>
    OUTPUT
    expect(strip_guid(xmlpp(Nokogiri::XML(
      IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true),
    )
  .at("//xmlns:sections")
      .to_xml)))
      .to be_equivalent_to xmlpp(output)
  end

  it "does not warn of missing metadata in compliant document" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
              <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
              <status><stage abbreviation="CD">30</stage></status>
              <date type="published">2000</date>
              <ext>
                <editorialgroup>
                </editorialgroup>
                <secretariat>BSI</secretariat>
                </ext>
          </bibdata>
          <sections>
            <clause>
              <title>Clause 1</title>
            </clause>
          </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <sections>
        <clause displayorder='1'>
          <title depth='1'>Clause 1</title>
        </clause>
      </sections>
    OUTPUT
    expect(strip_guid(xmlpp(Nokogiri::XML(
      IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true),
    )
      .at("//xmlns:sections").to_xml)))
      .to be_equivalent_to xmlpp(output)
  end

  it "does not warn of missing metadata in published document" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
              <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
              <status><stage abbreviation="CD">90</stage></status>
              <ext>
                <editorialgroup>
                </editorialgroup>
                <secretariat>BSI</secretariat>
              </ext>
          </bibdata>
          <sections>
            <clause>
              <title>Clause 1</title>
            </clause>
          </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <sections>
        <clause displayorder='1'>
          <title depth='1'>Clause 1</title>
        </clause>
      </sections>
    OUTPUT
    expect(strip_guid(xmlpp(Nokogiri::XML(
      IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true),
    )
  .at("//xmlns:sections").to_xml)))
      .to be_equivalent_to xmlpp(output)
  end
end
