require "spec_helper"
require "fileutils"

WORD_HTML_CSS = {
  wordstylesheet: "spec/assets/word.css",
  htmlstylesheet: "spec/assets/html.css",
}.freeze

WORD_HTML_CSS_SUBDIR = {
  wordstylesheet: "word.css",
  htmlstylesheet: "html.css",
}.freeze

WORD_HTML_CSS_HEADER_HTML = {
  wordstylesheet: "spec/assets/word.css",
  htmlstylesheet: "spec/assets/html.css",
  header: "spec/assets/header.html",
}.freeze

WORD_HTML_CSS_WORDINTRO = {
  wordstylesheet: "spec/assets/word.css",
  htmlstylesheet: "spec/assets/html.css",
  wordintropage: "spec/assets/wordintro.html",
}.freeze

RSpec.describe IsoDoc do
  it "generates file based on string input" do
    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS.merge(filename: "test"))
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
              <title format="text/plain" language="en" type="title-intro">Cereals and pulses</title>
              <title format="text/plain" language="en" type="title-main">Specifications and test methods</title>
              <title format="text/plain" language="en" type="title-part">Rice</title>
          </bibdata>
          <preface>
            <foreword>
              <note>
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
              </note>
            </foreword>
          </preface>
        </iso-standard>
    INPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    expect(html).to include "<title>Cereals and pulses&#xA0;&#x2014; "\
                            "Specifications and test methods&#xA0;&#x2014; Rice</title>"
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
  end

  it "generates HTML output docs with null configuration" do
    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
              <title format="text/plain" language="en" type="title-intro">Cereals and pulses</title>
              <title format="text/plain" language="en" type="title-main">Specifications and test methods</title>
              <title format="text/plain" language="en" type="title-part">Rice</title>
          </bibdata>
          <preface>
            <foreword>
              <note>
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
              </note>
            </foreword>
          </preface>
        </iso-standard>
      INPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    expect(html).to include "title>Cereals and pulses&#xA0;&#x2014; "\
                            "Specifications and test methods&#xA0;&#x2014; Rice</title>"
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
  end

  it "generates Word output docs with null configuration" do
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
            <foreword>
              <note>
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
              </note>
            </foreword>
          </preface>
        </iso-standard>
      INPUT
    expect(File.exist?("test.doc")).to be true
    word = File.read("test.doc", encoding: "UTF-8")
    expect(word).to match(/<style>/)
  end

  it "generates HTML output docs with null configuration from file" do
    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS_SUBDIR.dup)
      .convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.html")).to be true
    html = File.read("spec/assets/iso.html", encoding: "UTF-8")
    expect(html).to match(/<style>/)
    expect(html).to match(%r{https://use.fontawesome.com})
    expect(html).to match(%r{libs/jquery})
  end

  it "generates Word output docs with null configuration from file" do
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS_SUBDIR.dup)
      .convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.doc")).to be true
    word = File.read("spec/assets/iso.doc", encoding: "UTF-8")
    expect(word).to match(/<w:WordDocument>/)
    expect(word).to match(/<style>/)
  end

  it "generates Pdf output docs with null configuration from file" do
    mock_pdf
    IsoDoc::Iso::PdfConvert
      .new(WORD_HTML_CSS.dup)
      .convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.pdf")).to be true
  end

  it "populates Word template with terms reference labels" do
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
            <terms id="_terms_and_definitions" obligation="normative">
              <title>1
                <tab/>
                Terms and Definitions</title>
              <term id="paddy1">
                <name>1.1</name>
                <preferred>paddy</preferred>
                <definition>
                  <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
                </definition>
                <termsource status="modified">[SOURCE:
                  <origin bibitemid="ISO7301" citeas="ISO 7301:2011" type="inline"><locality type="clause">
                      <referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>, modified &#x2013;
                    The term &quot;cargo rice&quot; is shown as deprecated, and Note 1 to entry is not included here]
                </termsource>
              </term>
            </terms>
          </sections>
        </iso-standard>
      INPUT

    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">')
      .sub(%r{<br[^>]*>\s*<div class="colophon".*$}m, "")

    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <div class='WordSection3'>
         <p class='zzSTDTitle1'/>
         <div>
           <a name='_terms_and_definitions' id='_terms_and_definitions'/>
           <h1>
             1
             <span style='mso-tab-count:1'>&#xA0; </span>
              Terms and Definitions
           </h1>
           <p class='TermNum'>
             <a name='paddy1' id='paddy1'/>
             1.1
           </p>
           <p class='Terms' style='text-align:left;'>paddy</p>
           <p class='Definition'>
             <a name='_eb29b35e-123e-4d1c-b50b-2714d41e747f' id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'/>
             rice retaining its husk after threshing
           </p>
           <p class='Source'>
             [SOURCE: ISO 7301:2011, 3.1, modified &#x2013; The term "cargo rice" is shown as deprecated, and Note
             1 to entry is not included here]
           </p>
         </div>
       </div>
    OUTPUT
  end

  it "populates Word header" do
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS_HEADER_HTML.dup)
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="article">
            <docidentifier>
              <project-number part="1">1000</project-number>
            </docidentifier>
          </bibdata>
        </iso-standard>
      INPUT
    word = File.read("test.doc", encoding: "UTF-8")
    expect(word).to include('Content-Disposition: inline; filename="header.html"')
  end

  it "populates HTML ToC" do
    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
            <clause id="A" inline-header="false" obligation="normative">
              <title>1
                <tab/>
                Clause 4</title>
              <clause id="N" inline-header="false" obligation="normative">
                <title>1.1
                  <tab/>
                  Introduction
                  <bookmark id="Q"/>
                  to this
                  <fn reference="1">
                    <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
                </title>
              </clause>
              <clause id="O" inline-header="false" obligation="normative">
                <title>1.2
                  <tab/>
                  Clause 4.2</title>
                <p>A
                  <fn reference="1">
                    <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
                </p>
              </clause>
            </clause>
            <clause id="P"><title>2<tab/>Clause 5</title>
            <clause id="P1"><title>2.1<tab/>Clause 5.1</title></clause>
            </clause>
            <clause id="Q"><title>3<tab/>Clause 6</title></clause>
          </sections>
        </iso-standard>
      INPUT

    html = Nokogiri::XML(File.read("test.html", encoding: "UTF-8"))
      .at("//div[@id = 'toc']").to_xml

    expect(xmlpp(html))
      .to be_equivalent_to xmlpp(<<~'OUTPUT')
        <div id='toc'>
          <ul>
            <li class='h1'>
              <div class='collapse-group'>
                <a href='#toc0'>1 &#xA0; Clause 4</a>
                <div class='collapse-button'/>
              </div>
              <ul class='content collapse'>
                <li class='h2'>
                  <a href='#toc1'> 1.1 &#xA0; Introduction to this </a>
                </li>
                <li class='h2'>
                  <a href='#toc2'> 1.2 &#xA0; Clause 4.2</a>
                </li>
              </ul>
            </li>
            <li class='h1'>
              <div class='collapse-group'>
                <a href='#toc3'>2&#xA0; Clause 5</a>
                <div class='collapse-button'/>
              </div>
              <ul class='content collapse'>
                <li class='h2'>
                  <a href='#toc4'> 2.1&#xA0; Clause 5.1</a>
                </li>
              </ul>
            </li>
            <li class='h1'>
              <a href='#toc5'> 3&#xA0; Clause 6</a>
            </li>
          </ul>
        </div>
      OUTPUT
  end

  it "populates Word ToC" do
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS_WORDINTRO.dup)
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
            <clause id="A" inline-header="false" obligation="normative">
              <title>1
                <tab/>
                Clause 4</title>
              <clause id="N" inline-header="false" obligation="normative">
                <title>1.1
                  <tab/>
                  Introduction
                  <bookmark id="Q"/>
                  to this
                  <fn reference="1">
                    <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
                </title>
              </clause>
              <clause id="O" inline-header="false" obligation="normative">
                <title>1.2
                  <tab/>
                  Clause 4.2</title>
                <p>A
                  <fn reference="1">
                    <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
                </p>
              </clause>
            </clause>
          </sections>
          <annex id="AA"><title>Annex A<tab/>Annex First</title></annex>
        </iso-standard>
      INPUT

    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*An empty word intro page\./m, "")
      .sub(%r{</div>.*$}m, "</div>")
      .gsub(/<o:p>&#xA0;<\/o:p>/, "")

    expect(xmlpp("<div>#{word.gsub(/_Toc\d\d+/, '_Toc')}"))
      .to be_equivalent_to xmlpp(<<~'OUTPUT')
        <div>
          <p class="MsoToc1">
            <span lang="EN-GB" xml:lang="EN-GB">
              <span style="mso-element:field-begin"/>
              <span style='mso-spacerun:yes'>&#xA0;</span>
              TOC \o "1-3" \h \z \t "Heading 1;1;ANNEX;1;Biblio Title;1;Foreword
              Title;1;Intro Title;1"
              <span style="mso-element:field-separator"/></span>
            <span class="MsoHyperlink">
              <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
                <a href="#_Toc">1 Clause 4
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-tab-count:1 dotted">. </span></span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-begin"/>
                  </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">PAGEREF _Toc \h </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-separator"/>
                  </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">1</span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB"/>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-end"/>
                  </span>
                </a>
              </span>
            </span>
          </p>
          <p class="MsoToc2">
            <span class="MsoHyperlink">
              <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
                <a href="#_Toc">1.1 Introduction to this
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-tab-count:1 dotted">. </span></span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-begin"/>
                  </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">PAGEREF _Toc \h </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-separator"/>
                  </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">1</span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB"/>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-end"/>
                  </span>
                </a>
              </span>
            </span>
          </p>
          <p class="MsoToc2">
            <span class="MsoHyperlink">
              <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
                <a href="#_Toc">1.2 Clause 4.2
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-tab-count:1 dotted">. </span></span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-begin"/>
                  </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">PAGEREF _Toc \h </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-separator"/>
                  </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">1</span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB"/>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-end"/>
                  </span>
                </a>
              </span>
            </span>
          </p>
          <p class='MsoToc1'>
           <span class='MsoHyperlink'>
             <span lang='EN-GB' xml:lang='EN-GB' style='mso-no-proof:yes'>
               <a href='#_Toc'>
                 Annex A Annex First
                 <span lang='EN-GB' xml:lang='EN-GB' class='MsoTocTextSpan'>
                   <span style='mso-tab-count:1 dotted'>. </span>
                 </span>
                 <span lang='EN-GB' xml:lang='EN-GB' class='MsoTocTextSpan'>
                   <span style='mso-element:field-begin'/>
                 </span>
                 <span lang='EN-GB' xml:lang='EN-GB' class='MsoTocTextSpan'> PAGEREF _Toc \h </span>
                 <span lang='EN-GB' xml:lang='EN-GB' class='MsoTocTextSpan'>
                   <span style='mso-element:field-separator'/>
                 </span>
                 <span lang='EN-GB' xml:lang='EN-GB' class='MsoTocTextSpan'>1</span>
                 <span lang='EN-GB' xml:lang='EN-GB' class='MsoTocTextSpan'/>
                 <span lang='EN-GB' xml:lang='EN-GB' class='MsoTocTextSpan'>
                   <span style='mso-element:field-end'/>
                 </span>
               </a>
             </span>
           </span>
         </p>
          <p class="MsoToc1">
            <span lang="EN-GB" xml:lang="EN-GB">
              <span style="mso-element:field-end"/>
            </span>
            <span lang="EN-GB" xml:lang="EN-GB">
            </span>
          </p>
          <p class="MsoNormal"> </p>
        </div>
      OUTPUT
  end

  it "reorders footnote numbers" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <clause id="A" inline-header="false" obligation="normative">
            <title>1
              <tab/>
              Clause 4</title>
            <fn reference="3">
              <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">This is a footnote.</p>
            </fn>
            <clause id="N" inline-header="false" obligation="normative">
              <title>1.1 <tab/>
                Introduction to this
                <fn reference="2">
                  <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
              </title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title>1.2 <tab/>
                Clause 4.2</title>
              <p>A
                <fn reference="1">
                  <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
              </p>
            </clause>
          </clause>
        </sections>
      </iso-standard>
    INPUT

    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS_WORDINTRO.dup)
      .convert("test", input, false)

    html = File.read("test.html", encoding: "UTF-8")
      .sub(/^.*<main class="main-section">/m,
           '<main xmlns:epub="epub" class="main-section">')
      .sub(%r{</main>.*$}m, "</main>")

    expect(xmlpp(html)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <main class="main-section" xmlns:epub="epub">
        <button id="myBtn" onclick="topFunction()" title="Go to top">Top</button>
        <p class="zzSTDTitle1"/>
        <div id="A">
          <h1 id="toc0">1 &#xA0; Clause 4</h1>
          <a class="FootnoteRef" href="#fn:3" id="fnref:1">
            <sup>1)</sup>
          </a>
          <div id="N">
            <h2 id="toc1">1.1 &#xA0; Introduction to this
              <a class="FootnoteRef" href="#fn:2" id="fnref:2">
                <sup>2)</sup></a>
            </h2>
          </div>
          <div id="O">
            <h2 id="toc2">1.2 &#xA0; Clause 4.2</h2>
            <p>A
              <a class="FootnoteRef" href="#fn:2">
                <sup>2)</sup></a>
            </p>
          </div>
        </div>
        <aside class="footnote" id="fn:3">
          <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">
            <a class="FootnoteRef" href="#fn:3">
              <sup>1)</sup>
            </a>This is a footnote.</p>
          <a href="#fnref:1">↩</a>
        </aside>
        <aside class="footnote" id="fn:2">
          <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">
            <a class="FootnoteRef" href="#fn:2">
              <sup>2)</sup>
            </a>Formerly denoted as 15 % (m/m).</p>
          <a href="#fnref:2">↩</a>
        </aside>
      </main>
    OUTPUT

    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS_WORDINTRO.dup)
      .convert("test", input, false)

    html = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<div class="WordSection3"/m,
           '<body xmlns:epub="epub"><div class="WordSection3"')
      .sub(%r{</body>.*$}m, "</body>")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")

    expect(xmlpp(html)).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <body xmlns:epub="epub">
        <div class="WordSection3">
          <p class="zzSTDTitle1"/>
          <div>
            <a id="A" name="A"/>
            <h1>1
              <span style="mso-tab-count:1">  </span>
              Clause 4</h1>
            <span style="mso-bookmark:_Ref">
              <a class="FootnoteRef" epub:type="footnote" href="#_ftn1" id="_ftnref1" name="_ftnref1" style="mso-footnote-id:ftn1" title="">
                <span class="MsoFootnoteReference">
                  <span style="mso-special-character:footnote"/>
                </span>
                <span class="MsoFootnoteReference">)</span>
              </a>
            </span>
            <div>
              <a id="N" name="N"/>
              <h2>1.1
                <span style="mso-tab-count:1">  </span>
                Introduction to this
                <span style="mso-bookmark:_Ref">
                  <a class="FootnoteRef" epub:type="footnote" href="#_ftn2" id="_ftnref2" name="_ftnref2" style="mso-footnote-id:ftn2" title="">
                    <span class="MsoFootnoteReference">
                      <span style="mso-special-character:footnote"/></span>
                    <span class="MsoFootnoteReference">)</span>
                  </a>
                </span>
              </h2>
            </div>
            <div>
              <a id="O" name="O"/>
              <h2>1.2
                <span style="mso-tab-count:1">  </span>
                Clause 4.2</h2>
              <p class="MsoNormal">A
                <span style="mso-bookmark:_Ref">
                  <a class="FootnoteRef" epub:type="footnote" href="#_ftn3" id="_ftnref3" name="_ftnref3" style="mso-footnote-id:ftn3" title="">
                    <span class="MsoFootnoteReference">
                      <span style="mso-special-character:footnote"/></span>
                    <span class="MsoFootnoteReference">)</span>
                  </a>
                </span>
              </p>
            </div>
          </div>
        </div>
        <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"/>
        <div style="mso-element:footnote-list">
          <div id="ftn1" style="mso-element:footnote">
            <p class="MsoFootnoteText">
              <a id="_ff27c067-2785-4551-96cf-0a73530ff1e6" name="_ff27c067-2785-4551-96cf-0a73530ff1e6"/>
              <a href="#_ftn1" id="_ftnref1" name="_ftnref1" style="mso-footnote-id:ftn1" title="">
                <span class="MsoFootnoteReference">
                  <span style="mso-special-character:footnote"/>
                </span>
                <span class="MsoFootnoteReference">)</span>
              </a>This is a footnote.</p>
          </div>
          <div id="ftn2" style="mso-element:footnote">
            <p class="MsoFootnoteText">
              <a id="_ff27c067-2785-4551-96cf-0a73530ff1e6" name="_ff27c067-2785-4551-96cf-0a73530ff1e6"/>
              <a href="#_ftn2" id="_ftnref2" name="_ftnref2" style="mso-footnote-id:ftn2" title="">
                <span class="MsoFootnoteReference">
                  <span style="mso-special-character:footnote"/>
                </span>
                <span class="MsoFootnoteReference">)</span>
              </a>Formerly denoted as 15 % (m/m).</p>
          </div>
          <div id="ftn3" style="mso-element:footnote">
            <p class="MsoFootnoteText">
              <a id="_ff27c067-2785-4551-96cf-0a73530ff1e6" name="_ff27c067-2785-4551-96cf-0a73530ff1e6"/>
              <a href="#_ftn3" id="_ftnref3" name="_ftnref3" style="mso-footnote-id:ftn3" title="">
                <span class="MsoFootnoteReference">
                  <span style="mso-special-character:footnote"/>
                </span>
                <span class="MsoFootnoteReference">)</span>
              </a>Formerly denoted as 15 % (m/m).</p>
          </div>
        </div>
      </body>
    OUTPUT
  end

  it "processes IsoXML terms for HTML" do
    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
            <terms id="_terms_and_definitions" obligation="normative">
              <title>Terms and Definitions</title>
              <term id="paddy1">
                <name>1.1</name>
                <preferred>paddy</preferred>
                <domain>rice</domain>
                <definition>
                  <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
                </definition>
                <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
                  <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
                  <ul>
                    <li>A</li>
                  </ul>
                </termexample>
                <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
                  <ul>
                    <li>A</li>
                  </ul>
                </termexample>
                <termsource status="modified">
                  <origin bibitemid="ISO7301" citeas="ISO 7301:2011" type="inline">
                    <locality type="clause">
                      <referenceFrom>3.1</referenceFrom>
                    </locality>
                  </origin>
                  <modification>
                    <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term &quot;cargo rice&quot; is shown as deprecated, and Note 1 to entry is not included here</p>
                  </modification>
                </termsource>
              </term>
              <term id="paddy">
                <name>1.2</name>
                <preferred>paddy</preferred>
                <admitted>paddy rice</admitted>
                <admitted>rough rice</admitted>
                <deprecates>cargo rice</deprecates>
                <definition>
                  <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
                </definition>
                <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
                  <ul>
                    <li>A</li>
                  </ul>
                </termexample>
                <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
                  <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                </termnote>
                <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
                  <ul>
                    <li>A</li>
                  </ul>
                  <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                </termnote>
                <termsource status="identical">
                  <origin bibitemid="ISO7301" citeas="ISO 7301:2011" type="inline">
                    <locality type="clause">
                      <referenceFrom>3.1</referenceFrom>
                    </locality>
                  </origin>
                </termsource>
              </term>
            </terms>
          </sections>
        </iso-standard>
      INPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    expect(html).to match(%r{<h2 class="TermNum" id="paddy1">1\.1</h2>})
    expect(html).to match(%r{<h2 class="TermNum" id="paddy">1\.2</h2>})
  end

  it "inserts default paragraph between two tables for Word" do
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <annex id="P" inline-header="false" obligation="normative">
            <example id="_63112cbc-cde0-435f-9553-e0b8c4f5851c">
              <p id="_158d4efa-b1c9-4aec-b325-756de8e4c968">'1M', '01M', and '0001M' all describe the calendar month January.</p>
            </example>
            <example id="_63112cbc-cde0-435f-9553-e0b8c4f5851d">
              <p id="_158d4efa-b1c9-4aec-b325-756de8e4c969">'2M', '02M', and '0002M' all describe the calendar month February.</p>
            </example>
          </annex>
        </iso-standard>
      INPUT
    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">')
      .sub(%r{<br[^>]*>\s*<div class="colophon".*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <div class="WordSection3">
        <p class="zzSTDTitle1"/>
        <p class="MsoNormal">
          <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
        </p>
        <div class="Section3">
          <a id="P" name="P"/>
          <div class="Example">
            <a id="_63112cbc-cde0-435f-9553-e0b8c4f5851c" name="_63112cbc-cde0-435f-9553-e0b8c4f5851c"/>
            <p class="Example">
              <span style="mso-tab-count:1">  </span>'1M', '01M', and '0001M' all describe the calendar month January.</p>
          </div>
          <div class="Example">
            <a id="_63112cbc-cde0-435f-9553-e0b8c4f5851d" name="_63112cbc-cde0-435f-9553-e0b8c4f5851d"/>
            <p class="Example">
              <span style="mso-tab-count:1">  </span>'2M', '02M', and '0002M' all describe the calendar month February.</p>
          </div>
        </div>
      </div>
    OUTPUT
  end

  it "processes figure keys (Word)" do
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <annex id="P" inline-header="false" obligation="normative">
            <figure id="samplecode">
              <p>Hello</p>
              <p>Key</p>
              <dl>
                <dt>
                  <p>A</p>
                </dt>
                <dd>
                  <p>B</p>
                </dd>
              </dl>
            </figure>
          </annex>
        </iso-standard>
      INPUT
    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">')
      .sub(%r{<br[^>]*>\s*<div class="colophon".*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <div class="WordSection3">
        <p class="zzSTDTitle1"/>
        <p class="MsoNormal">
          <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
        </p>
        <div class="Section3">
          <a id="P" name="P"/>
          <div class="MsoNormal" style='text-align:center;'>
            <a id="samplecode" name="samplecode"/>
            <p class="MsoNormal">Hello</p>
            <p class="MsoNormal">Key</p>
            <p class="MsoNormal" style="page-break-after:avoid;">
              <b>Key</b>
            </p>
            <div class="figdl" style="page-break-after:avoid;">
              <table class="figdl">
                <tr>
                  <td align="left" valign="top">
                    <p align="left" class="MsoNormal" style="margin-left:0pt;text-align:left;">
                      <p class="MsoNormal">A</p>
                    </p>
                  </td>
                  <td valign="top">
                    <p class="MsoNormal">B</p>
                  </td>
                </tr>
              </table>
            </div>
          </div>
        </div>
      </div>
    OUTPUT
  end

  it "processes editorial notes (Word)" do
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~"INPUT", false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
            <annex id="P" inline-header="false" obligation="normative">
            <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="editorial">
                           <p id='_e94663cc-2473-4ccc-9a72-983a74d989f2'>
                   Only use paddy or parboiled rice for the
                   determination of husked rice yield.
                 </p>
          <p id="_e94663cc-2473-4ccc-9a72-983a74d989f3">Para 2.</p>
        </admonition>
            </annex>
          </iso-standard>
      INPUT
    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">')
      .sub(%r{<br[^>]*>\s*<div class="colophon".*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <div class='WordSection3'>
         <p class='zzSTDTitle1'/>
         <p class='MsoNormal'>
           <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
         </p>
         <div class='Section3'>
           <a name='P' id='P'/>
           <div class='zzHelp'>
             <a name='_70234f78-64e5-4dfc-8b6f-f3f037348b6a' id='_70234f78-64e5-4dfc-8b6f-f3f037348b6a'/>
             <p class='zzHelp'> Only use paddy or parboiled rice for the determination of husked rice yield. </p>
             <p class='zzHelp'>
               <a name='_e94663cc-2473-4ccc-9a72-983a74d989f3' id='_e94663cc-2473-4ccc-9a72-983a74d989f3'/>
               Para 2.
             </p>
           </div>
         </div>
       </div>
    OUTPUT
  end

  it "processes boilerplate" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
          <status>
            <stage>30</stage>
          </status>
        </bibdata>
        <boilerplate>
          <copyright-statement>
            <clause>
              <p id="boilerplate-year">© ISO 2019, Published in Switzerland</p>
              <p id="boilerplate-message">I am the Walrus.</p>
              <p id="boilerplate-name">ISO copyright office</p>
              <p align="left" id="boilerplate-address">ISO copyright office
                <br/>
                Ch. de Blandonnet 8 ?~@? CP 401
                <br/>
                CH-1214 Vernier, Geneva, Switzerland
                <br/>
                Phone: +41 22 749 01 11
                <br/>
                Email: copyright@iso.org
                <br/>
                www.iso.org</p>
            </clause>
          </copyright-statement>
          <license-statement>
            <clause>
              <title>Warning for Stuff</title>
              <p>This document is not an ISO International Standard. It is distributed for review and
      comment. It is subject to change without notice and may not be referred to as
      an International Standard.</p>
              <p>Recipients
      of this draft are invited to submit, with their comments, notification of any
      relevant patent rights of which they are aware and to provide supporting
      documentation.</p>
            </clause>
          </license-statement>
        </boilerplate>
      </iso-standard>
    INPUT

    presxml = <<~OUTPUT
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
          <status>
            <stage language="">30</stage>
            <stage language='en'>Committee draft</stage>
          </status>
        </bibdata>
        <boilerplate>
          <copyright-statement>
            <clause inline-header="true">
              <p id="boilerplate-year">© ISO 2019, Published in Switzerland
               </p>
              <p id="boilerplate-message">I am the Walrus.
               </p>
              <p id="boilerplate-name">ISO copyright office</p>
              <p align="left" id="boilerplate-address">ISO copyright office
                <br/>
                Ch. de Blandonnet 8 ?~@? CP 401
                <br/>
                CH-1214 Vernier, Geneva, Switzerland
                <br/>
                Phone: +41 22 749 01 11
                <br/>
                Email: copyright@iso.org
                <br/>
                www.iso.org</p>
            </clause>
          </copyright-statement>
          <license-statement>
            <clause>
              <title depth="1">Warning for Stuff</title>
              <p>This document is not an ISO International Standard. It is distributed for review and
             comment. It is subject to change without notice and may not be referred to as
             an International Standard.</p>
              <p>Recipients
             of this draft are invited to submit, with their comments, notification of any
             relevant patent rights of which they are aware and to provide supporting
             documentation.</p>
            </clause>
          </license-statement>
        </boilerplate>
      </iso-standard>
    OUTPUT

    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new(WORD_HTML_CSS.dup)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(presxml)

    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", presxml, false)

    word = File.read("test.html", encoding: "UTF-8")
    expect((word)).to include '<h1 class="IntroTitle">Warning for Stuff</h1>'
    expect((word)).to include "I am the Walrus."

    IsoDoc::Iso::WordConvert.new(WORD_HTML_CSS.dup)
      .convert("test", presxml, false)
    word = File.read("test.doc", encoding: "UTF-8")
    expect(xmlpp(word
      .sub(%r{^.*<div class="boilerplate-copyright">}m,
           '<div class="boilerplate-copyright">')
      .sub(%r{</div>.*$}m, "</div></div>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <div class="boilerplate-copyright">
          <div>
            <p class="zzCopyright">
              <a id="boilerplate-year" name="boilerplate-year"/>© ISO 2019, Published in Switzerland#{' '}</p>
            <p class="zzCopyright1">
              <a id="boilerplate-message" name="boilerplate-message"/>I am the Walrus.#{' '}</p>
            <p class="zzCopyright">
              <a id="boilerplate-name" name="boilerplate-name"/>ISO copyright office</p>
            <p align="left" class="zzAddress" style="text-align:left;">
              <a id="boilerplate-address" name="boilerplate-address"/>ISO copyright office

              <br/>
              Ch. de Blandonnet 8 ?~@? CP 401

              <br/>
              CH-1214 Vernier, Geneva, Switzerland

              <br/>
              Phone: +41 22 749 01 11

              <br/>
              Email: copyright@iso.org

              <br/>
              www.iso.org#{' '}</p>
          </div>
        </div>
      OUTPUT
    expect(word).to include '<p class="zzWarning">This document is not '\
                            "an ISO International Standard"
  end

  it "populates Word ToC" do
    IsoDoc::WordConvert.new(WORD_HTML_CSS_WORDINTRO.dup)
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
            <clause id="A" inline-header="false" obligation="normative">
              <title>Clause 4</title>
              <clause id="N" inline-header="false" obligation="normative">
                <title>Introduction
                  <bookmark id="Q"/>
                  to this
                  <fn reference="1">
                    <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
                </title>
              </clause>
              <clause id="O" inline-header="false" obligation="normative">
                <title>Clause 4.2</title>
                <p>A
                  <fn reference="1">
                    <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
                </p>
                <clause id="P" inline-header="false" obligation="normative">
                  <title>Clause 4.2.1</title>
                </clause>
              </clause>
            </clause>
          </sections>
        </iso-standard>
      INPUT
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection2">/m,
           '<div class="WordSection2">')
      .sub(%r{<p class="MsoNormal">\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*$}m, "")

    expect(xmlpp(word.gsub(/_Toc\d\d+/, "_Toc")
      .gsub(/<o:p>&#xA0;<\/o:p>/, "")))
      .to be_equivalent_to xmlpp(<<~'OUTPUT')
        <div class="WordSection2">An empty word intro page.
          <p class="MsoToc1">
            <span lang="EN-GB" xml:lang="EN-GB">
              <span style="mso-element:field-begin"/>
              <span style="mso-spacerun:yes"> </span>
              TOC
                 \o &quot;1-2&quot; \h \z \u
              <span style="mso-element:field-separator"/></span>
            <span class="MsoHyperlink">
              <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
                <a href="#_Toc">Clause 4
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-tab-count:1 dotted">. </span></span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-begin"/>
                  </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">PAGEREF _Toc \h </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-separator"/>
                  </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">1</span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB"/>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-end"/>
                  </span>
                </a>
              </span>
            </span>
          </p>
          <p class="MsoToc2">
            <span class="MsoHyperlink">
              <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
                <a href="#_Toc">Introduction to this
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-tab-count:1 dotted">. </span></span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-begin"/>
                  </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">PAGEREF _Toc \h </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-separator"/>
                  </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">1</span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB"/>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-end"/>
                  </span>
                </a>
              </span>
            </span>
          </p>
          <p class="MsoToc2">
            <span class="MsoHyperlink">
              <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
                <a href="#_Toc">Clause 4.2
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-tab-count:1 dotted">. </span></span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-begin"/>
                  </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">PAGEREF _Toc \h </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-separator"/>
                  </span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">1</span>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB"/>
                  <span class="MsoTocTextSpan" lang="EN-GB" xml:lang="EN-GB">
                    <span style="mso-element:field-end"/>
                  </span>
                </a>
              </span>
            </span>
          </p>
          <p class="MsoToc1">
            <span lang="EN-GB" xml:lang="EN-GB">
              <span style="mso-element:field-end"/>
            </span>
            <span lang="EN-GB" xml:lang="EN-GB">
            </span>
          </p>
          <p class="MsoNormal"> </p>
        </div>
      OUTPUT
  end
end
