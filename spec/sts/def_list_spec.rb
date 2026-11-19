# frozen_string_literal: true

require_relative "spec_helper"

# Regression: the native STS path crashed with
# NoMethodError (private method 'p') when building Sts::NisoSts::Def,
# because sts-ruby renamed the Def attribute from +p+ to +paragraph+
# (singular) and DefItem's from +def+ to +definition+. The unit specs
# above never exercised def-list building against the released gem.
RSpec.describe "DefList to STS conversion" do
  let(:xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">
          <title language="en" type="main">Test</title>
          <docidentifier>ISO 9999</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1"><title>Scope</title>
            <dl id="dl1">
              <dt id="dt1"><p>Term one</p></dt>
              <dd>
                <p id="p1">First definition.</p>
                <p id="p2">Second paragraph.</p>
              </dd>
              <dt id="dt2"><p>Term two</p></dt>
              <dd>
                <p id="p3">Definition with a list.</p>
                <ul id="ul1"><li><p>bullet one</p></li></ul>
              </dd>
            </dl>
          </clause>
        </sections>
      </metanorma>
    XML
  end

  let(:sts) { Metanorma::Iso::Sts.convert(xml) }
  let(:doc) { Nokogiri::XML(sts) }

  it "converts a def-list without raising" do
    expect { sts }.not_to raise_error
    expect(doc.at_xpath("//def-list")).not_to be_nil
  end

  it "maps dt/dd onto def-item/term/def" do
    items = doc.xpath("//def-list/def-item")
    expect(items.size).to eq(2)
    expect(items[0].at_xpath("./term")&.text).to eq("Term one")
    expect(items[0].at_xpath("./def/p")&.text).to include("First definition.")
  end

  it "merges multiple dd paragraphs into the single def p" do
    p = doc.at_xpath("//def-list/def-item[1]/def/p")
    expect(p.text).to include("First definition.")
    expect(p.text).to include("Second paragraph.")
  end

  it "attaches dd lists inside the def p" do
    p = doc.at_xpath("//def-list/def-item[2]/def/p")
    expect(p.at_xpath("./list")).not_to be_nil
    expect(p.text).to include("Definition with a list.")
    expect(p.at_xpath("./list/list-item")&.text).to include("bullet one")
  end
end
