require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "generates file based on string input" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::Iso::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", filename: "test"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
        <title>
            <title type="title-intro" language="en" format="text/plain">Cereals and pulses</title>
    <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
    <title type="title-part" language="en" format="text/plain">Rice</title>
  </title>
  </bibdata>
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    expect(html).to match(%r{<title>Cereals and pulses\&#xA0;\&#x2014; Specifications and test methods\&#xA0;\&#x2014; Rice</title>})
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
  end

  it "generates HTML output docs with null configuration" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::Iso::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
        <title>
            <title type="title-intro" language="en" format="text/plain">Cereals and pulses</title>
    <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
    <title type="title-part" language="en" format="text/plain">Rice</title>
  </title>
  </bibdata>
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    expect(html).to match(%r{<title>Cereals and pulses\&#xA0;\&#x2014; Specifications and test methods\&#xA0;\&#x2014; Rice</title>})
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
  end

  it "generates Word output docs with null configuration" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::Iso::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    word = File.read("test.doc", encoding: "UTF-8")
    expect(word).to match(/<style>/)
  end

  it "generates HTML output docs with null configuration from file" do
    FileUtils.rm_f "spec/assets/iso.doc"
    FileUtils.rm_f "spec/assets/iso.html"
    IsoDoc::Iso::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.html")).to be true
    html = File.read("spec/assets/iso.html", encoding: "UTF-8")
    expect(html).to match(/<style>/)
    expect(html).to match(%r{https://use.fontawesome.com})
    expect(html).to match(%r{libs/jquery})
  end

  it "generates Word output docs with null configuration from file" do
    FileUtils.rm_f "spec/assets/iso.doc"
    IsoDoc::Iso::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.doc")).to be true
    word = File.read("spec/assets/iso.doc", encoding: "UTF-8")
    expect(word).to match(/<w:WordDocument>/)
    expect(word).to match(/<style>/)
  end

    it "generates Pdf output docs with null configuration from file" do
    FileUtils.rm_f "spec/assets/iso.pdf"
    IsoDoc::Iso::PdfConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.pdf")).to be true
  end

  it "converts annex subheadings to h2Annex class for Word" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::Iso::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         </clause>
                <appendix id="Q2" inline-header="false" obligation="normative">
         <title>An Appendix</title>
       </appendix>
    </annex>
    </iso-standard>
    INPUT
    word = File.read("test.doc", encoding: "UTF-8").sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">').
      sub(%r{<br[^>]*>\s*<div class="colophon".*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
           <div class="WordSection3">
               <p class="zzSTDTitle1"></p>
               <p class="MsoNormal"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
               <div class="Section3"><a name="P" id="P"></a>
                 <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                 <div><a name="Q" id="Q"></a>
            <p class="h2Annex">A.1<span style="mso-tab-count:1">&#xA0; </span>Annex A.1</p>
       </div>
              <div><a name="Q2" id="Q2"></a>
                <p class="h2Annex">Appendix 1<span style="mso-tab-count:1">&#xA0; </span>An Appendix</p>
                </div>
               </div>
             </div>
    OUTPUT
  end

  it "populates Word template with terms reference labels" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::Iso::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections>
    <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>

<term id="paddy1"><preferred>paddy</preferred>
<definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
<termsource status="modified">
  <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
    <modification>
    <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
  </modification>
</termsource></term>

</terms>
</sections>
</iso-standard>

    INPUT
    word = File.read("test.doc", encoding: "UTF-8").sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">').
      sub(%r{<br[^>]*>\s*<div class="colophon".*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
           <div class="WordSection3">
               <p class="zzSTDTitle1"></p>
               <div><a name="_terms_and_definitions" id="_terms_and_definitions"></a><h1>1<span style="mso-tab-count:1">&#xA0; </span>Terms and definitions</h1>
       <p class="TermNum"><a name="paddy1" id="paddy1"></a>1.1</p><p class="Terms" style="text-align:left;">paddy</p>
       <p class="MsoNormal"><a name="_eb29b35e-123e-4d1c-b50b-2714d41e747f" id="_eb29b35e-123e-4d1c-b50b-2714d41e747f"></a>rice retaining its husk after threshing</p>
       <p class="MsoNormal">[SOURCE: <a href="#ISO7301">ISO 7301:2011, 3.1</a>, modified &#x2014; The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]</p></div>
             </div>
    OUTPUT
  end

  it "populates Word header" do
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", header: "spec/assets/header.html"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
               <bibdata type="article">
                        <docidentifier>
           <project-number part="1">1000</project-number>
         </docidentifier>
        </bibdata>
</iso-standard>

    INPUT
    word = File.read("test.doc", encoding: "UTF-8").sub(%r{^.*Content-Location: file:///C:/Doc/test_files/header.html}m, "Content-Location: file:///C:/Doc/test_files/header.html").
      sub(/------=_NextPart.*$/m, "")
    #expect(word).to include(%{Content-Location: file:///C:/Doc/test_files/header.html\nContent-Transfer-Encoding: base64\nContent-Type: text/html charset="utf-8" })
    expect(word).to include(%{Content-Location: file:///C:/Doc/test_files/header.html})
  end

  it "populates Word ToC" do
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", wordintropage: "spec/assets/wordintro.html"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
               <clause id="A" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">

         <title>Introduction<bookmark id="Q"/> to this<fn reference="1">
  <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
</fn></title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
         <p>A<fn reference="1">
  <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
</fn></p>
       </clause></clause>
        </sections>
        </iso-standard>

    INPUT
    word = File.read("test.doc", encoding: "UTF-8").sub(/^.*An empty word intro page\./m, '').
      sub(%r{</div>.*$}m, "</div>")

    expect(xmlpp("<div>" + word.gsub(/_Toc\d\d+/, "_Toc") )).to be_equivalent_to xmlpp(<<~'OUTPUT')
           <div>
       <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"></span><span style="mso-spacerun:yes">&#xA0;</span>TOC
         \o "1-2" \h \z \u <span style="mso-element:field-separator"></span></span>
       <span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
       <a href="#_Toc">1 Clause 4<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
       <span style="mso-tab-count:1 dotted">. </span>
       </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
       <span style="mso-element:field-begin"></span></span>
       <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"></span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"></span></span></a></span></span></p>

       <p class="MsoToc2">
         <span class="MsoHyperlink">
           <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
       <a href="#_Toc">1.1 Introduction to this<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
       <span style="mso-tab-count:1 dotted">. </span>
       </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
       <span style="mso-element:field-begin"></span></span>
       <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"></span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"></span></span></a></span>
         </span>
       </p>

       <p class="MsoToc2">
         <span class="MsoHyperlink">
           <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
       <a href="#_Toc">1.2 Clause 4.2<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
       <span style="mso-tab-count:1 dotted">. </span>
       </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
       <span style="mso-element:field-begin"></span></span>
       <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"></span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"></span></span></a></span>
         </span>
       </p>

       <p class="MsoToc1">
         <span lang="EN-GB" xml:lang="EN-GB">
           <span style="mso-element:field-end"></span>
         </span>
         <span lang="EN-GB" xml:lang="EN-GB">
           <p class="MsoNormal">&#xA0;</p>
         </span>
       </p>


               <p class="MsoNormal">&#xA0;</p>
             </div>
    OUTPUT
  end

  it "reorders footnote numbers in HTML" do
    FileUtils.rm_f "test.html"
    IsoDoc::Iso::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", wordintropage: "spec/assets/wordintro.html"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
               <clause id="A" inline-header="false" obligation="normative"><title>Clause 4</title><fn reference="3">
  <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">This is a footnote.</p>
</fn><clause id="N" inline-header="false" obligation="normative">

         <title>Introduction to this<fn reference="2">
  <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
</fn></title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
         <p>A<fn reference="1">
  <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6">Formerly denoted as 15 % (m/m).</p>
</fn></p>
       </clause></clause>
        </sections>
        </iso-standard>
    INPUT
    html = File.read("test.html", encoding: "UTF-8").sub(/^.*<main class="main-section">/m, '<main xmlns:epub="epub" class="main-section">').
      sub(%r{</main>.*$}m, "</main>")
    expect(xmlpp(html)).to be_equivalent_to xmlpp(<<~"OUTPUT")
           <main xmlns:epub="epub" class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <p class="zzSTDTitle1"></p>
             <div id="A">
               <h1>1&#xA0; Clause 4</h1>
               <a rel="footnote" href="#fn:3" epub:type="footnote" id="fnref:1">
                 <sup>1</sup>
               </a>
               <div id="N">

                <h2>1.1&#xA0; Introduction to this<a rel="footnote" href="#fn:2" epub:type="footnote" id="fnref:2"><sup>2</sup></a></h2>
              </div>
               <div id="O">
                <h2>1.2&#xA0; Clause 4.2</h2>
                <p>A<a rel="footnote" href="#fn:2" epub:type="footnote"><sup>2</sup></a></p>
              </div>
             </div>
             <aside id="fn:3" class="footnote">
         <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6"><a rel="footnote" href="#fn:3" epub:type="footnote">
                 <sup>1</sup>
               </a>This is a footnote.</p>
       <a href="#fnref:1">&#x21A9;</a></aside>
             <aside id="fn:2" class="footnote">
         <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6"><a rel="footnote" href="#fn:2" epub:type="footnote"><sup>2</sup></a>Formerly denoted as 15 % (m/m).</p>
       <a href="#fnref:2">&#x21A9;</a></aside>

           </main>
    OUTPUT
  end

  it "moves images in HTML" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_rf "_images"
    FileUtils.rm_rf "test_htmlimages"
    IsoDoc::Iso::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface><foreword>
         <figure id="_">
         <name>Split-it-right sample divider</name>
                  <image src="spec/assets/rice_image1.png" id="_" mimetype="image/png"/>
                  <image src="spec/assets/rice_image1.png" id="_" width="20000" height="300000" mimetype="image/png"/>
                  <image src="spec/assets/rice_image1.png" id="_" width="99" height="auto" mimetype="image/png"/>
       </figure>
       </foreword></preface>
        </iso-standard>
    INPUT
    html = File.read("test.html", encoding: "UTF-8").sub(/^.*<main class="main-section">/m, '<main class="main-section">').
      sub(%r{</main>.*$}m, "</main>")
    expect(`ls test_htmlimages`).to match(/\.png$/)
    expect(xmlpp(html.gsub(/\/[0-9a-f-]+\.png/, "/_.png"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
           <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <br />
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <div id="_" class="figure">
               <img src="test_htmlimages/_.png" height="776" width="922" />
<img src="test_htmlimages/_.png" height="800" width="53" />
<img src="test_htmlimages/_.png" height="83" width="99" />
       <p class="FigureTitle" style="text-align:center;">Figure 1&#xA0;&#x2014; Split-it-right sample divider</p></div>
             </div>
             <p class="zzSTDTitle1"></p>
           </main>
    OUTPUT

  end

  it "processes IsoXML terms for HTML" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections>
    <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>

<term id="paddy1"><preferred>paddy</preferred>
<domain>rice</domain>
<definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
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
  <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
    <modification>
    <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
  </modification>
</termsource></term>

<term id="paddy"><preferred>paddy</preferred><admitted>paddy rice</admitted>
<admitted>rough rice</admitted>
<deprecates>cargo rice</deprecates>
<definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
<termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
  <ul>
  <li>A</li>
  </ul>
</termexample>
<termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
  <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote>
<termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
<ul><li>A</li></ul>
  <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote>
<termsource status="identical">
  <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
</termsource></term>
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
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::Iso::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
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
    word = File.read("test.doc", encoding: "UTF-8").sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">').
      sub(%r{<br[^>]*>\s*<div class="colophon".*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
         <div class="WordSection3">
             <p class="zzSTDTitle1"></p>
             <p class="MsoNormal">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div class="Section3"><a name="P" id="P"></a>
               <div class="example"><a name="_63112cbc-cde0-435f-9553-e0b8c4f5851c" id="_63112cbc-cde0-435f-9553-e0b8c4f5851c"></a>
                 <p class="example"><span class="example_label">EXAMPLE  1</span><span style="mso-tab-count:1">&#xA0; </span>'1M', '01M', and '0001M' all describe the calendar month January.</p>
               </div>
               <div class="example"><a name="_63112cbc-cde0-435f-9553-e0b8c4f5851d" id="_63112cbc-cde0-435f-9553-e0b8c4f5851d"></a>
                 <p class="example"><span class="example_label">EXAMPLE  2</span><span style="mso-tab-count:1">&#xA0; </span>'2M', '02M', and '0002M' all describe the calendar month February.</p>
               </div>
             </div>
           </div>
    OUTPUT
  end

    it "processes figure keys (Word)" do
          FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::Iso::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
        <annex id="P" inline-header="false" obligation="normative">
    <figure id="samplecode">
  <p>Hello</p>
  <p>Key</p>
  <dl>
  <dt><p>A</p></dt>
  <dd><p>B</p></dd>
  </dl>
</figure>
    </annex>
    </iso-standard>
    INPUT
    word = File.read("test.doc", encoding: "UTF-8").sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">').
      sub(%r{<br[^>]*>\s*<div class="colophon".*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
       <div class="WordSection3">
             <p class="zzSTDTitle1"></p>
             <p class="MsoNormal">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div class="Section3"><a name="P" id="P"></a>
               <div class="figure"><a name="samplecode" id="samplecode"></a>
         <p class="MsoNormal">Hello</p>
         <p class="MsoNormal">Key</p>
         <p class="MsoNormal"><b>Key</b></p><div class="figdl" style="page-break-after:avoid;"><table class="figdl"><tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;" class="MsoNormal"><p class="MsoNormal">A</p></p></td><td valign="top"><p class="MsoNormal">B</p></td></tr></table></div>
         <p class="FigureTitle" style="text-align:center;">Figure A.1</p></div>
             </div>
           </div>

    OUTPUT
  end

      it "processes boilerplate" do
     FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::Iso::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
        <status><stage>30</stage></status>
        </bibdata>
    <boilerplate>
  <copyright-statement>
    <clause>
    <p id="boilerplate-year">
    © ISO 2019, Published in Switzerland
  </p>

  <p id="boilerplate-message">
I am the Walrus.
  </p>

    <p id="boilerplate-name">ISO copyright office</p>
  <p id="boilerplate-address" align="left">
    ISO copyright office<br/>
    Ch. de Blandonnet 8 ?~@? CP 401<br/>
    CH-1214 Vernier, Geneva, Switzerland<br/>
    Tel. + 41 22 749 01 11<br/>
    Fax + 41 22 749 09 47<br/>
    copyright@iso.org<br/>
    www.iso.org
  </p>
</clause>
  </copyright-statement>


  <license-statement>
    <clause>
<title>Warning for Stuff</title>

<p>This
document is not an ISO International Standard. It is distributed for review and
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
    word = File.read("test.html", encoding: "UTF-8")
    expect(xmlpp(word)).to include "<h1 class='IntroTitle'>Warning for Stuff</h1>"
    expect(xmlpp(word)).to include "I am the Walrus."
end

  it "processes boilerplate (Word)" do
     FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::Iso::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
        <status><stage>30</stage></status>
        </bibdata>
    <boilerplate>
  <copyright-statement>
    <clause>
    <p id="boilerplate-year">Published in Elbonia</p>

  <p id="boilerplate-message">No soup for you</p>

  <p id="boilerplate-place">Dilbert Associates</p>
  <p id="boilerplate-address" align="left">Elbonia 5000</p>
</clause>
  </copyright-statement>


  <license-statement>
    <clause>
<title>Warning for Stuff</title>

<p>I am the Walrus</p>
</clause>
  </license-statement>

</boilerplate>
</iso-standard>
    INPUT
    word = File.read("test.doc", encoding: "UTF-8")
    expect(xmlpp(word.sub(%r{^.*<div class="boilerplate-copyright">}m, '<div class="boilerplate-copyright">').sub(%r{</div>.*$}m, '</div></div>'))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <div class='boilerplate-copyright'>
  <div>
    <p class='zzCopyrightHdr'/>
    <p class='zzCopyright'>
      <a name='boilerplate-year' id='boilerplate-year'/>
      Published in Elbonia
    </p>
    <p class='zzCopyright1'>
      <a name='boilerplate-message' id='boilerplate-message'/>
      No soup for you
    </p>
    <p class='zzCopyright1'>
      <a name='boilerplate-place' id='boilerplate-place'/>
      Dilbert Associates
    </p>
    <p align='left' style='text-align:left' class='zzAddress'>
      <a name='boilerplate-address' id='boilerplate-address'/>
      Elbonia 5000
    </p>
  </div>
</div>
           OUTPUT
    expect(word).to include '<p class="zzWarning">I am the Walrus</p>'
end

end
