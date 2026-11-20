# frozen_string_literal: true

require_relative "unit_b_support"

RSpec.describe Metanorma::Iso::Sts::Transformer::SourceOrder, :aggregate_failures do # rubocop:disable RSpec/SpecFilePathFormat
  include TransformerUnitSupport

  let(:source) do
    Metanorma::Iso::Sts::Transformer::SourceDocument.parse(source_xml(sections: <<~XML))
      <clause id="c1"><title>One</title>
        <p id="p1">first</p>
        <note id="n1"><p id="p2">note one</p></note>
        <p id="p3">second</p>
        <note id="n2"><p id="p4">note two</p></note>
        <clause id="c2"><title>Nested</title></clause>
      </clause>
    XML
  end
  let(:clause) { source.sections.first }

  def pairs(entries)
    entries.map { |attr, item| [attr, item.id] }
  end

  it "restores the source interleaving of separate collections" do
    entries = described_class.entries(clause, %i[paragraphs notes clause])
    expect(pairs(entries)).to eq([[:paragraphs, "p1"], [:notes, "n1"],
                                  [:paragraphs, "p3"], [:notes, "n2"],
                                  [:clause, "c2"]])
  end

  it "keeps only the requested attributes" do
    entries = described_class.entries(clause, [:notes])
    expect(pairs(entries)).to eq([[:notes, "n1"], [:notes, "n2"]])
  end

  it "keeps items the order record does not name, after the ordered ones" do
    extra = clause.paragraphs.first.dup.tap { |p| p.id = "p_extra" }
    clause.paragraphs = clause.paragraphs + [extra]
    entries = described_class.entries(clause, %i[paragraphs notes])
    expect(pairs(entries).last).to eq([:paragraphs, "p_extra"])
    expect(entries.size).to eq(5)
  end

  it "ignores a requested attribute the class does not have" do
    expect(described_class.entries(clause, [:no_such_attribute])).to eq([])
  end
end
