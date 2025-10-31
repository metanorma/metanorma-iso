require "spec_helper"

RSpec.describe Metanorma::Iso do
  it "processes inline_quoted formatting" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [alt]#alt#
      [deprecated]#deprecated#
      [domain]#domain#
      [strike]#strike#
      [smallcap]#smallcap#
    INPUT
    output = <<~OUTPUT
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
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes breaks" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      Line break +
      line break

      '''

      <<<
    INPUT
    output = <<~OUTPUT
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
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes links" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      mailto:fred@example.com
      http://example.com[]
      http://example.com[Link]
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <p id="_">mailto:fred@example.com

            <link target="http://example.com"/>
            <link target="http://example.com">Link</link></p>
        </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes bookmarks" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      Text [[bookmark]] Text
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <p id="_">Text <bookmark id="_" anchor="bookmark"/> Text</p>
        </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes crossreferences" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [[reference]]
      == Section

      Inline Reference to <<reference>>
      Footnoted Reference to <<reference,fn>>
      Inline Reference with Text to <<reference,text>>
      Footnoted Reference with Text to <<reference,fn: text>>
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" anchor="reference" inline-header="false" obligation="normative">
            <title id="_">Section</title>
            <p id="_">Inline Reference to <xref target="reference"/>
              Footnoted Reference to <xref target="reference"/>
              Inline Reference with Text to <xref target="reference"><display-text>text</display-text></xref>
              Footnoted Reference with Text to <xref target="reference"><display-text>text</display-text></xref></p>
          </clause>
        </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes bibliographic anchors" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [bibliography]
      == Normative References

      * [[[ISO712,x]]] Reference
      * [[[ISO713]]] Reference

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>

        </sections>
        <bibliography>
          <references id="_" normative="true" obligation="informative">
            <title id="_">Normative references</title>
            <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
            <bibitem id="_" anchor="ISO712">
              <formattedref format="application/x-isodoc+xml">Reference</formattedref>
              <docidentifier>x</docidentifier>
              <language>en</language>
              <script>Latn</script>
            </bibitem>
            <bibitem id="_" anchor="ISO713">
              <formattedref format="application/x-isodoc+xml">Reference</formattedref>
              <docidentifier>ISO713</docidentifier>
              <docnumber>713</docnumber>
              <language>en</language>
              <script>Latn</script>
            </bibitem>
          </references>
        </bibliography>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes footnotes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      Hello!footnote:[Footnote text]
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <p id="_">Hello!
            <fn id="_" reference="1">
              <p id="_">Footnote text</p></fn>
          </p>
        </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
