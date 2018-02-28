require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "processes simple ISO reference" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

      [bibliography]
      == Normative References

      * [[[iso123,ISO 123]]] _Standard_
    INPUT
       #{BLANK_HDR}
              <sections>
       </sections><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso123" type="standard">
         <title format="text/plain">Standard</title>
         <docidentifier>ISO 123</docidentifier>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>ISO</name>
           </organization>
         </contributor>
       </bibitem>
       </references>
       </iso-standard>
    OUTPUT
  end

  it "processes simple IEC reference" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

      [bibliography]
      == Normative References

      * [[[iso123,IEC 123]]] _Standard_
    INPUT
       #{BLANK_HDR}
              <sections>
       </sections><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso123" type="standard">
         <title format="text/plain">Standard</title>
         <docidentifier>IEC 123</docidentifier>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>IEC</name>
           </organization>
         </contributor>
       </bibitem>
       </references>
       </iso-standard>
    OUTPUT
  end

  it "processes dated ISO reference" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:1066]]] _Standard_
    INPUT
       #{BLANK_HDR}
              <sections>
              </sections><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso123" type="standard">
         <title format="text/plain">Standard</title>
         <docidentifier>ISO 123</docidentifier>
         <date type="published">1066</date>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>ISO</name>
           </organization>
         </contributor>
       </bibitem>
       </references>
       </iso-standard>
    OUTPUT
  end

  it "processes draft ISO reference" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:--]]] footnote:[The standard is in press] _Standard_
    INPUT
       #{BLANK_HDR}
       <sections>
              </sections><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso123" type="standard">
         <title format="text/plain">Standard</title>
         <docidentifier>ISO 123</docidentifier>
         <date type="published">--</date>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>ISO</name>
           </organization>
         </contributor>
         <note format="text/plain" reference="1">ISO DATE: The standard is in press</note>
       </bibitem>
       </references>
       </iso-standard>
    OUTPUT
  end

  it "processes all-parts ISO reference" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:1066 (all parts)]]] _Standard_
    INPUT
       #{BLANK_HDR}
              <sections>
         
       </sections><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso123" type="standard">
         <title format="text/plain">Standard</title>
         <docidentifier>ISO 123:All Parts</docidentifier>
         <date type="published">1066</date>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>ISO</name>
           </organization>
         </contributor>
       </bibitem>
       </references>
       </iso-standard>
    OUTPUT
  end

  it "processes non-ISO reference in Normative References" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

      [bibliography]
      == Normative References

      * [[[iso123,XYZ 123:1066 (all parts)]]] _Standard_
    INPUT
       #{BLANK_HDR}
              <sections>
         
       </sections><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="iso123">
         <formattedref format="application/x-isodoc+xml">
           <em>Standard</em>
         </formattedref>
         <docidentifier>XYZ 123:1066 (all parts)</docidentifier>
       </bibitem>
       </references>
       </iso-standard>
    OUTPUT
  end

  it "processes non-ISO reference in Bibliography" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

      [bibliography]
      == Bibliography

      * [[[iso123,1]]] _Standard_
    INPUT
       #{BLANK_HDR}
              <sections>
         
       </sections><references id="_" obligation="informative">
         <title>Bibliography</title>
         <bibitem id="iso123">
         <formattedref format="application/x-isodoc+xml">
           <em>Standard</em>
         </formattedref>
         <docidentifier>[1]</docidentifier>
       </bibitem>
       </references>
       </iso-standard>
    OUTPUT
  end



end
