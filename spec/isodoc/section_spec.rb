require "spec_helper"

RSpec.describe IsoDoc do
  it "processes section names" do
    expect(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       <patent-notice>
       <p>This is patent boilerplate</p>
       </patent-notice>
       </introduction></preface><sections>
       <clause id="D" obligation="normative">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
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
       </annex><bibliography><references id="R" obligation="informative">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
    #{HTML_HDR}
                <br/>
                <div>
                  <h1 class="ForewordTitle">Foreword</h1>
                  <p id="A">This is a preamble</p>
                </div>
                <br/>
                <div class="Section3" id="B">
                  <h1 class="IntroTitle">0&#160; Introduction</h1>
                  <div id="C">
           <h2>0.1 Introduction Subsection</h2>
         </div>
                  <p>This is patent boilerplate</p>
                </div>
                <p class="zzSTDTitle1"/>
                <div id="D">
                  <h1>1&#160; Scope</h1>
                  <p id="E">Text</p>
                </div>
                <div>
                  <h1>2&#160; Normative references</h1>
                  <p>There are no normative references in this document.</p>
                </div>
                <div id="H"><h1>3&#160; Terms, definitions, symbols and abbreviated terms</h1>
        <div id="I">
           <h2>3.1 Normal Terms</h2>
           <p class="TermNum" id="J">3.1.1</p>
           <p class="Terms" style="text-align:left;">Term2</p>
      
         </div><div id="K"><h2>3.2 Symbols and abbreviated terms</h2>
           <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
         </div></div>
                <div id="L" class="Symbols">
                  <h1>4&#160; Symbols and abbreviated terms</h1>
                  <dl>
                    <dt>
                      <p>Symbol</p>
                    </dt>
                    <dd>Definition</dd>
                  </dl>
                </div>
                <div id="M">
                  <h1>5&#160; Clause 4</h1>
                  <div id="N">
           <h2>5.1 Introduction</h2>
         </div>
                  <div id="O">
           <h2>5.2 Clause 4.2</h2>
         </div>
                </div>
                <br/>
                <div id="P" class="Section3">
                  <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                  <div id="Q">
           <h2>A.1 Annex A.1</h2>
           <div id="Q1">
           <h3>A.1.1 Annex A.1a</h3>
           </div>
         </div>
                  <div id="Q2">
                <h2>Appendix 1 An Appendix</h2>
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
  end

  it "processes section names (Word)" do
    expect(IsoDoc::Iso::WordConvert.new({}).convert("test", <<~"INPUT", true).sub(/^.*<body /m, "<body ")).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       <patent-notice>
       <p>This is patent boilerplate</p>
       </patent-notice>
       </introduction></preface><sections>
       <clause id="D" obligation="normative">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
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
       </annex><bibliography><references id="R" obligation="informative">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <p><br clear="all" class="section"/></p>
             <div class="WordSection2">
               <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="A">This is a preamble</p>
               </div>
               <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
               <div class="Section3" id="B">
                 <h1 class="IntroTitle">0<span style="mso-tab-count:1">&#160; </span>Introduction</h1>
                 <div id="C">
          <h2>0.1 Introduction Subsection</h2>
        </div>
                 <p>This is patent boilerplate</p>
               </div>
               <p>&#160;</p>
             </div>
             <p><br clear="all" class="section"/></p>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
               <div id="D">
                 <h1>1<span style="mso-tab-count:1">&#160; </span>Scope</h1>
                 <p id="E">Text</p>
               </div>
               <div>
                 <h1>2<span style="mso-tab-count:1">&#160; </span>Normative references</h1>
                 <p>There are no normative references in this document.</p>
               </div>
               <div id="H"><h1>3<span style="mso-tab-count:1">&#160; </span>Terms, definitions, symbols and abbreviated terms</h1>
       <div id="I">
          <h2>3.1 Normal Terms</h2>
          <p class="TermNum" id="J">3.1.1</p>
          <p class="Terms" style="text-align:left;">Term2</p>

        </div><div id="K"><h2>3.2 Symbols and abbreviated terms</h2>
          <table class="dl"><tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;">Symbol</p></td><td valign="top">Definition</td></tr></table>
        </div></div>
               <div id="L" class="Symbols">
                 <h1>4<span style="mso-tab-count:1">&#160; </span>Symbols and abbreviated terms</h1>
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
                 <h1>5<span style="mso-tab-count:1">&#160; </span>Clause 4</h1>
                 <div id="N">
          <h2>5.1 Introduction</h2>
        </div>
                 <div id="O">
          <h2>5.2 Clause 4.2</h2>
        </div>
               </div>
               <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
               <div id="P" class="Section3">
                 <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                 <div id="Q">
          <h2>A.1 Annex A.1</h2>
          <div id="Q1">
          <h3>A.1.1 Annex A.1a</h3>
          </div>
        </div>
                 <div id="Q2">
          <h2>Appendix 1 An Appendix</h2>
        </div>
               </div>
               <p><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
               <div>
                 <h1 class="Section3">Bibliography</h1>
                 <div>
                   <h2 class="Section3">Bibliography Subsection</h2>
                 </div>
               </div>
             </div>
             <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
             <div class="colophon"/>
           </body>
       </html>
OUTPUT
  end

  it "processes simple terms & definitions" do
        expect(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
               <iso-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
        </terms>
        </sections>
        </iso-standard>
    INPUT
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div id="H"><h1>1&#160; Terms and definitions</h1>
       <p class="TermNum" id="J">1.1</p>
         <p class="Terms" style="text-align:left;">Term2</p>
       </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

    it "processes inline section headers" do
    expect(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="true" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>

       </sections>
      </iso-standard>
    INPUT
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div id="M">
                 <h1>1&#160; Clause 4</h1>
                 <div id="N">
          <h2>1.1 Introduction</h2>
        </div>
                 <div id="O">
          <span class="zzMoveToFollowing"><b>1.2 Clause 4.2 </b></span>
        </div>
               </div>
             </div>
           </body>
       </html>
OUTPUT
    end

   it "adds colophon to published standard (Word)" do
    expect(IsoDoc::Iso::WordConvert.new({}).convert("test", <<~"INPUT", true).sub(/^.*<body /m, "<body ")).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
        <status>
          <stage>60</stage>
        </status>
      </bibdata>
      <sections>
      </sections>
      </iso-standard>
      INPUT
          <body lang="EN-US" link="blue" vlink="#954F72">
            <div class="WordSection1">
              <p>&#160;</p>
            </div>
            <p><br clear="all" class="section"/></p>
            <div class="WordSection2">
              <p>&#160;</p>
            </div>
            <p><br clear="all" class="section"/></p>
            <div class="WordSection3">
              <p class="zzSTDTitle1"/>
            </div>
            <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
            <div class="colophon"/>
          </body>
        </html>
      OUTPUT
   end

      it "does not add colophon to draft standard (Word)" do
    expect(IsoDoc::Iso::WordConvert.new({}).convert("test", <<~"INPUT", true).sub(/^.*<body /m, "<body ")).to be_equivalent_to <<~"OUTPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
        <status>
          <stage>30</stage>
        </status>
      </bibdata>
      <sections>
      </sections>
      </iso-standard>
      INPUT
          <body lang="EN-US" link="blue" vlink="#954F72">
            <div class="WordSection1">
              <p>&#160;</p>
            </div>
            <p><br clear="all" class="section"/></p>
            <div class="WordSection2">
              <p>&#160;</p>
            </div>
            <p><br clear="all" class="section"/></p>
            <div class="WordSection3">
              <p class="zzSTDTitle1"/>
            </div>
          </body>
        </html>
      OUTPUT
   end


end
