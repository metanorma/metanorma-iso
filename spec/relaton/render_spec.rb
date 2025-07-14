# encoding: utf-8

require "spec_helper"

RSpec.describe Relaton::Render::Iso do
  it "returns formattedref" do
    input = <<~INPUT
      <bibitem type="book">
      <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. https://doi.org/10.1017/9781108877831. 1 vol.</formattedref>
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN">9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Aluffi</surname><forename>Paolo</forename></name>
          </person>
        </contributor>
                <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Anderson</surname><forename>David</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam</forename></name>
          </person>
        </contributor>
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <number>472</number>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="volume">1</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, P., D. ANDERSON, M. HERING, M. MUSTAŢĂ and S. PAYNE. (eds.) <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. First edition. (London Mathematical Society Lecture Note Series 472). Cambridge, UK: Cambridge University Press. 2022. 1 vol.</formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
    expect(p.render(input, embedded: false))
      .to be_equivalent_to output
    expect(p.render(input, embedded: true))
      .to be_equivalent_to output.gsub("<formattedref>", "")
        .gsub("</formattedref>", "")
  end

  it "renders book, five editors with generic class" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN">9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Aluffi</surname><forename>Paolo</forename></name>
          </person>
        </contributor>
                <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Anderson</surname><forename>David</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam</forename></name>
          </person>
        </contributor>
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <number>472</number>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
              </organization>
            </contributor>
          <size><value type="volume">1</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, P., D. ANDERSON, M. HERING, M. MUSTAŢĂ and S. PAYNE. (eds.) <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. First edition. (London Mathematical Society Lecture Note Series 472). Cambridge University Press. 2022. 1 vol.</formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders book, five editors with specific class, broken down place" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN">9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Aluffi</surname><forename>Paolo</forename></name>
          </person>
        </contributor>
                <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Anderson</surname><forename>David</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam</forename></name>
          </person>
        </contributor>
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <number>472</number>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
              </organization>
            </contributor>
            <place><city>Cambridge</city>
            <region>Cambridgeshire</region>
            <country>UK</country>
            </place>
          <size><value type="volume">1</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, P., D. ANDERSON, M. HERING, M. MUSTAŢĂ and S. PAYNE. (eds.) <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. First edition. (London Mathematical Society Lecture Note Series 472). Cambridge, Cambridgeshire, UK: Cambridge University Press. 2022. 1 vol.</formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors" do
    input = <<~INPUT
          <bibitem type="incollection">
        <title>Object play in great apes: Studies in nature and captivity</title>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2019-09-03</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name>
              <surname>Ramsey</surname>
              <formatted-initials>J. K.</formatted-initials>
            </name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name>
              <surname>McGrew</surname>
              <formatted-initials>W. C.</formatted-initials>
            </name>
          </person>
        </contributor>
        <relation type="includedIn">
          <bibitem>
            <title>The nature of play: Great apes and humans</title>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Pellegrini</surname>
                  <forename initial="A">Anthony</forename>
                  <forename initial="D"/>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Smith</surname>
                  <forename initial="P">Peter</forename>
                  <forename initial="K">Kenneth</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Guilford Press</name>
              </organization>
            </contributor>
            <edition>3</edition>
            <medium>
              <form>electronic resource</form>
              <size>8vo</size>
            </medium>
            <place>New York, NY</place>
          </bibitem>
        </relation>
        <extent>
         <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
          </locality>
        </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. and W. C. MCGREW. Object play in great apes: Studies in nature and captivity. <em>The nature of play: Great apes and humans</em> (eds. Pellegrini, A. D. and P. K. Smith). Third edition. New York, NY: Guilford Press. 2005. pp. 89–112. [viewed: September 3, 2019].</formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders journal" do
    input = <<~INPUT
      <bibitem type="journal">
        <title>Nature</title>
        <date type="published"><from>2005</from><to>2009</to></date>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref><em>Nature</em>. 2005–2009.</formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders article" do
    input = <<~INPUT
      <bibitem type="article">
              <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN">9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Aluffi</surname><forename>Paolo</forename></name>
          </person>
        </contributor>
                <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Anderson</surname><forename>David</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam</forename></name>
          </person>
        </contributor>
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <number>472</number>
        <partnumber>472</partnumber>
        <run>N.S.</run>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
            <extent>
                <localityStack>
                  <locality type="volume"><referenceFrom>1</referenceFrom></locality>
                  <locality type="issue"><referenceFrom>7</referenceFrom></locality>
        <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
        </locality>
                </localityStack>
            </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, P., D. ANDERSON, M. HERING, M. MUSTAŢĂ and S. PAYNE. (eds.) Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. <em>London Mathematical Society Lecture Note Series</em> (N.S.). 2022, vol. 1 no. 7, pp. 89–112.</formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders software" do
      input = <<~INPUT
        <bibitem type="software">
          <title>metanorma-standoc</title>
          <uri>https://github.com/metanorma/metanorma-standoc</uri>
          <date type="published"><on>2019-09-04</on></date>
          <contributor>
            <role type="author"/>
            <organization>
              <name>Ribose Inc.</name>
            </organization>
          </contributor>
          <contributor>
            <role type="distributor"/>
            <organization>
              <name>GitHub</name>
            </organization>
          </contributor>
          <edition>1.3.1</edition>
        </bibitem>
      INPUT
      output = <<~OUTPUT
        <formattedref>RIBOSE INC. <em>metanorma-standoc</em>. Version 1.3.1. 2019. Available from: <span class='biburl'><link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link></span>.</formattedref>
      OUTPUT
      p = renderer
      expect(p.render(input))
        .to be_equivalent_to output
  end

  it "renders home standard" do
    input = <<~INPUT
      <bibitem type="standard" schema-version="v1.2.1">
              <fetched>2022-12-22</fetched>
        <title type="title-intro" format="text/plain" language="en" script="Latn">Latex, rubber</title>
        <title type="title-main" format="text/plain" language="en" script="Latn">Determination of total solids content</title>
        <title type="main" format="text/plain" language="en" script="Latn">Latex, rubber - Determination of total solids content</title>
        <title type="title-intro" format="text/plain" language="fr" script="Latn">Latex de caoutchouc</title>
        <title type="title-main" format="text/plain" language="fr" script="Latn">Détermination des matières solides totales</title>
        <title type="main" format="text/plain" language="fr" script="Latn">Latex de caoutchouc - Détermination des matières solides totales</title>
        <uri type="src">https://www.iso.org/standard/61884.html</uri>
        <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:61884:en</uri>
        <uri type="rss">https://www.iso.org/contents/data/standard/06/18/61884.detail.rss</uri>
        <docidentifier type="ISO" primary="true">ISO 124</docidentifier>
        <docidentifier type="URN">urn:iso:std:iso:124:ed-7</docidentifier>
        <docnumber>124</docnumber>
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
        <status>
          <stage>90</stage>
          <substage>93</substage>
        </status>
        <copyright>
          <from>2014</from>
          <owner>
            <organization>
              <name>ISO</name>
            </organization>
          </owner>
        </copyright>
        <relation type="obsoletes">
          <bibitem type="standard">
            <formattedref format="text/plain">ISO 124:2011</formattedref>
            <docidentifier type="ISO" primary="true">ISO 124:2011</docidentifier>
          </bibitem>
        </relation>
        <place>Geneva</place>
        <ext schema-version="v1.0.0">
          <doctype>international-standard</doctype>
          <editorialgroup>
            <technical-committee number="45" type="TC">Raw materials (including latex) for use in the rubber industry</technical-committee>
          </editorialgroup>
          <ics>
            <code>83.040.10</code>
            <text>Latex and raw rubber</text>
          </ics>
          <structuredidentifier type="ISO">
            <project-number>ISO 124</project-number>
          </structuredidentifier>
        </ext>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref><em><span class='stddocTitle'>Latex, rubber - Determination of total solids content</span></em></formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders external standard, IETF" do
    input = <<~INPUT
      <bibitem type="standard">
        <fetched>2022-12-22</fetched>
        <title type="main" format="text/plain">Intellectual Property Rights in IETF Technology</title>
        <uri type="src">https://www.rfc-editor.org/info/rfc3979</uri>
        <docidentifier type="IETF" primary="true">RFC 3979</docidentifier>
        <docidentifier type="DOI">10.17487/RFC3979</docidentifier>
        <docnumber>RFC3979</docnumber>
        <date type="published">
          <on>2005-03</on>
        </date>
        <contributor>
          <role type="editor"/>
          <person>
            <name>
              <completename language="en" script="Latn">S. Bradner</completename>
            </name>
          </person>
        </contributor>
        <contributor>
          <role type="authorizer"/>
          <organization>
            <name>RFC Series</name>
          </organization>
        </contributor>
        <language>en</language>
        <script>Latn</script>
        <abstract format="text/html" language="en" script="Latn">
          <p>The IETF policies about Intellectual Property Rights (IPR), such as patent rights, relative to technologies developed in the IETF are designed to ensure that IETF working groups and participants have as much information about any IPR constraints on a technical proposal as possible.  The policies are also intended to benefit the Internet community and the public at large, while respecting the legitimate rights of IPR holders.  This memo details the IETF policies concerning IPR related to technology worked on within the IETF.  It also describes the objectives that the policies are designed to meet.  This memo updates RFC 2026 and, with RFC 3978, replaces Section 10 of RFC 2026.  This memo also updates paragraph 4 of Section 3.2 of RFC 2028, for all purposes, including reference [2] in RFC 2418.  This document specifies an Internet Best Current Practices for the Internet Community, and requests discussion and suggestions for improvements.</p>
        </abstract>
        <relation type="obsoletedBy">
          <bibitem>
            <formattedref format="text/plain">RFC8179</formattedref>
            <docidentifier type="IETF" primary="true">RFC8179</docidentifier>
          </bibitem>
        </relation>
        <relation type="updates">
          <bibitem>
            <formattedref format="text/plain">RFC2026</formattedref>
            <docidentifier type="IETF" primary="true">RFC2026</docidentifier>
          </bibitem>
        </relation>
        <relation type="updates">
          <bibitem>
            <formattedref format="text/plain">RFC2028</formattedref>
            <docidentifier type="IETF" primary="true">RFC2028</docidentifier>
          </bibitem>
        </relation>
        <series>
          <title format="text/plain">RFC</title>
          <number>3979</number>
        </series>
        <keyword>ipr</keyword>
        <keyword>copyright</keyword>
        <ext schema-version="v1.0.0">
          <editorialgroup>
            <committee>ipr</committee>
          </editorialgroup>
        </ext>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>S. BRADNER. <em><span class='stddocTitle'>Intellectual Property Rights in IETF Technology</span></em>. RFC Series. Available from: <span class='biburl'><link target='https://www.rfc-editor.org/info/rfc3979'>https://www.rfc-editor.org/info/rfc3979</link></span>.</formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders external standard, W3C" do
    input = <<~INPUT
      <bibitem type="standard">
        <fetched>2022-12-22</fetched>
        <title format="text/plain">Time Ontology in OWL</title>
        <uri type="src">https://www.w3.org/TR/owl-time/</uri>
        <docidentifier type="W3C" primary="true">W3C owl-time</docidentifier>
        <docnumber>owl-time</docnumber>
        <language>en</language>
        <script>Latn</script>
        <status>
          <stage>recommendation</stage>
        </status>
        <relation type="hasEdition">
          <bibitem>
            <formattedref format="text/plain">W3C REC-owl-time-20171019</formattedref>
            <docidentifier type="W3C" primary="true">W3C REC-owl-time-20171019</docidentifier>
          </bibitem>
        </relation>
        <relation type="instance">
          <bibitem>
            <formattedref format="text/plain">W3C CRD-owl-time-20221115</formattedref>
            <docidentifier type="W3C" primary="true">W3C CRD-owl-time-20221115</docidentifier>
          </bibitem>
        </relation>
        <relation type="hasEdition">
          <bibitem>
            <formattedref format="text/plain">W3C WD-owl-time-20060927</formattedref>
            <docidentifier type="W3C" primary="true">W3C WD-owl-time-20060927</docidentifier>
          </bibitem>
        </relation>
        <relation type="hasEdition">
          <bibitem>
            <formattedref format="text/plain">W3C CR-owl-time-20200326</formattedref>
            <docidentifier type="W3C" primary="true">W3C CR-owl-time-20200326</docidentifier>
          </bibitem>
        </relation>
        <relation type="hasEdition">
          <bibitem>
            <formattedref format="text/plain">W3C WD-owl-time-20160712</formattedref>
            <docidentifier type="W3C" primary="true">W3C WD-owl-time-20160712</docidentifier>
          </bibitem>
        </relation>
        <series>
          <title format="text/plain">W3C REC</title>
          <number>owl-time</number>
        </series>
        <ext schema-version="v1.0.0">
          <doctype>technicalReport</doctype>
        </ext>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref><em><span class='stddocTitle'>Time Ontology in OWL</span></em>. Recommendation. Available from: <span class='biburl'><link target='https://www.w3.org/TR/owl-time/'>https://www.w3.org/TR/owl-time/</link></span>.</formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders dataset" do
    input = <<~INPUT
      <bibitem type="dataset">
        <title>Children of Immigrants. Longitudinal Sudy (CILS) 1991–2006 ICPSR20520</title>
        <uri>https://doi.org/10.3886/ICPSR20520.v2</uri>
        <date type="published"><on>2012-01-23</on></date>
        <date type="accessed"><on>2018-05-06</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Portes</surname><forename>Alejandro</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Rumbaut</surname><forename>Rubén</forename><forename>G.</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="distributor"/>
          <organization>
            <name>Inter-University Consortium for Political and Social Research</name>
          </organization>
        </contributor>
        <edition>2</edition>
        <medium>
          <genre>dataset</genre>
        </medium>
          <size>
            <value type="data">501 GB</value>
          </size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>PORTES, A. and R. G. RUMBAUT. <em>Children of Immigrants. Longitudinal Sudy (CILS) 1991–2006 ICPSR20520</em>. Version 2. Dataset. 2012. Available from: <span class='biburl'><link target='https://doi.org/10.3886/ICPSR20520.v2'>https://doi.org/10.3886/ICPSR20520.v2</link></span>. 501 GB. [viewed: May 6, 2018].</formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders website" do
    input = <<~INPUT
      <bibitem type="website">
        <title>Language Log</title>
        <uri>https://languagelog.ldc.upenn.edu/nll/</uri>
        <date type="published"><from>2003</from></date>
        <date type="accessed"><on>2019-09-03</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Liberman</surname><forename>Mark</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Pullum</surname><forename>Geoffrey</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>University of Pennsylvania</name>
          </organization>
        </contributor>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>LIBERMAN, M. and G. PULLUM. <em><span class='stddocTitle'>Language Log</span></em> [website]. University of Pennsylvania. 2003–. Available from: <span class='biburl'><link target='https://languagelog.ldc.upenn.edu/nll/'>https://languagelog.ldc.upenn.edu/nll/</link></span>. [viewed: September 3, 2019].</formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders unpublished" do
    input = <<~INPUT
      <bibitem type="unpublished">
        <title>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</title>
        <uri>https://eprints.soton.ac.uk/338797/</uri>
        <date type="created"><on>2012</on></date>
        <date type="accessed"><on>2020-06-24</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Jenkins</surname><initials>S.</initials></name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Ruostekoski</surname><forename>Janne</forename></name>
          </person>
        </contributor>
        <medium>
          <genre>preprint</genre>
        </medium>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>JENKINS and J. RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em>. Preprint. 2012. Available from: <span class='biburl'><link target='https://eprints.soton.ac.uk/338797/'>https://eprints.soton.ac.uk/338797/</link></span>. [viewed: June 24, 2020].</formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders month-year dates" do
    input = <<~INPUT
      <bibitem type="unpublished">
        <title>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</title>
        <uri>https://eprints.soton.ac.uk/338797/</uri>
        <date type="published"><on>2020-06</on></date>
        <date type="accessed"><on>2020-06</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Jenkins</surname><initials>S.</initials></name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Ruostekoski</surname><forename>Janne</forename></name>
          </person>
        </contributor>
        <medium>
          <genre>preprint</genre>
        </medium>
      </bibitem>
    INPUT
    output = <<~OUTPUT
    <formattedref>JENKINS and J. RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em>. Preprint. 2020. Available from: <span class='biburl'><link target='https://eprints.soton.ac.uk/338797/'>https://eprints.soton.ac.uk/338797/</link></span>. [viewed: June 2020].</formattedref>
    OUTPUT
    p = renderer
    expect(p.render(input))
      .to be_equivalent_to output
  end

  private

  def renderer
    Relaton::Render::Iso::General
      .new("language" => "en", "script" => "Latn",
           "i18nhash" => IsoDoc::Iso::PresentationXMLConvert.new({})
      .i18n_init("en", "Latn", nil).get)
  end
end
