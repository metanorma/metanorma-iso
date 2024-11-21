require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references notes in amendments" do
    output = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", <<~INPUT, true)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <ext>
              <doctype>amendment</doctype>
            </ext>
          </bibdata>
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
            <clause id="scope">
              <title>Scope</title>
              <note id="N">
                <p>These results are based on a study carried out on three different types of kernel.</p>
              </note>
              <p>
                <xref target="N"/>
              </p>
            </clause>
            <terms id="terms"/>
            <clause id="widgets">
              <title>Widgets</title>
              <clause id="widgets1">
                <note id="note1">
                  <p>These results are based on a study carried out on three different types of kernel.</p>
                </note>
                <note id="note2">
                  <p>These results are based on a study carried out on three different types of kernel.</p>
                </note>
                <p>
                  <xref target="note1"/>
                  <xref target="note2"/>
                </p>
              </clause>
            </clause>
          </sections>
          <annex id="annex1">
            <clause id="annex1a">
              <note id="AN">
                <p>These results are based on a study carried out on three different types of kernel.</p>
              </note>
            </clause>
            <clause id="annex1b">
              <note id="Anote1">
                <p>These results are based on a study carried out on three different types of kernel.</p>
              </note>
              <note id="Anote2">
                <p>These results are based on a study carried out on three different types of kernel.</p>
              </note>
            </clause>
          </annex>
        </iso-standard>
      INPUT
    xml = Nokogiri::XML(output)
    xml = xml.at("//xmlns:foreword")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
        <foreword displayorder="1">
            <title id="_">Foreword</title>
            <fmt-title depth="1">
               <span class="fmt-caption-label">
                  <semx element="title" source="_">Foreword</semx>
               </span>
            </fmt-title>
            <p>
               <xref target="N">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="scope">1</semx>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
               </xref>
               <xref target="note1">
                  <semx element="autonum" source="widgets1">2.1</semx>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note1">1</semx>
               </xref>
               <xref target="note2">
                  <semx element="autonum" source="widgets1">2.1</semx>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="note2">2</semx>
               </xref>
               <xref target="AN">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="annex1a">A.1</semx>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
               </xref>
               <xref target="Anote1">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="annex1b">A.2</semx>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="Anote1">1</semx>
               </xref>
               <xref target="Anote2">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="annex1b">A.2</semx>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Note</span>
                  <semx element="autonum" source="Anote2">2</semx>
               </xref>
            </p>
         </foreword>
      OUTPUT
  end

  it "cross-references sections" do
    output = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", <<~INPUT, true)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <ext>
              <doctype>amendment</doctype>
            </ext>
          </bibdata>
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
                <xref target="R"/></p>
            </foreword>
            <introduction id="B" obligation="informative">
              <title>Introduction</title>
              <clause id="C" inline-header="false" obligation="informative">
                <title>Introduction Subsection</title>
              </clause>
              <clause id="C1" inline-header="false" obligation="informative">Text</clause>
            </introduction>
          </preface>
          <sections>
            <clause id="D" obligation="normative" type="scope">
              <title>Scope</title>
              <p id="E">Text</p>
            </clause>
            <clause id="M" inline-header="false" obligation="normative">
              <title>Clause 4</title>
              <clause id="N" inline-header="false" obligation="normative">
                <title>Introduction</title>
              </clause>
              <clause id="O" inline-header="false" obligation="normative">
                <title>Clause 4.2</title>
              </clause>
            </clause>
          </sections>
          <annex id="P" inline-header="false" obligation="normative">
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
          </annex>
          <bibliography>
            <references id="R" normative="true" obligation="informative">
              <title>Normative References</title>
            </references>
            <clause id="S" obligation="informative">
              <title>Bibliography</title>
              <references id="T" normative="false" obligation="informative">
                <title>Bibliography Subsection</title>
              </references>
            </clause>
          </bibliography>
        </iso-standard>
      INPUT
    xml = Nokogiri::XML(output)
    xml = xml.at("//xmlns:foreword")
    expect(Xml::C14n.format(strip_guid(xml.to_xml))
    .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
        <foreword obligation="informative" displayorder="1">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <span class="fmt-caption-label">
                 <semx element="title" source="_">Foreword</semx>
              </span>
           </fmt-title>
           <p id="A">
              This is a preamble
              <xref target="C">
                 <span class="citesec">
                    <semx element="autonum" source="C">0.1</semx>
                 </span>
              </xref>
              <xref target="C1">
                 <span class="citesec">
                    <semx element="autonum" source="C1">0.2</semx>
                 </span>
              </xref>
              <xref target="D">
                 <span class="citesec">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="D">1</semx>
                 </span>
              </xref>
              <xref target="H">[H]</xref>
              <xref target="I">[I]</xref>
              <xref target="J">[J]</xref>
              <xref target="K">[K]</xref>
              <xref target="L">[L]</xref>
              <xref target="M">
                 <span class="citesec">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="M">2</semx>
                 </span>
              </xref>
              <xref target="N">
                 <span class="citesec">
                    <semx element="autonum" source="N">2.1</semx>
                 </span>
              </xref>
              <xref target="O">
                 <span class="citesec">
                    <semx element="autonum" source="O">2.2</semx>
                 </span>
              </xref>
              <xref target="P">
                 <span class="citeapp">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="P">A</semx>
                 </span>
              </xref>
              <xref target="Q">
                 <span class="citeapp">
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="Q">A.1</semx>
                 </span>
              </xref>
              <xref target="Q1">
                 <span class="citeapp">
                    <semx element="autonum" source="Q1">A.1.1</semx>
                 </span>
              </xref>
              <xref target="Q2">
                 <span class="citeapp">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="P">A</semx>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Appendix</span>
                    <semx element="autonum" source="Q2">1</semx>
                 </span>
              </xref>
              <xref target="R">
                 <span class="citesec">
                    <semx element="references" source="R">Normative References</semx>
                 </span>
              </xref>
           </p>
        </foreword>
      OUTPUT
  end

  it "processes section names" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
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
          <abstract obligation="informative">
            <title>Abstract</title>
          </abstract>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
          </introduction>
          <clause id="B1">
            <title>Dedication</title>
          </clause>
          <clause id="B2">
            <title>Note to reader</title>
          </clause>
          <acknowledgements obligation="informative">
            <title>Acknowledgements</title>
          </acknowledgements>
        </preface>
        <sections>
          <clause id="M" inline-header="false" obligation="normative">
            <title>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title>Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title>Clause 4.2</title>
            </clause>
            <clause id="O1" inline-header="false" obligation="normative"/>
          </clause>
          <clause id="D" obligation="normative">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
        </sections>
        <annex id="P" inline-header="false" obligation="normative">
          <title>Annex</title>
          <clause id="Q" inline-header="false" obligation="normative">
            <title>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
              <title>Annex A.1a</title>
            </clause>
          </clause>
        </annex>
        <annex id="P1" inline-header="false" obligation="normative"/>
        <bibliography>
          <references id="R" normative="true" obligation="informative">
            <title>Normative References</title>
          </references>
          <clause id="S" obligation="informative">
            <title>Bibliography</title>
            <references id="T" normative="false" obligation="informative">
              <title>Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <ext>
               <doctype language="">amendment</doctype>
               <doctype language="en">Amendment</doctype>
            </ext>
         </bibdata>
      #{'   '}
         <boilerplate>
            <copyright-statement>
               <clause>
                  <title id="_">Copyright</title>
                  <fmt-title depth="1">
                     <span class="fmt-caption-label">
                        <semx element="title" source="_">Copyright</semx>
                     </span>
                  </fmt-title>
               </clause>
            </copyright-statement>
            <license-statement>
               <clause>
                  <title id="_">License</title>
                  <fmt-title depth="1">
                     <span class="fmt-caption-label">
                        <semx element="title" source="_">License</semx>
                     </span>
                  </fmt-title>
               </clause>
            </license-statement>
            <legal-statement>
               <clause>
                  <title id="_">Legal</title>
                  <fmt-title depth="1">
                     <span class="fmt-caption-label">
                        <semx element="title" source="_">Legal</semx>
                     </span>
                  </fmt-title>
               </clause>
            </legal-statement>
            <feedback-statement>
               <clause>
                  <title id="_">Feedback</title>
                  <fmt-title depth="1">
                     <span class="fmt-caption-label">
                        <semx element="title" source="_">Feedback</semx>
                     </span>
                  </fmt-title>
               </clause>
            </feedback-statement>
         </boilerplate>
         <preface>
            <abstract obligation="informative" displayorder="1">
               <title id="_">Abstract</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="title" source="_">Abstract</semx>
                  </span>
               </fmt-title>
            </abstract>
            <foreword obligation="informative" displayorder="2">
               <title id="_">Foreword</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="title" source="_">Foreword</semx>
                  </span>
               </fmt-title>
               <p id="A">This is a preamble</p>
            </foreword>
            <introduction id="B" obligation="informative" displayorder="3">
               <title id="_">Introduction</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="title" source="_">Introduction</semx>
                  </span>
               </fmt-title>
               <clause id="C" inline-header="false" obligation="informative">
                  <title id="_">Introduction Subsection</title>
                  <fmt-title depth="2">
                     <span class="fmt-caption-label">
                        <semx element="title" source="_">Introduction Subsection</semx>
                     </span>
                  </fmt-title>
               </clause>
            </introduction>
            <clause id="B1" displayorder="4">
               <title id="_">Dedication</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="title" source="_">Dedication</semx>
                  </span>
               </fmt-title>
            </clause>
            <clause id="B2" displayorder="5">
               <title id="_">Note to reader</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="title" source="_">Note to reader</semx>
                  </span>
               </fmt-title>
            </clause>
            <acknowledgements obligation="informative" displayorder="6">
               <title id="_">Acknowledgements</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="title" source="_">Acknowledgements</semx>
                  </span>
               </fmt-title>
            </acknowledgements>
         </preface>
         <sections>
            <clause id="M" inline-header="false" obligation="normative" displayorder="7">
               <title id="_">Clause 4</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="title" source="_">Clause 4</semx>
                  </span>
               </fmt-title>
               <clause id="N" inline-header="false" obligation="normative">
                  <title id="_">Introduction</title>
                  <fmt-title depth="2">
                     <span class="fmt-caption-label">
                        <semx element="title" source="_">Introduction</semx>
                     </span>
                  </fmt-title>
               </clause>
               <clause id="O" inline-header="false" obligation="normative">
                  <title id="_">Clause 4.2</title>
                  <fmt-title depth="2">
                     <span class="fmt-caption-label">
                        <semx element="title" source="_">Clause 4.2</semx>
                     </span>
                  </fmt-title>
               </clause>
               <clause id="O1" inline-header="true" obligation="normative"/>
            </clause>
            <clause id="D" obligation="normative" displayorder="8">
               <title id="_">Scope</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="title" source="_">Scope</semx>
                  </span>
               </fmt-title>
               <p id="E">Text</p>
            </clause>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
            <title id="_">
               <strong>Annex</strong>
            </title>
            <fmt-title>
               <span class="fmt-caption-label">
                  <strong>
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="P">A</semx>
                  </strong>
                  <br/>
                  <span class="obligation">(normative)</span>
                  <span class="fmt-caption-delim">
                     <br/>
                     <br/>
                  </span>
                  <semx element="title" source="_">
                     <strong>Annex</strong>
                  </semx>
               </span>
            </fmt-title>
            <fmt-xref-label>
               <span class="fmt-element-name">Annex</span>
               <semx element="autonum" source="P">A</semx>
            </fmt-xref-label>
            <clause id="Q" inline-header="false" obligation="normative">
               <title id="_">Annex A.1</title>
               <fmt-title depth="2">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="Q">A.1</semx>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Annex A.1</semx>
                  </span>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="Q">A.1</semx>
               </fmt-xref-label>
               <clause id="Q1" inline-header="false" obligation="normative">
                  <title id="_">Annex A.1a</title>
                  <fmt-title depth="3">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="Q1">A.1.1</semx>
                        <span class="fmt-caption-delim">
                           <tab/>
                        </span>
                        <semx element="title" source="_">Annex A.1a</semx>
                     </span>
                  </fmt-title>
                  <fmt-xref-label>
                     <semx element="autonum" source="Q1">A.1.1</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
         </annex>
         <annex id="P1" inline-header="false" obligation="normative" autonum="B" displayorder="10">
            <fmt-title>
               <span class="fmt-caption-label">
                  <strong>
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="P1">B</semx>
                  </strong>
                  <br/>
                  <span class="obligation">(normative)</span>
               </span>
            </fmt-title>
            <fmt-xref-label>
               <span class="fmt-element-name">Annex</span>
               <semx element="autonum" source="P1">B</semx>
            </fmt-xref-label>
         </annex>
         <bibliography>
            <references id="R" normative="true" obligation="informative" displayorder="11">
               <title id="_">Normative References</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="title" source="_">Normative References</semx>
                  </span>
               </fmt-title>
            </references>
            <clause id="S" obligation="informative" displayorder="12">
               <title id="_">Bibliography</title>
               <fmt-title depth="1">
                  <span class="fmt-caption-label">
                     <semx element="title" source="_">Bibliography</semx>
                  </span>
               </fmt-title>
               <references id="T" normative="false" obligation="informative">
                  <title id="_">Bibliography Subsection</title>
                  <fmt-title depth="2">
                     <span class="fmt-caption-label">
                        <semx element="title" source="_">Bibliography Subsection</semx>
                     </span>
                  </fmt-title>
               </references>
            </clause>
         </bibliography>
      </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      <html lang="en" xmlns:epub="http://www.idpf.org/2007/ops">
        <head/>
        <body lang="en">
          <div class="title-section">
            <p> </p>
          </div>
          <br/>
          <div class="prefatory-section">
            <p> </p>
          </div>
          <br/>
          <div class="main-section">
            <div class="authority">
              <div class="boilerplate-copyright">
                <div>
                  <h1>Copyright</h1>
                </div>
              </div>
              <div class="boilerplate-license">
                <div>
                  <h1>License</h1>
                </div>
              </div>
              <div class="boilerplate-legal">
                <div>
                  <h1>Legal</h1>
                </div>
              </div>
              <div class="boilerplate-feedback">
                <div>
                  <h1>Feedback</h1>
                </div>
              </div>
            </div>
            <br/>
            <div>
              <h1 class="AbstractTitle">Abstract</h1>
            </div>
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="A">This is a preamble</p>
            </div>
            <br/>
            <div class="Section3" id="B">
              <h1 class="IntroTitle">Introduction</h1>
              <div id="C">
                <h2>Introduction Subsection</h2>
              </div>
            </div>
            <br/>
            <div class="Section3" id="B1">
              <h1 class="IntroTitle">Dedication</h1>
            </div>
            <br/>
            <div class="Section3" id="B2">
              <h1 class="IntroTitle">Note to reader</h1>
            </div>
            <br/>
            <div class="Section3" id="">
              <h1 class="IntroTitle">Acknowledgements</h1>
            </div>
            <div>
              <h1>Normative References</h1>
            </div>
            <div id="M">
              <h1>Clause 4</h1>
              <div id="N">
                <h2>Introduction</h2>
              </div>
              <div id="O">
                <h2>Clause 4.2</h2>
              </div>
              <div id="O1"/>
            </div>
            <div id="D">
              <h1>Scope</h1>
              <p id="E">Text</p>
            </div>
            <br/>
            <div class="Section3" id="P">
              <h1 class="Annex">
                <b>Annex A</b>
                <br/><span class="obligation">(normative)</span>
                <br/>
                <br/>
                <b>Annex</b></h1>
              <div id="Q">
                <h2>A.1&#160; Annex A.1</h2>
                <div id="Q1">
                  <h3>A.1.1&#160; Annex A.1a</h3>
                </div>
              </div>
            </div>
            <br/>
            <div class="Section3" id="P1">
              <h1 class="Annex">
                <b>Annex B</b>
                <br/><span class="obligation">(normative)</span></h1>
            </div>
            <br/>
            <div>
              <h1 class="Section3">Bibliography</h1>
              <div>
                <h2 class="Section3">Bibliography Subsection</h2>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes IsoXML metadata for amendment" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
      <iso-standard xmlns="https://www.metanorma.org/ns/iso">
        <bibdata type="standard">
          <title format="text/plain" language="en" type="main">Introduction — Main Title — Title — Title Part  — Mass fraction of
                   extraneous matter, milled rice (nonglutinous), sample dividers and
                   recommendations relating to storage and transport conditions</title>
          <title format="text/plain" language="en" type="title-intro">Introduction</title>
          <title format="text/plain" language="en" type="title-main">Main Title — Title</title>
          <title format="text/plain" language="en" type="title-part">Title Part</title>
          <title format="text/plain" language="en" type="title-amd">Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
          <title format="text/plain" language="fr" type="main">Introduction Française — Titre Principal — Part du Titre — Fraction
              massique de matière étrangère, riz usiné (non gluant), diviseurs
              d’échantillon et recommandations relatives aux conditions d’entreposage et
              de transport
            </title>
          <title format="text/plain" language="fr" type="title-intro">Introduction Française</title>
          <title format="text/plain" language="fr" type="title-main">Titre Principal</title>
          <title format="text/plain" language="fr" type="title-part">Part du Titre</title>
          <title format="text/plain" language="fr" type="title-amd">Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport</title>
          <docidentifier type="ISO">ISO/PreNWIP3 17301-1:2016/Amd.1</docidentifier>
          <docidentifier type="iso-with-lang">ISO/PreNWIP3 17301-1:2016/Amd.1(E)</docidentifier>
          <docidentifier type="iso-reference">ISO/PreNWIP3 17301-1:2016/Amd.1:2017(E)</docidentifier>
          <docnumber>17301</docnumber>
          <date type="created">
            <on>2016-05-01</on>
          </date>
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
          <edition>2</edition>
          <version>
            <revision-date>2000-01-01</revision-date>
            <draft>0.3.4</draft>
          </version>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage abbreviation="NWIP">10</stage>
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
              <technical-committee number="1" type="A">TC</technical-committee>
              <technical-committee number="11" type="A1">TC1</technical-committee>
              <subcommittee number="2" type="B">SC</subcommittee>
              <subcommittee number="21" type="B1">SC1</subcommittee>
              <workgroup number="3" type="C">WG</workgroup>
              <workgroup number="31" type="C1">WG1</workgroup>
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
              <project-number amendment="1" corrigendum="2" origyr="2016-05-01" part="1">17301</project-number>
            </structuredidentifier>
            <stagename>New work item proposal</stagename>
            <updates-document-type>international-standard</updates-document-type>
          </ext>
        </bibdata>
        <sections/>
      </iso-standard>
    INPUT
    output =
      { agency: "ISO",
        createddate: "2016-05-01",
        docnumber: "ISO/PreNWIP3 17301-1:2016/Amd.1",
        docnumber_lang: "ISO/PreNWIP3 17301-1:2016/Amd.1(E)",
        docnumber_reference: "ISO/PreNWIP3 17301-1:2016/Amd.1:2017(E)",
        docnumeric: "17301",
        docsubtitle: "Introduction Fran&#xe7;aise&#xa0;&#x2014; Titre Principal&#xa0;&#x2014; Partie&#xa0;1: Part du Titre",
        docsubtitleamd: "Fraction massique de mati&#xe8;re &#xe9;trang&#xe8;re, riz usin&#xe9; (non gluant), diviseurs d&#x2019;&#xe9;chantillon et recommandations relatives aux conditions d&#x2019;entreposage et de transport",
        docsubtitleamdlabel: "AMENDMENT&#xa0;1",
        docsubtitlecorrlabel: "RECTIFICATIF TECHNIQUE&#xa0;2",
        docsubtitleintro: "Introduction Fran&#xe7;aise",
        docsubtitlemain: "Titre Principal",
        docsubtitlepart: "Part du Titre",
        docsubtitlepartlabel: "Partie&#xa0;1",
        doctitle: "Introduction&#xa0;&#x2014; Main Title&#x2009;&#x2014;&#x2009;Title&#xa0;&#x2014; Part&#xa0;1: Title Part",
        doctitleamd: "Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions",
        doctitleamdlabel: "AMENDMENT&#xa0;1",
        doctitlecorrlabel: "TECHNICAL CORRIGENDUM&#xa0;2",
        doctitleintro: "Introduction",
        doctitlemain: "Main Title&#x2009;&#x2014;&#x2009;Title",
        doctitlepart: "Title Part",
        doctitlepartlabel: "Part&#xa0;1",
        doctype: "Amendment",
        doctype_display: "Amendment",
        docyear: "2017",
        draft: "0.3.4",
        draftinfo: " (draft 0.3.4, 2000-01-01)",
        edition: "2",
        ics: "1, 2, 3",
        lang: "en",
        publisher: "International Organization for Standardization",
        revdate: "2000-01-01",
        revdate_monthyear: "January 2000",
        sc: "B 2",
        script: "Latn",
        secretariat: "SECRETARIAT",
        stage: "10",
        stage_int: 10,
        stageabbr: "NWIP",
        statusabbr: "PreNWIP3",
        substage_int: "20",
        tc: "A 1",
        unpublished: true,
        wg: "C 3" }
    expect(metadata(c.info(Nokogiri::XML(input), nil)))
      .to be_equivalent_to output
  end

  it "processes IsoXML metadata for amendment in French" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <language>fr</language>
        </bibdata>
      </iso-standard>
    INPUT
    input = <<~INPUT
      <iso-standard xmlns="https://www.metanorma.org/ns/iso">
        <bibdata type="standard">
          <title format="text/plain" language="en" type="main">Introduction — Main Title — Title — Title Part  — Mass fraction of
             extraneous matter, milled rice (nonglutinous), sample dividers and
             recommendations relating to storage and transport conditions</title>
          <title format="text/plain" language="en" type="title-intro">Introduction</title>
          <title format="text/plain" language="en" type="title-main">Main Title — Title</title>
          <title format="text/plain" language="en" type="title-part">Title Part</title>
          <title format="text/plain" language="en" type="title-amd">Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
          <title format="text/plain" language="fr" type="main">Introduction Française — Titre Principal — Part du Titre — Fraction
        massique de matière étrangère, riz usiné (non gluant), diviseurs
        d’échantillon et recommandations relatives aux conditions d’entreposage et
        de transport
      </title>
          <title format="text/plain" language="fr" type="title-intro">Introduction Française</title>
          <title format="text/plain" language="fr" type="title-main">Titre Principal</title>
          <title format="text/plain" language="fr" type="title-part">Part du Titre</title>
          <title format="text/plain" language="fr" type="title-amd">Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport</title>
          <docidentifier type="ISO">ISO/PreNWIP3 17301-1:2016/Amd.1</docidentifier>
          <docidentifier type="iso-with-lang">ISO/PreNWIP3 17301-1:2016/Amd.1(E)</docidentifier>
          <docidentifier type="iso-reference">ISO/PreNWIP3 17301-1:2016/Amd.1:2017(E)</docidentifier>
          <docnumber>17301</docnumber>
          <date type="created">
            <on>2016-05-01</on>
          </date>
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
          <edition>2</edition>
          <version>
            <revision-date>2000-01-01</revision-date>
            <draft>0.3.4</draft>
          </version>
          <language>fr</language>
          <script>Latn</script>
          <status>
            <stage abbreviation="NWIP">10</stage>
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
            <doctype language="">amendment</doctype>
            <doctype language="fr">Amendment</doctype>
            <editorialgroup identifier="ABC">
              <technical-committee number="1" type="A">TC</technical-committee>
              <technical-committee number="11" type="A1">TC1</technical-committee>
              <subcommittee number="2" type="B">SC</subcommittee>
              <subcommittee number="21" type="B1">SC1</subcommittee>
              <workgroup number="3" type="C">WG</workgroup>
              <workgroup number="31" type="C1">WG1</workgroup>
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
              <project-number amendment="1" corrigendum="2" origyr="2016-05-01" part="1">17301</project-number>
            </structuredidentifier>
            <stagename>New work item proposal</stagename>
            <updates-document-type>international-standard</updates-document-type>
          </ext>
        </bibdata>
        <sections/>
      </iso-standard>
    INPUT
    output =
      { agency: "ISO",
        createddate: "2016-05-01",
        docnumber: "ISO/PreNWIP3 17301-1:2016/Amd.1",
        docnumber_lang: "ISO/PreNWIP3 17301-1:2016/Amd.1(E)",
        docnumber_reference: "ISO/PreNWIP3 17301-1:2016/Amd.1:2017(E)",
        docnumeric: "17301",
        docsubtitle: "Introduction&#xa0;&#x2014; Main Title&#x2009;&#x2014;&#x2009;Title&#xa0;&#x2014; Part&#xa0;1: Title Part",
        docsubtitleamd: "Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions",
        docsubtitleamdlabel: "AMENDMENT&#xa0;1",
        docsubtitlecorrlabel: "TECHNICAL CORRIGENDUM&#xa0;2",
        docsubtitleintro: "Introduction",
        docsubtitlemain: "Main Title&#x2009;&#x2014;&#x2009;Title",
        docsubtitlepart: "Title Part",
        docsubtitlepartlabel: "Part&#xa0;1",
        doctitle: "Introduction Fran&#xe7;aise&#xa0;&#x2014; Titre Principal&#xa0;&#x2014; Partie&#xa0;1: Part du Titre",
        doctitleamd: "Fraction massique de mati&#xe8;re &#xe9;trang&#xe8;re, riz usin&#xe9; (non gluant), diviseurs d&#x2019;&#xe9;chantillon et recommandations relatives aux conditions d&#x2019;entreposage et de transport",
        doctitleamdlabel: "AMENDMENT&#xa0;1",
        doctitlecorrlabel: "RECTIFICATIF TECHNIQUE&#xa0;2",
        doctitleintro: "Introduction Fran&#xe7;aise",
        doctitlemain: "Titre Principal",
        doctitlepart: "Part du Titre",
        doctitlepartlabel: "Partie&#xa0;1",
        doctype: "Amendment",
        doctype_display: "Amendment",
        docyear: "2017",
        draft: "0.3.4",
        draftinfo: " (brouillon 0.3.4, 2000-01-01)",
        edition: "2",
        editorialgroup: "ABC",
        ics: "1, 2, 3",
        lang: "fr",
        publisher: "International Organization for Standardization",
        revdate: "2000-01-01",
        revdate_monthyear: "Janvier 2000",
        sc: "B 2",
        script: "Latn",
        secretariat: "SECRETARIAT",
        stage: "10",
        stage_int: 10,
        stageabbr: "NWIP",
        statusabbr: "PreNWIP3",
        substage_int: "20",
        tc: "A 1",
        unpublished: true,
        wg: "C 3" }
    expect(metadata(c.info(Nokogiri::XML(input), nil)))
      .to be_equivalent_to output
  end

  it "processes IsoXML metadata for addendum" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
      <iso-standard xmlns="https://www.metanorma.org/ns/iso">
        <bibdata type="standard">
          <title format="text/plain" language="en" type="main">Introduction — Main Title — Title — Title Part  — Mass fraction of
                   extraneous matter, milled rice (nonglutinous), sample dividers and
                   recommendations relating to storage and transport conditions</title>
          <title format="text/plain" language="en" type="title-intro">Introduction</title>
          <title format="text/plain" language="en" type="title-main">Main Title — Title</title>
          <title format="text/plain" language="en" type="title-part">Title Part</title>
          <title format="text/plain" language="en" type="title-add">Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
          <title format="text/plain" language="fr" type="main">Introduction Française — Titre Principal — Part du Titre — Fraction
              massique de matière étrangère, riz usiné (non gluant), diviseurs
              d’échantillon et recommandations relatives aux conditions d’entreposage et
              de transport
            </title>
          <title format="text/plain" language="fr" type="title-intro">Introduction Française</title>
          <title format="text/plain" language="fr" type="title-main">Titre Principal</title>
          <title format="text/plain" language="fr" type="title-part">Part du Titre</title>
          <title format="text/plain" language="fr" type="title-add">Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport</title>
          <docidentifier type="ISO">ISO/PreNWIP3 17301-1:2016/Add.1</docidentifier>
          <docidentifier type="iso-with-lang">ISO/PreNWIP3 17301-1:2016/Add.1(E)</docidentifier>
          <docidentifier type="iso-reference">ISO/PreNWIP3 17301-1:2016/Add.1:2017(E)</docidentifier>
          <docnumber>17301</docnumber>
          <date type="created">
            <on>2016-05-01</on>
          </date>
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
          <edition>2</edition>
          <version>
            <revision-date>2000-01-01</revision-date>
            <draft>0.3.4</draft>
          </version>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage abbreviation="NWIP">10</stage>
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
            <doctype>addendum</doctype>
            <editorialgroup>
              <technical-committee number="1" type="A">TC</technical-committee>
              <technical-committee number="11" type="A1">TC1</technical-committee>
              <subcommittee number="2" type="B">SC</subcommittee>
              <subcommittee number="21" type="B1">SC1</subcommittee>
              <workgroup number="3" type="C">WG</workgroup>
              <workgroup number="31" type="C1">WG1</workgroup>
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
              <project-number addendum="1" corrigendum="2" origyr="2016-05-01" part="1">17301</project-number>
            </structuredidentifier>
            <stagename>New work item proposal</stagename>
            <updates-document-type>international-standard</updates-document-type>
          </ext>
        </bibdata>
        <sections/>
      </iso-standard>
    INPUT
    output =
      { agency: "ISO",
        createddate: "2016-05-01",
        docnumber: "ISO/PreNWIP3 17301-1:2016/Add.1",
        docnumber_lang: "ISO/PreNWIP3 17301-1:2016/Add.1(E)",
        docnumber_reference: "ISO/PreNWIP3 17301-1:2016/Add.1:2017(E)",
        docnumeric: "17301",
        docsubtitle: "Introduction Fran&#xe7;aise&#xa0;&#x2014; Titre Principal&#xa0;&#x2014; Partie&#xa0;1: Part du Titre",
        docsubtitleadd: "Fraction massique de mati&#xe8;re &#xe9;trang&#xe8;re, riz usin&#xe9; (non gluant), diviseurs d&#x2019;&#xe9;chantillon et recommandations relatives aux conditions d&#x2019;entreposage et de transport",
        docsubtitleaddlabel: "ADDITIF&#xa0;1",
        docsubtitlecorrlabel: "RECTIFICATIF TECHNIQUE&#xa0;2",
        docsubtitleintro: "Introduction Fran&#xe7;aise",
        docsubtitlemain: "Titre Principal",
        docsubtitlepart: "Part du Titre",
        docsubtitlepartlabel: "Partie&#xa0;1",
        doctitle: "Introduction&#xa0;&#x2014; Main Title&#x2009;&#x2014;&#x2009;Title&#xa0;&#x2014; Part&#xa0;1: Title Part",
        doctitleadd: "Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions",
        doctitleaddlabel: "ADDENDUM&#xa0;1",
        doctitlecorrlabel: "TECHNICAL CORRIGENDUM&#xa0;2",
        doctitleintro: "Introduction",
        doctitlemain: "Main Title&#x2009;&#x2014;&#x2009;Title",
        doctitlepart: "Title Part",
        doctitlepartlabel: "Part&#xa0;1",
        doctype: "Addendum",
        doctype_display: "Addendum",
        docyear: "2017",
        draft: "0.3.4",
        draftinfo: " (draft 0.3.4, 2000-01-01)",
        edition: "2",
        ics: "1, 2, 3",
        lang: "en",
        publisher: "International Organization for Standardization",
        revdate: "2000-01-01",
        revdate_monthyear: "January 2000",
        sc: "B 2",
        script: "Latn",
        secretariat: "SECRETARIAT",
        stage: "10",
        stage_int: 10,
        stageabbr: "NWIP",
        statusabbr: "PreNWIP3",
        substage_int: "20",
        tc: "A 1",
        unpublished: true,
        wg: "C 3" }
    expect(metadata(c.info(Nokogiri::XML(input), nil)))
      .to be_equivalent_to output
  end

  it "processes middle title" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <title format="text/plain" language="en" type="title-intro">Introduction</title>
          <title format="text/plain" language="en" type="title-main">Main Title — Title</title>
          <title format="text/plain" language="en" type="title-part">Title Part</title>
          <title format="text/plain" language="en" type="title-amd">Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
          <ext>
            <structuredidentifier>
              <project-number amendment="1" corrigendum="2" origyr="2016-05-01" part="1">17301</project-number>
            </structuredidentifier>
          </ext>
        </bibdata>
        <preface>
        <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
        </preface>
        <sections>
        <clause/>
        </sections>
      </iso-standard>
    INPUT
    presxml = <<~PRESXML
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
          <title format="text/plain" language="en" type="title-intro">Introduction</title>
          <title format="text/plain" language="en" type="title-main">Main Title — Title</title>
          <title format="text/plain" language="en" type="title-part">Title Part</title>
          <title format="text/plain" language="en" type="title-amd">Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
          <ext>
            <structuredidentifier>
              <project-number amendment="1" corrigendum="2" origyr="2016-05-01" part="1">17301</project-number>
            </structuredidentifier>
          </ext>
        </bibdata>
        <preface>
          <clause type="toc" id="_" displayorder="1">
                   <title depth="1" id="_">Contents</title>
         <fmt-title depth="1">
            <span class="fmt-caption-label">
               <semx element="title" source="_">Contents</semx>
            </span>
         </fmt-title>
          </clause>
        </preface>
        <sections>
          <p class="zzSTDTitle1" displayorder="2">
            <span class="boldtitle">Introduction — Main Title — Title — </span>
            <span class="nonboldtitle">Part 1:</span>
            <span class="boldtitle">Title Part</span>
          </p>
          <p class="zzSTDTitle2" displayorder="3">AMENDMENT 1: Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</p>
          <p class="zzSTDTitle2" displayorder="4">TECHNICAL CORRIGENDUM 2</p>
          <clause displayorder="5"/>
        </sections>
      </iso-standard>
    PRESXML
    html = <<~OUTPUT
      #{HTML_HDR}
                   <p class="zzSTDTitle1">
               <span class="boldtitle">Introduction — Main Title — Title — </span>
               <span class="nonboldtitle">Part 1:</span>
               <span class="boldtitle">Title Part</span>
             </p>
             <p class="zzSTDTitle2">AMENDMENT 1: Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</p>
             <p class="zzSTDTitle2">TECHNICAL CORRIGENDUM 2</p>
             <div>
               <h1/>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end
end
