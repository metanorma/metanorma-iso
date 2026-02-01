require "spec_helper"

RSpec.describe IsoDoc do
  it "renders figures" do
    input = <<~INPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml'>
        <preface>
        <clause type="toc" id="_" displayorder="1"> <fmt-title id="_" depth="1">Contents</tfmt-itle> </clause>
          <foreword id='fwd' displayorder="2"><fmt-title id="_">Foreword</fmt-title>
            <p>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id='scope' type="scope" displayorder="3">
            <fmt-title id="_">Scope</fmt-title>
            <figure id='N'>
              <fmt-name id="_">Figure 1&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
              <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
            </figure>
            <p>
            </p>
          </clause>
          <clause id='widgets' displayorder="4">
            <fmt-title id="_">Widgets</fmt-title>
            <clause id='widgets1'>
              <figure id='note1'>
                <fmt-name id="_">Figure 2&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
                <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
              </figure>
              <figure id='note2'>
                <fmt-name id="_">Figure 3&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
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
              <fmt-name id="_">Figure A.1&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
              <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
            </figure>
          </clause>
          <clause id='annex1b'>
            <figure id='Anote1'>
              <fmt-name id="_">Figure A.2&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
              <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
            </figure>
            <figure id='Anote2'>
              <fmt-name id="_">Figure A.3&#xA0;&#x2014; Split-it-right sample divider</fmt-name>
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
    expect(Canon.format_xml(output)).to be_equivalent_to Canon.format_xml(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", input, true)
    expect(Canon.format_xml(Nokogiri::XML(output).at("//body").to_xml))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "renders subfigures" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
           <preface><foreword id="fwd">
           <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
         <name>Overall title</name>
         <figure id="note1">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         <figure id="note2">
       <name>Subfigure 2</name>
         <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
         </figure>
       </figure>
        <figure id="figureA-2" keep-with-next="true" keep-lines-together="true" unnumbered='true'>
         <name>Overall title</name>
         <figure id="note3">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         </figure>
         <figure id="figureA-3" keep-with-next="true" keep-lines-together="true">
         <name>Overall title</name>
         <figure id="note4" unnumbered="true">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         </figure>
           </foreword></preface>
           </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">Contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" autonum="1">
                   <name id="_">Overall title</name>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-1">1</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">Overall title</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="figureA-1">1</semx>
                   </fmt-xref-label>
                   <figure id="note1" autonum="1 a">
                      <name id="_">Subfigure 1</name>
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="note1">a</semx>
                            <span class="fmt-label-delim">)</span>
                         </span>
                         <span class="fmt-caption-delim">  </span>
                         <semx element="name" source="_">Subfigure 1</semx>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-1">1</semx>
                         <semx element="autonum" source="note1">a</semx>
                         <span class="fmt-autonum-delim">)</span>
                      </fmt-xref-label>
                      <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                   </figure>
                   <figure id="note2" autonum="1 b">
                      <name id="_">Subfigure 2</name>
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="note2">b</semx>
                            <span class="fmt-label-delim">)</span>
                         </span>
                         <span class="fmt-caption-delim">  </span>
                         <semx element="name" source="_">Subfigure 2</semx>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-1">1</semx>
                         <semx element="autonum" source="note2">b</semx>
                         <span class="fmt-autonum-delim">)</span>
                      </fmt-xref-label>
                      <image src="rice_images/rice_image1.png" height="20" width="auto" id="_" mimetype="image/png"/>
                   </figure>
                </figure>
                <figure id="figureA-2" keep-with-next="true" keep-lines-together="true" unnumbered="true">
                   <name id="_">Overall title</name>
                   <fmt-name id="_">
                      <semx element="name" source="_">Overall title</semx>
                   </fmt-name>
                   <figure id="note3" autonum="a">
                      <name id="_">Subfigure 1</name>
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="note3">a</semx>
                            <span class="fmt-label-delim">)</span>
                         </span>
                         <span class="fmt-caption-delim">  </span>
                         <semx element="name" source="_">Subfigure 1</semx>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-2">(??)</semx>
                         <semx element="autonum" source="note3">a</semx>
                         <span class="fmt-autonum-delim">)</span>
                      </fmt-xref-label>
                      <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                   </figure>
                </figure>
                <figure id="figureA-3" keep-with-next="true" keep-lines-together="true" autonum="2">
                   <name id="_">Overall title</name>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-3">2</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">Overall title</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="figureA-3">2</semx>
                   </fmt-xref-label>
                   <figure id="note4" unnumbered="true">
                      <name id="_">Subfigure 1</name>
                      <fmt-name id="_">
                         <semx element="name" source="_">Subfigure 1</semx>
                      </fmt-name>
                      <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                   </figure>
                </figure>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <br/>
                <div id="fwd">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <div id="figureA-1" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div id="note1" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                         <p class="FigureTitle" style="text-align:center;">a)  Subfigure 1</p>
                      </div>
                      <div id="note2" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                         <p class="FigureTitle" style="text-align:center;">b)  Subfigure 2</p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Figure 1 — Overall title</p>
                   </div>
                   <div id="figureA-2" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div id="note3" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                         <p class="FigureTitle" style="text-align:center;">a)  Subfigure 1</p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Overall title</p>
                   </div>
                   <div id="figureA-3" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div id="note4" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                         <p class="FigureTitle" style="text-align:center;">Subfigure 1</p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Figure 2 — Overall title</p>
                   </div>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
        <html xmlns:epub="http://www.idpf.org/2007/ops" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" lang="en">
    <head><style></style> <style></style></head>
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
                <div id="fwd">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <div id="figureA-1" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div id="note1" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                         <p class="FigureTitle" style="text-align:center;">a)  Subfigure 1</p>
                      </div>
                      <div id="note2" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                         <p class="FigureTitle" style="text-align:center;">b)  Subfigure 2</p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Figure 1 — Overall title</p>
                   </div>
                   <div id="figureA-2" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div id="note3" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                         <p class="FigureTitle" style="text-align:center;">a)  Subfigure 1</p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Overall title</p>
                   </div>
                   <div id="figureA-3" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div id="note4" class="figure">
                         <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                         <p class="FigureTitle" style="text-align:center;">Subfigure 1</p>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Figure 2 — Overall title</p>
                   </div>
                </div>
                <p> </p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection3"/>
             <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
             <div class="colophon"/>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output
      .gsub(/&lt;/, "&#x3c;"))))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    FileUtils.rm_rf "spec/assets/odf1.emf"
    expect(strip_guid(Canon.format_xml(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "processes tabular subfigures" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
           <preface><foreword id="fwd">
           <figure id="figureA-1" keep-with-next="true" keep-lines-together="true">
         <name>Overall title</name>
         <table id="T">
         <tbody>
         <tr>
         <td>
         <figure id="note1">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         </td>
         <td>
         <figure id="note2">
       <name>Subfigure 2</name>
         <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
         </figure>
         </td>
         </tr>
         </tbody>
         </table>
       </figure>
        <figure id="figureA-2" keep-with-next="true" keep-lines-together="true" unnumbered='true'>
         <name>Overall title</name>
        <table id="T1">
         <tbody>
         <tr>
         <td>
         <figure id="note3">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         </td>
         </tr>
         </tbody>
         </table>
         </figure>
         <figure id="figureA-3" keep-with-next="true" keep-lines-together="true">
         <name>Overall title</name>
         <table id="T2">
         <tbody>
         <tr>
         <td>
         <figure id="note4" unnumbered="true">
       <name>Subfigure 1</name>
         <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
         </figure>
         </tr>
         </tbody>
         </table>
         </figure>
           </foreword></preface>
           </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">Contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" autonum="1">
                   <name id="_">Overall title</name>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-1">1</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">Overall title</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="figureA-1">1</semx>
                   </fmt-xref-label>
                   <table id="T">
                      <tbody>
                         <tr>
                            <td>
                               <figure id="note1" autonum="1 a">
                                  <name id="_">Subfigure 1</name>
                                  <fmt-name id="_">
                                     <span class="fmt-caption-label">
                                        <semx element="autonum" source="note1">a</semx>
                                        <span class="fmt-label-delim">)</span>
                                     </span>
                                     <span class="fmt-caption-delim">  </span>
                                     <semx element="name" source="_">Subfigure 1</semx>
                                  </fmt-name>
                                  <fmt-xref-label>
                                     <span class="fmt-element-name">Figure</span>
                                     <semx element="autonum" source="figureA-1">1</semx>
                                     <semx element="autonum" source="note1">a</semx>
                                     <span class="fmt-autonum-delim">)</span>
                                  </fmt-xref-label>
                                  <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                               </figure>
                            </td>
                            <td>
                               <figure id="note2" autonum="1 b">
                                  <name id="_">Subfigure 2</name>
                                  <fmt-name id="_">
                                     <span class="fmt-caption-label">
                                        <semx element="autonum" source="note2">b</semx>
                                        <span class="fmt-label-delim">)</span>
                                     </span>
                                     <span class="fmt-caption-delim">  </span>
                                     <semx element="name" source="_">Subfigure 2</semx>
                                  </fmt-name>
                                  <fmt-xref-label>
                                     <span class="fmt-element-name">Figure</span>
                                     <semx element="autonum" source="figureA-1">1</semx>
                                     <semx element="autonum" source="note2">b</semx>
                                     <span class="fmt-autonum-delim">)</span>
                                  </fmt-xref-label>
                                  <image src="rice_images/rice_image1.png" height="20" width="auto" id="_" mimetype="image/png"/>
                               </figure>
                            </td>
                         </tr>
                      </tbody>
                   </table>
                </figure>
                <figure id="figureA-2" keep-with-next="true" keep-lines-together="true" unnumbered="true">
                   <name id="_">Overall title</name>
                   <fmt-name id="_">
                      <semx element="name" source="_">Overall title</semx>
                   </fmt-name>
                   <table id="T1">
                      <tbody>
                         <tr>
                            <td>
                               <figure id="note3" autonum="a">
                                  <name id="_">Subfigure 1</name>
                                  <fmt-name id="_">
                                     <span class="fmt-caption-label">
                                        <semx element="autonum" source="note3">a</semx>
                                        <span class="fmt-label-delim">)</span>
                                     </span>
                                     <span class="fmt-caption-delim">  </span>
                                     <semx element="name" source="_">Subfigure 1</semx>
                                  </fmt-name>
                                  <fmt-xref-label>
                                     <span class="fmt-element-name">Figure</span>
                                     <semx element="autonum" source="figureA-2">(??)</semx>
                                     <semx element="autonum" source="note3">a</semx>
                                     <span class="fmt-autonum-delim">)</span>
                                  </fmt-xref-label>
                                  <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                               </figure>
                            </td>
                         </tr>
                      </tbody>
                   </table>
                </figure>
                <figure id="figureA-3" keep-with-next="true" keep-lines-together="true" autonum="2">
                   <name id="_">Overall title</name>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Figure</span>
                         <semx element="autonum" source="figureA-3">2</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">Overall title</semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="figureA-3">2</semx>
                   </fmt-xref-label>
                   <table id="T2">
                      <tbody>
                         <tr>
                            <td>
                               <figure id="note4" unnumbered="true">
                                  <name id="_">Subfigure 1</name>
                                  <fmt-name id="_">
                                     <semx element="name" source="_">Subfigure 1</semx>
                                  </fmt-name>
                                  <image src="rice_images/rice_image1.png" height="20" width="30" id="_" mimetype="image/png" alt="alttext" title="titletxt"/>
                               </figure>
                            </td>
                         </tr>
                      </tbody>
                   </table>
                </figure>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <br/>
                <div id="fwd">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <div id="figureA-1" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <table id="T" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                         <tbody>
                            <tr>
                               <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">
                                  <div id="note1" class="figure">
                                     <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                                     <p class="FigureTitle" style="text-align:center;">a)  Subfigure 1</p>
                                  </div>
                               </td>
                               <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">
                                  <div id="note2" class="figure">
                                     <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                                     <p class="FigureTitle" style="text-align:center;">b)  Subfigure 2</p>
                                  </div>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                      <p class="FigureTitle" style="text-align:center;">Figure 1 — Overall title</p>
                   </div>
                   <div id="figureA-2" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <table id="T1" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                         <tbody>
                            <tr>
                               <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">
                                  <div id="note3" class="figure">
                                     <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                                     <p class="FigureTitle" style="text-align:center;">a)  Subfigure 1</p>
                                  </div>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                      <p class="FigureTitle" style="text-align:center;">Overall title</p>
                   </div>
                   <div id="figureA-3" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <table id="T2" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                         <tbody>
                            <tr>
                               <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">
                                  <div id="note4" class="figure">
                                     <img src="rice_images/rice_image1.png" height="20" width="30" title="titletxt" alt="alttext"/>
                                     <p class="FigureTitle" style="text-align:center;">Subfigure 1</p>
                                  </div>
                               </td>
                            </tr>
                         </tbody>
                      </table>
                      <p class="FigureTitle" style="text-align:center;">Figure 2 — Overall title</p>
                   </div>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
    <html xmlns:epub="http://www.idpf.org/2007/ops" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" lang="en">
    <head><style></style> <style></style></head>
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
                <div id="fwd">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <div id="figureA-1" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div align="center" class="table_container">
                         <table id="T" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                            <tbody>
                               <tr>
                                  <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                                     <div id="note1" class="figure">
                                        <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                                        <p class="FigureTitle" style="text-align:center;">a)  Subfigure 1</p>
                                     </div>
                                  </td>
                                  <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                                     <div id="note2" class="figure">
                                        <img src="rice_images/rice_image1.png" height="20" width="auto"/>
                                        <p class="FigureTitle" style="text-align:center;">b)  Subfigure 2</p>
                                     </div>
                                  </td>
                               </tr>
                            </tbody>
                         </table>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Figure 1 — Overall title</p>
                   </div>
                   <div id="figureA-2" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div align="center" class="table_container">
                         <table id="T1" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                            <tbody>
                               <tr>
                                  <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                                     <div id="note3" class="figure">
                                        <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                                        <p class="FigureTitle" style="text-align:center;">a)  Subfigure 1</p>
                                     </div>
                                  </td>
                               </tr>
                            </tbody>
                         </table>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Overall title</p>
                   </div>
                   <div id="figureA-3" class="figure" style="page-break-after: avoid;page-break-inside: avoid;">
                      <div align="center" class="table_container">
                         <table id="T2" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                            <tbody>
                               <tr>
                                  <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                                     <div id="note4" class="figure">
                                        <img src="rice_images/rice_image1.png" height="20" alt="alttext" title="titletxt" width="30"/>
                                        <p class="FigureTitle" style="text-align:center;">Subfigure 1</p>
                                     </div>
                                  </td>
                               </tr>
                            </tbody>
                         </table>
                      </div>
                      <p class="FigureTitle" style="text-align:center;">Figure 2 — Overall title</p>
                   </div>
                </div>
                <p> </p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection3"/>
             <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
             <div class="colophon"/>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output
      .gsub(/&lt;/, "&#x3c;"))))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    FileUtils.rm_rf "spec/assets/odf1.emf"
    expect(strip_guid(Canon.format_xml(IsoDoc::Iso::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(/['"][^'".]+\.(gif|xml)['"]/, "'_.\\1'")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))))
      .to be_equivalent_to Canon.format_xml(word)
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
                <fmt-title depth="1" id="_">Contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <clause id="widgets" displayorder="2">
                <title id="_">Widgets</title>
                <fmt-title depth="1" id="_">
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
                   <fmt-name id="_">
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
                      <fmt-name id="_">
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
                      <fmt-xref-label container="N">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Figure</span>
                            <semx element="autonum" source="N">1</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Note</span>
                         <semx element="autonum" source="A">1</semx>
                      </fmt-xref-label>
                      Note 1
                   </note>
                   <note id="B" type="units">Units in mm</note>
                   <note id="C" autonum="2">
                      <fmt-name id="_">
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
                      <fmt-xref-label container="N">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Figure</span>
                            <semx element="autonum" source="N">1</semx>
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
                <p class="FigureTitle" style="text-align:center;">Figure 1 &#x2014; Figure 1</p>
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
                <p class="FigureTitle" style="text-align:center;">Figure 1 &#x2014; Figure 1</p>
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
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", pres_output, true)
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(output).at("//body").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
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
        <key>
          <dl>
          <dt>A</dt>
          <dd><p>B</p></dd>
          </dl>
        </key>
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
               <fmt-title depth="1" id="_">Contents</fmt-title>
            </clause>
            <foreword id="_" displayorder="2">
               <title id="_">Foreword</title>
               <fmt-title depth="1" id="_">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <figure id="figureA-1" keep-with-next="true" keep-lines-together="true" autonum="1">
                  <name id="_">
                     Split-it-right
                     <em>sample</em>
                     divider
                     <fn original-id="_" original-reference="1">
                        <p>X</p>
                     </fn>
                  </name>
                  <fmt-name id="_">
                     <span class="fmt-caption-label">
                        <span class="fmt-element-name">Figure</span>
                        <semx element="autonum" source="figureA-1">1</semx>
                     </span>
                     <span class="fmt-caption-delim"> — </span>
                     <semx element="name" source="_">
                        Split-it-right
                        <em>sample</em>
                        divider
                        <fn reference="1" id="_" original-reference="1" target="_">
                           <p>X</p>
                           <fmt-fn-label>
                              <span class="fmt-caption-label">
                                 <sup>
                                    <semx element="autonum" source="_">1</semx>
                                    <span class="fmt-label-delim">)</span>
                                 </sup>
                              </span>
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
                        <span class="fmt-caption-label">
                           <sup>
                              <semx element="autonum" source="_">a</semx>
                           </sup>
                        </span>
                     </fmt-fn-label>
                  </fn>
           <key class="formula_dl">
              <name>Key</name>
              <dl>
                     <dt>
                        <p>
                           <fmt-fn-label>
                              <span class="fmt-caption-label">
                                 <sup>
                                    <semx element="autonum" source="_">a</semx>
                                 </sup>
                              </span>
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
                  </key>
                  <source status="generalisation" id="_">
                     <origin bibitemid="ISO712" type="inline" citeas="ISO 712">
                        <localityStack>
                           <locality type="section">
                              <referenceFrom>1</referenceFrom>
                           </locality>
                        </localityStack>
                     </origin>
                     <modification id="_">
                        <p id="_">with adjustments</p>
                     </modification>
                  </source>
                  <fmt-source>
                     [SOURCE:
                     <semx element="source" source="_">
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
                     </semx>
                     ;
                     <semx element="source" source="_">
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
                     </semx>
                     ]
                  </fmt-source>
                  <source status="specialisation" id="_">
                     <origin bibitemid="ISO712" type="inline" citeas="ISO 712">
                        <localityStack>
                           <locality type="section">
                              <referenceFrom>2</referenceFrom>
                           </locality>
                        </localityStack>
                     </origin>
                  </source>
               </figure>
               <figure id="figure-B" autonum="2">
                  <fmt-name id="_">
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
               <fmt-title depth="1" id="_">
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
                  <biblio-tag>
                     <span class="stdpublisher">ISO </span>
                     <span class="stddocNumber">712</span>
                     ,
                  </biblio-tag>
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
                        <span class="fmt-caption-label">
                           <sup>
                              <semx element="autonum" source="_">1</semx>
                           </sup>
                        </span>
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
    expect(Canon.format_xml(strip_guid(IsoDoc::Iso::PresentationXMLConvert
       .new(presxml_options)
       .convert("test", input, true).gsub(/&lt;/, "&#x3c;"))))
      .to be_equivalent_to Canon.format_xml(presxml)
  end
end
