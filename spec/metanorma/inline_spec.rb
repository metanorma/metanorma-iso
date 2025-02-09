require "spec_helper"

RSpec.describe Metanorma::Iso do
  it "processes inline_quoted formatting" do
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [alt]#alt#
      [deprecated]#deprecated#
      [domain]#domain#
      [strike]#strike#
      [smallcap]#smallcap#
    INPUT
      #{BLANK_HDR}
        <sections>
          <admitted>
            <expression>
              <name>alt</name>
            </expression>
          </admitted>
          <deprecates>
            <expression>
              <name>deprecated</name>
            </expression>
          </deprecates>
          <domain>domain</domain>
          <strike>strike</strike>
          <smallcap>smallcap</smallcap>
        </sections>
      </metanorma>
    OUTPUT
  end

  it "processes breaks" do
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      Line break +
      line break

      '''

      <<<
    INPUT
      #{BLANK_HDR}
        <sections>
          <p id="_">Line break
            <br/>
            line break</p>
          <hr/>
          <pagebreak/>
        </sections>
      </metanorma>
    OUTPUT
  end

  it "processes links" do
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
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
      </metanorma>
    OUTPUT
  end

  it "processes bookmarks" do
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      Text [[bookmark]] Text
    INPUT
      #{BLANK_HDR}
        <sections>
          <p id="_">Text <bookmark id="bookmark"/> Text</p>
        </sections>
      </metanorma>
    OUTPUT
  end

  it "processes crossreferences" do
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
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
      </metanorma>
    OUTPUT
  end

  it "processes bibliographic anchors" do
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[ISO712,x]]] Reference
      * [[[ISO713]]] Reference

    INPUT
      #{BLANK_HDR}
        <sections>

        </sections>
        <bibliography>
          <references id="_" normative="true" obligation="informative">
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
      </metanorma>
    OUTPUT
  end

  it "processes footnotes" do
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      Hello!footnote:[Footnote text]
    INPUT
      #{BLANK_HDR}
        <sections>
          <p id="_">Hello!
            <fn reference="1">
              <p id="_">Footnote text</p></fn>
          </p>
        </sections>
      </metanorma>
    OUTPUT
  end
end
