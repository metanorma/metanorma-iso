require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references notes" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
    <note id="N">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
<p><xref target="N"/></p>

    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <note id="note1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    <note id="note2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
</note>
<p>    <xref target="note1"/> <xref target="note2"/> </p>

    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    <note id="AN">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </clause>
    <clause id="annex1b">
    <note id="Anote1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    <note id="Anote2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </clause>
    </annex>
    </iso-standard>
    INPUT
    #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <a href="#N">Clause 1, Note</a>
           <a href="#note1">3.1, Note  1</a>
           <a href="#note2">3.1, Note  2</a>
           <a href="#AN">A.1, Note</a>
           <a href="#Anote1">A.2, Note  1</a>
           <a href="#Anote2">A.2, Note  2</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1&#160; Scope</h1>
                 <div id="N" class="Note">
                   <p><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
                 </div>
                 <p>
                   <a href="#N">Note</a>
                 </p>
               </div>
               <div id="terms"><h1>2&#160; </h1>
       </div>
               <div id="widgets">
                 <h1>3&#160; Widgets</h1>
                 <div id="widgets1"><span class='zzMoveToFollowing'><b>3.1&#160; </b></span>
           <div id="note1" class="Note"><p><span class="note_label">NOTE  1</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           <div id="note2" class="Note"><p><span class="note_label">NOTE  2</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
       <p>    <a href="#note1">Note  1</a> <a href="#note2">Note  2</a> </p>

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
           <div id="AN" class="Note"><p><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           </div>
                 <div id="annex1b"><span class='zzMoveToFollowing'><b>A.2&#160; </b></span>
           <div id="Anote1" class="Note"><p><span class="note_label">NOTE  1</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           <div id="Anote2" class="Note"><p><span class="note_label">NOTE  2</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           </div>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

   it "cross-references figures (Presentation XML)" do
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
    <foreword id="fwd">
    <p>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
        <figure id="N">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
<p><xref target="N"/></p>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
        <figure id="note1">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
    <figure id="note2">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
  <p>    <xref target="note1"/> <xref target="note2"/> </p>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
        <figure id="AN">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
    </clause>
    <clause id="annex1b">
        <figure id="Anote1">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
    <figure id="Anote2">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
    </clause>
    </annex>
    </iso-standard>
    INPUT
     <?xml version='1.0'?>
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
       <figure id='N'>
         <name>Figure 1&#xA0;&#x2014; Split-it-right sample divider</name>
         <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
       </figure>
       <p>
         <xref target='N'/>
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
           <xref target='note1'/>
           <xref target='note2'/>
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
    OUTPUT
    end

  it "cross-references figures (HTML)" do
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
       <figure id='N'>
         <name>Figure 1&#xA0;&#x2014; Split-it-right sample divider</name>
         <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
       </figure>
       <p>
         <xref target='N'/>
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
           <xref target='note1'/>
           <xref target='note2'/>
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
           <a href="#N">Figure 1</a>
           <a href="#note1">Figure 2</a>
           <a href="#note2">Figure 3</a>
           <a href="#AN">Figure A.1</a>
           <a href="#Anote1">Figure A.2</a>
           <a href="#Anote2">Figure A.3</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1&#160; Scope</h1>
                 <div id="N" class="figure">

         <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
         <p class="FigureTitle" style="text-align:center;">Figure 1&#160;&#8212; Split-it-right sample divider</p></div>
                 <p>
                   <a href="#N">Figure 1</a>
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
         <p>    <a href="#note1">Figure 2</a> <a href="#note2">Figure 3</a> </p>
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

  it "cross-references subfigures (Presentation XML)" do
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
    <foreword id="fwd">
    <p>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <figure id="N">
        <figure id="note1">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
    <figure id="note2">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
  </figure>
  <p>    <xref target="note1"/> <xref target="note2"/> </p>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    </clause>
    <clause id="annex1b">
    <figure id="AN">
        <figure id="Anote1">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
    <figure id="Anote2">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
  </figure>
    </clause>
    </annex>
    </iso-standard>
    INPUT
      <?xml version='1.0'?>
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
    OUTPUT
  end

  it "cross-references subfigures" do
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
        #{HTML_HDR}
    <br/>
               <div id="fwd">
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
         <a href="#N">Figure 1</a>
         <a href="#note1">Figure 1 a)</a>
         <a href="#note2">Figure 1 b)</a>
         <a href="#AN">Figure A.1</a>
         <a href="#Anote1">Figure A.1 a)</a>
         <a href="#Anote2">Figure A.1 b)</a>
         </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1&#160; Scope</h1>
               </div>
               <div id="terms"><h1>2&#160; </h1>
       </div>
               <div id="widgets">
                 <h1>3&#160; Widgets</h1>
                 <div id="widgets1"><span class='zzMoveToFollowing'><b>3.1&#160; </b></span>
         <div id="N" class="figure">
             <div id="note1" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class='FigureTitle' style='text-align:center;'>a)&#160;&#8212; Split-it-right sample divider</p>
       </div>
         <div id="note2" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class='FigureTitle' style='text-align:center;'>b)&#160;&#8212; Split-it-right sample divider</p>
       </div>
       <p class='FigureTitle' style='text-align:center;'>Figure 1</p>
         </div>
       <p>    <a href="#note1">Figure 1 a)</a> <a href="#note2">Figure 1 b)</a> </p>
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
         </div>
                 <div id="annex1b"><span class='zzMoveToFollowing'><b>A.2&#160; </b></span>
         <div id="AN" class="figure">
             <div id="Anote1" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class='FigureTitle' style='text-align:center;'>a)&#160;&#8212; Split-it-right sample divider</p>
       </div>
         <div id="Anote2" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
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

  it "cross-references examples" do
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
    <foreword>
    <p>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
        <example id="N">
  <p>Hello</p>
