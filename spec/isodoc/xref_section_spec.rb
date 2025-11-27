require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references clauses" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
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
              <xref target="M1"/>
              <xref target="M" style="title"/>
              <xref target="N" style="title"/>
              <xref target="O" style="title"/>
              <xref target="M1" style="title"/>
              <xref target="P"/>
              <xref target="Q"/>
              <xref target="Q1"/>
              <xref target="Q2"/>
              <xref target="Q3"/>
              <xref target="Q4"/>
              <xref target="QQ"/>
              <xref target="QQ1"/>
              <xref target="QQ2"/>
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
          <terms id="H" obligation="normative">
            <title>Terms, definitions, symbols and abbreviated terms</title>
            <terms id="I" obligation="normative">
              <title>Normal Terms</title>
              <term id="J">
                <preferred><expression><name>Term2</name></expression></preferred>
              </term>
            </terms>
            <definitions id="K">
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </terms>
          <definitions id="L">
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative">
            <title>Title A</title>
            <clause id="N" inline-header="false" obligation="normative">
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title>Title B</title>
            </clause>
          </clause>
          <clause id="M1" inline-header="false" obligation="normative">
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
            <clause id="Q3" inline-header="false" obligation="normative">
              <title>Appendix subclause</title>
            <clause id="Q4" inline-header="false" obligation="normative">
              <title>Appendix subclause</title>
              </clause>
            </clause>
          </appendix>
        </annex>
       <annex id="QQ">
       <terms id="QQ1">
       <term id="QQ2"/>
       </terms>
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
    output = <<~OUTPUT
      <foreword obligation="informative" displayorder="2" id="_">
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
               <fmt-xref target="H">
                  <span class="citesec">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="H">3</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="I" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="I">
                  <span class="citesec">
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="I">1</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="J" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="J">
                  <span class="citesec">
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="I">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="J">1</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="K" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="K">
                  <span class="citesec">
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="K">2</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="L" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="L">
                  <span class="citesec">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="L">4</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="M" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="M">
                  <span class="citesec">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="M">5</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="N" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N">
                  <span class="citesec">
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="O" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="O">
                  <span class="citesec">
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="O">2</semx>
                  </span>
               </fmt-xref>
            </semx>
                  <xref target="M1" id="_"/>
      <semx element="xref" source="_">
         <fmt-xref target="M1">
            <span class="citesec">
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="M1">6</semx>
            </span>
         </fmt-xref>
      </semx>
      <xref target="M" style="title" id="_"/>
      <semx element="xref" source="_">
         <fmt-xref target="M" style="title">
            <span class="citesec">
               <semx element="title" source="M">Title A</semx>
            </span>
         </fmt-xref>
      </semx>
      <xref target="N" style="title" id="_"/>
      <semx element="xref" source="_">
         <fmt-xref target="N" style="title">
            <span class="citesec">
               <semx element="autonum" source="M">5</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="N">1</semx>
            </span>
         </fmt-xref>
      </semx>
      <xref target="O" style="title" id="_"/>
      <semx element="xref" source="_">
         <fmt-xref target="O" style="title">
            <span class="citesec">Title B</span>
         </fmt-xref>
      </semx>
      <xref target="M1" style="title" id="_"/>
      <semx element="xref" source="_">
         <fmt-xref target="M1" style="title">
            <span class="citesec">
               <span class="fmt-element-name">Clause</span>
               <semx element="autonum" source="M1">6</semx>
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
            <xref target="Q3" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Q3">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="P">A</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Appendix</span>
                  <semx element="autonum" source="Q2">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q3">1</semx>
               </fmt-xref>
            </semx>
            <xref target="Q4" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="Q4">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="P">A</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Appendix</span>
                  <semx element="autonum" source="Q2">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q3">1</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q4">1</semx>
               </fmt-xref>
            </semx>
            <xref target="QQ" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="QQ">
                  <span class="citeapp">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="QQ">B</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="QQ1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="QQ1">
                  <span class="citeapp">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="QQ1">B</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="QQ2" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="QQ2">
                  <span class="citeapp">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="QQ1">B</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="QQ2">1</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="R" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="R">
                  <span class="citesec">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="R">2</semx>
                  </span>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "prefix subclauses if so specified in i18n" do
    mock_i18n
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble
              <xref target="M"/>
              <xref target="N"/>
              <xref target="O"/>
              <xref target="M1"/>
              <xref target="M" style="title"/>
              <xref target="N" style="title"/>
              <xref target="O" style="title"/>
              <xref target="M1" style="title"/>
              </p>
          </foreword>
                  <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
          <terms id="H" obligation="normative">
            <title>Terms, definitions, symbols and abbreviated terms</title>
            <terms id="I" obligation="normative">
              <title>Normal Terms</title>
              <term id="J">
                <preferred><expression><name>Term2</name></expression></preferred>
              </term>
            </terms>
            <definitions id="K">
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </terms>
          <definitions id="L">
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative">
            <title>Title A</title>
            <clause id="N" inline-header="false" obligation="normative">
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title>Title B</title>
            </clause>
          </clause>
          <clause id="M1" inline-header="false" obligation="normative">
          </clause>
        </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <foreword obligation="informative" id="_" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title depth="1" id="_">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p id="A">
            This is a preamble
            <xref target="M" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="M">
                  <span class="citesec">
                     <span class="fmt-element-name">Klaŭzo</span>
                     <semx element="autonum" source="M">4</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="N" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N">
                  <span class="citesec">
                     <span class="fmt-element-name">Subklaŭzo</span>
                     <semx element="autonum" source="M">4</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="O" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="O">
                  <span class="citesec">
                     <span class="fmt-element-name">Subklaŭzo</span>
                     <semx element="autonum" source="M">4</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="O">2</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="M1" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="M1">
                  <span class="citesec">
                     <span class="fmt-element-name">Klaŭzo</span>
                     <semx element="autonum" source="M1">5</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="M" style="title" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="M" style="title">
                  <span class="citesec">
                     <semx element="title" source="M">Title A</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="N" style="title" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N" style="title">
                  <span class="citesec">
                     <span class="fmt-element-name">Subklaŭzo</span>
                     <semx element="autonum" source="M">4</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="O" style="title" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="O" style="title">
                  <span class="citesec">Title B</span>
               </fmt-xref>
            </semx>
            <xref target="M1" style="title" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="M1" style="title">
                  <span class="citesec">
                     <span class="fmt-element-name">Klaŭzo</span>
                     <semx element="autonum" source="M1">5</semx>
                  </span>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT

    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options
          .merge({ i18nyaml: "spec/assets/i18n.yaml" }))
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "cross-references sections" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble
              <xref target="B"/>
              <xref target="D"/>
              <xref target="T"/>
              <xref target="H"/>
              <xref target="I"/>
              <xref target="J"/>
              <xref target="K"/>
              <xref target="L"/>
              <xref target="M"/>
              <xref target="N"/>
              </p>
          </foreword>
        </preface>
        <sections>
        <clause type="section" id="B"><title>General</title>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
            <references id='T' normative='false' obligation='informative'>
              <title depth='2'>Bibliography Subsection</title>
            </references>
          <terms id="H" obligation="normative">
            <title>Terms, definitions, symbols and abbreviated terms</title>
            <terms id="I" obligation="normative">
              <title>Normal Terms</title>
              <term id="J">
                <preferred><expression><name>Term2</name></expression></preferred>
              </term>
            </terms>
            <definitions id="K">
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </terms>
          <definitions id="L">
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative">
            <title>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title>Introduction</title>
            </clause>
            </clause>
            </clause>
            </sections>
            </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword obligation="informative" displayorder="2" id="_">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p id="A">
            This is a preamble
            <xref target="B" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="B">
                  <span class="citesec">
                     <span class="fmt-element-name">Section</span>
                     <semx element="autonum" source="B">1</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="D" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="D">
                  <span class="citesec">
                     <semx element="autonum" source="B">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="D">1</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="T" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="T">
                  <span class="citesec">
                     <semx element="autonum" source="B">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="T">2</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="H" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="H">
                  <span class="citesec">
                     <semx element="autonum" source="B">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="H">3</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="I" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="I">
                  <span class="citesec">
                     <semx element="autonum" source="B">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="I">1</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="J" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="J">
                  <span class="citesec">
                     <semx element="autonum" source="B">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="I">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="J">1</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="K" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="K">
                  <span class="citesec">
                     <semx element="autonum" source="B">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="H">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="K">2</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="L" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="L">
                  <span class="citesec">
                     <semx element="autonum" source="B">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="L">4</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="M" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="M">
                  <span class="citesec">
                     <semx element="autonum" source="B">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="M">5</semx>
                  </span>
               </fmt-xref>
            </semx>
            <xref target="N" id="_"/>
            <semx element="xref" source="_">
               <fmt-xref target="N">
                  <span class="citesec">
                     <semx element="autonum" source="B">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </span>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  private

  def mock_i18n
    allow_any_instance_of(IsoDoc::I18n)
      .to receive(:load_yaml)
      .with(anything, "Latn", nil, anything)
      .and_return(IsoDoc::I18n.new("eo", "Latn")
      .normalise_hash(YAML.load_file("spec/assets/i18n.yaml")))
    allow_any_instance_of(IsoDoc::I18n)
      .to receive(:load_yaml)
      .with(anything, "Latn", "spec/assets/i18n.yaml", anything)
      .and_return(IsoDoc::I18n.new("eo", "Latn")
      .normalise_hash(YAML.load_file("spec/assets/i18n.yaml")))
  end
end
