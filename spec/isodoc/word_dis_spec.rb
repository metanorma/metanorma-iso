require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "maps styles for DIS" do
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert
      .new({})
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <status><stage>30</stage></status>
          </bibdata>
          <sections>
          <terms id="A">
            <term id="B">
            <preferred><expression><name>First</name></expression></preferred>
            <admitted><expression><name>Second</name></expression></admitted>
            </term>
          </terms>
          </sections>
        </iso-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(html).to include 'class="AltTerms"'
    expect(html).not_to include 'class="AdmittedTerm"'

    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert
      .new({})
      .convert("test", <<~"INPUT", false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <status><stage>50</stage></status>
          </bibdata>
          <sections>
          <terms id="A">
            <term id="B">
            <preferred><expression><name>First</name></expression></preferred>
            <admitted><expression><name>Second</name></expression></admitted>
            </term>
          </terms>
          </sections>
        </iso-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(html).not_to include 'class="AltTerms"'
    expect(html).to include 'class="AdmittedTerm"'
  end

  it "deals with span" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>30</stage></status>
        </bibdata>
        <sections>
        <clause id="A"><p><span class="C"><em>H</em> I</em></span></p></clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class='WordSection3'>
        <p class='zzSTDTitle1'/>
        <div id='A'>
          <h1/>
          <p>
            <i>H</i>
             I
          </p>
        </div>
      </div>
    OUTPUT
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", input, true)
    expect(xmlpp(Nokogiri::XML(output)
      .at("//div[@class = 'WordSection3']").to_xml))
      .to be_equivalent_to xmlpp(word)

    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A"><p><span class="C"><em>H</em> I</em></span></p></clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class='WordSection3'>
        <p class='zzSTDTitle1'/>
        <div id='A'>
          <h1/>
          <p>
            <span class='C'>
              <i>H</i>
               I
            </span>
          </p>
        </div>
      </div>
    OUTPUT
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", input, true)
    expect(xmlpp(Nokogiri::XML(output)
      .at("//div[@class = 'WordSection3']").to_xml))
      .to be_equivalent_to xmlpp(word)
  end

  it "deals with foreword and intro" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>30</stage></status>
        </bibdata>
        <preface>
        <foreword><title>Foreword</title><p>Para</p></foreword>
        <introduction><title>Foreword</title><p>Para</p></introduction>
        </preface>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class='WordSection2'>
         <div style='mso-element:para-border-div;border:solid windowtext 1.0pt;
      border-bottom-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:
      solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:1.0pt 4.0pt 0cm 4.0pt;
      margin-left:5.1pt;margin-right:5.1pt'>
           <div>
             <a name='boilerplate-copyright-destination' id='boilerplate-copyright-destination'/>
           </div>
         </div>
         <p class='zzContents' style='margin-top:0cm'>
           <span lang='EN-GB' xml:lang='EN-GB'>Contents</span>
         </p>
         <p class='MsoNormal'>
           <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
         </p>
         <div>
           <p class='ForewordTitle'>Foreword</p>
           <p class='ForewordText'>Para</p>
         </div>
         <p class='MsoNormal'>
           <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
         </p>
         <div class='Section3' id=''>
           <p class='IntroTitle'>Foreword</p>
           <p class='MsoNormal'>Para</p>
         </div>
         <p class='MsoNormal'> </p>
       </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    doc = Nokogiri::XML(output)
      .xpath("//xmlns:p[@class = 'MsoToc1']").each(&:remove)
      .at("//xmlns:div[@class = 'WordSection2']")
    expect(xmlpp(doc.to_xml))
      .to be_equivalent_to xmlpp(word)

    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <preface>
        <foreword><title>Foreword</title><p>Para</p></foreword>
        <introduction><title>Foreword</title><p>Para</p></introduction>
        </preface>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class='WordSection2'>
         <div style='mso-element:para-border-div;border:solid windowtext 1.0pt;
      border-bottom-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:
      solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:1.0pt 4.0pt 0cm 4.0pt;
      margin-left:5.1pt;margin-right:5.1pt'>
           <div>
             <a name='boilerplate-copyright-destination' id='boilerplate-copyright-destination'/>
           </div>
         </div>
         <p class='zzContents' style='margin-top:0cm'>
           <span lang='EN-GB' xml:lang='EN-GB'>Contents</span>
         </p>
         <p class='MsoBodyText'>
           <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
         </p>
         <div>
           <p class='ForewordTitle'>Foreword</p>
           <p class='ForewordText'>Para</p>
         </div>
         <p class='MsoBodyText'>
           <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
         </p>
         <div class='Section3' id=''>
           <p class='IntroTitle'>Foreword</p>
           <p class='MsoBodyText'>Para</p>
         </div>
         <p class='MsoBodyText'> </p>
       </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    doc = Nokogiri::XML(output)
      .xpath("//xmlns:p[@class = 'MsoToc1']").each(&:remove)
      .at("//xmlns:div[@class = 'WordSection2']")
    expect(xmlpp(doc.to_xml))
      .to be_equivalent_to xmlpp(word)
  end
end
