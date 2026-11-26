# frozen_string_literal: true

require_relative "spec_helper"

# A legacy presentation table names itself "Table N — title" with no autonum;
# the STS label is the "Table N" part and the caption title is the rest.
RSpec.describe "table label split" do
  let(:xml) do
    <<~XML
      <metanorma>
        <bibdata>
          <title language="en" type="main">T</title>
          <docidentifier>ISO 1:2025</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1">
            <title>Body</title>
            <table id="tb1">
              <name>Table 2 — Parts of a provision class</name>
              <tbody>
                <tr><th>H</th><td>Cell</td></tr>
              </tbody>
            </table>
          </clause>
        </sections>
      </metanorma>
    XML
  end

  let(:doc) { Nokogiri::XML(Metanorma::Iso::Sts.convert(xml)) }

  it "moves the leading table number into <label>" do
    expect(doc.at("//body//table-wrap/label").text).to eq("Table 2")
  end

  it "keeps the remainder of the name as the caption title" do
    expect(doc.at("//body//table-wrap/caption/title").text).to eq("Parts of a provision class")
  end

  context "when the source name uses a non-breaking space after Table" do
    let(:xml) { super().sub("Table 2 —", "Table\u00A02 —") }

    it "still splits the label and title" do
      expect(doc.at("//body//table-wrap/label").text).to eq("Table\u00A02")
    end
  end
end
