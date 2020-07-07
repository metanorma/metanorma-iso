require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references notes in amendments" do
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata> <ext> <doctype>amendment</doctype> </ext> </bibdata>
    <preface>
    <foreword>
    <p>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
    <note id="N">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
<p><xref target="N"/></p>

    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <note id="note1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    <note id="note2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
</note>
<p>    <xref target="note1"/> <xref target="note2"/> </p>

    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    <note id="AN">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </clause>
    <clause id="annex1b">
    <note id="Anote1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    <note id="Anote2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </clause>
    </annex>
    </iso-standard>
    INPUT
     <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <bibdata>
    <ext>
      <doctype>amendment</doctype>
    </ext>
  </bibdata>
  <preface>
    <foreword>
      <p>
        <xref target='N'>[N]</xref>
<xref target='note1'>[note1]</xref>
<xref target='note2'>[note2]</xref>
<xref target='AN'>A.1, Note</xref>
<xref target='Anote1'>A.2, Note 1</xref>
<xref target='Anote2'>A.2, Note 2</xref>
      </p>
    </foreword>
  </preface>
  <sections>
    <clause id='scope'>
      <title depth="1">Scope</title>
      <note id='N'>
        <name>NOTE</name>
        <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
          These results are based on a study carried out on three different
          types of kernel.
        </p>
      </note>
      <p>
       <xref target='N'>[n]</xref>
      </p>
    </clause>
    <terms id='terms'/>
    <clause id='widgets'>
      <title depth="1">Widgets</title>
      <clause id='widgets1' inline-header="true">
        <note id='note1'>
          <name>NOTE</name>
          <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
            These results are based on a study carried out on three different
            types of kernel.
          </p>
        </note>
        <note id='note2'>
          <name>NOTE</name>
          <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a'>
            These results are based on a study carried out on three different
            types of kernel.
          </p>
        </note>
        <p>
        <xref target='note1'>[note1]</xref>
<xref target='note2'>[note2]</xref>
        </p>
      </clause>
    </clause>
  </sections>
  <annex id='annex1'>
  <title>
  <strong>Annex A</strong>
  <br/>
  (informative)
</title>
<clause id='annex1a' inline-header='true'>
<title>A.1</title>
      <note id='AN'>
        <name>NOTE</name>
        <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
          These results are based on a study carried out on three different
          types of kernel.
        </p>
      </note>
    </clause>
    <clause id='annex1b' inline-header="true">
     <title>A.2</title>
      <note id='Anote1'>
        <name>NOTE 1</name>
        <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
          These results are based on a study carried out on three different
          types of kernel.
        </p>
      </note>
      <note id='Anote2'>
        <name>NOTE 2</name>
        <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a'>
          These results are based on a study carried out on three different
          types of kernel.
        </p>
      </note>
    </clause>
  </annex>
</iso-standard>
    OUTPUT
  end

  it "cross-references sections" do
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata> <ext> <doctype>amendment</doctype> </ext> </bibdata>
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble
         <xref target="C"/>
         <xref target="C1"/>
         <xref target="D"/>
         <xref target="H"/>
         <xref target="I"/>
         <xref target="J"/>
         <xref target="K"/>
         <xref target="L"/>
         <xref target="M"/>
         <xref target="N"/>
         <xref target="O"/>
         <xref target="P"/>
         <xref target="Q"/>
         <xref target="Q1"/>
         <xref target="Q2"/>
         <xref target="R"/>
         </p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       <clause id="C1" inline-header="false" obligation="informative">Text</clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
              <appendix id="Q2" inline-header="false" obligation="normative">
         <title>An Appendix</title>
       </appendix>
       </annex><bibliography><references id="R" obligation="informative" normative="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
    <?xml version='1.0'?>
       <iso-standard xmlns='http://riboseinc.com/isoxml'>
         <bibdata>
           <ext>
             <doctype>amendment</doctype>
           </ext>
         </bibdata>
         <preface>
           <foreword obligation='informative'>
             <title>Foreword</title>
             <p id='A'>
               This is a preamble
               <xref target='C'>[C]</xref>
               <xref target='C1'>[C1]</xref>
               <xref target='D'>[D]</xref>
               <xref target='H'>[H]</xref>
               <xref target='I'>[I]</xref>
               <xref target='J'>[J]</xref>
               <xref target='K'>[K]</xref>
               <xref target='L'>[L]</xref>
               <xref target='M'>[M]</xref>
               <xref target='N'>[N]</xref>
               <xref target='O'>[O]</xref>
               <xref target='P'>Annex A</xref>
               <xref target='Q'>A.1</xref>
               <xref target='Q1'>A.1.1</xref>
               <xref target='Q2'>Annex A, Appendix 1</xref>
               <xref target='R'>[R]</xref>
             </p>
           </foreword>
           <introduction id='B' obligation='informative'>
             <title depth="1">Introduction</title>
             <clause id='C' inline-header='false' obligation='informative'>
               <title depth="1">Introduction Subsection</title>
             </clause>
             <clause id='C1' inline-header='true' obligation='informative'>Text</clause>
           </introduction>
         </preface>
         <sections>
           <clause id='D' obligation='normative' type="scope">
             <title depth="1">Scope</title>
             <p id='E'>Text</p>
           </clause>
           <clause id='M' inline-header='false' obligation='normative'>
             <title depth="1">Clause 4</title>
             <clause id='N' inline-header='false' obligation='normative'>
               <title depth="1">Introduction</title>
             </clause>
             <clause id='O' inline-header='false' obligation='normative'>
               <title depth="1">Clause 4.2</title>
             </clause>
           </clause>
         </sections>
         <annex id='P' inline-header='false' obligation='normative'>
         <title>
  <strong>Annex A</strong>
  <br/>
  (normative)
  <br/>
  <br/>
  <strong>Annex</strong>
