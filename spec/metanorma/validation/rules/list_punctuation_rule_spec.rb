require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::ListPunctuationRule do
  let(:state) do
    Metanorma::Iso::Validation::ConverterState.new(
      lang: "en", script: "Latn", document: "spec"
    )
  end
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

  it "passes when list is preceded by a colon" do
    body = "<p>Items are:</p><ul><li>a</li><li>b</li></ul>"
    expect(rule.check(context_with(body))).to eq([])
  end

  it "passes when list is preceded by a period" do
    body = "<p>The list follows.</p><ul><li>a</li><li>b</li></ul>"
    expect(rule.check(context_with(body))).to eq([])
  end

  it "flags ISO_60 when list is preceded by other text" do
    body = "<p>Items are; here</p><ul><li>a</li><li>b</li></ul>"
    issues = rule.check(context_with(body))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_60")
    expect(issues.first.message).to include("preceded by colon or full stop")
  end

  # metanorma/metanorma-pdfa#118: the reporter's paragraph ends with an
  # eref whose localityStack carries <referenceFrom>69</referenceFrom>,
  # followed by the colon. The rule must read the paragraph's trailing
  # own text (the colon), never the locality digits inside the eref.
  it "passes when the colon follows an eref with a localityStack" do
    body = "<p>When a rendering intent is specified, its value shall be " \
      "one of the four values defined in " \
      '<eref type="inline" bibitemid="ISO32000-2" citeas="ISO 32000-2">' \
      "<localityStack><locality type=\"table\">" \
      "<referenceFrom>69</referenceFrom>" \
      "</locality></localityStack></eref>:</p>" \
      "<ul><li><p>RelativeColorimetric;</p></li><li><p>Saturation.</p></li></ul>"
    expect(rule.check(context_with(body))).to eq([])
  end

  it "passes when the full stop follows a footnote" do
    body = "<p>The list follows" \
      '<fn reference="1"><p>See the annex.</p></fn>.</p>' \
      "<ul><li>a</li><li>b</li></ul>"
    expect(rule.check(context_with(body))).to eq([])
  end

  it "still flags a genuinely unterminated paragraph before a list" do
    body = "<p>The values are defined in " \
      '<eref type="inline" bibitemid="ISO32000-2" citeas="ISO 32000-2">' \
      "<localityStack><locality type=\"table\">" \
      "<referenceFrom>69</referenceFrom>" \
      "</locality></localityStack></eref></p>" \
      "<ul><li>a</li><li>b</li></ul>"
    issues = rule.check(context_with(body))
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_60")
  end
end
