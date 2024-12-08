require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::Iso do
  it "processes isodoc as ISO: HTML output" do
    IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~INPUT, false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <note>
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
            </note>
          </foreword>
        </preface>
      </iso-standard>
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html)
      .to match(%r[blockquote[^{]+\{[^{]+font-family: "Cambria", serif;]m)
    expect(html)
      .to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Cambria", serif;]m)
  end

  it "processes isodoc as ISO: alt HTML output" do
    IsoDoc::Iso::HtmlConvert.new(alt: true).convert("test", <<~INPUT, false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <note>
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
            </note>
          </foreword>
        </preface>
      </iso-standard>
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^{]+font-family: "Space Mono", monospace;]m)
    expect(html)
      .to match(%r[blockquote[^{]+\{[^{]+font-family: "Lato", sans-serif;]m)
    expect(html)
      .to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Lato", sans-serif;]m)
  end

  it "processes isodoc as ISO: Chinese HTML output" do
    IsoDoc::Iso::HtmlConvert.new(script: "Hans")
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
            <foreword>
              <note>
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
              </note>
            </foreword>
          </preface>
        </iso-standard>
      INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html)
      .to match(%r[blockquote[^{]+\{[^{]+font-family: "Source Han Sans", serif;]m)
    expect(html)
      .to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Source Han Sans", sans-serif;]m)
  end

  it "processes isodoc as ISO: user nominated fonts" do
    IsoDoc::Iso::HtmlConvert.new(bodyfont: "Zapf Chancery",
                                 headerfont: "Comic Sans",
                                 monospacefont: "Andale Mono")
      .convert("test", <<~INPUT, false)
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
            <foreword>
              <note>
                <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
              </note>
            </foreword>
          </preface>
        </iso-standard>
      INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html)
      .to match(%r[blockquote[^{]+\{[^{]+font-family: Zapf Chancery;]m)
    expect(html)
      .to match(%r[\.h2Annex[^{]+\{[^{]+font-family: Comic Sans;]m)
  end

  it "processes isodoc as ISO: Word output" do
    IsoDoc::Iso::WordConvert.new({}).convert("test", <<~INPUT, false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <note>
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
            </note>
          </foreword>
        </preface>
      </iso-standard>
    INPUT
    html = File.read("test.doc", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html)
      .to match(%r[Quote[^{]+\{[^{]+font-family: "Cambria", serif;]m)
    expect(html)
      .to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Cambria", serif;]m)
  end

  it "does not include IEV in references" do
    presxml = IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", <<~INPUT, true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword id="A"><title>Foreword</title>
            <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
              <eref bibitemid="IEV">IEV</eref>
              <eref bibitemid="ISO20483">ISO 20483</eref>
            </p>
          </foreword>
        </preface>
        <bibliography>
          <references id="_normative_references" normative="true" obligation="informative">
            <title>Normative References</title>
            <bibitem id="IEV" type="standard">
              <title format="text/plain" language="en" script="Latn">Electropedia: The World's Online Electrotechnical Vocabulary</title>
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
              <language>en</language>
              <language>fr</language>
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
              <formattedref format="text/plain"><em>Cereals and pulses</em></formattedref>
              <docidentifier>ISO 20483</docidentifier>
              <date type="published">
                <from>2013</from>
                <to>2014</to>
              </date>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>International Organization for Standardization</name>
                </organization>
              </contributor>
              <biblio-tag>ISO 20483,</biblio-tag>
            </bibitem>
          </references>
        </bibliography>
      </iso-standard>
    INPUT
    output = IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)
    expect(Xml::C14n.format(strip_guid(output)))
     .to be_equivalent_to Xml::C14n.format(strip_guid(<<~"OUTPUT"))
      #{HTML_HDR}
            <br/>
            <div id="A">
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
                <a href="http://www.electropedia.org">IEV</a>
                <a href="#ISO20483">ISO 20483</a>
              </p>
            </div>
            <div>
              <h1>1&#160; Normative References</h1>
              <p id="ISO20483" class="NormRef">ISO 20483, <i>Cereals and pulses</i></p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "inserts identifiers for editorial group and approval group" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <ext>
            <doctype>international-standard</doctype>
            <horizontal>true</horizontal>
            <editorialgroup>
              <agency>ISO</agency>
              <agency>IEC</agency>
              <technical-committee type="A" number="34">Food products</technical-committee>
              <subcommittee type="B" number="4">Cereals and pulses</subcommittee>
              <workgroup type="C" number="3">Rice Group</workgroup>
              <secretariat>GB</secretariat>
            </editorialgroup>
            <approvalgroup>
              <agency>ISO</agency>
              <technical-committee type="Other" number="34a">Food products A</technical-committee>
              <subcommittee type="E" number="4a">Cereals and pulses A</subcommittee>
              <workgroup type="F" number="3a">Rice Group A</workgroup>
            </approvalgroup>
            <stagename>Committee draft</stagename>
          </ext>
        </bibdata>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <bibdata>
        <ext>
          <doctype language=''>international-standard</doctype>
          <doctype language='en'>International Standard</doctype>
          <horizontal>true</horizontal>
          <editorialgroup identifier='ISO/IEC/A 34/B 4/C 3'>
              <agency>ISO</agency>
              <agency>IEC</agency>
            <technical-committee type='A' number='34'>Food products</technical-committee>
            <subcommittee type='B' number='4'>Cereals and pulses</subcommittee>
            <workgroup type='C' number='3'>Rice Group</workgroup>
            <secretariat>GB</secretariat>
          </editorialgroup>
          <approvalgroup identifier='ISO/34a/E 4a/F 3a'>
              <agency>ISO</agency>
            <technical-committee type='Other' number='34a'>Food products A</technical-committee>
            <subcommittee type='E' number='4a'>Cereals and pulses A</subcommittee>
            <workgroup type='F' number='3a'>Rice Group A</workgroup>
          </approvalgroup>
          <stagename>Committee draft</stagename>
        </ext>
      </bibdata>
    OUTPUT
    expect(Xml::C14n.format(Nokogiri::XML(
      IsoDoc::Iso::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    )
      .at("//xmlns:bibdata").to_xml))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end
end
