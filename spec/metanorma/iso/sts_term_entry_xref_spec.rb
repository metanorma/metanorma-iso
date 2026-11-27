# frozen_string_literal: true

require "spec_helper"
require "metanorma/iso/sts"

# A reference from one term's definition to another term names a term
# entry: NISO STS guidelines 9.2.6 require @ref-type='custom' with
# @custom-type='term-entry', and @rid must name the <tbx:termEntry>, not the
# <term-sec> section (guidelines 10.1.2 allows ref-type 'sec' only for <sec>).
RSpec.describe Metanorma::Iso::Sts do
  let(:input) do
    File.read(File.expand_path("../../fixtures/sts_e2e/calendar_notation_e2e_a.input.xml", __dir__))
  end
  let(:tally_source_id) { "_6c1f0a52-3b7e-4d10-9a11-0c5e1f7b2a02" }
  let(:sts) do
    described_class.convert(
      input.sub(
        "single vertical line recording one lunar cycle",
        %(single vertical line recording one lunar cycle, see <xref target="#{tally_source_id}"/>),
      ),
    )
  end
  let(:doc) { Nokogiri::XML(sts).tap(&:remove_namespaces!) }
  let(:xref) { doc.at_xpath("//definition//xref") }

  def tally_entry
    doc.xpath("//termEntry").find do |entry|
      entry.xpath(".//term").any? { |t| t.text == "tally mark" }
    end
  end

  it "emits a term xref with ref-type custom" do
    expect(xref["ref-type"]).to eq("custom")
  end

  it "emits the term-entry custom-type" do
    expect(xref["custom-type"]).to eq("term-entry")
  end

  it "points the rid at the referenced termEntry" do
    expect(xref["rid"]).to eq(tally_entry["id"])
  end

  it "emits no sec-typed xref to a term section" do
    expect(doc.xpath("//xref[@ref-type='sec'][starts-with(@rid, 'sec_')]"))
      .to be_empty
  end
end