</example>
<p><xref target="N"/></p>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
        <example id="note1">
  <p>Hello</p>
</example>
        <example id="note2">
  <p>Hello</p>
</example>
<p>    <xref target="note1"/> <xref target="note2"/> </p>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
        <example id="AN">
  <p>Hello</p>
</example>
    </clause>
    <clause id="annex1b">
        <example id="Anote1">
  <p>Hello</p>
</example>
        <example id="Anote2">
  <p>Hello</p>
</example>
    </clause>
    </annex>
    </iso-standard>
    INPUT
    <!--
    <a href="#N">Clause 1, Example</a>
    <a href="#note1">3.1, Example  1</a>
    <a href="#note2">3.1, Example  2</a>
    <a href="#AN">A.1, Example</a>
    <a href="#Anote1">A.2, Example  1</a>
    <a href="#Anote2">A.2, Example  2</a>
    -->
<?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <preface>
    <foreword>
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
      <example id='N'>
        <name>EXAMPLE</name>
        <p>Hello</p>
      </example>
      <p>
        <xref target='N'/>
      </p>
    </clause>
    <terms id='terms'/>
    <clause id='widgets'>
      <title>Widgets</title>
      <clause id='widgets1'>
        <example id='note1'>
          <name>EXAMPLE 1</name>
          <p>Hello</p>
        </example>
        <example id='note2'>
          <name>EXAMPLE 2</name>
          <p>Hello</p>
        </example>
        <p>
          <xref target='note1'/>
          <xref target='note2'/>
        </p>
      </clause>
    </clause>
  </sections>
  <annex id='annex1'>
    <clause id='annex1a'>
      <example id='AN'>
        <name>EXAMPLE</name>
        <p>Hello</p>
      </example>
    </clause>
    <clause id='annex1b'>
      <example id='Anote1'>
        <name>EXAMPLE 1</name>
        <p>Hello</p>
      </example>
      <example id='Anote2'>
        <name>EXAMPLE 2</name>
        <p>Hello</p>
      </example>
    </clause>
  </annex>
</iso-standard>
    OUTPUT
  end

  it "cross-references formulae" do
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
    <foreword>
    <p>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
    <formula id="N">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
  <p><xref target="N"/></p>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <formula id="note1">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
    <formula id="note2">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
  <p>    <xref target="note1"/> <xref target="note2"/> </p>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    <formula id="AN">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
    </clause>
    <clause id="annex1b">
    <formula id="Anote1">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
    <formula id="Anote2">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
    </clause>
    </annex>
    </iso-standard>

    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934">
  <stem type="AsciiMath">r = 1 %</stem>
<dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
  <dt>
    <stem type="AsciiMath">r</stem>
  </dt>
  <dd>
    <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
  </dd>
</dl></formula>
    </foreword>
    </preface>
    </iso-standard>
    INPUT
    <!--
           <a href="#N">Clause 1, Formula (1)</a>
           <a href="#note1">3.1, Formula (2)</a>
           <a href="#note2">3.1, Formula (3)</a>
           <a href="#AN">A.1, Formula (A.1)</a>
           <a href="#Anote1">A.2, Formula (A.2)</a>
           <a href="#Anote2">A.2, Formula (A.3)</a>
           -->
           <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <preface>
    <foreword>
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
      <formula id='N'>
        <name>1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
      <p>
        <xref target='N'/>
      </p>
    </clause>
    <terms id='terms'/>
    <clause id='widgets'>
      <title>Widgets</title>
      <clause id='widgets1'>
        <formula id='note1'>
          <name>2</name>
          <stem type='AsciiMath'>r = 1 %</stem>
        </formula>
        <formula id='note2'>
          <name>3</name>
          <stem type='AsciiMath'>r = 1 %</stem>
        </formula>
        <p>
          <xref target='note1'/>
          <xref target='note2'/>
        </p>
      </clause>
    </clause>
  </sections>
  <annex id='annex1'>
    <clause id='annex1a'>
      <formula id='AN'>
        <name>A.1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
    </clause>
    <clause id='annex1b'>
      <formula id='Anote1'>
        <name>A.2</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
      <formula id='Anote2'>
        <name>A.3</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
    </clause>
  </annex>
</iso-standard>
    OUTPUT
  end

  it "cross-references tables" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
    <foreword>
    <p>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
        <table id="N">
    <name>Repeatability and reproducibility of husked rice yield</name>
    <tbody>
    <tr>
      <td align="left">Number of laboratories retained after eliminating outliers</td>
      <td align="center">13</td>
      <td align="center">11</td>
    </tr>
    </tbody>
    </table>
    <p><xref target="N"/></p>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
        <table id="note1">
    <name>Repeatability and reproducibility of husked rice yield</name>
    <tbody>
    <tr>
      <td align="left">Number of laboratories retained after eliminating outliers</td>
      <td align="center">13</td>
      <td align="center">11</td>
    </tr>
    </tbody>
    </table>
        <table id="note2">
    <name>Repeatability and reproducibility of husked rice yield</name>
    <tbody>
    <tr>
      <td align="left">Number of laboratories retained after eliminating outliers</td>
      <td align="center">13</td>
      <td align="center">11</td>
    </tr>
    </tbody>
    </table>
    <p>    <xref target="note1"/> <xref target="note2"/> </p>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
        <table id="AN">
    <name>Repeatability and reproducibility of husked rice yield</name>
    <tbody>
    <tr>
      <td align="left">Number of laboratories retained after eliminating outliers</td>
      <td align="center">13</td>
      <td align="center">11</td>
    </tr>
    </tbody>
    </table>
    </clause>
    <clause id="annex1b">
        <table id="Anote1">
    <name>Repeatability and reproducibility of husked rice yield</name>
    <tbody>
    <tr>
      <td align="left">Number of laboratories retained after eliminating outliers</td>
      <td align="center">13</td>
      <td align="center">11</td>
    </tr>
    </tbody>
    </table>
        <table id="Anote2">
    <name>Repeatability and reproducibility of husked rice yield</name>
    <tbody>
    <tr>
      <td align="left">Number of laboratories retained after eliminating outliers</td>
      <td align="center">13</td>
      <td align="center">11</td>
    </tr>
    </tbody>
    </table>
    </clause>
    </annex>
    </iso-standard>
    INPUT
        #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
       <a href="#N">Table 1</a>
       <a href="#note1">Table 2</a>
       <a href="#note2">Table 3</a>
       <a href="#AN">Table A.1</a>
       <a href="#Anote1">Table A.2</a>
       <a href="#Anote2">Table A.3</a>
       </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1&#160; Scope</h1>
                 <p class="TableTitle" style="text-align:center;">
                   Table 1&#160;&#8212; Repeatability and reproducibility of husked rice yield
                 </p>
                 <table id="N" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                   <tbody>
                     <tr>
                       <td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td>
                       <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td>
                       <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td>
                     </tr>
                   </tbody>
                 </table>
                 <p>
                   <a href="#N">Table 1</a>
                 </p>
               </div>
               <div id="terms"><h1>2&#160; </h1>
       </div>
               <div id="widgets">
                 <h1>3&#160; Widgets</h1>
                 <div id="widgets1"><span class='zzMoveToFollowing'><b>3.1&#160; </b></span>
           <p class="TableTitle" style="text-align:center;">Table 2&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="note1" class="MsoISOTable" style="border-width:1px;border-spacing:0;"><tbody><tr><td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
           <p class="TableTitle" style="text-align:center;">Table 3&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="note2" class="MsoISOTable" style="border-width:1px;border-spacing:0;"><tbody><tr><td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
       <p>    <a href="#note1">Table 2</a> <a href="#note2">Table 3</a> </p>
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
           <p class="TableTitle" style="text-align:center;">Table A.1&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="AN" class="MsoISOTable" style="border-width:1px;border-spacing:0;"><tbody><tr><td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
       </div>
                 <div id="annex1b"><span class='zzMoveToFollowing'><b>A.2&#160; </b></span>
           <p class="TableTitle" style="text-align:center;">Table A.2&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="Anote1" class="MsoISOTable" style="border-width:1px;border-spacing:0;"><tbody><tr><td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
           <p class="TableTitle" style="text-align:center;">Table A.3&#160;&#8212; Repeatability and reproducibility of husked rice yield</p><table id="Anote2" class="MsoISOTable" style="border-width:1px;border-spacing:0;"><tbody><tr><td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Number of laboratories retained after eliminating outliers</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">13</td><td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">11</td></tr></tbody></table>
       </div>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "cross-references term notes" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
    <foreword>
    <p>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="note3"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
    </clause>
    <terms id="terms">
