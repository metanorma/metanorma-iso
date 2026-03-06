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
    output = <<~OUTPUT
       <foreword displayorder="1" id="_">
          <title id="_">Foreword</title>
          <fmt-title id="_" depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="widgets">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="note1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="widgets">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="note2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1a">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1b">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="Anote1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1b">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="Anote2">2</semx>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
      OUTPUT
    expect(strip_guid(xml.to_xml))
      .to be_xml_equivalent_to output
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
    output = <<~OUTPUT
      <foreword obligation="informative" displayorder="1" id="_">
          <title id="_">Foreword</title>
          <fmt-title id="_" depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p id="A">
             This is a preamble
             <xref target="C" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="C">
                   <span class="citesec">
                      <semx element="autonum" source="B">0</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="C">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="C1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="C1">
                   <span class="citesec">
                      <semx element="autonum" source="B">0</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="C1">2</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="D" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="D">
                   <span class="citesec">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="D">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="H" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="H">[H]</fmt-xref>
             </semx>
             <xref target="I" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="I">[I]</fmt-xref>
             </semx>
             <xref target="J" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="J">[J]</fmt-xref>
             </semx>
             <xref target="K" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="K">[K]</fmt-xref>
             </semx>
             <xref target="L" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="L">[L]</fmt-xref>
             </semx>
             <xref target="M" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="M">
                   <span class="citesec">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="M">2</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="citesec">
                      <semx element="autonum" source="M">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="N">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="O" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="O">
                   <span class="citesec">
                      <semx element="autonum" source="M">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="O">2</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="P" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="P">
                   <span class="citeapp">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Q" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Q">
                   <span class="citeapp">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Q1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Q1">
                   <span class="citeapp">
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q1">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Q2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Q2">
                   <span class="citeapp">
                      <span class="fmt-xref-container">
                         <span class="fmt-element-name">Annex</span>
                         <semx element="autonum" source="P">A</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Appendix</span>
                      <semx element="autonum" source="Q2">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="R" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="R">
                   <span class="citesec">
                      <semx element="references" source="R">Normative References</semx>
                   </span>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
      OUTPUT
    expect(Canon.format_xml(strip_guid(xml.to_xml))
    .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Canon.format_xml(output)
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
          
          <boilerplate>
             <copyright-statement>
                <clause id="_">
                   <title id="_">Copyright</title>
                   <fmt-title id="_" depth="1">
                      <semx element="title" source="_">Copyright</semx>
                   </fmt-title>
                </clause>
             </copyright-statement>
             <license-statement>
                <clause id="_">
                   <title id="_">License</title>
                   <fmt-title id="_" depth="1">
                      <semx element="title" source="_">License</semx>
                   </fmt-title>
                </clause>
             </license-statement>
             <legal-statement>
                <clause id="_">
                   <title id="_">Legal</title>
                   <fmt-title id="_" depth="1">
                      <semx element="title" source="_">Legal</semx>
                   </fmt-title>
                </clause>
             </legal-statement>
             <feedback-statement>
                <clause id="_">
                   <title id="_">Feedback</title>
                   <fmt-title id="_" depth="1">
                      <semx element="title" source="_">Feedback</semx>
                   </fmt-title>
                </clause>
             </feedback-statement>
          </boilerplate>
          <preface>
             <abstract obligation="informative" displayorder="1" id="_">
                <title id="_">Abstract</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Abstract</semx>
                </fmt-title>
             </abstract>
             <foreword obligation="informative" displayorder="2" id="_">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="3">
                <title id="_">Introduction</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title id="_" depth="2">
                      <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                </clause>
             </introduction>
             <clause id="B1" displayorder="4">
                <title id="_">Dedication</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Dedication</semx>
                </fmt-title>
             </clause>
             <clause id="B2" displayorder="5">
                <title id="_">Note to reader</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Note to reader</semx>
                </fmt-title>
             </clause>
             <acknowledgements obligation="informative" displayorder="6" id="_">
                <title id="_">Acknowledgements</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Acknowledgements</semx>
                </fmt-title>
             </acknowledgements>
          </preface>
          <sections>
             <clause id="M" inline-header="false" obligation="normative" displayorder="7">
                <title id="_">Clause 4</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Clause 4</semx>
                </fmt-title>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title id="_" depth="2">
                      <semx element="title" source="_">Introduction</semx>
                   </fmt-title>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title id="_" depth="2">
                      <semx element="title" source="_">Clause 4.2</semx>
                   </fmt-title>
                </clause>
                <clause id="O1" inline-header="true" obligation="normative"/>
             </clause>
             <clause id="D" obligation="normative" displayorder="8">
                <title id="_">Scope</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Scope</semx>
                </fmt-title>
                <p id="E">Text</p>
             </clause>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
             <title id="_">Annex</title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">(normative)</span>
                <span class="fmt-caption-delim">
                   <br/>
                   <br/>
                </span>
                <semx element="title" source="_">
                   <strong>Annex</strong>
                </semx>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="P">A</semx>
             </fmt-xref-label>
      <variant-title type="toc">
         <span class="fmt-caption-label">
            <span class="fmt-element-name">Annex</span>
            <semx element="autonum" source="P">A</semx>
         </span>
         <span class="fmt-caption-delim">
            <tab/>
         </span>
         <semx element="title" source="_">Annex</semx>
      </variant-title>
             <clause id="Q" inline-header="false" obligation="normative">
                <title id="_">Annex A.1</title>
                <fmt-title id="_" depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Annex A.1</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="P">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q">1</semx>
                </fmt-xref-label>
                <clause id="Q1" inline-header="false" obligation="normative">
                   <title id="_">Annex A.1a</title>
                   <fmt-title id="_" depth="3">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="P">A</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q1">1</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Annex A.1a</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q1">1</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
          </annex>
          <annex id="P1" inline-header="false" obligation="normative" autonum="B" displayorder="10">
                <variant-title type="toc">
         <span class="fmt-caption-label">
            <span class="fmt-element-name">Annex</span>
            <semx element="autonum" source="P1">B</semx>
         </span>
      </variant-title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="P1">B</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">(normative)</span>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="P1">B</semx>
             </fmt-xref-label>
          </annex>
          <bibliography>
             <references id="R" normative="true" obligation="informative" displayorder="11">
                <title id="_">Normative References</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
             </references>
             <clause id="S" obligation="informative" displayorder="12">
                <title id="_">Bibliography</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <references id="T" normative="false" obligation="informative">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title id="_" depth="2">
                      <semx element="title" source="_">Bibliography Subsection</semx>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      <html lang="en">
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
                <div id="_">
                  <h1>Copyright</h1>
                </div>
              </div>
              <div class="boilerplate-license">
                <div id="_">
                  <h1>License</h1>
                </div>
              </div>
              <div class="boilerplate-legal">
                <div id="_">
                  <h1>Legal</h1>
                </div>
              </div>
              <div class="boilerplate-feedback">
                <div id="_">
                  <h1>Feedback</h1>
                </div>
              </div>
            </div>
            <br/>
            <div id="_">
              <h1 class="AbstractTitle">Abstract</h1>
            </div>
            <br/>
            <div id="_">
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
            <div class="Section3" id="_">
              <h1 class="IntroTitle">Acknowledgements</h1>
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
                <p style="display:none;" class="variant-title-toc">Annex A  Annex</p>
              <div id="Q">
                <h2>A.1&#160; Annex A.1</h2>
                <div id="Q1">
                  <h3>A.1.1&#160; Annex A.1a</h3>
                </div>
              </div>
            </div>
            <br/>
            <div class="Section3" id="P1">
            <p style="display:none;" class="variant-title-toc">Annex B</p>
              <h1 class="Annex">
                <b>Annex B</b>
                <br/><span class="obligation">(normative)</span></h1>
            </div>
            <div>
              <h1>Normative References</h1>
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
    expect(Canon.format_xml(strip_guid(pres_output))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_html5_equivalent_to html
  end

  it "processes IsoXML metadata for amendment" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
      <iso-standard xmlns="https://www.metanorma.org/ns/standoc">
        <bibdata type="standard">
          <title format="text/plain" language="en" type="main">Introduction — Main Title — Title — Title Part  — Mass fraction of
                   extraneous matter, milled rice (nonglutinous), sample dividers and
                   recommendations relating to storage and transport conditions</title>
          <title format="text/plain" language="en" type="title-intro">Introduction</title>
          <title format="text/plain" language="en" type="title-main">Main Title — Title</title>
          <title format="text/plain" language="en" type="title-part">Title Part</title>
          <title format="text/plain" language="en" type="title-amd">Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
          <title format="text/plain" language="en" type="title-part-prefix">Part&#xa0;1</title>
          <title format="text/plain" language="en" type="title-amendment-prefix">AMENDMENT&#xa0;1</title>
          <title format="text/plain" language="en" type="title-corrigendum-prefix">TECHNICAL CORRIGENDUM&#xa0;2</title>
          <title format="text/plain" language="fr" type="main">Introduction Française — Titre Principal — Part du Titre — Fraction
              massique de matière étrangère, riz usiné (non gluant), diviseurs
              d’échantillon et recommandations relatives aux conditions d’entreposage et
              de transport
            </title>
          <title format="text/plain" language="fr" type="title-intro">Introduction Française</title>
          <title format="text/plain" language="fr" type="title-main">Titre Principal</title>
          <title format="text/plain" language="fr" type="title-part">Part du Titre</title>
          <title format="text/plain" language="fr" type="title-amd">Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport</title>
          <title format="text/plain" language="fr" type="title-part-prefix">Partie&#xa0;1</title>
          <title format="text/plain" language="fr" type="title-amendment-prefix">AMENDEMENT&#xa0;1</title>
          <title format="text/plain" language="fr" type="title-corrigendum-prefix">RECTIFICATIF TECHNIQUE&#xa0;2</title>
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
                <metanorma-extension>
        <semantic-metadata>
        <stage-published>false</stage-published>
        </semantic-metadata>
        </metanorma-extension>
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
        docsubtitle: "Introduction Française&#xa0;&#x2014; Titre Principal&#xa0;&#x2014; Partie\u00a01 : Part du Titre",
        docsubtitleamd: "Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport",
        docsubtitleamdlabel: "AMENDEMENT\u00a01",
        docsubtitlecorrlabel: "RECTIFICATIF TECHNIQUE\u00a02",
        docsubtitleintro: "Introduction Française",
        docsubtitlemain: "Titre Principal",
        docsubtitlepart: "Part du Titre",
        docsubtitlepartlabel: "Partie\u00a01",
        doctitle: "Introduction&#xa0;&#x2014; Main Title\u2009\u2014\u2009Title&#xa0;&#x2014; Part\u00a01: Title Part",
        doctitleamd: "Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions",
        doctitleamdlabel: "AMENDMENT\u00a01",
        doctitlecorrlabel: "TECHNICAL CORRIGENDUM\u00a02",
        doctitleintro: "Introduction",
        doctitlemain: "Main Title\u2009\u2014\u2009Title",
        doctitlepart: "Title Part",
        doctitlepartlabel: "Part\u00a01",
        doctype: "Amendment",
        doctype_display: "Amendment",
        docyear: "2017",
        draft: "0.3.4",
        draftinfo: " (draft 0.3.4, 2000-01-01)",
        edition: "2",
        editorialgroup: "IEC TC 62 and TC 210/SC 62A/WG 62A1",
        ics: "1, 2, 3",
        lang: "en",
        publisher: "International Organization for Standardization",
        revdate: "2000-01-01",
        revdate_monthyear: "January 2000",
        sc: "SC 62A",
        script: "Latn",
        secretariat: "GB",
        stage: "10",
        stage_int: 10,
        stageabbr: "NWIP",
        statusabbr: "PreNWIP3",
        substage_int: "20",
        tc: "TC 62",
        unpublished: true,
        wg: "WG 62A1" }
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
      <iso-standard xmlns="https://www.metanorma.org/ns/standoc">
        <bibdata type="standard">
          <title format="text/plain" language="en" type="main">Introduction — Main Title — Title — Title Part  — Mass fraction of
             extraneous matter, milled rice (nonglutinous), sample dividers and
             recommendations relating to storage and transport conditions</title>
          <title format="text/plain" language="en" type="title-intro">Introduction</title>
          <title format="text/plain" language="en" type="title-main">Main Title — Title</title>
          <title format="text/plain" language="en" type="title-part">Title Part</title>
          <title format="text/plain" language="en" type="title-amd">Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
          <title format="text/plain" language="en" type="title-part-prefix">Part&#xa0;1</title>
          <title format="text/plain" language="en" type="title-amendment-prefix">AMENDMENT&#xa0;1</title>
          <title format="text/plain" language="en" type="title-corrigendum-prefix">TECHNICAL CORRIGENDUM&#xa0;2</title>
          <title format="text/plain" language="fr" type="main">Introduction Française — Titre Principal — Part du Titre — Fraction
        massique de matière étrangère, riz usiné (non gluant), diviseurs
        d’échantillon et recommandations relatives aux conditions d’entreposage et
        de transport
      </title>
          <title format="text/plain" language="fr" type="title-intro">Introduction Française</title>
          <title format="text/plain" language="fr" type="title-main">Titre Principal</title>
          <title format="text/plain" language="fr" type="title-part">Part du Titre</title>
          <title format="text/plain" language="fr" type="title-amd">Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport</title>
          <title format="text/plain" language="fr" type="title-part-prefix">Partie&#xa0;1</title>
          <title format="text/plain" language="fr" type="title-amendment-prefix">AMENDEMENT&#xa0;1</title>
          <title format="text/plain" language="fr" type="title-corrigendum-prefix">RECTIFICATIF TECHNIQUE&#xa0;2</title>
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
                <metanorma-extension>
        <semantic-metadata>
        <stage-published>false</stage-published>
        </semantic-metadata>
        </metanorma-extension>
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
        docsubtitle: "Introduction&#xa0;&#x2014; Main Title\u2009—\u2009Title&#xa0;&#x2014; Part\u00a01: Title Part",
        docsubtitleamd: "Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions",
        docsubtitleamdlabel: "AMENDMENT\u00a01",
        docsubtitlecorrlabel: "TECHNICAL CORRIGENDUM\u00a02",
        docsubtitleintro: "Introduction",
        docsubtitlemain: "Main Title\u2009\u2014\u2009Title",
        docsubtitlepart: "Title Part",
        docsubtitlepartlabel: "Part\u00a01",
        doctitle: "Introduction Française&#xa0;&#x2014; Titre Principal&#xa0;&#x2014; Partie\u00a01 : Part du Titre",
        doctitleamd: "Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport",
        doctitleamdlabel: "AMENDEMENT\u00a01",
        doctitlecorrlabel: "RECTIFICATIF TECHNIQUE\u00a02",
        doctitleintro: "Introduction Française",
        doctitlemain: "Titre Principal",
        doctitlepart: "Part du Titre",
        doctitlepartlabel: "Partie\u00a01",
        doctype: "Amendment",
        doctype_display: "Amendment",
        docyear: "2017",
        draft: "0.3.4",
        draftinfo: " (brouillon 0.3.4, 2000-01-01)",
        edition: "2",
        ics: "1, 2, 3",
        lang: "fr",
        publisher: "International Organization for Standardization",
        revdate: "2000-01-01",
        revdate_monthyear: "Janvier 2000",
        script: "Latn",
        stage: "10",
        stage_int: 10,
        stageabbr: "NWIP",
        statusabbr: "PreNWIP3",
        substage_int: "20",
        unpublished: true }
    expect(metadata(c.info(Nokogiri::XML(input), nil)))
      .to be_equivalent_to output
  end

  it "processes IsoXML metadata for addendum" do
    c = IsoDoc::Iso::HtmlConvert.new({})
    _ = c.convert_init(<<~INPUT, "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
      <iso-standard xmlns="https://www.metanorma.org/ns/standoc">
        <bibdata type="standard">
          <title format="text/plain" language="en" type="main">Introduction — Main Title — Title — Title Part  — Mass fraction of
                   extraneous matter, milled rice (nonglutinous), sample dividers and
                   recommendations relating to storage and transport conditions</title>
          <title format="text/plain" language="en" type="title-intro">Introduction</title>
          <title format="text/plain" language="en" type="title-main">Main Title — Title</title>
          <title format="text/plain" language="en" type="title-part">Title Part</title>
          <title format="text/plain" language="en" type="title-part-prefix">Part&#xa0;1</title>
          <title format="text/plain" language="en" type="title-addendum-prefix">ADDENDUM&#xa0;1</title>
          <title format="text/plain" language="en" type="title-corrigendum-prefix">TECHNICAL CORRIGENDUM&#xa0;2</title>
          <title format="text/plain" language="en" type="title-add">Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions</title>
          <title format="text/plain" language="fr" type="main">Introduction Française — Titre Principal — Part du Titre — Fraction
              massique de matière étrangère, riz usiné (non gluant), diviseurs
              d’échantillon et recommandations relatives aux conditions d’entreposage et
              de transport
            </title>
          <title format="text/plain" language="fr" type="title-intro">Introduction Française</title>
          <title format="text/plain" language="fr" type="title-main">Titre Principal</title>
          <title format="text/plain" language="fr" type="title-part">Part du Titre</title>
          <title format="text/plain" language="fr" type="title-part-prefix">Partie&#xa0;1</title>
          <title format="text/plain" language="fr" type="title-addendum-prefix">ADDITIF&#xa0;1</title>
          <title format="text/plain" language="fr" type="title-corrigendum-prefix">RECTIFICATIF TECHNIQUE&#xa0;2</title>
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
        <metanorma-extension>
        <semantic-metadata>
        <stage-published>false</stage-published>
        </semantic-metadata>
        </metanorma-extension>
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
        docsubtitle: "Introduction Française&#xa0;&#x2014; Titre Principal&#xa0;&#x2014; Partie\u00a01 : Part du Titre",
        docsubtitleadd: "Fraction massique de matière étrangère, riz usiné (non gluant), diviseurs d’échantillon et recommandations relatives aux conditions d’entreposage et de transport",
        docsubtitleaddlabel: "ADDITIF\u00a01",
        docsubtitlecorrlabel: "RECTIFICATIF TECHNIQUE\u00a02",
        docsubtitleintro: "Introduction Française",
        docsubtitlemain: "Titre Principal",
        docsubtitlepart: "Part du Titre",
        docsubtitlepartlabel: "Partie\u00a01",
        doctitle: "Introduction&#xa0;&#x2014; Main Title\u2009—\u2009Title&#xa0;&#x2014; Part\u00a01: Title Part",
        doctitleadd: "Mass fraction of extraneous matter, milled rice (nonglutinous), sample dividers and recommendations relating to storage and transport conditions",
        doctitleaddlabel: "ADDENDUM\u00a01",
        doctitlecorrlabel: "TECHNICAL CORRIGENDUM\u00a02",
        doctitleintro: "Introduction",
        doctitlemain: "Main Title\u2009\u2014\u2009Title",
        doctitlepart: "Title Part",
        doctitlepartlabel: "Part\u00a01",
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
        script: "Latn",
        stage: "10",
        stage_int: 10,
        stageabbr: "NWIP",
        statusabbr: "PreNWIP3",
        substage_int: "20",
        unpublished: true }
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
          <title format="text/plain" language="en" type="title-part-prefix">Part 1</title>
          <title format="text/plain" language="en" type="title-amendment-prefix">AMENDMENT 1</title>
          <title format="text/plain" language="en" type="title-corrigendum-prefix">TECHNICAL CORRIGENDUM 2</title>
          <ext>
            <doctype>addendum</doctype>
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
          <title format="text/plain" language="en" type="title-part-prefix">Part 1</title>
          <title format="text/plain" language="en" type="title-amendment-prefix">AMENDMENT 1</title>
          <title format="text/plain" language="en" type="title-corrigendum-prefix">TECHNICAL CORRIGENDUM 2</title>
          <ext>
            <doctype language="">addendum</doctype>
            <doctype language="en">Addendum</doctype>
            <structuredidentifier>
              <project-number amendment="1" corrigendum="2" origyr="2016-05-01" part="1">17301</project-number>
            </structuredidentifier>
          </ext>
        </bibdata>
        <preface>
          <clause type="toc" id="_" displayorder="1">
                   <title depth="1" id="_">Contents</title>
         <fmt-title id="_" depth="1">
               <semx element="title" source="_">Contents</semx>
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
          <clause id="_" displayorder="5">
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
             </clause>
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
             <div id="_">
               <h1>1</h1>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_html5_equivalent_to html
  end

  it "processes amend subclauses" do
    input = <<~INPUT
            <standard-document xmlns='https://www.metanorma.org/ns/standoc'>
                 <bibdata type='standard'>
                   <title language='en' format='text/plain'>Document title</title>
                   <language>en</language>
                   <script>Latn</script>
                   <status>
                     <stage>published</stage>
                   </status>
                   <copyright>
                     <from>2020</from>
                   </copyright>
                   <ext>
                     <doctype>amendment</doctype>
                   </ext>
                 </bibdata>
                 <sections>
                   <clause id='A' inline-header='false' obligation='normative'>
                     <title>Change Clause</title>
                     <amend id="_2ecb7ba1-ced4-18d1-bc8c-d7d03139b0de" change="add">
                     <autonumber type="example">10</autonumber>
                     <autonumber type='clause'>3.1.2.14</autonumber>
                        <description><p id="_5162a644-6c8a-c719-da08-3a79c4b52e06">Add the following terminological entries after 3.1.2.13:</p></description><newcontent>
                                        <example id='F'>
                           <p id='G'>This is not generalised further.</p>
                         </example>
      <clause id="_813c4603-f691-7798-852f-962a3686c35b" inline-header="false" obligation="normative">
      <title id="_d1ac9d3a-cabe-0e32-34f6-e6a8cf430fdf"><br/>canonical form</title>


      <p id="_144e133e-157f-fe37-f92b-0b4f4957c772">date and time expression where all its time scale components are <em>normalised</em> (3.1.2.15)</p>

      <example id="_ae7b575c-a248-e0c3-08e4-8a81f77bf1e7"><p id="_aa5637f7-8d6c-7be0-8841-5b529c05016e">example</p>
      </example>

      <note id="_adf7a5b8-f42d-92a4-3a5f-8f0b705ada16"><p id="_20334171-4bec-169b-3537-f090c6f2a415">Note 1 to entry: A</p>
      </note>

      <table id="_e7f7af33-50be-609f-7371-4b41d7cfb044"><tbody><tr id="_0f1bd2b3-ed7d-a2e8-a14d-5bd2e777d10b"><td id="_f52d480e-d647-33df-7f57-9ba9b36fe6b9" valign="top" align="left">A</td>
      <td id="_fff6ab0f-6be2-d2f4-4d1b-2f3acbff0321" valign="top" align="left">B</td>
      </tr></tbody>
      </table>
      <autonumber type="example">1</autonumber><autonumber type="table">3</autonumber></clause>
      <clause id="xxx"><title>container</title>
      <p>This is a container of a subclause.</p>
      <clause id="xxy" inline-header="false" obligation="normative">
      <title id="_f88ca02a-e3cf-23b0-0ae4-c113bacffa23">non-canonical form</title>


      <p id="_89d15cba-4db5-02f0-9b84-945c5fdd9966">date and time expression where all its time scale components are <em>unnormalised</em> (3.1.2.1511)</p>

      <example id="_f7af314a-70ec-dce3-920f-3ef224772bfe"><p id="_decaf598-4bc9-73d4-e063-3d21387462f8">example</p>
      </example>

      <note id="_da1d6423-d4cc-253a-217d-ee7b7d17ea5e"><p id="_011888c1-793b-12d1-685d-5da27c4debf8">A</p>
      </note>

      <table id="_3fd93bf4-cb80-ba33-f5ed-b708be27ea0e"><tbody><tr id="_e4e36c14-b89f-7283-4e29-a5e8d9a0c828"><td id="_c72c6213-228c-006b-1699-83f8f2251c42" valign="top" align="left">A</td>
      <td id="_2d29edc6-6006-e485-0631-7adf754fefd4" valign="top" align="left">B</td>
      </tr></tbody>
      </table>
      <autonumber type="example">1</autonumber><autonumber type="note">1</autonumber><autonumber type="table">4</autonumber></clause></newcontent></amend>
      </clause>
                  </clause>
                  </sections>
                  </standard-document>
    INPUT
    presxml = <<~INPUT
       <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
          <bibdata type="standard">
             <title language="en" format="text/plain">Document title</title>
             <language current="true">en</language>
             <script current="true">Latn</script>
             <status>
                <stage>published</stage>
             </status>
             <copyright>
                <from>2020</from>
             </copyright>
             <ext>
                <doctype language="">amendment</doctype>
                <doctype language="en">Amendment</doctype>
             </ext>
          </bibdata>
          <sections>
             <clause id="A" inline-header="false" obligation="normative" displayorder="1">
                <title id="_">Change Clause</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Change Clause</semx>
                </fmt-title>
                <amend id="_" change="add">
                   <autonumber type="example">10</autonumber>
                   <autonumber type="clause">3.1.2.14</autonumber>
                   <description>
                      <p original-id="_">Add the following terminological entries after 3.1.2.13:</p>
                   </description>
                   <newcontent>
                      <example number="10" original-id="F">
                         <p original-id="G">This is not generalised further.</p>
                      </example>
                      <clause inline-header="false" obligation="normative" number="3.1.2.14" original-id="_">
                         <title id="_">
                            <br/>
                            canonical form
                         </title>
                         <p original-id="_">
                            date and time expression where all its time scale components are
                            <em>normalised</em>
                            (3.1.2.15)
                         </p>
                         <example original-id="_">
                            <p original-id="_">example</p>
                         </example>
                         <note unnumbered="true" original-id="_">
                            <p original-id="_">Note 1 to entry: A</p>
                         </note>
                         <table number="3" original-id="_">
                            <tbody>
                               <tr original-id="_">
                                  <td valign="top" align="left" original-id="_">A</td>
                                  <td valign="top" align="left" original-id="_">B</td>
                               </tr>
                            </tbody>
                         </table>
                         <autonumber type="example">1</autonumber>
                         <autonumber type="table">3</autonumber>
                      </clause>
                      <clause original-id="xxx">
                         <title>container</title>
                         <p>This is a container of a subclause.</p>
                         <clause inline-header="false" obligation="normative" original-id="xxy">
                            <title id="_">non-canonical form</title>
                            <p original-id="_">
                               date and time expression where all its time scale components are
                               <em>unnormalised</em>
                               (3.1.2.1511)
                            </p>
                            <example original-id="_">
                               <p original-id="_">example</p>
                            </example>
                            <note number="1" original-id="_">
                               <p original-id="_">A</p>
                            </note>
                            <table number="4" original-id="_">
                               <tbody>
                                  <tr original-id="_">
                                     <td valign="top" align="left" original-id="_">A</td>
                                     <td valign="top" align="left" original-id="_">B</td>
                                  </tr>
                               </tbody>
                            </table>
                            <autonumber type="example">1</autonumber>
                            <autonumber type="note">1</autonumber>
                            <autonumber type="table">4</autonumber>
                         </clause>
                      </clause>
                   </newcontent>
                </amend>
                <semx element="amend" source="_">
                   <p id="_">Add the following terminological entries after 3.1.2.13:</p>
                   <quote type="newcontent">
                      <example id="F" number="10" autonum="10">
                         <fmt-name id="_">
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">EXAMPLE</span>
                               <semx element="autonum" source="F">10</semx>
                            </span>
                         </fmt-name>
                         <fmt-xref-label>
                            <span class="fmt-element-name">Example</span>
                            <semx element="autonum" source="F">10</semx>
                         </fmt-xref-label>
                         <fmt-xref-label container="A">
                            <span class="fmt-xref-container">
                               <span class="fmt-element-name">Clause</span>
                               <semx element="autonum" source="A">1</semx>
                            </span>
                            <span class="fmt-comma">,</span>
                            <span class="fmt-element-name">Example</span>
                            <semx element="autonum" source="F">10</semx>
                         </fmt-xref-label>
                         <p id="G">This is not generalised further.</p>
                      </example>
                   </quote>
                   <quote id="_" inline-header="false" obligation="normative" number="3.1.2.14" type="newcontent">
                      <p depth="1" type="floating-title">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="_">3.1.2.14</semx>
                         </span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                         <semx element="title" source="_">
                            <br/>
                            canonical form
                         </semx>
                      </p>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Clause</span>
                         <semx element="autonum" source="_">3.1.2.14</semx>
                      </fmt-xref-label>
                      <p id="_">
                         date and time expression where all its time scale components are
                         <em>normalised</em>
                         (3.1.2.15)
                      </p>
                      <example id="_" autonum="11">
                         <fmt-name id="_">
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">EXAMPLE</span>
                               <semx element="autonum" source="_">11</semx>
                            </span>
                         </fmt-name>
                         <fmt-xref-label>
                            <span class="fmt-element-name">Example</span>
                            <semx element="autonum" source="_">11</semx>
                         </fmt-xref-label>
                         <fmt-xref-label container="_">
                            <span class="fmt-xref-container">
                               <span class="fmt-element-name">Clause</span>
                               <semx element="autonum" source="_">3.1.2.14</semx>
                            </span>
                            <span class="fmt-comma">,</span>
                            <span class="fmt-element-name">Example</span>
                            <semx element="autonum" source="_">11</semx>
                         </fmt-xref-label>
                         <p id="_">example</p>
                      </example>
                      <note id="_" unnumbered="true">
                         <p id="_">Note 1 to entry: A</p>
                      </note>
                      <table id="_" number="3" autonum="3">
                         <fmt-name id="_">
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="_">3</semx>
                            </span>
                         </fmt-name>
                         <fmt-xref-label>
                            <span class="fmt-element-name">Table</span>
                            <semx element="autonum" source="_">3</semx>
                         </fmt-xref-label>
                         <tbody>
                            <tr id="_">
                               <td id="_" valign="top" align="left">A</td>
                               <td id="_" valign="top" align="left">B</td>
                            </tr>
                         </tbody>
                      </table>
                   </quote>
                   <quote id="xxx" type="newcontent">
                      <p depth="1" type="floating-title">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="xxx">3.1.2.15</semx>
                         </span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                         <semx element="title" source="_">container</semx>
                      </p>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Clause</span>
                         <semx element="autonum" source="xxx">3.1.2.15</semx>
                      </fmt-xref-label>
                      <p>This is a container of a subclause.</p>
                      <quote id="xxy" inline-header="false" obligation="normative" type="newcontent">
                         <p depth="2" type="floating-title">
                            <span class="fmt-caption-label">
                               <semx element="autonum" source="xxx">3.1.2.15</semx>
                               <span class="fmt-autonum-delim">.</span>
                               <semx element="autonum" source="xxy">1</semx>
                            </span>
                            <span class="fmt-caption-delim">
                               <tab/>
                            </span>
                            <semx element="title" source="_">non-canonical form</semx>
                         </p>
                         <fmt-xref-label>
                            <semx element="autonum" source="xxx">3.1.2.15</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="xxy">1</semx>
                         </fmt-xref-label>
                         <p id="_">
                            date and time expression where all its time scale components are
                            <em>unnormalised</em>
                            (3.1.2.1511)
                         </p>
                         <example id="_" autonum="12">
                            <fmt-name id="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">EXAMPLE</span>
                                  <semx element="autonum" source="_">12</semx>
                               </span>
                            </fmt-name>
                            <fmt-xref-label>
                               <span class="fmt-element-name">Example</span>
                               <semx element="autonum" source="_">12</semx>
                            </fmt-xref-label>
                            <fmt-xref-label container="xxy">
                               <span class="fmt-xref-container">
                                  <semx element="autonum" source="xxx">3.1.2.15</semx>
                                  <span class="fmt-autonum-delim">.</span>
                                  <semx element="autonum" source="xxy">1</semx>
                               </span>
                               <span class="fmt-comma">,</span>
                               <span class="fmt-element-name">Example</span>
                               <semx element="autonum" source="_">12</semx>
                            </fmt-xref-label>
                            <p id="_">example</p>
                         </example>
                         <note id="_" number="1" autonum="1">
                            <fmt-name id="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">NOTE</span>
                                  <semx element="autonum" source="_">1</semx>
                               </span>
                               <span class="fmt-label-delim">
                                  <tab/>
                               </span>
                            </fmt-name>
                            <fmt-xref-label>
                               <span class="fmt-element-name">Note</span>
                               <semx element="autonum" source="_">1</semx>
                            </fmt-xref-label>
                            <fmt-xref-label container="xxy">
                               <span class="fmt-xref-container">
                                  <semx element="autonum" source="xxx">3.1.2.15</semx>
                                  <span class="fmt-autonum-delim">.</span>
                                  <semx element="autonum" source="xxy">1</semx>
                               </span>
                               <span class="fmt-comma">,</span>
                               <span class="fmt-element-name">Note</span>
                               <semx element="autonum" source="_">1</semx>
                            </fmt-xref-label>
                            <p id="_">A</p>
                         </note>
                         <table id="_" number="4" autonum="4">
                            <fmt-name id="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">Table</span>
                                  <semx element="autonum" source="_">4</semx>
                               </span>
                            </fmt-name>
                            <fmt-xref-label>
                               <span class="fmt-element-name">Table</span>
                               <semx element="autonum" source="_">4</semx>
                            </fmt-xref-label>
                            <tbody>
                               <tr id="_">
                                  <td id="_" valign="top" align="left">A</td>
                                  <td id="_" valign="top" align="left">B</td>
                               </tr>
                            </tbody>
                         </table>
                      </quote>
                   </quote>
                </semx>
             </clause>
          </sections>
       </standard-document>
    INPUT
    html = <<~OUTPUT
       <div id="A">
       <h1>Change Clause</h1>
          <p id="_">Add the following terminological entries after 3.1.2.13:</p>
          <div class="Quote AmendNewcontent">
             <div id="F" class="example">
                <p>
                   <span class="example_label">EXAMPLE 10</span>
                     This is not generalised further.
                </p>
             </div>
          </div>
          <div class="Quote AmendNewcontent" id="_">
             <p class="h1">
                3.1.2.14 
                <br/>
                canonical form
             </p>
             <p id="_">
                date and time expression where all its time scale components are
                <i>normalised</i>
                (3.1.2.15)
             </p>
             <div id="_" class="example">
                <p>
                   <span class="example_label">EXAMPLE 11</span>
                     example
                </p>
             </div>
             <div id="_" class="Note">
                <p>Note 1 to entry: A</p>
             </div>
             <table id="_" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                <caption>Table 3</caption>
                <tbody>
                   <tr>
                      <td style="text-align:left;vertical-align:top;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">A</td>
                      <td style="text-align:left;vertical-align:top;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">B</td>
                   </tr>
                </tbody>
             </table>
          </div>
          <div class="Quote AmendNewcontent" id="xxx">
             <p class="h1">3.1.2.15  container</p>
             <p>This is a container of a subclause.</p>
             <div class="Quote AmendNewcontent" id="xxy">
                <p class="h2">3.1.2.15.1  non-canonical form</p>
                <p id="_">
                   date and time expression where all its time scale components are
                   <i>unnormalised</i>
                   (3.1.2.1511)
                </p>
                <div id="_" class="example">
                   <p>
                      <span class="example_label">EXAMPLE 12</span>
                        example
                   </p>
                </div>
                <div id="_" class="Note">
                   <p>
                      <span class="note_label">NOTE 1  </span>
                      A
                   </p>
                </div>
                <table id="_" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                   <caption>Table 4</caption>
                   <tbody>
                      <tr>
                         <td style="text-align:left;vertical-align:top;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">A</td>
                         <td style="text-align:left;vertical-align:top;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">B</td>
                      </tr>
                   </tbody>
                </table>
             </div>
          </div>
       </div>
    OUTPUT

    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))
      .at("//div[@id ='A']").to_xml)))
      .to be_equivalent_to Canon.format_xml(html)

    presxml = <<~OUTPUT
       <semx element="amend" source="_">
          <p id="_">Add the following terminological entries after 3.1.2.13:</p>
          <quote type="newcontent">
             <example id="F" number="10" autonum="10">
                <fmt-name id="_">
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">EXAMPLE</span>
                      <semx element="autonum" source="F">10</semx>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="F">10</semx>
                </fmt-xref-label>
                <fmt-xref-label container="A">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="A">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="F">10</semx>
                </fmt-xref-label>
                <p id="G">This is not generalised further.</p>
             </example>
          </quote>
          <quote type="newcontent" id="_" inline-header="false" obligation="normative" number="3.1.2.14" autonum="3.1.2.14">
             <p type="floating-title">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="_">3.1.2.14</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">(normative)</span>
                <span class="fmt-caption-delim">
                   <br/>
                   <br/>
                </span>
                <semx element="title" source="_">
                   <strong>
                      <br/>
                      canonical form
                   </strong>
                </semx>
             </p>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="_">3.1.2.14</semx>
             </fmt-xref-label>
             <p id="_">
                date and time expression where all its time scale components are
                <em>normalised</em>
                (3.1.2.15)
             </p>
             <example id="_" autonum="11">
                <fmt-name id="_">
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">EXAMPLE</span>
                      <semx element="autonum" source="_">11</semx>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="_">11</semx>
                </fmt-xref-label>
                <fmt-xref-label container="_">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="_">3.1.2.14</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="_">11</semx>
                </fmt-xref-label>
                <p id="_">example</p>
             </example>
             <note id="_" unnumbered="true">
                <p id="_">Note 1 to entry: A</p>
             </note>
             <table id="_" number="3" autonum="3">
                <fmt-name id="_">
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="_">3</semx>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="_">3</semx>
                </fmt-xref-label>
                <tbody>
                   <tr id="_">
                      <td id="_" valign="top" align="left">A</td>
                      <td id="_" valign="top" align="left">B</td>
                   </tr>
                </tbody>
             </table>
          </quote>
          <quote id="xxx" type="newcontent">
             <p depth="1" type="floating-title">
                <span class="fmt-caption-label">
                   <semx element="autonum" source="xxx">3.1.2.15</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">container</semx>
             </p>
             <fmt-xref-label>
                <span class="fmt-element-name">Clause</span>
                <semx element="autonum" source="xxx">3.1.2.15</semx>
             </fmt-xref-label>
             <p>This is a container of a subclause.</p>
             <quote id="xxy" inline-header="false" obligation="normative" type="newcontent">
                <p depth="2" type="floating-title">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="xxx">3.1.2.15</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="xxy">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">non-canonical form</semx>
                </p>
                <fmt-xref-label>
                   <semx element="autonum" source="xxx">3.1.2.15</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="xxy">1</semx>
                </fmt-xref-label>
                <p id="_">
                   date and time expression where all its time scale components are
                   <em>unnormalised</em>
                   (3.1.2.1511)
                </p>
                <example id="_" autonum="12">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">EXAMPLE</span>
                         <semx element="autonum" source="_">12</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Example</span>
                      <semx element="autonum" source="_">12</semx>
                   </fmt-xref-label>
                   <fmt-xref-label container="xxy">
                      <span class="fmt-xref-container">
                         <semx element="autonum" source="xxx">3.1.2.15</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="xxy">1</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Example</span>
                      <semx element="autonum" source="_">12</semx>
                   </fmt-xref-label>
                   <p id="_">example</p>
                </example>
                <note id="_" number="1" autonum="1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                         <semx element="autonum" source="_">1</semx>
                      </span>
                      <span class="fmt-label-delim">
                         <tab/>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Note</span>
                      <semx element="autonum" source="_">1</semx>
                   </fmt-xref-label>
                   <fmt-xref-label container="xxy">
                      <span class="fmt-xref-container">
                         <semx element="autonum" source="xxx">3.1.2.15</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="xxy">1</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Note</span>
                      <semx element="autonum" source="_">1</semx>
                   </fmt-xref-label>
                   <p id="_">A</p>
                </note>
                <table id="_" number="4" autonum="4">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Table</span>
                         <semx element="autonum" source="_">4</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="_">4</semx>
                   </fmt-xref-label>
                   <tbody>
                      <tr id="_">
                         <td id="_" valign="top" align="left">A</td>
                         <td id="_" valign="top" align="left">B</td>
                      </tr>
                   </tbody>
                </table>
             </quote>
          </quote>
       </semx>
    OUTPUT

    input.sub!('<clause id="_813c4603-f691-7798-852f-962a3686c35b"',
               '<clause type="annex" id="_813c4603-f691-7798-852f-962a3686c35b"')
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    pres_output = Nokogiri::XML(pres_output).at("//xmlns:semx[@element='amend']")
    expect(strip_guid(Canon.format_xml(pres_output.to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
  end
end

