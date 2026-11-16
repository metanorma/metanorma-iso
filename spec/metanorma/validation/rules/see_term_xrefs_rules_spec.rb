require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::SeeXrefsRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec", lang: "en") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags ISO_46 when 'see <xref>' points to a normative section" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>Body</title>
            <p>see <xref target="annexA">Annex A</xref> for more.</p>
          </clause>
        </sections>
        <annex id="a1" anchor="annexA" obligation="normative"><title>Annex</title></annex>
      </metanorma>
    XML
    issues = rule.check(context_with(xml))
    iso46 = issues.select { |i| i.code == "ISO_46" }
    expect(iso46.size).to eq(1)
  end

  it "does not flag when xref is not preceded by 'see'" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>Body</title>
            <p>consult <xref target="annexA">Annex A</xref> for more.</p>
          </clause>
        </sections>
        <annex id="a1" anchor="annexA" obligation="normative"><title>Annex</title></annex>
      </metanorma>
    XML
    expect(rule.check(context_with(xml))).to eq([])
  end

  # Under semx the bibitem id is a UUID and the citation anchor moved to
  # the anchor attribute; a "see" eref cites the anchor (pdfa#111).
  it "does not flag ISO_47 for a 'see <eref>' whose bibitem carries the anchor" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>Body</title>
            <p>see <eref bibitemid="ISO32000-2" citeas="ISO 32000-2">[ISO32000-2]</eref> for details.</p>
          </clause>
        </sections>
        <bibliography>
          <references normative="true">
            <bibitem id="_2083ca6a-1111-4bbb-8ccc-ddddaaaaaaaa" anchor="ISO32000-2" type="standard">
              <title>PDF specification</title>
              <docidentifier type="ISO" primary="true">ISO 32000-2:2020</docidentifier>
            </bibitem>
          </references>
        </bibliography>
      </metanorma>
    XML
    issues = rule.check(context_with(xml))
    expect(issues.select { |i| i.code == "ISO_47" }).to eq([])
  end
end

RSpec.describe Metanorma::Iso::Validation::Rules::TermXrefsRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "passes for xref outside terms clauses (default doc)" do
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <sections>
          <clause id="c1"><title>Body</title>
            <p>see <xref target="other">other</xref></p>
          </clause>
        </sections>
      </metanorma>
    XML
    expect(rule.check(context_with(xml))).to eq([])
  end
end
