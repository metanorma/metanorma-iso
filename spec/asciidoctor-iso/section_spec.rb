require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "processes sections" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      .Foreword

      Text

      == Introduction

      === Introduction Subsection

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

      == Terms and Definitions

      [appendix]
      == Annex

      === Annex A.1

      [%appendix]
      === Appendix 1

      == Bibliography

      === Bibliography Subsection
    INPUT
            #{BLANK_HDR}
       <preface><foreword obligation="informative">
         <title>Foreword</title>
         <p id="_">Text</p>
       </foreword><introduction id="_" obligation="informative"><title>Introduction</title><clause id="_" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction></preface><sections>
       <clause id="_" obligation="normative">
         <title>Scope</title>
         <p id="_">Text</p>
       </clause>

       <terms id="_" obligation="normative">
         <title>Terms and definitions</title>
         <term id="_">
         <preferred>Term1</preferred>
       </term>
       </terms>
       <clause id="_" obligation="normative"><title>Terms, definitions, symbols and abbreviated terms</title><terms id="_" obligation="normative">
         <title>Normal Terms</title>
         <term id="_">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="_"/></clause>
       <definitions id="_"/>
       <clause id="_" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="_" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="_" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>
       <clause id="_" inline-header="false" obligation="normative">
          <title>Terms and Definitions</title>
       </clause>


       </sections><annex id="_" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="_" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
       </clause>
       <appendix id="_" inline-header="false" obligation="normative">
          <title>Appendix 1</title>
       </appendix></annex><bibliography><references id="_" obligation="informative">
         <title>Normative References</title>
       </references><clause id="_" obligation="informative">
         <title>Bibliography</title>
         <references id="_" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    OUTPUT
  end

  it "processes sections with title attributes" do
    expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}
      .Foreword

      Text

      [heading=introduction]
      == Εισαγωγή

      === Introduction Subsection

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

      [%appendix]
      === Appendx 1

      [heading=bibliography]
      == Βιβλιογραφία

      === Bibliography Subsection
    INPUT
            #{BLANK_HDR}
       <preface>     
       <foreword obligation="informative">
         <title>Foreword</title>
         <p id="_">Text</p>
       </foreword>
       <introduction id="_" obligation="informative"><title>Introduction</title><clause id="_" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction>
       </preface>
       <sections>
       <clause id="_" obligation="normative">
         <title>Scope</title>
         <p id="_">Text</p>
       </clause>
     
       <terms id="_" obligation="normative">
         <title>Terms and definitions</title>
         <term id="_">
         <preferred>Term1</preferred>
       </term>
       </terms>
       <clause id="_" obligation="normative"><title>Terms and definitions</title><terms id="_" obligation="normative">
         <title>Normal Terms</title>
         <term id="_">
         <preferred>Term2</preferred>
       </term>
       </clause>
       <definitions id="_"/></terms>
       <definitions id="_"/>
       <clause id="_" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="_" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="_" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>
     
       </sections><annex id="_" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="_" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
       </clause>
       <appendix id="_" inline-header="false" obligation="normative">
         <title>Appendx 1</title>
       </appendix></annex><bibliography><references id="_" obligation="informative">
         <title>Normative References</title>
       </references><clause id="_" obligation="informative">
         <title>Bibliography</title>
         <references id="_" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
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
         <clause id="_" inline-header="false" obligation="informative">
         <title>Clause 1a</title>
       </clause>
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
         <clause id="_" inline-header="true" obligation="normative">
         <title>Clause 1a</title>
       </clause>
       </clause>
       </sections><annex id="_" inline-header="false" obligation="normative">
         <title>Annex A</title>
         <clause id="_" inline-header="true" obligation="normative">
         <title>Clause Aa</title>
       </clause>
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
         <clause id="_" inline-header="false" obligation="normative">
       </clause>
       </clause>
       </sections>
       </iso-standard>
     OUTPUT
  end

    it "processes term document sources" do
     expect(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      #{ASCIIDOC_BLANK_HDR}

      Foreword

      [source="iso1234,iso5678"]
      == Terms and Definitions

     INPUT
             #{BLANK_HDR}
             <termdocsource bibitemid="iso1234"/><termdocsource bibitemid="iso5678"/>
        <preface><foreword obligation="informative">
         <title>Foreword</title>
         <p id="_">Foreword</p>
       </foreword></preface><sections>
       <terms id="_" obligation="normative">
         <title>Terms and definitions</title>


       </terms></sections>
       </iso-standard>

     OUTPUT
    end

end
