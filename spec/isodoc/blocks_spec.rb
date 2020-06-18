require "spec_helper"

RSpec.describe IsoDoc do
 it "processes formulae" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true">
  <stem type="AsciiMath">r = 1 %</stem>
<dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
  <dt> <stem type="AsciiMath">r</stem> </dt>
  <dd> <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p> </dd>
  <dt> <stem type="AsciiMath">s_1</stem> </dt>
  <dd> <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the other repeatability limit.</p> </dd>
</dl>
    <note id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0">
  <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
</note>
    </formula>
    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
         <br/>
      <div>
        <h1 class='ForewordTitle'>Foreword</h1>
        <div id='_be9158af-7e93-4ee2-90c5-26d31c181934' class='formula'>
          <p>
            <span class='stem'>(#(r = 1 %)#)</span>
          </p>
        </div>
        <p style='page-break-after:avoid;'>where</p>
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
        <div id='_be9158af-7e93-4ee2-90c5-26d31c181935' class='formula'>
          <p>
            <span class='stem'>(#(r = 1 %)#)</span>
            &#160; (1)
          </p>
        </div>
      </div>
      <p class='zzSTDTitle1'/>
    </div>
  </body>
</html>
    OUTPUT
  end

  it "processes formulae (Word)" do
    expect(xmlpp(IsoDoc::Iso::WordConvert.new({}).convert("test", <<~"INPUT", true).sub(%r{^.*<div>\s*<h1 class="ForewordTitle">}m, '<div><h1 class="ForewordTitle">').sub(%r{<p>\&#160;</p>\s*</div>.*$}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true">
  <stem type="AsciiMath">r = 1 %</stem>
<dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
  <dt>
    <stem type="AsciiMath">r</stem>
  </dt>
  <dd>
    <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
  </dd>
  <dt> <stem type="AsciiMath">s_1</stem> </dt>
  <dd> <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the other repeatability limit.</p> </dd>
</dl>
    <note id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0">
  <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
</note>
    </formula>
    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
    </foreword></preface>
    </iso-standard>
    INPUT
    <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <div id='_be9158af-7e93-4ee2-90c5-26d31c181934' class='formula'>
                 <p>
                   <span class='stem'>(#(r = 1 %)#)</span>
                 </p>
               </div>
               <p>where</p>
               <table class='formula_dl'>
                 <tr>
                   <td valign='top' align='left'>
                     <p align='left' style='margin-left:0pt;text-align:left;'>
                       <span class='stem'>(#(r)#)</span>
                     </p>
                   </td>
                   <td valign='top'>
                     <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the repeatability limit.</p>
                   </td>
                 </tr>
                 <tr>
  <td valign='top' align='left'>
    <p align='left' style='margin-left:0pt;text-align:left;'>
      <span class='stem'>(#(s_1)#)</span>
    </p>
  </td>
  <td valign='top'>
    <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the other repeatability limit.</p>
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
               <div id='_be9158af-7e93-4ee2-90c5-26d31c181935' class='formula'>
                 <p>
                   <span class='stem'>(#(r = 1 %)#)</span>
                   <span style='mso-tab-count:1'>&#160; </span>
                   (1)
                 </p>
               </div>
             </div>
    OUTPUT
  end

   it "processes formulae with single definition list entry" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
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
  <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
</note>
    </formula>
    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="_be9158af-7e93-4ee2-90c5-26d31c181934" class="formula"><p><span class="stem">(#(r = 1 %)#)</span></p></div>
<span class='zzMoveToFollowing'>
                 where 
                 <span class='stem'>(#(r)#)</span>
               </span>
               <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the repeatability limit.</p>

           <div id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0" class="Note"><p><span class="note_label">NOTE</span>&#160; [durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p></div>

                 <div id="_be9158af-7e93-4ee2-90c5-26d31c181935" class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (1)</p></div>
                 </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end


end