<term id="_waxy_rice"><preferred>waxy rice</preferred>
<termnote id="note1">
  <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote></term>
<term id="_nonwaxy_rice"><preferred>nonwaxy rice</preferred>
<termnote id="note2">
  <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote>
<termnote id="note3">
  <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote></term>
</terms>

    </iso-standard>
    INPUT
            #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <a href="#note1">2.1, Note 1</a>
           <a href="#note2">2.2, Note 1</a>
           <a href="#note3">2.2, Note 2</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1&#160; Scope</h1>
               </div>
               <div id="terms"><h1>2&#160; </h1>
       <p class="TermNum" id="_waxy_rice">2.1</p><p class="Terms" style="text-align:left;">waxy rice</p>
       <div id="note1" class="Note"><p>Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div><p class="TermNum" id="_nonwaxy_rice">2.2</p><p class="Terms" style="text-align:left;">nonwaxy rice</p>
       <div id="note2" class="Note"><p>Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
       <div id="note3" class="Note"><p>Note 2 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div></div>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "cross-references sections" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble
         <xref target="C"/>
         <xref target="C1"/>
         <xref target="D"/>
         <xref target="H"/>
         <xref target="I"/>
         <xref target="J"/>
         <xref target="K"/>
         <xref target="L"/>
         <xref target="M"/>
         <xref target="N"/>
         <xref target="O"/>
         <xref target="P"/>
         <xref target="Q"/>
         <xref target="Q1"/>
         <xref target="Q2"/>
         <xref target="R"/>
         </p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       <clause id="C1" inline-header="false" obligation="informative">Text</clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <terms id="H" obligation="normative"><title>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </terms>
       <definitions id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
              <appendix id="Q2" inline-header="false" obligation="normative">
         <title>An Appendix</title>
       </appendix>
       </annex><bibliography><references id="R" obligation="informative" normative="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT
        #{HTML_HDR}
    <br/>
    <div>
    <h1 class="ForewordTitle">Foreword</h1>
    <p id="A">This is a preamble
    <a href="#C">0.1</a>
         <a href="#C1">0.2</a>
    <a href="#D">Clause 1</a>
    <a href="#H">Clause 3</a>
    <a href="#I">3.1</a>
    <a href="#J">3.1.1</a>
    <a href="#K">3.2</a>
    <a href="#L">Clause 4</a>
    <a href="#M">Clause 5</a>
    <a href="#N">5.1</a>
    <a href="#O">5.2</a>
    <a href="#P">Annex A</a>
    <a href="#Q">A.1</a>
    <a href="#Q1">A.1.1</a>
    <a href="#Q2">Annex A, Appendix 1</a>
    <a href="#R">Clause 2</a>
    </p>
    </div>
    <br/>
                 <div class="Section3" id="B">
                 <h1 class="IntroTitle">0&#160; Introduction</h1>
               <div id="C">
                 <h2>0.1&#160; Introduction Subsection</h2>
        </div>
        <div id="C1"><span class='zzMoveToFollowing'>
  <b>0.2&#160; </b>
