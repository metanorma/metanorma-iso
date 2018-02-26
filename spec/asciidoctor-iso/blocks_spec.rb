require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "processes open blocks" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

      --
      x

      y

      z
      --
    INPUT
        #{BLANK_HDR}
       <sections><p id="_">x</p>
       <p id="_">y</p>
       <p id="_">z</p></sections>
       </iso-standard>
    OUTPUT
  end

  it "processes stem blocks" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

      [stem]
      ++++
      r = 1 % 
      r = 1 % 
      ++++
    INPUT
            #{BLANK_HDR}
       <sections>
         <formula id="_">
         <stem type="AsciiMath">r = 1 %
       r = 1 %</stem>
       </formula>
       </sections>
       </iso-standard>
    OUTPUT
  end

    it "ignores review blocks unless document is in draft mode" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

      [[foreword]]
      .Foreword
      Foreword

      [reviewer=ISO,date=20170101,from=foreword,to=foreword]
      ****
      A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.

      For further information on the Foreword, see *ISO/IEC Directives, Part 2, 2016, Clause 12.*
      ****
      INPUT
              #{BLANK_HDR}
       <sections><p id="foreword">Foreword</p>
       </sections>
       </iso-standard>
      OUTPUT
    end

  it "processes review blocks if document is in draft mode" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :draft: 1.2

      [[foreword]]
      .Foreword
      Foreword

      [reviewer=ISO,date=20170101,from=foreword,to=foreword]
      ****
      A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.

      For further information on the Foreword, see *ISO/IEC Directives, Part 2, 2016, Clause 12.*
      ****
      INPUT
              #{BLANK_HDR}
       <version>
         <draft>1.2</draft>
       </version>
       <sections><p id="foreword">Foreword</p>
       <review reviewer="ISO" id="_" date="20170101T0000" from="foreword" to="foreword"><p id="_">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
       <p id="_">For further information on the Foreword, see <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong></p></review></sections>
       </iso-standard>

      OUTPUT
  end


end
