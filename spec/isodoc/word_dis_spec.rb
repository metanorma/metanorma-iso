require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "maps styles for DIS" do
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert
      .new({})
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <status><stage>30</stage></status>
          </bibdata>
          <sections>
          <terms id="A" displayorder="1">
            <term id="B">
            <fmt-preferred><p>First</p></fmt-preferred>
            <fmt-admitted><p>Second</p></fmt-admitted>
            </term>
          </terms>
          </sections>
        </iso-standard>
      INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(html).to include('class="AltTerms"')
    expect(html).not_to include('class="AdmittedTerm"')

    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert
      .new({})
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <status><stage>50</stage></status>
          </bibdata>
          <sections>
          <terms id="A" displayorder="1">
            <term id="B">
            <fmt-preferred><p>First</p></fmt-preferred>
            <fmt-admitted><p>Second</p></fmt-admitted>
            </term>
          </terms>
          </sections>
        </iso-standard>
      INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(html).not_to include('class="AltTerms"')
    expect(html).to include('class="AdmittedTerm"')

    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert
      .new({ isowordtemplate: "simple" })
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <status><stage>50</stage></status>
          </bibdata>
          <sections>
          <terms id="A" displayorder="1">
            <term id="B">
            <fmt-preferred><p>First</p></fmt-preferred>
            <fmt-admitted><p>Second</p></fmt-admitted>
            </term>
          </terms>
          </sections>
        </iso-standard>
      INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(html).to include('class="AltTerms"')
    expect(html).not_to include('class="AdmittedTerm"')

    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert
      .new({ isowordtemplate: "dis" })
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <status><stage>30</stage></status>
          </bibdata>
          <sections>
          <terms id="A" displayorder="1">
            <term id="B">
            <fmt-preferred><p>First</p></fmt-preferred>
            <fmt-admitted><p>Second</p></fmt-admitted>
            </term>
          </terms>
          </sections>
        </iso-standard>
      INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(html).not_to include('class="AltTerms"')
    expect(html).to include('class="AdmittedTerm"')
  end

  it "deals with span" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>30</stage></status>
        </bibdata>
        <sections>
        <clause id="A" displayorder="1"><p><span class="C"><em>H</em> I</em></span></p></clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class='WordSection3'>
        <div id='A'>
          <h1/>
          <p>
            <span class="C"><i>H</i> I</span>
          </p>
        </div>
      </div>
    OUTPUT
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", input, true)
    expect(Canon.format_xml(Nokogiri::XML(output)
      .at("//div[@class = 'WordSection3']").to_xml))
      .to be_equivalent_to Canon.format_xml(word)

    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A" displayorder="1"><p><span class="C"><em>H</em> I</em></span></p></clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class='WordSection3'>
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
    expect(Canon.format_xml(Nokogiri::XML(output)
      .at("//div[@class = 'WordSection3']").to_xml))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "deals with foreword and intro" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>30</stage></status>
        </bibdata>
        <preface>
        <foreword displayorder="1" id="A"><fmt-title id="_">Foreword</fmt-title><p>Para</p></foreword>
        <introduction displayorder="2" id="B"><fmt-title id="_">Foreword</fmt-title><p>Para</p></introduction>
        </preface>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class="WordSection2">
          <div>
             <a name="boilerplate-copyright-destination" id="boilerplate-copyright-destination"/>
             <div style="mso-element:para-border-div;border:solid windowtext 1.0pt; border-bottom-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt: solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:1.0pt 4.0pt 0cm 4.0pt; margin-left:5.1pt;margin-right:5.1pt">
                <div>
                   <a name="boilerplate-copyright-default-destination" id="boilerplate-copyright-default-destination"/>
                </div>
             </div>
             <div>
                <a name="boilerplate-copyright-append-destination" id="boilerplate-copyright-append-destination"/>
             </div>
          </div>
          <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div><a name="A" id="A"/>
             <p class="ForewordTitle">Foreword</p>
             <p class="ForewordText">Para</p>
          </div>
          <p class="MsoNormal">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div class="Section3"><a name="B" id="B"/>
             <p class="IntroTitle">Foreword</p>
             <p class="MsoNormal">Para</p>
          </div>
          <p class="MsoNormal"> </p>
       </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    doc = Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection2']")
    expect(Canon.format_xml(strip_guid(doc.to_xml)))
      .to be_equivalent_to Canon.format_xml(word)

    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <preface>
        <foreword displayorder="1" id="A"><fmt-title id="_">Foreword</fmt-title><p>Para</p></foreword>
        <introduction displayorder="2" id="B"><fmt-title id="_">Foreword</fmt-title><p>Para</p></introduction>
        </preface>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class='WordSection2'>
           <div>
             <a name='boilerplate-copyright-destination' id='boilerplate-copyright-destination'/>
         <div>
         <a name="boilerplate-copyright-default-destination" id="boilerplate-copyright-default-destination"/>
      </div>
      <div>
         <a name="boilerplate-copyright-append-destination" id="boilerplate-copyright-append-destination"/>
      </div>
         </div>
         <p class='MsoBodyText'>
           <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
         </p>
         <div><a name="A" id="A"/>
           <p class='ForewordTitle'>Foreword</p>
           <p class='ForewordText'>Para</p>
         </div>
         <p class='MsoBodyText'>
           <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
         </p>
         <div class='Section3'><a name="B" id="B"/>
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
      .at("//xmlns:div[@class = 'WordSection2']")
    expect(Canon.format_xml(strip_guid(doc.to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "formats references" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
                <bibliography>
          <references id="_normative_references" normative="true" obligation="informative" displayorder="1">
            <fmt-title id="_">Normative References</fmt-title>
            <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
            <bibitem id="ISO712" type="standard">
            <formattedref>ALUFFI, Paolo, ed. (2022). <em><span class="std_class">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</span></em>, 1st edition. Cambridge, UK: CUP.</formattedref>
            <docidentifier type="ISO">ISO/IEC 712-3:2022</docidentifier>
            <biblio-tag><span class="stdpublisher" style="mso-pattern:none;">ISO/IEC</span><span class="stddocNumber" style="mso-pattern:none;">712</span>-<span class="stddocPartNumber" style="mso-pattern:none;">3</span>:<span class="stdyear" style="mso-pattern:none;">2022</span>, </biblio-tag>
            </bibitem>
        </references>
        </bibliography>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
             <div class='WordSection3'>
        <div>
          <h1>Normative References</h1>
          <p class='MsoBodyText'>
            The following documents are referred to in the text in such a way that
            some or all of their content constitutes requirements of this document.
            For dated references, only the edition cited applies. For undated
            references, the latest edition of the referenced document (including any
            amendments) applies.
          </p>
          <p class="RefNorm"><a name="ISO712" id="ISO712"/><span class="stdpublisher" style="mso-pattern:none;mso-pattern:none;">ISO/IEC</span><span class="stddocNumber" style="mso-pattern:none;mso-pattern:none;">712</span>-<span class="stddocPartNumber" style="mso-pattern:none;mso-pattern:none;">3</span>:<span class="stdyear" style="mso-pattern:none;mso-pattern:none;">2022</span>, ALUFFI, Paolo, ed. (2022). <i><span class="std_class">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</span></i>, 1st edition. Cambridge, UK: CUP.</p>
        </div>
      </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    doc = Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']")
    expect(Canon.format_xml(doc.to_xml))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "formats tt" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <preface>
        <foreword displayorder="1"><fmt-title id="_">Foreword</fmt-title>
        <p><tt>A <strong>B</strong> <em>C</em> <strong>D<em>E</em>F</strong> <em>G<strong>H</strong>I</em></tt></p>
        <p><strong>A <tt>B</tt> <em>C<tt>D</tt>E</em></strong></p>
        <p><em>A <tt>B</tt> <strong>C<tt>D</tt>E</strong></em></p>
        </foreword>
        </preface>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
          <div class='WordSection2'>
          <div>
            <a name='boilerplate-copyright-destination' id='boilerplate-copyright-destination'/>
          <div>
         <a name="boilerplate-copyright-default-destination" id="boilerplate-copyright-default-destination"/>
      </div>
      <div>
         <a name="boilerplate-copyright-append-destination" id="boilerplate-copyright-append-destination"/>
      </div>
          </div>
        <p class='MsoBodyText'>
          <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
        </p>
        <div>
          <p class='ForewordTitle'>Foreword</p>
          <p class='ForewordText'>
            <span class='ISOCode'>
              A
              <span class='ISOCodebold'>B</span>
              <span class='ISOCodeitalic'>C</span>
              <span class='ISOCodebold'>
                D
                <span class='ISOCodeitalic'>E</span>
                F
              </span>
              <span class='ISOCodeitalic'>
                G
                <b>H</b>
                I
              </span>
            </span>
          </p>
          <p class='ForewordText'>
            <b>
              A
              <span class='ISOCodebold'>B</span>
              <i>
                C
                <span class='ISOCodeitalic'>D</span>
                E
              </i>
            </b>
          </p>
          <p class='ForewordText'>
            <i>
              A
              <span class='ISOCodeitalic'>B</span>
              <b>
                C
                <span class='ISOCodebold'>D</span>
                E
              </b>
            </i>
          </p>
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
      .at("//xmlns:div[@class = 'WordSection2']")
    expect(Canon.format_xml(strip_guid(doc.to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "formats tt with ad hoc smaller font" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <preface>
        <foreword displayorder="1"><fmt-title id="_">Foreword</fmt-title>
        <table><tbody>
        <tr><td>
        <p><tt>A <strong>B</strong> <em>C</em> <strong>D<em>E</em>F</strong> <em>G<strong>H</strong>I</em></tt></p>
        <p><strong>A <tt>B</tt> <em>C<tt>D</tt>E</em></strong></p>
        <p><em>A <tt>B</tt> <strong>C<tt>D</tt>E</strong></em></p>
        </td></tr>
        </tbody></table>
        </foreword>
        </preface>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
          <div class='WordSection2'>
          <div>
            <a name='boilerplate-copyright-destination' id='boilerplate-copyright-destination'/>
          <div>
         <a name="boilerplate-copyright-default-destination" id="boilerplate-copyright-default-destination"/>
      </div>
      <div>
         <a name="boilerplate-copyright-append-destination" id="boilerplate-copyright-append-destination"/>
      </div>
          </div>
        <p class='MsoBodyText'>
          <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
        </p>
        <div>
           <p class="ForewordTitle">Foreword</p>
           <div align="center" class="table_container">
             <table class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
               <tbody>
                 <tr>
                   <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                     <p class="Tablebody" style="page-break-after:auto">
                       <span class="ISOCode">
                         <span style="font-size: 9pt;">A <span class="ISOCodebold"><span style="font-size: 9pt;">B</span></span><span class="ISOCodeitalic"><span style="font-size: 9pt;">C</span></span><span class="ISOCodebold"><span style="font-size: 9pt;">D<span class="ISOCodeitalic"><span style="font-size: 9pt;">E</span></span>F</span></span><span class="ISOCodeitalic"><span style="font-size: 9pt;">G<b>H</b>I</span></span></span>
                       </span>
                     </p>
                     <p class="Tablebody" style="page-break-after:auto">
                       <b>A <span class="ISOCodebold"><span style="font-size: 9pt;">B</span></span><i>C<span class="ISOCodeitalic"><span style="font-size: 9pt;">D</span></span>E</i></b>
                     </p>
                     <p class="Tablebody" style="page-break-after:auto">
                       <i>A <span class="ISOCodeitalic"><span style="font-size: 9pt;">B</span></span><b>C<span class="ISOCodebold"><span style="font-size: 9pt;">D</span></span>E</b></i>
                     </p>
                   </td>
                 </tr>
               </tbody>
             </table>
           </div>
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
      .at("//xmlns:div[@class = 'WordSection2']")
    expect(Canon.format_xml(strip_guid(doc.to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "deals with tables" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A" displayorder="1">
        <table id="B">
        <fmt-name id="_">Table1</fmt-name>
        <thead>
        <tr>
        <th>A</th><th><p>B</p></th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <th>C</th><td><p>D</p></td>
        </tr>
        </tbody>
        <tfoot>
        <tr>
        <th>E</th><td><p>F</p></td>
        </tr>
        </tfoot>
        <dl key="true">
        <fmt-name id="_">Key</fmt-name>
        <dt>E</dt><dd>eee</dd>
        </dl>
        </table>
        <table class="rouge-line-table"><tbody><tr id="line-1" class="lineno"><td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;"><pre>1</pre></td><td class="rouge-code"><sourcecode><span class="p">{</span></sourcecode></td></tr><tr id="line-2" class="lineno"><td class="rouge-gutter gl" style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;"><pre>2</pre></td><td class="rouge-code"><sourcecode><span class="w">  </span><span class="nl">"$schema"</span><span class="p">:</span><span class="w"> </span><span class="s2">"http://json-schema.org/draft/2019-09/schema"</span><span class="p">,</span></sourcecode></td></tr></table>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
       <div class="WordSection3">
          <div>
             <a name="A" id="A"/>
             <h1/>
             <p class="Tabletitle" style="text-align:center;">Table1</p>
             <div align="center" class="table_container">
                <table class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                   <a name="B" id="B"/>
                   <thead>
                      <tr>
                         <th style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;" align="center" valign="middle">
                            <div class="Tableheader" style="page-break-after:avoid">A</div>
                         </th>
                         <th style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;" align="center" valign="middle">
                            <p class="Tableheader" style="text-align: center;page-break-after:avoid">B</p>
                         </th>
                      </tr>
                   </thead>
                   <tbody>
                      <tr>
                         <th style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                            <div class="Tablebody" style="page-break-after:auto">C</div>
                         </th>
                         <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                            <p class="Tablebody" style="page-break-after:auto">D</p>
                         </td>
                      </tr>
                   </tbody>
                   <tfoot>
                      <tr>
                         <th style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;page-break-after:auto;">
                            <div class="Tablebody" style="page-break-after:auto">E</div>
                         </th>
                         <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;page-break-after:auto;">
                            <p class="Tablebody" style="page-break-after:auto">F</p>
                         </td>
                      </tr>
                      <tr>
                         <td colspan="2" style="border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">
                            <div class="Tablebody">
                               <p class="KeyTitle">Key</p>
                               <p style="text-indent: -2.0cm; margin-left: 2.0cm; tab-stops: 2.0cm;" class="MsoBodyText">
                                  E
                                  <span style="mso-tab-count:1">  </span>
                                  eee
                               </p>
                            </div>
                         </td>
                      </tr>
                   </tfoot>
                </table>
             </div>
             <div align="center" class="table_container">
                <table class="rouge-line-table" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;">
                   <tbody>
                      <tr>
                         <td style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;;page-break-after:avoid;" class="rouge-gutter gl">
                            <div class="Tablebody" style="page-break-after:avoid">
                               <pre style="page-break-after:avoid">1</pre>
                            </div>
                         </td>
                         <td style="page-break-after:avoid;" class="rouge-code">
                            <p class="Code" style="page-break-after:avoid">
                               <span class="p">{</span>
                            </p>
                         </td>
                      </tr>
                      <tr>
                         <td style="-moz-user-select: none;-ms-user-select: none;-webkit-user-select: none;user-select: none;;page-break-after:auto;" class="rouge-gutter gl">
                            <div class="Tablebody" style="page-break-after:auto">
                               <pre style="page-break-after:auto">2</pre>
                            </div>
                         </td>
                         <td style="page-break-after:auto;" class="rouge-code">
                            <p class="Code" style="page-break-after:auto">
                               <span class="w">  </span>
                               <span class="nl">"$schema"</span>
                               <span class="p">:</span>
                               <span class="w"> </span>
                               <span class="s2">"http://json-schema.org/draft/2019-09/schema"</span>
                               <span class="p">,</span>
                            </p>
                         </td>
                      </tr>
                   </tbody>
                </table>
             </div>
          </div>
       </div>
    WORD
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "deals with figures" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A" displayorder="1">
        <figure id="B">
        <fmt-name id="_">Table1</fmt-name>
        <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto"/>
        <note id="C"><fmt-name id="_">FIGURENOTE<span class="fmt-label-delim"><tab/></span></fmt-name>
        <p>Note</p></note>
        <example id="D"><p>Example</p></example>
        <dl key="true">
        <fmt-name id="_">Key</fmt-name>
        <dt>E</dt><dd>eee</dd>
        </dl>
        </figure>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
       <div class="WordSection3">
          <div>
             <a name="A" id="A"/>
             <h1/>
             <div class="figure">
                <a name="B" id="B"/>
                <p class="FigureGraphic">
                   <img src="_.gif" height="20" width="20"/>
                </p>
                <div class="Figurenote">
                   <a name="C" id="C"/>
                   <p class="Figurenote">
                      FIGURENOTE
                      <span style="mso-tab-count:1">  </span>
                      Note
                   </p>
                </div>
                <div class="Figureexample">
                   <a name="D" id="D"/>
                   <p class="Figureexample">
                      <span style="mso-tab-count:1">  </span>
                      Example
                   </p>
                </div>
                <div align="left" style="page-break-after:avoid;">
                <p class="KeyTitle">Key</p>
                <div class="figdl" style="page-break-after:avoid;">
                   <table class="figdl">
                      <tr>
                         <td valign="top" align="left">
                            <p align="left" style="margin-left:0pt;text-align:left;" class="Tablebody">E</p>
                         </td>
                         <td valign="top">
                            <div class="Tablebody">eee</div>
                         </td>
                      </tr>
                   </table>
                   </div>
                </div>
                <p class="Figuretitle" style="text-align:center;">Table1</p>
             </div>
          </div>
       </div>
    WORD
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "deals with examples" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A" displayorder="1">
        <example id="B">
        <fmt-name id="_">EXAMPLE</fmt-name>
        <p>First example</p>
        </example>
        <example id="C">
        <p>Second example</p>
        <sourcecode>Code</sourcecode>
        <p>Continuation</p>
        </example>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class='WordSection3'>
        <div>
          <a name='A' id='A'/>
          <h1/>
          <div>
            <a name='B' id='B'/>
            <p class='Example'>
            EXAMPLE
              <span style='mso-tab-count:1'>  </span>
              First example
            </p>
          </div>
          <div>
            <a name='C' id='C'/>
            <p class='Example'>
              <span style='mso-tab-count:1'>  </span>
              Second example
            </p>
            <p class='Code-' style='margin-bottom:12pt;'>Code</p>
            <p class='Examplecontinued'>Continuation</p>
          </div>
        </div>
      </div>
    WORD
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "deals with formulas" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A" displayorder="1">
        <formula id="B"><fmt-name id="_">(A.1)</fmt-name><fmt-stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow><mi>S</mi></mrow><mrow><mrow><mi>s</mi><mi>l</mi><mo>,</mo><mo>max</mo></mrow></mrow></msub><mo>=</mo><mo>⌊</mo><mrow><mfrac><mrow><mrow><msub><mrow><mi>L</mi></mrow><mrow><mo>max</mo></mrow></msub><mo>×</mo><msub><mrow><mi>N</mi></mrow><mrow><mrow><mi>b</mi><mi>p</mi><mi>p</mi></mrow></mrow></msub></mrow></mrow><mrow><mn>8</mn></mrow></mfrac></mrow><mo> </mo><mo>⌋</mo></math><!-- (S)_((s l , max)) = |__ (((L)_((max)) xx (N)_((b p p))))/((8))  __| --><asciimath>S_{sl,max} = |__ {: { L_{:max:} xx N_{bpp} :} / 8 :}  __|</asciimath></fmt-stem></formula>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
          <div class="WordSection3">
        <div>
          <a name="A" id="A"/>
          <h1/>
          <div>
            <a name="B" id="B"/>
            <div class="Formula">
              <p class="Formula"><span class="stem"><m:oMath><m:sSub><m:sSubPr><m:ctrlPr><w:rPr><w:rFonts w:ascii="Cambria Math" w:hAnsi="Cambria Math"/><w:i/></w:rPr></m:ctrlPr></m:sSubPr><m:e><m:r><m:t>S</m:t></m:r></m:e><m:sub><m:r><m:t>s</m:t></m:r><m:r><m:t>l</m:t></m:r><m:r><m:t>,</m:t></m:r><m:r><m:t>max</m:t></m:r></m:sub></m:sSub><m:r><m:t>=</m:t></m:r><m:r><m:t>⌊</m:t></m:r><m:f><m:fPr><m:ctrlPr><w:rPr><w:rFonts w:ascii="Cambria Math" w:hAnsi="Cambria Math"/><w:i/></w:rPr></m:ctrlPr></m:fPr><m:num><m:sSub><m:sSubPr><m:ctrlPr><w:rPr><w:rFonts w:ascii="Cambria Math" w:hAnsi="Cambria Math"/><w:i/></w:rPr></m:ctrlPr></m:sSubPr><m:e><m:r><m:t>L</m:t></m:r></m:e><m:sub><m:r><m:t>max</m:t></m:r></m:sub></m:sSub><m:r><m:t>×</m:t></m:r><m:sSub><m:sSubPr><m:ctrlPr><w:rPr><w:rFonts w:ascii="Cambria Math" w:hAnsi="Cambria Math"/><w:i/></w:rPr></m:ctrlPr></m:sSubPr><m:e><m:r><m:t>N</m:t></m:r></m:e><m:sub><m:r><m:t>b</m:t></m:r><m:r><m:t>p</m:t></m:r><m:r><m:t>p</m:t></m:r></m:sub></m:sSub></m:num><m:den><m:r><m:t>8</m:t></m:r></m:den></m:f><m:r><m:t> </m:t></m:r><m:r><m:t>⌋</m:t></m:r></m:oMath></span><span style="mso-tab-count:1">  </span>(A.1)</p>
            </div>
          </div>
        </div>
      </div>
    WORD
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "deals with notes" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A" displayorder="1">
        <note id="B">
        <fmt-name id="_">NOTE<span class="fmt-label-delim"><tab/></span></fmt-name>
        <p>First example</p>
        </note>
        <note id="C">
        <p>Second example</p>
        <sourcecode>Code</sourcecode>
        <p>Continuation</p>
        </note>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
          <div class='WordSection3'>
        <div>
          <a name='A' id='A'/>
          <h1/>
          <div>
            <a name='B' id='B'/>
            <p class='Note'>
              NOTE
              <span style='mso-tab-count:1'>  </span>
              First example
            </p>
          </div>
          <div>
             <a name='C' id='C'/>
             <p class='Note'>
               Second example
             </p>
             <p class='Code-'>Code</p>
             <p class='Notecontinued'>Continuation</p>
         </div>
        </div>
      </div>
    WORD
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "deals with annexes" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <annex id="A" displayorder="1"><fmt-title id="_">Annex</fmt-title>
        <clause id="B"><fmt-title id="_">Subannex</fmt-title>
        <clause id="C"><fmt-title id="_">Subsubannex</fmt-title>
        </clause>
        </clause>
        </annex>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class='WordSection3'>
         <p class='MsoBodyText'>
           <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
         </p>
         <div class='Section3'>
           <a name='A' id='A'/>
           <p class='ANNEX'>Annex</p>
           <div>
             <a name='B' id='B'/>
             <p class='a2'>Subannex</p>
             <div>
               <a name='C' id='C'/>
               <p class='a3'>Subsubannex</p>
             </div>
           </div>
         </div>
       </div>
    WORD
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "deals with blockquotes" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
         <sections>
        <clause id="A" displayorder="1">
        <quote>
        <p>Normal clause</p>
        <note><p>Note clause</p></note>
        <example>
        <p>Example start</p>
        <sourcecode>X</sourcecode>
        <p>Example continued</p>
        </example>
        <sourcecode>X</sourcecode>
        </quote>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class='WordSection3'>
         <div>
           <a name='A' id='A'/>
           <h1/>
           <div>
             <p class='BodyTextindent1'>Normal clause</p>
             <div>
               <p class='Noteindent'>
                 Note clause
               </p>
             </div>
             <div id=''>
               <p class='Exampleindent'>
                 <span style='mso-tab-count:1'>  </span>
                 Example start
               </p>
              <p class='Code--' style='margin-bottom:12pt;'>X</p>
               <p class='Exampleindentcontinued'>Example continued</p>
             </div>
              <p class='Code-'>X</p>
           </div>
         </div>
       </div>
    WORD
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "deals with title" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
        <title language="en" format="text/plain" type="title-intro">Date and time</title>
          <title language="en" format="text/plain" type="title-main">Representations for information interchange</title>
        <title language="en" format="text/plain" type="title-part">Basic rules</title>
        <title language="en" format="text/plain" type="title-part-prefix">Part 1</title>
        <date type="published"><on>2011</on></date>
          <status><stage>50</stage></status>
          <ext><doctype>international-standard</doctype>
          <structuredidentifier><project-number part="1" origyr="2022-03-10">8601</project-number></structuredidentifier>
          <editorialgroup/>
          <secretariat>BSI</secretariat>
          </ext>
        </bibdata>
        <sections>
        <clause id="A" displayorder="1"><title>First clause</title>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class='WordSection3'>
                 <p class='zzSTDTitle'>
                <span>Date and time — Representations for information interchange — </span>
         <span style=";font-weight:normal">Part 1:</span>
         <span>Basic rules</span>
        </p>
        <div>
          <a name='A' id='A'/>
             <h1>1
                      <span style="mso-tab-count:1">  </span>
                   First clause
             </h1>
        </div>
      </div>
    WORD
    title = <<~WORD
      <div class='WordSection1'>
          <p class="zzCover" align="right" style="text-align:right;font-weight:normal;">
              <span lang="EN-GB" xml:lang="EN-GB">Date: <span style="mso-no-proof:yes">2011</span></span>
          </p>
        <p class='zzCover' style='font-weight:normal;'>
           <span lang='EN-GB' xml:lang='EN-GB'>Reference number of project: </span>
         </p>
         <p class='zzCover' style='font-weight:normal;'>
           <span lang='EN-GB' xml:lang='EN-GB'>Committee identification: </span>
         </p>
         <p class='zzCover'>
           <span lang='EN-GB' xml:lang='EN-GB'>
             <b>
               Date and time — Representations for information interchange
               — Part 1: Basic rules
             </b>
           </span>
         </p>
         <p class='zzCover' style='font-weight:normal;'>
           <i/>
         </p>
      </div>
    WORD
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection1']").to_xml)))
      .to be_equivalent_to Canon.format_xml(title)
  end

  it "deals with amendments" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
        <title language="en" format="text/plain" type="title-intro">Date and time</title>
          <title language="en" format="text/plain" type="title-main">Representations for information interchange</title>
        <title language="en" format="text/plain" type="title-part">Basic rules</title>
        <title language="en" format="text/plain" type="title-amd">Technical corrections</title>
        <title language="en" format="text/plain" type="title-amendment-prefix">AMENDMENT 1</title>
        <title language="en" format="text/plain" type="title-part-prefix">Part 1</title>
        <date type="published"><on>2011</on></date>
          <status><stage>50</stage></status>
          <ext><doctype>amendment</doctype>
          <structuredidentifier><project-number part="1" amendment="1" origyr="2022-03-10">8601</project-number>
          </structuredidentifier>
          <editorialgroup/>
          <secretariat>BSI</secretariat>
          </ext>
        </bibdata>
        <preface>
        <foreword id="F" displayorder="1"><fmt-title id="_">Foreword</fmt-title></foreword>
        </preface>
         <sections>
        <clause id="A" displayorder="2"><fmt-title id="_">First clause</fmt-title>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
       <div class='WordSection3'>
                <p class="zzSTDTitle">
          <span>Date and time — Representations for information interchange — </span>
          <span style=";font-weight:normal">Part 1:</span>
          <span>Basic rules</span>
        </p>
        <p class="zzSTDTitle">
          <span style="font-weight:normal">AMENDMENT 1: Technical corrections</span>
        </p>
        <div>
          <a name="A" id="A"/>
          <p style="font-style:italic;page-break-after:avoid;" class="MsoBodyText">First clause</p>
        </div>
      </div>
    WORD
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "deals with copyright boilerplate" do
    presxml = <<~OUTPUT
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <bibdata type="standard">
          <status>
            <stage language="">50</stage>
          </status>
        </bibdata>
        <boilerplate>
          <copyright-statement>
             <clause id="boilerplate-copyright-default">
            <title>COPYRIGHT PROTECTED DOCUMENT</title>
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
              <clause id="added">
            <p>Is there anybody out there?</p>
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

    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new(wordstylesheet: "spec/assets/word.css")
      .convert("test", presxml, false)
    word = File.read("test.doc", encoding: "UTF-8")
    contents = word.sub(%r{^.*<body}m, "<body").sub(%r{</body>.*$}m,
                                                    "</body>")
    contents = Nokogiri::XML(contents)
      .at("//div[a/@id = 'boilerplate-copyright-destination']")
    expect(Canon.format_xml(contents.to_xml))
      .to be_equivalent_to Canon.format_xml(<<~OUTPUT)
        <div>
        <a name="boilerplate-copyright-destination" id="boilerplate-copyright-destination"/>
        <div>
        <a name="boilerplate-copyright-default-destination" id="boilerplate-copyright-default-destination"/>
        <div>
        <a name="boilerplate-copyright-default" id="boilerplate-copyright-default"/>
        <p class="zzCopyright">
        <a name="boilerplate-year" id="boilerplate-year"/>
        © ISO 2019, Published in Switzerland
        </p>
        <p class="zzCopyright">
        <a name="boilerplate-message" id="boilerplate-message"/>
        I am the Walrus.
          </p>
        <p class="zzCopyright">
        <a name="boilerplate-name" id="boilerplate-name"/>
        ISO copyright office
        </p>
        <p style="text-align:left;" align="left" class="zzCopyright">
        <a name="boilerplate-address" id="boilerplate-address"/>
        ISO copyright office
        </p>
        <p class="zzCopyright">
        Ch. de Blandonnet 8 ?~@? CP 401
        </p>
        <p class="zzCopyright">
        CH-1214 Vernier, Geneva, Switzerland
        </p>
        <p class="zzCopyright">
        Phone: +41 22 749 01 11
        </p>
        <p class="zzCopyright">
        Email: copyright@iso.org
        </p>
        <p class="zzCopyright">
        www.iso.org</p>
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

    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new(wordstylesheet: "spec/assets/word.css")
      .convert("test",
               presxml.sub(%r{<stage language="">50</stage>},
                           "<stage>60</stage><substage>00</substage>"), false)
    word = File.read("test.doc", encoding: "UTF-8")
    contents = word.sub(%r{^.*<body}m, "<body").sub(%r{</body>.*$}m,
                                                    "</body>")
    contents = Nokogiri::XML(contents)
      .at("//div[a/@id = 'boilerplate-copyright-destination']")
    expect(Canon.format_xml(contents.to_xml))
      .to be_equivalent_to Canon.format_xml(<<~OUTPUT)
        <div>
        <a name="boilerplate-copyright-destination" id="boilerplate-copyright-destination"/>
        <div>
        <a name="boilerplate-copyright-default-destination" id="boilerplate-copyright-default-destination"/>
        <div>
        <a name="boilerplate-copyright-default" id="boilerplate-copyright-default"/>
        <p class="zzCopyright">
        <a name="boilerplate-year" id="boilerplate-year"/>
        © ISO 2019, Published in Switzerland
        </p>
        <p class="zzCopyright">
        <a name="boilerplate-message" id="boilerplate-message"/>
        I am the Walrus.
          </p>
        <p class="zzCopyright">
        <a name="boilerplate-name" id="boilerplate-name"/>
        ISO copyright office
        </p>
        <p style="text-indent:20.15pt;" align="left" class="zzCopyright">
        <a name="boilerplate-address" id="boilerplate-address"/>
        ISO copyright office
        </p>
        <p class="zzCopyright" style="text-indent:20.15pt;">
        Ch. de Blandonnet 8 ?~@? CP 401
        </p>
        <p class="zzCopyright" style="text-indent:20.15pt;">
        CH-1214 Vernier, Geneva, Switzerland
        </p>
        <p class="zzCopyright" style="text-indent:20.15pt;">
        Phone: +41 22 749 01 11
        </p>
        <p class="zzCopyright" style="text-indent:20.15pt;">
        Email: copyright@iso.org
        </p>
        <p class="zzCopyright" style="text-indent:20.15pt;">
        www.iso.org</p>
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
  end

  it "deals with Simple Template styles" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>20</stage></status>
        </bibdata>
         <sections>
        <clause id="A" displayorder="1"><fmt-title id="_">Clause Title</fmt-title>
        <ul><li>List</li></ul>
        <note id="B"><p>Note</p>
        <ul><li>Note List</li></ul>
        </note>
        <example id="C"><p>Example</p>
        <ul><li>Example List</li></ul>
        </example>
        <figure id="D"><fmt-name id="_">Figure Title</fmt-name></figure>
        <sourcecode id="E">XYZ</sourcecode>
        <table id="F"><fmt-name id="_">Table</fmt-name></table>
        </clause>
        </sections>
        <annex id="G" displayorder="2"><fmt-title id="_">Annex Title</fmt-title>
        <table id="H"><fmt-name id="_">Annex Table</fmt-name></table>
        <clause id="I"><fmt-title id="_">Annex Clause Title</fmt-title>
        </clause>
        </annex>
        <bibliography>
        <references id="_normative_references" normative="false" obligation="informative" displayorder="3">
            <fmt-title id="_">Bibliography</fmt-title>
            <bibitem id="ISO712" type="standard">
            <formattedref>ALUFFI, Paolo, ed. (2022). <em><span class="std_class">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</span></em>, 1st edition. Cambridge, UK: CUP.</formattedref>
            <docidentifier type="ISO">ISO/IEC 712-3:2022</docidentifier>
            <biblio-tag>[1]<tab/>ISO/IEC 712-3:2022, </biblio-tag>
            </bibitem>
        </references>
        </bibliography>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class='WordSection3'>
         <div>
           <a name='A' id='A'/>
           <h1>Clause Title</h1>
           <div class="ul_wrap">
           <p style='mso-list:l3 level1 lfo1;' class='MsoListParagraphCxSpFirst'>List</p>
           </div>
           <div class='Note'>
             <a name='B' id='B'/>
             <p class='Note'>
               Note
             </p>
             <div class="ul_wrap">
             <p style='font-size:10.0pt;;mso-list:l3 level1 lfo2;' class='MsoListParagraphCxSpFirst'>Note List</p>
             </div>
           </div>
           <div class='Example'>
             <a name='C' id='C'/>
             <p class='Example'>
               <span style='mso-tab-count:1'>  </span>
             Example
             </p>
             <div class="ul_wrap">
             <p style='font-size:10.0pt;;mso-list:l3 level1 lfo3;' class='MsoListParagraphCxSpFirst'>Example List</p>
             </div>
           </div>
           <div class='MsoNormal'  style='text-align:center;'>
             <a name='D' id='D'/>
             <p class='FigureTitle' style='text-align:center;'>Figure Title</p>
           </div>
           <p class='Code'>
             <a name='E' id='E'/>
             XYZ
           </p>
           <p class='Tabletitle' style='text-align:center;'>Table</p>
           <div align='center' class='table_container'>
             <table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
               <a name='F' id='F'/>
             </table>
           </div>
         </div>
         <p class='MsoNormal'>
           <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
         </p>
         <div class='Section3'>
           <a name='G' id='G'/>
           <p class='ANNEX'>Annex Title</p>
           <p class='AnnexTableTitle' style='text-align:center;'>Annex Table</p>
           <div align='center' class='table_container'>
             <table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
               <a name='H' id='H'/>
             </table>
           </div>
           <div>
             <a name='I' id='I'/>
             <p class='a2'>Annex Clause Title</p>
           </div>
         </div>
         <p class='MsoNormal'>
           <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
         </p>
         <div>
           <p class='BiblioTitle'>Bibliography</p>
           <p class='MsoNormal'>
             <a name='ISO712' id='ISO712'/>
             [1]
             <span style='mso-tab-count:1'>  </span>
             ISO/IEC 712-3:2022, ALUFFI, Paolo, ed. (2022).
             <i><span class="std_class">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</span></i>
             , 1st edition. Cambridge, UK: CUP.
           </p>
         </div>
       </div>
    WORD
    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
  end
end