</span>
Text</div>
             </div>
    <p class="zzSTDTitle1"/>
    <div id="D">
    <h1>1&#160; Scope</h1>
      <p id="E">Text</p>
    </div>
    <div>
    <h1>2&#160; Normative references</h1>
    </div>
    <div id="H"><h1>3&#160; Terms, definitions, symbols and abbreviated terms</h1>
       <div id="I">
          <h2>3.1&#160; Normal Terms</h2>
          <p class="TermNum" id="J">3.1.1</p>
          <p class="Terms" style="text-align:left;">Term2</p>

        </div><div id="K"><h2>3.2&#160; Symbols and abbreviated terms</h2>
          <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
        </div></div>
               <div id="L" class="Symbols">
                 <h1>4&#160; Symbols and abbreviated terms</h1>
                 <dl>
                   <dt>
                     <p>Symbol</p>
                   </dt>
                   <dd>Definition</dd>
                 </dl>
               </div>
               <div id="M">
                 <h1>5&#160; Clause 4</h1>
                 <div id="N">
          <h2>5.1&#160; Introduction</h2>
        </div>
                 <div id="O">
          <h2>5.2&#160; Clause 4.2</h2>
        </div>
               </div>
               <br/>
               <div id="P" class="Section3">
                 <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                 <div id="Q">
          <h2>A.1&#160; Annex A.1</h2>
          <div id="Q1">
          <h3>A.1.1&#160; Annex A.1a</h3>
          </div>
        </div>
       <div id="Q2">
        <h2>Appendix 1&#160; An Appendix</h2>
        </div>
               </div>
               <br/>
               <div>
                 <h1 class="Section3">Bibliography</h1>
                 <div>
                   <h2 class="Section3">Bibliography Subsection</h2>
                 </div>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "cross-references lists" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
    <ol id="N">
  <li><p>A</p></li>
</ol>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <ol id="note1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</ol>
    <ol id="note2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
</ol>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    <ol id="AN">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</ol>
    </clause>
    <clause id="annex1b">
    <ol id="Anote1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</ol>
    <ol id="Anote2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
</ol>
    </clause>
    </annex>
    </iso-standard>
    INPUT
        #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <a href="#N">Clause 1, List</a>
           <a href="#note1">3.1, List  1</a>
           <a href="#note2">3.1, List  2</a>
           <a href="#AN">A.1, List</a>
           <a href="#Anote1">A.2, List  1</a>
           <a href="#Anote2">A.2, List  2</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
               <h1>1&#160; Scope</h1>
               <ol type="a" id="N">
         <li><p>A</p></li>
       </ol>
             </div>
             <div id="terms"><h1>2&#160; </h1>
       </div>
             <div id="widgets">
               <h1>3&#160; Widgets</h1>
               <div id="widgets1"><span class='zzMoveToFollowing'><b>3.1&#160; </b></span>
           <ol type="a" id="note1">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           <ol type="a" id="note2">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
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
           <ol type="a" id="AN">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           </div>
               <div id="annex1b"><span class='zzMoveToFollowing'><b>A.2&#160; </b></span>
           <ol type="a" id="Anote1">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           <ol type="a" id="Anote2">
         <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
       </ol>
           </div>
             </div>
           </div>
         </body>
       </html>

    OUTPUT
  end

  it "cross-references list items" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
    <ol id="N1">
  <li id="N"><p>A</p></li>
