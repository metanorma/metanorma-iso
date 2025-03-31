require "spec_helper"

RSpec.describe IsoDoc do
  it "processes inline formatting" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~INPUT, true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <clause type="toc" id="_" displayorder="1">
            <fmt-title depth="1">Contents</fmt-title>
          </clause>
          <foreword displayorder="2" id="_"><fmt-title>Foreword</fmt-title>
            <p>
              <em>A</em>
              <strong>B</strong>
              <sup>C</sup>
              <sub>D</sub>
              <tt>E</tt>
              <strike>F</strike>
              <smallcap>G</smallcap>
              <br/>
              <hr/>
              <bookmark id="H"/>
              <pagebreak/>
            </p>
          </foreword>
        </preface>
        <sections/>
      </iso-standard>
    INPUT
    expect(Xml::C14n.format(output)).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{HTML_HDR}
            <br/>
            <div id="_">
              <h1 class="ForewordTitle">Foreword</h1>
              <p>
                <i>A</i>
                <b>B</b>
                <sup>C</sup>
                <sub>D</sub>
                <tt>E</tt>
                <s>F</s>
                <span style="font-variant:small-caps;">G</span>
                <br/>
                <hr/>
                <a id="H"/>
                <br/>
              </p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "processes unrecognised markup" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~INPUT, true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <clause type="toc" id="_" displayorder="1">
            <fmt-title depth="1">Contents</fmt-title>
          </clause>
          <foreword displayorder="2" id="_"><fmt-title>Foreword</fmt-title>
            <p>
              <barry fred="http://example.com">example</barry>
            </p>
          </foreword>
        </preface>
        <sections/>
      </iso-standard>
    INPUT
    expect(Xml::C14n.format(output)).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{HTML_HDR}
            <br/>
            <div id="_">
              <h1 class="ForewordTitle">Foreword</h1>
              <p>
                <para>
                  <b role="strong">&lt;barry fred=&quot;http://example.com&quot;&gt;example&lt;/barry&gt;</b>
                </para>
              </p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "processes AsciiMath and MathML" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~INPUT, true)
      <iso-standard xmlns="http://riboseinc.com/isoxml" xmlns:m="http://www.w3.org/1998/Math/MathML">
        <preface>
          <clause type="toc" id="_" displayorder="1">
            <fmt-title depth="1">Contents</fmt-title>
          </clause>
          <foreword displayorder="2" id="_"><fmt-title>Foreword</fmt-title>
            <p>
              <fmt-stem type="AsciiMath">A</fmt-stem>
              <fmt-stem type="MathML"><m:math><m:row>X</m:row></m:math></fmt-stem>
              <fmt-stem type="None">Latex?</fmt-stem>
            </p>
          </foreword>
        </preface>
        <sections/>
      </iso-standard>
    INPUT
    expect(Xml::C14n.format(output
      .sub(/<html/, "<html xmlns:m='m'")))
      .to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
        #{HTML_HDR.sub(/<html/, "<html xmlns:m='m'")}
              <br/>
              <div id="_">
                <h1 class="ForewordTitle">Foreword</h1>
                <p>
                  <span class="stem">(#(A)#)</span>
                  <span class="stem">
                    <m:math xmlns:m="http://www.w3.org/1998/Math/MathML">
                      <m:row>X</m:row>
                    </m:math>
                  </span>
                  <span class="stem">Latex?</span>
                </p>
              </div>
            </div>
          </body>
        </html>
      OUTPUT
  end

  it "overrides AsciiMath delimiters" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~INPUT, true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <clause type="toc" id="_" displayorder="1">
            <fmt-title depth="1">Contents</fmt-title>
          </clause>
          <foreword displayorder="2" id="_"><fmt-title>Foreword</fmt-title>
            <p><fmt-stem type="AsciiMath">A</fmt-stem>(#((Hello))#)</p>
          </foreword>
        </preface>
        <sections>
      </iso-standard>
    INPUT
    expect(Xml::C14n.format(output)).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{HTML_HDR}
              <br/>
              <div id="_">
                <h1 class="ForewordTitle">Foreword</h1>
              <p>
                <span class="stem">(#(((A)#)))</span>
                (#((Hello))#)
              </p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "localises numbers in MathML" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <title language="en">test</title>
          <language>en</language>
        </bibdata>
        <preface>
          <p>
            <stem type="MathML">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <mn>30000</mn>
              </math>
            </stem>
            <stem type="MathML">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <mn>3000.0003</mn>
              </math>
            </stem>
            <stem type="MathML">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <mn>3000000.0000003</mn>
              </math>
            </stem>
            <stem type="MathML">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <mn>.0003</mn>
              </math>
            </stem>
            <stem type="MathML">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <mn>.0000003</mn>
              </math>
            </stem>
            <stem type="MathML">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <mn>3000</mn>
              </math>
            </stem>
            <stem type="MathML">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <mn>3000000</mn>
              </math>
            </stem>
            <stem type="MathML">
              <math xmlns="http://www.w3.org/1998/Math/MathML">
                <mi>P</mi>
                <mfenced close=")" open="(">
                  <mrow>
                    <mi>X</mi>
                    <mo>≥</mo>
                    <msub>
                      <mrow>
                        <mi>X</mi>
                      </mrow>
                      <mrow>
                        <mo>max</mo>
                      </mrow>
                    </msub>
                  </mrow>
                </mfenced>
                <mo>=</mo>
                <munderover>
                  <mrow>
                    <mo>∑</mo>
                  </mrow>
                  <mrow>
                    <mrow>
                      <mi>j</mi>
                      <mo>=</mo>
                      <msub>
                        <mrow>
                          <mi>X</mi>
                        </mrow>
                        <mrow>
                          <mo>max</mo>
                        </mrow>
                      </msub>
                    </mrow>
                  </mrow>
                  <mrow>
                    <mn>1000</mn>
                  </mrow>
                </munderover>
                <mfenced close=")" open="(">
                  <mtable>
                    <mtr>
                      <mtd>
                        <mn>0.0001</mn>
                      </mtd>
                    </mtr>
                    <mtr>
                      <mtd>
                        <mi>j</mi>
                      </mtd>
                    </mtr>
                  </mtable>
                </mfenced>
                <msup>
                  <mrow>
                    <mi>p</mi>
                  </mrow>
                  <mrow>
                    <mi>j</mi>
                  </mrow>
                </msup>
                <msup>
                  <mrow>
                    <mfenced close=")" open="(">
                      <mrow>
                        <mn>1000.00001</mn>
                        <mo>−</mo>
                        <mi>p</mi>
                      </mrow>
                    </mfenced>
                  </mrow>
                  <mrow>
                    <mrow>
                      <mn>1.003</mn>
                      <mo>−</mo>
                      <mi>j</mi>
                    </mrow>
                  </mrow>
                </msup>
              </math>
            </stem>
          </p>
        </preface>
      </iso-standard>
    INPUT

    output = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <title language="en">test</title>
             <language current="true">en</language>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <p displayorder="2" id="_">
                <stem type="MathML" id="_">
                   <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mn>30000</mn>
                   </math>
                </stem>
                <fmt-stem type="MathML">
                   <semx element="stem" source="_">
               30 000
             </semx>
                </fmt-stem>
                <stem type="MathML" id="_">
                   <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mn>3000.0003</mn>
                   </math>
                </stem>
                <fmt-stem type="MathML">
                   <semx element="stem" source="_">
               3 000.000 3
             </semx>
                </fmt-stem>
                <stem type="MathML" id="_">
                   <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mn>3000000.0000003</mn>
                   </math>
                </stem>
                <fmt-stem type="MathML">
                   <semx element="stem" source="_">
               3 000 000.000 000 3
             </semx>
                </fmt-stem>
                <stem type="MathML" id="_">
                   <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mn>.0003</mn>
                   </math>
                </stem>
                <fmt-stem type="MathML">
                   <semx element="stem" source="_">
               0.000 3
             </semx>
                </fmt-stem>
                <stem type="MathML" id="_">
                   <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mn>.0000003</mn>
                   </math>
                </stem>
                <fmt-stem type="MathML">
                   <semx element="stem" source="_">
               0.000 000 3
             </semx>
                </fmt-stem>
                <stem type="MathML" id="_">
                   <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mn>3000</mn>
                   </math>
                </stem>
                <fmt-stem type="MathML">
                   <semx element="stem" source="_">
               3 000
             </semx>
                </fmt-stem>
                <stem type="MathML" id="_">
                   <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mn>3000000</mn>
                   </math>
                </stem>
                <fmt-stem type="MathML">
                   <semx element="stem" source="_">
               3 000 000
             </semx>
                </fmt-stem>
                <stem type="MathML" id="_">
                   <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mi>P</mi>
                      <mfenced close=")" open="(">
                         <mrow>
                            <mi>X</mi>
                            <mo>≥</mo>
                            <msub>
                               <mrow>
                                  <mi>X</mi>
                               </mrow>
                               <mrow>
                                  <mo>max</mo>
                               </mrow>
                            </msub>
                         </mrow>
                      </mfenced>
                      <mo>=</mo>
                      <munderover>
                         <mrow>
                            <mo>∑</mo>
                         </mrow>
                         <mrow>
                            <mrow>
                               <mi>j</mi>
                               <mo>=</mo>
                               <msub>
                                  <mrow>
                                     <mi>X</mi>
                                  </mrow>
                                  <mrow>
                                     <mo>max</mo>
                                  </mrow>
                               </msub>
                            </mrow>
                         </mrow>
                         <mrow>
                            <mn>1000</mn>
                         </mrow>
                      </munderover>
                      <mfenced close=")" open="(">
                         <mtable>
                            <mtr>
                               <mtd>
                                  <mn>0.0001</mn>
                               </mtd>
                            </mtr>
                            <mtr>
                               <mtd>
                                  <mi>j</mi>
                               </mtd>
                            </mtr>
                         </mtable>
                      </mfenced>
                      <msup>
                         <mrow>
                            <mi>p</mi>
                         </mrow>
                         <mrow>
                            <mi>j</mi>
                         </mrow>
                      </msup>
                      <msup>
                         <mrow>
                            <mfenced close=")" open="(">
                               <mrow>
                                  <mn>1000.00001</mn>
                                  <mo>−</mo>
                                  <mi>p</mi>
                               </mrow>
                            </mfenced>
                         </mrow>
                         <mrow>
                            <mrow>
                               <mn>1.003</mn>
                               <mo>−</mo>
                               <mi>j</mi>
                            </mrow>
                         </mrow>
                      </msup>
                   </math>
                </stem>
                <fmt-stem type="MathML">
                   <semx element="stem" source="_">
                      <math xmlns="http://www.w3.org/1998/Math/MathML">
                         <mi>P</mi>
                         <mfenced close=")" open="(">
                            <mrow>
                               <mi>X</mi>
                               <mo>≥</mo>
                               <msub>
                                  <mrow>
                                     <mi>X</mi>
                                  </mrow>
                                  <mrow>
                                     <mo>max</mo>
                                  </mrow>
                               </msub>
                            </mrow>
                         </mfenced>
                         <mo>=</mo>
                         <munderover>
                            <mrow>
                               <mo>∑</mo>
                            </mrow>
                            <mrow>
                               <mrow>
                                  <mi>j</mi>
                                  <mo>=</mo>
                                  <msub>
                                     <mrow>
                                        <mi>X</mi>
                                     </mrow>
                                     <mrow>
                                        <mo>max</mo>
                                     </mrow>
                                  </msub>
                               </mrow>
                            </mrow>
                            <mrow>
                               <mn>1 000</mn>
                            </mrow>
                         </munderover>
                         <mfenced close=")" open="(">
                            <mtable>
                               <mtr>
                                  <mtd>
                                     <mn>0.000 1</mn>
                                  </mtd>
                               </mtr>
                               <mtr>
                                  <mtd>
                                     <mi>j</mi>
                                  </mtd>
                               </mtr>
                            </mtable>
                         </mfenced>
                         <msup>
                            <mrow>
                               <mi>p</mi>
                            </mrow>
                            <mrow>
                               <mi>j</mi>
                            </mrow>
                         </msup>
                         <msup>
                            <mrow>
                               <mfenced close=")" open="(">
                                  <mrow>
                                     <mn>1 000.000 01</mn>
                                     <mo>−</mo>
                                     <mi>p</mi>
                                  </mrow>
                               </mfenced>
                            </mrow>
                            <mrow>
                               <mrow>
                                  <mn>1.003</mn>
                                  <mo>−</mo>
                                  <mi>j</mi>
                               </mrow>
                            </mrow>
                         </msup>
                      </math>
                      <asciimath>P (X ge X_(max)) = sum_(j = X_(max))^(1000) ([[0.0001], [j]]) p^(j) (1000.00001 - p)^(1.003 - j)</asciimath>
                   </semx>
                </fmt-stem>
             </p>
          </preface>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes eref types" do
    output = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", <<~INPUT, true)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
            <clause type="toc" id="_" displayorder="1">
              <title depth="1">Contents</title>
            </clause>
            <foreword>
              <p>
                <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</stem>
                <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</stem>
              </p>
            </foreword>
          </preface>
          <bibliography>
            <references id="_normative_references" normative="true" obligation="informative">
              <title>1<tab/>
                Normative references</title>
              <bibitem id="ISO712" type="standard">
                <formattedref format="text/plain"><em>Cereals and cereal products</em></formattedref>
                <docidentifier>ISO 712</docidentifier>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <abbreviation>ISO</abbreviation>
                  </organization>
                </contributor>
              </bibitem>
            </references>
          </bibliography>
        </iso-standard>
      INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <foreword displayorder="1" id="_">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p>
                   <eref type="footnote" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
                   <semx element="eref" source="_">
                      <sup>
                         <fmt-xref type="footnote" target="ISO712">A</fmt-xref>
                      </sup>
                   </semx>
                   <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">A</fmt-xref>
                   </semx>
                </p>
             </foreword>
             <clause type="toc" id="_" displayorder="2">
                <title depth="1" id="_">Contents</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">Contents</semx>
                </fmt-title>
             </clause>
          </preface>
          <sections>
             <references id="_" normative="true" obligation="informative" displayorder="3">
                <title id="_">
                   1
                   <tab/>
                   Normative references
                </title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">
                         1
                         <tab/>
                         Normative references
                      </semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <bibitem id="ISO712" type="standard">
                   <formattedref format="text/plain">
                      <em>Cereals and cereal products</em>
                   </formattedref>
                   <docidentifier>ISO 712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <abbreviation>ISO</abbreviation>
                      </organization>
                   </contributor>
                   <biblio-tag>
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      ,
                   </biblio-tag>
                </bibitem>
             </references>
          </sections>
          <bibliography>
           
         </bibliography>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes eref content" do
    output = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", <<~INPUT, true)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
            <foreword>
              <p>
                <eref bibitemid="IEV" citeas="IEV" type="inline">
                  <locality type="clause">
                    <referenceFrom>1-2-3</referenceFrom>
                  </locality>
                </eref>
                <eref bibitemid="ISO712" citeas="ISO 712" type="inline"/>
                <eref bibitemid="ISO712" citeas="ISO/IEEE/IEV/IEC/BREAKINGSPACE 712" type="inline"/>
                <eref bibitemid="ISO712" type="inline"/>
                <eref bibitemid="ISO712" type="inline">
                  <locality type="table">
                    <referenceFrom>1</referenceFrom>
                  </locality>
                </eref>
                <eref bibitemid="ISO712" type="inline">
                  <locality type="table">
                    <referenceFrom>1</referenceFrom>
                    <referenceTo>1</referenceTo>
                  </locality>
                </eref>
                <eref bibitemid="ISO712" type="inline">
                  <locality type="clause">
                    <referenceFrom>1</referenceFrom>
                  </locality>
                  <locality type="table">
                    <referenceFrom>1</referenceFrom>
                  </locality>
                </eref>
                <eref bibitemid="ISO712" type="inline">
                  <locality type="clause">
                    <referenceFrom>1</referenceFrom>
                  </locality>
                  <locality type="list">
                    <referenceFrom>a</referenceFrom>
                  </locality>
                </eref>
                <eref bibitemid="ISO712" type="inline">
                  <locality type="clause">
                    <referenceFrom>1</referenceFrom>
                  </locality>
                </eref>
                <eref bibitemid="ISO712" type="inline">
                  <locality type="clause">
                    <referenceFrom>1.5</referenceFrom>
                  </locality>
                </eref>
                <eref bibitemid="ISO712" type="inline">
                  <locality type="table">
                    <referenceFrom>1</referenceFrom>
                  </locality>A</eref>
                <eref bibitemid="ISO712" type="inline">
                  <locality type="whole"/>
                </eref>
                <eref bibitemid="ISO712" type="inline">
                  <locality type="locality:prelude">
                    <referenceFrom>7</referenceFrom>
                  </locality>
                </eref>
                <eref bibitemid="ISO712" citeas="ISO 712" type="inline">A</eref>
                <eref bibitemid="ISO712" citeas="ISO/IEC DIR 1" type="inline"/>
                <eref type="inline" bibitemid="ISO_10303_32" citeas="[ISO 10303-32&lt;fn reference=&quot;1&quot;&gt;&lt;p&gt;To be published.&lt;/p&gt;&#10;&lt;/fn&gt;]"/>
              </p>
            </foreword>
          </preface>
          <bibliography>
            <references id="_normative_references" normative="true" obligation="informative">
              <title>Normative References</title>
              <bibitem id="ISO712" type="standard">
                <title format="text/plain">Cereals and cereal products</title>
                <docidentifier>ISO 712</docidentifier>
                <contributor>
                  <role type="publisher"/>
                  <organization>
                    <name>ISO</name>
                  </organization>
                </contributor>
              </bibitem>
            </references>
          </bibliography>
        </iso-standard>
      INPUT
    expect(Xml::C14n.format(strip_guid(output.sub(/citeas="\[ISO 10303-32[^"]+"/, "citeas"))
      .sub(%r{<i18nyaml>.*</i18nyaml>}m, "")))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p>
                   <eref bibitemid="IEV" citeas="IEV" type="inline" id="_">
                      <locality type="clause">
                         <referenceFrom>1-2-3</referenceFrom>
                      </locality>
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-eref bibitemid="IEV" citeas="IEV" type="inline">
                         <locality type="clause">
                            <referenceFrom>1-2-3</referenceFrom>
                         </locality>
                         <span class="stdpublisher">IEV</span>
                         ,
                         <span class="citesec">1-2-3</span>
                      </fmt-eref>
                   </semx>
                   <eref bibitemid="ISO712" citeas="ISO 712" type="inline" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                      </fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" citeas="ISO/IEEE/IEV/IEC/BREAKINGSPACE 712" type="inline" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                      </fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" type="inline" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                      </fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" type="inline" id="_">
                      <locality type="table">
                         <referenceFrom>1</referenceFrom>
                      </locality>
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                         ,
                         <span class="citetbl">Table 1</span>
                      </fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" type="inline" id="_">
                      <locality type="table">
                         <referenceFrom>1</referenceFrom>
                         <referenceTo>1</referenceTo>
                      </locality>
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                         ,
                         <span class="citetbl">Table 1–1</span>
                      </fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" type="inline" id="_">
                      <locality type="clause">
                         <referenceFrom>1</referenceFrom>
                      </locality>
                      <locality type="table">
                         <referenceFrom>1</referenceFrom>
                      </locality>
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                         ,
                         <span class="citesec">Clause 1</span>
                         ,
                         <span class="citetbl">Table 1</span>
                      </fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" type="inline" id="_">
                      <locality type="clause">
                         <referenceFrom>1</referenceFrom>
                      </locality>
                      <locality type="list">
                         <referenceFrom>a</referenceFrom>
                      </locality>
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                         ,
                         <span class="citesec">Clause 1</span>
                         a)
                      </fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" type="inline" id="_">
                      <locality type="clause">
                         <referenceFrom>1</referenceFrom>
                      </locality>
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                         ,
                         <span class="citesec">Clause 1</span>
                      </fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" type="inline" id="_">
                      <locality type="clause">
                         <referenceFrom>1.5</referenceFrom>
                      </locality>
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                         ,
                         <span class="citesec">1.5</span>
                      </fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" type="inline" id="_">
                      <locality type="table">
                         <referenceFrom>1</referenceFrom>
                      </locality>
                      A
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                 A</fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" type="inline" id="_">
                      <locality type="whole"/>
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                         , Whole of text
                      </fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" type="inline" id="_">
                      <locality type="locality:prelude">
                         <referenceFrom>7</referenceFrom>
                      </locality>
                   </eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                         , Prelude 7
                      </fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" citeas="ISO 712" type="inline" id="_">A</eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">A</fmt-xref>
                   </semx>
                   <eref bibitemid="ISO712" citeas="ISO/IEC DIR 1" type="inline" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">
                         <span class="stdpublisher">ISO </span>
                         <span class="stddocNumber">712</span>
                      </fmt-xref>
                   </semx>
                   <eref type="inline" bibitemid="ISO_10303_32"/>
                   id="_"/&gt;
                   <semx element="eref" source="_">
                      <fmt-eref type="inline" bibitemid="ISO_10303_32" citeas="[ISO 10303-32&lt;fn reference=&quot;1&quot;&gt;&lt;p&gt;To be published.&lt;/p&gt;&#10;&lt;/fn&gt;]">
                         [ISO 10303-32
                         <fn reference="1">
                            <p>To be published.</p>
                         </fn>
                         ]
                      </fmt-eref>
                   </semx>
                </p>
             </foreword>
          </preface>
          <sections>
             <references id="_" normative="true" obligation="informative" displayorder="3">
                <title id="_">Normative References</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <bibitem id="ISO712" type="standard">
                   <formattedref>
                      <em>
                         <span class="stddocTitle">Cereals and cereal products</span>
                      </em>
                   </formattedref>
                   <title format="text/plain">Cereals and cereal products</title>
                   <docidentifier>ISO 712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>ISO</name>
                      </organization>
                   </contributor>
                   <biblio-tag>
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      ,
                   </biblio-tag>
                </bibitem>
             </references>
          </sections>
          <bibliography>
           
         </bibliography>
       </iso-standard>
      OUTPUT
  end

  it "combines locality stacks with connectives, omitting subclauses" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
                  <p id='_'>
              <eref type='inline' bibitemid='ref1' citeas='ITU'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='ITU'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3.1</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>5.1</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='ITU'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3.1</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='ITU'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3.1</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='table'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
            </p>
            </itu-standard>
    INPUT
    output = <<~OUTPUT
        <itu-standard xmlns="https://www.calconnect.org/standards/itu" type="presentation">
           <p id="_">
              <eref type="inline" bibitemid="ref1" citeas="ITU" id="_">
                 <localityStack connective="from">
                    <locality type="clause">
                       <referenceFrom>3</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="to">
                    <locality type="clause">
                       <referenceFrom>5</referenceFrom>
                    </locality>
                 </localityStack>
              </eref>
              <semx element="eref" source="_">
                 <fmt-eref type="inline" bibitemid="ref1" citeas="ITU" droploc="">
                    <localityStack connective="from">
                       <locality type="clause">
                          <referenceFrom>3</referenceFrom>
                       </locality>
                    </localityStack>
                    <localityStack connective="to">
                       <locality type="clause">
                          <referenceFrom>5</referenceFrom>
                       </locality>
                    </localityStack>
                    <span class="stdpublisher">ITU</span>
                    ,
                    <span class="citesec">
                       Clauses
                       <span class="citesec">3</span>
                       <span class="fmt-conn">to</span>
                       <span class="citesec">5</span>
                    </span>
                 </fmt-eref>
              </semx>
              <eref type="inline" bibitemid="ref1" citeas="ITU" id="_">
                 <localityStack connective="from">
                    <locality type="clause">
                       <referenceFrom>3.1</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="to">
                    <locality type="clause">
                       <referenceFrom>5.1</referenceFrom>
                    </locality>
                 </localityStack>
              </eref>
              <semx element="eref" source="_">
                 <fmt-eref type="inline" bibitemid="ref1" citeas="ITU" droploc="">
                    <localityStack connective="from">
                       <locality type="clause">
                          <referenceFrom>3.1</referenceFrom>
                       </locality>
                    </localityStack>
                    <localityStack connective="to">
                       <locality type="clause">
                          <referenceFrom>5.1</referenceFrom>
                       </locality>
                    </localityStack>
                    <span class="stdpublisher">ITU</span>
                    ,
                    <span class="citesec">3.1</span>
                    <span class="fmt-conn">to</span>
                    <span class="citesec">5.1</span>
                 </fmt-eref>
              </semx>
              <eref type="inline" bibitemid="ref1" citeas="ITU" id="_">
                 <localityStack connective="from">
                    <locality type="clause">
                       <referenceFrom>3.1</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="to">
                    <locality type="clause">
                       <referenceFrom>5</referenceFrom>
                    </locality>
                 </localityStack>
              </eref>
              <semx element="eref" source="_">
                 <fmt-eref type="inline" bibitemid="ref1" citeas="ITU">
                    <localityStack connective="from">
                       <locality type="clause">
                          <referenceFrom>3.1</referenceFrom>
                       </locality>
                    </localityStack>
                    <localityStack connective="to">
                       <locality type="clause">
                          <referenceFrom>5</referenceFrom>
                       </locality>
                    </localityStack>
                    <span class="stdpublisher">ITU</span>
                    ,
                    <span class="citesec">3.1</span>
                    <span class="fmt-conn">to</span>
                    <span class="citesec">Clause 5</span>
                 </fmt-eref>
              </semx>
              <eref type="inline" bibitemid="ref1" citeas="ITU" id="_">
                 <localityStack connective="from">
                    <locality type="clause">
                       <referenceFrom>3.1</referenceFrom>
                    </locality>
                 </localityStack>
                 <localityStack connective="to">
                    <locality type="table">
                       <referenceFrom>5</referenceFrom>
                    </locality>
                 </localityStack>
              </eref>
              <semx element="eref" source="_">
                 <fmt-eref type="inline" bibitemid="ref1" citeas="ITU">
                    <localityStack connective="from">
                       <locality type="clause">
                          <referenceFrom>3.1</referenceFrom>
                       </locality>
                    </localityStack>
                    <localityStack connective="to">
                       <locality type="table">
                          <referenceFrom>5</referenceFrom>
                       </locality>
                    </localityStack>
                    <span class="stdpublisher">ITU</span>
                    ,
                    <span class="citesec">3.1</span>
                    <span class="fmt-conn">to</span>
                    <span class="citetbl">Table 5</span>
                 </fmt-eref>
              </semx>
           </p>
        </itu-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

    it "processes footnotes" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword id="F"><title>Foreword</title>
          <p>A.<fn reference="2">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
          <p>B.<fn reference="2">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
          <p>C.<fn reference="1">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
      </fn></p>
          </foreword>
          </preface>
          <sections>
          <clause id="A">
          A.<fn reference="42">
          <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Third footnote.</p>
      </fn></p>
          <p>B.<fn reference="2">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
          </clause>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products<fn reference="7">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">ISO is a standards organisation.</p>
      </fn></title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references>
      </bibliography>
          </iso-standard>
    INPUT
presxml = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
             <foreword id="F" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p>
                   A.
                   <fn reference="1" original-reference="2" id="_" target="_">
                      <p original-id="_">Formerly denoted as 15 % (m/m).</p>
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-label-delim">)</span>
                         </sup>
                      </fmt-fn-label>
                   </fn>
                </p>
                <p>
                   B.
                   <fn reference="1" original-reference="2" id="_" target="_">
                      <p id="_">Formerly denoted as 15 % (m/m).</p>
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-label-delim">)</span>
                         </sup>
                      </fmt-fn-label>
                   </fn>
                </p>
                <p>
                   C.
                   <fn reference="2" original-reference="1" id="_" target="_">
                      <p original-id="_">Hello! denoted as 15 % (m/m).</p>
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">2</semx>
                            <span class="fmt-label-delim">)</span>
                         </sup>
                      </fmt-fn-label>
                   </fn>
                </p>
             </foreword>
          </preface>
          <sections>
             <clause id="A" displayorder="5">
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="A">2</semx>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="A">2</semx>
                </fmt-xref-label>
                A.
                <fn reference="4" original-reference="42" id="_" target="_">
                   <p original-id="_">Third footnote.</p>
                   <fmt-fn-label>
                      <sup>
                         <semx element="autonum" source="_">4</semx>
                         <span class="fmt-label-delim">)</span>
                      </sup>
                   </fmt-fn-label>
                </fn>
             </clause>
             <p displayorder="3">
                B.
                <fn reference="1" original-reference="2" id="_" target="_">
                   <p id="_">Formerly denoted as 15 % (m/m).</p>
                   <fmt-fn-label>
                      <sup>
                         <semx element="autonum" source="_">1</semx>
                         <span class="fmt-label-delim">)</span>
                      </sup>
                   </fmt-fn-label>
                </fn>
             </p>
             <references id="_" obligation="informative" normative="true" displayorder="4">
                <title id="_">Normative References</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                <bibitem id="ISO712" type="standard">
                   <formattedref>
                      <em>
                         <span class="stddocTitle">
                            Cereals and cereal products
                            <fn reference="3" original-reference="7" id="_" target="_">
                               <p original-id="_">ISO is a standards organisation.</p>
                               <fmt-fn-label>
                                  <sup>
                                     <semx element="autonum" source="_">3</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </sup>
                               </fmt-fn-label>
                            </fn>
                         </span>
                      </em>
                   </formattedref>
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">
                      Cereals and cereal products
                      <fn reference="3" original-reference="7" id="_" target="_">
                         <p id="_">ISO is a standards organisation.</p>
                         <fmt-fn-label>
                            <sup>
                               <semx element="autonum" source="_">3</semx>
                               <span class="fmt-label-delim">)</span>
                            </sup>
                         </fmt-fn-label>
                      </fn>
                   </title>
                   <docidentifier type="ISO">ISO 712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                   <biblio-tag>
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      ,
                   </biblio-tag>
                </bibitem>
             </references>
          </sections>
          <bibliography>
       </bibliography>
          <fmt-footnote-container>
             <fmt-fn-body id="_" target="_" reference="1">
                <semx element="fn" source="_">
                   <p id="_">
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">1</semx>
                         </sup>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      Formerly denoted as 15 % (m/m).
                   </p>
                </semx>
             </fmt-fn-body>
             <fmt-fn-body id="_" target="_" reference="2">
                <semx element="fn" source="_">
                   <p id="_">
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">2</semx>
                         </sup>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      Hello! denoted as 15 % (m/m).
                   </p>
                </semx>
             </fmt-fn-body>
             <fmt-fn-body id="_" target="_" reference="3">
                <semx element="fn" source="_">
                   <p id="_">
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">3</semx>
                         </sup>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      ISO is a standards organisation.
                   </p>
                </semx>
             </fmt-fn-body>
             <fmt-fn-body id="_" target="_" reference="4">
                <semx element="fn" source="_">
                   <p id="_">
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">4</semx>
                         </sup>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      Third footnote.
                   </p>
                </semx>
             </fmt-fn-body>
          </fmt-footnote-container>
       </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div id="F">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p>
                      A.
                      <a class="FootnoteRef" href="#_">
                         <sup>1)</sup>
                      </a>
                   </p>
                   <p>
                      B.
                      <a class="FootnoteRef" href="#_">
                         <sup>1)</sup>
                      </a>
                   </p>
                   <p>
                      C.
                      <a class="FootnoteRef" href="#_">
                         <sup>2)</sup>
                      </a>
                   </p>
                </div>
                <p>
                   B.
                   <a class="FootnoteRef" href="#_">
                      <sup>1)</sup>
                   </a>
                </p>
                <div>
                   <h1>1  Normative References</h1>
                   <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                   <p id="ISO712" class="NormRef">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      ,
                      <i>
                         <span class="stddocTitle">
                            Cereals and cereal products
                            <a class="FootnoteRef" href="#_">
                               <sup>3)</sup>
                            </a>
                         </span>
                      </i>
                   </p>
                </div>
                <div id="A">
                   <h1>2</h1>
                   <a class="FootnoteRef" href="#_">
                      <sup>4)</sup>
                   </a>
                </div>
                <aside id="_" class="footnote">
                   <p id="_">Formerly denoted as 15 % (m/m).</p>
                </aside>
                <aside id="_" class="footnote">
                   <p id="_">Hello! denoted as 15 % (m/m).</p>
                </aside>
                <aside id="_" class="footnote">
                   <p id="_">ISO is a standards organisation.</p>
                </aside>
                <aside id="_" class="footnote">
                   <p id="_">Third footnote.</p>
                </aside>
             </div>
          </body>
       </html>
    OUTPUT
    doc = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
             <p> </p>
          </div>
          <p class="section-break">
             <br clear="all" class="section"/>
          </p>
          <div class="WordSection2">
             <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="_" class="TOC">
                <p class="zzContents">Contents</p>
             </div>
             <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="F">
                <h1 class="ForewordTitle">Foreword</h1>
                <p class="ForewordText">
                   A.
                   <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                      <a class="FootnoteRef" epub:type="footnote" href="#_">1</a>
                      )
                   </span>
                </p>
                <p class="ForewordText">
                   B.
                   <span class="MsoFootnoteReference">
                      <span style="mso-element:field-begin"/>
                      NOTEREF _Ref \\f \\h
                      <span style="mso-element:field-separator"/>
                      1
                      <span style="mso-element:field-end"/>
                      )
                   </span>
                </p>
                <p class="ForewordText">
                   C.
                   <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                      <a class="FootnoteRef" epub:type="footnote" href="#_">2</a>
                      )
                   </span>
                </p>
             </div>
             <p> </p>
          </div>
          <p class="section-break">
             <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
             <p>
                B.
                <span class="MsoFootnoteReference">
                   <span style="mso-element:field-begin"/>
                   NOTEREF _Ref \\f \\h
                   <span style="mso-element:field-separator"/>
                   1
                   <span style="mso-element:field-end"/>
                   )
                </span>
             </p>
             <div>
                <h1>
                   1
                   <span style="mso-tab-count:1">  </span>
                   Normative References
                </h1>
                <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                <p id="ISO712" class="NormRef">
                   <span class="stdpublisher">ISO </span>
                   <span class="stddocNumber">712</span>
                   ,
                   <i>
                      <span class="stddocTitle">
                         Cereals and cereal products
                         <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                            <a class="FootnoteRef" epub:type="footnote" href="#_">3</a>
                            )
                         </span>
                      </span>
                   </i>
                </p>
             </div>
             <div id="A">
                <h1>2</h1>
                <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                   <a class="FootnoteRef" epub:type="footnote" href="#_">4</a>
                   )
                </span>
             </div>
             <aside id="_">
                <p id="_">Formerly denoted as 15 % (m/m).</p>
             </aside>
             <aside id="_">
                <p id="_">Hello! denoted as 15 % (m/m).</p>
             </aside>
             <aside id="_">
                <p id="_">ISO is a standards organisation.</p>
             </aside>
             <aside id="_">
                <p id="_">Third footnote.</p>
             </aside>
          </div>
          <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
          <div class="colophon"/>
       </body>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(html))
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true))
      .at("//body").to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(doc))
  end
end
