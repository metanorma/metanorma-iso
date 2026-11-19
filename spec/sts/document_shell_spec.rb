# frozen_string_literal: true

require_relative "spec_helper"

# Document shell conformance: the NISO STS schema pins
# <standard dtd-version> to the fixed value "1.0", and <ics> is a plain
# string element on std-meta — typed models there would serialize their
# #to_s as content.
RSpec.describe "Document shell" do
  let(:xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">
          <title language="en" type="main">Test</title>
          <docidentifier>ISO 9999</docidentifier>
          <language>en</language>
          <ext>
            <ics><code>35.240.70</code></ics>
          </ext>
        </bibdata>
        <sections>
          <clause id="c1"><title>Scope</title><p id="p1">Scope text.</p></clause>
        </sections>
      </metanorma>
    XML
  end

  let(:sts) { Metanorma::Iso::Sts.convert(xml) }
  let(:doc) { Nokogiri::XML(sts) }

  it "pins dtd-version to the schema's fixed value" do
    expect(doc.root["dtd-version"]).to eq("1.0")
  end

  it "emits ics codes as plain string content" do
    ics = doc.at_xpath("//std-meta/ics")
    expect(ics).not_to be_nil
    expect(ics.text).to eq("35.240.70")
    expect(ics.text).not_to include("#<")
  end
end