</title>
           <clause id='Q' inline-header='false' obligation='normative'>
           <title depth='2'>
  A.1
  <tab/>
  Annex A.1
</title>
             <clause id='Q1' inline-header='false' obligation='normative'>
             <title depth='3'>
  A.1.1
  <tab/>
  Annex A.1a
</title>
             </clause>
           </clause>
           <appendix id='Q2' inline-header='false' obligation='normative'>
           <title depth='2'>
  Appendix 1
  <tab/>
  An Appendix
</title>
           </appendix>
         </annex>
         <bibliography>
           <references id='R' obligation='informative' normative='true'>
             <title depth="1">Normative References</title>
           </references>
           <clause id='S' obligation='informative'>
             <title depth="1">Bibliography</title>
             <references id='T' obligation='informative' normative='false'>
               <title depth="2">Bibliography Subsection</title>
             </references>
           </clause>
         </bibliography>
       </iso-standard>
    OUTPUT
  end

    it "processes section names" do
      input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata> <ext> <doctype>amendment</doctype> </ext> </bibdata>
      <boilerplate>
        <copyright-statement>
        <clause>
          <title>Copyright</title>
        </clause>
        </copyright-statement>
        <license-statement>
        <clause>
          <title>License</title>
        </clause>
        </license-statement>
        <legal-statement>
        <clause>
          <title>Legal</title>
        </clause>
        </legal-statement>
        <feedback-statement>
        <clause>
          <title>Feedback</title>
        </clause>
        </feedback-statement>
      </boilerplate>
      <preface>
      <abstract obligation="informative">
         <title>Foreword</title>
      </abstract>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction>
       <clause id="B1"><title>Dedication</title></clause>
       <clause id="B2"><title>Note to reader</title></clause>
       <acknowledgements obligation="informative">
         <title>Acknowledgements</title>
       </acknowledgements>
        </preface><sections>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause>
       <clause id="O1" inline-header="false" obligation="normative">
       </clause>
        </clause>
<clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>
       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
       </annex>
       <annex id="P1" inline-header="false" obligation="normative">
       </annex>
        <bibliography><references id="R" obligation="informative" normative="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
    <iso-standard xmlns='http://riboseinc.com/isoxml'>
         <bibdata>
           <ext>
             <doctype>amendment</doctype>
           </ext>
         </bibdata>
         <boilerplate>
           <copyright-statement>
             <clause>
               <title>Copyright</title>
             </clause>
           </copyright-statement>
           <license-statement>
             <clause>
               <title>License</title>
             </clause>
           </license-statement>
           <legal-statement>
             <clause>
               <title>Legal</title>
             </clause>
           </legal-statement>
           <feedback-statement>
             <clause>
               <title>Feedback</title>
             </clause>
           </feedback-statement>
         </boilerplate>
         <preface>
           <abstract obligation='informative'>
             <title>Foreword</title>
           </abstract>
           <foreword obligation='informative'>
             <title>Foreword</title>
             <p id='A'>This is a preamble</p>
           </foreword>
           <introduction id='B' obligation='informative'>
             <title depth='1'>Introduction</title>
             <clause id='C' inline-header='false' obligation='informative'>
               <title depth='1'>Introduction Subsection</title>
             </clause>
           </introduction>
           <clause id='B1'>
             <title depth='1'>Dedication</title>
           </clause>
           <clause id='B2'>
             <title depth='1'>Note to reader</title>
           </clause>
           <acknowledgements obligation='informative'>
             <title>Acknowledgements</title>
           </acknowledgements>
         </preface>
         <sections>
           <clause id='M' inline-header='false' obligation='normative'>
             <title depth='1'>Clause 4</title>
             <clause id='N' inline-header='false' obligation='normative'>
               <title depth='1'>Introduction</title>
             </clause>
             <clause id='O' inline-header='false' obligation='normative'>
               <title depth='1'>Clause 4.2</title>
             </clause>
             <clause id='O1' inline-header='true' obligation='normative'> </clause>
           </clause>
            <clause id='D' obligation='normative' type="scope">
             <title depth='1'>Scope</title>
             <p id='E'>Text</p>
           </clause>
         </sections>
         <annex id='P' inline-header='false' obligation='normative'>
           <title>
             <strong>Annex A</strong>
             <br/>
             (normative)
             <br/>
             <br/>
             <strong>Annex</strong>
           </title>
           <clause id='Q' inline-header='false' obligation='normative'>
             <title depth='2'>A.1<tab/>Annex A.1</title>
             <clause id='Q1' inline-header='false' obligation='normative'>
               <title depth='3'>A.1.1<tab/>Annex A.1a</title>
             </clause>
           </clause>
         </annex>
         <annex id='P1' inline-header='false' obligation='normative'>
           <title>
             <strong>Annex B</strong>
             <br/>
             (normative)
           </title>
         </annex>
         <bibliography>
           <references id='R' obligation='informative' normative='true'>
             <title depth='1'>Normative References</title>
           </references>
           <clause id='S' obligation='informative'>
             <title depth='1'>Bibliography</title>
             <references id='T' obligation='informative' normative='false'>
               <title depth='2'>Bibliography Subsection</title>
             </references>
           </clause>
         </bibliography>
       </iso-standard>
       OUTPUT
    html = <<~OUTPUT
    <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
  <head/>
  <body lang='en'>
    <div class='title-section'>
      <p>&#160;</p>
    </div>
    <br/>
    <div class='prefatory-section'>
      <p>&#160;</p>
    </div>
    <br/>
    <div class='main-section'>
      <div class='authority'>
        <div class='boilerplate-copyright'>
          <div>
            <h1>Copyright</h1>
          </div>
        </div>
        <div class='boilerplate-license'>
          <div>
            <h1>License</h1>
          </div>
        </div>
        <div class='boilerplate-legal'>
          <div>
            <h1>Legal</h1>
          </div>
        </div>
        <div class='boilerplate-feedback'>
          <div>
            <h1>Feedback</h1>
          </div>
        </div>
      </div>
      <br/>
      <div>
        <h1 class='AbstractTitle'>Abstract</h1>
      </div>
      <br/>
      <div>
        <h1 class='ForewordTitle'>Foreword</h1>
        <p id='A'>This is a preamble</p>
      </div>
      <br/>
      <div class='Section3' id='B'>
        <h1 class='IntroTitle'>Introduction</h1>
        <div id='C'>
          <h1>Introduction Subsection</h1>
        </div>
      </div>
      <br/>
      <div class='Section3' id='B1'>
        <h1 class='IntroTitle'>Dedication</h1>
      </div>
      <br/>
      <div class='Section3' id='B2'>
        <h1 class='IntroTitle'>Note to reader</h1>
      </div>
      <br/>
      <div class='Section3' id=''>
        <h1 class='IntroTitle'>Acknowledgements</h1>
      </div>
      <p class='zzSTDTitle1'/>
      <div>
        <h1>Normative References</h1>
      </div>
      <div id='M'>
        <h1>Clause 4</h1>
        <div id='N'>
          <h1>Introduction</h1>
        </div>
        <div id='O'>
          <h1>Clause 4.2</h1>
        </div>
        <div id='O1'>
        </div>
      </div>
      <div id='D'>
        <h1>Scope</h1>
        <p id='E'>Text</p>
      </div>
      <br/>
      <div id='P' class='Section3'>
        <h1 class='Annex'>
        <b>Annex A</b>
          <br/>
          (normative)
          <br/>
          <br/>
          <b>Annex</b>
        </h1>
        <div id='Q'>
          <h2>A.1&#160; Annex A.1</h2>
          <div id='Q1'>
            <h3>A.1.1&#160; Annex A.1a</h3>
          </div>
        </div>
      </div>
      <br/>
      <div id='P1' class='Section3'>
        <h1 class='Annex'>
        <b>Annex B</b>
