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
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <status><stage>50</stage></status>
          </bibdata>
          <sections>
          <terms id="A" displayorder="1">
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
      .new({ isowordtemplate: "dis" })
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <status><stage>30</stage></status>
          </bibdata>
          <sections>
          <terms id="A" displayorder="1">
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
    expect(xmlpp(Nokogiri::XML(output)
      .at("//div[@class = 'WordSection3']").to_xml))
      .to be_equivalent_to xmlpp(word)

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
        <foreword displayorder="1"><title>Foreword</title><p>Para</p></foreword>
        <introduction displayorder="2"><title>Foreword</title><p>Para</p></introduction>
        </preface>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class='WordSection2'>
         <div style='mso-element:para-border-div;border:solid windowtext 1.0pt; border-bottom-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt: solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:1.0pt 4.0pt 0cm 4.0pt; margin-left:5.1pt;margin-right:5.1pt'>
           <div>
             <a name='boilerplate-copyright-destination' id='boilerplate-copyright-destination'/>
           </div>
         </div>
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
      .at("//xmlns:div[@class = 'WordSection2']")
    expect(xmlpp(doc.to_xml))
      .to be_equivalent_to xmlpp(word)

    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <preface>
        <foreword displayorder="1"><title>Foreword</title><p>Para</p></foreword>
        <introduction displayorder="2"><title>Foreword</title><p>Para</p></introduction>
        </preface>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class='WordSection2'>
           <div>
             <a name='boilerplate-copyright-destination' id='boilerplate-copyright-destination'/>
         </div>
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
      .at("//xmlns:div[@class = 'WordSection2']")
    expect(xmlpp(doc.to_xml))
      .to be_equivalent_to xmlpp(word)
  end

  it "formats references" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
                <bibliography>
          <references id="_normative_references" normative="true" obligation="informative" displayorder="1">
            <title>Normative References</title>
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
    expect(xmlpp(doc.to_xml))
      .to be_equivalent_to xmlpp(word)
  end

  it "formats tt" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <preface>
        <foreword displayorder="1">
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
    expect(xmlpp(doc.to_xml))
      .to be_equivalent_to xmlpp(word)
  end

  it "formats tt with ad hoc smaller font" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <preface>
        <foreword displayorder="1">
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
    expect(xmlpp(doc.to_xml))
      .to be_equivalent_to xmlpp(word)
  end

  it "deals with lists" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A"><p>
        <ol>
        <li><p>A</p></li>
        <li><p>B</p></li>
        <li><ol>
        <li>C</li>
        <li>D</li>
        <li><ol>
        <li>E</li>
        <li>F</li>
        <li><ol>
        <li>G</li>
        <li>H</li>
        <li><ol>
        <li>I</li>
        <li>J</li>
        <li><ol>
        <li>K</li>
        <li>L</li>
        <li>M</li>
        </ol></li>
        <li>N</li>
        </ol></li>
        <li>O</li>
        </ol></li>
        <li>P</li>
        </ol></li>
        <li>Q</li>
        </ol></li>
        <li>R</li>
        </ol>
        <ul>
        <li><p>A</p></li>
        <li><p>B</p></li>
        <li><p>B1</p><ul>
        <li>C</li>
        <li>D</li>
        <li><ul>
        <li>E</li>
        <li>F</li>
        <li><ul>
        <li>G</li>
        <li>H</li>
        <li><ul>
        <li>I</li>
        <li>J</li>
        <li><ul>
        <li>K</li>
        <li>L</li>
        <li>M</li>
        </ul></li>
        <li>N</li>
        </ul></li>
        <li>O</li>
        </ul></li>
        <li>P</li>
        </ul></li>
        <li>Q</li>
        </ul></li>
        <li>R</li>
        </ul>
        </p></clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
        <div class="WordSection3">
          <div>
            <a name="A" id="A"/>
            <h1>1</h1>
            <p class="MsoBodyText">
              <div class="ol_wrap">
                <p class="ListNumber1">a)<span style="mso-tab-count:1"> </span>A</p>
                <p class="ListNumber1">b)<span style="mso-tab-count:1"> </span>B</p>
                <p class="MsoNormal">
                  <a name="_" id="_"/>
                  <div class="ol_wrap">
                    <p class="MsoListNumber2"><a name="_" id="_"/>1)<span style="mso-tab-count:1"> </span>C</p>
                    <p class="MsoListNumber2"><a name="_" id="_"/>2)<span style="mso-tab-count:1"> </span>D</p>
                    <p class="MsoNormal">
                      <a name="_" id="_"/>
                      <div class="ol_wrap">
                        <p class="MsoListNumber3"><a name="_" id="_"/>i)<span style="mso-tab-count:1"> </span>E</p>
                        <p class="MsoListNumber3"><a name="_" id="_"/>ii)<span style="mso-tab-count:1"> </span>F</p>
                        <p class="MsoNormal">
                          <a name="_" id="_"/>
                          <div class="ol_wrap">
                            <p class="MsoListNumber4"><a name="_" id="_"/>A)<span style="mso-tab-count:1"> </span>G</p>
                            <p class="MsoListNumber4"><a name="_" id="_"/>B)<span style="mso-tab-count:1"> </span>H</p>
                            <p class="MsoNormal">
                              <a name="_" id="_"/>
                              <div class="ol_wrap">
                                <p class="MsoListNumber5"><a name="_" id="_"/>I)<span style="mso-tab-count:1"> </span>I</p>
                                <p class="MsoListNumber5"><a name="_" id="_"/>II)<span style="mso-tab-count:1"> </span>J</p>
                                <p class="MsoNormal">
                                  <a name="_" id="_"/>
                                  <div class="ol_wrap">
                                    <p class="MsoListNumber5"><a name="_" id="_"/>a)<span style="mso-tab-count:1"> </span>K</p>
                                    <p class="MsoListNumber5"><a name="_" id="_"/>b)<span style="mso-tab-count:1"> </span>L</p>
                                    <p class="MsoListNumber5"><a name="_" id="_"/>c)<span style="mso-tab-count:1"> </span>M</p>
                                  </div>
                                </p>
                                <p class="MsoListNumber5"><a name="_" id="_"/>III)<span style="mso-tab-count:1"> </span>N</p>
                              </div>
                            </p>
                            <p class="MsoListNumber4"><a name="_" id="_"/>C)<span style="mso-tab-count:1"> </span>O</p>
                          </div>
                        </p>
                        <p class="MsoListNumber3"><a name="_" id="_"/>iii)<span style="mso-tab-count:1"> </span>P</p>
                      </div>
                    </p>
                    <p class="MsoListNumber2"><a name="_" id="_"/>3)<span style="mso-tab-count:1"> </span>Q</p>
                  </div>
                </p>
                <p class="ListNumber1"><a name="_" id="_"/>c)<span style="mso-tab-count:1"> </span>R</p>
              </div>
              <div class="ul_wrap">
                <p class="ListContinue1">—<span style="mso-tab-count:1"> </span>A</p>
                <p class="ListContinue1">—<span style="mso-tab-count:1"> </span>B</p>
                <p class="ListContinue1">
                  <p class="ListContinue1">—<span style="mso-tab-count:1"> </span>B1</p>
                  <div class="ListContLevel1">
                    <div class="ul_wrap">
                      <p class="MsoListContinue2">—<span style="mso-tab-count:1"> </span>C</p>
                      <p class="MsoListContinue2">—<span style="mso-tab-count:1"> </span>D</p>
                      <p class="MsoNormal">
                        <div class="ul_wrap">
                          <p class="MsoListContinue3">—<span style="mso-tab-count:1"> </span>E</p>
                          <p class="MsoListContinue3">—<span style="mso-tab-count:1"> </span>F</p>
                          <p class="MsoNormal">
                            <div class="ul_wrap">
                              <p class="MsoListContinue4">—<span style="mso-tab-count:1"> </span>G</p>
                              <p class="MsoListContinue4">—<span style="mso-tab-count:1"> </span>H</p>
                              <p class="MsoNormal">
                                <div class="ul_wrap">
                                  <p class="MsoListContinue5">—<span style="mso-tab-count:1"> </span>I</p>
                                  <p class="MsoListContinue5">—<span style="mso-tab-count:1"> </span>J</p>
                                  <p class="MsoNormal">
                                    <div class="ul_wrap">
                                      <p class="MsoListContinue5">—<span style="mso-tab-count:1"> </span>K</p>
                                      <p class="MsoListContinue5">—<span style="mso-tab-count:1"> </span>L</p>
                                      <p class="MsoListContinue5">—<span style="mso-tab-count:1"> </span>M</p>
                                    </div>
                                  </p>
                                  <p class="MsoListContinue5">—<span style="mso-tab-count:1"> </span>N</p>
                                </div>
                              </p>
                              <p class="MsoListContinue4">—<span style="mso-tab-count:1"> </span>O</p>
                            </div>
                          </p>
                          <p class="MsoListContinue3">—<span style="mso-tab-count:1"> </span>P</p>
                        </div>
                      </p>
                      <p class="MsoListContinue2">—<span style="mso-tab-count:1"> </span>Q</p>
                    </div>
                  </div>
                </p>
                <p class="ListContinue1">—<span style="mso-tab-count:1"> </span>R</p>
              </div>
            </p>
          </div>
        </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(xmlpp(strip_guid(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
  end

  it "deals with lists types" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A"><p>
        <ol type="arabic">
        <li><p>A</p></li>
        <li><ol type="alphabet_upper">
        <li>C</li>
        <li><ol type="roman_upper">
        <li>E</li>
        <li><ol type="roman">
        <li>G</li>
        <li><ol type="alphabet">
        <li>I</li>
        <li><ol type="roman_upper">
        <li>K</li>
        </ol></li>
        <li>N</li>
        </ol></li>
        <li>O</li>
        </ol></li>
        <li>P</li>
        </ol></li>
        <li>Q</li>
        </ol></li>
        <li>R</li>
        </ol>
        </p></clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class="WordSection3">
          <div>
            <a name="A" id="A"/>
            <h1>1</h1>
            <p class="MsoBodyText">
              <div class="ol_wrap">
                <p class="ListNumber1">1)<span style="mso-tab-count:1"> </span>A</p>
                <p class="MsoNormal">
                  <a name="_" id="_"/>
                  <div class="ol_wrap">
                    <p class="MsoListNumber2"><a name="_" id="_"/>A)<span style="mso-tab-count:1"> </span>C</p>
                    <p class="MsoNormal">
                      <a name="_" id="_"/>
                      <div class="ol_wrap">
                        <p class="MsoListNumber3"><a name="_" id="_"/>I)<span style="mso-tab-count:1"> </span>E</p>
                        <p class="MsoNormal">
                          <a name="_" id="_"/>
                          <div class="ol_wrap">
                            <p class="MsoListNumber4"><a name="_" id="_"/>i)<span style="mso-tab-count:1"> </span>G</p>
                            <p class="MsoNormal">
                              <a name="_" id="_"/>
                              <div class="ol_wrap">
                                <p class="MsoListNumber5"><a name="_" id="_"/>a)<span style="mso-tab-count:1"> </span>I</p>
                                <p class="MsoNormal">
                                  <a name="_" id="_"/>
                                  <div class="ol_wrap">
                                    <p class="MsoListNumber5"><a name="_" id="_"/>I)<span style="mso-tab-count:1"> </span>K</p>
                                  </div>
                                </p>
                                <p class="MsoListNumber5"><a name="_" id="_"/>b)<span style="mso-tab-count:1"> </span>N</p>
                              </div>
                            </p>
                            <p class="MsoListNumber4"><a name="_" id="_"/>ii)<span style="mso-tab-count:1"> </span>O</p>
                          </div>
                        </p>
                        <p class="MsoListNumber3"><a name="_" id="_"/>II)<span style="mso-tab-count:1"> </span>P</p>
                      </div>
                    </p>
                    <p class="MsoListNumber2"><a name="_" id="_"/>B)<span style="mso-tab-count:1"> </span>Q</p>
                  </div>
                </p>
                <p class="ListNumber1"><a name="_" id="_"/>2)<span style="mso-tab-count:1"> </span>R</p>
              </div>
            </p>
          </div>
        </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(xmlpp(strip_guid(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
  end

  it "deals with lists and paragraphs" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
        <status><stage>50</stage></status>
      </bibdata>
      <sections>
      <clause id="A">
      <p id="_eb2fd8cd-5cbe-1f1f-7bdb-282868a25828">ISO and IEC maintain terminological databases for use in
      standardization at the following addresses:</p>

      <ul id="_6f8dbb84-61d9-f774-264e-b7e249cf44d1">
      <li> <p id="_9f56356a-3a58-64c4-e59e-a23ca3da7e88">ISO Online browsing platform: available at
        <link target="https://www.iso.org/obp"/></p></li>
      <li> <p id="_5dc6886f-a99c-e420-a29d-2aa6ca9f376e">IEC Electropedia: available at
      <link target="https://www.electropedia.org"/>
      </p> </li> </ul>
      </clause>
      </sections>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class='WordSection3'>
         <div>
           <a name='A' id='A'/>
           <h1>1</h1>
           <p class='MsoBodyText'>
             <a name='_eb2fd8cd-5cbe-1f1f-7bdb-282868a25828' id='_eb2fd8cd-5cbe-1f1f-7bdb-282868a25828'/>
             ISO and IEC maintain terminological databases for use in standardization
             at the following addresses:
           </p>
           <div class="ul_wrap">
           <p class='ListContinue1'>
             —
             <span style='mso-tab-count:1'> </span>
               ISO Online browsing platform: available at
               <a href='https://www.iso.org/obp'>https://www.iso.org/obp</a>
           </p>
           <p class='ListContinue1'>
             —
             <span style='mso-tab-count:1'> </span>
               IEC Electropedia: available at
               <a href='https://www.electropedia.org'>https://www.electropedia.org</a>
           </p>
           </div>
         </div>
       </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml))
      .to be_equivalent_to xmlpp(word)
  end

  it "deals with ordered list start" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A"><p>
        <ol start="3">
        <li><p>A</p></li>
        <li><p>B</p></li>
        <li><ol start="3">
        <li>C</li>
        <li>D</li>
        <li><ol start="3">
        <li>E</li>
        <li>F</li>
        <li><ol start="3">
        <li>G</li>
        <li>H</li>
        <li><ol start="3">
        <li>I</li>
        <li>J</li>
        <li><ol start="3">
        <li>K</li>
        <li>L</li>
        <li>M</li>
        </ol></li>
        <li>N</li>
        </ol></li>
        <li>O</li>
        </ol></li>
        <li>P</li>
        </ol></li>
        <li>Q</li>
        </ol></li>
        <li>R</li>
        </ol>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
      <div class="WordSection3">
        <div>
          <a name="A" id="A"/>
          <h1>1</h1>
          <p class="MsoBodyText">
            <div class="ol_wrap">
              <p class="ListNumber1">c)<span style="mso-tab-count:1"> </span>A</p>
              <p class="ListNumber1">d)<span style="mso-tab-count:1"> </span>B</p>
              <p class="MsoNormal">
                <a name="_" id="_"/>
                <div class="ol_wrap">
                  <p class="MsoListNumber2"><a name="_" id="_"/>3)<span style="mso-tab-count:1"> </span>C</p>
                  <p class="MsoListNumber2"><a name="_" id="_"/>4)<span style="mso-tab-count:1"> </span>D</p>
                  <p class="MsoNormal">
                    <a name="_" id="_"/>
                    <div class="ol_wrap">
                      <p class="MsoListNumber3"><a name="_" id="_"/>iii)<span style="mso-tab-count:1"> </span>E</p>
                      <p class="MsoListNumber3"><a name="_" id="_"/>iv)<span style="mso-tab-count:1"> </span>F</p>
                      <p class="MsoNormal">
                        <a name="_" id="_"/>
                        <div class="ol_wrap">
                          <p class="MsoListNumber4"><a name="_" id="_"/>C)<span style="mso-tab-count:1"> </span>G</p>
                          <p class="MsoListNumber4"><a name="_" id="_"/>D)<span style="mso-tab-count:1"> </span>H</p>
                          <p class="MsoNormal">
                            <a name="_" id="_"/>
                            <div class="ol_wrap">
                              <p class="MsoListNumber5"><a name="_" id="_"/>III)<span style="mso-tab-count:1"> </span>I</p>
                              <p class="MsoListNumber5"><a name="_" id="_"/>IV)<span style="mso-tab-count:1"> </span>J</p>
                              <p class="MsoNormal">
                                <a name="_" id="_"/>
                                <div class="ol_wrap">
                                  <p class="MsoListNumber5"><a name="_" id="_"/>c)<span style="mso-tab-count:1"> </span>K</p>
                                  <p class="MsoListNumber5"><a name="_" id="_"/>d)<span style="mso-tab-count:1"> </span>L</p>
                                  <p class="MsoListNumber5"><a name="_" id="_"/>e)<span style="mso-tab-count:1"> </span>M</p>
                                </div>
                              </p>
                              <p class="MsoListNumber5"><a name="_" id="_"/>V)<span style="mso-tab-count:1"> </span>N</p>
                            </div>
                          </p>
                          <p class="MsoListNumber4"><a name="_" id="_"/>E)<span style="mso-tab-count:1"> </span>O</p>
                        </div>
                      </p>
                      <p class="MsoListNumber3"><a name="_" id="_"/>v)<span style="mso-tab-count:1"> </span>P</p>
                    </div>
                  </p>
                  <p class="MsoListNumber2"><a name="_" id="_"/>5)<span style="mso-tab-count:1"> </span>Q</p>
                </div>
              </p>
              <p class="ListNumber1"><a name="_" id="_"/>e)<span style="mso-tab-count:1"> </span>R</p>
            </div>
          </p>
        </div>
      </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    expect(xmlpp(strip_guid(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
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
        <name>Table1</name>
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
                  <th style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                    <div class="Tablebody" style="page-break-after:auto">E</div>
                  </th>
                  <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                    <p class="Tablebody" style="page-break-after:auto">F</p>
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>
          <div align="center" class="table_container">
            <table class="rouge-line-table" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;">
              <tbody>
                <tr>
                  <td style="page-break-after:avoid;" class="rouge-gutter gl">
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
                  <td style="page-break-after:auto;" class="rouge-gutter gl">
                    <div class="Tablebody" style="page-break-after:auto">
                      <pre style="page-break-after:auto">2</pre>
                    </div>
                  </td>
                  <td style="page-break-after:auto;" class="rouge-code">
                    <p class="Code" style="page-break-after:auto">
                      <span class="w">  </span>
                      <span class="nl">"$schema"</span>
                      <span class="p">:</span>
                      <span class="w"/>
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
    expect(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml))
      .to be_equivalent_to xmlpp(word)
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
        <name>Table1</name>
        <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto"/>
        <note id="C"><name>FIGURENOTE</name><p>Note</p></note>
        <example id="D"><p>Example</p></example>
        </figure>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class='WordSection3'>
        <div>
          <a name='A' id='A'/>
          <h1/>
          <div class='figure'>
            <a name='B' id='B'/>
            <p class='FigureGraphic'>
              <img src='_.gif' height='20' width='20'/>
            </p>
            <div class='Figurenote'>
              <a name='C' id='C'/>
              <p class='Figurenote'>
                FIGURENOTE
                <span style='mso-tab-count:1'>  </span>
                Note
              </p>
            </div>
            <div class="Figureexample" style='page-break-after:avoid;'>
              <a name='D' id='D'/>
              <p class='Figureexample'>
                <span style='mso-tab-count:1'>  </span>
                Example
              </p>
            </div>
            <p class='Figuretitle' style='text-align:center;'>Table1</p>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
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
        <name>EXAMPLE</name>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
  end

  it "deals with formulas" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A" displayorder="1">
        <formula id="B"><name>A.1</name><stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow><mi>S</mi></mrow><mrow><mrow><mi>s</mi><mi>l</mi><mo>,</mo><mo>max</mo></mrow></mrow></msub><mo>=</mo><mo>⌊</mo><mrow><mfrac><mrow><mrow><msub><mrow><mi>L</mi></mrow><mrow><mo>max</mo></mrow></msub><mo>×</mo><msub><mrow><mi>N</mi></mrow><mrow><mrow><mi>b</mi><mi>p</mi><mi>p</mi></mrow></mrow></msub></mrow></mrow><mrow><mn>8</mn></mrow></mfrac></mrow><mo> </mo><mo>⌋</mo></math><!-- (S)_((s l , max)) = |__ (((L)_((max)) xx (N)_((b p p))))/((8))  __| --><asciimath>S_{sl,max} = |__ {: { L_{:max:} xx N_{bpp} :} / 8 :}  __|</asciimath></stem></formula>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
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
        <name>NOTE</name>
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
               <span style='mso-tab-count:1'>  </span>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
  end

  it "deals with unordered lists embedded within notes and examples" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A">
        <note id="B">
        <ul>
        <li><p>A</p></li>
        <li><p>B</p></li>
        <li><ul>
        <li>C</li>
        <li>D</li>
        <li><ul>
        <li>E</li>
        <li>F</li>
        <li><ul>
        <li>G</li>
        <li>H</li>
        <li><ul>
        <li>I</li>
        <li>J</li>
        <li><ul>
        <li>K</li>
        <li>L</li>
        <li>M</li>
        </ul></li>
        <li>N</li>
        </ul></li>
        <li>O</li>
        </ul></li>
        <li>P</li>
        </ul></li>
        <li>Q</li>
        </ul></li>
        <li>R</li>
        </ul>
        </note>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class="WordSection3">
          <div>
            <a name="A" id="A"/>
            <h1>1</h1>
            <div>
              <a name="B" id="B"/>
              <p class="Note">NOTE<span style="mso-tab-count:1">  </span></p>
              <div class="ul_wrap">
                <p class="ListContinue2-">—<span style="mso-tab-count:1"> </span>A</p>
                <p class="ListContinue2-">—<span style="mso-tab-count:1"> </span>B</p>
                <p class="MsoNormal">
                  <div class="ul_wrap">
                    <p class="ListContinue3-">—<span style="mso-tab-count:1"> </span>C</p>
                    <p class="ListContinue3-">—<span style="mso-tab-count:1"> </span>D</p>
                    <p class="MsoNormal">
                      <div class="ul_wrap">
                        <p class="ListContinue4-">—<span style="mso-tab-count:1"> </span>E</p>
                        <p class="ListContinue4-">—<span style="mso-tab-count:1"> </span>F</p>
                        <p class="MsoNormal">
                          <div class="ul_wrap">
                            <p class="ListContinue5-">—<span style="mso-tab-count:1"> </span>G</p>
                            <p class="ListContinue5-">—<span style="mso-tab-count:1"> </span>H</p>
                            <p class="MsoNormal">
                              <div class="ul_wrap">
                                <p class="ListContinue5-">—<span style="mso-tab-count:1"> </span>I</p>
                                <p class="ListContinue5-">—<span style="mso-tab-count:1"> </span>J</p>
                                <p class="MsoNormal">
                                  <div class="ul_wrap">
                                    <p class="ListContinue5-">—<span style="mso-tab-count:1"> </span>K</p>
                                    <p class="ListContinue5-">—<span style="mso-tab-count:1"> </span>L</p>
                                    <p class="ListContinue5-">—<span style="mso-tab-count:1"> </span>M</p>
                                  </div>
                                </p>
                                <p class="ListContinue5-">—<span style="mso-tab-count:1"> </span>N</p>
                              </div>
                            </p>
                            <p class="ListContinue5-">—<span style="mso-tab-count:1"> </span>O</p>
                          </div>
                        </p>
                        <p class="ListContinue4-">—<span style="mso-tab-count:1"> </span>P</p>
                      </div>
                    </p>
                    <p class="ListContinue3-">—<span style="mso-tab-count:1"> </span>Q</p>
                  </div>
                </p>
                <p class="ListContinue2-">—<span style="mso-tab-count:1"> </span>R</p>
              </div>
            </div>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
  end

  it "deals with ordered lists embedded within notes and examples" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A">
        <example id="B">
                <ol>
        <li><p>A</p></li>
        <li><p>B</p></li>
        <li><ol>
        <li>C</li>
        <li>D</li>
        <li><ol>
        <li>E</li>
        <li>F</li>
        <li><ol>
        <li>G</li>
        <li>H</li>
        <li><ol>
        <li>I</li>
        <li>J</li>
        <li><ol>
        <li>K</li>
        <li>L</li>
        <li>M</li>
        </ol></li>
        <li>N</li>
        </ol></li>
        <li>O</li>
        </ol></li>
        <li>P</li>
        </ol></li>
        <li>Q</li>
        </ol></li>
        <li>R</li>
        </ol>
        </example>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class="WordSection3">
          <div>
            <a name="A" id="A"/>
            <h1>1</h1>
            <div>
              <a name="B" id="B"/>
              <p class="Example">EXAMPLE<span style="mso-tab-count:1">  </span></p>
              <div class="ol_wrap">
                <p class="ListNumber2-">a)<span style="mso-tab-count:1"> </span>A</p>
                <p class="ListNumber2-">b)<span style="mso-tab-count:1"> </span>B</p>
                <p class="MsoNormal">
                  <a name="_" id="_"/>
                  <div class="ol_wrap">
                    <p class="ListNumber3-"><a name="_" id="_"/>1)<span style="mso-tab-count:1"> </span>C</p>
                    <p class="ListNumber3-"><a name="_" id="_"/>2)<span style="mso-tab-count:1"> </span>D</p>
                    <p class="MsoNormal">
                      <a name="_" id="_"/>
                      <div class="ol_wrap">
                        <p class="ListNumber4-"><a name="_" id="_"/>i)<span style="mso-tab-count:1"> </span>E</p>
                        <p class="ListNumber4-"><a name="_" id="_"/>ii)<span style="mso-tab-count:1"> </span>F</p>
                        <p class="MsoNormal">
                          <a name="_" id="_"/>
                          <div class="ol_wrap">
                            <p class="ListNumber5-"><a name="_" id="_"/>A)<span style="mso-tab-count:1"> </span>G</p>
                            <p class="ListNumber5-"><a name="_" id="_"/>B)<span style="mso-tab-count:1"> </span>H</p>
                            <p class="MsoNormal">
                              <a name="_" id="_"/>
                              <div class="ol_wrap">
                                <p class="ListNumber5-"><a name="_" id="_"/>I)<span style="mso-tab-count:1"> </span>I</p>
                                <p class="ListNumber5-"><a name="_" id="_"/>II)<span style="mso-tab-count:1"> </span>J</p>
                                <p class="MsoNormal">
                                  <a name="_" id="_"/>
                                  <div class="ol_wrap">
                                    <p class="ListNumber5-"><a name="_" id="_"/>a)<span style="mso-tab-count:1"> </span>K</p>
                                    <p class="ListNumber5-"><a name="_" id="_"/>b)<span style="mso-tab-count:1"> </span>L</p>
                                    <p class="ListNumber5-"><a name="_" id="_"/>c)<span style="mso-tab-count:1"> </span>M</p>
                                  </div>
                                </p>
                                <p class="ListNumber5-"><a name="_" id="_"/>III)<span style="mso-tab-count:1"> </span>N</p>
                              </div>
                            </p>
                            <p class="ListNumber5-"><a name="_" id="_"/>C)<span style="mso-tab-count:1"> </span>O</p>
                          </div>
                        </p>
                        <p class="ListNumber4-"><a name="_" id="_"/>iii)<span style="mso-tab-count:1"> </span>P</p>
                      </div>
                    </p>
                    <p class="ListNumber3-"><a name="_" id="_"/>3)<span style="mso-tab-count:1"> </span>Q</p>
                  </div>
                </p>
                <p class="ListNumber2-"><a name="_" id="_"/>c)<span style="mso-tab-count:1"> </span>R</p>
              </div>
            </div>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
  end

  it "ignores intervening ul in numbering ol" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A">
      <ul>
      <li>A</li>
      <li>
      <ol>
      <li>List</li>
      <li>
      <ul>
      <li>B</li>
      <li>
      <ol>
      <li>List 2</li>
      </ol>
      </li>
      </ul>
      </li>
      </ol>
      </li>
      </ul>
      </clause></sections>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class="WordSection3">
          <div>
            <a name="A" id="A"/>
            <h1>1</h1>
            <div class="ul_wrap">
              <p class="ListContinue1">—<span style="mso-tab-count:1"> </span>A</p>
              <p class="MsoNormal">
                <div class="ol_wrap">
                  <p class="MsoListNumber2"><a name="_" id="_"/>a)<span style="mso-tab-count:1"> </span>List</p>
                  <p class="MsoNormal">
                    <a name="_" id="_"/>
                    <div class="ul_wrap">
                      <p class="MsoListContinue3">—<span style="mso-tab-count:1"> </span>B</p>
                      <p class="MsoNormal">
                        <div class="ol_wrap">
                          <p class="MsoListNumber4"><a name="_" id="_"/>1)<span style="mso-tab-count:1"> </span>List 2</p>
                        </div>
                      </p>
                    </div>
                  </p>
                </div>
              </p>
            </div>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
  end

  it "deals with definition lists embedded within notes and examples" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A" displayorder="1">
        <example id="B">
        <name>EXAMPLE</name>
        <dl>
        <dt>A</dt><dd>B</dd>
        </dl>
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
            </p>
            <table class='dl' style='margin-left: 1cm;'>
              <tr>
                <td valign='top' align='left'>
                  <p align='left' style='margin-left:0pt;text-align:left;' class='Tablebody'>A</p>
                </td>
                <td valign='top'>
                  <div class='Tablebody'>B</div>
                </td>
              </tr>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
  end

  it "deals with annexes" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <annex id="A" displayorder="1"><title>Annex</title>
        <clause id="B"><title>Subannex</title>
        <clause id="C"><title>Subsubannex</title>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
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
                 <span style='mso-tab-count:1'>  </span>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
  end

  it "deals with title" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
        <title language="en" format="text/plain" type="title-intro">Date and time</title>
          <title language="en" format="text/plain" type="title-main">Representations for information interchange</title>
        <title language="en" format="text/plain" type="title-part">Basic rules</title>
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
          <h1>1<span style="mso-tab-count:1">  </span>First clause</h1>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection1']").to_xml)))
      .to be_equivalent_to xmlpp(title)
  end

  it "deals with amendments" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
        <title language="en" format="text/plain" type="title-intro">Date and time</title>
          <title language="en" format="text/plain" type="title-main">Representations for information interchange</title>
        <title language="en" format="text/plain" type="title-part">Basic rules</title>
        <title language="en" format="text/plain" type="title-amd">Technical corrections</title>
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
        <foreword id="F" displayorder="1"><title>Foreword</title></foreword>
        </preface>
         <sections>
        <clause id="A" displayorder="2"><title>First clause</title>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
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
            <clause><title>COPYRIGHT PROTECTED DOCUMENT</title>
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

    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new(wordstylesheet: "spec/assets/word.css")
      .convert("test", presxml, false)
    word = File.read("test.doc", encoding: "UTF-8")
    expect(xmlpp(word
      .sub(%r{^.*<div class="boilerplate-copyright">}m,
           '<div class="boilerplate-copyright">')
      .sub(%r{</div>.*$}m, "</div></div>")))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
        <div class='boilerplate-copyright'>
          <div>
            <p class='zzCopyright'>
              <a name='boilerplate-year' id='boilerplate-year'/>
              © ISO 2019, Published in Switzerland
            </p>
            <p class='zzCopyright'>
              <a name='boilerplate-message' id='boilerplate-message'/>
              I am the Walrus.
            </p>
            <p class='zzCopyright'>
              <a name='boilerplate-name' id='boilerplate-name'/>
              ISO copyright office
            </p>
            <p style='text-align:left;' align='left' class='zzCopyright'>
              <a name='boilerplate-address' id='boilerplate-address'/>
              ISO copyright office
            </p>
            <p class='zzCopyright'> Ch. de Blandonnet 8 ?~@? CP 401 </p>
            <p class='zzCopyright'> CH-1214 Vernier, Geneva, Switzerland </p>
            <p class='zzCopyright'> Phone: +41 22 749 01 11 </p>
            <p class='zzCopyright'> Email: copyright@iso.org </p>
            <p class='zzCopyright'> www.iso.org</p>
          </div>
        </div>
      OUTPUT

    FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new(wordstylesheet: "spec/assets/word.css")
      .convert("test",
               presxml.sub(%r{<stage language="">50</stage>},
                           "<stage>60</stage><substage>00</substage>"), false)
    word = File.read("test.doc", encoding: "UTF-8")
    expect(xmlpp(word
      .sub(%r{^.*<div class="boilerplate-copyright">}m,
           '<div class="boilerplate-copyright">')
      .sub(%r{</div>.*$}m, "</div></div>")))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
        <div class='boilerplate-copyright'>
          <div>
            <p class='zzCopyright'>
              <a name='boilerplate-year' id='boilerplate-year'/>
              © ISO 2019, Published in Switzerland
            </p>
            <p class='zzCopyright'>
              <a name='boilerplate-message' id='boilerplate-message'/>
              I am the Walrus.
            </p>
            <p class='zzCopyright'>
              <a name='boilerplate-name' id='boilerplate-name'/>
              ISO copyright office
            </p>
            <p style='text-indent:20.15pt;' align='left' class='zzCopyright'>
              <a name='boilerplate-address' id='boilerplate-address'/>
              ISO copyright office
            </p>
            <p class='zzCopyright' style='text-indent:20.15pt;'> Ch. de Blandonnet 8 ?~@? CP 401 </p>
            <p class='zzCopyright' style='text-indent:20.15pt;'> CH-1214 Vernier, Geneva, Switzerland </p>
            <p class='zzCopyright' style='text-indent:20.15pt;'> Phone: +41 22 749 01 11 </p>
            <p class='zzCopyright' style='text-indent:20.15pt;'> Email: copyright@iso.org </p>
            <p class='zzCopyright' style='text-indent:20.15pt;'> www.iso.org</p>
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
        <clause id="A" displayorder="1"><title>Clause Title</title>
        <ul><li>List</li></ul>
        <note id="B"><p>Note</p>
        <ul><li>Note List</li></ul>
        </note>
        <example id="C"><p>Example</p>
        <ul><li>Example List</li></ul>
        </example>
        <figure id="D"><name>Figure Title</name></figure>
        <sourcecode id="E">XYZ</sourcecode>
        <table id="F"><name>Table</name></table>
        </clause>
        </sections>
        <annex id="G" displayorder="2"><title>Annex Title</title>
        <table id="H"><name>Annex Table</name></table>
        <clause id="I"><title>Annex Clause Title</title>
        </clause>
        </annex>
        <bibliography>
        <references id="_normative_references" normative="false" obligation="informative" displayorder="3">
            <title>Bibliography</title>
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
               <span class='note_label'/>
               <span style='mso-tab-count:1'>  </span>
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
    expect(strip_guid(xmlpp(Nokogiri::XML(output)
      .at("//xmlns:div[@class = 'WordSection3']").to_xml)))
      .to be_equivalent_to xmlpp(word)
  end
end
