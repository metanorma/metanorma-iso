require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::NormativeBibitemRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  def bibitem_xml(id:, publisher_abbr: nil, publisher_name: nil)
    publisher_inner = if publisher_abbr
                        "<abbreviation>#{publisher_abbr}</abbreviation>"
                      elsif publisher_name
                        "<name>#{publisher_name}</name>"
                      else
                        ""
                      end
    <<~XML
      <bibitem id="#{id}">
        <title>#{id}</title>
        <contributor>
          <role type="publisher"/>
          <organization>#{publisher_inner}</organization>
        </contributor>
      </bibitem>
    XML
  end

  def doc_with_normative(*bibitems)
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        <bibliography>
          <references normative="true">
            #{bibitems.join("\n")}
          </references>
        </bibliography>
      </metanorma>
    XML
  end

  describe "#check" do
    it "passes for an ISO-published bibitem" do
      xml = doc_with_normative(bibitem_xml(id: "iso-1", publisher_abbr: "ISO"))
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "passes for an IEC-published bibitem" do
      xml = doc_with_normative(bibitem_xml(id: "iec-1", publisher_abbr: "IEC"))
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags ISO_42 for a non-ISO/IEC bibitem" do
      xml = doc_with_normative(bibitem_xml(id: "other-1", publisher_abbr: "W3C"))
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_42")
      expect(issues.first.message).to include("non-ISO/IEC reference")
    end

    it "ignores bibitems in non-normative bibliography" do
      bib = bibitem_xml(id: "other-2", publisher_abbr: "W3C")
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <bibliography>
            <references normative="false">#{bib}</references>
          </bibliography>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end
  end

  describe "code" do
    it "declares ISO_42" do
      expect(described_class.new.code).to eq("ISO_42")
    end
  end
end
