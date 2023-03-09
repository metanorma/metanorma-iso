require "spec_helper"

RSpec.describe IsoDoc do
  it "processes examples" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <example id="samplecode">
              <name>Title</name>
              <p>Hello</p>
            </example>
          </foreword>
        </preface>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword displayorder="1">
            <example id="samplecode">
              <name>EXAMPLE — Title</name>
              <p>Hello</p>
            </example>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <div id="samplecode" class="example">
                <p><span class="example_label">EXAMPLE&#160;&#8212; Title</span>&#160; Hello</p>
              </div>
            </div>
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      </html>
    OUTPUT

    word = <<~OUTPUT
          <body lang="EN-US" link="blue" vlink="#954F72">
        <div class="WordSection1">
          <p>&#160;</p>
        </div>
        <p>
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection2">
          <p>
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div>
            <h1 class="ForewordTitle">Foreword</h1>
            <div id="samplecode" class="example">
              <p><span class="example_label">EXAMPLE&#160;&#8212; Title</span><span style="mso-tab-count:1">&#160; </span>Hello</p>
            </div>
          </div>
          <p>&#160;</p>
        </div>
        <p>
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
          <p class="zzSTDTitle1"/>
        </div>
        <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"/>
      </body>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, true)
    expect(xmlpp(output
      .sub(/^.*<body/m, "<body").sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to xmlpp(word)
  end

  it "processes sequences of examples" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <example id="samplecode">
              <quote>Hello</quote>
            </example>
            <example id="samplecode2">
              <name>Title</name>
              <p>Hello</p>
            </example>
          </foreword>
        </preface>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword displayorder="1">
            <example id="samplecode">
              <name>EXAMPLE 1</name>
              <quote>Hello</quote>
            </example>
            <example id="samplecode2">
              <name>EXAMPLE 2 — Title</name>
              <p>Hello</p>
            </example>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <div id="samplecode" class="example">
                <p><span class="example_label">EXAMPLE  1</span>&#160; </p>
                 <div class="Quote">Hello</div>
              </div>
              <div id="samplecode2" class="example">
                <p><span class="example_label">EXAMPLE  2&#160;&#8212; Title</span>&#160; Hello</p>
              </div>
            </div>
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      </html>
    OUTPUT
    word = <<~OUTPUT
          <body lang="EN-US" link="blue" vlink="#954F72">
        <div class="WordSection1">
          <p>&#160;</p>
        </div>
        <p>
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection2">
          <p>
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div>
            <h1 class="ForewordTitle">Foreword</h1>
            <div id="samplecode" class="example">
              <p><span class="example_label">EXAMPLE  1</span><span style="mso-tab-count:1">&#160; </span></p>
              <div class="Quote">Hello</div>
            </div>
            <div id="samplecode2" class="example">
              <p><span class="example_label">EXAMPLE  2&#160;&#8212; Title</span><span style="mso-tab-count:1">&#160; </span>Hello</p>
            </div>
          </div>
          <p>&#160;</p>
        </div>
        <p>
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
          <p class="zzSTDTitle1"/>
        </div>
        <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"/>
      </body>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, true)
    expect(xmlpp(output
      .sub(/^.*<body/m, "<body").sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to xmlpp(word)
  end

  it "processes admonitions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
          <name>CAUTION</name>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f3">Para 2.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type='presentation'>
          <preface><foreword displayorder="1">
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
                         <p id='_e94663cc-2473-4ccc-9a72-983a74d989f2'>
                 CAUTION — Only use paddy or parboiled rice for the
                 determination of husked rice yield.
               </p>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f3">Para 2.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                   <br/>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <div id='_70234f78-64e5-4dfc-8b6f-f3f037348b6a' class='Admonition'>
                 <p>
                    CAUTION — Only use paddy or parboiled rice for the
                   determination of husked rice yield.
                 </p>
                 <p id='_e94663cc-2473-4ccc-9a72-983a74d989f3'>Para 2.</p>
               </div>
             </div>
             <p class='zzSTDTitle1'/>
           </div>
         </body>
       </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes admonitions with titles" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
          <name>Title</name>
          <ul>
          <li>List</li>
          </ul>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type='presentation'>
          <preface><foreword displayorder="1">
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
          <name>Title</name>
          <ul>
          <li>List</li>
          </ul>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                    <br/>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <div id='_70234f78-64e5-4dfc-8b6f-f3f037348b6a' class='Admonition'>
                        <p>Title — </p>
         <ul>
           <li>List</li>
         </ul>
         <p id='_e94663cc-2473-4ccc-9a72-983a74d989f2'>Only use paddy or parboiled rice for the determination of husked rice yield.</p>
               </div>
             </div>
             <p class='zzSTDTitle1'/>
           </div>
         </body>
       </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes editorial notes" do
    input = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="editorial">
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f3">Para 2.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type='presentation'>
          <preface><foreword displayorder="1">
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="editorial">
                         <p id='_e94663cc-2473-4ccc-9a72-983a74d989f2'>EDITORIAL NOTE —
                 Only use paddy or parboiled rice for the
                 determination of husked rice yield.
               </p>
        <p id="_e94663cc-2473-4ccc-9a72-983a74d989f3">Para 2.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                   <br/>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <div id='_70234f78-64e5-4dfc-8b6f-f3f037348b6a' class='zzHelp'>
                 <p>EDITORIAL NOTE —
                    Only use paddy or parboiled rice for the
                   determination of husked rice yield.
                 </p>
                 <p id='_e94663cc-2473-4ccc-9a72-983a74d989f3'>Para 2.</p>
               </div>
             </div>
             <p class='zzSTDTitle1'/>
           </div>
         </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
        <div class='WordSection2'>
      <p>
        <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
      </p>
      <div>
        <h1 class='ForewordTitle'>Foreword</h1>
        <div id='_70234f78-64e5-4dfc-8b6f-f3f037348b6a' class='zzHelp'>
          <p>EDITORIAL NOTE — Only use paddy or parboiled rice for the determination of husked rice yield. </p>
          <p class='ForewordText' id='_e94663cc-2473-4ccc-9a72-983a74d989f3'>Para 2.</p>
        </div>
      </div>
      <p> </p>
      </div>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::WordConvert.new({})
      .convert("test", presxml, true))
      .at("//div[@class = 'WordSection2']").to_xml))
      .to be_equivalent_to xmlpp(word)
  end

  it "renders figures" do
    input = <<~INPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml'>
        <preface>
          <foreword id='fwd'>
            <p>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id='scope' type="scope">
            <title>Scope</title>
            <figure id='N'>
              <name>Figure 1&#xA0;&#x2014; Split-it-right sample divider</name>
              <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
            </figure>
            <p>
            </p>
          </clause>
          <terms id='terms'/>
          <clause id='widgets'>
            <title>Widgets</title>
            <clause id='widgets1'>
              <figure id='note1'>
                <name>Figure 2&#xA0;&#x2014; Split-it-right sample divider</name>
                <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
              </figure>
              <figure id='note2'>
                <name>Figure 3&#xA0;&#x2014; Split-it-right sample divider</name>
                <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
              </figure>
              <p>
              </p>
            </clause>
          </clause>
        </sections>
        <annex id='annex1'>
          <clause id='annex1a'>
            <figure id='AN'>
              <name>Figure A.1&#xA0;&#x2014; Split-it-right sample divider</name>
              <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
            </figure>
          </clause>
          <clause id='annex1b'>
            <figure id='Anote1'>
              <name>Figure A.2&#xA0;&#x2014; Split-it-right sample divider</name>
              <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
            </figure>
            <figure id='Anote2'>
              <name>Figure A.3&#xA0;&#x2014; Split-it-right sample divider</name>
              <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
            </figure>
          </clause>
        </annex>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
          <br/>
          <div id="fwd">
            <h1 class="ForewordTitle">Foreword</h1>
            <p>
            </p>
          </div>
          <p class="zzSTDTitle1"/>
          <div id="scope">
            <h1>Scope</h1>
            <div id="N" class="figure">
              <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
              <p class="FigureTitle" style="text-align:center;">Figure 1&#160;&#8212; Split-it-right sample divider</p>
            </div>
            <p>
            </p>
          </div>
          <div id="terms"><h1/></div>
          <div id="widgets">
            <h1>Widgets</h1>
            <div id="widgets1">
              <div id="note1" class="figure">
                <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
                <p class="FigureTitle" style="text-align:center;">Figure 2&#160;&#8212; Split-it-right sample divider</p>
              </div>
              <div id="note2" class="figure">
                <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
                <p class="FigureTitle" style="text-align:center;">Figure 3&#160;&#8212; Split-it-right sample divider</p>
              </div>
              <p>   </p>
            </div>
          </div>
          <br/>
          <div id="annex1" class="Section3">
            <div id="annex1a">
              <div id="AN" class="figure">
                <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
                <p class="FigureTitle" style="text-align:center;">Figure A.1&#160;&#8212; Split-it-right sample divider</p>
              </div>
            </div>
            <div id="annex1b">
              <div id="Anote1" class="figure">
                  <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
                  <p class="FigureTitle" style="text-align:center;">Figure A.2&#160;&#8212; Split-it-right sample divider</p>
                </div>
                <div id="Anote2" class="figure">
                  <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
                  <p class="FigureTitle" style="text-align:center;">Figure A.3&#160;&#8212; Split-it-right sample divider</p>
                </div>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    word = <<~OUTPUT
      <body lang='EN-US' link='blue' vlink='#954F72'>
        <div class='WordSection1'>
          <p>&#xA0;</p>
        </div>
        <p>
          <br clear='all' class='section'/>
        </p>
        <div class='WordSection2'>
          <p>
            <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
          </p>
          <div id='fwd'>
            <h1 class='ForewordTitle'>Foreword</h1>
            <p class='ForewordText'> </p>
          </div>
          <p>&#xA0;</p>
        </div>
        <p>
          <br clear='all' class='section'/>
        </p>
        <div class='WordSection3'>
          <p class='zzSTDTitle1'/>
          <div id='scope'>
            <h1>Scope</h1>
            <div id='N' class='figure'>
              <img src='rice_images/rice_image1.png'/>
              <p class='FigureTitle' style='text-align:center;'>Figure 1&#xA0;&#x2014; Split-it-right sample divider</p>
            </div>
            <p> </p>
          </div>
          <div id='terms'>
            <h1/>
          </div>
          <div id='widgets'>
            <h1>Widgets</h1>
            <div id='widgets1'>
              <div id='note1' class='figure'>
                <img src='rice_images/rice_image1.png'/>
                <p class='FigureTitle' style='text-align:center;'>Figure 2&#xA0;&#x2014; Split-it-right sample divider</p>
              </div>
              <div id='note2' class='figure'>
                <img src='rice_images/rice_image1.png'/>
                <p class='FigureTitle' style='text-align:center;'>Figure 3&#xA0;&#x2014; Split-it-right sample divider</p>
              </div>
              <p> </p>
            </div>
          </div>
          <p>
            <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
          </p>
          <div id='annex1' class='Section3'>
            <div id='annex1a'>
              <div id='AN' class='figure'>
                <img src='rice_images/rice_image1.png'/>
                <p class='AnnexFigureTitle' style='text-align:center;'>Figure A.1&#xA0;&#x2014; Split-it-right sample divider</p>
              </div>
            </div>
            <div id='annex1b'>
              <div id='Anote1' class='figure'>
                <img src='rice_images/rice_image1.png'/>
                <p class='AnnexFigureTitle' style='text-align:center;'>Figure A.2&#xA0;&#x2014; Split-it-right sample divider</p>
              </div>
              <div id='Anote2' class='figure'>
                <img src='rice_images/rice_image1.png'/>
                <p class='AnnexFigureTitle' style='text-align:center;'>Figure A.3&#xA0;&#x2014; Split-it-right sample divider</p>
              </div>
            </div>
          </div>
        </div>
        <br clear='all' style='page-break-before:left;mso-break-type:section-break'/>
        <div class='colophon'/>
      </body>
    OUTPUT
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", input, true)
    expect(xmlpp(output)).to be_equivalent_to xmlpp(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", input, true)
    expect(xmlpp(Nokogiri::XML(output).at("//body").to_xml))
      .to be_equivalent_to xmlpp(word)
  end

  it "renders subfigures (HTML)" do
    output = IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", <<~"INPUT", true)
        <iso-standard xmlns='http://riboseinc.com/isoxml'>
          <preface>
            <foreword id='fwd'>
              <p>
                <xref target='N'/>
                <xref target='note1'/>
                <xref target='note2'/>
                <xref target='AN'/>
                <xref target='Anote1'/>
                <xref target='Anote2'/>
              </p>
            </foreword>
          </preface>
          <sections>
            <clause id='scope' type="scope">
              <title>Scope</title>
            </clause>
            <terms id='terms'/>
            <clause id='widgets'>
              <title>Widgets</title>
              <clause id='widgets1'>
                <figure id='N'>
                  <name>Figure 1</name>
                  <figure id='note1'>
                    <name>a)&#xA0;&#x2014; Split-it-right sample divider</name>
                    <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                  </figure>
                  <figure id='note2'>
                    <name>b)&#xA0;&#x2014; Split-it-right sample divider</name>
                    <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                  </figure>
                </figure>
                <p>
                  <xref target='note1'/>
                  <xref target='note2'/>
                </p>
              </clause>
            </clause>
          </sections>
          <annex id='annex1'>
            <clause id='annex1a'> </clause>
            <clause id='annex1b'>
              <figure id='AN'>
                <name>Figure A.1</name>
                <figure id='Anote1'>
                  <name>a)&#xA0;&#x2014; Split-it-right sample divider</name>
                  <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                </figure>
                <figure id='Anote2'>
                  <name>b)&#xA0;&#x2014; Split-it-right sample divider</name>
                  <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                </figure>
              </figure>
            </clause>
          </annex>
        </iso-standard>
      INPUT
    expect(xmlpp(output)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <html lang='en'>
        <head/>
        <body lang='en'>
          <div class='title-section'>
            <p>&#160;</p>
          </div>
          <br/>
          <div class='prefatory-section'>
            <p>&#160;</p>
          </div>
          <br/>
          <div class='main-section'>
            <br/>
            <div id='fwd'>
              <h1 class='ForewordTitle'>Foreword</h1>
              <p>
                <a href='#N'/>
                <a href='#note1'/>
                <a href='#note2'/>
                <a href='#AN'/>
                <a href='#Anote1'/>
                <a href='#Anote2'/>
              </p>
            </div>
            <p class='zzSTDTitle1'/>
            <div id='scope'>
              <h1>Scope</h1>
            </div>
            <div id='terms'>
              <h1/>
            </div>
            <div id='widgets'>
              <h1>Widgets</h1>
              <div id='widgets1'>
                <div id='N' class='figure'>
                  <div id='note1' class='figure'>
                    <img src='rice_images/rice_image1.png' height='auto' width='auto'/>
                    <p class='FigureTitle' style='text-align:center;'>a)&#160;&#8212; Split-it-right sample divider</p>
                  </div>
                  <div id='note2' class='figure'>
                    <img src='rice_images/rice_image1.png' height='auto' width='auto'/>
                    <p class='FigureTitle' style='text-align:center;'>b)&#160;&#8212; Split-it-right sample divider</p>
                  </div>
                  <p class='FigureTitle' style='text-align:center;'>Figure 1</p>
                </div>
                <p>
                  <a href='#note1'/>
                  <a href='#note2'/>
                </p>
              </div>
            </div>
            <br/>
            <div id='annex1' class='Section3'>
              <div id='annex1a'>
              </div>
              <div id='annex1b'>
                <div id='AN' class='figure'>
                  <div id='Anote1' class='figure'>
                    <img src='rice_images/rice_image1.png' height='auto' width='auto'/>
                    <p class='FigureTitle' style='text-align:center;'>a)&#160;&#8212; Split-it-right sample divider</p>
                  </div>
                  <div id='Anote2' class='figure'>
                    <img src='rice_images/rice_image1.png' height='auto' width='auto'/>
                    <p class='FigureTitle' style='text-align:center;'>b)&#160;&#8212; Split-it-right sample divider</p>
                  </div>
                  <p class='FigureTitle' style='text-align:center;'>Figure A.1</p>
                </div>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "processes units statements in figures" do
    input = <<~INPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml'>
          <sections>
            <clause id='widgets'>
              <title>Widgets</title>
                <figure id='N'>
                  <name>Figure 1</name>
                    <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                    <note id="A">Note 1</note>
                    <note id="B" type="units">Units in mm</note>
                    <note id="C">Note 2</note>
                    <note id="D" type="units">Other units in sec</note>
                </figure>
            </clause>
          </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <sections>
          <clause id="widgets" displayorder="1">
            <title depth="1">1<tab/>Widgets</title>
            <figure id="N">
              <name>Figure 1 — Figure 1</name>
              <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
              <note id="A"><name>NOTE  1</name>Note 1</note>
              <note id="B" type="units">Units in mm</note>
              <note id="C"><name>NOTE  2</name>Note 2</note>
              <note id="D" type="units">Other units in sec</note>
            </figure>
          </clause>
        </sections>
      </iso-standard>
    OUTPUT
    html = <<~OUTPUT
          #{HTML_HDR}
            <p class="zzSTDTitle1"/>
            <div id="widgets">
              <h1>1  Widgets</h1>
              <div align="right">
                <b>Units in mm</b>
              </div>
              <div align="right">
                <b>Other units in sec</b>
              </div>
              <div id="N" class="figure">
                <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
                <div id="A" class="Note"><p><span class="note_label">NOTE  1</span>  </p>Note 1</div>
                <div id="C" class="Note"><p><span class="note_label">NOTE  2</span>  </p>Note 2</div>
                <p class="FigureTitle" style="text-align:center;">Figure 1 — Figure 1</p>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    word = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72">
        <div class="WordSection1">
          <p> </p>
        </div>
        <p>
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection2">
          <p> </p>
        </div>
        <p>
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
          <p class="zzSTDTitle1"/>
          <div id="widgets">
            <h1>1<span style="mso-tab-count:1">  </span>Widgets</h1>
            <div align="right">
              <b>Units in mm</b>
            </div>
            <div align="right">
              <b>Other units in sec</b>
            </div>
            <div id="N" class="figure">
              <img src="rice_images/rice_image1.png"/>
              <div id="A" class="Note"><p class="Note"><span class="note_label">NOTE  1</span><span style="mso-tab-count:1">  </span></p>Note 1</div>
              <div id="C" class="Note"><p class="Note"><span class="note_label">NOTE  2</span><span style="mso-tab-count:1">  </span></p>Note 2</div>
              <p class="FigureTitle" style="text-align:center;">Figure 1 — Figure 1</p>
            </div>
          </div>
        </div>
        <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"/>
      </body>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, true)
    expect(xmlpp(Nokogiri::XML(output).at("//body").to_xml))
      .to be_equivalent_to xmlpp(word)
  end

  it "processes formulae" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true">
              <stem type="AsciiMath">r = 1 %</stem>
              <dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
                <dt>
                  <stem type="AsciiMath">r</stem>
                </dt>
                <dd>
                  <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
                </dd>
                <dt>
                  <stem type="AsciiMath">s_1</stem>
                </dt>
                <dd>
                  <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the other repeatability limit.</p>
                </dd>
              </dl>
              <note id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0">
                <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the &quot;P&quot; prefix. &quot;P&quot; is unnecessary because between &quot;G&quot; and &quot;U&quot; duration is always expressed.</p>
              </note>
            </formula>
            <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935">
              <stem type="AsciiMath">r = 1 %</stem>
            </formula>
          </foreword>
        </preface>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword displayorder="1">
            <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true">
              <stem type="AsciiMath">r = 1 %</stem>
              <p keep-with-next="true">where</p>
              <dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d" class="formula_dl">
                <dt>
                  <stem type="AsciiMath">r</stem>
                </dt>
                <dd>
                  <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
                </dd>
                <dt>
                  <stem type="AsciiMath">s_1</stem>
                </dt>
                <dd>
                  <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the other repeatability limit.</p>
                </dd>
              </dl>
              <note id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0">
                <name>NOTE</name>
                <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the "P"
                  prefix. "P" is unnecessary because between "G" and "U" duration is
                  always expressed.
                </p>
              </note>
            </formula>
            <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935">
              <name>1</name>
              <stem type="AsciiMath">r = 1 %</stem>
            </formula>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
              <br/>
                <div>
                  <h1 class='ForewordTitle'>Foreword</h1>
                  <div id='_be9158af-7e93-4ee2-90c5-26d31c181934'>
                    <div class='formula'>
                      <p>
                        <span class='stem'>(#(r = 1 %)#)</span>
                      </p>
                    </div>
                    <p style='page-break-after: avoid;'>where</p>
                    <dl id='_e4fe94fe-1cde-49d9-b1ad-743293b7e21d' class='formula_dl'>
                      <dt>
                        <span class='stem'>(#(r)#)</span>
                      </dt>
                      <dd>
                        <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the repeatability limit.</p>
                      </dd>
                      <dt>
                        <span class='stem'>(#(s_1)#)</span>
                      </dt>
                      <dd>
                        <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the other repeatability limit.</p>
                      </dd>
                    </dl>
                    <div id='_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0' class='Note'>
                      <p>
                      <span class='note_label'>NOTE</span>
                        &#160; [durationUnits] is essentially a duration statement without
                        the "P" prefix. "P" is unnecessary because between "G" and "U"
                        duration is always expressed.
                      </p>
                    </div>
                  </div>
                <div id='_be9158af-7e93-4ee2-90c5-26d31c181935'>
                <div class='formula'>
                  <p>
                    <span class='stem'>(#(r = 1 %)#)</span>
                    &#160; (1)
                  </p>
                </div>
              </div>
            </div>
            <p class='zzSTDTitle1'/>
          </div>
        </body>
      </html>
    OUTPUT

    word = <<~OUTPUT
          <div>
            <h1 class='ForewordTitle'>Foreword</h1>
            <div id='_be9158af-7e93-4ee2-90c5-26d31c181934'><div class='formula'>
              <p>
                <span class='stem'>(#(r = 1 %)#)</span>
                <span style='mso-tab-count:1'>&#160; </span>
              </p>
            </div>
            <p class="ForewordText" style="page-break-after: avoid;">where</p>
            <table class="formula_dl">
              <tr>
                <td align="left" valign="top">
                  <p align="left" style="margin-left:0pt;text-align:left;">
                    <span class="stem">(#(r)#)</span>
                  </p>
                </td>
                <td valign="top">
                  <p class="ForewordText" id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
                </td>
              </tr>
              <tr>
                <td align="left" valign="top">
                  <p align="left" style="margin-left:0pt;text-align:left;">
                    <span class="stem">(#(s_1)#)</span>
                  </p>
                </td>
                <td valign="top">
                  <p class="ForewordText" id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the other repeatability limit.</p>
                </td>
              </tr>
            </table>
            <div id='_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0' class='Note'>
              <p class='Note'>
                    <span class='note_label'>NOTE</span>
                <span style='mso-tab-count:1'>&#160; </span>
                [durationUnits] is essentially a duration statement without the "P"
                prefix. "P" is unnecessary because between "G" and "U" duration is
                always expressed.
              </p>
            </div>
          </div>
          <div id='_be9158af-7e93-4ee2-90c5-26d31c181935'><div class='formula'>
            <p>
              <span class='stem'>(#(r = 1 %)#)</span>
              <span style='mso-tab-count:1'>&#160; </span>
              (1)
            </p>
          </div>
        </div>
      </div>
    OUTPUT
    output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options).convert("test", input, true)
    expect(xmlpp(output)).to be_equivalent_to xmlpp(presxml)
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", presxml, true)
    expect(xmlpp(output)).to be_equivalent_to xmlpp(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, true)
    expect(xmlpp(output
      .sub(%r{^.*<div>\s*<h1 class="ForewordTitle">}m, '<div><h1 class="ForewordTitle">')
      .sub(%r{<p>&#160;</p>\s*</div>.*$}m, ""))).to be_equivalent_to xmlpp(word)
  end

  it "processes formulae with single definition list entry" do
    input = <<~"INPUT"
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true">
              <stem type="AsciiMath">r = 1 %</stem>
              <dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
                <dt>
                  <stem type="AsciiMath">r</stem>
                </dt>
                <dd>
                  <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
                </dd>
              </dl>
              <note id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0">
                <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the &quot;P&quot; prefix. &quot;P&quot; is unnecessary because between &quot;G&quot; and &quot;U&quot; duration is always expressed.</p>
              </note>
            </formula>
            <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935">
              <stem type="AsciiMath">r = 1 %</stem>
            </formula>
          </foreword>
        </preface>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <preface>
          <foreword displayorder="1">
            <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true">
              <stem type="AsciiMath">r = 1 %</stem>
              <p>where
                  <stem type="AsciiMath">r</stem>
                 is the repeatability limit.</p>
              <note id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0">
                <name>NOTE</name>
                <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
              </note>
            </formula>
            <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935">
              <name>1</name>
              <stem type="AsciiMath">r = 1 %</stem>
            </formula>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    html = <<~"OUTPUT"
      #{HTML_HDR}
              <br/>
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <div id="_be9158af-7e93-4ee2-90c5-26d31c181934">
                                 <div class="formula">
                   <p>
                     <span class="stem">(#(r = 1 %)#)</span>
                   </p>
                 </div>
                 <p>where
                   <span class="stem">(#(r)#)</span>
                  is the repeatability limit.</p>
                 <div id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0" class="Note">
                   <p><span class="note_label">NOTE</span>  [durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
                 </div>
               </div>
               <div id="_be9158af-7e93-4ee2-90c5-26d31c181935">
                 <div class="formula">
                   <p><span class="stem">(#(r = 1 %)#)</span>  (1)</p>
                 </div>
               </div>
             </div>
             <p class="zzSTDTitle1"/>
           </div>
         </body>
       </html>
    OUTPUT
    output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options).convert("test", input, true)
    expect(xmlpp(output)).to be_equivalent_to xmlpp(presxml)
    output = IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)
    expect(xmlpp(output)).to be_equivalent_to xmlpp(html)
  end

  it "adds ordered list classes for HTML" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
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
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
              <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <preface>
          <foreword displayorder='1'>
            <ol type='alphabet'>
              <li>
                <p>A</p>
              </li>
              <li>
                <p>B</p>
              </li>
              <li>
                <ol type='arabic'>
                  <li>C</li>
                  <li>D</li>
                  <li>
                    <ol type='roman'>
                      <li>E</li>
                      <li>F</li>
                      <li>
                        <ol type='alphabet_upper'>
                          <li>G</li>
                          <li>H</li>
                          <li>
                            <ol type='roman_upper'>
                              <li>I</li>
                              <li>J</li>
                              <li>
                                <ol type='alphabet'>
                                  <li>K</li>
                                  <li>L</li>
                                  <li>M</li>
                                </ol>
                              </li>
                              <li>N</li>
                            </ol>
                          </li>
                          <li>O</li>
                        </ol>
                      </li>
                      <li>P</li>
                    </ol>
                  </li>
                  <li>Q</li>
                </ol>
              </li>
              <li>R</li>
            </ol>
          </foreword>
        </preface>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                    <br/>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
                              <ol type='a' class='alphabet'>
                 <li>
                   <p>A</p>
                 </li>
                 <li>
                   <p>B</p>
                 </li>
                 <li>
                   <ol type='1' class='arabic'>
                     <li>C</li>
                     <li>D</li>
                     <li>
                       <ol type='i' class='roman'>
                         <li>E</li>
                         <li>F</li>
                         <li>
                           <ol type='A' class='alphabet_upper'>
                             <li>G</li>
                             <li>H</li>
                             <li>
                               <ol type='I' class='roman_upper'>
                                 <li>I</li>
                                 <li>J</li>
                                 <li>
                                   <ol type='a' class='alphabet'>
                                     <li>K</li>
                                     <li>L</li>
                                     <li>M</li>
                                   </ol>
                                 </li>
                                 <li>N</li>
                               </ol>
                             </li>
                             <li>O</li>
                           </ol>
                         </li>
                         <li>P</li>
                       </ol>
                     </li>
                     <li>Q</li>
                   </ol>
                 </li>
                 <li>R</li>
               </ol>
             </div>
             <p class='zzSTDTitle1'/>
           </div>
         </body>
       </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
  end

  it "processes ordered lists with start" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <ol start="4">
      <li>List</li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type='presentation'>
         <preface>
           <foreword displayorder='1'>
             <ol start='4' type='alphabet'>
               <li>List</li>
             </ol>
           </foreword>
         </preface>
       </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                    <br/>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <ol type='a' start='4'  class='alphabet'>
                 <li>List</li>
               </ol>
             </div>
             <p class='zzSTDTitle1'/>
           </div>
         </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
      <div class='WordSection2'>
        <p>
          <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
        </p>
        <div>
          <h1 class='ForewordTitle'>Foreword</h1>
          <ol type='a' start='4'>
            <li>List</li>
          </ol>
        </div>
        <p> </p>
      </div>
    OUTPUT

    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
    expect(xmlpp(Nokogiri::XML(IsoDoc::Iso::WordConvert.new({})
      .convert("test", presxml, true))
      .at("//div[@class = 'WordSection2']").to_xml))
      .to be_equivalent_to xmlpp(word)
  end

  it "ignores intervening ul in numbering ol" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <ul>
      <li>A</li>
      <li>
      <ol>
      <li>List</li>
      </ol>
      </li>
      </ul>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
         <preface>
           <foreword displayorder='1'>
             <ul>
               <li>A</li>
               <li>
                 <ol type='alphabet'>
                   <li>List</li>
                 </ol>
               </li>
             </ul>
           </foreword>
         </preface>
       </iso-standard>
    INPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
  end
end
