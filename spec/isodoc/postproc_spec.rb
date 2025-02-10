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
    FileUtils.rm_rf "test.html"
    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS.merge(filename: "test"))
      .convert("test", <<~INPUT, false)
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
    expect(html).to include("<title>Cereals and pulses — Specifications " \
                            "and test methods — Rice</title>")
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
  end

  it "generates HTML output docs with null configuration" do
    FileUtils.rm_rf "test.html"
    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~INPUT, false)
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
    expect(html).to(include "<title>Cereals and pulses — Specifications " \
                            "and test methods — Rice</title>")
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
  end

  it "generates Word output docs with null configuration" do
    FileUtils.rm_rf "test.doc"
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~INPUT, false)
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
    FileUtils.rm_rf "test.html"
    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS_SUBDIR.dup)
      .convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.html")).to be true
    html = File.read("spec/assets/iso.html", encoding: "UTF-8")
    expect(html).to match(/<style>/)
    expect(html).to match(%r{https://use\.fontawesome\.com})
    expect(html).to match(%r{libs/jquery})
  end

  it "generates Word output docs with null configuration from file" do
    FileUtils.rm_rf "test.doc"
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS_SUBDIR.dup)
      .convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.doc")).to be true
    word = File.read("spec/assets/iso.doc", encoding: "UTF-8")
    expect(word).to match(/<w:WordDocument>/)
    expect(word).to match(/<style>/)
  end

  it "generates Pdf output docs with null configuration from file" do
    FileUtils.rm_rf "spec/assets/iso.pdf"
    mock_pdf
    IsoDoc::Iso::PdfConvert
      .new(WORD_HTML_CSS.dup)
      .convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.pdf")).to be true
  end

  it "populates Word template with terms reference labels" do
    FileUtils.rm_rf "test.doc"
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
            <terms id="_terms_and_definitions" obligation="normative" displayorder="1">
              <fmt-title>1
                <tab/>
                Terms and Definitions</fmt-title>
              <term id="paddy1">
                <fmt-name>1.1</fmt-name>
                <fmt-preferred><p>paddy</p></fmt-preferred>
                <fmt-definition>
                  <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
                </fmt-definition>
                <fmt-termsource status="modified">[SOURCE:
                  <fmt-origin bibitemid="ISO7301" citeas="ISO 7301:2011" type="inline"><locality type="clause">
                      <referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</fmt-origin>, modified &#x2013;
                    The term &quot;cargo rice&quot; is shown as deprecated, and Note 1 to entry is not included here]
                </fmt-termsource>
              </term>
            </terms>
          </sections>
        </iso-standard>
      INPUT

    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">')
      .sub(%r{<br[^>]*>\s*<div class="colophon".*$}m, "")

    expect(Xml::C14n.format(word)).to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
      <div class='WordSection3'>
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
    FileUtils.rm_rf "test.doc"
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS_HEADER_HTML.dup)
      .convert("test", <<~INPUT, false)
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
    FileUtils.rm_rf "test.html"
    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
            <clause id="A" inline-header="false" obligation="normative" displayorder="1">
              <fmt-title>1
                <tab/>
                Clause 4</fmt-title>
              <clause id="N" inline-header="false" obligation="normative">
                <fmt-title>1.1
                  <tab/>
                  Introduction
                  <bookmark id="Q"/>
                  to this
                  <fn reference="1">
                    <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
                </fmt-title>
              </clause>
              <clause id="O" inline-header="false" obligation="normative">
                <fmt-title>1.2
                  <tab/>
                  Clause 4.2</fmt-title>
                <p>A
                  <fn reference="1">
                    <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
                </p>
              </clause>
            </clause>
            <clause id="P" displayorder="2"><fmt-title>2<tab/>Clause 5</fmt-title>
            <clause id="P1"><fmt-title>2.1<tab/>Clause 5.1</fmt-title>
            <p>X</p>
            </clause>
            </clause>
            <clause id="Q" displayorder="3"><fmt-title>3<tab/>Clause 6</fmt-title></clause>
          </sections>
        </iso-standard>
      INPUT

    html = Nokogiri::XML(File.read("test.html", encoding: "UTF-8"))
      .at("//div[@id = 'toc']").to_xml

    expect(Xml::C14n.format(strip_guid(html)))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
             <div id="toc">
           <ul>
             <li class="h1">
               <div class="collapse-group">
                 <a href="#_">1
                  
                 Clause 4</a>
                 <div class="collapse-button"/>
               </div>
               <ul class="content collapse">
                 <li class="h2">
                   <a href="#_">      1.1
                    
                   Introduction

                   to this

                 </a>
                 </li>
                 <li class="h2">
                   <a href="#_">      1.2
                    
                   Clause 4.2</a>
                 </li>
               </ul>
             </li>
                        <li class="h1">
              <div class="collapse-group">
                <a href="#_">2  Clause 5</a>
                <div class="collapse-button"/>
              </div>
              <ul class="content collapse">
                <li class="h2">
                  <a href="#_">      2.1  Clause 5.1</a>
                </li>
              </ul>
            </li>
            <li class="h1">
              <a href="#_">      3  Clause 6</a>
            </li>
          </ul>
        </div>
      OUTPUT
  end

  it "populates Word ToC" do
    FileUtils.rm_rf "test.doc"
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS_WORDINTRO.dup)
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <metanorma-extension>
            <presentation-metadata>
              <name>TOC Heading Levels</name>
              <value>3</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>HTML TOC Heading Levels</name>
              <value>2</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>DOC TOC Heading Levels</name>
              <value>3</value>
            </presentation-metadata>
          </metanorma-extension>
                  <sections>
                    <clause id="A" inline-header="false" obligation="normative" displayorder="1">
                      <fmt-title>1
                        <tab/>
                        Clause 4</fmt-title>
                      <clause id="N" inline-header="false" obligation="normative">
                        <fmt-title>1.1
                          <tab/>
                          Introduction
                          <bookmark id="Q"/>
                          to this
                          <fn reference="1">
                            <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
                        </fmt-title>
                      </clause>
                      <clause id="O" inline-header="false" obligation="normative">
                        <fmt-title>1.2
                          <tab/>
                          Clause 4.2</fmt-title>
                        <p>A
                          <fn reference="1">
                            <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
                        </p>
                      </clause>
                    </clause>
                  </sections>
                  <annex id="AA" displayorder="2"><fmt-title>Annex A<tab/>Annex First</fmt-title></annex>
                </iso-standard>
      INPUT

    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*An empty word intro page\./m, "")
      .sub(%r{</div>.*$}m, "</div>")
      .gsub(/<o:p>&#xA0;<\/o:p>/, "")

    expect(Xml::C14n.format("<div>#{word.gsub(/_Toc\d\d+/, '_Toc')}"))
      .to be_equivalent_to Xml::C14n.format(<<~'OUTPUT')
           <div>
         <p class="MsoToc1">
           <span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"/><span style="mso-spacerun:yes"> </span>TOC
         \o "1-3" \h \z \t "Heading
         1;1;ANNEX;1;Biblio Title;1;Foreword Title;1;Intro Title;1" <span style="mso-element:field-separator"/></span>
           <span class="MsoHyperlink">
             <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
               <a href="#_Toc">1

                       Clause 4<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a>
             </span>
           </span>
         </p>
         <p class="MsoToc2">
           <span class="MsoHyperlink">
             <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
               <a href="#_Toc">1.1

                         Introduction

                         to this

                       <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a>
             </span>
           </span>
         </p>
         <p class="MsoToc2">
           <span class="MsoHyperlink">
             <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
               <a href="#_Toc">1.2

                         Clause 4.2<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a>
             </span>
           </span>
         </p>
         <p class="MsoToc1">
           <span class="MsoHyperlink">
             <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
               <a href="#_Toc">Annex A Annex First<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a>
             </span>
           </span>
         </p>
         <p class="MsoToc1">
           <span lang="EN-GB" xml:lang="EN-GB">
             <span style="mso-element:field-end"/>
           </span>
           <span lang="EN-GB" xml:lang="EN-GB">
             <o:p class="MsoNormal"> </o:p>
           </span>
         </p>
         <p class="MsoNormal"> </p>
       </div>
      OUTPUT
  end

  it "reorders footnote numbers" do
    FileUtils.rm_rf "test.html"
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <clause id="A" inline-header="false" obligation="normative" displayorder="1">
            <fmt-title>1
              <tab/>
              Clause 4</fmt-title>
            <fn reference="3">
              <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">This is a footnote.</p>
            </fn>
            <clause id="N" inline-header="false" obligation="normative">
              <fmt-title>1.1 <tab/>
                Introduction to this
                <fn reference="2">
                  <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
              </fmt-title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <fmt-title>1.2 <tab/>
                Clause 4.2</fmt-title>
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

    expect(Xml::C14n.format(strip_guid(html))).to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
      <main xmlns:epub="epub" class="main-section">
          <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
          <div id="A">
            <h1 id="_">
              <a class="anchor" href="#A"/>
              <a class="header" href="#A">1
                 
                Clause 4</a>
            </h1>
            <a class="FootnoteRef" href="#fn:3" id="fnref:1">
              <sup>1)</sup>
            </a>
            <div id="N">
              <h2 id="_">
                <a class="anchor" href="#N"/>
                <a class="header" href="#N">1.1  
                  Introduction to this
                  <a class="FootnoteRef" href="#fn:2" id="fnref:2"><sup>2)</sup></a></a>
              </h2>
            </div>
            <div id="O">
              <h2 id="_">
                <a class="anchor" href="#O"/>
                <a class="header" href="#O">1.2  
                  Clause 4.2</a>
              </h2>
              <p>A
                  <a class="FootnoteRef" href="#fn:2"><sup>2)</sup></a></p>
            </div>
          </div>
          <aside id="fn:3" class="footnote">
            <p id="_"><a class="FootnoteRef" href="#fn:3"><sup>1)</sup></a>This is a footnote.</p>
            <a href="#fnref:1">↩</a>
          </aside>
          <aside id="fn:2" class="footnote">
            <p id="_"><a class="FootnoteRef" href="#fn:2"><sup>2)</sup></a>Formerly denoted as 15 % (m/m).</p>
            <a href="#fnref:2">↩</a>
          </aside>
        </main>
    OUTPUT

    FileUtils.rm_rf "test.doc"
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS_WORDINTRO.dup)
      .convert("test", input, false)

    html = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<div class="WordSection3"/m,
           '<body xmlns:epub="epub"><div class="WordSection3"')
      .sub(%r{</body>.*$}m, "</body>")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref")

    expect(Xml::C14n.format(html)).to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
        <body xmlns:epub="epub">
        <div class="WordSection3">
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
    FileUtils.rm_rf "test.html"
    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
            <terms id="_terms_and_definitions" obligation="normative" displayorder="1">
              <fmt-title>Terms and Definitions</fmt-title>
              <term id="paddy1">
                <fmt-name>1.1</fmt-name>
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
                <fmt-name>1.2</fmt-name>
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
    html = strip_guid(File.read("test.html", encoding: "UTF-8"))
    expect(html).to match(%r{<h2 class="TermNum" id="_"><a class="anchor" href="#paddy1"></a><a class="header" href="#paddy1">1\.1</a>})
    expect(html).to match(%r{<h2 class="TermNum" id="_"><a class="anchor" href="#paddy"></a><a class="header" href="#paddy">1\.2</a>})
  end

  it "inserts default paragraph between two tables for Word" do
    FileUtils.rm_rf "test.doc"
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <annex id="P" inline-header="false" obligation="normative" displayorder="1">
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
    expect(Xml::C14n.format(word)).to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
      <div class="WordSection3">
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

  it "processes editorial notes (Word)" do
    FileUtils.rm_rf "test.doc"
    IsoDoc::Iso::WordConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", <<~INPUT, false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
            <annex id="P" inline-header="false" obligation="normative" displayorder="1">
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
    output = <<~OUTPUT
      <div class='WordSection3'>
         <p class='MsoNormal'>
           <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
         </p>
         <div class='Section3'>
           <a name='P' id='P'/>
           <div class='zzHelp'>
             <a name='_' id='_'/>
             <p class='zzHelp'> Only use paddy or parboiled rice for the determination of husked rice yield. </p>
             <p class='zzHelp'>
               <a name='_' id='_'/>
               Para 2.
             </p>
           </div>
         </div>
       </div>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(word))).to be_equivalent_to Xml::C14n.format(output)
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
            <clause id="boilerplate-copyright-default">
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
            <clause id="added">
            <p>Is there anybody out there?</p>
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
            <clause inline-header="true" id="boilerplate-copyright-default">
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
           <clause id="added" inline-header="true">
            <p>Is there anybody out there?</p>
         </clause>
          </copyright-statement>
          <license-statement>
            <clause>
              <title id="_">Warning for Stuff</title>
           <fmt-title depth="1">
                 <semx element="title" source="_">Warning for Stuff</semx>
           </fmt-title>
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

    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(WORD_HTML_CSS.dup
      .merge(presxml_options))
      .convert("test", input, true)

    expect(Xml::C14n.format(strip_guid(pres_output)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(presxml)

    FileUtils.rm_rf "test.html"
    IsoDoc::Iso::HtmlConvert
      .new(WORD_HTML_CSS.dup)
      .convert("test", pres_output, false)

    word = File.read("test.html", encoding: "UTF-8")
    expect(strip_guid(word))
      .to include('<h1 class="IntroTitle">Warning for Stuff</h1>')
    expect(word).to include("I am the Walrus.")

    FileUtils.rm_rf "test.doc"
    IsoDoc::Iso::WordConvert.new(WORD_HTML_CSS.dup)
      .convert("test", pres_output, false)
    word = File.read("test.doc", encoding: "UTF-8")
    contents = word.sub(%r{^.*<body}m, "<body").sub(%r{</body>.*$}m, "</body>")
    contents = Nokogiri::XML(contents)
      .at("//div[a/@id = 'boilerplate-copyright-destination']")
    expect(Xml::C14n.format(contents.to_xml))
      .to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
           <div>
          <a name="boilerplate-copyright-destination" id="boilerplate-copyright-destination"/>
          <div style="mso-element:para-border-div;border:solid windowtext 1.0pt; border-bottom-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt: solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:1.0pt 4.0pt 0cm 4.0pt; margin-left:5.1pt;margin-right:5.1pt">
             <div>
                <a name="boilerplate-copyright-default-destination" id="boilerplate-copyright-default-destination"/>
                <div>
                   <a name="boilerplate-copyright-default" id="boilerplate-copyright-default"/>
                   <p class="zzCopyright">
                      <a name="boilerplate-year" id="boilerplate-year"/>
                      © ISO 2019, Published in Switzerland
                   </p>
                   <p class="zzCopyright1">
                      <a name="boilerplate-message" id="boilerplate-message"/>
                      I am the Walrus.
                   </p>
                   <p class="zzCopyright">
                      <a name="boilerplate-name" id="boilerplate-name"/>
                      ISO copyright office
                   </p>
                   <p style="text-align:left;" align="left" class="zzAddress">
                      <a name="boilerplate-address" id="boilerplate-address"/>
                      ISO copyright office
                      <br/>
                      Ch. de Blandonnet 8 ?~@? CP 401
                      <br/>
                      CH-1214 Vernier, Geneva, Switzerland
                      <br/>
                      Phone: +41 22 749 01 11
                      <br/>
                      Email: copyright@iso.org
                      <br/>
                      www.iso.org
                   </p>
                </div>
             </div>
          </div>
          <div>
             <a name="boilerplate-copyright-append-destination" id="boilerplate-copyright-append-destination"/>
             <div class="boilerplate-copyright">
                <div>
                   <a name="added" id="added"/>
                   <p class="zzCopyright">Is there anybody out there?</p>
                </div>
             </div>
          </div>
       </div>
      OUTPUT
    expect(word).to include('<p class="zzWarning">This document is not ' \
                            "an ISO International Standard")
  end

  it "populates Word ToC" do
    FileUtils.rm_rf "test.doc"
    IsoDoc::WordConvert.new(WORD_HTML_CSS_WORDINTRO.dup)
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
            <clause id="A" inline-header="false" obligation="normative" displayorder="1">
              <fmt-title>Clause 4</fmt-title>
              <clause id="N" inline-header="false" obligation="normative">
                <fmt-title>Introduction
                  <bookmark id="Q"/>
                  to this
                  <fn reference="1">
                    <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
                </fmt-title>
              </clause>
              <clause id="O" inline-header="false" obligation="normative">
                <fmt-title>Clause 4.2</fmt-title>
                <p>A
                  <fn reference="1">
                    <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p></fn>
                </p>
                <clause id="P" inline-header="false" obligation="normative">
                  <fmt-title>Clause 4.2.1</fmt-title>
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

    expect(Xml::C14n.format(word.gsub(/_Toc\d\d+/, "_Toc")
      .gsub(/<o:p>&#xA0;<\/o:p>/, "")))
      .to be_equivalent_to Xml::C14n.format(<<~'OUTPUT')
        <div class="WordSection2">
         An empty word intro page.

         <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"/><span style="mso-spacerun:yes"> </span>TOC \o "1-2" \h \z \u <span style="mso-element:field-separator"/></span><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Clause 4<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p><p class="MsoToc2"><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Introduction

                   to this

                 <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p><p class="MsoToc2"><span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB"><a href="#_Toc">Clause 4.2<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-tab-count:1 dotted">. </span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-begin"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"/></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"/><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"/></span></a></span></span></p><p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-end"/></span><span lang="EN-GB" xml:lang="EN-GB"><o:p class="MsoNormal"> </o:p></span></p><p class="MsoNormal"> </p></div>
      OUTPUT
  end
end
