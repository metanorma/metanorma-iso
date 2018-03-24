require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "processes sections" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      .Foreword

      == Introduction

      === Introduction Subsection

      === Patent Notice

      == Scope

      Text

      == Normative References

      == Terms and Definitions

      === Term1

      == Terms, Definitions, Symbols and Abbreviated Terms

      === Normal Terms

      ==== Term2

      === Symbols and Abbreviated Terms

      == Symbols and Abbreviated Terms

      == Clause 4

      === Introduction

      === Clause 4.2

      [appendix]
      == Annex

      === Annex A.1

      == Bibliography

      === Bibliography Subsection
    INPUT
            #{BLANK_HDR}
       <introduction id="_" obligation="informative"><title>Introduction</title><subsection id="_" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </subsection>
       </introduction><sections>
       <clause id="_" obligation="normative">
         <title>Scope</title>
         <p id="_">Text</p>
       </clause>

       <terms id="_" obligation="normative">
         <title>Terms and Definitions</title>
         <term id="_">
         <preferred>Term1</preferred>
       </term>
       </terms>
       <clause id="_" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="_" obligation="normative">
         <title>Normal Terms</title>
         <term id="_">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <symbols-abbrevs id="_"/></clause>
       <symbols-abbrevs id="_"/>
       <clause id="_" inline-header="false" obligation="normative"><title>Clause 4</title><subsection id="_" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </subsection>
       <subsection id="_" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </subsection></clause>

       </sections><annex id="_" inline-header="false" obligation="normative">
         <title>Annex</title>
         <subsection id="_" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
       </subsection>
       </annex><references id="_" obligation="informative">
         <title>Normative References</title>
       </references><references id="_" obligation="informative">
         <title>Bibliography</title>
         <references id="_" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </references>
       </iso-standard>
    OUTPUT
  end

  it "processes sections with title attributes" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      .Foreword

      [heading=introduction]
      == Εισαγωγή

      === Introduction Subsection

      === Patent Notice

      [heading=scope]
      == Σκοπός

      Text

      [heading=normative references]
      == Κανονιστικές Παραπομπές

      [heading=terms and definitions]
      == Όροι και Ορισμοί

      === Term1

      [heading="terms, definitions, symbols and abbreviated terms"]
      == Όροι, Ορισμοί, Σύμβολα και Συντομογραφίες

      === Normal Terms

      ==== Term2

      [heading=symbols and abbreviated terms]
      === Σύμβολα και Συντομογραφίες

      [heading=symbols and abbreviated terms]
      == Σύμβολα και Συντομογραφίες

      == Clause 4

      === Introduction

      === Clause 4.2

      [appendix]
      == Annex

      === Annex A.1

      [heading=bibliography]
      == Βιβλιογραφία

      === Bibliography Subsection
    INPUT
            #{BLANK_HDR}
       <introduction id="_" obligation="informative"><title>Introduction</title><subsection id="_" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </subsection>
       </introduction><sections>
       <clause id="_" obligation="normative">
         <title>Scope</title>
         <p id="_">Text</p>
       </clause>
     
       <terms id="_" obligation="normative">
         <title>Terms and Definitions</title>
         <term id="_">
         <preferred>Term1</preferred>
       </term>
       </terms>
       <clause id="_" obligation="normative"><title>Terms and Definitions</title><terms id="_" obligation="normative">
         <title>Normal Terms</title>
         <term id="_">
         <preferred>Term2</preferred>
       </term>
       </clause>
       <symbols-abbrevs id="_"/></terms>
       <symbols-abbrevs id="_"/>
       <clause id="_" inline-header="false" obligation="normative"><title>Clause 4</title><subsection id="_" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </subsection>
       <subsection id="_" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </subsection></clause>
     
       </sections><annex id="_" inline-header="false" obligation="normative">
         <title>Annex</title>
         <subsection id="_" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
       </subsection>
       </annex><references id="_" obligation="informative">
         <title>Normative References</title>
       </references><references id="_" obligation="informative">
         <title>Bibliography</title>
         <references id="_" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </references>
       </iso-standard>
    OUTPUT
  end

  it "processes section obligations" do
     expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [obligation=informative]
      == Clause 1

      === Clause 1a

      [obligation=normative]
      == Clause 2

      [appendix,obligation=informative]
      == Annex
     INPUT
             #{BLANK_HDR}
       <sections><clause id="_" inline-header="false" obligation="informative">
         <title>Clause 1</title>
         <subsection id="_" inline-header="false" obligation="informative">
         <title>Clause 1a</title>
       </subsection>
       </clause>
       <clause id="_" inline-header="false" obligation="normative">
         <title>Clause 2</title>
       </clause>
       </sections><annex id="_" inline-header="false" obligation="informative">
         <title>Annex</title>
       </annex>
       </iso-standard>
     OUTPUT
  end

    it "processes inline headers" do
     expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      == Clause 1

      [%inline-header]
      === Clause 1a

      [appendix]
      == Annex A

      [%inline-header]
      === Clause Aa
     INPUT
             #{BLANK_HDR}
       <sections><clause id="_" inline-header="false" obligation="normative">
         <title>Clause 1</title>
         <subsection id="_" inline-header="true" obligation="normative">
         <title>Clause 1a</title>
       </subsection>
       </clause>
       </sections><annex id="_" inline-header="false" obligation="normative">
         <title>Annex A</title>
         <subsection id="_" inline-header="true" obligation="normative">
         <title>Clause Aa</title>
       </subsection>
       </annex>
       </iso-standard>
     OUTPUT
    end

  it "processes blank headers" do
     expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      == Clause 1

      === {blank}

     INPUT
             #{BLANK_HDR}
       <sections>
         <clause id="_" inline-header="false" obligation="normative">
         <title>Clause 1</title>
         <subsection id="_" inline-header="false" obligation="normative">
       </subsection>
       </clause>
       </sections>
       </iso-standard>
     OUTPUT
  end

    it "processes term document sources" do
     expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      [source="iso1234,iso5678"]
      == Terms and Definitions

     INPUT
             #{BLANK_HDR}
       <sections>
         <terms id="_" obligation="normative">
         <title>Terms and Definitions</title>
         <source type="inline" bibitemid="iso1234" citeas=""/>
         <source type="inline" bibitemid="iso5678" citeas=""/>
       </terms>
       </sections>
       </iso-standard>
     OUTPUT
    end

end
