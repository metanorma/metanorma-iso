require "spec_helper"

RSpec.describe IsoDoc do
  it "processes clause names" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
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
            <title>Terms, Definitions, Symbols and Abbreviated Terms</title>
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
            <clause id="Q2a" inline-header="false" obligation="normative">
              <title>Appendix subclause</title>
            <clause id="Q2b" inline-header="false" obligation="normative">
              <title>Appendix subsubclause</title>
              </clause>
            </clause>
          </appendix>
          <references id="Q3" normative="false">
            <title>Annex Bibliography</title>
          </references>
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
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword obligation="informative" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="3">
                <title id="_">Introduction</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2">
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
             <clause id="D" obligation="normative" type="scope" displayorder="4">
                <title id="_">Scope</title>
                <fmt-title depth="1">
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
             <clause id="H" obligation="normative" displayorder="6">
                <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="H">3</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="H">3</semx>
                </fmt-xref-label>
                <terms id="I" obligation="normative">
                   <title id="_">Normal Terms</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">1</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Normal Terms</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="I">1</semx>
                   </fmt-xref-label>
                   <term id="J">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="H">3</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="I">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="J">1</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <semx element="autonum" source="H">3</semx>
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
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="H">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="K">2</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Symbols</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="K">2</semx>
                   </fmt-xref-label>
                   <dl>
                      <dt>Symbol</dt>
                      <dd>Definition</dd>
                   </dl>
                </definitions>
             </clause>
             <definitions id="L" displayorder="7">
                <title id="_">Symbols</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="L">4</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Symbols</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="L">4</semx>
                </fmt-xref-label>
                <dl>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="8">
                <title id="_">Clause 4</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="M">5</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 4</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="M">5</semx>
                </fmt-xref-label>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">5</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="N">1</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Introduction</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="N">1</semx>
                   </fmt-xref-label>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">5</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="O">2</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Clause 4.2</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="O">2</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
             <references id="R" normative="true" obligation="informative" displayorder="5">
                <title id="_">Normative References</title>
                <fmt-title depth="1">
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
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title>
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
                <fmt-title depth="2">
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
                   <fmt-title depth="3">
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
                <fmt-title depth="2">
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
                <clause id="Q2a" inline-header="false" obligation="normative">
                   <title id="_">Appendix subclause</title>
                   <fmt-title depth="3">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Appendix</span>
                         <semx element="autonum" source="Q2">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q2a">1</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Appendix subclause</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Appendix</span>
                      <semx element="autonum" source="Q2">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q2a">1</semx>
                   </fmt-xref-label>
                   <fmt-xref-label container="P">
                      <span class="fmt-xref-container">
                         <span class="fmt-element-name">Annex</span>
                         <semx element="autonum" source="P">A</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Appendix</span>
                      <semx element="autonum" source="Q2">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q2a">1</semx>
                   </fmt-xref-label>
                   <clause id="Q2b" inline-header="false" obligation="normative">
                      <title id="_">Appendix subsubclause</title>
                      <fmt-title depth="4">
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">Appendix</span>
                            <semx element="autonum" source="Q2">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="Q2a">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="Q2b">1</semx>
                         </span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                         <semx element="title" source="_">Appendix subsubclause</semx>
                      </fmt-title>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Appendix</span>
                         <semx element="autonum" source="Q2">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q2a">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q2b">1</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="P">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Annex</span>
                            <semx element="autonum" source="P">A</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Appendix</span>
                         <semx element="autonum" source="Q2">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q2a">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q2b">1</semx>
                      </fmt-xref-label>
                   </clause>
                </clause>
             </appendix>
             <references id="Q3" normative="false">
                <title id="_">Annex Bibliography</title>
                <fmt-title depth="2">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q3">2</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Annex Bibliography</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="P">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q3">2</semx>
                </fmt-xref-label>
             </references>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" displayorder="10">
                <title id="_">Bibliography</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <references id="T" normative="false" obligation="informative">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title depth="2">
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
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="A">This is a preamble</p>
            </div>
            <br/>
            <div class="Section3" id="B">
              <h1 class="IntroTitle">Introduction</h1>
              <div id="C">
                <h2>0.1&#160; Introduction Subsection</h2>
              </div>
              <p>This is patent boilerplate</p>
            </div>
            <div id="D">
              <h1>1&#160; Scope</h1>
              <p id="E">Text</p>
            </div>
            <div>
              <h1>2&#160; Normative References</h1>
            </div>
            <div id="H">
              <h1>3&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
              <div id="I">
                <h2>3.1&#160; Normal Terms</h2>
                <p class="TermNum" id="J">3.1.1</p>
                <p class="Terms" style="text-align:left;"><b>Term2</b></p>
              </div>
              <div id="K">
                <h2>3.2  Symbols</h2>
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
            <div class="Symbols" id="L">
            <h1>4  Symbols</h1>
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
              <h1>5&#160; Clause 4</h1>
              <div id="N">
                <h2>5.1&#160; Introduction</h2>
              </div>
              <div id="O">
                <h2>5.2&#160; Clause 4.2</h2>
              </div>
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
              <div id="Q2">
                <h2>Appendix 1&#160; An Appendix</h2>
                <div id="Q2a">
                  <h3>Appendix 1.1&#160; Appendix subclause</h3>
                  <div id="Q2b">
                     <h4>Appendix 1.1.1  Appendix subsubclause</h4>
                  </div>
                </div>
              </div>
              <div>
                <h2 class="Section3">A.2&#160; Annex Bibliography</h2>
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

    word = <<~OUTPUT
        <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p>&#160;</p>
          </div>
          <p class="section-break">
            <br class="section" clear="all"/>
          </p>
          <div class="WordSection2">
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
                <div class="TOC" id="_">
        <p class="zzContents">Contents</p>
      </div>
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="A" class='ForewordText'>This is a preamble</p>
            </div>
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div class="Section3" id="B">
              <h1 class="IntroTitle">
                Introduction</h1>
              <div id="C">
                <h2>0.1
                  <span style="mso-tab-count:1">&#160; </span>
                  Introduction Subsection</h2>
              </div>
              <p>This is patent boilerplate</p>
            </div>
            <p>&#160;</p>
          </div>
          <p class="section-break">
            <br class="section" clear="all"/>
          </p>
          <div class="WordSection3">
            <div id="D">
              <h1>1
                <span style="mso-tab-count:1">&#160; </span>
                Scope</h1>
              <p id="E">Text</p>
            </div>
            <div>
              <h1>2
                <span style="mso-tab-count:1">&#160; </span>
                Normative References</h1>
            </div>
            <div id="H">
              <h1>3
                <span style="mso-tab-count:1">&#160; </span>
                Terms, Definitions, Symbols and Abbreviated Terms</h1>
              <div id="I">
                <h2>3.1
                  <span style="mso-tab-count:1">&#160; </span>
                  Normal Terms</h2>
                <p class="TermNum" id="J">3.1.1</p>
                <p class="Terms" style="text-align:left;"><b>Term2</b></p>
              </div>
              <div id="K">
              <h2>3.2<span style="mso-tab-count:1">  </span>Symbols</h2>
                <table class="dl">
                  <tr>
                    <td align="left" valign="top">
                      <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                    </td>
                    <td valign="top">Definition</td>
                  </tr>
                </table>
              </div>
            </div>
            <div class="Symbols" id="L">
            <h1>4<span style="mso-tab-count:1">  </span>Symbols</h1>
              <table class="dl">
                <tr>
                  <td align="left" valign="top">
                    <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                  </td>
                  <td valign="top">Definition</td>
                </tr>
              </table>
            </div>
            <div id="M">
              <h1>5
                <span style="mso-tab-count:1">&#160; </span>
                Clause 4</h1>
              <div id="N">
                <h2>5.1
                  <span style="mso-tab-count:1">&#160; </span>
                  Introduction</h2>
              </div>
              <div id="O">
                <h2>5.2
                  <span style="mso-tab-count:1">&#160; </span>
                  Clause 4.2</h2>
              </div>
            </div>
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
            <div class="Section3" id="P">
              <h1 class="Annex">
                <br/><span style='font-weight:normal;'>(normative)</span>
                <br/>
                <br/>
                <b>Annex</b></h1>
              <div id="Q">
                <h2>A.1
                  <span style="mso-tab-count:1">&#160; </span>
                  Annex A.1</h2>
                <div id="Q1">
                  <h3>A.1.1
                    <span style="mso-tab-count:1">&#160; </span>
                    Annex A.1a</h3>
                </div>
              </div>
              <div id="Q2">
                <h2>Appendix 1
                  <span style="mso-tab-count:1">&#160; </span>
                  An Appendix</h2>
                <div id="Q2a">
                  <h3>Appendix 1.1
                    <span style="mso-tab-count:1">&#160; </span>
                    Appendix subclause</h3>
                                   <div id="Q2b">
                  <h4>
                     Appendix 1.1.1
                     <span style="mso-tab-count:1">  </span>
                     Appendix subsubclause
                  </h4>
               </div>
                </div>
              </div>
              <div>
                <h2 class="BiblioTitle">A.2
                  <span style="mso-tab-count:1">&#160; </span>
                  Annex Bibliography</h2>
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
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true)
      .sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes section titles" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
        <clause id="B" type="section"><title>General</title>
          <clause id="D" obligation="normative">
            <title>Scope</title>
              <clause id="D1" obligation="normative">
                <title>Scope 1</title>
              </clause>
            <clause id="D2" obligation="normative">
            </clause>
          </clause>
          </clause>
        </sections>
      </iso-standard>
    INPUT

    presxml = <<~OUTPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <clause id="B" type="section" displayorder="2">
                 <title id="_">General</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Section</span>
                       <semx element="autonum" source="B">1</semx>
                       </span>
                       <span class="fmt-caption-delim">
                          :
                          <tab/>
                       </span>
                       <semx element="title" source="_">General</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Section</span>
                    <semx element="autonum" source="B">1</semx>
                 </fmt-xref-label>
                 <clause id="D" obligation="normative">
                    <title id="_">Scope</title>
                    <fmt-title depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="B">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="D">1</semx>
                          </span>
                          <span class="fmt-caption-delim">
                             <tab/>
                          </span>
                          <semx element="title" source="_">Scope</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="B">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="D">1</semx>
                    </fmt-xref-label>
                    <clause id="D1" obligation="normative">
                       <title id="_">Scope 1</title>
                       <fmt-title depth="3">
                          <span class="fmt-caption-label">
                             <semx element="autonum" source="B">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="D">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="D1">1</semx>
                             </span>
                             <span class="fmt-caption-delim">
                                <tab/>
                             </span>
                             <semx element="title" source="_">Scope 1</semx>
                       </fmt-title>
                       <fmt-xref-label>
                          <semx element="autonum" source="B">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="D">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="D1">1</semx>
                       </fmt-xref-label>
                    </clause>
                    <clause id="D2" obligation="normative" inline-header="true">
                       <fmt-title depth="3">
                          <span class="fmt-caption-label">
                             <semx element="autonum" source="B">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="D">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="D2">2</semx>
                          </span>
                       </fmt-title>
                       <fmt-xref-label>
                          <semx element="autonum" source="B">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="D">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="D2">2</semx>
                       </fmt-xref-label>
                    </clause>
                 </clause>
              </clause>
           </sections>
        </iso-standard>
    OUTPUT

    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes subclauses with and without titles" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <clause id="D" obligation="normative">
            <title>Scope</title>
              <clause id="D1" obligation="normative">
                <title>Scope 1</title>
              </clause>
            <clause id="D2" obligation="normative">
            </clause>
          </clause>
        </sections>
      </iso-standard>
    INPUT

    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <clause id="D" obligation="normative" displayorder="2">
                 <title id="_">Scope</title>
                 <fmt-title depth="1">
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
                 <clause id="D1" obligation="normative">
                    <title id="_">Scope 1</title>
                    <fmt-title depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="D">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="D1">1</semx>
                          </span>
                          <span class="fmt-caption-delim">
                             <tab/>
                          </span>
                          <semx element="title" source="_">Scope 1</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="D">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="D1">1</semx>
                    </fmt-xref-label>
                 </clause>
                 <clause id="D2" obligation="normative" inline-header="true">
                    <fmt-title depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="D">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="D2">2</semx>
                       </span>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="D">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="D2">2</semx>
                    </fmt-xref-label>
                 </clause>
              </clause>
           </sections>
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
                <br/>
      <div class="TOC" id="_">
        <h1 class="IntroTitle">Contents</h1>
      </div>
            <div id='D'>
              <h1>1&#160; Scope</h1>
              <div id='D1'>
                <h2>1.1&#160; Scope 1</h2>
              </div>
              <div id='D2'>
                <span class='zzMoveToFollowing inline-header'>
                  <b>1.2&#160; </b>
                </span>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes simple terms & definitions" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface> <clause type="toc" id="_" displayorder="1"> 
        <fmt-title depth="1">Contents</fmt-title> 
        </clause> 
        </preface>
        <sections>
          <terms id="H" obligation="normative" displayorder="2">
            <fmt-title>Terms, Definitions, Symbols and Abbreviated Terms</fmt-title>
            <term id="J">
              <fmt-name>1.1</fmt-name>
              <fmt-preferred><p>Term2</p></fmt-preferred>
            </term>
          </terms>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
            <div id="H">
              <h1>Terms, Definitions, Symbols and Abbreviated Terms</h1>
              <p class="TermNum" id="J">1.1</p>
              <p class="Terms" style="text-align:left;">Term2</p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes multiple terms & definitions sections" do
    input = <<~INPUT
      #{BLANK_HDR.sub(%r{<doctype>standard</doctype>}, '<doctype>standard</doctype><subdoctype>vocabulary</subdoctype>')}
               <sections>
           <terms id='A' obligation='normative'>
             <title>Terms and definitions</title>
             <p id='A1'>No terms and definitions are listed in this document.</p>
           </terms>
           <clause id='B' inline-header='false' obligation='normative'>
             <title>Clause</title>
           </clause>
           <terms id='C' obligation='normative'>
             <title>More terms</title>
           </terms>
         </sections>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='presentation' version="#{Metanorma::Iso::VERSION}" flavor="iso">
           <bibdata type="standard">
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
              <contributor>
                 <role type="authorizer">
                    <description>Agency</description>
                 </role>
                 <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                 </organization>
              </contributor>
              <language current="true">en</language>
              <script current="true">Latn</script>
              <status>
                 <stage>60</stage>
                 <substage>60</substage>
              </status>
              <copyright>
                 <from>#{Date.today.year}</from>
                 <owner>
                    <organization>
                       <name>International Organization for Standardization</name>
                       <abbreviation>ISO</abbreviation>
                    </organization>
                 </owner>
              </copyright>
              <ext>
                 <doctype>standard</doctype>
                 <subdoctype>vocabulary</subdoctype>
                 <flavor>iso</flavor>
                 <editorialgroup identifier="ISO">
                    <agency>ISO</agency>
                 </editorialgroup>
                 <approvalgroup identifier="ISO">
                    <agency>ISO</agency>
                 </approvalgroup>
                 <stagename>International Standard</stagename>
              </ext>
           </bibdata>
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <terms id="A" obligation="normative" displayorder="2">
                 <title id="_">Terms and definitions</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="A">1</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Terms and definitions</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="A">1</semx>
                 </fmt-xref-label>
                 <p id="A1">No terms and definitions are listed in this document.</p>
              </terms>
              <clause id="B" inline-header="false" obligation="normative" displayorder="3">
                 <title id="_">Clause</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="B">2</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Clause</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="B">2</semx>
                 </fmt-xref-label>
              </clause>
              <terms id="C" obligation="normative" displayorder="4">
                 <title id="_">More terms</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="C">3</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">More terms</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="C">3</semx>
                 </fmt-xref-label>
              </terms>
           </sections>
        </metanorma>
    OUTPUT
    output = <<~OUTPUT
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
                <br/>
                <div id="_" class="TOC">
                   <h1 class="IntroTitle">Contents</h1>
                </div>
                <div id="A">
                   <h1>1  Terms and definitions</h1>
                   <p id="A1">No terms and definitions are listed in this document.</p>
                </div>
                <div id="B">
                   <h1>2  Clause</h1>
                </div>
                <div id="C">
                   <h1>3  More terms</h1>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    xml = Nokogiri::XML(pres_output)
    xml.at("//xmlns:localized-strings")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    xml.at("//xmlns:metanorma-extension")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    xml = Nokogiri::XML(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))
    xml.at("//div[@class = 'authority']")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes inline section headers" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~INPUT, true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface> 
        <clause type="toc" id="_" displayorder="1"> 
        <fmt-title depth="1">Contents</fmt-title> 
        </clause> 
        </preface>
        <sections>
          <clause id="M" inline-header="false" obligation="normative" displayorder="2">
            <fmt-title>Clause 4</fmt-title>
            <clause id="N" inline-header="false" obligation="normative">
              <fmt-title>Introduction</fmt-title>
            </clause>
            <clause id="O" inline-header="true" obligation="normative">
              <fmt-title>Clause 4.2</fmt-title>
              <p>Hello</p>
            </clause>
          </clause>
        </sections>
      </iso-standard>
    INPUT
    expect(Xml::C14n.format(output)).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{HTML_HDR}
            <div id="M">
              <h1>Clause 4</h1>
              <div id="N">
                <h2>Introduction</h2>
              </div>
              <div id="O">
                <span class="zzMoveToFollowing inline-header"><b>Clause 4.2&#160; </b></span>
                <p>Hello</p>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "adds colophon to published standard (Word)" do
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", <<~INPUT, true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status>
            <stage>60</stage>
          </status>
        </bibdata>
        <sections/>
      </iso-standard>
    INPUT
    expect(Xml::C14n.format(output.sub(/^.*<body /m, "<body ")
      .sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
        <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p>&#160;</p>
          </div>
          <p class="section-break"><br clear="all" class="section"/></p>
          <div class="WordSection2">
            <p>&#160;</p>
          </div>
          <p class="section-break"><br clear="all" class="section"/></p>
          <div class="WordSection3">
          </div>
          <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
          <div class="colophon"/>
        </body>
      OUTPUT
  end

  it "does not add colophon to draft standard (Word)" do
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", <<~INPUT, true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status>
            <stage>30</stage>
          </status>
        </bibdata>
        <sections/>
      </iso-standard>
    INPUT
    expect(Xml::C14n.format(output.sub(/^.*<body /m, "<body ")
      .sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
        <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p>&#160;</p>
          </div>
          <p class="section-break"><br clear="all" class="section"/></p>
          <div class="WordSection2">
            <p>&#160;</p>
          </div>
          <p class="section-break"><br clear="all" class="section"/></p>
          <div class="WordSection3">
          </div>
        </body>
      OUTPUT
  end

  it "processes middle title" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <title format="text/plain" language="en" type="title-intro">Introduction</title>
          <title format="text/plain" language="en" type="title-main">Main Title — Title</title>
          <title format="text/plain" language="en" type="title-part">Title Part</title>
          <ext>
            <structuredidentifier>
              <project-number origyr="2016-05-01" part="1">17301</project-number>
            </structuredidentifier>
          </ext>
        </bibdata>
        <sections>
        <clause id="A"/>
        </sections>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
           <title format="text/plain" language="en" type="title-intro">Introduction</title>
           <title format="text/plain" language="en" type="title-main">Main Title&#x2009;&#x2014;&#x2009;Title</title>
           <title format="text/plain" language="en" type="title-part">Title Part</title>
           <ext>
             <structuredidentifier>
               <project-number origyr="2016-05-01" part="1">17301</project-number>
             </structuredidentifier>
           </ext>
         </bibdata>
       <preface> <clause type="toc" id="_" displayorder="1"> 
            <fmt-title depth="1">Contents</fmt-title> 
          </clause> </preface>
         <sections><p class="zzSTDTitle1" displayorder="2"><span class="boldtitle">Introduction &#x2014; Main Title&#x2009;&#x2014;&#x2009;Title &#x2014; </span><span class="nonboldtitle">Part&#xA0;1:</span> <span class="boldtitle">Title Part</span></p>
         <clause id="A" displayorder="3">
                  <fmt-title depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="A">1</semx>
            </span>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="A">1</semx>
         </fmt-xref-label>
          </clause>
         </sections>
       </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                   <p class="zzSTDTitle1">
               <span class="boldtitle">Introduction — Main Title — Title — </span>
               <span class="nonboldtitle">Part 1:</span>
               <span class="boldtitle">Title Part</span>
             </p>
             <div id="A">
               <h1>1</h1>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    xml = Nokogiri::XML(pres_output)
    xml.at("//xmlns:localized-strings")&.remove
    xml.at("//xmlns:boilerplate")&.remove
    xml.at("//xmlns:metanorma-extension")&.remove
    expect(strip_guid(Xml::C14n.format(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "generates an index in English" do
    input = <<~INPUT
      <iso-standard xmlns="https://open.ribose.com/standards/bipm">
        <bibdata>
          <language>en</language>
          <script>Latn</script>
        </bibdata>
        <sections>
          <clause id="A">
            <p>A</p>
            <index><primary>&#xE9;long&#xE9;</primary></index>
            <index><primary>&#xEA;tre</primary><secondary>Husserl</secondary><tertiary>en allemand</tertiary></index>
            <index><primary><em>Eman</em>cipation</primary></index>
            <index><primary><em>Eman</em>cipation</primary><secondary>dans la France</secondary></index>
            <index><primary><em>Eman</em>cipation</primary><secondary>dans la France</secondary><tertiary>en Bretagne</tertiary></index>
            <clause id="B">
              <p>B</p>
              <index><primary><em>Eman</em>cipation</primary></index>
              <index><primary>zebra</primary></index>
              <index><primary><em>Eman</em>cipation</primary><secondary>dans les &#xC9;tats-Unis</secondary></index>
              <index><primary><em>Eman</em>cipation</primary><secondary>dans la France</secondary><tertiary>&#xE0; Paris</tertiary></index>
              <index-xref also="true"><primary>&#xEA;tre</primary><secondary>Husserl</secondary><target>zebra</target></index-xref>
              <index-xref also="true"><primary>&#xEA;tre</primary><secondary>Husserl</secondary><target><em>Eman</em>cipation</target></index-xref>
              <index-xref also="false"><primary>&#xEA;tre</primary><secondary>Husserl</secondary><target>zebra</target></index-xref>
              <index-xref also="false"><primary><em>Dasein</em></primary><target>&#xEA;tre</target></index-xref>
              <index-xref also="false"><primary><em>Dasein</em></primary><target><em>Eman</em>cipation</target></index-xref>
            </clause>
          </clause>
        </sections>
      </bipm-standard>
    INPUT
    presxml = <<~OUTPUT
        <iso-standard xmlns="https://open.ribose.com/standards/bipm" type="presentation">
           <bibdata>
              <language current="true">en</language>
              <script current="true">Latn</script>
           </bibdata>
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <clause id="A" displayorder="2">
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="A">1</semx>
                    </span>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="A">1</semx>
                 </fmt-xref-label>
                 <p>A</p>
                 <bookmark id="_"/>
                 <bookmark id="_"/>
                 <bookmark id="_"/>
                 <bookmark id="_"/>
                 <bookmark id="_"/>
                 <clause id="B" inline-header="true">
                    <fmt-title depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="A">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="B">1</semx>
                       </span>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="A">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="B">1</semx>
                    </fmt-xref-label>
                    <p>B</p>
                    <bookmark id="_"/>
                    <bookmark id="_"/>
                    <bookmark id="_"/>
                    <bookmark id="_"/>
                 </clause>
              </clause>
           </sections>
           <indexsect id="_" displayorder="3">
              <title>Index</title>
              <ul>
                 <li>
                    <em>Dasein</em>
                    , see
                    <em>Eman</em>
                    cipation, être
                 </li>
                 <li>
                    élongé,
                    <xref target="_" pagenumber="true" id="_"/>
                    <semx element="xref" source="_">
                       <fmt-xref target="_" pagenumber="true">
                          <span class="fmt-element-name">Clause</span>
                          <semx element="autonum" source="A">1</semx>
                       </fmt-xref>
                    </semx>
                 </li>
                 <li>
                    <em>Eman</em>
                    cipation,
                    <xref target="_" pagenumber="true" id="_"/>
                    <semx element="xref" source="_">
                       <fmt-xref target="_" pagenumber="true">
                          <span class="fmt-element-name">Clause</span>
                          <semx element="autonum" source="A">1</semx>
                       </fmt-xref>
                    </semx>
                    ,
                    <xref target="_" pagenumber="true" id="_"/>
                    <semx element="xref" source="_">
                       <fmt-xref target="_" pagenumber="true">
                          <semx element="autonum" source="A">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="B">1</semx>
                       </fmt-xref>
                    </semx>
                    <ul>
                       <li>
                          dans la France,
                          <xref target="_" pagenumber="true" id="_"/>
                          <semx element="xref" source="_">
                             <fmt-xref target="_" pagenumber="true">
                                <span class="fmt-element-name">Clause</span>
                                <semx element="autonum" source="A">1</semx>
                             </fmt-xref>
                          </semx>
                          <ul>
                             <li>
                                à Paris,
                                <xref target="_" pagenumber="true" id="_"/>
                                <semx element="xref" source="_">
                                   <fmt-xref target="_" pagenumber="true">
                                      <semx element="autonum" source="A">1</semx>
                                      <span class="fmt-autonum-delim">.</span>
                                      <semx element="autonum" source="B">1</semx>
                                   </fmt-xref>
                                </semx>
                             </li>
                             <li>
                                en Bretagne,
                                <xref target="_" pagenumber="true" id="_"/>
                                <semx element="xref" source="_">
                                   <fmt-xref target="_" pagenumber="true">
                                      <span class="fmt-element-name">Clause</span>
                                      <semx element="autonum" source="A">1</semx>
                                   </fmt-xref>
                                </semx>
                             </li>
                          </ul>
                       </li>
                       <li>
                          dans les États-Unis,
                          <xref target="_" pagenumber="true" id="_"/>
                          <semx element="xref" source="_">
                             <fmt-xref target="_" pagenumber="true">
                                <semx element="autonum" source="A">1</semx>
                                <span class="fmt-autonum-delim">.</span>
                                <semx element="autonum" source="B">1</semx>
                             </fmt-xref>
                          </semx>
                       </li>
                    </ul>
                 </li>
                 <li>
                    être
                    <ul>
                       <li>
                          Husserl, see zebra, see also
                          <em>Eman</em>
                          cipation, zebra
                          <ul>
                             <li>
                                en allemand,
                                <xref target="_" pagenumber="true" id="_"/>
                                <semx element="xref" source="_">
                                   <fmt-xref target="_" pagenumber="true">
                                      <span class="fmt-element-name">Clause</span>
                                      <semx element="autonum" source="A">1</semx>
                                   </fmt-xref>
                                </semx>
                             </li>
                          </ul>
                       </li>
                    </ul>
                 </li>
                 <li>
                    zebra,
                    <xref target="_" pagenumber="true" id="_"/>
                    <semx element="xref" source="_">
                       <fmt-xref target="_" pagenumber="true">
                          <semx element="autonum" source="A">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="B">1</semx>
                       </fmt-xref>
                    </semx>
                 </li>
              </ul>
           </indexsect>
        </iso-standard>
    OUTPUT
    html = <<~OUTPUT
          <html lang='en'>
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
                <br/>
            <div class="TOC" id="_">
              <h1 class="IntroTitle">Contents</h1>
            </div>
            <div id='A'>
              <h1>1</h1>
              <p>A</p>
              <a id='_'/>
              <a id='_'/>
              <a id='_'/>
              <a id='_'/>
              <a id='_'/>
              <div id='B'>
                <span class='zzMoveToFollowing inline-header'>
                  <b>1.1&#160; </b>
                </span>
                <p>B</p>
                <a id='_'/>
                <a id='_'/>
                <a id='_'/>
                <a id='_'/>
              </div>
            </div>
            <div id='_'>
              <h1>Index</h1>
              <div class="ul_wrap">
              <ul>
                <li>
                  <i>Dasein</i>
                   , see
                  <i>Eman</i>
                   cipation, &#234;tre
                </li>
                <li>
                   &#233;long&#233;,
                  <a href='#_'>Clause 1</a>
                </li>
                <li>
                  <i>Eman</i>
                   cipation,
                  <a href='#_'>Clause 1</a>
                   ,
                  <a href='#_'>1.1</a>
                  <div class="ul_wrap">
                  <ul>
                    <li>
                       dans la France,
                      <a href='#_'>Clause 1</a>
                      <div class="ul_wrap">
                      <ul>
                        <li>
                           &#224; Paris,
                          <a href='#_'>1.1</a>
                        </li>
                        <li>
                           en Bretagne,
                          <a href='#_'>Clause 1</a>
                        </li>
                      </ul>
                      </div>
                    </li>
                    <li>
                       dans les &#201;tats-Unis,
                      <a href='#_'>1.1</a>
                    </li>
                  </ul>
                  </div>
                </li>
                <li>
                   &#234;tre
                   <div class="ul_wrap">
                  <ul>
                    <li>
                       Husserl, see zebra, see also
                      <i>Eman</i>
                       cipation, zebra
                       <div class="ul_wrap">
                      <ul>
                        <li>
                           en allemand,
                          <a href='#_'>Clause 1</a>
                        </li>
                      </ul>
                      </div>
                    </li>
                  </ul>
                  </div>
                </li>
                <li>
                   zebra,
                  <a href='#_'>1.1</a>
                </li>
              </ul>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    doc = <<~DOC
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US">
          <p class="MsoNormal">
            <br clear="all" class="section"/>
          </p>
          <br clear="all" style="page-break-before:always;mso-break-type:section-break"/>
          <div class="WordSection3">
            <h1/>
          </div>
          <br clear="all" style="page-break-before:auto;mso-break-type:section-break"/>
          <div class="index">
            <h1>Index</h1>
            <div class="ul_wrap">
              <p style="margin-bottom:0px;;mso-list:l3 level1 lfo1;" class="MsoListParagraphCxSpFirst"><i>Dasein</i>
                , see
                <i>Eman</i>
                cipation, être
              </p>
              <p style="margin-bottom:0px;;mso-list:l3 level1 lfo1;" class="MsoListParagraphCxSpMiddle">
                élongé,
                <a href="#_">Clause 1</a></p>
              <p style="margin-bottom:0px;;mso-list:l3 level1 lfo1;" class="MsoListParagraphCxSpMiddle"><i>Eman</i>
                cipation,
                <a href="#_">Clause 1</a>
                ,
                <a href="#_">1.1</a><div class="ul_wrap"><p style="margin-bottom:0px;;mso-list:l3 level2 lfo1;" class="MsoListParagraphCxSpFirst">
                    dans la France,
                    <a href="#_">Clause 1</a><div class="ul_wrap"><p style="margin-bottom:0px;;mso-list:l3 level3 lfo1;" class="MsoListParagraphCxSpFirst">
                        à Paris,
                        <a href="#_">1.1</a></p><p style="margin-bottom:0px;;mso-list:l3 level3 lfo1;" class="MsoListParagraphCxSpLast">
                        en Bretagne,
                        <a href="#_">Clause 1</a></p></div></p><p style="margin-bottom:0px;;mso-list:l3 level2 lfo1;" class="MsoListParagraphCxSpLast">
                    dans les États-Unis,
                    <a href="#_">1.1</a></p></div></p>
              <p style="margin-bottom:0px;;mso-list:l3 level1 lfo1;" class="MsoListParagraphCxSpMiddle">
                être
                <div class="ul_wrap"><p style="margin-bottom:0px;;mso-list:l3 level2 lfo1;" class="MsoListParagraphCxSpFirst">
                    Husserl, see zebra, see also
                    <i>Eman</i>
                    cipation, zebra
                    <div class="ul_wrap"><p style="margin-bottom:0px;;mso-list:l3 level3 lfo1;" class="MsoListParagraphCxSpFirst">
                        en allemand,
                        <a href="#_">Clause 1</a></p></div></p></div></p>
              <p style="margin-bottom:0px;;mso-list:l3 level1 lfo1;" class="MsoListParagraphCxSpLast">
                zebra,
                <a href="#_">1.1</a></p>
            </div>
          </div>
          <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
          <div class="colophon"/>
          <div style="mso-element:footnote-list"/>
        </body>
    DOC
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_f("test.doc")
    IsoDoc::Iso::WordConvert.new({}).convert("test", pres_output, false)
    expect(File.exist?("test.doc")).to be true
    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>")
    wordxml = Nokogiri::XML(word)
    wordxml.xpath("//div[@class = 'WordSection1' or @class = 'WordSection2']")
      .each(&:remove)
    wordxml.at("//div[@class = 'WordSection3']")&.remove
    expect(Xml::C14n.format(strip_guid(wordxml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(doc)
  end
end
