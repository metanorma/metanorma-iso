require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "processes open blocks" do
    expect(strip_guid(Asciidoctor.convert(<<~'INPUT', backend: :iso, header_footer: true))).to be_equivalent_to <<~'OUTPUT'
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
    OUTPUT
  end
end
