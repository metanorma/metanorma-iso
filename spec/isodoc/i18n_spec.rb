require "spec_helper"

RSpec.describe IsoDoc do
  it "processes English" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status>
            <stage abbreviation='IS' language=''>60</stage>
          </status>
          <language>en</language>
          <ext>
            <doctype language=''>international-standard</doctype>
          </ext>
        </bibdata>
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
        </preface>
        <sections>
          <clause id="D0" type="section"><title>General</title></clause>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative">
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
          </clause>
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

    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <status>
               <stage abbreviation="IS" language="">60</stage>
               <stage abbreviation="IS" language="en">International Standard</stage>
            </status>
            <language current="true">en</language>
            <ext>
               <doctype language="">international-standard</doctype>
               <doctype language="en">International Standard</doctype>
            </ext>
         </bibdata>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Contents</fmt-title>
            </clause>
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
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="B">0</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="C">1</semx>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Introduction Subsection</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <semx element="autonum" source="B">0</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="C">1</semx>
                  </fmt-xref-label>
               </clause>
               <p>This is patent boilerplate</p>
            </introduction>
         </preface>
         <sections>
            <clause id="D0" type="section" displayorder="6">
               <title id="_">General</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Section</span>
                     <semx element="autonum" source="D0">3</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     :
                     <tab/>
                  </span>
                  <semx element="title" source="_">General</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Section</span>
                  <semx element="autonum" source="D0">3</semx>
               </fmt-xref-label>
            </clause>
            <clause id="D" obligation="normative" type="scope" displayorder="4">
               <title id="_">Scope</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="D">1</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Scope</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="D">1</semx>
               </fmt-xref-label>
               <p id="E">Text</p>
            </clause>
            <clause id="H" obligation="normative" displayorder="7">
               <title id="_">Terms, definitions, symbols and abbreviated terms</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="H">4</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Terms, definitions, symbols and abbreviated terms</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="H">4</semx>
               </fmt-xref-label>
               <terms id="I" obligation="normative">
                  <title id="_">Normal Terms</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">4</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="I">1</semx>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Normal Terms</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <semx element="autonum" source="H">4</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="I">1</semx>
                  </fmt-xref-label>
                  <term id="J">
                     <fmt-name id="_">
                        <span class="fmt-caption-label">
                           <semx element="autonum" source="H">4</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="I">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="J">1</semx>
                        </span>
                     </fmt-name>
                     <fmt-xref-label>
                        <semx element="autonum" source="H">4</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="I">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="J">1</semx>
                     </fmt-xref-label>
                     <preferred id="_">
                        <expression>
                           <name>Term2</name>
                        </expression>
                     </preferred>
                     <fmt-preferred>
                        <p>
                           <semx element="preferred" source="_">
                              <strong>Term2</strong>
                           </semx>
                        </p>
                     </fmt-preferred>
                  </term>
               </terms>
               <definitions id="K">
                  <title id="_">Symbols</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">4</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="K">2</semx>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Symbols</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <semx element="autonum" source="H">4</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="K">2</semx>
                  </fmt-xref-label>
                  <dl>
                     <dt>Symbol</dt>
                     <dd>Definition</dd>
                  </dl>
               </definitions>
            </clause>
            <definitions id="L" displayorder="8">
               <title id="_">Symbols</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="L">5</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Symbols</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="L">5</semx>
               </fmt-xref-label>
               <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
               </dl>
            </definitions>
            <clause id="M" inline-header="false" obligation="normative" displayorder="9">
               <title id="_">Clause 4</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="M">6</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Clause 4</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="M">6</semx>
               </fmt-xref-label>
               <clause id="N" inline-header="false" obligation="normative">
                  <title id="_">Introduction</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">6</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="N">1</semx>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Introduction</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <semx element="autonum" source="M">6</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </fmt-xref-label>
               </clause>
               <clause id="O" inline-header="false" obligation="normative">
                  <title id="_">Clause 4.2</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">6</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="O">2</semx>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Clause 4.2</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <semx element="autonum" source="M">6</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="O">2</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
            <references id="R" normative="true" obligation="informative" displayorder="5">
               <title id="_">Normative References</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="R">2</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Normative References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="R">2</semx>
               </fmt-xref-label>
            </references>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="10">
            <title id="_">
               <strong>Annex</strong>
            </title>
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
            <appendix id="Q2" inline-header="false" obligation="normative" autonum="1">
               <title id="_">An Appendix</title>
               <fmt-title id="_" depth="2">
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Appendix</span>
                     <semx element="autonum" source="Q2">1</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">An Appendix</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Appendix</span>
                  <semx element="autonum" source="Q2">1</semx>
               </fmt-xref-label>
               <fmt-xref-label container="P">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="P">A</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Appendix</span>
                  <semx element="autonum" source="Q2">1</semx>
               </fmt-xref-label>
            </appendix>
         </annex>
         <bibliography>
            <clause id="S" obligation="informative" displayorder="11">
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
      #{HTML_HDR}
                      <br/>
                <div id="_">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p id="A">This is a preamble</p>
                </div>
                <br/>
                <div class="Section3" id="B">
                   <h1 class="IntroTitle">Introduction</h1>
                   <div id="C">
                      <h2>0.1  Introduction Subsection</h2>
                   </div>
                   <p>This is patent boilerplate</p>
                </div>
                <div id="D">
                   <h1>1  Scope</h1>
                   <p id="E">Text</p>
                </div>
                <div>
                   <h1>2  Normative References</h1>
                </div>
                <div id="D0">
                   <h1>Section 3:  General</h1>
                </div>
                <div id="H">
                   <h1>4  Terms, definitions, symbols and abbreviated terms</h1>
                   <div id="I">
                      <h2>4.1  Normal Terms</h2>
                      <p class="TermNum" id="J">4.1.1</p>
                      <p class="Terms" style="text-align:left;">
                         <b>Term2</b>
                      </p>
                   </div>
                   <div id="K">
                      <h2>4.2  Symbols</h2>
                      <div class="figdl">
                         <dl>
                            <dt>
                               <p>Symbol</p>
                            </dt>
                            <dd>Definition</dd>
                         </dl>
                      </div>
                   </div>
                </div>
                <div id="L" class="Symbols">
                <h1>5  Symbols</h1>
                   <div class="figdl">
                      <dl>
                         <dt>
                            <p>Symbol</p>
                         </dt>
                         <dd>Definition</dd>
                      </dl>
                   </div>
                </div>
                <div id="M">
                   <h1>6  Clause 4</h1>
                   <div id="N">
                      <h2>6.1  Introduction</h2>
                   </div>
                   <div id="O">
                      <h2>6.2  Clause 4.2</h2>
                   </div>
                </div>
                <br/>
                <div id="P" class="Section3">
                   <h1 class="Annex">
                      <b>Annex A</b>
                      <br/>
                      <span class="obligation">(normative)</span>
                      <br/>
                      <br/>
                      <b>Annex</b>
                   </h1>
                   <div id="Q">
                      <h2>A.1  Annex A.1</h2>
                      <div id="Q1">
                         <h3>A.1.1  Annex A.1a</h3>
                      </div>
                   </div>
                   <div id="Q2">
                      <h2>Appendix 1  An Appendix</h2>
                   </div>
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
    word = <<~WORD
      <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
         <head>
           <style></style>
           <style></style>
         </head>
                   <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
                <p> </p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection2">
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="_" class="TOC">
                   <p class="zzContents">Contents</p>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="_">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p class="ForewordText" id="A">This is a preamble</p>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div class="Section3" id="B">
                   <h1 class="IntroTitle">Introduction</h1>
                   <div id="C">
                      <h2>
                         0.1
                         <span style="mso-tab-count:1">  </span>
                         Introduction Subsection
                      </h2>
                   </div>
                   <p>This is patent boilerplate</p>
                </div>
                <p> </p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection3">
                <div id="D">
                   <h1>
                      1
                      <span style="mso-tab-count:1">  </span>
                      Scope
                   </h1>
                   <p id="E">Text</p>
                </div>
                <div>
                   <h1>
                      2
                      <span style="mso-tab-count:1">  </span>
                      Normative References
                   </h1>
                </div>
                <div id="D0">
                   <h1>
                      Section 3:
                      <span style="mso-tab-count:1">  </span>
                      General
                   </h1>
                </div>
                <div id="H">
                   <h1>
                      4
                      <span style="mso-tab-count:1">  </span>
                      Terms, definitions, symbols and abbreviated terms
                   </h1>
                   <div id="I">
                      <h2>
                         4.1
                         <span style="mso-tab-count:1">  </span>
                         Normal Terms
                      </h2>
                      <p class="TermNum" id="J">4.1.1</p>
                      <p class="Terms" style="text-align:left;">
                         <b>Term2</b>
                      </p>
                   </div>
                   <div id="K">
                      <h2>
                         4.2
                         <span style="mso-tab-count:1">  </span>
                         Symbols
                      </h2>
                      <div align="left">
                      <table class="dl">
                         <tr>
                            <td valign="top" align="left">
                               <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                            </td>
                            <td valign="top">Definition</td>
                         </tr>
                      </table>
                      </div>
                   </div>
                </div>
                <div id="L" class="Symbols">
                   <h1>
                      5
                      <span style="mso-tab-count:1">  </span>
                      Symbols
                   </h1>
                   <div align="left">
                   <table class="dl">
                      <tr>
                         <td valign="top" align="left">
                            <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                         </td>
                         <td valign="top">Definition</td>
                      </tr>
                   </table>
                   </div>
                </div>
                <div id="M">
                   <h1>
                      6
                      <span style="mso-tab-count:1">  </span>
                      Clause 4
                   </h1>
                   <div id="N">
                      <h2>
                         6.1
                         <span style="mso-tab-count:1">  </span>
                         Introduction
                      </h2>
                   </div>
                   <div id="O">
                      <h2>
                         6.2
                         <span style="mso-tab-count:1">  </span>
                         Clause 4.2
                      </h2>
                   </div>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div id="P" class="Section3">
                   <h1 class="Annex">
                      <br/>
                      <span style="font-weight:normal;">(normative)</span>
                      <br/>
                      <br/>
                      <b>Annex</b>
                   </h1>
                   <div id="Q">
                      <h2>
                         A.1
                         <span style="mso-tab-count:1">  </span>
                         Annex A.1
                      </h2>
                      <div id="Q1">
                         <h3>
                            A.1.1
                            <span style="mso-tab-count:1">  </span>
                            Annex A.1a
                         </h3>
                      </div>
                   </div>
                   <div id="Q2">
                      <h2>
                         Appendix 1
                         <span style="mso-tab-count:1">  </span>
                         An Appendix
                      </h2>
                   </div>
                </div>
                <p class="page-break">
                   <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                </p>
                <div>
                   <h1 class="BiblioTitle">Bibliography</h1>
                   <div>
                      <h2 class="BiblioTitle">Bibliography Subsection</h2>
                   </div>
                </div>
             </div>
             <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
             <div class="colophon"/>
          </body>
       </html>
    WORD
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "defaults to English" do
    output = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", <<~"INPUT", true)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
              <status>
              <stage abbreviation='IS' language=''>60</stage>
            </status>
            <language>tlh</language>
            <ext>
              <doctype language=''>international-standard</doctype>
            </ext>
          </bibdata>
          <preface>
            <foreword obligation="informative">
              <title>Foreword</title>
              <p id="A">This is a preamble</p>
            </foreword>
            <introduction id="B" obligation="informative">
              <title>Introduction</title>
              <clause id="C" inline-header="false" obligation="informative">
                <title>Introduction Subsection</title>
              </clause>
              <p>This is patent boilerplate</p>
            </introduction>
          </preface>
          <sections>
            <clause id="D" obligation="normative" type="scope">
              <title>Scope</title>
              <p id="E">Text</p>
            </clause>
            <clause id="H" obligation="normative">
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
            </clause>
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
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(output)
      .at("//xmlns:preface").to_xml)))
      .to be_equivalent_to Canon.format_xml(<<~"OUTPUT")
        <preface>
           <clause type="toc" id="_" displayorder="1">
              <fmt-title id="_" depth="1">Table of contents</fmt-title>
           </clause>
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
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="B">0</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="C">1</semx>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Introduction Subsection</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <semx element="autonum" source="B">0</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="C">1</semx>
                 </fmt-xref-label>
              </clause>
              <p>This is patent boilerplate</p>
           </introduction>
        </preface>
      OUTPUT
  end

  it "processes French" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status>
            <stage abbreviation='IS' language=''>60</stage>
          </status>
          <language>fr</language>
          <ext>
            <doctype language=''>international-standard</doctype>
          </ext>
        </bibdata>
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
        </preface>
        <sections>
          <clause id="D0" type="section"><title>General</title></clause>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative">
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
          </clause>
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

    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <status>
                <stage abbreviation="IS" language="">60</stage>
                <stage abbreviation="IS" language="fr">Norme internationale</stage>
             </status>
             <language current="true">fr</language>
             <ext>
                <doctype language="">international-standard</doctype>
                <doctype language="fr">Norme internationale</doctype>
             </ext>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Sommaire</fmt-title>
             </clause>
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
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="B">0</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="C">1</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="B">0</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="C">1</semx>
                   </fmt-xref-label>
                </clause>
                <p>This is patent boilerplate</p>
             </introduction>
          </preface>
          <sections>
             <clause id="D0" type="section" displayorder="6">
                <title id="_">General</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Section</span>
                      <semx element="autonum" source="D0">3</semx>
                   </span>
                   <span class="fmt-caption-delim">
                       :
                      <tab/>
                   </span>
                   <semx element="title" source="_">General</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Section</span>
                   <semx element="autonum" source="D0">3</semx>
                </fmt-xref-label>
             </clause>
             <clause id="D" obligation="normative" type="scope" displayorder="4">
                <title id="_">Scope</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="D">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Scope</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Article</span>
                   <semx element="autonum" source="D">1</semx>
                </fmt-xref-label>
                <p id="E">Text</p>
             </clause>
             <clause id="H" obligation="normative" displayorder="7">
                <title id="_">Terms, definitions, symbols and abbreviated terms</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="H">4</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Terms, definitions, symbols and abbreviated terms</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Article</span>
                   <semx element="autonum" source="H">4</semx>
                </fmt-xref-label>
                <terms id="I" obligation="normative">
                   <title id="_">Normal Terms</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">4</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Normal Terms</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="H">4</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="I">1</semx>
                   </fmt-xref-label>
                   <term id="J">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="H">4</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="I">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="J">1</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <semx element="autonum" source="H">4</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="J">1</semx>
                      </fmt-xref-label>
                      <preferred id="_">
                         <expression>
                            <name>Term2</name>
                         </expression>
                      </preferred>
                      <fmt-preferred>
                         <p>
                            <semx element="preferred" source="_">
                               <strong>Term2</strong>
                            </semx>
                         </p>
                      </fmt-preferred>
                   </term>
                </terms>
                <definitions id="K">
                   <title id="_">Symboles</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">4</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="K">2</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Symboles</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="H">4</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="K">2</semx>
                   </fmt-xref-label>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" displayorder="8">
                <title id="_">Symboles</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="L">5</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Symboles</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Article</span>
                   <semx element="autonum" source="L">5</semx>
                </fmt-xref-label>
                <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="9">
                <title id="_">Clause 4</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="M">6</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 4</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Article</span>
                   <semx element="autonum" source="M">6</semx>
                </fmt-xref-label>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">6</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="N">1</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Introduction</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="M">6</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="N">1</semx>
                   </fmt-xref-label>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">6</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="O">2</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Clause 4.2</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="M">6</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="O">2</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
             <references id="R" normative="true" obligation="informative" displayorder="5">
                <title id="_">Normative References</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="R">2</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Article</span>
                   <semx element="autonum" source="R">2</semx>
                </fmt-xref-label>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="10">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annexe</span>
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
                <span class="fmt-element-name">Annexe</span>
                <semx element="autonum" source="P">A</semx>
             </fmt-xref-label>
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
                   <span class="fmt-element-name">Article</span>
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
             <appendix id="Q2" inline-header="false" obligation="normative" autonum="1">
                <title id="_">An Appendix</title>
                <fmt-title id="_" depth="2">
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Appendice</span>
                      <semx element="autonum" source="Q2">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">An Appendix</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Appendice</span>
                   <semx element="autonum" source="Q2">1</semx>
                </fmt-xref-label>
                <fmt-xref-label container="P">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annexe</span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Appendice</span>
                   <semx element="autonum" source="Q2">1</semx>
                </fmt-xref-label>
             </appendix>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" displayorder="11">
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
      #{HTML_HDR.gsub(/"en"/, '"fr"').sub(/Contents/, 'Sommaire')}
      <br/>
             <div id="_">
               <h1 class="ForewordTitle">Foreword</h1>
               <p id="A">This is a preamble</p>
             </div>
             <br/>
             <div class="Section3" id="B">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="C">
                 <h2>0.1  Introduction Subsection</h2>
               </div>
               <p>This is patent boilerplate</p>
             </div>
             <div id="D">
               <h1>1  Scope</h1>
               <p id="E">Text</p>
             </div>
             <div>
               <h1>2  Normative References</h1>
             </div>
                 <div id="D0">
                   <h1>Section 3 :  General</h1>
                </div>
                <div id="H">
                   <h1>4  Terms, definitions, symbols and abbreviated terms</h1>
                   <div id="I">
                      <h2>4.1  Normal Terms</h2>
                      <p class="TermNum" id="J">4.1.1</p>
                      <p class="Terms" style="text-align:left;">
                         <b>Term2</b>
                      </p>
                   </div>
                   <div id="K">
                      <h2>4.2  Symboles</h2>
                      <div class="figdl">
                         <dl>
                            <dt>
                               <p>Symbol</p>
                            </dt>
                            <dd>Definition</dd>
                         </dl>
                      </div>
                   </div>
                </div>
                <div id="L" class="Symbols">
                   <h1>5  Symboles</h1>
                   <div class="figdl">
                      <dl>
                         <dt>
                            <p>Symbol</p>
                         </dt>
                         <dd>Definition</dd>
                      </dl>
                   </div>
                </div>
                <div id="M">
                   <h1>6  Clause 4</h1>
                   <div id="N">
                      <h2>6.1  Introduction</h2>
                   </div>
                   <div id="O">
                      <h2>6.2  Clause 4.2</h2>
                   </div>
                </div>
                <br/>
                <div id="P" class="Section3">
                   <h1 class="Annex">
                      <b>Annexe A</b>
                      <br/>
                      <span class="obligation">(normative)</span>
                      <br/>
                      <br/>
                      <b>Annex</b>
                   </h1>
                   <div id="Q">
                      <h2>A.1  Annex A.1</h2>
                      <div id="Q1">
                         <h3>A.1.1  Annex A.1a</h3>
                      </div>
                   </div>
                   <div id="Q2">
                      <h2>Appendice 1  An Appendix</h2>
                   </div>
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
    expect(Canon.format_xml(strip_guid(pres_output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
  end

  it "processes Russian" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status>
            <stage abbreviation='IS' language=''>60</stage>
          </status>
          <language>ru</language>
          <ext>
            <doctype language=''>international-standard</doctype>
          </ext>
        </bibdata>
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
        </preface>
        <sections>
          <clause id="D0" type="section"><title>General</title></clause>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative">
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
          </clause>
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

    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <status>
               <stage abbreviation="IS" language="">60</stage>
               <stage abbreviation="IS" language="ru">Международный Стандарт</stage>
            </status>
            <language current="true">ru</language>
            <ext>
               <doctype language="">international-standard</doctype>
               <doctype language="ru">Международный Стандарт</doctype>
            </ext>
         </bibdata>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Содержание</fmt-title>
            </clause>
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
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="B">0</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="C">1</semx>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Introduction Subsection</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <semx element="autonum" source="B">0</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="C">1</semx>
                  </fmt-xref-label>
               </clause>
               <p>This is patent boilerplate</p>
            </introduction>
         </preface>
         <sections>
            <clause id="D0" type="section" displayorder="6">
               <title id="_">General</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Раздел</span>
                     <semx element="autonum" source="D0">3</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     :
                     <tab/>
                  </span>
                  <semx element="title" source="_">General</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Раздел</span>
                  <semx element="autonum" source="D0">3</semx>
               </fmt-xref-label>
            </clause>
            <clause id="D" obligation="normative" type="scope" displayorder="4">
               <title id="_">Scope</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="D">1</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Scope</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="D">1</semx>
               </fmt-xref-label>
               <p id="E">Text</p>
            </clause>
            <clause id="H" obligation="normative" displayorder="7">
               <title id="_">Terms, definitions, symbols and abbreviated terms</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="H">4</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Terms, definitions, symbols and abbreviated terms</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="H">4</semx>
               </fmt-xref-label>
               <terms id="I" obligation="normative">
                  <title id="_">Normal Terms</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">4</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="I">1</semx>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Normal Terms</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <semx element="autonum" source="H">4</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="I">1</semx>
                  </fmt-xref-label>
                  <term id="J">
                     <fmt-name id="_">
                        <span class="fmt-caption-label">
                           <semx element="autonum" source="H">4</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="I">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="J">1</semx>
                        </span>
                     </fmt-name>
                     <fmt-xref-label>
                        <semx element="autonum" source="H">4</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="I">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="J">1</semx>
                     </fmt-xref-label>
                     <preferred id="_">
                        <expression>
                           <name>Term2</name>
                        </expression>
                     </preferred>
                     <fmt-preferred>
                        <p>
                           <semx element="preferred" source="_">
                              <strong>Term2</strong>
                           </semx>
                        </p>
                     </fmt-preferred>
                  </term>
               </terms>
               <definitions id="K">
                  <title id="_">Символы</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">4</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="K">2</semx>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Символы</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <semx element="autonum" source="H">4</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="K">2</semx>
                  </fmt-xref-label>
                  <dl>
                     <dt>Symbol</dt>
                     <dd>Definition</dd>
                  </dl>
               </definitions>
            </clause>
            <definitions id="L" displayorder="8">
               <title id="_">Символы</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="L">5</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Символы</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="L">5</semx>
               </fmt-xref-label>
               <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
               </dl>
            </definitions>
            <clause id="M" inline-header="false" obligation="normative" displayorder="9">
               <title id="_">Clause 4</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="M">6</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Clause 4</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="M">6</semx>
               </fmt-xref-label>
               <clause id="N" inline-header="false" obligation="normative">
                  <title id="_">Introduction</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">6</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="N">1</semx>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Introduction</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <semx element="autonum" source="M">6</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </fmt-xref-label>
               </clause>
               <clause id="O" inline-header="false" obligation="normative">
                  <title id="_">Clause 4.2</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">6</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="O">2</semx>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Clause 4.2</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <semx element="autonum" source="M">6</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="O">2</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
            <references id="R" normative="true" obligation="informative" displayorder="5">
               <title id="_">Normative References</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="R">2</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Normative References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Пункт</span>
                  <semx element="autonum" source="R">2</semx>
               </fmt-xref-label>
            </references>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="10">
            <title id="_">
               <strong>Annex</strong>
            </title>
            <fmt-title id="_">
               <strong>
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Дополнение</span>
                     <semx element="autonum" source="P">A</semx>
                  </span>
               </strong>
               <br/>
               <span class="fmt-obligation">(нормативное)</span>
               <span class="fmt-caption-delim">
                  <br/>
                  <br/>
               </span>
               <semx element="title" source="_">
                  <strong>Annex</strong>
               </semx>
            </fmt-title>
            <fmt-xref-label>
               <span class="fmt-element-name">Дополнение</span>
               <semx element="autonum" source="P">A</semx>
            </fmt-xref-label>
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
                  <span class="fmt-element-name">Пункт</span>
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
            <appendix id="Q2" inline-header="false" obligation="normative" autonum="1">
               <title id="_">An Appendix</title>
               <fmt-title id="_" depth="2">
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Приложение</span>
                     <semx element="autonum" source="Q2">1</semx>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">An Appendix</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Приложение</span>
                  <semx element="autonum" source="Q2">1</semx>
               </fmt-xref-label>
               <fmt-xref-label container="P">
                  <span class="fmt-xref-container">
                     <span class="fmt-element-name">Дополнение</span>
                     <semx element="autonum" source="P">A</semx>
                  </span>
                  <span class="fmt-comma">,</span>
                  <span class="fmt-element-name">Приложение</span>
                  <semx element="autonum" source="Q2">1</semx>
               </fmt-xref-label>
            </appendix>
         </annex>
         <bibliography>
            <clause id="S" obligation="informative" displayorder="11">
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
      #{HTML_HDR.gsub(/"en"/, '"ru"').sub(/Contents/, 'Содержание')}
       <br/>
             <div id="_">
               <h1 class="ForewordTitle">Foreword</h1>
               <p id="A">This is a preamble</p>
             </div>
             <br/>
             <div class="Section3" id="B">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="C">
                 <h2>0.1  Introduction Subsection</h2>
               </div>
               <p>This is patent boilerplate</p>
             </div>
             <div id="D">
               <h1>1  Scope</h1>
               <p id="E">Text</p>
             </div>
             <div>
               <h1>2  Normative References</h1>
             </div>
             <div id="D0">
               <h1>Раздел 3:  General</h1>
             </div>
             <div id="H">
               <h1>4  Terms, definitions, symbols and abbreviated terms</h1>
               <div id="I">
                 <h2>4.1  Normal Terms</h2>
                 <p class="TermNum" id="J">4.1.1</p>
                 <p class="Terms" style="text-align:left;">
                   <b>Term2</b>
                 </p>
               </div>
               <div id="K">
               <h2>4.2  Символы</h2>
                 <div class="figdl">
                 <dl>
                   <dt>
                     <p>Symbol</p>
                   </dt>
                   <dd>Definition</dd>
                 </dl>
                 </div>
               </div>
             </div>
             <div id="L" class="Symbols">
               <h1>5  Символы</h1>
               <div class="figdl">
               <dl>
                 <dt>
                   <p>Symbol</p>
                 </dt>
                 <dd>Definition</dd>
               </dl>
               </div>
             </div>
             <div id="M">
               <h1>6  Clause 4</h1>
               <div id="N">
                 <h2>6.1  Introduction</h2>
               </div>
               <div id="O">
                 <h2>6.2  Clause 4.2</h2>
               </div>
             </div>
             <br/>
             <div id="P" class="Section3">
               <h1 class="Annex">
                 <b>Дополнение A</b>
                 <br/>
                 <span class="obligation">(нормативное)</span>
                 <br/>
                 <br/>
                 <b>Annex</b>
               </h1>
               <div id="Q">
                 <h2>A.1  Annex A.1</h2>
                 <div id="Q1">
                   <h3>A.1.1  Annex A.1a</h3>
                 </div>
               </div>
               <div id="Q2">
                 <h2>Приложение 1  An Appendix</h2>
               </div>
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
    expect(Canon.format_xml(strip_guid(pres_output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
  end

  it "processes Simplified Chinese" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status>
            <stage abbreviation='IS' language=''>60</stage>
          </status>
          <language>zh</language>
          <script>Hans</script>
          <ext>
            <doctype language=''>international-standard</doctype>
          </ext>
        </bibdata>
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
        </preface>
        <sections>
          <clause id="D0" type="section"><title>一般的</title></clause>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">
              <eref bibitemid="ISO712" type="inline">
                <locality type="table">
                  <referenceFrom>1</referenceFrom>
                  <referenceTo>1</referenceTo>
                </locality>
              </eref>
            </p>
          </clause>
          <clause id="H" obligation="normative">
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
          </clause>
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
            <bibitem id="ISO712" type="standard">
              <formattedref><em>Cereals and cereal products</em>.</formattedref>
              <docidentifier>ISO 712</docidentifier>
            </bibitem>
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
             <status>
                <stage abbreviation="IS" language="">60</stage>
                <stage abbreviation="IS" language="zh">国际标准</stage>
             </status>
             <language current="true">zh</language>
             <script current="true">Hans</script>
             <ext>
                <doctype language="">international-standard</doctype>
                <doctype language="zh">国际标准</doctype>
             </ext>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">目　次</fmt-title>
             </clause>
             <foreword obligation="informative" id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="3">
                <title id="_">Introduction</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="B">0</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="C">1</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="B">0</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="C">1</semx>
                   </fmt-xref-label>
                </clause>
                <p>This is patent boilerplate</p>
             </introduction>
          </preface>
          <sections>
             <clause id="D0" type="section" displayorder="6">
                <title id="_">一般的</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">条</span>
                      <semx element="autonum" source="D0">3</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      ：
                      <tab/>
                   </span>
                   <semx element="title" source="_">一般的</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条</span>
                   <semx element="autonum" source="D0">3</semx>
                </fmt-xref-label>
             </clause>
             <clause id="D" obligation="normative" type="scope" displayorder="4">
                <title id="_">Scope</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="D">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Scope</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条</span>
                   <semx element="autonum" source="D">1</semx>
                </fmt-xref-label>
                <p id="E">
                   <eref bibitemid="ISO712" type="inline" id="_">
                      <locality type="table">
                         <referenceFrom>1</referenceFrom>
                         <referenceTo>1</referenceTo>
                      </locality>
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                         ，
                         <span class="citetbl">表1〜1</span>
                      </fmt-xref>
                   </semx>
                </p>
             </clause>
             <clause id="H" obligation="normative" displayorder="7">
                <title id="_">Terms, definitions, symbols and abbreviated terms</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="H">4</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Terms, definitions, symbols and abbreviated terms</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条</span>
                   <semx element="autonum" source="H">4</semx>
                </fmt-xref-label>
                <terms id="I" obligation="normative">
                   <title id="_">Normal Terms</title>
                   <fmt-title depth="2" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">4</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Normal Terms</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="H">4</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="I">1</semx>
                   </fmt-xref-label>
                   <term id="J">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="H">4</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="I">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="J">1</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <semx element="autonum" source="H">4</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="J">1</semx>
                      </fmt-xref-label>
                      <preferred id="_">
                         <expression>
                            <name>Term2</name>
                         </expression>
                      </preferred>
                      <fmt-preferred>
                         <p>
                            <semx element="preferred" source="_">
                               <strong>Term2</strong>
                            </semx>
                         </p>
                      </fmt-preferred>
                   </term>
                </terms>
                <definitions id="K">
                   <title id="_">符号</title>
                   <fmt-title depth="2" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">4</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="K">2</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">符号</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="H">4</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="K">2</semx>
                   </fmt-xref-label>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" displayorder="8">
                <title id="_">符号</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="L">5</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">符　号</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条</span>
                   <semx element="autonum" source="L">5</semx>
                </fmt-xref-label>
                <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="9">
                <title id="_">Clause 4</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="M">6</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 4</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条</span>
                   <semx element="autonum" source="M">6</semx>
                </fmt-xref-label>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title depth="2" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">6</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="N">1</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Introduction</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="M">6</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="N">1</semx>
                   </fmt-xref-label>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title depth="2" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">6</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="O">2</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Clause 4.2</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="M">6</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="O">2</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
             <references id="R" normative="true" obligation="informative" displayorder="5">
                <title id="_">Normative References</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="R">2</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条</span>
                   <semx element="autonum" source="R">2</semx>
                </fmt-xref-label>
                <bibitem id="ISO712" type="standard">
                   <biblio-tag>
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                       ，
                   </biblio-tag>
                   <formattedref>
                      <em>Cereals and cereal products</em>
                      .
                   </formattedref>
                   <docidentifier>ISO 712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                </bibitem>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="10">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">附件</span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">（规范性附录）</span>
                <span class="fmt-caption-delim">
                   <br/>
                   <br/>
                </span>
                <semx element="title" source="_">
                   <strong>Annex</strong>
                </semx>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">附件</span>
                <semx element="autonum" source="P">A</semx>
             </fmt-xref-label>
             <clause id="Q" inline-header="false" obligation="normative">
                <title id="_">Annex A.1</title>
                <fmt-title depth="2" id="_">
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
                   <span class="fmt-element-name">条</span>
                   <semx element="autonum" source="P">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q">1</semx>
                </fmt-xref-label>
                <clause id="Q1" inline-header="false" obligation="normative">
                   <title id="_">Annex A.1a</title>
                   <fmt-title depth="3" id="_">
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
             <appendix id="Q2" inline-header="false" obligation="normative" autonum="1">
                <title id="_">An Appendix</title>
                <fmt-title depth="2" id="_">
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">附录</span>
                      <semx element="autonum" source="Q2">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">An Appendix</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">附录</span>
                   <semx element="autonum" source="Q2">1</semx>
                </fmt-xref-label>
                <fmt-xref-label container="P">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">附件</span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                   <span class="fmt-comma">，</span>
                   <span class="fmt-element-name">附录</span>
                   <semx element="autonum" source="Q2">1</semx>
                </fmt-xref-label>
             </appendix>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" displayorder="11">
                <title id="_">Bibliography</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <references id="T" normative="false" obligation="informative">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title depth="2" id="_">
                      <semx element="title" source="_">Bibliography Subsection</semx>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR.gsub(/"en"/, '"zh"').sub(/Contents/, '目　次')}
                   <br/>
               <div id="_">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p id="A">This is a preamble</p>
                </div>
                <br/>
                <div class="Section3" id="B">
                   <h1 class="IntroTitle">Introduction</h1>
                   <div id="C">
                      <h2>0.1　Introduction Subsection</h2>
                   </div>
                   <p>This is patent boilerplate</p>
                </div>
                <div id="D">
                   <h1>1　Scope</h1>
                   <p id="E">
                      <a href="#ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                         ，
                         <span class="citetbl">表1〜1</span>
                      </a>
                   </p>
                </div>
                <div>
                   <h1>2　Normative References</h1>
                   <p id="ISO712" class="NormRef">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                       ，
                      <i>Cereals and cereal products</i>
                      .
                   </p>
                </div>
                <div id="D0">
                   <h1>条3：　一般的</h1>
                </div>
                <div id="H">
                   <h1>4　Terms, definitions, symbols and abbreviated terms</h1>
                   <div id="I">
                      <h2>4.1　Normal Terms</h2>
                      <p class="TermNum" id="J">4.1.1</p>
                      <p class="Terms" style="text-align:left;">
                         <b>Term2</b>
                      </p>
                   </div>
                   <div id="K">
                      <h2>4.2　符号</h2>
                      <div class="figdl">
                         <dl>
                            <dt>
                               <p>Symbol</p>
                            </dt>
                            <dd>Definition</dd>
                         </dl>
                      </div>
                   </div>
                </div>
                <div id="L" class="Symbols">
                   <h1>5　符　号</h1>
                   <div class="figdl">
                      <dl>
                         <dt>
                            <p>Symbol</p>
                         </dt>
                         <dd>Definition</dd>
                      </dl>
                   </div>
                </div>
                <div id="M">
                   <h1>6　Clause 4</h1>
                   <div id="N">
                      <h2>6.1　Introduction</h2>
                   </div>
                   <div id="O">
                      <h2>6.2　Clause 4.2</h2>
                   </div>
                </div>
                <br/>
                <div id="P" class="Section3">
                   <h1 class="Annex">
                      <b>附件A</b>
                      <br/>
                      <span class="obligation">（规范性附录）</span>
                      <br/>
                      <br/>
                      <b>Annex</b>
                   </h1>
                   <div id="Q">
                      <h2>A.1　Annex A.1</h2>
                      <div id="Q1">
                         <h3>A.1.1　Annex A.1a</h3>
                      </div>
                   </div>
                   <div id="Q2">
                      <h2>附录1　An Appendix</h2>
                   </div>
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
    expect(Canon.format_xml(strip_guid(pres_output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
  end

  it "internationalises locality" do
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
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A"><eref type="inline" bibitemid="ISO712"><locality type="locality:appendix"><referenceFrom>7</referenceFrom></locality></eref></p>
         <p id="B"><eref type="inline" bibitemid="ISO712"><locality type="annex"><referenceFrom>7</referenceFrom></locality></eref></p>
       </foreword>
       </preface>
       <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <foreword obligation="informative" displayorder="2" id="_">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p id="A">
            <eref type="inline" bibitemid="ISO712" id="_">
               <locality type="locality:appendix">
                  <referenceFrom>7</referenceFrom>
               </locality>
            </eref>
            <semx element="eref" source="_">
               <fmt-xref type="inline" target="ISO712">
                  <span class="stdpublisher">ISO </span>
                  <span class="stddocNumber">712</span>
                  , Appendice 7
               </fmt-xref>
            </semx>
         </p>
         <p id="B">
            <eref type="inline" bibitemid="ISO712" id="_">
               <locality type="annex">
                  <referenceFrom>7</referenceFrom>
               </locality>
            </eref>
            <semx element="eref" source="_">
               <fmt-xref type="inline" target="ISO712">
                  <span class="stdpublisher">ISO </span>
                  <span class="stddocNumber">712</span>
                  ,
                  <span class="citeapp">Annexe 7</span>
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new({}).convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
  end
end