<br/>
(normative)
        </h1>
      </div>
      <br/>
      <div>
        <h1 class='Section3'>Bibliography</h1>
        <div>
          <h2 class='Section3'>Bibliography Subsection</h2>
        </div>
      </div>
    </div>
  </body>
</html>
OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({}).convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    end

     it "processes IsoXML metadata" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    arr = c.convert_init(<<~"INPUT", "test", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
  expect(Hash[c.info(Nokogiri::XML(<<~"INPUT"), nil).sort]).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns='https://www.metanorma.org/ns/iso'>
  <bibdata type='standard'>
    <title language='en' format='text/plain' type='main'>Introduction — Main Title — Title — Title Part  — Mass fraction of
       extraneous matter, milled rice (nonglutinous), sample dividers and
       recommendations relating to storage and transport conditions</title>
    <title language='en' format='text/plain' type='title-intro'>Introduction</title>
    <title language='en' format='text/plain' type='title-main'>Main Title — Title</title>
    <title language='en' format='text/plain' type='title-part'>Title Part</title>
    <title language='en' format='text/plain' type='title-amd'>Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
<title language='fr' format='text/plain' type='main'>
  Introduction Française — Titre Principal — Part du Titre — Fraction
  massique de matière étrangère, riz usiné (non gluant), diviseurs
  d’échantillon et recommandations relatives aux conditions d’entreposage et
  de transport
</title>
    <title language='fr' format='text/plain' type='title-intro'>Introduction Française</title>
    <title language='fr' format='text/plain' type='title-main'>Titre Principal</title>
    <title language='fr' format='text/plain' type='title-part'>Part du Titre</title>
    <title language='fr' format='text/plain' type='title-amd'>Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport</title>
    <docidentifier type='ISO'>ISO/PreNWIP3 17301-1:2016/Amd.1</docidentifier>
    <docidentifier type='iso-with-lang'>ISO/PreNWIP3 17301-1:2016/Amd.1(E)</docidentifier>
    <docidentifier type='iso-reference'>ISO/PreNWIP3 17301-1:2016/Amd.1:2017(E)</docidentifier>
    <docnumber>17301</docnumber>
    <date type='created'>
      <on>2016-05-01</on>
    </date>
    <contributor>
      <role type='author'/>
      <organization>
        <name>International Organization for Standardization</name>
        <abbreviation>ISO</abbreviation>
      </organization>
    </contributor>
    <contributor>
      <role type='publisher'/>
      <organization>
        <name>International Organization for Standardization</name>
        <abbreviation>ISO</abbreviation>
      </organization>
    </contributor>
    <edition>2</edition>
    <version>
      <revision-date>2000-01-01</revision-date>
      <draft>0.3.4</draft>
    </version>
    <language>en</language>
    <script>Latn</script>
    <status>
      <stage abbreviation='NWIP'>10</stage>
      <substage>20</substage>
      <iteration>3</iteration>
    </status>
    <copyright>
      <from>2017</from>
      <owner>
        <organization>
          <name>International Organization for Standardization</name>
          <abbreviation>ISO</abbreviation>
        </organization>
      </owner>
    </copyright>
    <ext>
      <doctype>amendment</doctype>
      <editorialgroup>
        <technical-committee number='1' type='A'>TC</technical-committee>
        <technical-committee number='11' type='A1'>TC1</technical-committee>
        <subcommittee number='2' type='B'>SC</subcommittee>
        <subcommittee number='21' type='B1'>SC1</subcommittee>
        <workgroup number='3' type='C'>WG</workgroup>
        <workgroup number='31' type='C1'>WG1</workgroup>
        <secretariat>SECRETARIAT</secretariat>
      </editorialgroup>
      <ics>
        <code>1</code>
      </ics>
      <ics>
        <code>2</code>
      </ics>
      <ics>
        <code>3</code>
      </ics>
      <structuredidentifier>
        <project-number part='1' amendment='1' corrigendum='2' origyr='2016-05-01'>17301</project-number>
      </structuredidentifier>
      <stagename>New work item proposal</stagename>
      <updates-document-type>international-standard</updates-document-type>
    </ext>
  </bibdata>
  <sections/>
</iso-standard>
INPUT
{:agency=>"ISO",
:authors=>[],
:authors_affiliations=>{},
:createddate=>"2016-05-01",
:docnumber=>"ISO/PreNWIP3 17301-1:2016/Amd.1",
:docnumber_lang=>"ISO/PreNWIP3 17301-1:2016/Amd.1(E)",
:docnumber_reference=>"ISO/PreNWIP3 17301-1:2016/Amd.1:2017(E)",
:docnumeric=>"17301",
:docsubtitle=>"Introduction Fran&#xe7;aise&nbsp;&mdash; Titre Principal&nbsp;&mdash; Partie&nbsp;1: Part du Titre",
:docsubtitleamd=>"Fraction massique de mati&#xe8;re &#xe9;trang&#xe8;re, riz usin&#xe9; (non gluant), diviseurs d&#x2019;&#xe9;chantillon et recommandations relatives aux conditions d&#x2019;entreposage et de transport",
:docsubtitleamdlabel=>"AMENDMENT&nbsp;1",
:docsubtitlecorrlabel=>"RECTIFICATIF TECHNIQUE&nbsp;2",
:docsubtitleintro=>"Introduction Fran&#xe7;aise",
:docsubtitlemain=>"Titre Principal",
:docsubtitlepart=>"Part du Titre",
:docsubtitlepartlabel=>"Partie&nbsp;1",
:doctitle=>"Introduction&nbsp;&mdash; Main Title&#x2009;&#x2014;&#x2009;Title&nbsp;&mdash; Part&nbsp;1: Title Part",
:doctitleamd=>"Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions",
:doctitleamdlabel=>"AMENDMENT&nbsp;1",
:doctitlecorrlabel=>"TECHNICAL CORRIGENDUM&nbsp;2",
:doctitleintro=>"Introduction",
:doctitlemain=>"Main Title&#x2009;&#x2014;&#x2009;Title",
:doctitlepart=>"Title Part",
:doctitlepartlabel=>"Part&nbsp;1",
:doctype=>"Amendment",
:docyear=>"2017",
:draft=>"0.3.4",
:draftinfo=>" (draft 0.3.4, 2000-01-01)",
:edition=>"2",
:editorialgroup=>["A 1", "B 2", "C 3"],
:ics=>"1, 2, 3",
:keywords=>[],
:obsoletes=>nil,
:obsoletes_part=>nil,
:publisher=>"International Organization for Standardization",
:revdate=>"2000-01-01",
:revdate_monthyear=>"January 2000",
:sc=>"B 2",
:secretariat=>"SECRETARIAT",
:stage=>"10",
:stage_int=>10,
:stageabbr=>"NWIP",
:statusabbr=>"PreNWIP3",
:tc=>"A 1",
:tc_docnumber=>[],
:unpublished=>true,
:wg=>"C 3"}
OUTPUT
  end

  it "processes middle title" do
         expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
          <title language='en' format='text/plain' type='title-intro'>Introduction</title>
    <title language='en' format='text/plain' type='title-main'>Main Title — Title</title>
    <title language='en' format='text/plain' type='title-part'>Title Part</title>
    <title language='en' format='text/plain' type='title-amd'>Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
    <ext>
          <structuredidentifier>
        <project-number part='1' amendment='1' corrigendum='2' origyr='2016-05-01'>17301</project-number>
      </structuredidentifier>
</ext>
      </bibdata>
       <sections/>
      </iso-standard>
    INPUT
    #{HTML_HDR}
      <p class='zzSTDTitle1'>Introduction &#8212; Main Title&#8201;&#8212;&#8201;Title &#8212; </p>
      <p class='zzSTDTitle2'>
        Part&#160;1:
        <br/><b>Title Part</b>
      </p>
          <p class='zzSTDTitle2'>
      AMENDMENT&#160;1: Mass fraction of extraneous matter, milled rice
      (nonglutinous), sample dividers and recommendations relating to storage
      and transport conditions
    </p>
    <p class='zzSTDTitle2'>TECHNICAL CORRIGENDUM&#160;2</p>
    </div>
  </body>
</html>
    OUTPUT
      end


end