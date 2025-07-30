require "spec_helper"

RSpec.describe Metanorma::Iso do
  it "processes sections" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Foreword

      Text

      == Introduction

      === Introduction Subsection

      == Acknowledgements

      == Scope

      Text

      == Normative References

      == Terms, Definitions, Symbols and Abbreviated Terms

      === Normal Terms

      ==== Term2

      === Symbols and Abbreviated Terms

      == Symbols and Abbreviated Terms

      == Clause 4

      === Introduction

      === Clause 4.2

      == Terms and Definitions

      [appendix]
      == Annex

      === Annex A.1

      [%appendix]
      === Appendix 1

      ==== Appendix subclause

      == Bibliography

      === Bibliography Subsection
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
          <preface>
             <foreword id="_" obligation="informative">
                <title id="_">Foreword</title>
                <p id="_">Text</p>
             </foreword>
             <introduction id="_" obligation="informative">
                <title id="_">Introduction</title>
                <clause id="_" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                </clause>
             </introduction>
             <acknowledgements id="_" obligation="informative">
                <title id="_">Acknowledgements</title>
             </acknowledgements>
          </preface>
          <sections>
             <clause id="_" type="scope" inline-header="false" obligation="normative">
                <title id="_">Scope</title>
                <p id="_">Text</p>
             </clause>
             <clause id="_" obligation="normative" type="terms">
                <title id="_">Terms, definitions, symbols and abbreviated terms</title>
                <terms id="_" obligation="normative">
                   <title id="_">Terms and definitions</title>
                   <p id="_">For the purposes of this document, the following terms and definitions apply.</p>
                   <p id="_">ISO and IEC maintain terminology databases for use in standardization at the following addresses:</p>
                   <ul id="_">
                      <li>
                         <p id="_">
                            ISO Online browsing platform: available at
                            <link target="https://www.iso.org/obp"/>
                         </p>
                      </li>
                      <li>
                         <p id="_">
                            IEC Electropedia: available at
                            <link target="https://www.electropedia.org"/>
                         </p>
                      </li>
                   </ul>
                   <term id="_" anchor="term-Term2">
                      <preferred>
                         <expression>
                            <name>Term2</name>
                         </expression>
                      </preferred>
                   </term>
                </terms>
                <definitions id="_" obligation="normative">
                   <title id="_">Symbols and Abbreviated Terms</title>
                </definitions>
             </clause>
             <definitions id="_" obligation="normative">
                <title id="_">Symbols and Abbreviated Terms</title>
             </definitions>
             <clause id="_" inline-header="false" obligation="normative">
                <title id="_">Clause 4</title>
                <clause id="_" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                </clause>
                <clause id="_" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                </clause>
             </clause>
             <terms id="_" obligation="normative">
                <title id="_">Terms and Definitions</title>
             </terms>
          </sections>
          <annex id="_" inline-header="false" obligation="normative">
             <title id="_">Annex</title>
             <clause id="_" inline-header="false" obligation="normative">
                <title id="_">Annex A.1</title>
             </clause>
             <appendix id="_" inline-header="false" obligation="normative">
                <title id="_">Appendix 1</title>
                <clause id="_" inline-header="false" obligation="normative">
                   <title id="_">Appendix subclause</title>
                </clause>
             </appendix>
          </annex>
          <bibliography>
             <references id="_" normative="true" obligation="informative">
                <title id="_">Normative references</title>
                <p id="_">There are no normative references in this document.</p>
             </references>
             <clause id="_" obligation="informative">
                <title id="_">Bibliography</title>
                <references id="_" normative="false" obligation="informative">
                   <title id="_">Bibliography Subsection</title>
                </references>
             </clause>
          </bibliography>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes section obligations" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [obligation=informative]
      == Clause 1

      === Clause 1a

      [obligation=normative]
      == Clause 2

      [appendix,obligation=informative]
      == Annex
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="informative">
            <title id="_">Clause 1</title>
            <clause id="_" inline-header="false" obligation="informative">
              <title id="_">Clause 1a</title>
            </clause>
          </clause>
          <clause id="_" inline-header="false" obligation="normative">
            <title id="_">Clause 2</title>
          </clause>
        </sections>
        <annex id="_" inline-header="false" obligation="informative">
          <title id="_">Annex</title>
        </annex>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes inline headers" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Clause 1

      [%inline-header]
      === Clause 1a

      [appendix]
      == Annex A

      [%inline-header]
      === Clause Aa
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title id="_">Clause 1</title>
            <clause id="_" inline-header="true" obligation="normative">
              <title id="_">Clause 1a</title>
            </clause>
          </clause>
        </sections>
        <annex id="_" inline-header="false" obligation="normative">
          <title id="_">Annex A</title>
          <clause id="_" inline-header="true" obligation="normative">
            <title id="_">Clause Aa</title>
          </clause>
        </annex>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes blank headers" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Clause 1

      === {blank}

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title id="_">Clause 1</title>
            <clause id="_" inline-header="false" obligation="normative"/>
          </clause>
        </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes terms & definitions with external source" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      Foreword

      [source="iso1234,iso5678"]
      == Terms and Definitions

      === Term1

      [bibliography]
      == Bibliography
      * [[[iso1234,A]]]
      * [[[iso5678,B]]]
    INPUT
    output = <<~OUTPUT
        #{BLANK_HDR.sub(/<boilerplate>/, '<termdocsource bibitemid="iso1234"/><termdocsource bibitemid="iso5678"/><boilerplate>')}
        <preface>
          <foreword id="_" obligation="informative">
            <title id="_">Foreword</title>
            <p id="_">Foreword</p>
          </foreword>
        </preface>
                  <sections>
             <terms id="_" obligation="normative">
                <title id="_">Terms and definitions</title>
                <p id="_">
                   For the purposes of this document, the terms and definitions given in
                   <eref bibitemid="iso1234" citeas="A"/>
                   and
                   <eref bibitemid="iso5678" citeas="B"/>
                   and the following apply.
                </p>
                <p id="_">ISO and IEC maintain terminology databases for use in standardization at the following addresses:</p>
                <ul id="_">
                   <li>
                      <p id="_">
                         ISO Online browsing platform: available at
                         <link target="https://www.iso.org/obp"/>
                      </p>
                   </li>
                   <li>
                      <p id="_">
                         IEC Electropedia: available at
                         <link target="https://www.electropedia.org"/>
                      </p>
                   </li>
                </ul>
                <term id="_" anchor="term-Term1">
                   <preferred>
                      <expression>
                         <name>Term1</name>
                      </expression>
                   </preferred>
                </term>
             </terms>
          </sections>
          <bibliography>
             <references id="_" normative="false" obligation="informative">
                <title id="_">Bibliography</title>
                <bibitem id="_" anchor="iso1234">
                   <formattedref format="application/x-isodoc+xml">[NO INFORMATION AVAILABLE]</formattedref>
                   <docidentifier>A</docidentifier>
                </bibitem>
                <bibitem id="_" anchor="iso5678">
                   <formattedref format="application/x-isodoc+xml">[NO INFORMATION AVAILABLE]</formattedref>
                   <docidentifier>B</docidentifier>
                </bibitem>
             </references>
          </bibliography>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes empty terms & definitions" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      Foreword

      == Terms and Definitions


    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <preface>
          <foreword id="_" obligation="informative">
            <title id="_">Foreword</title>
            <p id="_">Foreword</p>
          </foreword>
        </preface>
        <sections>
          <terms id='_' obligation='normative'>
            <title id="_">Terms and definitions</title>
            <p id='_'>No terms and definitions are listed in this document.</p>
            <p id='_'>
              ISO and IEC maintain terminology databases for use in standardization
              at the following addresses:
            </p>
            <ul id='_'>
              <li>
                <p id='_'>
                  ISO Online browsing platform: available at
                  <link target='https://www.iso.org/obp'/>
                </p>
              </li>
              <li>
                <p id='_'>
                  IEC Electropedia: available at
                  <link target='https://www.electropedia.org'/>
                </p>
              </li>
            </ul>
          </terms>
        </sections>
      </metanorma>

    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes empty terms & definitions with external source" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      Foreword

      [source="iso1234,iso5678"]
      == Terms and Definitions

      [bibliography]
      == Bibliography
      * [[[iso1234,A]]]
      * [[[iso5678,B]]]
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR.sub(/<boilerplate>/, '<termdocsource bibitemid="iso1234"/><termdocsource bibitemid="iso5678"/><boilerplate>')}
        <preface>
          <foreword id="_" obligation="informative">
            <title id="_">Foreword</title>
            <p id="_">Foreword</p>
          </foreword>
        </preface>
                  <sections>
             <terms id="_" obligation="normative">
                <title id="_">Terms and definitions</title>
                <p id="_">
                   For the purposes of this document, the terms and definitions given in
                   <eref bibitemid="iso1234" citeas="A"/>
                   and
                   <eref bibitemid="iso5678" citeas="B"/>
                   apply.
                </p>
                <p id="_">ISO and IEC maintain terminology databases for use in standardization at the following addresses:</p>
                <ul id="_">
                   <li>
                      <p id="_">
                         ISO Online browsing platform: available at
                         <link target="https://www.iso.org/obp"/>
                      </p>
                   </li>
                   <li>
                      <p id="_">
                         IEC Electropedia: available at
                         <link target="https://www.electropedia.org"/>
                      </p>
                   </li>
                </ul>
             </terms>
          </sections>
          <bibliography>
             <references id="_" normative="false" obligation="informative">
                <title id="_">Bibliography</title>
                <bibitem id="_" anchor="iso1234">
                   <formattedref format="application/x-isodoc+xml">[NO INFORMATION AVAILABLE]</formattedref>
                   <docidentifier>A</docidentifier>
                </bibitem>
                <bibitem id="_" anchor="iso5678">
                   <formattedref format="application/x-isodoc+xml">[NO INFORMATION AVAILABLE]</formattedref>
                   <docidentifier>B</docidentifier>
                </bibitem>
             </references>
          </bibliography>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  xit "ignores multiple terms & definitions in default documents" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      == Terms and Definitions

      == Clause

      [heading=terms and definitions]
      == More terms

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
               <sections>
           <terms id='_' obligation='normative'>
             <title id="_">Terms and definitions</title>
             <p id='_'>No terms and definitions are listed in this document.</p>
             <p id='_'>
               ISO and IEC maintain terminology databases for use in standardization
               at the following addresses:
             </p>
             <ul id='_'>
               <li>
                 <p id='_'>
                   ISO Online browsing platform: available at
                   <link target='https://www.iso.org/obp'/>
                 </p>
               </li>
               <li>
                 <p id='_'>
                   IEC Electropedia: available at
                   <link target='https://www.electropedia.org'/>
                 </p>
               </li>
             </ul>
           </terms>
           <clause id='_' inline-header='false' obligation='normative'>
             <title id="_">Clause</title>
           </clause>
           <clause id='_' inline-header='false' obligation='normative'>
             <title id="_">More terms</title>
           </clause>
         </sections>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "permits multiple terms & definitions in vocabulary documents" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR.sub(/:nodoc:/, ":nodoc:\n:docsubtype: vocabulary")}

      == Terms and Definitions

      == Clause

      [heading=terms and definitions]
      == More terms

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR.sub(%r{<doctype>standard</doctype>},
                      '<doctype>standard</doctype><subdoctype>vocabulary</subdoctype>')}
               <sections>
           <terms id='_' obligation='normative'>
             <title id="_">Terms and Definitions</title>
             <p id='_'>No terms and definitions are listed in this document.</p>
             <p id='_'>ISO and IEC maintain terminology databases for use in standardization
               at the following addresses:
             </p>
             <ul id='_'>
               <li>
                 <p id='_'>ISO Online browsing platform: available at
                   <link target='https://www.iso.org/obp'/>
                 </p>
               </li>
               <li>
                 <p id='_'>IEC Electropedia: available at
                   <link target='https://www.electropedia.org'/>
                 </p>
               </li>
             </ul>
           </terms>
           <clause id='_' inline-header='false' obligation='normative'>
             <title id="_">Clause</title>
           </clause>
           <terms id='_' obligation='normative'>
             <title id="_">More terms</title>
           </terms>
         </sections>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
