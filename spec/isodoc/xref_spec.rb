require "spec_helper"

RSpec.describe IsoDoc do
  it "cross-references notes" do
    input = <<~INPUT
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
          <clause id="scope" type="scope">
            <title>Scope</title>
            <note id="N">
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
            </note>
            <p>
              <xref target="N"/>
            </p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets">
            <title>Widgets</title>
            <clause id="widgets1">
              <note id="note1">
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
              </note>
              <note id="note2">
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
              </note>
              <p>
                <xref target="note1"/>
                <xref target="note2"/>
              </p>
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
    output = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword displayorder='1'>
            <p>
              <xref target="N">Clause 1, Note</xref>
              <xref target="note1">3.1, Note 1</xref>
              <xref target="note2">3.1, Note 2</xref>
              <xref target="AN">A.1, Note</xref>
              <xref target="Anote1">A.2, Note 1</xref>
              <xref target="Anote2">A.2, Note 2</xref>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id="scope" type="scope" displayorder='2'>
            <title depth="1">1
              <tab/>
              Scope</title>
            <note id="N">
              <name>NOTE</name>
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different
                        types of kernel.
                      </p>
            </note>
            <p>
              <xref target="N">Note</xref>
            </p>
          </clause>
          <terms id="terms"  displayorder='3'>
            <title>2</title>
          </terms>
          <clause id="widgets"  displayorder='4'>
            <title depth="1">3
              <tab/>
              Widgets</title>
            <clause id="widgets1" inline-header="true">
              <title>3.1</title>
              <note id="note1">
                <name>NOTE 1</name>
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different
                          types of kernel.
                        </p>
              </note>
              <note id="note2">
                <name>NOTE 2</name>
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different
                          types of kernel.
                        </p>
              </note>
              <p>
                <xref target="note1">Note 1</xref>
                <xref target="note2">Note 2</xref>
              </p>
            </clause>
          </clause>
        </sections>
        <annex id="annex1" displayorder='5'>
          <title>
            <strong>Annex A</strong>
            <br/><span class="obligation">(informative)</span></title>
          <clause id="annex1a" inline-header="true">
            <title>A.1</title>
            <note id="AN">
              <name>NOTE</name>
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different
                        types of kernel.
                      </p>
            </note>
          </clause>
          <clause id="annex1b" inline-header="true">
            <title>A.2</title>
            <note id="Anote1">
              <name>NOTE 1</name>
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different
                        types of kernel.
                      </p>
            </note>
            <note id="Anote2">
              <name>NOTE 2</name>
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different
                        types of kernel.
                      </p>
            </note>
          </clause>
        </annex>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "cross-references figures" do
    input = <<~INPUT
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
          <clause id="scope" type="scope">
            <title>Scope</title>
            <figure id="N">
              <name>Split-it-right sample divider</name>
              <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
            </figure>
            <p>
              <xref target="N"/>
            </p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets">
            <title>Widgets</title>
            <clause id="widgets1">
              <figure id="note1">
                <name>Split-it-right sample divider</name>
                <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
              </figure>
              <figure id="note2">
                <name>Split-it-right sample divider</name>
                <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
              </figure>
              <p>
                <xref target="note1"/>
                <xref target="note2"/>
              </p>
            </clause>
          </clause>
        </sections>
        <annex id="annex1">
          <clause id="annex1a">
            <figure id="AN">
              <name>Split-it-right sample divider</name>
              <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
            </figure>
          </clause>
          <clause id="annex1b">
            <figure id="Anote1">
              <name>Split-it-right sample divider</name>
              <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
            </figure>
            <figure id="Anote2">
              <name>Split-it-right sample divider</name>
              <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
            </figure>
          </clause>
        </annex>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword id="fwd" displayorder='1'>
            <p>
              <xref target="N"><span class='citefig'>Figure 1</span></xref>
              <xref target="note1"><span class='citefig'>Figure 2</span></xref>
              <xref target="note2"><span class='citefig'>Figure 3</span></xref>
              <xref target="AN"><span class='citefig'>Figure A.1</span></xref>
              <xref target="Anote1"><span class='citefig'>Figure A.2</span></xref>
              <xref target="Anote2"><span class='citefig'>Figure A.3</span></xref>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id="scope" type="scope" displayorder='2'>
            <title depth="1">1
              <tab/>
              Scope</title>
            <figure id="N">
              <name>Figure 1 — Split-it-right sample divider</name>
              <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
            </figure>
            <p>
              <xref target="N"><span class='citefig'>Figure 1</span></xref>
            </p>
          </clause>
          <terms id="terms" displayorder='3'>
            <title>2</title>
          </terms>
          <clause id="widgets" displayorder='4'>
            <title depth="1">3
              <tab/>
              Widgets</title>
            <clause id="widgets1" inline-header="true">
              <title>3.1</title>
              <figure id="note1">
                <name>Figure 2 — Split-it-right sample divider</name>
                <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
              </figure>
              <figure id="note2">
                <name>Figure 3 — Split-it-right sample divider</name>
                <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
              </figure>
              <p>
                <xref target="note1"><span class='citefig'>Figure 2</span></xref>
                <xref target="note2"><span class='citefig'>Figure 3</span></xref>
              </p>
            </clause>
          </clause>
        </sections>
        <annex id="annex1" displayorder='5'>
          <title>
            <strong>Annex A</strong>
            <br/><span class="obligation">(informative)</span></title>
          <clause id="annex1a" inline-header="true">
            <title>A.1</title>
            <figure id="AN">
              <name>Figure A.1 — Split-it-right sample divider</name>
              <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
            </figure>
          </clause>
          <clause id="annex1b" inline-header="true">
            <title>A.2</title>
            <figure id="Anote1">
              <name>Figure A.2 — Split-it-right sample divider</name>
              <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
            </figure>
            <figure id="Anote2">
              <name>Figure A.3 — Split-it-right sample divider</name>
              <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
            </figure>
          </clause>
        </annex>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "cross-references subfigures" do
    input = <<~INPUT
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
          <clause id="scope" type="scope">
            <title>Scope</title>
          </clause>
          <terms id="terms"/>
          <clause id="widgets">
            <title>Widgets</title>
            <clause id="widgets1">
              <figure id="N">
                <figure id="note1">
                  <name>Split-it-right sample divider</name>
                  <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
                </figure>
                <figure id="note2">
                  <name>Split-it-right sample divider</name>
                  <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
                </figure>
              </figure>
              <p>
                <xref target="note1"/>
                <xref target="note2"/>
              </p>
            </clause>
          </clause>
        </sections>
        <annex id="annex1">
          <clause id="annex1a"/>
          <clause id="annex1b">
            <figure id="AN">
              <figure id="Anote1">
                <name>Split-it-right sample divider</name>
                <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
              </figure>
              <figure id="Anote2">
                <name>Split-it-right sample divider</name>
                <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
              </figure>
            </figure>
          </clause>
        </annex>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword id="fwd" displayorder='1'>
            <p>
              <xref target="N"><span class='citefig'>Figure 1</span></xref>
              <xref target="note1"><span class='citefig'>Figure 1 a)</span></xref>
              <xref target="note2"><span class='citefig'>Figure 1 b)</span></xref>
              <xref target="AN"><span class='citefig'>Figure A.1</span></xref>
              <xref target="Anote1"><span class='citefig'>Figure A.1 a)</span></xref>
              <xref target="Anote2"><span class='citefig'>Figure A.1 b)</span></xref>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id="scope" type="scope" displayorder='2'>
            <title depth="1">1
              <tab/>
              Scope</title>
          </clause>
          <terms id="terms" displayorder='3'>
            <title>2</title>
          </terms>
          <clause id="widgets" displayorder='4'>
            <title depth="1">3
              <tab/>
              Widgets</title>
            <clause id="widgets1" inline-header="true">
              <title>3.1</title>
              <figure id="N">
                <name>Figure 1</name>
                <figure id="note1">
                  <name>a)  Split-it-right sample divider</name>
                  <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
                </figure>
                <figure id="note2">
                  <name>b)  Split-it-right sample divider</name>
                  <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
                </figure>
              </figure>
              <p>
                <xref target="note1"><span class='citefig'>Figure 1 a)</span></xref>
                <xref target="note2"><span class='citefig'>Figure 1 b)</span></xref>
              </p>
            </clause>
          </clause>
        </sections>
        <annex id="annex1" displayorder='5'>
          <title>
            <strong>Annex A</strong>
            <br/><span class="obligation">(informative)</span></title>
          <clause id="annex1a" inline-header="true">
            <title>A.1</title>
          </clause>
          <clause id="annex1b" inline-header="true">
            <title>A.2</title>
            <figure id="AN">
              <name>Figure A.1</name>
              <figure id="Anote1">
                <name>a)  Split-it-right sample divider</name>
                <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
              </figure>
              <figure id="Anote2">
                <name>b)  Split-it-right sample divider</name>
                <image id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" src="rice_images/rice_image1.png"/>
              </figure>
            </figure>
          </clause>
        </annex>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
     .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "cross-references examples" do
    input = <<~INPUT
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
          <clause id="scope" type="scope">
            <title>Scope</title>
            <example id="N">
              <p>Hello</p>
            </example>
            <p>
              <xref target="N"/>
            </p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets">
            <title>Widgets</title>
            <clause id="widgets1">
              <example id="note1">
                <p>Hello</p>
              </example>
              <example id="note2">
                <p>Hello</p>
              </example>
              <p>
                <xref target="note1"/>
                <xref target="note2"/>
              </p>
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
    output = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword displayorder='1'>
            <p>
              <xref target="N">Clause 1, Example</xref>
              <xref target="note1">3.1, Example 1</xref>
              <xref target="note2">3.1, Example 2</xref>
              <xref target="AN">A.1, Example</xref>
              <xref target="Anote1">A.2, Example 1</xref>
              <xref target="Anote2">A.2, Example 2</xref>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id="scope" type="scope" displayorder='2'>
            <title depth="1">1
              <tab/>
              Scope</title>
            <example id="N">
              <name>EXAMPLE</name>
              <p>Hello</p>
            </example>
            <p>
              <xref target="N">Example</xref>
            </p>
          </clause>
          <terms id="terms" displayorder='3'>
            <title>2</title>
          </terms>
          <clause id="widgets" displayorder='4'>
            <title depth="1">3
              <tab/>
              Widgets</title>
            <clause id="widgets1" inline-header="true">
              <title>3.1</title>
              <example id="note1">
                <name>EXAMPLE 1</name>
                <p>Hello</p>
              </example>
              <example id="note2">
                <name>EXAMPLE 2</name>
                <p>Hello</p>
              </example>
              <p>
                <xref target="note1">Example 1</xref>
                <xref target="note2">Example 2</xref>
              </p>
            </clause>
          </clause>
        </sections>
        <annex id="annex1" displayorder='5'>
          <title>
            <strong>Annex A</strong>
            <br/><span class="obligation">(informative)</span></title>
          <clause id="annex1a" inline-header="true">
            <title>A.1</title>
            <example id="AN">
              <name>EXAMPLE</name>
              <p>Hello</p>
            </example>
          </clause>
          <clause id="annex1b" inline-header="true">
            <title>A.2</title>
            <example id="Anote1">
              <name>EXAMPLE 1</name>
              <p>Hello</p>
            </example>
            <example id="Anote2">
              <name>EXAMPLE 2</name>
              <p>Hello</p>
            </example>
          </clause>
        </annex>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "cross-references formulae" do
    input = <<~INPUT
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
          <clause id="scope" type="scope">
            <title>Scope</title>
            <formula id="N">
              <stem type="AsciiMath">r = 1 %</stem>
            </formula>
            <p>
              <xref target="N"/>
            </p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets">
            <title>Widgets</title>
            <clause id="widgets1">
              <formula id="note1">
                <stem type="AsciiMath">r = 1 %</stem>
              </formula>
              <formula id="note2">
                <stem type="AsciiMath">r = 1 %</stem>
              </formula>
              <p>
                <xref target="note1"/>
                <xref target="note2"/>
              </p>
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
        </dl>
      </formula>
          </foreword>
        </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword displayorder='1'>
            <p>
              <xref target="N">Clause 1, Formula (1)</xref>
              <xref target="note1">3.1, Formula (2)</xref>
              <xref target="note2">3.1, Formula (3)</xref>
              <xref target="AN">A.1, Formula (A.1)</xref>
              <xref target="Anote1">A.2, Formula (A.2)</xref>
              <xref target="Anote2">A.2, Formula (A.3)</xref>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id="scope" type="scope" displayorder='2'>
            <title depth="1">1
              <tab/>
              Scope</title>
            <formula id="N">
              <name>1</name>
              <stem type="AsciiMath">r = 1 %</stem>
            </formula>
            <p>
              <xref target="N">Formula (1)</xref>
            </p>
          </clause>
          <terms id="terms" displayorder='3'>
            <title>2</title>
          </terms>
          <clause id="widgets" displayorder='4'>
            <title depth="1">3
              <tab/>
              Widgets</title>
            <clause id="widgets1" inline-header="true">
              <title>3.1</title>
              <formula id="note1">
                <name>2</name>
                <stem type="AsciiMath">r = 1 %</stem>
              </formula>
              <formula id="note2">
                <name>3</name>
                <stem type="AsciiMath">r = 1 %</stem>
              </formula>
              <p>
                <xref target="note1">Formula (2)</xref>
                <xref target="note2">Formula (3)</xref>
              </p>
            </clause>
          </clause>
        </sections>
        <annex id="annex1" displayorder='5'>
          <title>
            <strong>Annex A</strong>
            <br/><span class="obligation">(informative)</span></title>
          <clause id="annex1a" inline-header="true">
            <title>A.1</title>
            <formula id="AN">
              <name>A.1</name>
              <stem type="AsciiMath">r = 1 %</stem>
            </formula>
          </clause>
          <clause id="annex1b" inline-header="true">
            <title>A.2</title>
            <formula id="Anote1">
              <name>A.2</name>
              <stem type="AsciiMath">r = 1 %</stem>
            </formula>
            <formula id="Anote2">
              <name>A.3</name>
              <stem type="AsciiMath">r = 1 %</stem>
            </formula>
          </clause>
        </annex>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "cross-references tables" do
    input = <<~INPUT
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
          <clause id="scope" type="scope">
            <title>Scope</title>
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
            <p>
              <xref target="N"/>
            </p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets">
            <title>Widgets</title>
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
              <p>
                <xref target="note1"/>
                <xref target="note2"/>
              </p>
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
    output = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword displayorder='1'>
            <p>
              <xref target="N"><span class='citetbl'>Table 1</span></xref>
              <xref target="note1"><span class='citetbl'>Table 2</span></xref>
              <xref target="note2"><span class='citetbl'>Table 3</span></xref>
              <xref target="AN"><span class='citetbl'>Table A.1</span></xref>
              <xref target="Anote1"><span class='citetbl'>Table A.2</span></xref>
              <xref target="Anote2"><span class='citetbl'>Table A.3</span></xref>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id="scope" type="scope" displayorder='2'>
            <title depth="1">1
              <tab/>
              Scope</title>
            <table id="N">
              <name>Table 1 — Repeatability and reproducibility of husked rice yield</name>
              <tbody>
                <tr>
                  <td align="left">Number of laboratories retained after eliminating outliers</td>
                  <td align="center">13</td>
                  <td align="center">11</td>
                </tr>
              </tbody>
            </table>
            <p>
              <xref target="N"><span class='citetbl'>Table 1</span></xref>
            </p>
          </clause>
          <terms id="terms" displayorder='3'>
            <title>2</title>
          </terms>
          <clause id="widgets" displayorder='4'>
            <title depth="1">3
              <tab/>
              Widgets</title>
            <clause id="widgets1" inline-header="true">
              <title>3.1</title>
              <table id="note1">
                <name>Table 2 — Repeatability and reproducibility of husked rice yield</name>
                <tbody>
                  <tr>
                    <td align="left">Number of laboratories retained after eliminating outliers</td>
                    <td align="center">13</td>
                    <td align="center">11</td>
                  </tr>
                </tbody>
              </table>
              <table id="note2">
                <name>Table 3 — Repeatability and reproducibility of husked rice yield</name>
                <tbody>
                  <tr>
                    <td align="left">Number of laboratories retained after eliminating outliers</td>
                    <td align="center">13</td>
                    <td align="center">11</td>
                  </tr>
                </tbody>
              </table>
              <p>
                <xref target="note1"><span class='citetbl'>Table 2</span></xref>
                <xref target="note2"><span class='citetbl'>Table 3</span></xref>
              </p>
            </clause>
          </clause>
        </sections>
        <annex id="annex1" displayorder='5'>
          <title>
            <strong>Annex A</strong>
            <br/><span class="obligation">(informative)</span></title>
          <clause id="annex1a" inline-header="true">
            <title>A.1</title>
            <table id="AN">
              <name>Table A.1 — Repeatability and reproducibility of husked rice yield</name>
              <tbody>
                <tr>
                  <td align="left">Number of laboratories retained after eliminating outliers</td>
                  <td align="center">13</td>
                  <td align="center">11</td>
                </tr>
              </tbody>
            </table>
          </clause>
          <clause id="annex1b" inline-header="true">
            <title>A.2</title>
            <table id="Anote1">
              <name>Table A.2 — Repeatability and reproducibility of husked rice yield</name>
              <tbody>
                <tr>
                  <td align="left">Number of laboratories retained after eliminating outliers</td>
                  <td align="center">13</td>
                  <td align="center">11</td>
                </tr>
              </tbody>
            </table>
            <table id="Anote2">
              <name>Table A.3 — Repeatability and reproducibility of husked rice yield</name>
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
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "cross-references term notes" do
    input = <<~INPUT
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
          <clause id="scope" type="scope">
            <title>Scope</title>
          </clause>
          <terms id="terms">
            <term id="_waxy_rice">
              <preferred><expression><name>waxy rice</name></expression></preferred>
              <termnote id="note1">
                <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
            </term>
            <term id="_nonwaxy_rice">
              <preferred><expression><name>nonwaxy rice</name></expression></preferred>
              <termnote id="note2">
                <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
              <termnote id="note3">
                <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
            </term>
          </terms>

      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword displayorder='1'>
            <p>
              <xref target="note1">2.1, Note 1</xref>
              <xref target="note2">2.2, Note 1</xref>
              <xref target="note3">2.2, Note 2</xref>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id="scope" type="scope" displayorder='2'>
            <title depth="1">1
              <tab/>
              Scope</title>
          </clause>
          <terms id="terms" displayorder='3'>
            <title>2</title>
            <term id="_waxy_rice">
              <name>2.1</name>
              <preferred><strong>waxy rice</strong></preferred>
              <termnote id="note1">
                <name>Note 1 to entry</name>
                <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The
                  kernels have a tendency to stick together after cooking.
                </p>
              </termnote>
            </term>
            <term id="_nonwaxy_rice">
              <name>2.2</name>
              <preferred><strong>nonwaxy rice</strong></preferred>
              <termnote id="note2">
                <name>Note 1 to entry</name>
                <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The
                  kernels have a tendency to stick together after cooking.
                </p>
              </termnote>
              <termnote id="note3">
                <name>Note 2 to entry</name>
                <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The
                  kernels have a tendency to stick together after cooking.
                </p>
              </termnote>
            </term>
          </terms>
        </sections>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "cross-references sections" do
    input = <<~INPUT
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
              <xref target="Q3"/>
              <xref target="R"/></p>
          </foreword>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
            <clause id="C1" inline-header="false" obligation="informative">Text</clause>
          </introduction>
        </preface>
        <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
          <terms id="H" obligation="normative">
            <title>Terms, definitions, symbols and abbreviated terms</title>
            <terms id="I" obligation="normative">
              <title>Normal Terms</title>
              <term id="J">
                <preferred><expression><name>Term2</name></expression></preferred>
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
          <clause id="M" inline-header="false" obligation="normative">
            <title>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title>Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title>Clause 4.2</title>
            </clause>
          </clause>
        </sections>
        <annex id="P" inline-header="false" obligation="normative">
          <title>Annex</title>
          <clause id="Q" inline-header="false" obligation="normative">
            <title>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
              <title>Annex A.1a</title>
            </clause>
          </clause>
          <appendix id="Q2" inline-header="false" obligation="normative">
            <title>An Appendix</title>
            <clause id="Q3" inline-header="false" obligation="normative">
              <title>Appendix subclause</title>
            </clause>
          </appendix>
        </annex>
        <bibliography>
          <references id="R" normative="true" obligation="informative">
            <title>Normative References</title>
          </references>
          <clause id="S" obligation="informative">
            <title>Bibliography</title>
            <references id="T" normative="false" obligation="informative">
              <title>Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <preface>
          <foreword obligation='informative' displayorder='1'>
            <title>Foreword</title>
            <p id='A'>
              This is a preamble
              <xref target='C'><span class='citesec'>0.1</span></xref>
              <xref target='C1'><span class='citesec'>0.2</span></xref>
              <xref target='D'><span class='citesec'>Clause 1</span></xref>
              <xref target='H'><span class='citesec'>Clause 3</span></xref>
              <xref target='I'><span class='citesec'>3.1</span></xref>
              <xref target='J'><span class='citesec'>3.1.1</span></xref>
              <xref target='K'><span class='citesec'>3.2</span></xref>
              <xref target='L'><span class='citesec'>Clause 4</span></xref>
              <xref target='M'><span class='citesec'>Clause 5</span></xref>
              <xref target='N'><span class='citesec'>5.1</span></xref>
              <xref target='O'><span class='citesec'>5.2</span></xref>
              <xref target='P'><span class='citeapp'>Annex A</span></xref>
              <xref target='Q'><span class='citeapp'>A.1</span></xref>
              <xref target='Q1'><span class='citeapp'>A.1.1</span></xref>
              <xref target='Q2'><span class='citeapp'>Annex A, Appendix 1</span></xref>
              <xref target='Q3'>Annex A, Appendix 1.1</xref>
              <xref target='R'><span class='citesec'>Clause 2</span></xref>
            </p>
          </foreword>
          <introduction id='B' obligation='informative' displayorder='2'>
            <title depth='1'>
              0
              <tab/>
              Introduction
            </title>
            <clause id='C' inline-header='false' obligation='informative'>
              <title depth='2'>
                0.1
                <tab/>
                Introduction Subsection
              </title>
            </clause>
            <clause id='C1' inline-header='true' obligation='informative'>
              <title>0.2</title>
              Text
            </clause>
          </introduction>
        </preface>
        <sections>
          <clause id='D' obligation='normative' type='scope' displayorder='3'>
            <title depth='1'>
              1
              <tab/>
              Scope
            </title>
            <p id='E'>Text</p>
          </clause>
          <terms id='H' obligation='normative' displayorder='5'>
            <title depth='1'>
              3
              <tab/>
              Terms, definitions, symbols and abbreviated terms
            </title>
            <terms id='I' obligation='normative'>
              <title depth='2'>
                3.1
                <tab/>
                Normal Terms
              </title>
              <term id='J'>
                <name>3.1.1</name>
                <preferred><strong>Term2</strong></preferred>
              </term>
            </terms>
            <definitions id='K' inline-header='true'>
              <title>3.2</title>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </terms>
          <definitions id='L' displayorder='6'>
            <title>4</title>
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id='M' inline-header='false' obligation='normative' displayorder='7'>
            <title depth='1'>
              5
              <tab/>
              Clause 4
            </title>
            <clause id='N' inline-header='false' obligation='normative'>
              <title depth='2'>
                5.1
                <tab/>
                Introduction
              </title>
            </clause>
            <clause id='O' inline-header='false' obligation='normative'>
              <title depth='2'>
                5.2
                <tab/>
                Clause 4.2
              </title>
            </clause>
          </clause>
        </sections>
        <annex id='P' inline-header='false' obligation='normative' displayorder='8'>
          <title>
            <strong>Annex A</strong>
            <br/>
            <span class="obligation">(normative)</span>
            <br/>
            <br/>
            <strong>Annex</strong>
          </title>
          <clause id='Q' inline-header='false' obligation='normative'>
            <title depth='2'>
              A.1
              <tab/>
              Annex A.1
            </title>
            <clause id='Q1' inline-header='false' obligation='normative'>
              <title depth='3'>
                A.1.1
                <tab/>
                Annex A.1a
              </title>
            </clause>
          </clause>
          <appendix id='Q2' inline-header='false' obligation='normative'>
            <title depth='2'>
              Appendix 1
              <tab/>
              An Appendix
            </title>
            <clause id='Q3' inline-header='false' obligation='normative'>
              <title depth='3'>
                Appendix 1.1
                <tab/>
                Appendix subclause
              </title>
            </clause>
          </appendix>
        </annex>
        <bibliography>
          <references id='R' normative='true' obligation='informative' displayorder='4'>
            <title depth='1'>
              2
              <tab/>
              Normative References
            </title>
          </references>
          <clause id='S' obligation='informative' displayorder='9'>
            <title depth='1'>Bibliography</title>
            <references id='T' normative='false' obligation='informative'>
              <title depth='2'>Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "cross-references lists" do
    output = IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", <<~"INPUT", true)
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
            <clause id="scope" type="scope">
              <title>Scope</title>
              <ol id="N">
                <li>
                  <p>A</p>
                </li>
              </ol>
            </clause>
            <terms id="terms"/>
            <clause id="widgets">
              <title>Widgets</title>
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
    expect(xmlpp(output)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <?xml version='1.0'?>
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword displayorder='1'>
            <p>
              <xref target="N">Clause 1, List</xref>
              <xref target="note1">3.1, List 1</xref>
              <xref target="note2">3.1, List 2</xref>
              <xref target="AN">A.1, List</xref>
              <xref target="Anote1">A.2, List 1</xref>
              <xref target="Anote2">A.2, List 2</xref>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id="scope" type="scope" displayorder='2'>
            <title depth="1">1
              <tab/>
              Scope</title>
            <ol id="N" type="alphabet">
              <li>
                <p>A</p>
              </li>
            </ol>
          </clause>
          <terms id="terms" displayorder='3'>
            <title>2</title>
          </terms>
          <clause id="widgets" displayorder='4'>
            <title depth="1">3
              <tab/>
              Widgets</title>
            <clause id="widgets1" inline-header="true">
              <title>3.1</title>
              <ol id="note1" type="alphabet">
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different
                          types of kernel.
                        </p>
              </ol>
              <ol id="note2" type="alphabet">
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different
                          types of kernel.
                        </p>
              </ol>
            </clause>
          </clause>
        </sections>
        <annex id="annex1" displayorder='5'>
          <title>
            <strong>Annex A</strong>
            <br/><span class="obligation">(informative)</span></title>
          <clause id="annex1a" inline-header="true">
            <title>A.1</title>
            <ol id="AN" type="alphabet">
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different
                        types of kernel.
                      </p>
            </ol>
          </clause>
          <clause id="annex1b" inline-header="true">
            <title>A.2</title>
            <ol id="Anote1" type="alphabet">
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different
                        types of kernel.
                      </p>
            </ol>
            <ol id="Anote2" type="alphabet">
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different
                        types of kernel.
                      </p>
            </ol>
          </clause>
        </annex>
      </iso-standard>
    OUTPUT
  end

  it "cross-references list items" do
    input = <<~INPUT
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
          <clause id="scope" type="scope">
            <title>Scope</title>
            <ol id="N1">
              <li id="N">
                <p>A</p>
              </li>
            </ol>
          </clause>
          <terms id="terms"/>
          <clause id="widgets">
            <title>Widgets</title>
            <clause id="widgets1">
              <ol id="note1l">
                <li id="note1">
                  <p>A</p>
                </li>
              </ol>
              <ol id="note2l">
                <li id="note2">
                  <p>A</p>
                </li>
              </ol>
            </clause>
          </clause>
        </sections>
        <annex id="annex1">
          <clause id="annex1a">
            <ol id="ANl">
              <li id="AN">
                <p>A</p>
              </li>
            </ol>
          </clause>
          <clause id="annex1b">
            <ol id="Anote1l">
              <li id="Anote1">
                <p>A</p>
              </li>
            </ol>
            <ol id="Anote2l">
              <li id="Anote2">
                <p>A</p>
              </li>
            </ol>
          </clause>
        </annex>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <foreword displayorder='1'>
            <p>
              <xref target='N'>1 a)</xref>
              <xref target='note1'>3.1 List 1 a)</xref>
              <xref target='note2'>3.1 List 2 a)</xref>
              <xref target='AN'>A.1 a)</xref>
              <xref target='Anote1'>A.2 List 1 a)</xref>
              <xref target='Anote2'>A.2 List 2 a)</xref>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id='scope' type='scope' displayorder='2'>
            <title depth='1'>1<tab/>Scope</title>
            <ol id='N1' type="alphabet">
              <li id='N'>
                <p>A</p>
              </li>
            </ol>
          </clause>
          <terms id='terms' displayorder='3'><title>2</title></terms>
          <clause id='widgets' displayorder='4'>
          <title depth='1'>3<tab/>Widgets</title>
            <clause inline-header="true" id='widgets1'><title>3.1</title>
              <ol id='note1l' type="alphabet">
                <li id='note1'>
                  <p>A</p>
                </li>
              </ol>
              <ol id='note2l' type="alphabet">
                <li id='note2'>
                  <p>A</p>
                </li>
              </ol>
            </clause>
          </clause>
        </sections>
        <annex id='annex1'  displayorder='5'><title><strong>Annex A</strong><br/><span class="obligation">(informative)</span></title>
          <clause inline-header="true" id='annex1a'><title>A.1</title>
            <ol id='ANl' type="alphabet">
              <li id='AN'>
                <p>A</p>
              </li>
            </ol>
          </clause>
          <clause inline-header="true" id='annex1b'><title>A.2</title>
            <ol id='Anote1l' type="alphabet">
              <li id='Anote1'>
                <p>A</p>
              </li>
            </ol>
            <ol id='Anote2l' type="alphabet">
              <li id='Anote2'>
                <p>A</p>
              </li>
            </ol>
          </clause>
        </annex>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "cross-references nested list items" do
    input = <<~INPUT
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
          <clause id="scope" type="scope">
            <title>Scope</title>
            <ol id="N1">
              <li id="N">
                <p>A</p>
                <ol>
                  <li id="note1">
                    <p>A</p>
                    <ol>
                      <li id="note2">
                        <p>A</p>
                        <ol>
                          <li id="AN">
                            <p>A</p>
                            <ol>
                              <li id="Anote1">
                                <p>A</p>
                                <ol>
                                  <li id="Anote2">
                                    <p>A</p>
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
              </li>
            </ol>
          </clause>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version='1.0'?>
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <preface>
          <foreword displayorder='1'>
            <p>
              <xref target='N'>1 a)</xref>
              <xref target='note1'>1 a) 1)</xref>
              <xref target='note2'>1 a) 1) i)</xref>
              <xref target='AN'>1 a) 1) i) A)</xref>
              <xref target='Anote1'>1 a) 1) i) A) I)</xref>
              <xref target='Anote2'>1 a) 1) i) A) I) a)</xref>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id='scope' type='scope' displayorder='2'>
            <title depth='1'>1<tab/>Scope</title>
            <ol id='N1' type="alphabet">
              <li id='N'>
                <p>A</p>
                <ol type="arabic">
                  <li id='note1'>
                    <p>A</p>
                    <ol type="roman">
                      <li id='note2'>
                        <p>A</p>
                        <ol type="alphabet_upper">
                          <li id='AN'>
                            <p>A</p>
                            <ol type="roman_upper">
                              <li id='Anote1'>
                                <p>A</p>
                                <ol type="alphabet">
                                  <li id='Anote2'>
                                    <p>A</p>
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
              </li>
            </ol>
          </clause>
        </sections>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end
end
