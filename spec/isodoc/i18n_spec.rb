require "spec_helper"

RSpec.describe IsoDoc do
  it "processes English" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <language>en</language>
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

    presxml = <<~OUTPUT
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <language current="true">en</language>
        </bibdata>
        <preface>
          <foreword obligation="informative" displayorder='1'>
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative" displayorder='2'>
            <title depth="1">0<tab/>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title depth="2">0.1<tab/>Introduction Subsection</title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
        </preface>
        <sections>
          <clause id="D" obligation="normative" type="scope" displayorder='3'>
            <title depth="1">1<tab/>Scope</title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative" displayorder='5'>
            <title depth="1">3<tab/>Terms, definitions, symbols and abbreviated terms</title>
            <terms id="I" obligation="normative">
              <title depth="2">3.1<tab/>Normal Terms</title>
              <term id="J">
                <name>3.1.1</name>
                <preferred><strong>Term2</strong></preferred>
              </term>
            </terms>
            <definitions id="K" inline-header="true">
              <title>3.2</title>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </clause>
          <definitions id="L" displayorder='6'>
            <title>4</title>
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative" displayorder='7'>
            <title depth="1">5<tab/>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title depth="2">5.1<tab/>Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title depth="2">5.2<tab/>Clause 4.2</title>
            </clause>
          </clause>
        </sections>
        <annex id="P" inline-header="false" obligation="normative" displayorder='8'>
          <title>
            <strong>Annex A</strong>
            <br/>(normative)
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
          <references id="R" normative="true" obligation="informative" displayorder='4'>
            <title depth="1">2<tab/>Normative References</title>
          </references>
          <clause id="S" obligation="informative" displayorder='9'>
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
              <h1 class="IntroTitle">0&#160; Introduction</h1>
              <div id="C">
                <h2>0.1&#160; Introduction Subsection</h2>
              </div>
              <p>This is patent boilerplate</p>
            </div>
            <p class="zzSTDTitle1"/>
            <div id="D">
              <h1>1&#160; Scope</h1>
              <p id="E">Text</p>
            </div>
            <div>
              <h1>2&#160; Normative References</h1>
            </div>
            <div id="H">
              <h1>3&#160; Terms, definitions, symbols and abbreviated terms</h1>
              <div id="I">
                <h2>3.1&#160; Normal Terms</h2>

                <p class="TermNum" id="J">3.1.1</p>
                <p class="Terms" style="text-align:left;"><b>Term2</b></p>
              </div>
              <div id="K">
                <span class="zzMoveToFollowing">
                  <b>3.2&#160; </b>
                </span>
                <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
              </div>
            </div>
            <div id="L" class="Symbols">
              <h1>4</h1>
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
                <h2>5.1&#160; Introduction</h2>
              </div>
              <div id="O">
                <h2>5.2&#160; Clause 4.2</h2>
              </div>
            </div>
            <br/>
            <div id="P" class="Section3">
              <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
              <div id="Q"><h2>A.1&#160; Annex A.1</h2>
                <div id="Q1">
                  <h3>A.1.1&#160; Annex A.1a</h3>
                </div>
              </div>
              <div id="Q2">
                <h2>Appendix 1&#160; An Appendix</h2>
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
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
  end

  it "defaults to English" do
    output = IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", <<~"INPUT", true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <language>tlh</language>
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
    expect(xmlpp(output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <language current="true">tlh</language>
          </bibdata>
          <preface>
            <foreword obligation="informative" displayorder='1'>
              <title>Foreword</title>
              <p id="A">This is a preamble</p>
            </foreword>
            <introduction id="B" obligation="informative" displayorder='2'>
              <title depth="1">
                0
                <tab/>
                Introduction
              </title>
              <clause id="C" inline-header="false" obligation="informative">
                <title depth="2">0.1<tab/>Introduction Subsection</title>
              </clause>
              <p>This is patent boilerplate</p>
            </introduction>
          </preface>
          <sections>
            <clause id="D" obligation="normative" type="scope" displayorder='3'>
              <title depth="1">1<tab/>Scope</title>
              <p id="E">Text</p>
            </clause>
            <clause id="H" obligation="normative" displayorder='5'>
              <title depth="1">3<tab/>Terms, definitions, symbols and abbreviated terms</title>
              <terms id="I" obligation="normative">
                <title depth="2">3.1<tab/>Normal Terms</title>
                <term id="J">
                  <name>3.1.1</name>
                  <preferred><strong>Term2</strong></preferred>
                </term>
              </terms>
              <definitions id="K" inline-header="true">
                <title>3.2</title>
                <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
                </dl>
              </definitions>
            </clause>
            <definitions id="L" displayorder='6'>
              <title>4</title>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
            <clause id="M" inline-header="false" obligation="normative" displayorder='7'>
              <title depth="1">5<tab/>Clause 4</title>
              <clause id="N" inline-header="false" obligation="normative">
                <title depth="2">5.1<tab/>Introduction</title>
              </clause>
              <clause id="O" inline-header="false" obligation="normative">
                <title depth="2">5.2<tab/>Clause 4.2</title>
              </clause>
            </clause>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" displayorder='8'>
            <title>
              <strong>Annex A</strong>
              <br/>(normative)
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
            <references id="R" normative="true" obligation="informative" displayorder='4'>
              <title depth="1">2<tab/>Normative References</title>
            </references>
            <clause id="S" obligation="informative" displayorder='9'>
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
          <language>fr</language>
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

    presxml = <<~OUTPUT
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <language current="true">fr</language>
        </bibdata>
        <preface>
          <foreword obligation="informative" displayorder='1'>
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative" displayorder='2'>
            <title depth="1">0<tab/>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title depth="2">0.1<tab/>Introduction Subsection</title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
        </preface>
        <sections>
          <clause id="D" obligation="normative" type="scope" displayorder='3'>
            <title depth="1">1<tab/>Scope</title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative" displayorder='5'>
            <title depth="1">3<tab/>Terms, definitions, symbols and abbreviated terms</title>
            <terms id="I" obligation="normative">
              <title depth="2">3.1<tab/>Normal Terms</title>
              <term id="J">
                <name>3.1.1</name>
                <preferred><strong>Term2</strong></preferred>
              </term>
            </terms>
            <definitions id="K" inline-header="true">
              <title>3.2</title>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </clause>
          <definitions id="L" displayorder='6'>
            <title>4</title>
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative" displayorder='7'>
            <title depth="1">5<tab/>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title depth="2">5.1<tab/>Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title depth="2">5.2<tab/>Clause 4.2</title>
            </clause>
          </clause>
        </sections>
        <annex id="P" inline-header="false" obligation="normative" displayorder='8'>
          <title>
            <strong>Annexe A</strong>
            <br/>(normative)
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
            <title depth="2">Appendice 1<tab/>An Appendix</title>
          </appendix>
        </annex>
        <bibliography>
          <references id="R" normative="true" obligation="informative" displayorder='4'>
            <title depth="1">2<tab/>Normative References</title>
          </references>
          <clause id="S" obligation="informative" displayorder='9'>
            <title depth="1">Bibliography</title>
            <references id="T" normative="false" obligation="informative">
              <title depth="2">Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR.gsub(/"en"/, '"fr"')}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="A">This is a preamble</p>
            </div>
            <br/>
            <div class="Section3" id="B">
              <h1 class="IntroTitle">0&#160; Introduction</h1>
              <div id="C">
                <h2>0.1&#160; Introduction Subsection</h2>
              </div>
              <p>This is patent boilerplate</p>
            </div>
            <p class="zzSTDTitle1"/>
            <div id="D">
              <h1>1&#160; Scope</h1>
              <p id="E">Text</p>
            </div>
            <div>
              <h1>2&#160; Normative References</h1>
            </div>
            <div id="H">
              <h1>3&#160; Terms, definitions, symbols and abbreviated terms</h1>
              <div id="I">
                <h2>3.1&#160; Normal Terms</h2>
                <p class="TermNum" id="J">3.1.1</p>
                <p class="Terms" style="text-align:left;"><b>Term2</b></p>
              </div>
              <div id="K">
                <span class="zzMoveToFollowing">
                  <b>3.2&#160; </b>
                </span>
                <dl>
                  <dt>
                    <p>Symbol</p>
                  </dt>
                  <dd>Definition</dd>
                </dl>
              </div>
            </div>
            <div class="Symbols" id="L">
              <h1>4</h1>
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
                <h2>5.1&#160; Introduction</h2>
              </div>
              <div id="O">
                <h2>5.2&#160; Clause 4.2</h2>
              </div>
            </div>
            <br/>
            <div class="Section3" id="P">
              <h1 class="Annex">
                <b>Annexe A</b>
                <br/>(normative)
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
                <h2>Appendice 1&#160; An Appendix</h2>
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
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
  end

  it "processes Simplified Chinese" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <language>zh</language>
          <script>Hans</script>
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
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <language current="true">zh</language>
          <script current="true">Hans</script>
        </bibdata>
        <preface>
          <foreword obligation="informative" displayorder='1'>
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative" displayorder='2'>
            <title depth="1">0
              <tab/>
              Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title depth="2">0.1
                <tab/>
                Introduction Subsection</title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
        </preface>
        <sections>
          <clause id="D" obligation="normative" type="scope" displayorder='3'>
            <title depth="1">1
              <tab/>
              Scope</title>
            <p id="E">
              <eref bibitemid="ISO712" type="inline"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality>ISO 712、第1–1表</eref>
            </p>
          </clause>
          <clause id="H" obligation="normative" displayorder='5'>
            <title depth="1">3
              <tab/>
              Terms, definitions, symbols and abbreviated terms</title>
            <terms id="I" obligation="normative">
              <title depth="2">3.1
                <tab/>
                Normal Terms</title>
              <term id="J">
                <name>3.1.1</name>
                <preferred><strong>Term2</strong></preferred>
              </term>
            </terms>
            <definitions id="K" inline-header="true">
              <title>3.2</title>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </clause>
          <definitions id="L" displayorder='6'>
            <title>4</title>
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative" displayorder='7'>
            <title depth="1">5
              <tab/>
              Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title depth="2">5.1
                <tab/>
                Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title depth="2">5.2
                <tab/>
                Clause 4.2</title>
            </clause>
          </clause>
        </sections>
        <annex id="P" inline-header="false" obligation="normative" displayorder='8'>
          <title>
            <strong>附件A</strong>
            <br/>（规范性附录）
            <br/>
            <br/>
            <strong>Annex</strong></title>
          <clause id="Q" inline-header="false" obligation="normative">
            <title depth="2">A.1
              <tab/>
              Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
              <title depth="3">A.1.1
                <tab/>
                Annex A.1a</title>
            </clause>
          </clause>
          <appendix id="Q2" inline-header="false" obligation="normative">
            <title depth="2">附录1
              <tab/>
              An Appendix</title>
          </appendix>
        </annex>
        <bibliography>
          <references id="R" normative="true" obligation="informative" displayorder='4'>
            <title depth="1">2
              <tab/>
              Normative References</title>
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
          <clause id="S" obligation="informative" displayorder='9'>
            <title depth="1">Bibliography</title>
            <references id="T" normative="false" obligation="informative">
              <title depth="2">Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR.gsub(/"en"/, '"zh"')}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="A">This is a preamble</p>
            </div>
            <br/>
            <div class="Section3" id="B">
              <h1 class="IntroTitle">0 &#12288; Introduction</h1>
              <div id="C">
                <h2>0.1 &#12288; Introduction Subsection</h2>
              </div>
              <p>This is patent boilerplate</p>
            </div>
            <p class="zzSTDTitle1"/>
            <div id="D">
              <h1>1 &#12288; Scope</h1>
              <p id="E"><a href='#ISO712'>ISO 712&#12289;&#31532;1&#8211;1&#34920;</a></p>
            </div>
            <div>
              <h1>2 &#12288; Normative References</h1>
              <p id="ISO712" class="NormRef">ISO 712, <i>Cereals and cereal products</i></p>
            </div>
            <div id="H">
              <h1>3 &#12288; Terms, definitions, symbols and abbreviated terms</h1>
              <div id="I"><h2>3.1 &#12288; Normal Terms</h2>
                <p class="TermNum" id="J">3.1.1</p>
                <p class="Terms" style="text-align:left;"><b>Term2</b></p>
              </div><div id="K">
              <span class='zzMoveToFollowing'>
                <b>3.2&#12288;</b>
              </span>
                <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
              </div></div>
            <div id="L" class="Symbols">
              <h1>4</h1>
              <dl>
                <dt>
                  <p>Symbol</p>
                </dt>
                <dd>Definition</dd>
              </dl>
            </div>
            <div id="M">
              <h1>5 &#12288; Clause 4</h1>
              <div id="N">
                <h2>5.1 &#12288; Introduction</h2>
              </div>
              <div id="O">
                <h2>5.2 &#12288; Clause 4.2</h2>
              </div>
            </div>
            <br/>
            <div id="P" class="Section3">
              <h1 class="Annex"><b>&#38468;&#20214;A</b><br/>&#65288;&#35268;&#33539;&#24615;&#38468;&#24405;&#65289;<br/><br/><b>Annex</b></h1>
              <div id="Q">
                <h2>A.1 &#12288; Annex A.1</h2>
                <div id="Q1"><h3>A.1.1 &#12288; Annex A.1a</h3></div>
              </div>
              <div id="Q2">
                <h2>&#38468;&#24405;1 &#12288; An Appendix</h2>
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
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
  end
end
