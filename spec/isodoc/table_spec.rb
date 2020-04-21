require "spec_helper"
  
RSpec.describe IsoDoc do
  it "processes IsoXML tables" do
    FileUtils.rm_f("test.html")
    IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
      <table id="tableD-1" alt="tool tip" summary="long desc">
  <name>Repeatability and reproducibility of <em>husked</em> rice yield</name>
  <thead>
    <tr>
      <td rowspan="2" align="left">Description</td>
      <td colspan="4" align="center">Rice sample</td>
    </tr>
    <tr>
      <td align="left">Arborio</td>
      <td align="center">Drago<fn reference="a">
  <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
</fn></td>
      <td align="center">Balilla<fn reference="a">
  <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
</fn></td>
      <td align="center">Thaibonnet</td>
    </tr>
    </thead>
    <tbody>
    <tr>
      <th align="left">Number of laboratories retained after eliminating outliers</th>
      <td align="center">13</td>
      <td align="center">11</td>
      <td align="center">13</td>
      <td align="center">13</td>
    </tr>
    <tr>
      <td align="left">Mean value, g/100 g</td>
      <td align="center">81,2</td>
      <td align="center">82,0</td>
      <td align="center">81,8</td>
      <td align="center">77,7</td>
    </tr>
    </tbody>
    <tfoot>
    <tr>
      <td align="left">Reproducibility limit, <stem type="AsciiMath">R</stem> (= 2,83 <stem type="AsciiMath">s_R</stem>)</td>
      <td align="center">2,89</td>
      <td align="center">0,57</td>
      <td align="center">2,26</td>
      <td align="center">6,06</td>
    </tr>
  </tfoot>
  <dl>
  <dt>Drago</dt>
<dd>A type of rice</dd>
</dl>
<note><p>This is a table about rice</p></note>
</table>

