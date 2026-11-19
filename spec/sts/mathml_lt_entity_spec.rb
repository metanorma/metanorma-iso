# frozen_string_literal: true

require_relative "spec_helper"
require "sts"
require "mml"

# Regression spec: lock in the round-trip behaviour for STS documents
# that nest MathML inside mixed_content parents (the OIML sts-guidelines
# shape: a paragraph with an inline-formula whose <mml:math> contains
# a <mo>&lt;</mo> operator).
#
# Background: an earlier workaround (LT_SENTINEL, removed in this PR)
# shielded "<mo>&lt;</mo>" from what was believed to be a lutaml-model
# mixed_content parser bug. The mml team verified on mml 2.4.0 +
# lutaml-model 0.8.17 + nokogiri 1.19.2 that no such bug exists — the
# round-trip preserves the entity correctly. These specs lock that
# contract in at the OIML STS layer.
RSpec.describe "MathML <mo>&lt;</mo> round-trip through Sts::NisoSts::Standard" do
  let(:document_with_lt) do
    <<~XML.freeze
      <?xml version="1.0" encoding="UTF-8"?>
      <standard xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML">
        <body>
          <sec>
            <p>For values of x where x <inline-formula>
              <mml:math>
                <mml:mi>x</mml:mi>
                <mml:mo>&lt;</mml:mo>
                <mml:mn>5</mml:mn>
              </mml:math>
            </inline-formula> 5, the result holds.</p>
          </sec>
        </body>
      </standard>
    XML
  end

  # The mo element may serialise with or without the mml: prefix
  # depending on namespace registration state — what matters is that
  # the &lt; entity survives as the element's content.
  def mo_content(roundtripped)
    match = roundtripped.match(/<(?:mml:)?mo[^>]*>([^<]*)<\/(?:mml:)?mo>/)
    match && match[1]
  end

  it "preserves the &lt; entity as the mo element's content" do
    parsed = Sts::NisoSts::Standard.from_xml(document_with_lt)
    roundtripped = parsed.to_xml
    expect(mo_content(roundtripped)).to eq("&lt;")
  end

  it "preserves multiple operators in sequence" do
    doc = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <standard xmlns:mml="http://www.w3.org/1998/Math/MathML">
        <body><sec><p>
          <inline-formula><mml:math>
            <mml:mi>a</mml:mi>
            <mml:mo>&lt;</mml:mo>
            <mml:mi>b</mml:mi>
            <mml:mo>&gt;</mml:mo>
            <mml:mi>c</mml:mi>
          </mml:math></inline-formula>
        </p></sec></body>
      </standard>
    XML
    parsed = Sts::NisoSts::Standard.from_xml(doc)
    roundtripped = parsed.to_xml
    # Extract all mo contents
    contents = roundtripped.scan(/<(?:mml:)?mo[^>]*>([^<]*)<\/(?:mml:)?mo>/).flatten
    expect(contents).to include("&lt;", "&gt;")
  end

  it "preserves the lt entity when interleaved with text content" do
    doc = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <standard xmlns:mml="http://www.w3.org/1998/Math/MathML">
        <body><sec><p>before <inline-formula>
          <mml:math><mml:mo>&lt;</mml:mo></mml:math>
        </inline-formula> after</p></sec></body>
      </standard>
    XML
    parsed = Sts::NisoSts::Standard.from_xml(doc)
    expect(mo_content(parsed.to_xml)).to eq("&lt;")
  end
end
