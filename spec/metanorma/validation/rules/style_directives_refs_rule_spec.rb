require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleDirectivesRefsRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(normative_xml, informative_xml)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections><clause id="c1"><title>One</title><p>body</p></clause></sections>
        <bibliography>
          <references id="_norm" normative="true"><title>Normative references</title>
            #{normative_xml}
          </references>
          <references id="_bibl"><title>Bibliography</title>
            #{informative_xml}
          </references>
        </bibliography>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags a Clause 2 entry citing the Directives Part 2" do
    issues = rule.check(context_with(
                          '<bibitem id="ref1"><docidentifier>ISO/IEC Directives, Part 2</docidentifier></bibitem>',
                          '<bibitem id="ref2"><docidentifier>ISO 9001</docidentifier></bibitem>'
                        ))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("STANDOC_48")
    expect(issues.first.message).to include("ISO/IEC Directives Part 2")
    expect(issues.first.message).to include("Clause 2 (normative references)")
    expect(issues.first.message).to include("reproduce")
  end

  it "flags a Bibliography entry citing the Directives Part 1" do
    issues = rule.check(context_with(
                          '<bibitem id="ref1"><docidentifier>ISO 9001</docidentifier></bibitem>',
                          '<bibitem id="ref2"><title>Cited as ISO/IEC Directives Part 1</title></bibitem>'
                        ))
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("the Bibliography")
  end

  it "flags a bare Directives mention without a part number" do
    issues = rule.check(context_with(
                          '<bibitem id="ref1"><docidentifier>ISO/IEC Directives</docidentifier></bibitem>',
                          ""
                        ))
    expect(issues.size).to eq(1)
  end

  it "does not flag other Directives parts" do
    issues = rule.check(context_with(
                          '<bibitem id="ref1"><docidentifier>ISO/IEC Directives, Part 3</docidentifier></bibitem>',
                          ""
                        ))
    expect(issues).to eq([])
  end

  it "does not flag ordinary references" do
    issues = rule.check(context_with(
                          '<bibitem id="ref1"><docidentifier>ISO 9001</docidentifier></bibitem>',
                          '<bibitem id="ref2"><docidentifier>ISO/IEC 17025</docidentifier></bibitem>'
                        ))
    expect(issues).to eq([])
  end
end