</foreword>
</preface>
</iso-standard>
    INPUT
       expect(File.exist?("test.html")).to be true
       html = File.read("test.html").sub(/^.*<main /m, '<main ').sub(%r{</main>.*$}m, "</main>")
       expect(xmlpp(html)).to be_equivalent_to xmlpp(<<~"OUTPUT")
       <main class='main-section'>
  <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
  <br/>
  <div>
    <h1 class='ForewordTitle'>Foreword</h1>
    <p class='TableTitle' style='text-align:center;'>
      Table 1&#xA0;&#x2014; Repeatability and reproducibility of
      <i>husked</i>
       rice yield
    </p>
    <table id='tableD-1' class='MsoISOTable' style='border-width:1px;border-spacing:0;' title='tool tip'>
      <caption>
        <span style='display:none'>long desc</span>
      </caption>
      <thead>
        <tr>
          <td rowspan='2' style='text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;padding:0;;text-align:center;vertical-align:middle;' scope='col'>Description</td>
          <td colspan='4' style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;padding:0;;text-align:center;vertical-align:middle;' scope='colgroup'>Rice sample</td>
        </tr>
        <tr>
          <td style='text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;padding:0;;text-align:center;vertical-align:middle;' scope='col'>Arborio</td>
          <td style='text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;padding:0;;text-align:center;vertical-align:middle;' scope='col'>
            Drago
            <a href='#tableD-1a' class='TableFootnoteRef'>a)</a>
          </td>
          <td style='text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;padding:0;;text-align:center;vertical-align:middle;' scope='col'>
            Balilla
            <a href='#tableD-1a' class='TableFootnoteRef'>a)</a>
          </td>
          <td style='text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;padding:0;;text-align:center;vertical-align:middle;' scope='col'>Thaibonnet</td>
        </tr>
      </thead>
      <tbody>
        <tr>
          <th style='font-weight:bold;text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;padding:0;' scope='row'>Number of laboratories retained after eliminating outliers</th>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;padding:0;'>13</td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;padding:0;'>11</td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;padding:0;'>13</td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;padding:0;'>13</td>
        </tr>
        <tr>
          <td style='text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;padding:0;'>Mean value, g/100 g</td>
          <td style='text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;padding:0;'>81,2</td>
          <td style='text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;padding:0;'>82,0</td>
          <td style='text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;padding:0;'>81,8</td>
          <td style='text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;padding:0;'>77,7</td>
        </tr>
      </tbody>
      <tfoot>
        <tr>
          <td style='text-align:left;border-top:solid windowtext 1.5pt;border-bottom:0pt;padding:0;'>
            Reproducibility limit,
            <span class='stem'>(#(R)#)</span>
             (= 2,83
            <span class='stem'>(#(s_R)#)</span>
            )
          </td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:0pt;padding:0;'>2,89</td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:0pt;padding:0;'>0,57</td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:0pt;padding:0;'>2,26</td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:0pt;padding:0;'>6,06</td>
        </tr>
        <tr>
          <td colspan='5' style='border-top:0pt;border-bottom:solid windowtext 1.5pt;'>
            <div id='' class='Note'>
              <p>
                <span class='note_label'>NOTE</span>
                &#xA0; This is a table about rice
              </p>
            </div>
            <div class='TableFootnote'>
              <div id='fn:tableD-1a'>
                <p id='_0fe65e9a-5531-408e-8295-eeff35f41a55' class='TableFootnote'>
                  <span>
                    <span id='tableD-1a' class='TableFootnoteRef'>a)</span>
                    &#xA0;
                  </span>
                  Parboiled rice.
                </p>
              </div>
            </div>
          </td>
        </tr>
      </tfoot>
      <dl>
        <dt>
          <p>Drago</p>
        </dt>
        <dd>A type of rice</dd>
      </dl>
    </table>
  </div>
  <p class='zzSTDTitle1'/>
</main>
OUTPUT
  end

    it "processes IsoXML tables (Word)" do
    FileUtils.rm_f("test.doc")
    IsoDoc::Iso::WordConvert.new({}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
      <table id="tableD-1" alt="tool tip" summary="long desc">
  <name>Repeatability and reproducibility of <em>husked</em> rice yield</name>
  <thead>
    <tr>
      <td rowspan="2" align="left">Description</td>
      <td colspan="4" align="center">Rice sample</td>
    </tr>
    <tr>
      <td align="left">Arborio</td>
      <td align="center">Drago<fn reference="a">
  <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
</fn></td>
      <td align="center">Balilla<fn reference="a">
  <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
</fn></td>
      <td align="center">Thaibonnet</td>
    </tr>
    </thead>
    <tbody>
    <tr>
      <th align="left">Number of laboratories retained after eliminating outliers</th>
      <td align="center">13</td>
      <td align="center">11</td>
      <td align="center">13</td>
      <td align="center">13</td>
    </tr>
    <tr>
      <td align="left">Mean value, g/100 g</td>
      <td align="center">81,2</td>
      <td align="center">82,0</td>
      <td align="center">81,8</td>
      <td align="center">77,7</td>
    </tr>
    </tbody>
    <tfoot>
    <tr>
      <td align="left">Reproducibility limit, <stem type="AsciiMath">R</stem> (= 2,83 <stem type="AsciiMath">s_R</stem>)</td>
      <td align="center">2,89</td>
      <td align="center">0,57</td>
      <td align="center">2,26</td>
      <td align="center">6,06</td>
    </tr>
  </tfoot>
  <dl>
  <dt>Drago</dt>
<dd>A type of rice</dd>
</dl>
<note><p>This is a table about rice</p></note>
</table>

</foreword>
</preface>
</iso-standard>
    INPUT

       expect(File.exist?("test.doc")).to be true
       html = File.read("test.doc").sub(/^.+?<table /m, '<table xmlns:m="m" ').sub(%r{</div>\s*<p class="MsoNormal">.*$}m, "")
       expect(xmlpp("<div>#{html}")).to be_equivalent_to xmlpp(<<~"OUTPUT")
       <div><table xmlns:m="m" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;" title="tool tip" summary="long desc"><a name="tableD-1" id="tableD-1"></a>
                   <thead>
                     <tr>
                       <td rowspan="2" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="middle">Description</td>
                       <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="middle">Rice sample</td>
                     </tr>
                     <tr>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="middle">Arborio</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="middle">Drago<a href="#tableD-1a" class="TableFootnoteRef">a)</a></td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="middle">Balilla<a href="#tableD-1a" class="TableFootnoteRef">a)</a></td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="middle">Thaibonnet</td>
                     </tr>
                   </thead>
                   <tbody>
                     <tr>
                       <th align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">Number of laboratories retained after eliminating outliers</th>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">13</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">11</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">13</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;">13</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">Mean value, g/100 g</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">81,2</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">82,0</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">81,8</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">77,7</td>
                     </tr>
                   </tbody>
                   <tfoot>
                     <tr>
                       <td align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;">Reproducibility limit, <span class="stem"><m:oMath>
         <m:r><m:t>R</m:t></m:r>
       </m:oMath>
       </span> (= 2,83 <span class="stem"><m:oMath>
         <m:sSub><m:e><m:r><m:t>s</m:t></m:r></m:e><m:sub><m:r><m:t>R</m:t></m:r></m:sub></m:sSub>
       </m:oMath>
       </span>)</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;">2,89</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;">0,57</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;">2,26</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:0pt;mso-border-bottom-alt:0pt;">6,06</td>
                     </tr>
                   <tr><td colspan="5" style="border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;"><div id="" class="Note">
                     <p class="Note"><span class="note_label">NOTE</span><span style="mso-tab-count:1">&#xA0; </span>This is a table about rice</p>
                   </div><div class="TableFootnote"><div><a name="ftntableD-1a" id="ftntableD-1a"></a>
         <p class="TableFootnote"><a name="_0fe65e9a-5531-408e-8295-eeff35f41a55" id="_0fe65e9a-5531-408e-8295-eeff35f41a55"></a><span><span class="TableFootnoteRef"><a name="tableD-1a" id="tableD-1a"></a>a)</span><span style="mso-tab-count:1">&#xA0; </span></span>Parboiled rice.</p>
       </div></div></td></tr></tfoot>


                 </table><table class="dl">
                     <tr>
                       <td valign="top" align="left">
                         <p align="left" style="margin-left:0pt;text-align:left;" class="MsoNormal">Drago</p>
                       </td>
                       <td valign="top">A type of rice</td>
                     </tr>
                   </table>
               </div>
OUTPUT
end
end
