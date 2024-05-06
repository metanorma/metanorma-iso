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
            <clause type="toc" id="_" displayorder="1">
          <title depth="1">Contents</title>
        </clause>
          <foreword displayorder="2">
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
          </div>
        </body>
      </html>
    OUTPUT

    word = <<~OUTPUT
            <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p>&#160;</p>
          </div>
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection2">
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
                <div class="TOC" id="_">
        <p class="zzContents">Contents</p>
      </div>
      <p class="page-break">
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
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
          </div>
          <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
          <div class="colophon"/>
        </body>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to xmlpp(presxml)
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
            <clause type="toc" id="_" displayorder="1">
          <title depth="1">Contents</title>
          </clause>
          <foreword displayorder="2">
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
          </div>
        </body>
      </html>
    OUTPUT
    word = <<~OUTPUT
            <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p>&#160;</p>
          </div>
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection2">
            <p class="page-break">
              <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
            </p>
                <div class="TOC" id="_">
        <p class="zzContents">Contents</p>
      </div>
      <p class="page-break">
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
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
          </div>
          <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
          <div class="colophon"/>
        </body>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to xmlpp(presxml)
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
          <preface>
          <clause type="toc" id="_" displayorder="1">
          <title depth="1">Contents</title>
        </clause>
          <foreword displayorder="2">
          <admonition id="_" type="caution">
                         <p id='_'>
                 CAUTION — Only use paddy or parboiled rice for the
                 determination of husked rice yield.
               </p>
        <p id="_">Para 2.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <div>
        <h1 class='ForewordTitle'>Foreword</h1>
        <div id='_' class='Admonition'>
          <p>
             CAUTION — Only use paddy or parboiled rice for the
            determination of husked rice yield.
          </p>
          <p id='_'>Para 2.</p>
        </div>
      </div>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(Nokogiri::XML(
      IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true),
    )
      .at("//div[h1/@class = 'ForewordTitle']").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes empty admonitions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <preface>
          <clause type="toc" id="_" displayorder="1">
            <title depth="1">Contents</title>
          </clause>
          <foreword displayorder="2">
            <admonition id="_" type="caution">
              <name>CAUTION</name>
            </admonition>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
        .convert("test", input, true))))
      .to be_equivalent_to xmlpp(presxml)
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
          <preface>
             <clause type="toc" id="_" displayorder="1">
          <title depth="1">Contents</title>
           </clause>
          <foreword displayorder="2">
          <admonition id="_" type="caution">
          <name>Title</name>
          <ul>
          <li>List</li>
          </ul>
        <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <div id='_' class='Admonition'>
                        <p>Title — </p>
                        <div class="ul_wrap">
         <ul>
           <li>List</li>
         </ul>
       </div>
         <p id='_'>Only use paddy or parboiled rice for the determination of husked rice yield.</p>
               </div>
             </div>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(Nokogiri::XML(
      IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true),
    )
      .at("//div[h1/@class = 'ForewordTitle']").to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes admonitions outside of clauses" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections><title>A</title>
      <admonition id="_47f25c97-8757-9c1f-4ac1-3a9daefd72b7" type="important"><p id="_a83ad1fc-b3b7-2679-ef9d-cb732cd8a046">The electronic file of this document contains colours which are considered to be useful for the correct understanding of the &lt;document&gt;.</p></admonition>
      <clause id="A"><title>Scope</title></clause>
      </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
           <clause type="toc" id="_" displayorder="1">
             <title depth="1">Contents</title>
           </clause>
         </preface>
         <sections>
           <title>A</title>
           <admonition id="_" type="important" displayorder="2">
             <p id="_">
               <strong>IMPORTANT — </strong>
               <strong>The electronic file of this document contains colours which are considered to be useful for the correct understanding of the <document>.</strong>
             </p>
           </admonition>
           <clause id="A" displayorder="3">
             <title depth="1">1<tab/>Scope</title>
           </clause>
         </sections>
       </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
    .convert("test", input, true))))
      .to be_equivalent_to xmlpp(presxml)
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
          <preface>
            <clause type="toc" id="_" displayorder="1">
              <title depth="1">Contents</title>
          </clause>
            <foreword displayorder="2">
          <admonition id="_" type="editorial">
                         <p id='_'>EDITORIAL NOTE —
                 Only use paddy or parboiled rice for the
                 determination of husked rice yield.
               </p>
        <p id="_">Para 2.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                   <br/>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <div id='_' class='zzHelp'>
                 <p>EDITORIAL NOTE —
                    Only use paddy or parboiled rice for the
                   determination of husked rice yield.
                 </p>
                 <p id='_'>Para 2.</p>
               </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
            <div class='WordSection2'>
          <p class="page-break">
            <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
          </p>
            <div class="TOC" id="_">
        <p class="zzContents">Contents</p>
      </div>
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
          <div>
            <h1 class='ForewordTitle'>Foreword</h1>
            <div id='_' class='zzHelp'>
              <p>EDITORIAL NOTE — Only use paddy or parboiled rice for the determination of husked rice yield. </p>
              <p class='ForewordText' id='_'>Para 2.</p>
            </div>
          </div>
          <p> </p>
          </div>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
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
        <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
          <foreword id='fwd' displayorder="2">
            <p>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id='scope' type="scope" displayorder="3">
            <title>Scope</title>
            <figure id='N'>
              <name>Figure 1&#xA0;&#x2014; Split-it-right sample divider</name>
              <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
            </figure>
            <p>
            </p>
          </clause>
          <clause id='widgets' displayorder="4">
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
        <annex id='annex1' displayorder="5">
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
          <div id="scope">
            <h1>Scope</h1>
            <div id="N" class="figure">
              <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
              <p class="FigureTitle" style="text-align:center;">Figure 1&#160;&#8212; Split-it-right sample divider</p>
            </div>
            <p>
            </p>
          </div>
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
          <p class="section-break">
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection2'>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
                <div class="TOC" id="_">
        <p class="zzContents">Contents</p>
      </div>
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
            <div id='fwd'>
              <h1 class='ForewordTitle'>Foreword</h1>
              <p class='ForewordText'> </p>
            </div>
            <p>&#xA0;</p>
          </div>
          <p class="section-break">
            <br clear='all' class='section'/>
          </p>
          <div class='WordSection3'>
            <div id='scope'>
              <h1>Scope</h1>
              <div id='N' class='figure'>
                <img src='rice_images/rice_image1.png'/>
                <p class='FigureTitle' style='text-align:center;'>Figure 1&#xA0;&#x2014; Split-it-right sample divider</p>
              </div>
              <p> </p>
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
            <p class="page-break">
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
      .convert("test", <<~INPUT, true)
        <iso-standard xmlns='http://riboseinc.com/isoxml'>
          <preface>
            <foreword id='fwd' displayorder="1">
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
            <clause id='scope' type="scope" displayorder="2">
              <title>Scope</title>
            </clause>
            <terms id='terms'/>
            <clause id='widgets' displayorder="3">
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
          <annex id='annex1' displayorder="4">
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
    expect(xmlpp(output)).to be_equivalent_to xmlpp(<<~OUTPUT)
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
            <div id='scope'>
              <h1>Scope</h1>
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
           <preface><clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause></preface>
        <sections>
          <clause id="widgets" displayorder="2">
            <title depth="1">1<tab/>Widgets</title>
            <figure id="N">
              <name>Figure 1 — Figure 1</name>
              <image src="rice_images/rice_image1.png" id="_" mimetype="image/png"/>
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
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection2">
              <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
      <div class="TOC" id="_">
        <p class="zzContents">Contents</p>
      </div>
            <p> </p>
          </div>
          <p class="section-break">
            <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
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
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
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
           <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
          <foreword displayorder="2">
            <formula id="_" unnumbered="true">
              <stem type="AsciiMath">r = 1 %</stem>
              <p keep-with-next="true">where</p>
              <dl id="_" class="formula_dl">
                <dt>
                  <stem type="AsciiMath">r</stem>
                </dt>
                <dd>
                  <p id="_">is the repeatability limit.</p>
                </dd>
                <dt>
                  <stem type="AsciiMath">s_1</stem>
                </dt>
                <dd>
                  <p id="_">is the other repeatability limit.</p>
                </dd>
              </dl>
              <note id="_">
                <name>NOTE</name>
                <p id="_">[durationUnits] is essentially a duration statement without the "P"
                  prefix. "P" is unnecessary because between "G" and "U" duration is
                  always expressed.
                </p>
              </note>
            </formula>
            <formula id="_">
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
                  <div id='_'>
                    <div class='formula'>
                      <p>
                        <span class='stem'>(#(r = 1 %)#)</span>
                      </p>
                    </div>
                    <p style='page-break-after: avoid;'>where</p>
                    <div class="figdl">
                    <dl id='_' class='formula_dl'>
                      <dt>
                        <span class='stem'>(#(r)#)</span>
                      </dt>
                      <dd>
                        <p id='_'>is the repeatability limit.</p>
                      </dd>
                      <dt>
                        <span class='stem'>(#(s_1)#)</span>
                      </dt>
                      <dd>
                        <p id='_'>is the other repeatability limit.</p>
                      </dd>
                    </dl>
                    </div>
                    <div id='_' class='Note'>
                      <p>
                      <span class='note_label'>NOTE</span>
                        &#160; [durationUnits] is essentially a duration statement without
                        the "P" prefix. "P" is unnecessary because between "G" and "U"
                        duration is always expressed.
                      </p>
                    </div>
                  </div>
                <div id='_'>
                <div class='formula'>
                  <p>
                    <span class='stem'>(#(r = 1 %)#)</span>
                    &#160; (1)
                  </p>
                </div>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT

    word = <<~OUTPUT
          <div>
            <h1 class='ForewordTitle'>Foreword</h1>
            <div id='_'><div class='formula'>
              <p>
                <span class='stem'>(#(r = 1 %)#)</span>
                <span style='mso-tab-count:1'>&#160; </span>
              </p>
            </div>
            <p class="ForewordText" style="page-break-after: avoid;">where</p>
            <table id="_" class="formula_dl">
              <tr>
                <td align="left" valign="top">
                  <p align="left" style="margin-left:0pt;text-align:left;">
                    <span class="stem">(#(r)#)</span>
                  </p>
                </td>
                <td valign="top">
                  <p class="ForewordText" id="_">is the repeatability limit.</p>
                </td>
              </tr>
              <tr>
                <td align="left" valign="top">
                  <p align="left" style="margin-left:0pt;text-align:left;">
                    <span class="stem">(#(s_1)#)</span>
                  </p>
                </td>
                <td valign="top">
                  <p class="ForewordText" id="_">is the other repeatability limit.</p>
                </td>
              </tr>
            </table>
            <div id='_' class='Note'>
              <p class='Note'>
                    <span class='note_label'>NOTE</span>
                <span style='mso-tab-count:1'>&#160; </span>
                [durationUnits] is essentially a duration statement without the "P"
                prefix. "P" is unnecessary because between "G" and "U" duration is
                always expressed.
              </p>
            </div>
          </div>
          <div id='_'><div class='formula'>
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
    expect(xmlpp(strip_guid(output))).to be_equivalent_to xmlpp(presxml)
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", presxml, true)
    expect(xmlpp(output)).to be_equivalent_to xmlpp(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", presxml, true)
    expect(xmlpp(output
      .sub(%r{^.*<div>\s*<h1 class="ForewordTitle">}m, '<div><h1 class="ForewordTitle">')
      .sub(%r{<p>&#160;</p>\s*</div>.*$}m, ""))).to be_equivalent_to xmlpp(word)
  end

  it "processes formulae with single definition list entry" do
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
           <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
          <foreword displayorder="2">
            <formula id="_" unnumbered="true">
              <stem type="AsciiMath">r = 1 %</stem>
              <p>where
                  <stem type="AsciiMath">r</stem>
                 is the repeatability limit.</p>
              <note id="_">
                <name>NOTE</name>
                <p id="_">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
              </note>
            </formula>
            <formula id="_">
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
                <div id="_">
                                 <div class="formula">
                   <p>
                     <span class="stem">(#(r = 1 %)#)</span>
                   </p>
                 </div>
                 <p>where
                   <span class="stem">(#(r)#)</span>
                  is the repeatability limit.</p>
                 <div id="_" class="Note">
                   <p><span class="note_label">NOTE</span>  [durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
                 </div>
               </div>
               <div id="_">
                 <div class="formula">
                   <p><span class="stem">(#(r = 1 %)#)</span>  (1)</p>
                 </div>
               </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options).convert("test", input, true)
    expect(xmlpp(strip_guid(output))).to be_equivalent_to xmlpp(presxml)
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
           <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
          <foreword displayorder='2'>
            <ol type='alphabet'>
              <li id="_" label="">
                <p>A</p>
              </li>
              <li id="_" label="">
                <p>B</p>
              </li>
              <li id="_" label="">
                <ol type='arabic'>
                  <li id="_" label="">C</li>
                  <li id="_" label="">D</li>
                  <li id="_" label="">
                    <ol type='roman'>
                      <li id="_" label="">E</li>
                      <li id="_" label="">F</li>
                      <li id="_" label="">
                        <ol type='alphabet_upper'>
                          <li id="_" label="">G</li>
                          <li id="_" label="">H</li>
                          <li id="_" label="">
                            <ol type='roman_upper'>
                              <li id="_" label="">I</li>
                              <li id="_" label="">J</li>
                              <li id="_" label="">
                                <ol type='alphabet'>
                                  <li id="_" label="">K</li>
                                  <li id="_" label="">L</li>
                                  <li id="_" label="">M</li>
                                </ol>
                              </li>
                              <li id="_" label="">N</li>
                            </ol>
                          </li>
                          <li id="_" label="">O</li>
                        </ol>
                      </li>
                      <li id="_" label="">P</li>
                    </ol>
                  </li>
                  <li id="_" label="">Q</li>
                </ol>
              </li>
              <li id="_" label="">R</li>
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
                              <div class="ol_wrap">
                 <ol type="a" class="alphabet">
                   <li id="_">
                     <p>A</p>
                   </li>
                   <li id="_">
                     <p>B</p>
                   </li>
                   <li id="_">
                     <div class="ol_wrap">
                       <ol type="1" class="arabic">
                         <li id="_">C</li>
                         <li id="_">D</li>
                         <li id="_">
                           <div class="ol_wrap">
                             <ol type="i" class="roman">
                               <li id="_">E</li>
                               <li id="_">F</li>
                               <li id="_">
                                 <div class="ol_wrap">
                                   <ol type="A" class="alphabet_upper">
                                     <li id="_">G</li>
                                     <li id="_">H</li>
                                     <li id="_">
                                       <div class="ol_wrap">
                                         <ol type="I" class="roman_upper">
                                           <li id="_">I</li>
                                           <li id="_">J</li>
                                           <li id="_">
                                             <div class="ol_wrap">
                                               <ol type="a" class="alphabet">
                                                 <li id="_">K</li>
                                                 <li id="_">L</li>
                                                 <li id="_">M</li>
                                               </ol>
                                             </div>
                                           </li>
                                           <li id="_">N</li>
                                         </ol>
                                       </div>
                                     </li>
                                     <li id="_">O</li>
                                   </ol>
                                 </div>
                               </li>
                               <li id="_">P</li>
                             </ol>
                           </div>
                         </li>
                         <li id="_">Q</li>
                       </ol>
                     </div>
                   </li>
                   <li id="_">R</li>
                 </ol>
               </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
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
           <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
           <foreword displayorder='2'>
             <ol start='4' type='alphabet'>
               <li id="_" label="">List</li>
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
               <div class="ol_wrap">
               <ol type='a' start='4'  class='alphabet'>
                 <li id="_">List</li>
               </ol>
               </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
          <div class='WordSection2'>
            <p class="page-break">
              <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
            </p>
              <div class="TOC" id="_">
        <p class="zzContents">Contents</p>
      </div>
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
            <div>
              <h1 class='ForewordTitle'>Foreword</h1>
              <div class="ol_wrap">
              <ol type='a' start='4'>
                <li id="_">List</li>
              </ol>
              </div>
            </div>
            <p> </p>
          </div>
    OUTPUT

    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
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
           <clause type="toc" id="_" displayorder="1"> <title depth="1">Contents</title> </clause>
           <foreword displayorder='2'>
             <ul>
               <li>A</li>
               <li>
                 <ol type='alphabet'>
                   <li id="_" label="">List</li>
                 </ol>
               </li>
             </ul>
           </foreword>
         </preface>
       </iso-standard>
    INPUT
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to xmlpp(presxml)
  end
end
