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
                <example id="samplecode" autonum="">
                   <name id="_">Title</name>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">EXAMPLE</span>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">Title</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Example</span>
                   </fmt-xref-label>
                   <fmt-xref-label container="_">
                      <span class="fmt-xref-container">
                         <semx element="foreword" source="_">Foreword</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Example</span>
                   </fmt-xref-label>
                   <p>Hello</p>
                </example>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
            <br/>
            <div id="_">
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
            <div id="_">
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
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)))).to be_equivalent_to Xml::C14n.format(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", pres_output, true)
    expect(Xml::C14n.format(strip_guid(output
      .sub(/^.*<body/m, "<body").sub(%r{</body>.*$}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(word)
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
                <example id="samplecode" autonum="1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">EXAMPLE</span>
                         <semx element="autonum" source="samplecode">1</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Example</span>
                      <semx element="autonum" source="samplecode">1</semx>
                   </fmt-xref-label>
                   <fmt-xref-label container="_">
                      <span class="fmt-xref-container">
                         <semx element="foreword" source="_">Foreword</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Example</span>
                      <semx element="autonum" source="samplecode">1</semx>
                   </fmt-xref-label>
                   <quote>Hello</quote>
                </example>
                <example id="samplecode2" autonum="2">
                   <name id="_">Title</name>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">EXAMPLE</span>
                         <semx element="autonum" source="samplecode2">2</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">Title</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Example</span>
                      <semx element="autonum" source="samplecode2">2</semx>
                   </fmt-xref-label>
                   <fmt-xref-label container="_">
                      <span class="fmt-xref-container">
                         <semx element="foreword" source="_">Foreword</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Example</span>
                      <semx element="autonum" source="samplecode2">2</semx>
                   </fmt-xref-label>
                   <p>Hello</p>
                </example>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
            <br/>
            <div id="_">
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
            <div id="_">
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
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", pres_output, true)
    expect(Xml::C14n.format(strip_guid(output
      .sub(/^.*<body/m, "<body").sub(%r{</body>.*$}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(word)
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
          <fmt-title depth="1">Contents</fmt-title>
        </clause>
          <foreword displayorder="2" id="_">
                   <title id="_">Foreword</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
          <admonition id="_" type="caution">
          <name id="_">CAUTION</name>
            <fmt-name>
                  <semx element="name" source="_">CAUTION</semx>
               <span class="fmt-label-delim"> — </span>
            </fmt-name>
                  <p id='_'>Only use paddy or parboiled rice for the
                 determination of husked rice yield.
               </p>
        <p id="_">Para 2.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <div id="_">
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
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//div[h1/@class = 'ForewordTitle']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
          <fmt-title depth="1">Contents</fmt-title>
          </clause>
          <foreword displayorder="2" id="_">
                   <title id="_">Foreword</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
            <admonition id="_" type="caution">
              <fmt-name>
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">CAUTION</span>
               </span>
            </fmt-name>
            </admonition>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
        .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
             <fmt-title depth="1">Contents</fmt-title>
           </clause>
          <foreword displayorder="2" id="_">
                   <title id="_">Foreword</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
          <admonition id="_" type="caution">
          <name id="_">Title</name>
            <fmt-name>
                  <semx element="name" source="_">Title</semx>
            </fmt-name>
          <ul>
          <li>List</li>
          </ul>
        <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
      </admonition>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <div id="_">
               <h1 class='ForewordTitle'>Foreword</h1>
               <div id='_' class='Admonition'>
                        <p class="AdmonitionTitle" style="text-align:center;">Title</p>
                        <div class="ul_wrap">
         <ul>
           <li>List</li>
         </ul>
       </div>
         <p id='_'>Only use paddy or parboiled rice for the determination of husked rice yield.</p>
               </div>
             </div>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//div[h1/@class = 'ForewordTitle']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
           <fmt-title depth="1">Contents</fmt-title>
           </clause>
         </preface>
         <sections>
           <title>A</title>
           <admonition id="_" type="important" displayorder="2">
             <fmt-name>
            <span class="fmt-caption-label">
               <span class="fmt-element-name">
                  <strong>IMPORTANT</strong>
               </span>
            </span>
            <span class="fmt-label-delim">
               <strong> — </strong>
            </span>
         </fmt-name>
             <p id="_">
               <strong>The electronic file of this document contains colours which are considered to be useful for the correct understanding of the &lt;document&gt;.</strong>
             </p>
           </admonition>
           <clause id="A" displayorder="3">
           <title id="_">Scope</title>
         <fmt-title depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="A">1</semx>
               </span>
               <span class="fmt-caption-delim">
                  <tab/>
               </span>
               <semx element="title" source="_">Scope</semx>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="A">1</semx>
         </fmt-xref-label>
           </clause>
         </sections>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
    .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
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
            <fmt-title depth="1">Contents</fmt-title>
          </clause>
            <foreword displayorder="2" id="_">
                     <title id="_">Foreword</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
          <admonition id="_" type="editorial">
                      <fmt-name>
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">EDITORIAL NOTE</span>
               </span>
               <span class="fmt-label-delim"> — </span>
            </fmt-name>
                         <p id="_">Only use paddy or parboiled rice for the
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
             <div id="_">
               <h1 class='ForewordTitle'>Foreword</h1>
               <div id='_' class='zzHelp'>
                 <p>EDITORIAL NOTE — Only use paddy or parboiled rice for the
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
          <div id="_">
            <h1 class='ForewordTitle'>Foreword</h1>
            <div id='_' class='zzHelp'>
              <p>EDITORIAL NOTE — Only use paddy or parboiled rice for the determination of husked rice yield. </p>
              <p class='ForewordText' id='_'>Para 2.</p>
            </div>
          </div>
          <p> </p>
          </div>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true))
      .at("//div[@class = 'WordSection2']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "renders figures" do
    input = <<~INPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml'>
        <preface>
        <clause type="toc" id="_" displayorder="1"> <fmt-title depth="1">Contents</tfmt-itle> </clause>
          <foreword id='fwd' displayorder="2"><fmt-title>Foreword</fmt-title>
            <p>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id='scope' type="scope" displayorder="3">
            <fmt-title>Scope</fmt-title>
            <figure id='N'>
              <fmt-name>Figure 1&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
              <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
            </figure>
            <p>
            </p>
          </clause>
          <clause id='widgets' displayorder="4">
            <fmt-title>Widgets</fmt-title>
            <clause id='widgets1'>
              <figure id='note1'>
                <fmt-name>Figure 2&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
                <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
              </figure>
              <figure id='note2'>
                <fmt-name>Figure 3&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
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
              <fmt-name>Figure A.1&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
              <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
            </figure>
          </clause>
          <clause id='annex1b'>
            <figure id='Anote1'>
              <fmt-name>Figure A.2&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
              <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
            </figure>
            <figure id='Anote2'>
              <fmt-name>Figure A.3&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
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
    expect(Xml::C14n.format(output)).to be_equivalent_to Xml::C14n.format(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", input, true)
    expect(Xml::C14n.format(Nokogiri::XML(output).at("//body").to_xml))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "renders subfigures (HTML)" do
    output = IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", <<~INPUT, true)
        <iso-standard xmlns='http://riboseinc.com/isoxml'>
          <preface>
            <foreword id='fwd' displayorder="1"><fmt-title>Foreword</fmt-title>
              <p>
                <fmt-xref target='N'/>
                <fmt-xref target='note1'/>
                <fmt-xref target='note2'/>
                <fmt-xref target='AN'/>
                <fmt-xref target='Anote1'/>
                <fmt-xref target='Anote2'/>
              </p>
            </foreword>
          </preface>
          <sections>
            <clause id='scope' type="scope" displayorder="2">
              <fmt-title>Scope</fmt-title>
            </clause>
            <terms id='terms'/>
            <clause id='widgets' displayorder="3">
              <fmt-title>Widgets</fmt-title>
              <clause id='widgets1'>
                <figure id='N'>
                  <fmt-name>Figure 1</fmt-name>
                  <figure id='note1'>
                    <fmt-name>a)&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
                    <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                  </figure>
                  <figure id='note2'>
                    <fmt-name>b)&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
                    <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                  </figure>
                </figure>
                <p>
                  <fmt-xref target='note1'/>
                  <fmt-xref target='note2'/>
                </p>
              </clause>
            </clause>
          </sections>
          <annex id='annex1' displayorder="4">
            <clause id='annex1a'> </clause>
            <clause id='annex1b'>
              <figure id='AN'>
                <fmt-name>Figure A.1</fmt-name>
                <figure id='Anote1'>
                  <fmt-name>a)&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
                  <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                </figure>
                <figure id='Anote2'>
                  <fmt-name>b)&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
                  <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                </figure>
              </figure>
            </clause>
          </annex>
        </iso-standard>
      INPUT
    expect(Xml::C14n.format(output)).to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
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
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <clause id="widgets" displayorder="2">
                <title id="_">Widgets</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="widgets">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Widgets</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="widgets">1</semx>
                </fmt-xref-label>
                <figure id="N" autonum="1">
                   <name id="_">Figure 1</name>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="N">1</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">Figure 1</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="N">1</semx>
                   </fmt-xref-label>
                   <image src="rice_images/rice_image1.png" id="_" mimetype="image/png"/>
                   <note id="A" autonum="1">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">NOTE</span>
                            <semx element="autonum" source="A">1</semx>
                         </span>
                         <span class="fmt-label-delim">
                            <tab/>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="A">1</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="widgets">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="widgets">1</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="A">1</semx>
                      </fmt-xref-label>
                      Note 1
                   </note>
                   <note id="B" type="units">Units in mm</note>
                   <note id="C" autonum="2">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">NOTE</span>
                            <semx element="autonum" source="C">2</semx>
                         </span>
                         <span class="fmt-label-delim">
                            <tab/>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="C">2</semx>
                      </fmt-xref-label>
                      <fmt-xref-label container="widgets">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="widgets">1</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="C">2</semx>
                      </fmt-xref-label>
                      Note 2
                   </note>
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
                <div id="A" class="Note"><p><span class="note_label">NOTE  1  </span></p>Note 1</div>
                <div id="C" class="Note"><p><span class="note_label">NOTE  2  </span></p>Note 2</div>
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
                <div id="A" class="Note"><p class="Note"><span class="note_label">NOTE  1<span style="mso-tab-count:1">  </span></span></p>Note 1</div>
                <div id="C" class="Note"><p class="Note"><span class="note_label">NOTE  2<span style="mso-tab-count:1">  </span></span></p>Note 2</div>
                <p class="FigureTitle" style="text-align:center;">Figure 1 — Figure 1</p>
              </div>
            </div>
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
      .to be_equivalent_to Xml::C14n.format(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", pres_output, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(output).at("//body").to_xml)))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes formulae" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword id="A">
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
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Contents</fmt-title>
              </clause>
              <foreword id="A" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <formula id="_" unnumbered="true">
                    <stem type="AsciiMath" id="_">r = 1 %</stem>
                    <fmt-stem type="AsciiMath">
                       <semx element="stem" source="_">r = 1 %</semx>
                    </fmt-stem>
                    <p keep-with-next="true">where</p>
                    <dl id="_" class="formula_dl">
                       <dt>
                          <stem type="AsciiMath" id="_">r</stem>
                          <fmt-stem type="AsciiMath">
                             <semx element="stem" source="_">r</semx>
                          </fmt-stem>
                       </dt>
                       <dd>
                          <p id="_">is the repeatability limit.</p>
                       </dd>
                       <dt>
                          <stem type="AsciiMath" id="_">s_1</stem>
                          <fmt-stem type="AsciiMath">
                             <semx element="stem" source="_">s_1</semx>
                          </fmt-stem>
                       </dt>
                       <dd>
                          <p id="_">is the other repeatability limit.</p>
                       </dd>
                    </dl>
                    <note id="_" autonum="">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">NOTE</span>
                          </span>
                          <span class="fmt-label-delim">
                             <tab/>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Note</span>
                       </fmt-xref-label>
                       <fmt-xref-label container="A">
                          <span class="fmt-xref-container">
                             <semx element="foreword" source="A">Foreword</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Note</span>
                       </fmt-xref-label>
                       <p id="_">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
                    </note>
                 </formula>
                 <formula id="_" autonum="1">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <span class="fmt-autonum-delim">(</span>
                          1
                          <span class="fmt-autonum-delim">)</span>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Formula</span>
                       <span class="fmt-autonum-delim">(</span>
                       <semx element="autonum" source="_">1</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </fmt-xref-label>
                    <fmt-xref-label container="A">
                       <span class="fmt-xref-container">
                          <semx element="foreword" source="A">Foreword</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Formula</span>
                       <span class="fmt-autonum-delim">(</span>
                       <semx element="autonum" source="_">1</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </fmt-xref-label>
                    <stem type="AsciiMath" id="_">r = 1 %</stem>
                    <fmt-stem type="AsciiMath">
                       <semx element="stem" source="_">r = 1 %</semx>
                    </fmt-stem>
                 </formula>
              </foreword>
           </preface>
        </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
              <br/>
                <div id="A">
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
                      <span class='note_label'>NOTE  </span>
                        [durationUnits] is essentially a duration statement without
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
          <div id="A">
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
                    <span class='note_label'>NOTE
                <span style='mso-tab-count:1'>&#160; </span></span>
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
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", pres_output, true)
    expect(Xml::C14n.format(strip_guid(output)))
      .to be_equivalent_to Xml::C14n.format(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", pres_output, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(output)
      .at("//div[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(word)
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
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Contents</fmt-title>
              </clause>
              <foreword id="_" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <formula id="_" unnumbered="true">
                    <stem type="AsciiMath" id="_">r = 1 %</stem>
                    <fmt-stem type="AsciiMath">
                       <semx element="stem" source="_">r = 1 %</semx>
                    </fmt-stem>
                    <p>
                       where
                       <stem type="AsciiMath" id="_">r</stem>
                       <fmt-stem type="AsciiMath">
                          <semx element="stem" source="_">r</semx>
                       </fmt-stem>
                       is the repeatability limit.
                    </p>
                    <note id="_" autonum="">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">NOTE</span>
                          </span>
                          <span class="fmt-label-delim">
                             <tab/>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Note</span>
                       </fmt-xref-label>
                       <fmt-xref-label container="_">
                          <span class="fmt-xref-container">
                             <semx element="foreword" source="_">Foreword</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Note</span>
                       </fmt-xref-label>
                       <p id="_">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
                    </note>
                 </formula>
                 <formula id="_" autonum="1">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <span class="fmt-autonum-delim">(</span>
                          1
                          <span class="fmt-autonum-delim">)</span>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Formula</span>
                       <span class="fmt-autonum-delim">(</span>
                       <semx element="autonum" source="_">1</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </fmt-xref-label>
                    <fmt-xref-label container="_">
                       <span class="fmt-xref-container">
                          <semx element="foreword" source="_">Foreword</semx>
                       </span>
                       <span class="fmt-comma">,</span>
                       <span class="fmt-element-name">Formula</span>
                       <span class="fmt-autonum-delim">(</span>
                       <semx element="autonum" source="_">1</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </fmt-xref-label>
                    <stem type="AsciiMath" id="_">r = 1 %</stem>
                    <fmt-stem type="AsciiMath">
                       <semx element="stem" source="_">r = 1 %</semx>
                    </fmt-stem>
                 </formula>
              </foreword>
           </preface>
        </iso-standard>
    OUTPUT
    html = <<~"OUTPUT"
      #{HTML_HDR}
              <br/>
              <div id="_">
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
                   <p><span class="note_label">NOTE  </span>[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
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
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(pres_output))).to be_equivalent_to Xml::C14n.format(presxml)
    output = IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)
    expect(Xml::C14n.format(strip_guid(output))).to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes figures" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword>
            <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
          <name>Split-it-right <em>sample</em> divider<fn reference="1"><p>X</p></fn></name>
          <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
          <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
          <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="image/png"/>
          <image src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="application/xml"/>
          <fn reference="a">
          <p id="_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852">The time <stem type="AsciiMath">t_90</stem> was estimated to be 18,2 min for this example.</p>
        </fn>
          <dl>
          <dt>A</dt>
          <dd><p>B</p></dd>
          </dl>
                <source status="generalisation">
          <origin bibitemid="ISO712" type="inline" citeas="ISO 712">
            <localityStack>
              <locality type="section">
                <referenceFrom>1</referenceFrom>
              </locality>
            </localityStack>
          </origin>
          <modification>
            <p id="_">with adjustments</p>
          </modification>
        </source>
                <source status="specialisation">
          <origin bibitemid="ISO712" type="inline" citeas="ISO 712">
            <localityStack>
              <locality type="section">
                <referenceFrom>2</referenceFrom>
              </locality>
            </localityStack>
          </origin>
        </source>
        </figure>
        <figure id="figure-B">
        <pre alt="A B">A &#x3c;
        B</pre>
        </figure>
        <figure id="figure-C" unnumbered="true">
        <pre>A &#x3c;
        B</pre>
        </figure>
            </foreword></preface>
                  <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
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
      </bibliography>
            </iso-standard>
    INPUT
    presxml = <<~OUTPUT
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
                <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" autonum="1">
                   <name id="_">
                      Split-it-right
                      <em>sample</em>
                      divider
                      <fn reference="1" original-reference="1" target="_" original-id="_">
                         <p>X</p>
                         <fmt-fn-label>
                            <sup>
                               <semx element="autonum" source="_">1</semx>
                               <span class="fmt-label-delim">)</span>
                            </sup>
                         </fmt-fn-label>
                      </fn>
                   </name>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-1">1</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">
                         Split-it-right
                         <em>sample</em>
                         divider
                         <fn reference="1" original-reference="1" id="_" target="_">
                            <p>X</p>
                            <fmt-fn-label>
                               <sup>
                                  <semx element="autonum" source="_">1</semx>
                                  <span class="fmt-label-delim">)</span>
                               </sup>
                            </fmt-fn-label>
                         </fn>
                      </semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="figureA-1">1</semx>
                   </fmt-xref-label>
                   <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                   <image src="rice_images/rice_image1.png" height="20" width="auto" id="_" mimetype="image/png"/>
                   <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto" id="_" mimetype="image/png"/>
                   <image src="data:application/xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjw/eG1sLXN0eWxlc2hlZXQgdHlwZT0idGV4dC94c2wiIGhyZWY9Ii4uLy4uLy4uL3hzbC9yZXNfZG9jL2ltZ2ZpbGUueHNsIj8+CjwhRE9DVFlQRSBpbWdmaWxlLmNvbnRlbnQgU1lTVEVNICIuLi8uLi8uLi9kdGQvdGV4dC5lbnQiPgo8aW1nZmlsZS5jb250ZW50IG1vZHVsZT0iZnVuZGFtZW50YWxzX29mX3Byb2R1Y3RfZGVzY3JpcHRpb25fYW5kX3N1cHBvcnQiIGZpbGU9ImFjdGlvbl9zY2hlbWFleHBnMS54bWwiPgo8aW1nIHNyYz0iYWN0aW9uX3NjaGVtYWV4cGcxLmdpZiI+CjxpbWcuYXJlYSBzaGFwZT0icmVjdCIgY29vcmRzPSIyMTAsMTg2LDM0MywyMjciIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9iYXNpY19hdHRyaWJ1dGVfc2NoZW1hL2Jhc2ljX2F0dHJpYnV0ZV9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMTAsMTAsOTYsNTEiIGhyZWY9Ii4uLy4uL3Jlc291cmNlcy9hY3Rpb25fc2NoZW1hL2FjdGlvbl9zY2hlbWEueG1sIiAvPgo8aW1nLmFyZWEgc2hhcGU9InJlY3QiIGNvb3Jkcz0iMjEwLDI2NCwzNTgsMzA1IiBocmVmPSIuLi8uLi9yZXNvdXJjZXMvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEvc3VwcG9ydF9yZXNvdXJjZV9zY2hlbWEueG1sIiAvPgo8L2ltZz4KPC9pbWdmaWxlLmNvbnRlbnQ+Cg==" height="20" width="auto" id="_" mimetype="application/xml"/>
                   <fn reference="a" id="_" target="_">
                      <p original-id="_">
                         The time
                         <stem type="AsciiMath" id="_">t_90</stem>
                         <fmt-stem type="AsciiMath">
                            <semx element="stem" source="_">t_90</semx>
                         </fmt-stem>
                         was estimated to be 18,2 min for this example.
                      </p>
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">a</semx>
                         </sup>
                      </fmt-fn-label>
                   </fn>
                   <p keep-with-next="true">
                      <strong>Key</strong>
                   </p>
                   <dl class="formula_dl">
                      <dt>
                         <p>
                            <fmt-fn-label>
                               <sup>
                                  <semx element="autonum" source="_">a</semx>
                               </sup>
                            </fmt-fn-label>
                         </p>
                      </dt>
                      <dd>
                         <fmt-fn-body id="_" target="_" reference="a">
                            <semx element="fn" source="_">
                               <p id="_">
                                  The time
                                  <stem type="AsciiMath" id="_">t_90</stem>
                                  <fmt-stem type="AsciiMath">
                                     <semx element="stem" source="_">t_90</semx>
                                  </fmt-stem>
                                  was estimated to be 18,2 min for this example.
                               </p>
                            </semx>
                         </fmt-fn-body>
                      </dd>
                      <dt>A</dt>
                      <dd>
                         <p>B</p>
                      </dd>
                   </dl>
                   <source status="generalisation">
                      [SOURCE:
                      <origin bibitemid="ISO712" type="inline" citeas="ISO 712" id="_">
                         <localityStack>
                            <locality type="section">
                               <referenceFrom>1</referenceFrom>
                            </locality>
                         </localityStack>
                      </origin>
                      <semx element="origin" source="_">
                         <fmt-xref type="inline" target="ISO712">
                            <span class="stdpublisher">ISO </span>
                            <span class="stddocNumber">712</span>
                            , Section 1
                         </fmt-xref>
                      </semx>
                      —
                      <semx element="modification" source="_">with adjustments</semx>
                      ;
                      <origin bibitemid="ISO712" type="inline" citeas="ISO 712" id="_">
                         <localityStack>
                            <locality type="section">
                               <referenceFrom>2</referenceFrom>
                            </locality>
                         </localityStack>
                      </origin>
                      <semx element="origin" source="_">
                         <fmt-xref type="inline" target="ISO712">
                            <span class="stdpublisher">ISO </span>
                            <span class="stddocNumber">712</span>
                            , Section 2
                         </fmt-xref>
                      </semx>
                      ]
                   </source>
                </figure>
                <figure id="figure-B" autonum="2">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figure-B">2</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="figure-B">2</semx>
                   </fmt-xref-label>
                   <pre alt="A B">A &lt;
         B</pre>
                </figure>
                <figure id="figure-C" unnumbered="true">
                   <pre>A &lt;
         B</pre>
                </figure>
             </foreword>
          </preface>
          <sections>
             <references id="_" obligation="informative" normative="true" displayorder="3">
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
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">Cereals and cereal products</title>
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
                   <p>
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">1</semx>
                         </sup>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      X
                   </p>
                </semx>
             </fmt-fn-body>
          </fmt-footnote-container>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert
       .new(presxml_options)
       .convert("test", input, true).gsub(/&lt;/, "&#x3c;"))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "adds ordered list classes for HTML" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword id="A">
        <ol id="B">
        <li><p>A</p></li>
        <li><p>B</p></li>
        <li><ol id="C">
        <li>C</li>
        <li>D</li>
        <li><ol id="D">
        <li>E</li>
        <li>F</li>
        <li><ol id="E">
        <li>G</li>
        <li>H</li>
        <li><ol id="F">
        <li>I</li>
        <li>J</li>
        <li><ol id="G">
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
           <clause type="toc" id="_" displayorder="1"> 
          <fmt-title depth="1">Contents</fmt-title>
          </clause>
          <foreword displayorder='2' id="A">
                   <title id="_">Foreword</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
            <ol type='alphabet' id="B">
              <li id="_" label="a">
                <p>A</p>
              </li>
              <li id="_" label="b">
                <p>B</p>
              </li>
              <li id="_" label="c">
                <ol type='arabic' id="C">
                  <li id="_" label="1">C</li>
                  <li id="_" label="2">D</li>
                  <li id="_" label="3">
                    <ol type='roman' id="D">
                      <li id="_" label="i">E</li>
                      <li id="_" label="ii">F</li>
                      <li id="_" label="iii">
                        <ol type='alphabet_upper' id="E">
                          <li id="_" label="A">G</li>
                          <li id="_" label="B">H</li>
                          <li id="_" label="C">
                            <ol type='roman_upper' id="F">
                              <li id="_" label="I">I</li>
                              <li id="_" label="II">J</li>
                              <li id="_" label="III">
                                <ol type='alphabet' id="G">
                                  <li id="_" label="a">K</li>
                                  <li id="_" label="b">L</li>
                                  <li id="_" label="c">M</li>
                                </ol>
                              </li>
                              <li id="_" label="IV">N</li>
                            </ol>
                          </li>
                          <li id="_" label="D">O</li>
                        </ol>
                      </li>
                      <li id="_" label="iv">P</li>
                    </ol>
                  </li>
                  <li id="_" label="4">Q</li>
                </ol>
              </li>
              <li id="_" label="d">R</li>
            </ol>
          </foreword>
        </preface>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                    <br/>
             <div id="A">
               <h1 class='ForewordTitle'>Foreword</h1>
                              <div class="ol_wrap">
                 <ol type="a" class="alphabet" id="B">
                   <li id="_">
                     <p>A</p>
                   </li>
                   <li id="_">
                     <p>B</p>
                   </li>
                   <li id="_">
                     <div class="ol_wrap">
                       <ol type="1" class="arabic" id="C">
                         <li id="_">C</li>
                         <li id="_">D</li>
                         <li id="_">
                           <div class="ol_wrap">
                             <ol type="i" class="roman" id="D">
                               <li id="_">E</li>
                               <li id="_">F</li>
                               <li id="_">
                                 <div class="ol_wrap">
                                   <ol type="A" class="alphabet_upper" id="E">
                                     <li id="_">G</li>
                                     <li id="_">H</li>
                                     <li id="_">
                                       <div class="ol_wrap">
                                         <ol type="I" class="roman_upper" id="F">
                                           <li id="_">I</li>
                                           <li id="_">J</li>
                                           <li id="_">
                                             <div class="ol_wrap">
                                               <ol type="a" class="alphabet" id="G">
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
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes ordered lists with start" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword id="A">
      <ol start="4" id="B">
      <li>List</li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type='presentation'>
         <preface>
           <clause type="toc" id="_" displayorder="1"> 
          <fmt-title depth="1">Contents</fmt-title>
          </clause>
           <foreword id="A" displayorder='2'>
                    <title id="_">Foreword</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
             <ol start='4' id="B" type='alphabet'>
               <li id="_" label="d">List</li>
             </ol>
           </foreword>
         </preface>
       </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
                    <br/>
             <div id="A">
               <h1 class='ForewordTitle'>Foreword</h1>
               <div class="ol_wrap">
               <ol type='a' start='4' id="B" class='alphabet'>
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
            <div id="A">
              <h1 class='ForewordTitle'>Foreword</h1>
              <div class="ol_wrap">
              <ol type='a' start='4' id="B">
                <li id="_">List</li>
              </ol>
              </div>
            </div>
            <p> </p>
          </div>
    OUTPUT

    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true))
      .at("//div[@class = 'WordSection2']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "ignores intervening ul in numbering ol" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword id="A">
      <ul>
      <li>A</li>
      <li>
      <ol id="B">
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
           <clause type="toc" id="_" displayorder="1"> 
          <fmt-title depth="1">Contents</fmt-title>
          </clause>
           <foreword id="A" displayorder='2'>
                    <title id="_">Foreword</title>
         <fmt-title depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
             <ul>
               <li>A</li>
               <li>
                 <ol id="B" type='alphabet'>
                   <li id="_" label="a">List</li>
                 </ol>
               </li>
             </ul>
           </foreword>
         </preface>
       </iso-standard>
    INPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end
end
