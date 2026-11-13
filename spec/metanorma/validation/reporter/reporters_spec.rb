require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Reporter::Text do
  let(:report) do
    Metanorma::Iso::Validation::Report.new(document: "rice.adoc").tap do |r|
      r.add_issue(code: "ISO_5", location: nil, params: ["pizza"])
      r.add_issue(code: "ISO_21", location: "annex A", params: %w[annex A])
    end
  end

  it "renders summary as first line" do
    output = described_class.new.format(report)
    expect(output.split("\n").first).to include("rice.adoc")
    expect(output.split("\n").first).to include("2 findings")
  end

  it "includes one tagged line per finding" do
    output = described_class.new.format(report)
    expect(output).to include("[error] ISO_5")
    expect(output).to include("[warning] ISO_21")
    expect(output).to include("@ annex A")
  end

  it "ends with a newline" do
    expect(described_class.new.format(report)).to end_with("\n")
  end
end

RSpec.describe Metanorma::Iso::Validation::Reporter::Json do
  let(:report) do
    Metanorma::Iso::Validation::Report.new(document: "rice.adoc").tap do |r|
      r.add_issue(code: "ISO_5", location: nil, params: ["pizza"])
    end
  end

  it "returns valid JSON containing the report" do
    output = described_class.new.format(report)
    parsed = JSON.parse(output)
    expect(parsed["document"]).to eq("rice.adoc")
  end
end

RSpec.describe Metanorma::Iso::Validation::Reporter::Yaml do
  let(:report) do
    Metanorma::Iso::Validation::Report.new(document: "rice.adoc").tap do |r|
      r.add_issue(code: "ISO_5", location: nil, params: ["pizza"])
    end
  end

  it "returns valid YAML containing the report" do
    output = described_class.new.format(report)
    parsed = YAML.safe_load(output)
    expect(parsed["document"]).to eq("rice.adoc")
  end
end
