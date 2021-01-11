require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "processes inline_quoted formatting" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true, agree_to_terms: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      _emphasis_
      *strong*
      `monospace`
      "double quote"
      'single quote'
      super^script^
      sub~script~
      stem:[a_90]
      stem:[<mml:math><mml:msub xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">F</mml:mi> </mml:mrow> </mml:mrow> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">&#x391;</mml:mi> </mml:mrow> </mml:mrow> </mml:msub> </mml:math>]
      [alt]#alt#
      [deprecated]#deprecated#
      [domain]#domain#
      [strike]#strike#
      [smallcap]#smallcap#
    INPUT
            #{BLANK_HDR}
       <sections>
         <em>emphasis</em>
       <strong>strong</strong>
       <tt>monospace</tt>
       “double quote”
       ‘single quote’
       super<sup>script</sup>
       sub<sub>script</sub>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow>
  <mi>a</mi>
</mrow>
<mrow>
  <mn>90</mn>
</mrow>
</msub></math></stem>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub> <mrow> <mrow> <mi mathvariant="bold-italic">F</mi> </mrow> </mrow> <mrow> <mrow> <mi mathvariant="bold-italic">Α</mi> </mrow> </mrow> </msub> </math></stem>
       <admitted>alt</admitted>
       <deprecates>deprecated</deprecates>
       <domain>domain</domain>
       <strike>strike</strike>
       <smallcap>smallcap</smallcap>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "processes breaks" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true, agree_to_terms: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      Line break +
      line break

      '''

      <<<
    INPUT
            #{BLANK_HDR}
       <sections><p id="_">Line break<br/>
       line break</p>
       <hr/>
       <pagebreak/></sections>
       </iso-standard>
    OUTPUT
  end

  it "processes links" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true, agree_to_terms: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      mailto:fred@example.com
      http://example.com[]
      http://example.com[Link]
    INPUT
            #{BLANK_HDR}
       <sections>
         <p id="_">mailto:fred@example.com
       <link target="http://example.com"/>
       <link target="http://example.com">Link</link></p>
       </sections>
       </iso-standard>
    OUTPUT
  end

    it "processes bookmarks" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true, agree_to_terms: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      Text [[bookmark]] Text
    INPUT
            #{BLANK_HDR}
       <sections>
         <p id="_">Text <bookmark id="bookmark"/> Text</p>
       </sections>
       </iso-standard>
    OUTPUT
    end

    it "processes crossreferences" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true, agree_to_terms: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [[reference]]
      == Section

      Inline Reference to <<reference>>
      Footnoted Reference to <<reference,fn>>
      Inline Reference with Text to <<reference,text>>
      Footnoted Reference with Text to <<reference,fn: text>>
    INPUT
       #{BLANK_HDR}
        <sections>
         <clause id="reference" inline-header="false" obligation="normative">
         <title>Section</title>
         <p id="_">Inline Reference to <xref target="reference"/>
       Footnoted Reference to <xref target="reference"/>
       Inline Reference with Text to <xref target="reference">text</xref>
       Footnoted Reference with Text to <xref target="reference">text</xref></p>
       </clause>
       </sections>
       </iso-standard>
      OUTPUT
    end

    it "processes bibliographic anchors" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true, agree_to_terms: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[ISO712,x]]] Reference
      * [[[ISO713]]] Reference

    INPUT
            #{BLANK_HDR}
       <sections>

       </sections><bibliography><references id="_" obligation="informative" normative="true">
         <title>Normative references</title>
         <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
         <bibitem id="ISO712">
         <formattedref format="application/x-isodoc+xml">Reference</formattedref>
         <docidentifier>x</docidentifier>
       </bibitem>
         <bibitem id="ISO713">
         <formattedref format="application/x-isodoc+xml">Reference</formattedref>
         <docidentifier>ISO713</docidentifier>
         <docnumber>713</docnumber>
       </bibitem>
       </references>
       </bibliography>
       </iso-standard>
    OUTPUT
  end

  it "processes footnotes" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true, agree_to_terms: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      Hello!footnote:[Footnote text]
    INPUT
            #{BLANK_HDR}
       <sections>
         <p id="_">Hello!<fn reference="1">
         <p id="_">Footnote text</p>
       </fn></p>
       </sections>
       </iso-standard>
    OUTPUT
  end


end
