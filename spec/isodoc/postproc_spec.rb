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
            <title-intro language="en" format="text/plain">Cereals and pulses</title-intro>
    <title-main language="en" format="text/plain">Specifications and test methods</title-main>
    <title-part language="en" format="text/plain">Rice</title-part>
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
    html = File.read("test.html")
    expect(html).to match(%r{<title>Cereals and pulses\&nbsp;\&mdash; Specifications and test methods\&nbsp;\&mdash; Rice</title>})
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/2\.7\.1/MathJax\.js})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
  end

  it "generates HTML output docs with null configuration" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::Iso::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
        <title>
            <title-intro language="en" format="text/plain">Cereals and pulses</title-intro>
    <title-main language="en" format="text/plain">Specifications and test methods</title-main>
    <title-part language="en" format="text/plain">Rice</title-part>
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
    html = File.read("test.html")
    expect(html).to match(%r{<title>Cereals and pulses\&nbsp;\&mdash; Specifications and test methods\&nbsp;\&mdash; Rice</title>})
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/2\.7\.1/MathJax\.js})
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
    word = File.read("test.doc")
    expect(word).to match(/<style>/)
  end

  it "generates HTML output docs with null configuration from file" do
    FileUtils.rm_f "spec/assets/iso.doc"
    FileUtils.rm_f "spec/assets/iso.html"
    IsoDoc::Iso::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.html")).to be true
    html = File.read("spec/assets/iso.html")
    expect(html).to match(/<style>/)
    expect(html).to match(%r{https://use.fontawesome.com})
    expect(html).to match(%r{libs/jquery})
  end

  it "generates Word output docs with null configuration from file" do
    FileUtils.rm_f "spec/assets/iso.doc"
    IsoDoc::Iso::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.doc")).to be true
    word = File.read("spec/assets/iso.doc")
    expect(word).to match(/<w:WordDocument>/)
    expect(word).to match(/<style>/)
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
    word = File.read("test.doc").sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">').
      sub(%r{<div style="mso-element:footnote-list"/>.*$}m, "")
    expect(word).to be_equivalent_to <<~"OUTPUT"
           <div class="WordSection3">
               <p class="zzSTDTitle1"></p>
               <p class="MsoNormal"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
               <div class="Section3"><a name="P" id="P"></a>
                 <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                 <div><a name="Q" id="Q"></a>
            <p class="h2Annex">A.1. Annex A.1</p>
       </div>
              <div><a name="Q2" id="Q2"></a>
                <p class="h2Annex">Appendix 1. An Appendix</p>
                </div>
               </div>
             </div>
             <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"></div>
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
    word = File.read("test.doc").sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">').
      sub(%r{<div style="mso-element:footnote-list"/>.*$}m, "")
    expect(word).to be_equivalent_to <<~"OUTPUT"
           <div class="WordSection3">
               <p class="zzSTDTitle1"></p>
               <div><a name="_terms_and_definitions" id="_terms_and_definitions"></a><h1>1.<span style="mso-tab-count:1">&#xA0; </span>Terms and definitions</h1><p class="MsoNormal">For the purposes of this document,
           the following terms and definitions apply.</p>
       <p class="MsoNormal">ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <p style="mso-list:l3 level1 lfo1;" class="MsoListParagraphCxSpFirst"> ISO Online browsing platform: available at
          <a href="http://www.iso.org/obp">http://www.iso.org/obp</a> </p>
        <p style="mso-list:l3 level1 lfo1;" class="MsoListParagraphCxSpLast"> IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> 
       <p class="TermNum"><a name="paddy1" id="paddy1"></a>1.1</p><p class="Terms" style="text-align:left;">paddy</p>
       <p class="MsoNormal"><a name="_eb29b35e-123e-4d1c-b50b-2714d41e747f" id="_eb29b35e-123e-4d1c-b50b-2714d41e747f"></a>rice retaining its husk after threshing</p>
       <p class="MsoNormal">[SOURCE: <a href="#ISO7301">ISO 7301:2011, 3.1</a>, modified &mdash; The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]</p></div>
             </div>
             <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"></div>
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
    word = File.read("test.doc").sub(%r{^.*Content-Location: file:///C:/Doc/test_files/header.html}m, "Content-Location: file:///C:/Doc/test_files/header.html").
      sub(/------=_NextPart.*$/m, "")
    #expect(word).to include(%{Content-Location: file:///C:/Doc/test_files/header.html\nContent-Transfer-Encoding: base64\nContent-Type: text/html charset="utf-8" })
    expect(word).to include(%{Content-Location: file:///C:/Doc/test_files/header.html})
  end

  it "populates Word ToC" do
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css", wordintropage: "spec/assets/wordintro.html"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
               <clause inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">

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
    word = File.read("test.doc").sub(/^.*An empty word intro page\./m, '').
      sub(%r{<br clear="all" class="section"/>\s*<div class="WordSection3">.*$}m, "")
    expect(word.gsub(/_Toc\d\d+/, "_Toc")).to be_equivalent_to <<~'OUTPUT'
       <p class="MsoToc1"><span lang="EN-GB" xml:lang="EN-GB"><span style="mso-element:field-begin"></span><span style="mso-spacerun:yes">&#xA0;</span>TOC
         \o "1-2" \h \z \u <span style="mso-element:field-separator"></span></span>
       <span class="MsoHyperlink"><span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
       <a href="#_Toc">1. Clause 4<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
       <span style="mso-tab-count:1 dotted">. </span>
       </span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
       <span style="mso-element:field-begin"></span></span>
       <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"> PAGEREF _Toc \h </span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-separator"></span></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">1</span>
         <span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"></span><span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB"><span style="mso-element:field-end"></span></span></a></span></span></p>

       <p class="MsoToc2">
         <span class="MsoHyperlink">
           <span lang="EN-GB" style="mso-no-proof:yes" xml:lang="EN-GB">
       <a href="#_Toc">1.1. Introduction to this<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
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
       <a href="#_Toc">1.2. Clause 4.2<span lang="EN-GB" class="MsoTocTextSpan" xml:lang="EN-GB">
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
               <clause inline-header="false" obligation="normative"><title>Clause 4</title><fn reference="3">
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
    html = File.read("test.html").sub(/^.*<main class="main-section">/m, '<main class="main-section">').
      sub(%r{</main>.*$}m, "</main>")
    expect(html).to be_equivalent_to <<~"OUTPUT"
           <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <p class="zzSTDTitle1"></p>
             <div>
               <h1>1.&#xA0; Clause 4</h1>
               <a rel="footnote" href="#fn:3" epub:type="footnote" id="fnref:1">
                 <sup>1</sup>
               </a>
               <div id="N">

                <h2>1.1. Introduction to this<a rel="footnote" href="#fn:2" epub:type="footnote" id="fnref:2"><sup>2</sup></a></h2>
              </div>
               <div id="O">
                <h2>1.2. Clause 4.2</h2>
                <p>A<a rel="footnote" href="#fn:2" epub:type="footnote"><sup>2</sup></a></p>
              </div>
             </div>
             <aside id="fn:3" class="footnote">
         <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6"><a rel="footnote" href="#fn:3" epub:type="footnote" id="fnref:1">
                 <sup>1</sup>
               </a>This is a footnote.</p>
       <a href="#fnref:1">&#x21A9;</a></aside>
             <aside id="fn:2" class="footnote">
         <p id="_ff27c067-2785-4551-96cf-0a73530ff1e6"><a rel="footnote" href="#fn:2" epub:type="footnote" id="fnref:2"><sup>2</sup></a>Formerly denoted as 15 % (m/m).</p>
       <a href="#fnref:2">&#x21A9;</a></aside>

           </main>
    OUTPUT
  end

  it "moves images in HTML" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_rf "_images"
    IsoDoc::Iso::HtmlConvert.new({wordstylesheet: "spec/assets/word.css", htmlstylesheet: "spec/assets/html.css"}).convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface><foreword>
         <figure id="_">
         <name>Split-it-right sample divider</name>
                  <image src="spec/assets/rice_image1.png" id="_" imagetype="PNG"/>
                  <image src="spec/assets/rice_image1.png" id="_" width="20000" height="300000" imagetype="PNG"/>
                  <image src="spec/assets/rice_image1.png" id="_" width="99" height="auto" imagetype="PNG"/>
       </figure>
       </foreword></preface>
        </iso-standard>
    INPUT
    html = File.read("test.html").sub(/^.*<main class="main-section">/m, '<main class="main-section">').
      sub(%r{</main>.*$}m, "</main>")
    expect(`ls test_images`).to match(/\.png$/)
    expect(html.gsub(/\/[0-9a-f-]+\.png/, "/_.png")).to be_equivalent_to <<~"OUTPUT"
           <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <br />
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <div id="_" class="figure">
               <img src="test_images/_.png" height="776" width="922" />
<img src="test_images/_.png" height="800" width="53" />
<img src="test_images/_.png" height="83" width="99" />
       <p class="FigureTitle" align="center">Figure 1&#xA0;&#x2014; Split-it-right sample divider</p></div>
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
    html = File.read("test.html")
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
    word = File.read("test.doc").sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">').
      sub(%r{<div style="mso-element:footnote-list"/>.*$}m, "")
    expect(word).to be_equivalent_to <<~"OUTPUT"
    <div class="WordSection3">
             <p class="zzSTDTitle1"></p>
             <p class="MsoNormal"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
             <div class="Section3"><a name="P" id="P"></a>
               <table class="example" cellspacing="0" cellpadding="0" style="mso-table-lspace:15.0cm;margin-left:423.0pt;mso-table-rspace:15.0cm;margin-right:423.0pt;mso-table-bspace:14.2pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-overlap:never;border-collapse:collapse;"><a name="_63112cbc-cde0-435f-9553-e0b8c4f5851c" id="_63112cbc-cde0-435f-9553-e0b8c4f5851c"></a>
                 <tr>
                   <td valign="top" class="example_label" style="width:82.8pt;padding:0 0 0 1em;margin-left:0pt">EXAMPLE  1</td>
                   <td valign="top" class="example">
         <p class="example"><a name="_158d4efa-b1c9-4aec-b325-756de8e4c968" id="_158d4efa-b1c9-4aec-b325-756de8e4c968"></a>'1M', '01M', and '0001M' all describe the calendar month January.</p>
       </td>
                 </tr>
               </table><p style="margin-top:0cm;margin-right:0cm;margin-bottom:0cm;margin-left:0.0pt;margin-bottom:.0001pt;line-height:1.0pt;mso-line-height-rule:exactly" class="MsoNormal"><span lang="EN-GB" style="display:none;mso-hide:all" xml:lang="EN-GB">&#xA0;</span></p>
               <table class="example" cellspacing="0" cellpadding="0" style="mso-table-lspace:15.0cm;margin-left:423.0pt;mso-table-rspace:15.0cm;margin-right:423.0pt;mso-table-bspace:14.2pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-overlap:never;border-collapse:collapse;"><a name="_63112cbc-cde0-435f-9553-e0b8c4f5851d" id="_63112cbc-cde0-435f-9553-e0b8c4f5851d"></a>
                 <tr>
                   <td valign="top" class="example_label" style="width:82.8pt;padding:0 0 0 1em;margin-left:0pt">EXAMPLE  2</td>
                   <td valign="top" class="example">
         <p class="example"><a name="_158d4efa-b1c9-4aec-b325-756de8e4c969" id="_158d4efa-b1c9-4aec-b325-756de8e4c969"></a>'2M', '02M', and '0002M' all describe the calendar month February.</p>
       </td>
                 </tr>
               </table>
             </div>
           </div>
           <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
<div class="colophon"></div>
    OUTPUT
  end



end
