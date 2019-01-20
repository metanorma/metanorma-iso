require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::Iso do
  FileUtils.rm_f "test.html"
  it "processes isodoc as ISO: HTML output" do
    IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[blockquote[^{]+\{[^{]+font-family: "Cambria", serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Cambria", serif;]m)
  end

  it "processes isodoc as ISO: alt HTML output" do
  FileUtils.rm_f "test.html"
    IsoDoc::Iso::HtmlConvert.new({alt: true}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^{]+font-family: "Space Mono", monospace;]m)
    expect(html).to match(%r[blockquote[^{]+\{[^{]+font-family: "Lato", sans-serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Lato", sans-serif;]m)
  end

  it "processes isodoc as ISO: Chinese HTML output" do
  FileUtils.rm_f "test.html"
    IsoDoc::Iso::HtmlConvert.new({script: "Hans"}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[blockquote[^{]+\{[^{]+font-family: "SimSun", serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "SimHei", sans-serif;]m)
  end

  it "processes isodoc as ISO: user nominated fonts" do
  FileUtils.rm_f "test.html"
    IsoDoc::Iso::HtmlConvert.new({bodyfont: "Zapf Chancery", headerfont: "Comic Sans", monospacefont: "Andale Mono"}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html).to match(%r[blockquote[^{]+\{[^{]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: Comic Sans;]m)
  end

  it "processes isodoc as ISO: Word output" do
  FileUtils.rm_f "test.doc"
    IsoDoc::Iso::WordConvert.new({}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
    html = File.read("test.doc", encoding: "utf-8")
    expect(html).to match(%r[\.Sourcecode[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[Quote[^{]+\{[^{]+font-family: "Cambria", serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Cambria", serif;]m)
  end

  it "does not include IEV in references" do
    expect(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
  <eref bibitemid="IEV"/>
  <eref bibitemid="ISO20483"/>
  </p>
    </foreword></preface>
    <bibliography><references id="_normative_references" obligation="informative"><title>Normative References</title>
          <bibitem type="international-standard" id="IEV">
  <title format="text/plain" language="en" script="Latn">Electropedia: 
  The World's Online Electrotechnical Vocabulary</title>
  <uri type="src">http://www.electropedia.org</uri>
  <docidentifier>IEV</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Electrotechnical Commission</name>
      <abbreviation>IEC</abbreviation>
      <uri>www.iec.ch</uri>
    </organization>
  </contributor>
  <language>en</language> <language>fr</language>
  <script>Latn</script>
  <copyright>
    <owner>
      <organization>
      <name>International Electrotechnical Commission</name>
      <abbreviation>IEC</abbreviation>
      <uri>www.iec.ch</uri>
      </organization>
    </owner>
  </copyright>
  <relation type="updates">
    <bibitem>
      <formattedref>IEC 60050</formattedref>
    </bibitem>
  </relation>
</bibitem>
<bibitem id="ISO20483" type="standard">
  <title format="text/plain">Cereals and pulses</title>
  <docidentifier>ISO 20483</docidentifier>
  <date type="published"><from>2013</from><to>2014</to></date>
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
    #{HTML_HDR}
                 <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
         <a href="#IEV">IEV</a>
         <a href="#ISO20483">ISO 20483</a>
         </p>
             </div>
             <p class="zzSTDTitle1"/>
             <div>
               <h1>1.&#160; Normative references</h1>
               <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
               <p id="ISO20483" class="NormRef">ISO 20483, <i> Cereals and pulses</i></p>
             </div>
           </div>
         </body>
       </html>

    OUTPUT
end

  it "processes examples" do
    expect(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <example id="samplecode">
  <p>Hello</p>
</example>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="samplecode" class="example">
                     <p class="example-title">EXAMPLE</p>
         <p>Hello</p>
                 </div>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end


  it "processes sequences of examples" do
    expect(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <example id="samplecode">
  <p>Hello</p>
</example>
    <example id="samplecode2">
  <p>Hello</p>
</example>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="samplecode" class="example">
                     <p class="example-title">EXAMPLE  1</p>
         <p>Hello</p>
                 </div>
                 <div id="samplecode2" class="example">
                     <p class="example-title">EXAMPLE  2</p>
                 <p>Hello</p>
                 </div>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

    it "processes examples (Word)" do
    expect(IsoDoc::Iso::WordConvert.new({}).convert("test", <<~"INPUT", true).sub(/^.*<body/m, "<body")).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <example id="samplecode">
  <p>Hello</p>
</example>
    </foreword></preface>
    </iso-standard>
    INPUT
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
               <table id="samplecode" class="example" cellspacing="0" cellpadding="0" style="mso-table-lspace:15.0cm;margin-left:423.0pt;mso-table-rspace:15.0cm;margin-right:423.0pt;mso-table-bspace:14.2pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-overlap:never;border-collapse:collapse;">
                 <tr>
                   <td valign="top" class="example_label" style="width:82.8pt;padding:0 0 0 1em;margin-left:0pt">EXAMPLE</td>
                   <td valign="top" class="example">
         <p>Hello</p>
       </td>
                 </tr>
               </table>
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
       </html>
    OUTPUT
  end


  it "processes sequences of examples (Word)" do
    expect(IsoDoc::Iso::WordConvert.new({}).convert("test", <<~"INPUT", true).sub(/^.*<body/m, "<body")).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <example id="samplecode">
  <p>Hello</p>
</example>
    <example id="samplecode2">
  <p>Hello</p>
</example>
    </foreword></preface>
    </iso-standard>
    INPUT
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
               <table id="samplecode" class="example" cellspacing="0" cellpadding="0" style="mso-table-lspace:15.0cm;margin-left:423.0pt;mso-table-rspace:15.0cm;margin-right:423.0pt;mso-table-bspace:14.2pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-overlap:never;border-collapse:collapse;">
                 <tr>
                   <td valign="top" class="example_label" style="width:82.8pt;padding:0 0 0 1em;margin-left:0pt">EXAMPLE  1</td>
                   <td valign="top" class="example">
         <p>Hello</p>
       </td>
                 </tr>
               </table>
               <table id="samplecode2" class="example" cellspacing="0" cellpadding="0" style="mso-table-lspace:15.0cm;margin-left:423.0pt;mso-table-rspace:15.0cm;margin-right:423.0pt;mso-table-bspace:14.2pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-overlap:never;border-collapse:collapse;">
                 <tr>
                   <td valign="top" class="example_label" style="width:82.8pt;padding:0 0 0 1em;margin-left:0pt">EXAMPLE  2</td>
                   <td valign="top" class="example">
         <p>Hello</p>
       </td>
                 </tr>
               </table>
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
       </html>
    OUTPUT
  end


end