</ol>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <ol id="note1l">
  <li id="note1"><p>A</p></li>
</ol>
    <ol id="note2l">
  <li id="note2"><p>A</p></li>
</ol>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    <ol id="ANl">
  <li id="AN"><p>A</p></li>
</ol>
    </clause>
    <clause id="annex1b">
    <ol id="Anote1l">
  <li id="Anote1"><p>A</p></li>
</ol>
    <ol id="Anote2l">
  <li id="Anote2"><p>A</p></li>
</ol>
    </clause>
    </annex>
    </iso-standard>
    INPUT
        #{HTML_HDR}
    <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <a href="#N">Clause 1 a)</a>
           <a href="#note1">3.1 List  1 a)</a>
           <a href="#note2">3.1 List  2 a)</a>
           <a href="#AN">A.1 a)</a>
           <a href="#Anote1">A.2 List  1 a)</a>
           <a href="#Anote2">A.2 List  2 a)</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div id="scope">
                 <h1>1&#160; Scope</h1>
               <ol type="a" id="N1">
         <li id="N"><p>A</p></li>
       </ol>
             </div>
             <div id="terms"><h1>2&#160; </h1>
       </div>
             <div id="widgets">
               <h1>3&#160; Widgets</h1>
               <div id="widgets1"><span class='zzMoveToFollowing'><b>3.1&#160; </b></span>
           <ol type="a" id="note1l">
         <li id="note1"><p>A</p></li>
       </ol>
           <ol type="a" id="note2l">
         <li id="note2"><p>A</p></li>
       </ol>
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
           <ol type="a" id="ANl">
         <li id="AN"><p>A</p></li>
       </ol>
           </div>
               <div id="annex1b"><span class='zzMoveToFollowing'><b>A.2&#160; </b></span>
           <ol type="a" id="Anote1l">
         <li id="Anote1"><p>A</p></li>
       </ol>
           <ol type="a" id="Anote2l">
         <li id="Anote2"><p>A</p></li>
       </ol>
           </div>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
  end

  it "cross-references nested list items" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
    <ol id="N1">
      <li id="N"><p>A</p>
      <ol>
      <li id="note1"><p>A</p>
      <ol>
      <li id="note2"><p>A</p>
      <ol>
      <li id="AN"><p>A</p>
      <ol>
      <li id="Anote1"><p>A</p>
      <ol>
      <li id="Anote2"><p>A</p></li>
      </ol></li>
      </ol></li>
      </ol></li>
      </ol></li>
      </ol></li>
    </ol>
    </clause>
    </sections>
    </iso-standard>
    INPUT
        #{HTML_HDR}
    <br/>
                <div>
                  <h1 class="ForewordTitle">Foreword</h1>
                  <p>
        <a href="#N">Clause 1 a)</a>
        <a href="#note1">Clause 1 a.1)</a>
        <a href="#note2">Clause 1 a.1.i)</a>
        <a href="#AN">Clause 1 a.1.i.A)</a>
        <a href="#Anote1">Clause 1 a.1.i.A.I)</a>
        <a href="#Anote2">Clause 1 a.1.i.A.I.a)</a>
        </p>
                </div>
                <p class="zzSTDTitle1"/>
                <div id="scope">
                  <h1>1&#160; Scope</h1>
                                   <ol type="a" id="N1">
         <li id="N"><p>A</p>
         <ol type="1">
         <li id="note1"><p>A</p>
         <ol type="i">
         <li id="note2"><p>A</p>
         <ol type="A">
         <li id="AN"><p>A</p>
         <ol type="I">
         <li id="Anote1"><p>A</p>
         <ol type="a">
         <li id="Anote2"><p>A</p></li>
         </ol></li>
         </ol></li>
         </ol></li>
         </ol></li>
         </ol></li>
       </ol>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
  end

end
