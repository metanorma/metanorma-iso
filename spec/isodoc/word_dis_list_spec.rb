require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
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
                             <p class="ListNumber1">
                                a)
                                <span style="mso-tab-count:1"> </span>
                                A
                             </p>
                             <p class="ListNumber1">
                                b)
                                <span style="mso-tab-count:1"> </span>
                                B
                             </p>
                             <p class="MsoNormal">
                                <a name="_" id="_"/>
                                <div class="ol_wrap">
                                   <p class="MsoListNumber2">
                                      <a name="_" id="_"/>
                                      1)
                                      <span style="mso-tab-count:1"> </span>
                                      C
                                   </p>
                                   <p class="MsoListNumber2">
                                      <a name="_" id="_"/>
                                      2)
                                      <span style="mso-tab-count:1"> </span>
                                      D
                                   </p>
                                   <p class="MsoNormal">
                                      <a name="_" id="_"/>
                                      <div class="ol_wrap">
                                         <p class="MsoListNumber3">
                                            <a name="_" id="_"/>
                                            i)
                                            <span style="mso-tab-count:1"> </span>
                                            E
                                         </p>
                                         <p class="MsoListNumber3">
                                            <a name="_" id="_"/>
                                            ii)
                                            <span style="mso-tab-count:1"> </span>
                                            F
                                         </p>
                                         <p class="MsoNormal">
                                            <a name="_" id="_"/>
                                            <div class="ol_wrap">
                                               <p class="MsoListNumber4">
                                                  <a name="_" id="_"/>
                                                  A)
                                                  <span style="mso-tab-count:1"> </span>
                                                  G
                                               </p>
                                               <p class="MsoListNumber4">
                                                  <a name="_" id="_"/>
                                                  B)
                                                  <span style="mso-tab-count:1"> </span>
                                                  H
                                               </p>
                                               <p class="MsoNormal">
                                                  <a name="_" id="_"/>
                                                  <div class="ol_wrap">
                                                     <p class="MsoListNumber5">
                                                        <a name="_" id="_"/>
                                                        I)
                                                        <span style="mso-tab-count:1"> </span>
                                                        I
                                                     </p>
                                                     <p class="MsoListNumber5">
                                                        <a name="_" id="_"/>
                                                        II)
                                                        <span style="mso-tab-count:1"> </span>
                                                        J
                                                     </p>
                                                     <p class="MsoNormal">
                                                        <a name="_" id="_"/>
                                                        <div class="ol_wrap">
                                                           <p class="MsoListNumber5">
                                                              <a name="_" id="_"/>
                                                              a)
                                                              <span style="mso-tab-count:1"> </span>
                                                              K
                                                           </p>
                                                           <p class="MsoListNumber5">
                                                              <a name="_" id="_"/>
                                                              b)
                                                              <span style="mso-tab-count:1"> </span>
                                                              L
                                                           </p>
                                                           <p class="MsoListNumber5">
                                                              <a name="_" id="_"/>
                                                              c)
                                                              <span style="mso-tab-count:1"> </span>
                                                              M
                                                           </p>
                                                        </div>
                                                     </p>
                                                     <p class="MsoListNumber5">
                                                        <a name="_" id="_"/>
                                                        III)
                                                        <span style="mso-tab-count:1"> </span>
                                                        N
                                                     </p>
                                                  </div>
                                               </p>
                                               <p class="MsoListNumber4">
                                                  <a name="_" id="_"/>
                                                  C)
                                                  <span style="mso-tab-count:1"> </span>
                                                  O
                                               </p>
                                            </div>
                                         </p>
                                         <p class="MsoListNumber3">
                                            <a name="_" id="_"/>
                                            iii)
                                            <span style="mso-tab-count:1"> </span>
                                            P
                                         </p>
                                      </div>
                                   </p>
                                   <p class="MsoListNumber2">
                                      <a name="_" id="_"/>
                                      3)
                                      <span style="mso-tab-count:1"> </span>
                                      Q
                                   </p>
                                </div>
                             </p>
                             <p class="ListNumber1">
                                <a name="_" id="_"/>
                                c)
                                <span style="mso-tab-count:1"> </span>
                                R
                             </p>
                          </div>
                          <div class="ul_wrap">
                             <p class="ListContinue1">
                                —
                                <span style="mso-tab-count:1"> </span>
                                A
                             </p>
                             <p class="ListContinue1">
                                —
                                <span style="mso-tab-count:1"> </span>
                                B
                             </p>
                             <p class="ListContinue1">
                                <a name="_" id="_"/>
                                <p class="ListContinue1">
                                   —
                                   <span style="mso-tab-count:1"> </span>
                                   B1
                                </p>
                                <div class="ListContLevel1">
                                   <div class="ul_wrap">
                                      <p class="MsoListContinue2">
                                         <a name="_" id="_"/>
                                         —
                                         <span style="mso-tab-count:1"> </span>
                                         C
                                      </p>
                                      <p class="MsoListContinue2">
                                         <a name="_" id="_"/>
                                         —
                                         <span style="mso-tab-count:1"> </span>
                                         D
                                      </p>
                                      <p class="MsoNormal">
                                         <a name="_" id="_"/>
                                         <div class="ul_wrap">
                                            <p class="MsoListContinue3">
                                               <a name="_" id="_"/>
                                               —
                                               <span style="mso-tab-count:1"> </span>
                                               E
                                            </p>
                                            <p class="MsoListContinue3">
                                               <a name="_" id="_"/>
                                               —
                                               <span style="mso-tab-count:1"> </span>
                                               F
                                            </p>
                                            <p class="MsoNormal">
                                               <a name="_" id="_"/>
                                               <div class="ul_wrap">
                                                  <p class="MsoListContinue4">
                                                     <a name="_" id="_"/>
                                                     —
                                                     <span style="mso-tab-count:1"> </span>
                                                     G
                                                  </p>
                                                  <p class="MsoListContinue4">
                                                     <a name="_" id="_"/>
                                                     —
                                                     <span style="mso-tab-count:1"> </span>
                                                     H
                                                  </p>
                                                  <p class="MsoNormal">
                                                     <a name="_" id="_"/>
                                                     <div class="ul_wrap">
                                                        <p class="MsoListContinue5">
                                                           <a name="_" id="_"/>
                                                           —
                                                           <span style="mso-tab-count:1"> </span>
                                                           I
                                                        </p>
                                                        <p class="MsoListContinue5">
                                                           <a name="_" id="_"/>
                                                           —
                                                           <span style="mso-tab-count:1"> </span>
                                                           J
                                                        </p>
                                                        <p class="MsoNormal">
                                                           <a name="_" id="_"/>
                                                           <div class="ul_wrap">
                                                              <p class="MsoListContinue5">
                                                                 <a name="_" id="_"/>
                                                                 —
                                                                 <span style="mso-tab-count:1"> </span>
                                                                 K
                                                              </p>
                                                              <p class="MsoListContinue5">
                                                                 <a name="_" id="_"/>
                                                                 —
                                                                 <span style="mso-tab-count:1"> </span>
                                                                 L
                                                              </p>
                                                              <p class="MsoListContinue5">
                                                                 <a name="_" id="_"/>
                                                                 —
                                                                 <span style="mso-tab-count:1"> </span>
                                                                 M
                                                              </p>
                                                           </div>
                                                        </p>
                                                        <p class="MsoListContinue5">
                                                           <a name="_" id="_"/>
                                                           —
                                                           <span style="mso-tab-count:1"> </span>
                                                           N
                                                        </p>
                                                     </div>
                                                  </p>
                                                  <p class="MsoListContinue4">
                                                     <a name="_" id="_"/>
                                                     —
                                                     <span style="mso-tab-count:1"> </span>
                                                     O
                                                  </p>
                                               </div>
                                            </p>
                                            <p class="MsoListContinue3">
                                               <a name="_" id="_"/>
                                               —
                                               <span style="mso-tab-count:1"> </span>
                                               P
                                            </p>
                                         </div>
                                      </p>
                                      <p class="MsoListContinue2">
                                         <a name="_" id="_"/>
                                         —
                                         <span style="mso-tab-count:1"> </span>
                                         Q
                                      </p>
                                   </div>
                                </div>
                             </p>
                             <p class="ListContinue1">
                                <a name="_" id="_"/>
                                —
                                <span style="mso-tab-count:1"> </span>
                                R
                             </p>
                          </div>
                       </p>
                    </div>
        </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<annotation.*</annotation>}m, "")
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    xml = Nokogiri::XML(output)
    xml = xml.at("//xmlns:div[@class = 'WordSection3']")
    xml.at("//xmlns:div[@style = 'mso-element:comment-list']")&.remove
    expect(strip_guid(Canon.format_xml(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
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
                             <p class="ListNumber1">
                                1)
                                <span style="mso-tab-count:1"> </span>
                                A
                             </p>
                             <p class="MsoNormal">
                                <a name="_" id="_"/>
                                <div class="ol_wrap">
                                   <p class="MsoListNumber2">
                                      <a name="_" id="_"/>
                                      A)
                                      <span style="mso-tab-count:1"> </span>
                                      C
                                   </p>
                                   <p class="MsoNormal">
                                      <a name="_" id="_"/>
                                      <div class="ol_wrap">
                                         <p class="MsoListNumber3">
                                            <a name="_" id="_"/>
                                            I)
                                            <span style="mso-tab-count:1"> </span>
                                            E
                                         </p>
                                         <p class="MsoNormal">
                                            <a name="_" id="_"/>
                                            <div class="ol_wrap">
                                               <p class="MsoListNumber4">
                                                  <a name="_" id="_"/>
                                                  i)
                                                  <span style="mso-tab-count:1"> </span>
                                                  G
                                               </p>
                                               <p class="MsoNormal">
                                                  <a name="_" id="_"/>
                                                  <div class="ol_wrap">
                                                     <p class="MsoListNumber5">
                                                        <a name="_" id="_"/>
                                                        a)
                                                        <span style="mso-tab-count:1"> </span>
                                                        I
                                                     </p>
                                                     <p class="MsoNormal">
                                                        <a name="_" id="_"/>
                                                        <div class="ol_wrap">
                                                           <p class="MsoListNumber5">
                                                              <a name="_" id="_"/>
                                                              I)
                                                              <span style="mso-tab-count:1"> </span>
                                                              K
                                                           </p>
                                                        </div>
                                                     </p>
                                                     <p class="MsoListNumber5">
                                                        <a name="_" id="_"/>
                                                        b)
                                                        <span style="mso-tab-count:1"> </span>
                                                        N
                                                     </p>
                                                  </div>
                                               </p>
                                               <p class="MsoListNumber4">
                                                  <a name="_" id="_"/>
                                                  ii)
                                                  <span style="mso-tab-count:1"> </span>
                                                  O
                                               </p>
                                            </div>
                                         </p>
                                         <p class="MsoListNumber3">
                                            <a name="_" id="_"/>
                                            II)
                                            <span style="mso-tab-count:1"> </span>
                                            P
                                         </p>
                                      </div>
                                   </p>
                                   <p class="MsoListNumber2">
                                      <a name="_" id="_"/>
                                      B)
                                      <span style="mso-tab-count:1"> </span>
                                      Q
                                   </p>
                                </div>
                             </p>
                             <p class="ListNumber1">
                                <a name="_" id="_"/>
                                2)
                                <span style="mso-tab-count:1"> </span>
                                R
                             </p>
                          </div>
                       </p>
                    </div>
        </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<annotation.*</annotation>}m, "")
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    xml = Nokogiri::XML(output)
    xml = xml.at("//xmlns:div[@class = 'WordSection3']")
    xml.at("//xmlns:div[@style = 'mso-element:comment-list']")&.remove
    expect(strip_guid(Canon.format_xml(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
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
       <div class="WordSection3">
                     <div>
                       <a name="A" id="A"/>
                       <h1>1</h1>
                       <p class="MsoBodyText">
                          <a name="_" id="_"/>
                          ISO and IEC maintain terminological databases for use in standardization at the following addresses:
                       </p>
                       <div class="ul_wrap">
                          <p class="ListContinue1">
                             <a name="_" id="_"/>
                             —
                             <span style="mso-tab-count:1"> </span>
                             ISO Online browsing platform: available at
                             <a href="https://www.iso.org/obp">https://www.iso.org/obp</a>
                          </p>
                          <p class="ListContinue1">
                             <a name="_" id="_"/>
                             —
                             <span style="mso-tab-count:1"> </span>
                             IEC Electropedia: available at
                             <a href="https://www.electropedia.org">https://www.electropedia.org</a>
                          </p>
                       </div>
                    </div>
        </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<annotation.*</annotation>}m, "")
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    xml = Nokogiri::XML(output)
    xml = xml.at("//xmlns:div[@class = 'WordSection3']")
    xml.at("//xmlns:div[@style = 'mso-element:comment-list']")&.remove
    expect(strip_guid(Canon.format_xml(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
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
                             <p class="ListNumber1">
                                c)
                                <span style="mso-tab-count:1"> </span>
                                A
                             </p>
                             <p class="ListNumber1">
                                d)
                                <span style="mso-tab-count:1"> </span>
                                B
                             </p>
                             <p class="MsoNormal">
                                <a name="_" id="_"/>
                                <div class="ol_wrap">
                                   <p class="MsoListNumber2">
                                      <a name="_" id="_"/>
                                      3)
                                      <span style="mso-tab-count:1"> </span>
                                      C
                                   </p>
                                   <p class="MsoListNumber2">
                                      <a name="_" id="_"/>
                                      4)
                                      <span style="mso-tab-count:1"> </span>
                                      D
                                   </p>
                                   <p class="MsoNormal">
                                      <a name="_" id="_"/>
                                      <div class="ol_wrap">
                                         <p class="MsoListNumber3">
                                            <a name="_" id="_"/>
                                            iii)
                                            <span style="mso-tab-count:1"> </span>
                                            E
                                         </p>
                                         <p class="MsoListNumber3">
                                            <a name="_" id="_"/>
                                            iv)
                                            <span style="mso-tab-count:1"> </span>
                                            F
                                         </p>
                                         <p class="MsoNormal">
                                            <a name="_" id="_"/>
                                            <div class="ol_wrap">
                                               <p class="MsoListNumber4">
                                                  <a name="_" id="_"/>
                                                  C)
                                                  <span style="mso-tab-count:1"> </span>
                                                  G
                                               </p>
                                               <p class="MsoListNumber4">
                                                  <a name="_" id="_"/>
                                                  D)
                                                  <span style="mso-tab-count:1"> </span>
                                                  H
                                               </p>
                                               <p class="MsoNormal">
                                                  <a name="_" id="_"/>
                                                  <div class="ol_wrap">
                                                     <p class="MsoListNumber5">
                                                        <a name="_" id="_"/>
                                                        III)
                                                        <span style="mso-tab-count:1"> </span>
                                                        I
                                                     </p>
                                                     <p class="MsoListNumber5">
                                                        <a name="_" id="_"/>
                                                        IV)
                                                        <span style="mso-tab-count:1"> </span>
                                                        J
                                                     </p>
                                                     <p class="MsoNormal">
                                                        <a name="_" id="_"/>
                                                        <div class="ol_wrap">
                                                           <p class="MsoListNumber5">
                                                              <a name="_" id="_"/>
                                                              c)
                                                              <span style="mso-tab-count:1"> </span>
                                                              K
                                                           </p>
                                                           <p class="MsoListNumber5">
                                                              <a name="_" id="_"/>
                                                              d)
                                                              <span style="mso-tab-count:1"> </span>
                                                              L
                                                           </p>
                                                           <p class="MsoListNumber5">
                                                              <a name="_" id="_"/>
                                                              e)
                                                              <span style="mso-tab-count:1"> </span>
                                                              M
                                                           </p>
                                                        </div>
                                                     </p>
                                                     <p class="MsoListNumber5">
                                                        <a name="_" id="_"/>
                                                        V)
                                                        <span style="mso-tab-count:1"> </span>
                                                        N
                                                     </p>
                                                  </div>
                                               </p>
                                               <p class="MsoListNumber4">
                                                  <a name="_" id="_"/>
                                                  E)
                                                  <span style="mso-tab-count:1"> </span>
                                                  O
                                               </p>
                                            </div>
                                         </p>
                                         <p class="MsoListNumber3">
                                            <a name="_" id="_"/>
                                            v)
                                            <span style="mso-tab-count:1"> </span>
                                            P
                                         </p>
                                      </div>
                                   </p>
                                   <p class="MsoListNumber2">
                                      <a name="_" id="_"/>
                                      5)
                                      <span style="mso-tab-count:1"> </span>
                                      Q
                                   </p>
                                </div>
                             </p>
                             <p class="ListNumber1">
                                <a name="_" id="_"/>
                                e)
                                <span style="mso-tab-count:1"> </span>
                                R
                             </p>
                          </div>
                       </p>
                    </div>
        </div>
    OUTPUT
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<annotation.*</annotation>}m, "")
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    xml = Nokogiri::XML(output)
    xml = xml.at("//xmlns:div[@class = 'WordSection3']")
    xml.at("//xmlns:div[@style = 'mso-element:comment-list']")&.remove
    expect(strip_guid(Canon.format_xml(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
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
                          <p class="Note">
                             NOTE
                             <span style="mso-tab-count:1">  </span>
                          </p>
                          <div class="ul_wrap">
                             <p class="ListContinue2-">
                                —
                                <span style="mso-tab-count:1"> </span>
                                A
                             </p>
                             <p class="ListContinue2-">
                                —
                                <span style="mso-tab-count:1"> </span>
                                B
                             </p>
                             <p class="MsoNormal">
                                <a name="_" id="_"/>
                                <div class="ul_wrap">
                                   <p class="ListContinue3-">
                                      <a name="_" id="_"/>
                                      —
                                      <span style="mso-tab-count:1"> </span>
                                      C
                                   </p>
                                   <p class="ListContinue3-">
                                      <a name="_" id="_"/>
                                      —
                                      <span style="mso-tab-count:1"> </span>
                                      D
                                   </p>
                                   <p class="MsoNormal">
                                      <a name="_" id="_"/>
                                      <div class="ul_wrap">
                                         <p class="ListContinue4-">
                                            <a name="_" id="_"/>
                                            —
                                            <span style="mso-tab-count:1"> </span>
                                            E
                                         </p>
                                         <p class="ListContinue4-">
                                            <a name="_" id="_"/>
                                            —
                                            <span style="mso-tab-count:1"> </span>
                                            F
                                         </p>
                                         <p class="MsoNormal">
                                            <a name="_" id="_"/>
                                            <div class="ul_wrap">
                                               <p class="ListContinue5-">
                                                  <a name="_" id="_"/>
                                                  —
                                                  <span style="mso-tab-count:1"> </span>
                                                  G
                                               </p>
                                               <p class="ListContinue5-">
                                                  <a name="_" id="_"/>
                                                  —
                                                  <span style="mso-tab-count:1"> </span>
                                                  H
                                               </p>
                                               <p class="MsoNormal">
                                                  <a name="_" id="_"/>
                                                  <div class="ul_wrap">
                                                     <p class="ListContinue5-">
                                                        <a name="_" id="_"/>
                                                        —
                                                        <span style="mso-tab-count:1"> </span>
                                                        I
                                                     </p>
                                                     <p class="ListContinue5-">
                                                        <a name="_" id="_"/>
                                                        —
                                                        <span style="mso-tab-count:1"> </span>
                                                        J
                                                     </p>
                                                     <p class="MsoNormal">
                                                        <a name="_" id="_"/>
                                                        <div class="ul_wrap">
                                                           <p class="ListContinue5-">
                                                              <a name="_" id="_"/>
                                                              —
                                                              <span style="mso-tab-count:1"> </span>
                                                              K
                                                           </p>
                                                           <p class="ListContinue5-">
                                                              <a name="_" id="_"/>
                                                              —
                                                              <span style="mso-tab-count:1"> </span>
                                                              L
                                                           </p>
                                                           <p class="ListContinue5-">
                                                              <a name="_" id="_"/>
                                                              —
                                                              <span style="mso-tab-count:1"> </span>
                                                              M
                                                           </p>
                                                        </div>
                                                     </p>
                                                     <p class="ListContinue5-">
                                                        <a name="_" id="_"/>
                                                        —
                                                        <span style="mso-tab-count:1"> </span>
                                                        N
                                                     </p>
                                                  </div>
                                               </p>
                                               <p class="ListContinue5-">
                                                  <a name="_" id="_"/>
                                                  —
                                                  <span style="mso-tab-count:1"> </span>
                                                  O
                                               </p>
                                            </div>
                                         </p>
                                         <p class="ListContinue4-">
                                            <a name="_" id="_"/>
                                            —
                                            <span style="mso-tab-count:1"> </span>
                                            P
                                         </p>
                                      </div>
                                   </p>
                                   <p class="ListContinue3-">
                                      <a name="_" id="_"/>
                                      —
                                      <span style="mso-tab-count:1"> </span>
                                      Q
                                   </p>
                                </div>
                             </p>
                             <p class="ListContinue2-">
                                <a name="_" id="_"/>
                                —
                                <span style="mso-tab-count:1"> </span>
                                R
                             </p>
                          </div>
                       </div>
                    </div>
        </div>
    WORD
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<annotation.*</annotation>}m, "")
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    xml = Nokogiri::XML(output)
    xml = xml.at("//xmlns:div[@class = 'WordSection3']")
    xml.at("//xmlns:div[@style = 'mso-element:comment-list']")&.remove
    expect(strip_guid(Canon.format_xml(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
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
                          <p class="Example">
                             EXAMPLE
                             <span style="mso-tab-count:1">  </span>
                          </p>
                          <div class="ol_wrap">
                             <p class="ListNumber2-">
                                a)
                                <span style="mso-tab-count:1"> </span>
                                A
                             </p>
                             <p class="ListNumber2-">
                                b)
                                <span style="mso-tab-count:1"> </span>
                                B
                             </p>
                             <p class="MsoNormal">
                                <a name="_" id="_"/>
                                <div class="ol_wrap">
                                   <p class="ListNumber3-">
                                      <a name="_" id="_"/>
                                      1)
                                      <span style="mso-tab-count:1"> </span>
                                      C
                                   </p>
                                   <p class="ListNumber3-">
                                      <a name="_" id="_"/>
                                      2)
                                      <span style="mso-tab-count:1"> </span>
                                      D
                                   </p>
                                   <p class="MsoNormal">
                                      <a name="_" id="_"/>
                                      <div class="ol_wrap">
                                         <p class="ListNumber4-">
                                            <a name="_" id="_"/>
                                            i)
                                            <span style="mso-tab-count:1"> </span>
                                            E
                                         </p>
                                         <p class="ListNumber4-">
                                            <a name="_" id="_"/>
                                            ii)
                                            <span style="mso-tab-count:1"> </span>
                                            F
                                         </p>
                                         <p class="MsoNormal">
                                            <a name="_" id="_"/>
                                            <div class="ol_wrap">
                                               <p class="ListNumber5-">
                                                  <a name="_" id="_"/>
                                                  A)
                                                  <span style="mso-tab-count:1"> </span>
                                                  G
                                               </p>
                                               <p class="ListNumber5-">
                                                  <a name="_" id="_"/>
                                                  B)
                                                  <span style="mso-tab-count:1"> </span>
                                                  H
                                               </p>
                                               <p class="MsoNormal">
                                                  <a name="_" id="_"/>
                                                  <div class="ol_wrap">
                                                     <p class="ListNumber5-">
                                                        <a name="_" id="_"/>
                                                        I)
                                                        <span style="mso-tab-count:1"> </span>
                                                        I
                                                     </p>
                                                     <p class="ListNumber5-">
                                                        <a name="_" id="_"/>
                                                        II)
                                                        <span style="mso-tab-count:1"> </span>
                                                        J
                                                     </p>
                                                     <p class="MsoNormal">
                                                        <a name="_" id="_"/>
                                                        <div class="ol_wrap">
                                                           <p class="ListNumber5-">
                                                              <a name="_" id="_"/>
                                                              a)
                                                              <span style="mso-tab-count:1"> </span>
                                                              K
                                                           </p>
                                                           <p class="ListNumber5-">
                                                              <a name="_" id="_"/>
                                                              b)
                                                              <span style="mso-tab-count:1"> </span>
                                                              L
                                                           </p>
                                                           <p class="ListNumber5-">
                                                              <a name="_" id="_"/>
                                                              c)
                                                              <span style="mso-tab-count:1"> </span>
                                                              M
                                                           </p>
                                                        </div>
                                                     </p>
                                                     <p class="ListNumber5-">
                                                        <a name="_" id="_"/>
                                                        III)
                                                        <span style="mso-tab-count:1"> </span>
                                                        N
                                                     </p>
                                                  </div>
                                               </p>
                                               <p class="ListNumber5-">
                                                  <a name="_" id="_"/>
                                                  C)
                                                  <span style="mso-tab-count:1"> </span>
                                                  O
                                               </p>
                                            </div>
                                         </p>
                                         <p class="ListNumber4-">
                                            <a name="_" id="_"/>
                                            iii)
                                            <span style="mso-tab-count:1"> </span>
                                            P
                                         </p>
                                      </div>
                                   </p>
                                   <p class="ListNumber3-">
                                      <a name="_" id="_"/>
                                      3)
                                      <span style="mso-tab-count:1"> </span>
                                      Q
                                   </p>
                                </div>
                             </p>
                             <p class="ListNumber2-">
                                <a name="_" id="_"/>
                                c)
                                <span style="mso-tab-count:1"> </span>
                                R
                             </p>
                          </div>
                       </div>
                    </div>
        </div>
            WORD
    FileUtils.rm_f "test.doc"
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<annotation.*</annotation>}m, "")
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    xml = Nokogiri::XML(output)
    xml = xml.at("//xmlns:div[@class = 'WordSection3']")
    xml.at("//xmlns:div[@style = 'mso-element:comment-list']")&.remove
    expect(strip_guid(Canon.format_xml(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
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
                          <p class="ListContinue1">
                             <a name="_" id="_"/>
                             —
                             <span style="mso-tab-count:1"> </span>
                             A
                          </p>
                          <p class="MsoNormal">
                             <a name="_" id="_"/>
                             <div class="ol_wrap">
                                <p class="MsoListNumber2">
                                   <a name="_" id="_"/>
                                   a)
                                   <span style="mso-tab-count:1"> </span>
                                   List
                                </p>
                                <p class="MsoNormal">
                                   <a name="_" id="_"/>
                                   <div class="ul_wrap">
                                      <p class="MsoListContinue3">
                                         <a name="_" id="_"/>
                                         —
                                         <span style="mso-tab-count:1"> </span>
                                         B
                                      </p>
                                      <p class="MsoNormal">
                                         <a name="_" id="_"/>
                                         <div class="ol_wrap">
                                            <p class="MsoListNumber4">
                                               <a name="_" id="_"/>
                                               1)
                                               <span style="mso-tab-count:1"> </span>
                                               List 2
                                            </p>
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
      .sub(%r{<annotation.*</annotation>}m, "")
    IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, false)
    expect(File.exist?("test.doc")).to be true
    output = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<html/m, "<html")
      .sub(/<\/html>.*$/m, "</html>")
    xml = Nokogiri::XML(output)
    xml = xml.at("//xmlns:div[@class = 'WordSection3']")
    xml.at("//xmlns:div[@style = 'mso-element:comment-list']")&.remove
    expect(strip_guid(Canon.format_xml(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
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
        <fmt-name id="_">EXAMPLE</fmt-name>
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
            <div align="left">
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
