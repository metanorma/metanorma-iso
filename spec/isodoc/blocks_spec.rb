require "spec_helper"

RSpec.describe IsoDoc do
  it "renders figures (HTML)" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
 <iso-standard xmlns='http://riboseinc.com/isoxml'>
   <preface>
     <foreword id='fwd'>
       <p>
       </p>
     </foreword>
   </preface>
   <sections>
     <clause id='scope'>
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
    #{HTML_HDR}
    <br/>
               <div id="fwd">
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1&#160; Scope</h1>
                 <div id="N" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure 1&#160;&#8212; Split-it-right sample divider</p></div>
                 <p>
                 </p>
               </div>
               <div id="terms"><h1>2&#160; </h1>
       </div>
               <div id="widgets">
                 <h1>3&#160; Widgets</h1>
                 <div id="widgets1"><span class='zzMoveToFollowing'><b>3.1&#160; </b></span>
               <div id="note1" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure 2&#160;&#8212; Split-it-right sample divider</p></div>
           <div id="note2" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure 3&#160;&#8212; Split-it-right sample divider</p></div>
         <p>   </p> 
           </div>
               </div>
               <br/>
               <div id="annex1" class="Section3">
               <h1 class='Annex'>
  <b>Annex A</b>
  <br/>
(informative)
  <br/>
  <br/>
  <b/>
</h1>
                 <div id="annex1a"><span class='zzMoveToFollowing'><b>A.1&#160; </b></span>
               <div id="AN" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure A.1&#160;&#8212; Split-it-right sample divider</p></div>
           </div>
                 <div id="annex1b"><span class='zzMoveToFollowing'><b>A.2&#160; </b></span>
               <div id="Anote1" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure A.2&#160;&#8212; Split-it-right sample divider</p></div>
           <div id="Anote2" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure A.3&#160;&#8212; Split-it-right sample divider</p></div>
           </div>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

   it "renders subfigures (HTML)" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
      <clause id='scope'>
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
               <h1>1&#160; Scope</h1>
             </div>
             <div id='terms'>
               <h1>2&#160; </h1>
             </div>
             <div id='widgets'>
               <h1>3&#160; Widgets</h1>
               <div id='widgets1'>
                 <span class='zzMoveToFollowing'>
                   <b>3.1&#160; </b>
                 </span>
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
               <h1 class='Annex'>
<b>Annex A</b>
                 <br/>
                 (informative)
                 <br/>
                 <br/>
                 <b/>
               </h1>
               <div id='annex1a'>
                 <span class='zzMoveToFollowing'>
                   <b>A.1&#160; </b>
                 </span>
               </div>
               <div id='annex1b'>
                 <span class='zzMoveToFollowing'>
                   <b>A.2&#160; </b>
                 </span>
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

   it "processes formulae (Presentation XML)" do
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <preface>
    <foreword>
      <formula id='_be9158af-7e93-4ee2-90c5-26d31c181934' unnumbered='true'>
        <stem type='AsciiMath'>r = 1 %</stem>
        <dl id='_e4fe94fe-1cde-49d9-b1ad-743293b7e21d'>
          <dt>
            <stem type='AsciiMath'>r</stem>
          </dt>
          <dd>
            <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the repeatability limit.</p>
          </dd>
          <dt>
            <stem type='AsciiMath'>s_1</stem>
          </dt>
          <dd>
            <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the other repeatability limit.</p>
          </dd>
        </dl>
        <note id='_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0'>
        <name>NOTE</name>
          <p id='_511aaa98-4116-42af-8e5b-c87cdf5bfdc8'>
            [durationUnits] is essentially a duration statement without the "P"
            prefix. "P" is unnecessary because between "G" and "U" duration is
            always expressed.
          </p>
        </note>
      </formula>
      <formula id='_be9158af-7e93-4ee2-90c5-26d31c181935'>
        <name>1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
    </foreword>
  </preface>
