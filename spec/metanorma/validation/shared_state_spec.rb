require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::SharedState do
  it "initializes cross-rule state to empty defaults" do
    state = described_class.new
    expect(state.doc_ids).to eq({})
    expect(state.doc_anchors).to eq({})
    expect(state.doc_xrefs).to eq({})
    expect(state.id_seq).to eq([])
    expect(state.anchor_seq).to eq([])
  end

  it "allows mutation so rules can populate it" do
    state = described_class.new
    state.doc_ids["abc"] = { line: 42 }
    expect(state.doc_ids["abc"]).to eq(line: 42)
  end
end
