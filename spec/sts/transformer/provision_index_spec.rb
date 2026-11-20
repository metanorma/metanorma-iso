# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::ProvisionIndex, :aggregate_failures do # rubocop:disable RSpec/SpecFilePathFormat
  let(:presentation_xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc"><sections><clause id="c">
        <requirement id="r1" anchor="req-1"><fmt-provision><table id="t1"><tbody><tr><td>Invented requirement text</td></tr></tbody></table></fmt-provision></requirement>
        <permission id="r2" anchor="perm-1"><fmt-provision><table id="t2"><tbody><tr><td>Invented permission text</td></tr></tbody></table></fmt-provision></permission>
        <recommendation id="r3" anchor="rec-1"><p>no formal provision table</p></recommendation>
      </clause></sections></metanorma>
    XML
  end
  let(:index) { described_class.from_xml(presentation_xml) }

  it "indexes each requirement-like element that carries a provision table" do
    expect(index.size).to eq(2)
  end

  it "returns the typed table under the requirement anchor" do
    table = index.table_for("req-1")
    expect(table).to be_a(Metanorma::Document::Components::Tables::TableBlock)
    expect(table.id).to eq("t1")
  end

  it "keeps a permission's table under its own anchor" do
    expect(index.table_for("perm-1").id).to eq("t2")
  end

  it "has no entry for a requirement without a provision, or an unknown anchor" do
    expect(index.table_for("rec-1")).to be_nil
    expect(index.table_for("nope")).to be_nil
  end

  it "is empty for a missing or empty presentation XML" do
    expect(described_class.from_xml(nil).size).to eq(0)
    expect(described_class.from_xml("").size).to eq(0)
  end
end
