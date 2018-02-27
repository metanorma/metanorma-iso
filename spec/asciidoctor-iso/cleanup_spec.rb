require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "removes empty text elements" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

      == {blank}
    INPUT
       #{BLANK_HDR}
              <sections>
         <clause id="_" inline-header="false" obligation="normative">
         
       </clause>
       </sections>
       </iso-standard>
    OUTPUT
  end
end