</iso-standard>
OUTPUT
   end

 it "processes formulae (HTML)" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns='http://riboseinc.com/isoxml'>
  <preface>
    <foreword>
      <formula id='_be9158af-7e93-4ee2-90c5-26d31c181934' unnumbered='true'>
        <stem type='AsciiMath'>r = 1 %</stem>
        <dl id='_e4fe94fe-1cde-49d9-b1ad-743293b7e21d'>
          <dt>
            <stem type='AsciiMath'>r</stem>
          </dt>
          <dd>
            <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the repeatability limit.</p>
          </dd>
          <dt>
            <stem type='AsciiMath'>s_1</stem>
          </dt>
          <dd>
            <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the other repeatability limit.</p>
          </dd>
        </dl>
        <note id='_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0'>
          <p id='_511aaa98-4116-42af-8e5b-c87cdf5bfdc8'>
            [durationUnits] is essentially a duration statement without the "P"
            prefix. "P" is unnecessary because between "G" and "U" duration is
            always expressed.
          </p>
        </note>
      </formula>
      <formula id='_be9158af-7e93-4ee2-90c5-26d31c181935'>
        <name>1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
    </foreword>
  </preface>
</iso-standard>
    INPUT
        #{HTML_HDR}
         <br/>
      <div>
        <h1 class='ForewordTitle'>Foreword</h1>
        <div id='_be9158af-7e93-4ee2-90c5-26d31c181934'><div class='formula'>
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
            &#160; [durationUnits] is essentially a duration statement without
            the "P" prefix. "P" is unnecessary because between "G" and "U"
            duration is always expressed.
          </p>
          </div>
        </div>
        <div id='_be9158af-7e93-4ee2-90c5-26d31c181935'><div class='formula'>
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
  end

  it "processes formulae (Word)" do
    expect(xmlpp(IsoDoc::Iso::WordConvert.new({}).convert("test", <<~"INPUT", true).sub(%r{^.*<div>\s*<h1 class="ForewordTitle">}m, '<div><h1 class="ForewordTitle">').sub(%r{<p>\&#160;</p>\s*</div>.*$}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns='http://riboseinc.com/isoxml'>
  <preface>
    <foreword>
      <formula id='_be9158af-7e93-4ee2-90c5-26d31c181934' unnumbered='true'>
        <stem type='AsciiMath'>r = 1 %</stem>
        <dl id='_e4fe94fe-1cde-49d9-b1ad-743293b7e21d'>
          <dt>
            <stem type='AsciiMath'>r</stem>
          </dt>
          <dd>
            <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the repeatability limit.</p>
          </dd>
          <dt>
            <stem type='AsciiMath'>s_1</stem>
          </dt>
          <dd>
            <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the other repeatability limit.</p>
          </dd>
        </dl>
        <note id='_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0'>
          <p id='_511aaa98-4116-42af-8e5b-c87cdf5bfdc8'>
            [durationUnits] is essentially a duration statement without the "P"
            prefix. "P" is unnecessary because between "G" and "U" duration is
            always expressed.
          </p>
        </note>
      </formula>
      <formula id='_be9158af-7e93-4ee2-90c5-26d31c181935'>
        <name>1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
    </foreword>
  </preface>
</iso-standard>
    INPUT
    <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <div id='_be9158af-7e93-4ee2-90c5-26d31c181934'><div class='formula'>
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
                   <span class='note_label'/>
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
    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935"><name>1</name>
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="_be9158af-7e93-4ee2-90c5-26d31c181934"><div class="formula"><p><span class="stem">(#(r = 1 %)#)</span></p></div>
<span class='zzMoveToFollowing'>
                 where 
                 <span class='stem'>(#(r)#)</span>
               </span>
               <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the repeatability limit.</p>

           <div id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0" class="Note"><p>&#160; [durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p></div>
           </div>

                 <div id="_be9158af-7e93-4ee2-90c5-26d31c181935"><div class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (1)</p></div></div>
                 </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end


end
