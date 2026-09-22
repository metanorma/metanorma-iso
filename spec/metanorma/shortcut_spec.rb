require "spec_helper"

RSpec.describe "Metanorma::Iso.validate top-level shortcut" do
  it "delegates to API.validate" do
    xml = "<metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' flavor='iso'><bibdata><docidentifier>ISO 1</docidentifier></bibdata></metanorma>"
    report = Metanorma::Iso.validate(xml)
    expect(report).to be_a(Metanorma::Iso::Validation::Report)
  end

  it "passes kwargs through" do
    xml = "<metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' flavor='iso'><bibdata><docidentifier>ISO 1</docidentifier></bibdata></metanorma>"
    report = Metanorma::Iso.validate(xml, profile: :publication)
    expect(report.issues.none? { |i| i.code == "STANDOC_48" }).to be(true)
  end
end
