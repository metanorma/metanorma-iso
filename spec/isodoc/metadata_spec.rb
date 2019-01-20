require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc::Iso::Metadata do
  it "processes IsoXML metadata" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    arr = c.convert_init(<<~"INPUT", "test", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
  expect(Hash[c.info(Nokogiri::XML(<<~"INPUT"), nil).sort]).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata type="international-standard">
  <title>
    <title-intro language="en" format="text/plain">Cereals and pulses</title-intro>
    <title-main language="en" format="text/plain">Specifications and test methods</title-main>
    <title-part language="en" format="text/plain">Rice</title-part>
  </title>
  <title>
    <title-intro language="fr" format="text/plain">Céréales et légumineuses</title-intro>
    <title-main language="fr" format="text/plain">Spécification et méthodes d'essai</title-main>
    <title-part language="fr" format="text/plain">Riz</title-part>
  </title>
  <docidentifier type="iso">ISO/PreCD3 17301-1</docidentifier>
  <docidentifier type="iso-structured">
    <project-number part="1">ISO/PreCD3 17301</project-number>
  </docidentifier>
  <docidentifier type="iso-tc">17301</docidentifier>
  <date type="published"><on>2011</on></date>
  <date type="accessed"><on>2012</on></date>
  <date type="created"><from>2010</from><to>2011</to></date>
  <date type="activated"><on>2013</on></date>
  <date type="obsoleted"><on>2014</on></date>
  <contributor>
    <role type="author"/>
    <organization>
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>30</stage>
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
  <editorialgroup>
    <technical-committee number="34">Food products</technical-committee>
    <subcommittee number="4">Cereals and pulses</subcommittee>
    <workgroup number="3">Rice Group</workgroup>
    <secretariat>GB</secretariat>
  </editorialgroup>
</bibdata><version>
  <edition>2</edition>
  <revision-date>2016-05-01</revision-date>
  <draft>0.4</draft>
</version>
</iso-standard>
INPUT
       {:accesseddate=>"2012", :activateddate=>"2013", :agency=>"ISO", :authors=>[], :authors_affiliations=>{}, :confirmeddate=>"XXX", :createddate=>"2010&ndash;2011", :docnumber=>"ISO/PreCD3 17301-1", :docsubtitle=>"C&#xe9;r&#xe9;ales et l&#xe9;gumineuses&nbsp;&mdash; Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai&nbsp;&mdash; Partie&nbsp;1: Riz", :docsubtitleintro=>"C&#xe9;r&#xe9;ales et l&#xe9;gumineuses", :docsubtitlemain=>"Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai", :docsubtitlepart=>"Partie&nbsp;1: Riz", :doctitle=>"Cereals and pulses&nbsp;&mdash; Specifications and test methods&nbsp;&mdash; Part&nbsp;1: Rice", :doctitleintro=>"Cereals and pulses", :doctitlemain=>"Specifications and test methods", :doctitlepart=>"Part&nbsp;1: Rice", :doctype=>"International Standard", :docyear=>"2016", :draft=>"0.4", :draftinfo=>" (draft 0.4, 2016-05-01)", :editorialgroup=>["TC 34", "SC 4", "WG 3"], :ics=>"XXX", :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"2014", :obsoletes=>nil, :obsoletes_part=>nil, :publisheddate=>"2011", :receiveddate=>"XXX", :revdate=>"2016-05-01", :sc=>"SC 4", :secretariat=>"GB", :stage=>"30", :stage_int=>30, :stageabbr=>"PreCD3", :tc=>"TC 34", :tc_docnumber=>"17301", :unpublished=>true, :updateddate=>"XXX", :wg=>"WG 3"}
OUTPUT
  end

  it "processes IsoXML metadata" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    arr = c.convert_init(<<~"INPUT", "test", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
  expect(Hash[c.info(Nokogiri::XML(<<~"INPUT"), nil).sort]).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata type="international-standard">
  <title>
    <title-intro language="en" format="text/plain">Cereals and pulses</title-intro>
    <title-main language="en" format="text/plain">Specifications and test methods</title-main>
    <title-part language="en" format="text/plain">Rice</title-part>
  </title>
  <title>
    <title-intro language="fr" format="text/plain">Céréales et légumineuses</title-intro>
    <title-main language="fr" format="text/plain">Spécification et méthodes d'essai</title-main>
    <title-part language="fr" format="text/plain">Riz</title-part>
  </title>
  <docidentifier type="iso">ISO/IEC/CD 17301-1-3</docidentifier>
    <docidentifier type="iso-structured">
    <project-number part="1" subpart="3">ISO/IEC/CD 17301</project-number>
  </docidentifier>
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
      <abbreviation>ISO</abbreviation>
     </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>IEC</abbreviation>
    </organization>
  </contributor>
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>60</stage>
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
  <editorialgroup>
    <technical-committee number="34" type="ABC">Food products</technical-committee>
    <subcommittee number="4" type="DEF">Cereals and pulses</subcommittee>
    <workgroup number="3" type="GHI">Rice Group</workgroup>
  </editorialgroup>
  <ics><code>1.2.3</code></ics>
  <ics><code>1.2.3</code></ics>
</bibdata><version>
  <edition>2</edition>
  <revision-date>2016-05-01</revision-date>
  <draft>12</draft>
</version>
</iso-standard>
INPUT
{:accesseddate=>"XXX", :agency=>"ISO/IEC", :authors=>[], :authors_affiliations=>{}, :confirmeddate=>"XXX", :createddate=>"XXX", :docnumber=>"ISO/IEC/CD 17301-1-3", :docsubtitle=>"C&#xe9;r&#xe9;ales et l&#xe9;gumineuses&nbsp;&mdash; Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai&nbsp;&mdash; Partie&nbsp;1&ndash;3: Riz", :docsubtitleintro=>"C&#xe9;r&#xe9;ales et l&#xe9;gumineuses", :docsubtitlemain=>"Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai", :docsubtitlepart=>"Partie&nbsp;1&ndash;3: Riz", :doctitle=>"Cereals and pulses&nbsp;&mdash; Specifications and test methods&nbsp;&mdash; Part&nbsp;1&ndash;3: Rice", :doctitleintro=>"Cereals and pulses", :doctitlemain=>"Specifications and test methods", :doctitlepart=>"Part&nbsp;1&ndash;3: Rice", :doctype=>"International Standard", :docyear=>"2016", :draft=>"12", :draftinfo=>" (draft 12, 2016-05-01)", :editorialgroup=>["ABC 34", "DEF 4", "GHI 3"], :ics=>"1.2.3, 1.2.3", :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :obsoletes=>"IEC 8121", :obsoletes_part=>"3.1", :publisheddate=>"XXX", :receiveddate=>"XXX", :revdate=>"2016-05-01", :sc=>"DEF 4", :secretariat=>"XXXX", :stage=>"60", :stage_int=>60, :stageabbr=>"IS", :tc=>"ABC 34", :tc_docnumber=>"17301", :unpublished=>false, :updateddate=>"XXX", :wg=>"GHI 3"}
OUTPUT
  end

end
