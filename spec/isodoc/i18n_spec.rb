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
           <fmt-title depth="1">Contents</fmt-title>
           </clause>
           <foreword obligation="informative" displayorder="2">
             <title>Foreword</title>
             <p id="A">This is a preamble</p>
           </foreword>
           <introduction id="B" obligation="informative" displayorder="3">
             <title depth="1">Introduction</title>
             <clause id="C" inline-header="false" obligation="informative">
               <title depth="2">0.1<tab/>Introduction Subsection</title>
             </clause>
             <p>This is patent boilerplate</p>
           </introduction>
         </preface>
         <sections>
           <clause id="D0" type="section" displayorder="6">
             <title depth="1">Section 3:<tab/>General</title>
           </clause>
           <clause id="D" obligation="normative" type="scope" displayorder="4">
             <title depth="1">1<tab/>Scope</title>
             <p id="E">Text</p>
           </clause>
           <clause id="H" obligation="normative" displayorder="7">
             <title depth="1">4<tab/>Terms, definitions, symbols and abbreviated terms</title>
             <terms id="I" obligation="normative">
               <title depth="2">4.1<tab/>Normal Terms</title>
               <term id="J">
                 <name>4.1.1</name>
                 <preferred>
                   <strong>Term2</strong>
                 </preferred>
               </term>
             </terms>
             <definitions id="K">
                        <title depth="2">
              4.2
              <tab/>
              Symbols
           </title>
               <dl>
                 <dt>Symbol</dt>
                 <dd>Definition</dd>
               </dl>
             </definitions>
           </clause>
           <definitions id="L" displayorder="8">
                    <title depth="1">
            5
            <tab/>
            Symbols
         </title>
             <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
             </dl>
           </definitions>
           <clause id="M" inline-header="false" obligation="normative" displayorder="9">
             <title depth="1">6<tab/>Clause 4</title>
             <clause id="N" inline-header="false" obligation="normative">
               <title depth="2">6.1<tab/>Introduction</title>
             </clause>
             <clause id="O" inline-header="false" obligation="normative">
               <title depth="2">6.2<tab/>Clause 4.2</title>
             </clause>
           </clause>
           <references id="R" normative="true" obligation="informative" displayorder="5">
             <title depth="1">2<tab/>Normative References</title>
           </references>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" displayorder="10">
           <title>
             <strong>Annex A</strong>
             <br/>
             <span class="obligation">(normative)</span>
             <br/>
             <br/>
             <strong>Annex</strong>
           </title>
           <clause id="Q" inline-header="false" obligation="normative">
             <title depth="2">A.1<tab/>Annex A.1</title>
             <clause id="Q1" inline-header="false" obligation="normative">
               <title depth="3">A.1.1<tab/>Annex A.1a</title>
             </clause>
           </clause>
           <appendix id="Q2" inline-header="false" obligation="normative">
             <title depth="2">Appendix 1<tab/>An Appendix</title>
           </appendix>
         </annex>
         <bibliography>
           <clause id="S" obligation="informative" displayorder="11">
             <title depth="1">Bibliography</title>
             <references id="T" normative="false" obligation="informative">
               <title depth="2">Bibliography Subsection</title>
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
                      <h2>
               4.2
                
               Symbols
            </h2>
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
                   <h1>
             5
              
             Symbols
          </h1>
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
                <div>
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
                <div id="L" class="Symbols">
                   <h1>
                      5
                      <span style="mso-tab-count:1">  </span>
                      Symbols
                   </h1>
                   <table class="dl">
                      <tr>
                         <td valign="top" align="left">
                            <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                         </td>
                         <td valign="top">Definition</td>
                      </tr>
                   </table>
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
    expect(Xml::C14n.format(strip_guid(pres_output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true)))
      .to be_equivalent_to Xml::C14n.format(word)
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
    expect(Xml::C14n.format(strip_guid(output))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
        <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
          <bibdata>
           <status>
             <stage abbreviation='IS' language=''>60</stage>
             <stage abbreviation="IS" language="tlh">International Standard</stage>
           </status>
           <language current='true'>tlh</language>
           <ext>
             <doctype language=''>international-standard</doctype>
             <doctype language="tlh">International Standard</doctype>
           </ext>
         </bibdata>
          <preface>
            <clause type="toc" id="_" displayorder="1">
              <title depth="1">Table of contents</title>
            </clause>
            <foreword obligation="informative" displayorder='2'>
              <title>Foreword</title>
              <p id="A">This is a preamble</p>
            </foreword>
            <introduction id="B" obligation="informative" displayorder='3'>
              <title depth="1">Introduction</title>
              <clause id="C" inline-header="false" obligation="informative">
                <title depth="2">0.1<tab/>Introduction Subsection</title>
              </clause>
              <p>This is patent boilerplate</p>
            </introduction>
          </preface>
          <sections>
            <clause id="D" obligation="normative" type="scope" displayorder='4'>
              <title depth="1">1<tab/>Scope</title>
              <p id="E">Text</p>
            </clause>
            <clause id="H" obligation="normative" displayorder='6'>
              <title depth="1">3<tab/>Terms, definitions, symbols and abbreviated terms</title>
              <terms id="I" obligation="normative">
                <title depth="2">3.1<tab/>Normal Terms</title>
                <term id="J">
                  <name>3.1.1</name>
                  <preferred><strong>Term2</strong></preferred>
                </term>
              </terms>
              <definitions id="K">
                          <title depth="2">
               3.2
               <tab/>
               Symbols
            </title>
                <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
                </dl>
              </definitions>
            </clause>
            <definitions id="L" displayorder='7'>
                    <title depth="1">
           4
           <tab/>
           Symbols
        </title>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
            <clause id="M" inline-header="false" obligation="normative" displayorder='8'>
              <title depth="1">5<tab/>Clause 4</title>
              <clause id="N" inline-header="false" obligation="normative">
                <title depth="2">5.1<tab/>Introduction</title>
              </clause>
              <clause id="O" inline-header="false" obligation="normative">
                <title depth="2">5.2<tab/>Clause 4.2</title>
              </clause>
            </clause>
            <references id="R" normative="true" obligation="informative" displayorder='5'>
              <title depth="1">2<tab/>Normative References</title>
            </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" displayorder='9'>
            <title>
              <strong>Annex A</strong>
              <br/><span class='obligation'>(normative)</span>
              <br/>
              <br/>
              <strong>Annex</strong></title>
            <clause id="Q" inline-header="false" obligation="normative">
              <title depth="2">A.1<tab/>Annex A.1</title>
              <clause id="Q1" inline-header="false" obligation="normative">
                <title depth="3">A.1.1<tab/>Annex A.1a</title>
              </clause>
            </clause>
            <appendix id="Q2" inline-header="false" obligation="normative">
              <title depth="2">Appendix 1<tab/>An Appendix</title>
            </appendix>
          </annex>
          <bibliography>
            <clause id="S" obligation="informative" displayorder='10'>
              <title depth="1">Bibliography</title>
              <references id="T" normative="false" obligation="informative">
                <title depth="2">Bibliography Subsection</title>
              </references>
            </clause>
          </bibliography>
        </iso-standard>
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
             <title depth="1">Sommaire</title>
           </clause>
           <foreword obligation="informative" displayorder="2">
             <title>Foreword</title>
             <p id="A">This is a preamble</p>
           </foreword>
           <introduction id="B" obligation="informative" displayorder="3">
             <title depth="1">Introduction</title>
             <clause id="C" inline-header="false" obligation="informative">
               <title depth="2">0.1<tab/>Introduction Subsection</title>
             </clause>
             <p>This is patent boilerplate</p>
           </introduction>
         </preface>
         <sections>
           <clause id="D0" type="section" displayorder="6">
             <title depth="1">Section 3 :<tab/>General</title>
           </clause>
           <clause id="D" obligation="normative" type="scope" displayorder="4">
             <title depth="1">1<tab/>Scope</title>
             <p id="E">Text</p>
           </clause>
           <clause id="H" obligation="normative" displayorder="7">
             <title depth="1">4<tab/>Terms, definitions, symbols and abbreviated terms</title>
             <terms id="I" obligation="normative">
               <title depth="2">4.1<tab/>Normal Terms</title>
               <term id="J">
                 <name>4.1.1</name>
                 <preferred>
                   <strong>Term2</strong>
                 </preferred>
               </term>
             </terms>
             <definitions id="K">
               <title depth="2">
              4.2
              <tab/>
              Symboles
           </title>
               <dl>
                 <dt>Symbol</dt>
                 <dd>Definition</dd>
               </dl>
             </definitions>
           </clause>
           <definitions id="L" displayorder="8">
                   <title depth="1">
           5
           <tab/>
           Symboles
        </title>
             <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
             </dl>
           </definitions>
           <clause id="M" inline-header="false" obligation="normative" displayorder="9">
             <title depth="1">6<tab/>Clause 4</title>
             <clause id="N" inline-header="false" obligation="normative">
               <title depth="2">6.1<tab/>Introduction</title>
             </clause>
             <clause id="O" inline-header="false" obligation="normative">
               <title depth="2">6.2<tab/>Clause 4.2</title>
             </clause>
           </clause>
           <references id="R" normative="true" obligation="informative" displayorder="5">
             <title depth="1">2<tab/>Normative References</title>
           </references>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" displayorder="10">
           <title>
             <strong>Annexe A</strong>
             <br/>
             <span class="obligation">(normative)</span>
             <br/>
             <br/>
             <strong>Annex</strong>
           </title>
           <clause id="Q" inline-header="false" obligation="normative">
             <title depth="2">A.1<tab/>Annex A.1</title>
             <clause id="Q1" inline-header="false" obligation="normative">
               <title depth="3">A.1.1<tab/>Annex A.1a</title>
             </clause>
           </clause>
           <appendix id="Q2" inline-header="false" obligation="normative">
             <title depth="2">Appendice 1<tab/>An Appendix</title>
           </appendix>
         </annex>
         <bibliography>
           <clause id="S" obligation="informative" displayorder="11">
             <title depth="1">Bibliography</title>
             <references id="T" normative="false" obligation="informative">
               <title depth="2">Bibliography Subsection</title>
             </references>
           </clause>
         </bibliography>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR.gsub(/"en"/, '"fr"').sub(/Contents/, 'Sommaire')}
      <br/>
             <div>
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
                                    <h2>
               4.2
                
               Symboles
            </h2>
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
                               <h1>
            5
             
            Symboles
         </h1>
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
    expect(Xml::C14n.format(strip_guid(pres_output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_equivalent_to Xml::C14n.format(html)
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
             <title depth="1">Содержание</title>
           </clause>
           <foreword obligation="informative" displayorder="2">
             <title>Foreword</title>
             <p id="A">This is a preamble</p>
           </foreword>
           <introduction id="B" obligation="informative" displayorder="3">
             <title depth="1">Introduction</title>
             <clause id="C" inline-header="false" obligation="informative">
               <title depth="2">0.1<tab/>Introduction Subsection</title>
             </clause>
             <p>This is patent boilerplate</p>
           </introduction>
         </preface>
         <sections>
           <clause id="D0" type="section" displayorder="6">
             <title depth="1">Раздел 3:<tab/>General</title>
           </clause>
           <clause id="D" obligation="normative" type="scope" displayorder="4">
             <title depth="1">1<tab/>Scope</title>
             <p id="E">Text</p>
           </clause>
           <clause id="H" obligation="normative" displayorder="7">
             <title depth="1">4<tab/>Terms, definitions, symbols and abbreviated terms</title>
             <terms id="I" obligation="normative">
               <title depth="2">4.1<tab/>Normal Terms</title>
               <term id="J">
                 <name>4.1.1</name>
                 <preferred>
                   <strong>Term2</strong>
                 </preferred>
               </term>
             </terms>
             <definitions id="K">
               <title depth="2">4.2<tab/>Символы</title>
               <dl>
                 <dt>Symbol</dt>
                 <dd>Definition</dd>
               </dl>
             </definitions>
           </clause>
           <definitions id="L" displayorder="8">
            <title depth="1">5<tab/>Символы</title>

             <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
             </dl>
           </definitions>
           <clause id="M" inline-header="false" obligation="normative" displayorder="9">
             <title depth="1">6<tab/>Clause 4</title>
             <clause id="N" inline-header="false" obligation="normative">
               <title depth="2">6.1<tab/>Introduction</title>
             </clause>
             <clause id="O" inline-header="false" obligation="normative">
               <title depth="2">6.2<tab/>Clause 4.2</title>
             </clause>
           </clause>
           <references id="R" normative="true" obligation="informative" displayorder="5">
             <title depth="1">2<tab/>Normative References</title>
           </references>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" displayorder="10">
           <title>
             <strong>Дополнение A</strong>
             <br/>
             <span class="obligation">(нормативное)</span>
             <br/>
             <br/>
             <strong>Annex</strong>
           </title>
           <clause id="Q" inline-header="false" obligation="normative">
             <title depth="2">A.1<tab/>Annex A.1</title>
             <clause id="Q1" inline-header="false" obligation="normative">
               <title depth="3">A.1.1<tab/>Annex A.1a</title>
             </clause>
           </clause>
           <appendix id="Q2" inline-header="false" obligation="normative">
             <title depth="2">Приложение 1<tab/>An Appendix</title>
           </appendix>
         </annex>
         <bibliography>
           <clause id="S" obligation="informative" displayorder="11">
             <title depth="1">Bibliography</title>
             <references id="T" normative="false" obligation="informative">
               <title depth="2">Bibliography Subsection</title>
             </references>
           </clause>
         </bibliography>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR.gsub(/"en"/, '"ru"').sub(/Contents/, 'Содержание')}
       <br/>
             <div>
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
    expect(Xml::C14n.format(strip_guid(pres_output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_equivalent_to Xml::C14n.format(html)
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
          <clause id="D0" type="section"><title>General</title></clause>
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
             <title depth="1">目　次</title>
           </clause>
           <foreword obligation="informative" displayorder="2">
             <title>Foreword</title>
             <p id="A">This is a preamble</p>
           </foreword>
           <introduction id="B" obligation="informative" displayorder="3">
             <title depth="1">Introduction</title>
             <clause id="C" inline-header="false" obligation="informative">
               <title depth="2">0.1<tab/>Introduction Subsection</title>
             </clause>
             <p>This is patent boilerplate</p>
           </introduction>
         </preface>
         <sections>
           <clause id="D0" type="section" displayorder="6">
             <title depth="1">条3：<tab/>General</title>
           </clause>
           <clause id="D" obligation="normative" type="scope" displayorder="4">
             <title depth="1">1<tab/>Scope</title>
             <p id="E">
               <xref type="inline" target="ISO712"><span class="stdpublisher">ISO </span>
               <span class="stddocNumber">712</span>，
                <span class="citetbl">第1～1表</span></xref>
             </p>
           </clause>
           <clause id="H" obligation="normative" displayorder="7">
             <title depth="1">4<tab/>Terms, definitions, symbols and abbreviated terms</title>
             <terms id="I" obligation="normative">
               <title depth="2">4.1<tab/>Normal Terms</title>
               <term id="J">
                 <name>4.1.1</name>
                 <preferred>
                   <strong>Term2</strong>
                 </preferred>
               </term>
             </terms>
             <definitions id="K">
            <title depth="2">
               4.2
               <tab/>
               符号
            </title>
               <dl>
                 <dt>Symbol</dt>
                 <dd>Definition</dd>
               </dl>
             </definitions>
           </clause>
           <definitions id="L" displayorder="8">
             <title depth="1">5<tab/>符号</title>
             <dl>
               <dt>Symbol</dt>
               <dd>Definition</dd>
             </dl>
           </definitions>
           <clause id="M" inline-header="false" obligation="normative" displayorder="9">
             <title depth="1">6<tab/>Clause 4</title>
             <clause id="N" inline-header="false" obligation="normative">
               <title depth="2">6.1<tab/>Introduction</title>
             </clause>
             <clause id="O" inline-header="false" obligation="normative">
               <title depth="2">6.2<tab/>Clause 4.2</title>
             </clause>
           </clause>
           <references id="R" normative="true" obligation="informative" displayorder="5">
             <title depth="1">2<tab/>Normative References</title>
             <bibitem id="ISO712" type="standard">
               <formattedref><em>Cereals and cereal products</em>.</formattedref>
               <docidentifier>ISO 712</docidentifier>
               <docidentifier scope="biblio-tag">ISO 712</docidentifier>
            <biblio-tag>
               <span class="stdpublisher">ISO </span>
               <span class="stddocNumber">712</span>
               ,
            </biblio-tag>
             </bibitem>
           </references>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" displayorder="10">
           <title>
             <strong>附件A</strong>
             <br/>
             <span class="obligation">（规范性附录）</span>
             <br/>
             <br/>
             <strong>Annex</strong>
           </title>
           <clause id="Q" inline-header="false" obligation="normative">
             <title depth="2">A.1<tab/>Annex A.1</title>
             <clause id="Q1" inline-header="false" obligation="normative">
               <title depth="3">A.1.1<tab/>Annex A.1a</title>
             </clause>
           </clause>
           <appendix id="Q2" inline-header="false" obligation="normative">
             <title depth="2">附录1<tab/>An Appendix</title>
           </appendix>
         </annex>
         <bibliography>
           <clause id="S" obligation="informative" displayorder="11">
             <title depth="1">Bibliography</title>
             <references id="T" normative="false" obligation="informative">
               <title depth="2">Bibliography Subsection</title>
             </references>
           </clause>
         </bibliography>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR.gsub(/"en"/, '"zh"').sub(/Contents/, '目　次')}
                   <br/>
             <div>
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
                 <a href="#ISO712"><span class="stdpublisher">ISO </span>
                  <span class="stddocNumber">712</span>，
                  <span class="citetbl">第1～1表</span></a>
               </p>
             </div>
             <div>
               <h1>2　Normative References</h1>
               <p id="ISO712" class="NormRef"><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span>,
              <i>Cereals and cereal products</i>.</p>
             </div>
             <div id="D0">
               <h1>条3：　General</h1>
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
                 <h2>
                4.2
                　
                符号
             </h2>
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
             <h1>5　符号</h1>
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
    expect(Xml::C14n.format(strip_guid(pres_output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)))
      .to be_equivalent_to Xml::C14n.format(html)
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
      <foreword obligation='informative' displayorder='2'>
              <title>Foreword</title>
              <p id='A'>
     <xref type="inline" target="ISO712">
        <span class="stdpublisher">ISO </span>
        <span class="stddocNumber">712</span>
        , Appendice 7
     </xref>
              </p>
              <p id='B'>
              <xref type="inline" target="ISO712"><span class="stdpublisher">ISO </span>
         <span class="stddocNumber">712</span>
         ,
         <span class="citeapp">Annexe 7</span>
      </xref>
        </p>
      </foreword>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new({}).convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "changes i18n of reference_number based on document scheme" do
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
      <metanorma-extension>
      <presentation-metadata><name>document-scheme</name><value>2024</value></presentation-metadata>
      </metanorma-extension>
      <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <localized-string key="reference_number" language="fr">Numéro de référence</localized-string>
    OUTPUT
    edn = <<~OUTPUT
      <edition language="fr">deuxi&#xE8;me &#xE9;dition</edition>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
    expect(xml.at("//xmlns:localized-string[@key = 'reference_number']").to_xml)
      .to be_equivalent_to output
    expect(xml.at("//xmlns:edition[@language = 'fr']").to_xml)
      .to be_equivalent_to edn

    output = <<~OUTPUT
      <localized-string key="reference_number" language="fr">Réf. №</localized-string>
    OUTPUT
    edn = <<~OUTPUT
      <edition language="fr">2<sup>e</sup> &#xC9;DITION</edition>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub("2024", "1951"), true))
    expect(xml.at("//xmlns:localized-string[@key = 'reference_number']").to_xml)
      .to be_equivalent_to output
    expect(xml.at("//xmlns:edition[@language = 'fr']").to_xml)
      .to be_equivalent_to edn
  end

  it "add edition replacement text" do
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
      <metanorma-extension>
      <presentation-metadata><name>document-scheme</name><value>1951</value></presentation-metadata>
      </metanorma-extension>
      <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
      </sections>
      </iso-standard>
    INPUT

    edn = <<~OUTPUT
      <edn-replacement>Cette deuxi&#xE8;me &#xE9;dition annule et remplace la premi&#xE8;re &#xE9;dition</edn-replacement>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
    expect(xml.at("//xmlns:edn-replacement").to_xml).to be_equivalent_to edn

    edn = <<~OUTPUT
      <edn-replacement>Настоящее второе издание заменяет первое издание</edn-replacement>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input
        .sub("<language>fr</language>", "<language>ru</language>")
        .sub("<script>Latn</script>", "<script>Cyrl</script>"), true))
    expect(xml.at("//xmlns:edn-replacement").to_xml).to be_equivalent_to edn

    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub("1951", "2024"), true))
    expect(xml.at("//xmlns:edn-replacement")).to be_nil

    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input
        .sub("<edition>2</edition>", "<edition>1</edition>"), true))
    expect(xml.at("//xmlns:edn-replacement"))
      .to be_nil
  end

  it "add printing number text" do
    input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>en</language>
      <script>Latn</script>
      <edition>2</edition>
      <ext>
      <doctype>brochure</doctype>
      </ext>
      </bibdata>
      <metanorma-extension>
      <presentation-metadata><name>document-scheme</name><value>1951</value></presentation-metadata>
      <presentation-metadata><printing-date>2</printing-date>value></presentation-metadata>
      <presentation-metadata><printing-date>1965-12-01</printing-date>value></presentation-metadata>
      </metanorma-extension>
      <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
      </sections>
      </iso-standard>
    INPUT

    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
    expect(xml.at("//xmlns:date-printing").to_xml)
      .to be_equivalent_to "<date-printing>Date of the second printing</date-printing>"

    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input
        .sub("<language>en</language>", "<language>fr</language>"), true))
    expect(xml.at("//xmlns:date-printing").to_xml)
      .to be_equivalent_to "<date-printing>Date de la deuxi&#xE8;me impression</date-printing>"

    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input
        .sub("<language>en</language>", "<language>ru</language>")
        .sub("<script>Latn</script>", "<script>Cyrl</script>"), true))
    expect(xml.at("//xmlns:date-printing").to_xml)
      .to be_equivalent_to "<date-printing>&#x414;&#x430;&#x442;&#x430; &#x432;&#x442;&#x43E;&#x440;&#x43E;&#x439; &#x43F;&#x435;&#x447;&#x430;&#x442;&#x438;</date-printing>"

    xml = Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
     .new(presxml_options)
     .convert("test", input
       .sub("<language>en</language>", "<language>ja</language>")
       .sub("<script>Latn</script>", "<script>Japn</script>"), true))
    expect(xml.at("//xmlns:date-printing")).to be_nil
  end
end
