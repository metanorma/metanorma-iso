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
      <foreword displayorder="2" id="_">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="widgets">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="note1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="widgets">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="note2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1a">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1b">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="Anote1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1b">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="Anote2">2</semx>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references notes, skipping units notes" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <p>
              <xref target="note1"/>
              <xref target="note2"/>
            </p>
          </foreword>
        </preface>
        <sections>
          <clause id="widgets">
            <title>Widgets</title>
            <clause id="widgets1">
              <note id="note1" type="units">
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
              </note>
              <note id="note2">
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
              </note>
            </clause>
          </clause>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
       <foreword displayorder="2" id="_">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">[note1]</fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="widgets">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

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
          <clause id="widgets">
            <title>Widgets</title>
            <clause id="widgets1">
              <note id="note1" type="units">
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
              </note>
              <note id="note2">
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
              </note>
              <note id="note3">
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83b">These results are based on a study carried out on three different types of kernel.</p>
              </note>
            </clause>
          </clause>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="2" id="_">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">[note1]</fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="widgets">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="note2">1</semx>
                </fmt-xref>
             </semx>
             <xref target="note3" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note3">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="widgets">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="note3">2</semx>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
       <foreword id="fwd" displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="N">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="note1">2</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="note2">3</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="AN">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Anote1">2</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Anote2">3</semx>
                   </span>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
                     <xref target="AN1"/>
        <xref target="Anote11"/>
        <xref target="Anote21"/>
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
                          <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
                  <figure id="AN1">
            <figure id="Anote11">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
        <figure id="Anote21">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
      </figure>
          </references></bibliography>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
       <foreword id="fwd" displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="N">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="N">1</semx>
                      <semx element="autonum" source="note1">a</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="N">1</semx>
                      <semx element="autonum" source="note2">b</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="AN">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="AN">1</semx>
                      <semx element="autonum" source="Anote1">a</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="citefig">
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="AN">1</semx>
                      <semx element="autonum" source="Anote2">b</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="AN1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN1">
                   <span class="citefig">
                      <span class="fmt-xref-container">
                         <semx element="references" source="biblio">Bibliographical Section</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="AN1">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Anote11" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote11">
                   <span class="citefig">
                      <span class="fmt-xref-container">
                         <semx element="references" source="biblio">Bibliographical Section</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="AN1">1</semx>
                      <semx element="autonum" source="Anote11">a</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Anote21" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote21">
                   <span class="citefig">
                      <span class="fmt-xref-container">
                         <semx element="references" source="biblio">Bibliographical Section</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Figure</span>
                      <semx element="autonum" source="AN1">1</semx>
                      <semx element="autonum" source="Anote21">b</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </span>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
      <foreword displayorder="2" id="_">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="widgets">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="note1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="widgets">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="note2">2</semx>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1a">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1b">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="Anote1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1b">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Example</span>
                   <semx element="autonum" source="Anote2">2</semx>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
       <foreword displayorder="2" id="_">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="scope">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Formula</span>
                   <span class="fmt-autonum-delim">(</span>
                   <semx element="autonum" source="N">1</semx>
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="widgets">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Formula</span>
                   <span class="fmt-autonum-delim">(</span>
                   <semx element="autonum" source="note1">2</semx>
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="widgets">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="widgets1">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Formula</span>
                   <span class="fmt-autonum-delim">(</span>
                   <semx element="autonum" source="note2">3</semx>
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1a">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Formula</span>
                   <span class="fmt-autonum-delim">(</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AN">1</semx>
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1b">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Formula</span>
                   <span class="fmt-autonum-delim">(</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote1">2</semx>
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="annex1b">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Formula</span>
                   <span class="fmt-autonum-delim">(</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Anote2">3</semx>
                   <span class="fmt-autonum-delim">)</span>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
      <foreword displayorder="2" id="_">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="citetbl">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="N">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="citetbl">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="note1">2</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="citetbl">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="note2">3</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="AN" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="AN">
                   <span class="citetbl">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="AN">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Anote1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote1">
                   <span class="citetbl">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Anote1">2</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Anote2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Anote2">
                   <span class="citetbl">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Anote2">3</semx>
                   </span>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
            <term id="waxy_rice">
              <preferred><expression><name>waxy rice</name></expression></preferred>
              <termnote id="note1">
                <p id="_b0cb3dfd-78fc-47dd-a339-84070d947463">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
              </termnote>
            </term>
            <term id="nonwaxy_rice">
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
       <foreword displayorder="2" id="_">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="note1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note1">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="terms">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="waxy_rice">1</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="note1">1</semx>
                </fmt-xref>
             </semx>
             <xref target="note2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note2">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="terms">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="nonwaxy_rice">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="note2">1</semx>
                </fmt-xref>
             </semx>
             <xref target="note3" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="note3">
                   <span class="fmt-xref-container">
                      <semx element="autonum" source="terms">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="nonwaxy_rice">2</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Note</span>
                   <semx element="autonum" source="note3">2</semx>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references clauses" do
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
              <xref target="Q4"/>
              <xref target="QQ"/>
              <xref target="QQ1"/>
              <xref target="QQ2"/>
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
            <clause id="Q4" inline-header="false" obligation="normative">
              <title>Appendix subclause</title>
              </clause>
            </clause>
          </appendix>
        </annex>
       <annex id="QQ">
       <terms id="QQ1">
       <term id="QQ2"/>
       </terms>
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
       <foreword obligation="informative" displayorder="2" id="_">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p id="A">
             This is a preamble
             <xref target="C" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="C">
                   <span class="citesec">
                      <semx element="autonum" source="B">0</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="C">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="C1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="C1">
                   <span class="citesec">
                      <semx element="autonum" source="B">0</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="C1">2</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="D" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="D">
                   <span class="citesec">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="D">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="H" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="H">
                   <span class="citesec">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="H">3</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="I" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="I">
                   <span class="citesec">
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="I">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="J" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="J">
                   <span class="citesec">
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="I">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="J">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="K" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="K">
                   <span class="citesec">
                      <semx element="autonum" source="H">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="K">2</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="L" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="L">
                   <span class="citesec">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="L">4</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="M" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="M">
                   <span class="citesec">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="M">5</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="N" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="N">
                   <span class="citesec">
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="N">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="O" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="O">
                   <span class="citesec">
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="O">2</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="P" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="P">
                   <span class="citeapp">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Q" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Q">
                   <span class="citeapp">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Q1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Q1">
                   <span class="citeapp">
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q1">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Q2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Q2">
                   <span class="citeapp">
                      <span class="fmt-xref-container">
                         <span class="fmt-element-name">Annex</span>
                         <semx element="autonum" source="P">A</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Appendix</span>
                      <semx element="autonum" source="Q2">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="Q3" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Q3">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="Q2">1</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q3">1</semx>
                </fmt-xref>
             </semx>
             <xref target="Q4" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="Q4">
                   <span class="fmt-xref-container">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                   <span class="fmt-comma">,</span>
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="Q2">1</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q3">1</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q4">1</semx>
                </fmt-xref>
             </semx>
             <xref target="QQ" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="QQ">
                   <span class="citeapp">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="QQ">B</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="QQ1" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="QQ1">
                   <span class="citeapp">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="QQ1">B</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="QQ2" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="QQ2">
                   <span class="citeapp">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="QQ1">B</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="QQ2">1</semx>
                   </span>
                </fmt-xref>
             </semx>
             <xref target="R" id="_"/>
             <semx element="xref" source="_">
                <fmt-xref target="R">
                   <span class="citesec">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="R">2</semx>
                   </span>
                </fmt-xref>
             </semx>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references sections" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble
              <xref target="B"/>
              <xref target="D"/>
              <xref target="T"/>
              <xref target="H"/>
              <xref target="I"/>
              <xref target="J"/>
              <xref target="K"/>
              <xref target="L"/>
              <xref target="M"/>
              <xref target="N"/>
              </p>
          </foreword>
        </preface>
        <sections>
        <clause type="section" id="B"><title>General</title>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
            <references id='T' normative='false' obligation='informative'>
              <title depth='2'>Bibliography Subsection</title>
            </references>
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
            </clause>
            </clause>
            </sections>
            </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword obligation="informative" displayorder="2" id="_">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p id="A">
              This is a preamble
              <xref target="B" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="B">
                    <span class="citesec">
                       <span class="fmt-element-name">Section</span>
                       <semx element="autonum" source="B">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="D" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="D">
                    <span class="citesec">
                       <semx element="autonum" source="B">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="D">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="T" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="T">
                    <span class="citesec">
                       <semx element="autonum" source="B">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="T">2</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="H" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="H">
                    <span class="citesec">
                       <semx element="autonum" source="B">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="H">3</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="I" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="I">
                    <span class="citesec">
                       <semx element="autonum" source="B">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="H">3</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="I">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="J" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="J">
                    <span class="citesec">
                       <semx element="autonum" source="B">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="H">3</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="I">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="J">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="K" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="K">
                    <span class="citesec">
                       <semx element="autonum" source="B">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="H">3</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="K">2</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="L" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="L">
                    <span class="citesec">
                       <semx element="autonum" source="B">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="L">4</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="M" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="M">
                    <span class="citesec">
                       <semx element="autonum" source="B">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="M">5</semx>
                    </span>
                 </fmt-xref>
              </semx>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="citesec">
                       <semx element="autonum" source="B">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="M">5</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="N">1</semx>
                    </span>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references lists" do
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
    output = <<~OUTPUT
       <foreword displayorder="2" id="_">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="scope">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                 </fmt-xref>
              </semx>
              <xref target="note1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note1">
                    <span class="fmt-xref-container">
                       <semx element="autonum" source="widgets">3</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="widgets1">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="note1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="note2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note2">
                    <span class="fmt-xref-container">
                       <semx element="autonum" source="widgets">3</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="widgets1">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="note2">2</semx>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="annex1a">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                 </fmt-xref>
              </semx>
              <xref target="Anote1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote1">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="annex1b">2</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="Anote1">1</semx>
                 </fmt-xref>
              </semx>
              <xref target="Anote2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote2">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="annex1b">2</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="Anote2">2</semx>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <foreword displayorder="2" id="_">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="scope">1</semx>
                    </span>
                    <semx element="autonum" source="N">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="note1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note1">
                    <span class="fmt-xref-container">
                       <semx element="autonum" source="widgets">3</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="widgets1">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="note1l">1</semx>
                    <semx element="autonum" source="note1">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="note2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note2">
                    <span class="fmt-xref-container">
                       <semx element="autonum" source="widgets">3</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="widgets1">1</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="note2l">2</semx>
                    <semx element="autonum" source="note2">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="annex1a">1</semx>
                    </span>
                    <semx element="autonum" source="AN">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="Anote1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote1">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="annex1b">2</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="Anote1l">1</semx>
                    <semx element="autonum" source="Anote1">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="Anote2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote2">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="annex1b">2</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="Anote2l">2</semx>
                    <semx element="autonum" source="Anote2">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
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
              <xref target="P"/>
         <xref target="Q"/>
         <xref target="R"/>
         <xref target="S"/>
         <xref target="P1"/>
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
       <clause id="A"><title>Clause</title>
       <ol id="L">
       <li id="P">
       <ol id="L11">
       <li id="Q">
       <ol id="L12">
       <li id="R">
       <ol id="L13">
       <li id="S">
       </li>
       </ol>
       </li>
       </ol>
       </li>
       </ol>
       </li>
       </ol>
       <ol id="L1">
       <li id="P1">A</li>
       </ol>
       </clause>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword displayorder="2" id="_">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="N">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="scope">1</semx>
                    </span>
                    <semx element="autonum" source="N">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="note1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note1">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="scope">1</semx>
                    </span>
                    <semx element="autonum" source="N">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="note1">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="note2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="note2">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="scope">1</semx>
                    </span>
                    <semx element="autonum" source="N">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="note1">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="note2">i</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="AN" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="AN">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="scope">1</semx>
                    </span>
                    <semx element="autonum" source="N">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="note1">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="note2">i</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="AN">A</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="Anote1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote1">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="scope">1</semx>
                    </span>
                    <semx element="autonum" source="N">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="note1">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="note2">i</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="AN">A</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="Anote1">I</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="Anote2" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Anote2">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="scope">1</semx>
                    </span>
                    <semx element="autonum" source="N">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="note1">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="note2">i</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="AN">A</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="Anote1">I</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="Anote2">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="P" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="P">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="A">2</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="L">1</semx>
                    <semx element="autonum" source="P">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="Q" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Q">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="A">2</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="L">1</semx>
                    <semx element="autonum" source="P">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="Q">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="R" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="R">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="A">2</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="L">1</semx>
                    <semx element="autonum" source="P">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="Q">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="R">i</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="S" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="S">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="A">2</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="L">1</semx>
                    <semx element="autonum" source="P">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="Q">1</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="R">i</semx>
                    <span class="fmt-autonum-delim">)</span>
                    <semx element="autonum" source="S">A</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
              <xref target="P1" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="P1">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="A">2</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">List</span>
                    <semx element="autonum" source="L1">2</semx>
                    <semx element="autonum" source="P1">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)).at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "conflates cross-references to a split list" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <p><xref target="Na"/></p>
          </foreword>
        </preface>
        <sections>
          <clause id="scope" type="scope">
            <title>Scope</title>
            <ol id="N1">
              <li id="Na"><p>A</p></li>
              <li id="Na1"><p>A</p></li>
            </ol>
            <ol id="N2" start="3">
              <li id="Nb"><p>A</p></li>
              <li id="Nb1"><p>A</p></li>
            </ol>
            <ol id="N3" start="5">
              <li id="Nc"><p>A</p></li>
              <li id="Nc1"><p>A</p></li>
            </ol>
          </clause>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword displayorder="2" id="_">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="Na" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Na">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="scope">1</semx>
                    </span>
                    <semx element="autonum" source="Na">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
    .convert("test", input, true))
    .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <p><xref target="Na"/></p>
          </foreword>
        </preface>
        <sections>
          <clause id="scope" type="scope">
            <title>Scope</title>
            <ol id="N1">
              <li id="Na"><p>A</p></li>
              <li id="Na1"><p>A</p></li>
            </ol>
            <ol id="N2" start="3">
              <li id="Nb"><p>A</p></li>
              <li id="Nb1"><p>A</p></li>
            </ol>
            <ol id="N3" start="6">
              <li id="Nc"><p>A</p></li>
              <li id="Nc1"><p>A</p></li>
            </ol>
          </clause>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
        <foreword displayorder="2" id="_">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="Na" id="_"/>
              <semx element="xref" source="_">
                 <fmt-xref target="Na">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Clause</span>
                       <semx element="autonum" source="scope">1</semx>
                    </span>
                                <span class="fmt-comma">,</span>
            <span class="fmt-element-name">List</span>
            <semx element="autonum" source="N1">1</semx>
                    <semx element="autonum" source="Na">a</semx>
                    <span class="fmt-autonum-delim">)</span>
                 </fmt-xref>
              </semx>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Iso::PresentationXMLConvert
      .new(presxml_options)
    .convert("test", input, true))
    .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
