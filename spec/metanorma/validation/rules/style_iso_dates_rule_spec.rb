require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleIsoDatesRule do
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

  def table_with(*cells)
    tds = cells.map { |c| "<td>#{c}</td>" }.join
    "<table id=\"t1\"><tbody><tr>#{tds}</tr></tbody></table>"
  end

  it "flags a day month-name year date inside a table cell" do
    issues = rule.check(context_with(table_with("31 October 2026")))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_99")
    expect(issues.first.message).to include("YYYY-MM-DD")
  end

  it "flags a month-first date inside a table cell" do
    issues = rule.check(context_with(table_with("October 31, 2026")))
    expect(issues.size).to eq(1)
  end

  it "flags slash- and dot-separated numeric dates inside table cells" do
    issues = rule.check(context_with(table_with("10/31/2026", "31.10.2026")))
    expect(issues.size).to eq(2)
  end

  it "does not flag ISO-format dates inside table cells" do
    issues = rule.check(context_with(table_with("2026-10-31")))
    expect(issues).to eq([])
  end

  it "does not flag software versions inside table cells" do
    issues = rule.check(context_with(table_with("1.2.10")))
    expect(issues).to eq([])
  end

  it "does not flag prose dates (prose is StyleDateFormatsRule scope)" do
    issues = rule.check(context_with(
      "<p>the revision was published 31 October 2026</p>"
    ))
    expect(issues).to eq([])
  end
end
