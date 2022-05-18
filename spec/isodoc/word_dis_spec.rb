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
        <p class='zzSTDTitle'/>
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
         <p class='zzContents'>
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

  it "formats references" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
                <bibliography>
          <references id="_normative_references" normative="true" obligation="informative">
            <title>Normative References</title>
            <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
            <bibitem id="ISO712" type="standard">
            <formattedref>ALUFFI, Paolo, ed. (2022). <em><span class="std_class">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</span></em>, 1st edition. Cambridge, UK: CUP.</formattedref>
            <docidentifier type="ISO">ISO/IEC 712-3:2022</docidentifier>
            </bibitem>
        </references>
        </bibliography>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
             <div class='WordSection3'>
        <p class='zzSTDTitle'/>
        <div>
          <h1>Normative References</h1>
          <p class='MsoBodyText'>
            The following documents are referred to in the text in such a way that
            some or all of their content constitutes requirements of this document.
            For dated references, only the edition cited applies. For undated
            references, the latest edition of the referenced document (including any
            amendments) applies.
          </p>
          <p class='RefNorm'>
            <a name='ISO712' id='ISO712'/>
            <span class='stdpublisher'>ISO/IEC</span> <span class='stddocNumber'>712</span>-<span class='stddocPartNumber'>3</span>:<span class='stdyear'>2022</span>, ALUFFI, Paolo, ed. (2022).
            <i>
              <span class='std_class'>
                Facets of Algebraic Geometry: A Collection in Honor of William
                Fulton's 80th Birthday
              </span>
            </i>
            , 1st edition. Cambridge, UK: CUP.
          </p>
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
        <foreword>
        <p><tt>A <strong>B</strong> <em>C</em> <strong>D<em>E</em>F</strong> <em>G<strong>H</strong>I</em></tt></p>
        <p><strong>A <tt>B</tt> <em>C<tt>D</tt>E</em></strong></p>
        <p><em>A <tt>B</tt> <strong>C<tt>D</tt>E</strong></em></p>
        </foreword>
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
        <p class='zzContents'>
          <span lang='EN-GB' xml:lang='EN-GB'>Contents</span>
        </p>
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
      .xpath("//xmlns:p[@class = 'MsoToc1']").each(&:remove)
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
        </p></clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~OUTPUT
          <div class='WordSection3'>
        <p class='zzSTDTitle'/>
        <div>
          <a name='A' id='A'/>
          <h1/>
          <p class='MsoBodyText'>
            <p class='ListNumber1'>
              a)
              <span style='mso-tab-count:1'> </span>
              A
            </p>
            <p class='ListNumber1'>
              b)
              <span style='mso-tab-count:1'> </span>
              B
            </p>
            <p class='MsoListNumber2'>
              1)
              <span style='mso-tab-count:1'> </span>
              C
            </p>
            <p class='MsoListNumber2'>
              2)
              <span style='mso-tab-count:1'> </span>
              D
            </p>
            <p class='MsoListNumber3'>
              i)
              <span style='mso-tab-count:1'> </span>
              E
            </p>
            <p class='MsoListNumber3'>
              ii)
              <span style='mso-tab-count:1'> </span>
              F
            </p>
            <p class='MsoListNumber4'>
              A)
              <span style='mso-tab-count:1'> </span>
              G
            </p>
            <p class='MsoListNumber4'>
              B)
              <span style='mso-tab-count:1'> </span>
              H
            </p>
            <p class='MsoListNumber5'>
              I)
              <span style='mso-tab-count:1'> </span>
              I
            </p>
            <p class='MsoListNumber5'>
              II)
              <span style='mso-tab-count:1'> </span>
              J
            </p>
            <p class='MsoListNumber5'>
              a)
              <span style='mso-tab-count:1'> </span>
              K
            </p>
            <p class='MsoListNumber5'>
              b)
              <span style='mso-tab-count:1'> </span>
              L
            </p>
            <p class='MsoListNumber5'>
              c)
              <span style='mso-tab-count:1'> </span>
              M
            </p>
            <p class='MsoListNumber5'>
              III)
              <span style='mso-tab-count:1'> </span>
              N
            </p>
            <p class='MsoListNumber4'>
              C)
              <span style='mso-tab-count:1'> </span>
              O
            </p>
            <p class='MsoListNumber3'>
              iii)
              <span style='mso-tab-count:1'> </span>
              P
            </p>
            <p class='MsoListNumber2'>
              3)
              <span style='mso-tab-count:1'> </span>
              Q
            </p>
            <p class='ListNumber1'>
              c)
              <span style='mso-tab-count:1'> </span>
              R
            </p>
            <p class='ListContinue1'>
              —
              <span style='mso-tab-count:1'> </span>
              A
            </p>
            <p class='ListContinue1'>
              —
              <span style='mso-tab-count:1'> </span>
              B
            </p>
            <p class='MsoListContinue2'>
              —
              <span style='mso-tab-count:1'> </span>
              C
            </p>
            <p class='MsoListContinue2'>
              —
              <span style='mso-tab-count:1'> </span>
              D
            </p>
            <p class='MsoListContinue3'>
              —
              <span style='mso-tab-count:1'> </span>
              E
            </p>
            <p class='MsoListContinue3'>
              —
              <span style='mso-tab-count:1'> </span>
              F
            </p>
            <p class='MsoListContinue4'>
              —
              <span style='mso-tab-count:1'> </span>
              G
            </p>
            <p class='MsoListContinue4'>
              —
              <span style='mso-tab-count:1'> </span>
              H
            </p>
            <p class='MsoListContinue5'>
              —
              <span style='mso-tab-count:1'> </span>
              I
            </p>
            <p class='MsoListContinue5'>
              —
              <span style='mso-tab-count:1'> </span>
              J
            </p>
            <p class='MsoListContinue5'>
              —
              <span style='mso-tab-count:1'> </span>
              K
            </p>
            <p class='MsoListContinue5'>
              —
              <span style='mso-tab-count:1'> </span>
              L
            </p>
            <p class='MsoListContinue5'>
              —
              <span style='mso-tab-count:1'> </span>
              M
            </p>
            <p class='MsoListContinue5'>
              —
              <span style='mso-tab-count:1'> </span>
              N
            </p>
            <p class='MsoListContinue4'>
              —
              <span style='mso-tab-count:1'> </span>
              O
            </p>
            <p class='MsoListContinue3'>
              —
              <span style='mso-tab-count:1'> </span>
              P
            </p>
            <p class='MsoListContinue2'>
              —
              <span style='mso-tab-count:1'> </span>
              Q
            </p>
            <p class='ListContinue1'>
              —
              <span style='mso-tab-count:1'> </span>
              R
            </p>
          </p>
        </div>
      </div>
    OUTPUT
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

  it "deals with tables" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A">
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
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class='WordSection3'>
         <p class='zzSTDTitle'/>
         <div>
           <a name='A' id='A'/>
           <h1/>
           <p class='Tabletitle' style='text-align:center;'>Table1</p>
           <div align='center' class='table_container'>
             <table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
               <a name='B' id='B'/>
               <thead>
                 <tr>
                   <th style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' align='center' valign='middle'>
                     <div class='Tableheader'>A</div>
                   </th>
                   <th style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' align='center' valign='middle'>
                     <p class='Tableheader' style='text-align: center'>B</p>
                   </th>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                   <th style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
                     <div class='Tablebody'>C</div>
                   </th>
                   <td style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
                     <p class='Tablebody'>D</p>
                   </td>
                 </tr>
               </tbody>
               <tfoot>
                 <tr>
                   <th style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
                     <div class='Tablebody'>E</div>
                   </th>
                   <td style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
                     <p class='Tablebody'>F</p>
                   </td>
                 </tr>
               </tfoot>
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
        <clause id="A">
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
        <p class='zzSTDTitle'/>
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
            <div style='page-break-after:avoid;'>
              <a name='D' id='D'/>
              <p class='Example'>
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
        <clause id="A">
        <example id="B">
        <name>EXAMPLE</name>
        <p>First example</p>
        </example>
        <example id="C">
        <p>Second example</p>
        <p>Continuation</p>
        </example>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class='WordSection3'>
        <p class='zzSTDTitle'/>
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

  it "deals with notes" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A">
        <note id="B">
        <name>NOTE</name>
        <p>First example</p>
        </note>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
          <div class='WordSection3'>
        <p class='zzSTDTitle'/>
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
        <name>NOTE</name>
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
             <div class='WordSection3'>
        <p class='zzSTDTitle'/>
        <div>
          <a name='A' id='A'/>
          <h1/>
          <div>
            <a name='B' id='B'/>
            <p class='Note'>
              NOTE
              <span style='mso-tab-count:1'>  </span>
            </p>
            <p class='MsoListContinue2'>
              —
              <span style='mso-tab-count:1'> </span>
              A
            </p>
            <p class='MsoListContinue2'>
              —
              <span style='mso-tab-count:1'> </span>
              B
            </p>
            <p class='MsoListContinue3'>
              —
              <span style='mso-tab-count:1'> </span>
              C
            </p>
            <p class='MsoListContinue3'>
              —
              <span style='mso-tab-count:1'> </span>
              D
            </p>
            <p class='MsoListContinue4'>
              —
              <span style='mso-tab-count:1'> </span>
              E
            </p>
            <p class='MsoListContinue4'>
              —
              <span style='mso-tab-count:1'> </span>
              F
            </p>
            <p class='MsoListContinue5'>
              —
              <span style='mso-tab-count:1'> </span>
              G
            </p>
            <p class='MsoListContinue5'>
              —
              <span style='mso-tab-count:1'> </span>
              H
            </p>
            <p class='MsoListContinue6'>
              —
              <span style='mso-tab-count:1'> </span>
              I
            </p>
            <p class='MsoListContinue6'>
              —
              <span style='mso-tab-count:1'> </span>
              J
            </p>
            <p class='MsoListContinue6'>
              —
              <span style='mso-tab-count:1'> </span>
              K
            </p>
            <p class='MsoListContinue6'>
              —
              <span style='mso-tab-count:1'> </span>
              L
            </p>
            <p class='MsoListContinue6'>
              —
              <span style='mso-tab-count:1'> </span>
              M
            </p>
            <p class='MsoListContinue6'>
              —
              <span style='mso-tab-count:1'> </span>
              N
            </p>
            <p class='MsoListContinue5'>
              —
              <span style='mso-tab-count:1'> </span>
              O
            </p>
            <p class='MsoListContinue4'>
              —
              <span style='mso-tab-count:1'> </span>
              P
            </p>
            <p class='MsoListContinue3'>
              —
              <span style='mso-tab-count:1'> </span>
              Q
            </p>
            <p class='MsoListContinue2'>
              —
              <span style='mso-tab-count:1'> </span>
              R
            </p>
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

  it "deals with ordered lists embedded within notes and examples" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A">
        <example id="B">
        <name>EXAMPLE</name>
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
          <div class='WordSection3'>
        <p class='zzSTDTitle'/>
        <div>
          <a name='A' id='A'/>
          <h1/>
          <div>
            <a name='B' id='B'/>
            <p class='Example'>
              EXAMPLE
              <span style='mso-tab-count:1'>  </span>
            </p>
            <p class='MsoListNumber2'>
              a)
              <span style='mso-tab-count:1'> </span>
              A
            </p>
            <p class='MsoListNumber2'>
              b)
              <span style='mso-tab-count:1'> </span>
              B
            </p>
            <p class='MsoListNumber2'>
              1)
              <span style='mso-tab-count:1'> </span>
              C
            </p>
            <p class='MsoListNumber2'>
              2)
              <span style='mso-tab-count:1'> </span>
              D
            </p>
            <p class='MsoListNumber3'>
              i)
              <span style='mso-tab-count:1'> </span>
              E
            </p>
            <p class='MsoListNumber3'>
              ii)
              <span style='mso-tab-count:1'> </span>
              F
            </p>
            <p class='MsoListNumber4'>
              A)
              <span style='mso-tab-count:1'> </span>
              G
            </p>
            <p class='MsoListNumber4'>
              B)
              <span style='mso-tab-count:1'> </span>
              H
            </p>
            <p class='MsoListNumber5'>
              I)
              <span style='mso-tab-count:1'> </span>
              I
            </p>
            <p class='MsoListNumber5'>
              II)
              <span style='mso-tab-count:1'> </span>
              J
            </p>
            <p class='MsoListNumber5'>
              a)
              <span style='mso-tab-count:1'> </span>
              K
            </p>
            <p class='MsoListNumber5'>
              b)
              <span style='mso-tab-count:1'> </span>
              L
            </p>
            <p class='MsoListNumber5'>
              c)
              <span style='mso-tab-count:1'> </span>
              M
            </p>
            <p class='MsoListNumber5'>
              III)
              <span style='mso-tab-count:1'> </span>
              N
            </p>
            <p class='MsoListNumber4'>
              C)
              <span style='mso-tab-count:1'> </span>
              O
            </p>
            <p class='MsoListNumber3'>
              iii)
              <span style='mso-tab-count:1'> </span>
              P
            </p>
            <p class='MsoListNumber2'>
              3)
              <span style='mso-tab-count:1'> </span>
              Q
            </p>
            <p class='MsoListNumber2'>
              c)
              <span style='mso-tab-count:1'> </span>
              R
            </p>
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

  it "deals with definition lists embedded within notes and examples" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status><stage>50</stage></status>
        </bibdata>
        <sections>
        <clause id="A">
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
        <p class='zzSTDTitle'/>
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
        <annex id="A"><title>Annex</title>
        <clause id="B"><title>Subannex</title>
        <clause id="C"><title>Subsubannex</title>
        </clause>
        </clause>
        </annex>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class='WordSection3'>
         <p class='zzSTDTitle'/>
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
        <clause id="A">
        <quote>
        <p>Normal clause</p>
        <note><p>Note clause</p></note>
        <example>
        <p>Example start</p>
        <p>Example continued</p>
        </example>
        </quote>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
      <div class='WordSection3'>
         <p class='zzSTDTitle'/>
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
               <p class='Exampleindentcontinued'>Example continued</p>
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

  it "deals with title" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
        <title language="en" format="text/plain" type="title-intro">Date and time</title>
          <title language="en" format="text/plain" type="title-main">Representations for information interchange</title>
        <title language="en" format="text/plain" type="title-part">Basic rules</title>
          <status><stage>50</stage></status>
          <ext><doctype>international-standard</doctype>
          <structuredidentifier><project-number part="1" origyr="2022-03-10">8601</project-number></structuredidentifier>
          </ext>
        </bibdata>
        <sections>
        <clause id="A"><title>First clause</title>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
        <div class='WordSection3'>
                   <p class='zzSTDTitle'>
                 Date and time — Representations for information interchange —
      <span style='font-weight:normal'>Part 1</span>
       Basic rules
          </p>
          <div>
            <a name='A' id='A'/>
            <h1>First clause</h1>
          </div>
        </div>
    WORD
    title = <<~WORD
      <div class='WordSection1'>
        <p class='zzCover'>
          <span lang='EN-GB' xml:lang='EN-GB'>Reference number of project: </span>
        </p>
        <p class='zzCover'>
          <span lang='EN-GB' xml:lang='EN-GB'>Committee identification: /</span>
        </p>
        <p class='zzCover'>
          <span lang='EN-GB' xml:lang='EN-GB'>
            Secretariat:
            <span>XXX</span>
          </span>
        </p>
        <p class='zzCover'>
          <span lang='EN-GB' xml:lang='EN-GB'>
            Date and time — Representations for information interchange
            — Part 1: Basic rules
          </span>
        </p>
        <p class='zzCover'> </p>
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
          <status><stage>50</stage></status>
          <ext><doctype>amendment</doctype>
          <structuredidentifier><project-number part="1" amendment="1" origyr="2022-03-10">8601</project-number></structuredidentifier>
          </ext>
        </bibdata>
        <preface>
        <foreword id="F"><title>Foreword</title></foreword>
        </preface>
         <sections>
        <clause id="A"><title>First clause</title>
        </clause>
        </sections>
      </iso-standard>
    INPUT
    word = <<~WORD
        <div class='WordSection3'>
                   <p class='zzSTDTitle'>
                       Date and time — Representations for information interchange —
      <span style='font-weight:normal'>Part 1</span>
       Basic rules
      <span style='font-weight:normal'> AMENDMENT 1: Technical corrections</span>
          </p>
          <div>
            <a name='A' id='A'/>
            <p style='font-style:italic;page-break-after:avoid;' class='MsoBodyText'>First clause</p>
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
