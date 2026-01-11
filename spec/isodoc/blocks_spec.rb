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
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
             <foreword id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <example id="samplecode" autonum="">
                   <name id="_">Title</name>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">EXAMPLE</span>
                      </span>
                      <span class="fmt-caption-delim"> &#x2014; </span>
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
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)))).to be_equivalent_to Canon.format_xml(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", pres_output, true)
    expect(Canon.format_xml(strip_guid(output
      .sub(/^.*<body/m, "<body").sub(%r{</body>.*$}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(word)
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
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
             <foreword id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <example id="samplecode" autonum="1">
                   <fmt-name id="_">
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
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">EXAMPLE</span>
                         <semx element="autonum" source="samplecode2">2</semx>
                      </span>
                      <span class="fmt-caption-delim"> &#x2014; </span>
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
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", pres_output, true)
    expect(Canon.format_xml(strip_guid(output
      .sub(/^.*<body/m, "<body").sub(%r{</body>.*$}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(word)
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
          <fmt-title id="_" depth="1">Contents</fmt-title>
        </clause>
          <foreword displayorder="2" id="_">
                   <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
          <admonition id="_" type="caution">
          <name id="_">CAUTION</name>
            <fmt-name id="_">
                  <semx element="name" source="_">CAUTION</semx>
               <span class="fmt-label-delim"> &#x2014; </span>
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
             CAUTION &#x2014; Only use paddy or parboiled rice for the
            determination of husked rice yield.
          </p>
          <p id='_'>Para 2.</p>
        </div>
      </div>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(
      IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//div[h1/@class = 'ForewordTitle']").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
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
          <fmt-title id="_" depth="1">Contents</fmt-title>
          </clause>
          <foreword displayorder="2" id="_">
                   <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
            <admonition id="_" type="caution">
              <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">CAUTION</span>
               </span>
            </fmt-name>
            </admonition>
          </foreword>
        </preface>
      </iso-standard>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
        .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(presxml)
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
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">Contents</fmt-title>
             </clause>
             <foreword id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <admonition id="_" type="caution">
                   <name id="_">Title</name>
                   <fmt-name id="_">
                      <semx element="name" source="_">Title</semx>
                   </fmt-name>
                   <ul>
                      <li id="_">
                         <fmt-name id="_">
                            <semx element="autonum" source="_">—</semx>
                         </fmt-name>
                         List
                      </li>
                   </ul>
                   <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
                </admonition>
             </foreword>
          </preface>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      <div id="_">
               <h1 class='ForewordTitle'>Foreword</h1>
               <div id='_' class='Admonition'>
                        <p class="AdmonitionTitle" style="text-align:center;">Title</p>
                        <div class="ul_wrap">
         <ul>
           <li id="_">List</li>
         </ul>
       </div>
         <p id='_'>Only use paddy or parboiled rice for the determination of husked rice yield.</p>
               </div>
             </div>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(
      IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//div[h1/@class = 'ForewordTitle']").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
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
           <fmt-title id="_" depth="1">Contents</fmt-title>
           </clause>
         </preface>
         <sections>
           <title>A</title>
           <admonition id="_" type="important" displayorder="2">
             <fmt-name id="_">
            <span class="fmt-caption-label">
               <span class="fmt-element-name">
                  <strong>IMPORTANT</strong>
               </span>
            </span>
            <span class="fmt-label-delim">
               <strong> &#x2014; </strong>
            </span>
         </fmt-name>
             <p id="_">
               <strong>The electronic file of this document contains colours which are considered to be useful for the correct understanding of the &lt;document&gt;.</strong>
             </p>
           </admonition>
           <clause id="A" displayorder="3">
           <title id="_">Scope</title>
         <fmt-title id="_" depth="1">
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
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
    .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(presxml)
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
            <fmt-title id="_" depth="1">Contents</fmt-title>
          </clause>
            <foreword displayorder="2" id="_">
                     <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
               <semx element="title" source="_">Foreword</semx>
         </fmt-title>
          <admonition id="_" type="editorial">
                      <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">EDITORIAL NOTE</span>
               </span>
               <span class="fmt-label-delim"> &#x2014; </span>
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
                 <p>EDITORIAL NOTE &#x2014; Only use paddy or parboiled rice for the
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
              <p>EDITORIAL NOTE &#x2014; Only use paddy or parboiled rice for the determination of husked rice yield. </p>
              <p class='ForewordText' id='_'>Para 2.</p>
            </div>
          </div>
          <p> </p>
          </div>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true))
      .at("//div[@class = 'WordSection2']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
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
               <fmt-title id="_" depth="1">Contents</fmt-title>
            </clause>
            <foreword id="A" displayorder="2">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
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
                     <fmt-name id="_">
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
                  <fmt-name id="_">
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
            <div align="left">
            <table id="_" style="text-align:left;" class="formula_dl">
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
            </div>
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
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", pres_output, true)
    expect(Canon.format_xml(strip_guid(output)))
      .to be_equivalent_to Canon.format_xml(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", pres_output, true)
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(output)
      .at("//div[@id = 'A']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
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
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
             <foreword id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
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
                      <fmt-name id="_">
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
                   <fmt-name id="_">
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
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    output = IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true)
    expect(Canon.format_xml(strip_guid(output)))
      .to be_equivalent_to Canon.format_xml(html)
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
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <ol id="B" type="alphabet">
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">a</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <p>A</p>
                   </li>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">b</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <p>B</p>
                   </li>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">c</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <ol id="C" type="arabic">
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">1</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            C
                         </li>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">2</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            D
                         </li>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">3</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            <ol id="D" type="roman">
                               <li id="_">
                                  <fmt-name id="_">
                                     <semx element="autonum" source="_">i</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                                  E
                               </li>
                               <li id="_">
                                  <fmt-name id="_">
                                     <semx element="autonum" source="_">ii</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                                  F
                               </li>
                               <li id="_">
                                  <fmt-name id="_">
                                     <semx element="autonum" source="_">iii</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                                  <ol id="E" type="alphabet_upper">
                                     <li id="_">
                                        <fmt-name id="_">
                                           <semx element="autonum" source="_">A</semx>
                                           <span class="fmt-label-delim">.</span>
                                        </fmt-name>
                                        G
                                     </li>
                                     <li id="_">
                                        <fmt-name id="_">
                                           <semx element="autonum" source="_">B</semx>
                                           <span class="fmt-label-delim">.</span>
                                        </fmt-name>
                                        H
                                     </li>
                                     <li id="_">
                                        <fmt-name id="_">
                                           <semx element="autonum" source="_">C</semx>
                                           <span class="fmt-label-delim">.</span>
                                        </fmt-name>
                                        <ol id="F" type="roman_upper">
                                           <li id="_">
                                              <fmt-name id="_">
                                                 <semx element="autonum" source="_">I</semx>
                                                 <span class="fmt-label-delim">.</span>
                                              </fmt-name>
                                              I
                                           </li>
                                           <li id="_">
                                              <fmt-name id="_">
                                                 <semx element="autonum" source="_">II</semx>
                                                 <span class="fmt-label-delim">.</span>
                                              </fmt-name>
                                              J
                                           </li>
                                           <li id="_">
                                              <fmt-name id="_">
                                                 <semx element="autonum" source="_">III</semx>
                                                 <span class="fmt-label-delim">.</span>
                                              </fmt-name>
                                              <ol id="G" type="alphabet">
                                                 <li id="_">
                                                    <fmt-name id="_">
                                                       <semx element="autonum" source="_">a</semx>
                                                       <span class="fmt-label-delim">)</span>
                                                    </fmt-name>
                                                    K
                                                 </li>
                                                 <li id="_">
                                                    <fmt-name id="_">
                                                       <semx element="autonum" source="_">b</semx>
                                                       <span class="fmt-label-delim">)</span>
                                                    </fmt-name>
                                                    L
                                                 </li>
                                                 <li id="_">
                                                    <fmt-name id="_">
                                                       <semx element="autonum" source="_">c</semx>
                                                       <span class="fmt-label-delim">)</span>
                                                    </fmt-name>
                                                    M
                                                 </li>
                                              </ol>
                                           </li>
                                           <li id="_">
                                              <fmt-name id="_">
                                                 <semx element="autonum" source="_">IV</semx>
                                                 <span class="fmt-label-delim">.</span>
                                              </fmt-name>
                                              N
                                           </li>
                                        </ol>
                                     </li>
                                     <li id="_">
                                        <fmt-name id="_">
                                           <semx element="autonum" source="_">D</semx>
                                           <span class="fmt-label-delim">.</span>
                                        </fmt-name>
                                        O
                                     </li>
                                  </ol>
                               </li>
                               <li id="_">
                                  <fmt-name id="_">
                                     <semx element="autonum" source="_">iv</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                                  P
                               </li>
                            </ol>
                         </li>
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">4</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            Q
                         </li>
                      </ol>
                   </li>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">d</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      R
                   </li>
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
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
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
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <ol start="4" id="B" type="alphabet">
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">d</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      List
                   </li>
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
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true))
      .at("//div[@class = 'WordSection2']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
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
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <ul>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">—</semx>
                      </fmt-name>
                      A
                   </li>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">—</semx>
                      </fmt-name>
                      <ol id="B" type="alphabet">
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">a</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            List
                         </li>
                      </ol>
                   </li>
                </ul>
             </foreword>
          </preface>
       </iso-standard>
    INPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "processes unordered lists" do
    input = <<~INPUT
     <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <clause type="toc" id="_" displayorder="1"> <fmt-title id="_" depth="1">Table of contents</fmt-title> </clause>
          <foreword displayorder="2" id="fwd"><fmt-title id="_">Foreword</fmt-title>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddb"  keep-with-next="true" keep-lines-together="true">
          <name>Caption</name>
        <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a2">Level 1</p>
        </li>
        <li>
          <p id="_60eb765c-1f6c-418a-8016-29efa06bf4f9">deletion of 4.3.</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 2</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 3</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 4</p>
        </li>
        </ul>
        </li>
        </ul>
        </li>
          </ul>
        </li>
      </ul>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <foreword displayorder="1" id="fwd">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">Foreword</fmt-title>
                <ul id="_" keep-with-next="true" keep-lines-together="true">
                   <name id="_">Caption</name>
                   <fmt-name id="_">
                      <semx element="name" source="_">Caption</semx>
                   </fmt-name>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">—</semx>
                      </fmt-name>
                      <p id="_">Level 1</p>
                   </li>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">—</semx>
                      </fmt-name>
                      <p id="_">deletion of 4.3.</p>
                      <ul id="_" keep-with-next="true" keep-lines-together="true">
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">—</semx>
                            </fmt-name>
                            <p id="_">Level 2</p>
                            <ul id="_" keep-with-next="true" keep-lines-together="true">
                               <li id="_">
                                  <fmt-name id="_">
                                     <semx element="autonum" source="_">—</semx>
                                  </fmt-name>
                                  <p id="_">Level 3</p>
                                  <ul id="_" keep-with-next="true" keep-lines-together="true">
                                     <li id="_">
                                        <fmt-name id="_">
                                           <semx element="autonum" source="_">—</semx>
                                        </fmt-name>
                                        <p id="_">Level 4</p>
                                     </li>
                                  </ul>
                               </li>
                            </ul>
                         </li>
                      </ul>
                   </li>
                </ul>
             </foreword>
             <clause type="toc" id="_" displayorder="2">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
       </iso-standard>
      INPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
    presxml = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <foreword displayorder="1" id="fwd">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">Foreword</fmt-title>
                <ul id="_" keep-with-next="true" keep-lines-together="true">
                   <name id="_">Caption</name>
                   <fmt-name id="_">
                      <semx element="name" source="_">Caption</semx>
                   </fmt-name>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">–</semx>
                      </fmt-name>
                      <p id="_">Level 1</p>
                   </li>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">–</semx>
                      </fmt-name>
                      <p id="_">deletion of 4.3.</p>
                      <ul id="_" keep-with-next="true" keep-lines-together="true">
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">–</semx>
                            </fmt-name>
                            <p id="_">Level 2</p>
                            <ul id="_" keep-with-next="true" keep-lines-together="true">
                               <li id="_">
                                  <fmt-name id="_">
                                     <semx element="autonum" source="_">–</semx>
                                  </fmt-name>
                                  <p id="_">Level 3</p>
                                  <ul id="_" keep-with-next="true" keep-lines-together="true">
                                     <li id="_">
                                        <fmt-name id="_">
                                           <semx element="autonum" source="_">–</semx>
                                        </fmt-name>
                                        <p id="_">Level 4</p>
                                     </li>
                                  </ul>
                               </li>
                            </ul>
                         </li>
                      </ul>
                   </li>
                </ul>
             </foreword>
             <clause type="toc" id="_" displayorder="2">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
       </iso-standard>
    INPUT
    input = input.sub("<preface>",
               "<metanorma-extension><presentation-metadata><document-scheme>1951</document-scheme></presentation-metadata></metanorma-extension><preface>")
    pres_output = IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "processes ordered lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword id="_" displayorder="2">
          <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" type="alphabet"  keep-with-next="true" keep-lines-together="true">
          <name>Caption</name>
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">Level 1</p>
          </li>
          </ol>
        <ol id="A">
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">Level 1</p>
          </li>
        <li>
          <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">Level 1</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 2</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 3</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 4</p>
        </li>
        </ol>
        </li>
        </ol>
        </li>
        </ol>
        </li>
        </ol>
        </li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
             <foreword id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <ol id="_" type="alphabet" keep-with-next="true" keep-lines-together="true" autonum="1">
                   <name id="_">Caption</name>
                   <fmt-name id="_">
                      <semx element="name" source="_">Caption</semx>
                   </fmt-name>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">a</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <p id="_">Level 1</p>
                   </li>
                </ol>
                <ol id="A" type="alphabet">
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">a</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <p id="_">Level 1</p>
                   </li>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">b</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <p id="_">Level 1</p>
                      <ol type="arabic">
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">1</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            <p id="_">Level 2</p>
                            <ol type="roman">
                               <li id="_">
                                  <fmt-name id="_">
                                     <semx element="autonum" source="_">i</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                                  <p id="_">Level 3</p>
                                  <ol type="alphabet_upper">
                                     <li id="_">
                                        <fmt-name id="_">
                                           <semx element="autonum" source="_">A</semx>
                                           <span class="fmt-label-delim">.</span>
                                        </fmt-name>
                                        <p id="_">Level 4</p>
                                     </li>
                                  </ol>
                               </li>
                            </ol>
                         </li>
                      </ol>
                   </li>
                </ol>
             </foreword>
          </preface>
       </iso-standard>
    INPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
    presxml = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Contents</fmt-title>
             </clause>
             <foreword id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <ol id="_" type="alphabet" keep-with-next="true" keep-lines-together="true" autonum="1">
                   <name id="_">Caption</name>
                   <fmt-name id="_">
                      <semx element="name" source="_">Caption</semx>
                   </fmt-name>
                   <li id="_">
                      <fmt-name id="_">
                         <span class="fmt-label-delim">(</span>
                         <semx element="autonum" source="_">a</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <p id="_">Level 1</p>
                   </li>
                </ol>
                <ol id="A" type="alphabet">
                   <li id="_">
                      <fmt-name id="_">
                         <span class="fmt-label-delim">(</span>
                         <semx element="autonum" source="_">a</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <p id="_">Level 1</p>
                   </li>
                   <li id="_">
                      <fmt-name id="_">
                         <span class="fmt-label-delim">(</span>
                         <semx element="autonum" source="_">b</semx>
                         <span class="fmt-label-delim">)</span>
                      </fmt-name>
                      <p id="_">Level 1</p>
                      <ol type="arabic">
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">1</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            <p id="_">Level 2</p>
                            <ol type="roman">
                               <li id="_">
                                  <fmt-name id="_">
                                     <semx element="autonum" source="_">i</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </fmt-name>
                                  <p id="_">Level 3</p>
                                  <ol type="alphabet_upper">
                                     <li id="_">
                                        <fmt-name id="_">
                                           <semx element="autonum" source="_">A</semx>
                                           <span class="fmt-label-delim">.</span>
                                        </fmt-name>
                                        <p id="_">Level 4</p>
                                     </li>
                                  </ol>
                               </li>
                            </ol>
                         </li>
                      </ol>
                   </li>
                </ol>
             </foreword>
          </preface>
       </iso-standard>
    INPUT
    input = input.sub("<preface>",
               "<metanorma-extension><presentation-metadata><document-scheme>1951</document-scheme></presentation-metadata></metanorma-extension><preface>")
    pres_output = IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
  end
end
