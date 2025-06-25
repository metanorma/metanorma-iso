require "spec_helper"

RSpec.describe Metanorma::Iso do
  it "processes open blocks" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      --
      x

      y

      z
      --
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <p id="_">x</p>
          <p id="_">y</p>
          <p id="_">z</p>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes review blocks if  document is not in draft mode" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [[foreword]]
      .Foreword
      Foreword

      [reviewer=ISO,date=20170101,from=foreword,to=foreword]
      ****
      A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.

      For further information on the Foreword, see *ISO/IEC Directives, Part 2, 2016, Clause 12.*
      ****
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
          <sections>
             <p id="_" anchor="foreword">Foreword</p>
          </sections>
          <annotation-container>
             <annotation id="_" reviewer="ISO" date="20170101T00:00:00Z" type="review" from="foreword" to="foreword">
                <p id="_">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
                <p id="_">
                   For further information on the Foreword, see
                   <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong>
                </p>
             </annotation>
          </annotation-container>
       </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes review blocks if document is in draft mode" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :draft: 1.2
      :no-isobib:

      [[foreword]]
      .Foreword
      Foreword

      [reviewer=ISO,date=20170101,from=foreword,to=foreword]
      ****
      A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.

      For further information on the Foreword, see *ISO/IEC Directives, Part 2, 2016, Clause 12.*
      ****
    INPUT
    output = <<~OUTPUT
       <metanorma>
          <sections>
             <p id="_" anchor="foreword">Foreword</p>
          </sections>
          <annotation-container>
             <annotation id="_" reviewer="ISO" date="20170101T00:00:00Z" type="review" from="foreword" to="foreword">
                <p id="_">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
                <p id="_">
                   For further information on the Foreword, see
                   <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong>
                </p>
             </annotation>
          </annotation-container>
       </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(input)
      .sub(/^.+<sections>/m, "<metanorma><sections>")))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes term notes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      NOTE: This is a note
    INPUT
    output = <<~OUTPUT
        #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title id="_">Terms and definitions</title>
            #{TERM_BOILERPLATE}
            <term id="_" anchor="term-Term1">
              <preferred><expression><name>Term1</name></expression></preferred>
              <termnote id="_">
                <p id="_">This is a note</p></termnote>
            </term>
          </terms>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes notes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      NOTE: This is a note
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
        <note id="_">
          <p id="_">This is a note</p>
        </note>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes literals" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      ....
      LITERAL
      ....
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <figure id="_">
            <pre id="_">LITERAL</pre>
          </figure>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes simple admonitions with Asciidoc names" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      CAUTION: Only use paddy or parboiled rice for the determination of husked rice yield.
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <admonition id="_" type="caution">
            <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
          </admonition>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes editorial notes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [IMPORTANT,type=editorial]
      ====
      Editorial note
      ====
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <admonition id="_" type="editorial">
            <p id="_">Editorial note</p>
          </admonition>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes complex admonitions with non-Asciidoc names" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [CAUTION,type=Safety Precautions]
      .Safety Precautions
      ====
      While werewolves are hardy community members, keep in mind the following dietary concerns:

      . They are allergic to cinnamon.
      . More than two glasses of orange juice in 24 hours makes them howl in harmony with alarms and sirens.
      . Celery makes them sad.
      ====
    INPUT
    output = <<~OUTPUT
        #{BLANK_HDR}
        <sections>
          <admonition id="_" type="safety precautions">
            <name id="_">Safety Precautions</name>
            <p id="_">While werewolves are hardy community members, keep in mind the following dietary concerns:</p>
            <ol id="_">
              <li>
                <p id="_">They are allergic to cinnamon.</p>
              </li>
              <li>
                <p id="_">More than two glasses of orange juice in 24 hours makes them howl in harmony with alarms and sirens.</p>
              </li>
              <li>
                <p id="_">Celery makes them sad.</p>
              </li>
            </ol>
          </admonition>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes term examples" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      [example]
      This is an example
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title id="_">Terms and definitions</title>
            #{TERM_BOILERPLATE}
            <term id="_" anchor="term-Term1">
              <preferred><expression><name>Term1</name></expression></preferred>
              <termexample id="_">
                <p id="_">This is an example</p></termexample>
            </term>
          </terms>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes examples" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [example]
      ====
      This is an example

      Amen
      ====
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <example id="_">
            <p id="_">This is an example</p>
            <p id="_">Amen</p>
          </example>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes preambles" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <preface>
          <foreword id="_" obligation="informative">
            <title id="_">Foreword</title>
            <p id="_">This is a preamble</p>
          </foreword>
        </preface>
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title id="_">Section 1</title>
          </clause>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes images" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      .Split-it-right sample divider
      image::spec/examples/rice_images/rice_image1.png[]

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <figure id="_">
            <name id="_">Split-it-right sample divider</name>
            <image height="auto" id="_" mimetype="image/png" src="spec/examples/rice_images/rice_image1.png" width="auto"/>
          </figure>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "accepts width and height attributes on images" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [height=4,width=3]
      image::spec/examples/rice_images/rice_image1.png[]

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <figure id="_" width="3">
            <image height="4" id="_" mimetype="image/png" src="spec/examples/rice_images/rice_image1.png" width="3"/>
          </figure>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "accepts auto for width and height attributes on images" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [height=4,width=auto]
      image::spec/examples/rice_images/rice_image1.png[]

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <figure id="_"  width="auto">
            <image height="4" id="_" mimetype="image/png" src="spec/examples/rice_images/rice_image1.png" width="auto"/>
          </figure>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "accepts alignment attribute on paragraphs" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [align=right]
      This para is right-aligned.
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
           <p align="right" id="_">This para is right-aligned.</p>
         </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes blockquotes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [quote, ISO, "ISO7301,section 1"]
      ____
      Block quotation
      ____
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <quote id="_">
            <source bibitemid="ISO7301" citeas="" type="inline">
              <localityStack>
                <locality type="section">
                  <referenceFrom>1</referenceFrom>
                </locality>
              </localityStack>
            </source>
            <author>ISO</author>
            <p id="_">Block quotation</p>
          </quote>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes unmodified term sources" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      Definition

      [.source]
      <<ISO2191,section=1>>
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title id="_">Terms and definitions</title>
            #{TERM_BOILERPLATE}
            <term id="_" anchor="term-Term1">
              <preferred><expression><name>Term1</name></expression></preferred>
                      <definition id="_">
          <verbal-definition id="_">
            <p id='_'>Definition</p>
          </verbal-definition>
        </definition>
        <source status='identical' type='authoritative'>
                <origin bibitemid="ISO2191" citeas="" type="inline">
                  <localityStack>
                    <locality type="section">
                      <referenceFrom>1</referenceFrom></locality>
                  </localityStack>
                </origin>
              </source>
            </term>
          </terms>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes modified term sources" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      Definition

      [.source]
      <<ISO2191,section=1>>, with adjustments
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <terms id="_" obligation="normative">
            <title id="_">Terms and definitions</title>
            #{TERM_BOILERPLATE}
            <term id="_" anchor="term-Term1">
              <preferred><expression><name>Term1</name></expression></preferred>
                      <definition id="_">
          <verbal-definition id="_">
            <p id='_'>Definition</p>
          </verbal-definition>
        </definition>
        <source status='modified' type='authoritative'>
                <origin bibitemid="ISO2191" citeas="" type="inline">
                  <localityStack>
                    <locality type="section">
                      <referenceFrom>1</referenceFrom></locality>
                  </localityStack>
                </origin>
                <modification>
                  <p id="_">with adjustments</p>
                </modification>
              </source>
            </term>
          </terms>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
