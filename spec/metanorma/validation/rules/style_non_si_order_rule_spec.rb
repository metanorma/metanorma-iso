require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleNonSiOrderRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(body)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>One</title>
            #{body}
          </clause>
        </sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags a parenthetical non-SI value with no preceding unit" do
    issues = rule.check(context_with(
      "<p>The measured pipeline length (3 miles) exceeds the design " \
      "limit.</p>"
    ))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_146")
    expect(issues.first.message).to include("(3 miles)")
    expect(issues.first.message).to include("SI value first")
  end

  it "flags a parenthetical knot value" do
    issues = rule.check(context_with(
      "<p>The wind speed (30 knots) was recorded at the station.</p>"
    ))
    expect(issues.size).to eq(1)
  end

  it "flags each offending parenthetical separately" do
    issues = rule.check(context_with(
      "<p>A length (3 miles) and a mass (5 lb) were recorded.</p>"
    ))
    expect(issues.size).to eq(2)
  end

  it "does not flag the SI-first shape" do
    expect(rule.check(context_with(
      "<p>The pipeline length is 5 km (3,5 miles).</p>"
    ))).to eq([])
  end

  it "does not flag a parenthetical preceded by any unit value" do
    expect(rule.check(context_with(
      "<p>The power output 450 hp (336 kW) is nominal.</p>"
    ))).to eq([])
  end

  it "does not flag an SI unit in the parenthetical" do
    expect(rule.check(context_with(
      "<p>A distance (5 km) separates the two sites.</p>"
    ))).to eq([])
  end

  it "does not flag citation callouts and cross-references" do
    expect(rule.check(context_with(
      "<p>See the requirements (3) and (4) and Table (see 5.2).</p>"
    ))).to eq([])
  end

  it "does not flag parentheticals whose content is not value+unit" do
    expect(rule.check(context_with(
      "<p>The results (see Table 3) are conclusive at 5 MPa.</p>"
    ))).to eq([])
  end

  it "judges the preceding text within its sentence" do
    expect(rule.check(context_with(
      "<p>Pressure was 5 MPa. The measured length (3 miles) exceeded the " \
      "limit.</p>"
    )).size).to eq(1)
  end
end
