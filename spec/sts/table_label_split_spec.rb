# frozen_string_literal: true

require_relative "spec_helper"

# A legacy presentation table names itself "Table N — title" with no autonum;
# the STS label is the "Table N" part and the caption title is the rest.
# The NBSP processor joins "Table" to its number in every text node, so the
# expected label and any unsplit title carry U+00A0 after "Table".
RSpec.describe "table label split" do
  let(:name) { "Table 2 — Parts of a provision class" }

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
              <name>#{name}</name>
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
  let(:label) { doc.at("//body//table-wrap/label")&.text }
  let(:title) { doc.at("//body//table-wrap/caption/title")&.text }

  it "moves the leading table number into <label>" do
    expect(label).to eq("Table 2")
  end

  it "keeps the remainder of the name as the caption title" do
    expect(title).to eq("Parts of a provision class")
  end

  context "when the source name uses a non-breaking space after Table" do
    let(:name) { "Table 2 — Parts of a provision class" }

    it "still splits the label and title" do
      expect([label, title]).to eq(["Table 2", "Parts of a provision class"])
    end
  end

  context "when the title itself contains an em dash" do
    let(:name) { "Table 2 — Parts — of a class" }

    it "splits only at the first separator" do
      expect([label, title]).to eq(["Table 2", "Parts — of a class"])
    end
  end

  context "with an annex letter designation" do
    let(:name) { "Table B.1 — Mapping of statuses" }

    it "splits the annex label and title" do
      expect([label, title]).to eq(["Table B.1", "Mapping of statuses"])
    end
  end

  context "with a lettered designation containing a dotted subnumber" do
    let(:name) { "Table D.10 — Register item attributes" }

    it "splits the label and title" do
      expect([label, title]).to eq(["Table D.10", "Register item attributes"])
    end
  end

  context "with a dotted number and no spaces around the em dash" do
    let(:name) { "Table 1.1—Scope" }

    it "splits the label and title" do
      expect([label, title]).to eq(["Table 1.1", "Scope"])
    end
  end

  context "with no spaces around the em dash" do
    let(:name) { "Table 1—Scope" }

    it "splits the label and title" do
      expect([label, title]).to eq(["Table 1", "Scope"])
    end
  end

  context "with an uppercase TABLE keyword" do
    let(:name) { "TABLE 1 — Scope" }

    it "splits the label and title" do
      expect([label, title]).to eq(["TABLE 1", "Scope"])
    end
  end

  context "with a figure dash U+2012 separator" do
    let(:name) { "Table 1 ‒ Scope" }

    it "splits the label and title" do
      expect([label, title]).to eq(["Table 1", "Scope"])
    end
  end

  context "with a minus sign U+2212 separator" do
    let(:name) { "Table 1 − Scope" }

    it "splits the label and title" do
      expect([label, title]).to eq(["Table 1", "Scope"])
    end
  end

  context "with a bare hyphen between two numbers" do
    let(:name) { "Table 1-2 Scope" }

    it "keeps the whole name as the title, since it is a range" do
      expect([label, title]).to eq([nil, "Table 1-2 Scope"])
    end
  end

  context "with an en dash between two numbers and no spaces" do
    let(:name) { "Table 1–2 Scope" }

    it "keeps the whole name as the title, since it is a range" do
      expect([label, title]).to eq([nil, "Table 1–2 Scope"])
    end
  end

  context "with a bare hyphen and no spaces before a word" do
    let(:name) { "Table 1-Scope" }

    it "keeps the whole name as the title" do
      expect([label, title]).to eq([nil, "Table 1-Scope"])
    end
  end
end
