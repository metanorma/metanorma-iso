require "spec_helper"

RSpec.describe IsoDoc do
  it "processes inline formatting" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~INPUT, true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <clause type="toc" id="_" displayorder="1">
            <fmt-title depth="1">Contents</fmt-title>
          </clause>
          <foreword displayorder="2"><fmt-title>Foreword</fmt-title>
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
            <div>
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

  it "processes links" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~INPUT, true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <clause type="toc" id="_" displayorder="1">
            <fmt-title depth="1">Contents</fmt-title>
          </clause>
          <foreword displayorder="2"><fmt-title>Foreword</fmt-title>
            <p>
              <link target="http://example.com"/>
              <link target="http://example.com">example</link>
              <link target="mailto:fred@example.com"/>
              <link target="mailto:fred@example.com">mailto:fred@example.com</link>
            </p>
          </foreword>
        </preface>
        <sections/>
      </iso-standard>
    INPUT
    expect(Xml::C14n.format(output)).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p>
                <a href="http://example.com">http://example.com</a>
                <a href="http://example.com">example</a>
                <a href="mailto:fred@example.com">fred@example.com</a>
                <a href="mailto:fred@example.com">mailto:fred@example.com</a>
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
          <foreword displayorder="2"><fmt-title>Foreword</fmt-title>
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
            <div>
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
          <foreword displayorder="2"><fmt-title>Foreword</fmt-title>
            <p>
              <stem type="AsciiMath">A</stem>
              <stem type="MathML"><m:math><m:row>X</m:row></m:math></stem>
              <stem type="None">Latex?</stem>
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
              <div>
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
          <foreword displayorder="2"><fmt-title>Foreword</fmt-title>
            <p><stem type="AsciiMath">A</stem>(#((Hello))#)</p>
          </foreword>
        </preface>
        <sections>
      </iso-standard>
    INPUT
    expect(Xml::C14n.format(output)).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{HTML_HDR}
              <br/>
              <div>
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
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibdata>
          <title language="en">test</title>
          <language current="true">en</language>
        </bibdata>
        <preface>
            <clause type="toc" id="_" displayorder="1">
            <fmt-title depth="1">Contents</fmt-title>
            </clause>
          <p displayorder="2">
             30&#xa0;000
             3&#xa0;000.000&#xa0;3
             3&#xa0;000&#xa0;000.000&#xa0;000&#xa0;3
             0.000&#xa0;3
             0.000&#xa0;000&#xa0;3
             3&#xa0;000
             3&#xa0;000&#xa0;000
             <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>P</mi><mfenced close=")" open="("><mrow><mi>X</mi><mo>≥</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mfenced><mo>=</mo><munderover><mrow><mo>∑</mo></mrow><mrow><mrow><mi>j</mi><mo>=</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mrow><mrow><mn>1&#xa0;000</mn></mrow></munderover><mfenced close=")" open="("><mtable><mtr><mtd><mn>0.000&#xa0;1</mn></mtd></mtr><mtr><mtd><mi>j</mi></mtd></mtr></mtable></mfenced><msup><mrow><mi>p</mi></mrow><mrow><mi>j</mi></mrow></msup><msup><mrow><mfenced close=")" open="("><mrow><mn>1&#xa0;000.000&#xa0;01</mn><mo>−</mo><mi>p</mi></mrow></mfenced></mrow><mrow><mrow><mn>1.003</mn><mo>−</mo><mi>j</mi></mrow></mrow></msup></math><asciimath>P (X ge X_(max)) = sum_(j = X_(max))^(1000) ([[0.0001], [j]]) p^(j) (1000.00001 - p)^(1.003 - j)</asciimath></stem>
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
             <foreword displayorder="1">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p>
                   <sup>
                      <xref type="footnote" target="ISO712">A</xref>
                   </sup>
                   <xref type="inline" target="ISO712">A</xref>
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
    expect(Xml::C14n.format(strip_guid(output))).to be_equivalent_to Xml::C14n.format(presxml)
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
             <foreword displayorder="2">
                      <title id="_">Foreword</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
                <p>
                   <eref bibitemid="IEV" citeas="IEV" type="inline">
                      <locality type="clause">
                         <referenceFrom>1-2-3</referenceFrom>
                      </locality>
                      <span class="stdpublisher">IEV</span>
                      ,
                      <span class="citesec">1-2-3</span>
                   </eref>
                   <xref type="inline" target="ISO712">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                   </xref>
                   <xref type="inline" target="ISO712">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                   </xref>
                   <xref type="inline" target="ISO712">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                   </xref>
                   <xref type="inline" target="ISO712">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      ,
                      <span class="citetbl">Table 1</span>
                   </xref>
                   <xref type="inline" target="ISO712">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      ,
                      <span class="citetbl">Table 1–1</span>
                   </xref>
                   <xref type="inline" target="ISO712">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      ,
                      <span class="citesec">Clause 1</span>
                      ,
                      <span class="citetbl">Table 1</span>
                   </xref>
                   <xref type="inline" target="ISO712">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      ,
                      <span class="citesec">Clause 1</span>
                      a)
                   </xref>
                   <xref type="inline" target="ISO712">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      ,
                      <span class="citesec">Clause 1</span>
                   </xref>
                   <xref type="inline" target="ISO712">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      ,
                      <span class="citesec">1.5</span>
                   </xref>
                   <xref type="inline" target="ISO712">
                 A</xref>
                   <xref type="inline" target="ISO712">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      , Whole of text
                   </xref>
                   <xref type="inline" target="ISO712">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                      , Prelude 7
                   </xref>
                   <xref type="inline" target="ISO712">A</xref>
                   <xref type="inline" target="ISO712">
                      <span class="stdpublisher">ISO </span>
                      <span class="stddocNumber">712</span>
                   </xref>
                   <eref type="inline" bibitemid="ISO_10303_32">
                      [ISO 10303-32
                      <fn reference="1">
                         <p>To be published.</p>
                      </fn>
                      ]
                   </eref>
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
                   <docidentifier>ISO 712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
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

  it "processes concept markup" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="Terms">
          <term id="B"><preferred><expression><name>B</name></expression></preferred>
          <p>
          <ul>
            <li><concept><refterm>term0</refterm>
              <xref target='clause1'/>
            </concept></li>
            <li><concept><refterm>term1</refterm>
              <renderterm>term</renderterm>
              <xref target='clause1'/>
            </concept></li>
          <li><concept><refterm>term2</refterm>
              <renderterm>w[o]rd</renderterm>
              <xref target='clause1'>Clause #1</xref>
            </concept></li>
            <li><concept><refterm>term3</refterm>
              <renderterm>term</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712"/>
            </concept></li>
            <li><concept><refterm>term4</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">The Aforementioned Citation</eref>
            </concept></li>
            <li><concept><refterm>term5</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
                <locality type='figure'>
                  <referenceFrom>a</referenceFrom>
                </locality>
              </eref>
            </concept></li>
            <li><concept><refterm>term6</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack connective="and">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack connective="and">
                <locality type='figure'>
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              </eref>
            </concept></li>
            <li><concept><refterm>term7</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack connective="and">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack connective="and">
                <locality type='figure'>
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              The Aforementioned Citation
              </eref>
            </concept></li>
            <li><concept><refterm>term8</refterm>
              <renderterm>word</renderterm>
              <termref base='IEV' target='135-13-13'/>
            </concept></li>
            <li><concept><refterm>term9</refterm>
              <renderterm>word</renderterm>
              <termref base='IEV' target='135-13-13'>The IEV database</termref>
            </concept></li>
            <li><concept><refterm>term10</refterm>
              <renderterm>word</renderterm>
              <strong>error!</strong>
            </concept></li>
            </ul>
          </p>
          </term>
          </terms>
          <clause id="clause1"><title>Clause 1</title></clause>
          </sections>
          <bibliography><references id="_" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
         <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
                  <preface>
          <clause type="toc" id="_" displayorder="1">
          <fmt-title depth="1">Contents</fmt-title>
          </clause>
        </preface>
        <sections>
          <terms id="Terms" displayorder="3">
                  <fmt-title depth="1">
           <span class="fmt-caption-label">
              <semx element="autonum" source="Terms">2</semx>
           </span>
        </fmt-title>
        <fmt-xref-label>
           <span class="fmt-element-name">Clause</span>
           <semx element="autonum" source="Terms">2</semx>
        </fmt-xref-label>
            <term id="B">
                        <fmt-name>
               <span class="fmt-caption-label">
                  <semx element="autonum" source="Terms">2</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="B">1</semx>
               </span>
            </fmt-name>
            <fmt-xref-label>
                  <semx element="autonum" source="Terms">2</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="B">1</semx>
            </fmt-xref-label>
              <preferred>
                <strong>B</strong>
              </preferred>
              <p>
                <ul>
                  <li>
              (<xref target="clause1"><span class="citesec"><span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="clause1">3</semx>
              </span></xref>)
            </li>
                  <li><em>term</em>
              (<xref target="clause1"><span class="citesec"><span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="clause1">3</semx></span></xref>)
            </li>
                  <li><em>w[o]rd</em>
              (<xref target="clause1">Clause #1</xref>)
            </li>
                  <li><em>term</em>
              (<xref type="inline" target="ISO712"><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span></xref>)
            </li>
                  <li><em>word</em>
              (<xref type="inline" target="ISO712">The Aforementioned Citation</xref>)
            </li>
                  <li><em>word</em>
              (<xref type="inline" target="ISO712"><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span>, <span class="citesec">3.1</span>, <span class="citefig">Figure a</span></xref>)
            </li>
                  <li><em>word</em>
              (<xref type="inline" target="ISO712"><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span>, <span class="citesec">3.1</span> <span class="fmt-conn">and</span> <span class="citefig">Figure b</span></xref>)
            </li>
                  <li><em>word</em>
              (<xref type="inline" target="ISO712">


              The Aforementioned Citation
              </xref>)
            </li>
                  <li><em>word</em>
              (<termref base="IEV" target="135-13-13"/>)
            </li>
                  <li><em>word</em>
              (<termref base="IEV" target="135-13-13">The IEV database</termref>)
            </li>
                  <li>
                    <em>word</em>
                    <strong>error!</strong>
                  </li>
                </ul>
              </p>
            </term>
          </terms>
          <clause id="clause1" displayorder="4">
                   <title id="_">Clause 1</title>
         <fmt-title depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="clause1">3</semx>
               </span>
               <span class="fmt-caption-delim">
                  <tab/>
               </span>
               <semx element="title" source="_">Clause 1</semx>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="clause1">3</semx>
         </fmt-xref-label>
         </clause>
      <references id="_" obligation="informative" normative="true" displayorder="2">
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
                  <span class="stddocTitle">Cereals and cereal products</span>
                </em>
              </formattedref>
              <docidentifier type="ISO">ISO 712</docidentifier>
              <docidentifier scope="biblio-tag">ISO 712</docidentifier>
            <biblio-tag>
               <span class="stdpublisher">ISO </span>
               <span class="stddocNumber">712</span>
               ,
            </biblio-tag>
            </bibitem>
          </references>
        </sections>
        <bibliography/>
      </iso-standard>
    OUTPUT
    output = <<~OUTPUT
      #{HTML_HDR}
             <div>
               <h1>1  Normative References</h1>
               <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
               <p id="ISO712" class="NormRef"><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span>, <i><span class="stddocTitle">Cereals and cereal products</span></i></p>
             </div>
                          <div id="Terms">
               <h1>2</h1>
               <p class="TermNum" id="B">2.1</p>
               <p class="Terms" style="text-align:left;">
                 <b>B</b>
               </p>
               <p>
               <div class="ul_wrap">
                 <ul>
                   <li>
               (<a href="#clause1"><span class="citesec">Clause 3</span></a>)
             </li>
                   <li><i>term</i>
               (<a href="#clause1"><span class="citesec">Clause 3</span></a>)
             </li>
                   <li><i>w[o]rd</i>
               (<a href="#clause1">Clause #1</a>)
             </li>
                   <li><i>term</i>
               (<a href="#ISO712"><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span></a>)
             </li>
                   <li><i>word</i>
               (<a href="#ISO712">The Aforementioned Citation</a>)
             </li>
                   <li><i>word</i>
               (<a href="#ISO712"><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span>, <span class="citesec">3.1</span>, <span class="citefig">Figure a</span></a>)
             </li>
                   <li><i>word</i>
               (<a href="#ISO712"><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span>, <span class="citesec">3.1</span> and <span class="citefig">Figure b</span></a>)
             </li>
                   <li><i>word</i>
               (<a href="#ISO712">


               The Aforementioned Citation
               </a>)
             </li>
                   <li><i>word</i>
               (Termbase IEV, term ID 135-13-13)
             </li>
                   <li><i>word</i>
               (The IEV database)
             </li>
                   <li>
                     <i>word</i>
                     <b>error!</b>
                   </li>
                 </ul>
                 </div>
               </p>
             </div>
             <div id="clause1">
               <h1>3  Clause 1</h1>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes concept markup by context" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword id="A">
      <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
      </foreword></preface>
      <sections>
      <terms id="Terms">
      <clause id="A">
             <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
      </clause>
      <term id="clause1">
       <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
        </term>
      <term id="clause2">
       <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
        </term>
             <term id="clause3">
       <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
        <term id="clause4">
               <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
        </term>
        </term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Contents</fmt-title>
              </clause>
              <foreword id="A" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="2">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="Terms">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="A">1</semx>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <semx element="autonum" source="Terms">1</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="A">1</semx>
                 </fmt-xref-label>
                 <ul>
                    <li>
            term
            
          </li>
                 </ul>
              </foreword>
           </preface>
           <sections>
              <terms id="Terms" displayorder="3">
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="Terms">1</semx>
                    </span>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="Terms">1</semx>
                 </fmt-xref-label>
                 <clause id="A" inline-header="true">
                    <fmt-title depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="Terms">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="A">1</semx>
                       </span>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="Terms">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="A">1</semx>
                    </fmt-xref-label>
                    <ul>
                       <li>
            term
            
          </li>
                    </ul>
                 </clause>
                 <term id="clause1">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="Terms">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="clause1">2</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="Terms">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="clause1">2</semx>
                    </fmt-xref-label>
                    <ul>
                       <li>
                          <em>term</em>
                          (
                          <xref target="clause1">
                             <span class="citesec">
                                <semx element="autonum" source="Terms">1</semx>
                                <span class="fmt-autonum-delim">.</span>
                                <semx element="autonum" source="clause1">2</semx>
                             </span>
                          </xref>
                          )
                       </li>
                       <li>
            term
            
          </li>
                    </ul>
                 </term>
                 <term id="clause2">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="Terms">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="clause2">3</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="Terms">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="clause2">3</semx>
                    </fmt-xref-label>
                    <ul>
                       <li>
                          <em>term</em>
                          (
                          <xref target="clause1">
                             <span class="citesec">
                                <semx element="autonum" source="Terms">1</semx>
                                <span class="fmt-autonum-delim">.</span>
                                <semx element="autonum" source="clause1">2</semx>
                             </span>
                          </xref>
                          )
                       </li>
                       <li>
            term
            
          </li>
                    </ul>
                 </term>
                 <term id="clause3">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="Terms">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="clause3">4</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="Terms">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="clause3">4</semx>
                    </fmt-xref-label>
                    <ul>
                       <li>
                          <em>term</em>
                          (
                          <xref target="clause1">
                             <span class="citesec">
                                <semx element="autonum" source="Terms">1</semx>
                                <span class="fmt-autonum-delim">.</span>
                                <semx element="autonum" source="clause1">2</semx>
                             </span>
                          </xref>
                          )
                       </li>
                       <li>
            term
            
          </li>
                    </ul>
                    <term id="clause4">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <semx element="autonum" source="Terms">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="clause3">4</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="clause4">1</semx>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <semx element="autonum" source="Terms">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="clause3">4</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="clause4">1</semx>
                       </fmt-xref-label>
                       <ul>
                          <li>
                             <em>term</em>
                             (
                             <xref target="clause1">
                                <span class="citesec">
                                   <semx element="autonum" source="Terms">1</semx>
                                   <span class="fmt-autonum-delim">.</span>
                                   <semx element="autonum" source="clause1">2</semx>
                                </span>
                             </xref>
                             )
                          </li>
                          <li>
            term
            
          </li>
                       </ul>
                    </term>
                 </term>
              </terms>
           </sections>
        </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
       .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes concept attributes" do
    input = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <clause id="clause1"><title>Clause 1</title></clause>
       <terms id="A">
       <term id="B"><preferred><expression><name>B</name></expression></preferred<
       <p>
       <ul>
       <li>
              <concept ital="true"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
         <li><concept ref="true"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
       <li><concept ital="true" ref="true"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
        <li><concept ital="false"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
         <li><concept ref="false"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
       <li><concept ital="false" ref="false"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
       <li><concept ital="true" ref="true" linkmention="true" linkref="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept></li>
       <li><concept ital="true" ref="true" linkmention="true" linkref="false"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept></li>
       <li><concept ital="true" ref="true" linkmention="false" linkref="true"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept></li>
       <li><concept ital="true" ref="true" linkmention="false" linkref="false"><refterm>term</refterm><renderterm>term</renderterm><xref target='clause1'/></concept></li>
        </ul></p>
        </term>
       </terms>
       </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <preface>
          <clause type="toc" id="_" displayorder="1">
          <fmt-title depth="1">Contents</fmt-title>
          </clause>
        </preface>
        <sections>
        <clause id="clause1" displayorder="2">
                 <title id="_">Clause 1</title>
         <fmt-title depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="clause1">1</semx>
               </span>
               <span class="fmt-caption-delim">
                  <tab/>
               </span>
               <semx element="title" source="_">Clause 1</semx>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="clause1">1</semx>
         </fmt-xref-label>
        </clause>
        <terms id="A" displayorder="3">
         <fmt-title depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="A">2</semx>
            </span>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="A">2</semx>
         </fmt-xref-label>
        <term id='B'>
                    <fmt-name>
               <span class="fmt-caption-label">
                  <semx element="autonum" source="A">2</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="B">1</semx>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <semx element="autonum" source="A">2</semx>
               <span class="fmt-autonum-delim">.</span>
               <semx element="autonum" source="B">1</semx>
            </fmt-xref-label>
      <preferred><strong>B</strong></preferred>
        <p>
        <ul>
        <li>
            <em>term</em>
            (<xref target="clause1"><span class="citesec">
                           <span class="fmt-element-name">Clause</span>
                           <semx element="autonum" source="clause1">1</semx>
                        </span>
                        </xref>)
          </li>
          <li>
            term
            (<xref target="clause1"><span class="citesec">
                           <span class="fmt-element-name">Clause</span>
                           <semx element="autonum" source="clause1">1</semx>
                        </span></xref>)
          </li>
        <li>
            <em>term</em>
            (<xref target="clause1"><span class="citesec">
                           <span class="fmt-element-name">Clause</span>
                           <semx element="autonum" source="clause1">1</semx>
                        </span></xref>)
          </li>
                                   <li>
             term

           </li>
                          <li>
             term

           </li>
                          <li>
             term
        </li>
        <li><xref target="clause1"><em>term</em></xref> (<xref target="clause1"><span class="citesec">
                           <span class="fmt-element-name">Clause</span>
                           <semx element="autonum" source="clause1">1</semx>
                        </span></xref>)</li>
        <li><xref target="clause1"><em>term</em></xref> (<span class="citesec">
                        <span class="fmt-element-name">Clause</span>
                        <semx element="autonum" source="clause1">1</semx>
                     </span>
        )</li>
        <li><em>term</em> (<xref target="clause1"><span class='citesec'>
                           <span class="fmt-element-name">Clause</span>
                           <semx element="autonum" source="clause1">1</semx>
                        </span></xref>)</li>
        <li><em>term</em> (<span class="citesec">
                           <span class="fmt-element-name">Clause</span>
                           <semx element="autonum" source="clause1">1</semx>
                        </span>)</li>
         </ul></p>
         </term>
        </terms>
        </sections>
       </iso-standard>
    OUTPUT
    output = <<~OUTPUT
        #{HTML_HDR}
            <div id="clause1">
              <h1>1  Clause 1</h1>
            </div>
            <div id="A">
              <h1>2</h1>
              <p class="TermNum" id="B">2.1</p>
              <p class="Terms" style="text-align:left;">
                <b>B</b>
              </p>
              <p>
              <div class="ul_wrap">
                <ul>
                  <li><i>term</i>
            (<a href="#clause1"><span class="citesec">Clause 1</span></a>)
          </li>
                  <li>
            term
            (<a href="#clause1"><span class="citesec">Clause 1</span></a>)
          </li>
                  <li><i>term</i>
            (<a href="#clause1"><span class="citesec">Clause 1</span></a>)
          </li>
                  <li>
            term
          </li>
                  <li>
            term
          </li>
                  <li>
            term
          </li>
                  <li><a href="#clause1"><i>term</i></a> (<a href="#clause1"><span class="citesec">Clause 1</span></a>)</li>
                  <li><a href="#clause1"><i>term</i></a> (<span class="citesec">Clause 1</span>)</li>
                  <li><i>term</i> (<a href="#clause1"><span class="citesec">Clause 1</span></a>)</li>
                  <li><i>term</i> (<span class="citesec">Clause 1</span>)</li>
                </ul>
                </div>
              </p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)))).to be_equivalent_to Xml::C14n.format(output)
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
          <eref type="inline" bibitemid="ref1" citeas="ITU" droploc=""><localityStack connective="from"><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack><localityStack connective="to"><locality type="clause"><referenceFrom>5</referenceFrom></locality></localityStack><span class="stdpublisher">ITU</span>,  <span class="citesec">Clauses  <span class="citesec">3</span> <span class="fmt-conn">to</span>  <span class="citesec">5</span></span></eref>
          <eref type="inline" bibitemid="ref1" citeas="ITU" droploc=""><localityStack connective="from"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></localityStack><localityStack connective="to"><locality type="clause"><referenceFrom>5.1</referenceFrom></locality></localityStack><span class="stdpublisher">ITU</span>,    <span class="citesec">3.1</span> <span class="fmt-conn">to</span>  <span class="citesec">5.1</span></eref>
          <eref type="inline" bibitemid="ref1" citeas="ITU"><localityStack connective="from"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></localityStack><localityStack connective="to"><locality type="clause"><referenceFrom>5</referenceFrom></locality></localityStack><span class="stdpublisher">ITU</span>,  <span class="citesec">3.1</span> <span class="fmt-conn">to</span>  <span class="citesec">Clause 5</span></eref>
          <eref type="inline" bibitemid="ref1" citeas="ITU"><localityStack connective="from"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></localityStack><localityStack connective="to"><locality type="table"><referenceFrom>5</referenceFrom></locality></localityStack><span class="stdpublisher">ITU</span>,  <span class="citesec">3.1</span> <span class="fmt-conn">to</span>  <span class="citetbl">Table 5</span></eref>
        </p>
      </itu-standard>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
