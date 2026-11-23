require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::UniqueIdRule do
  let(:state) { Metanorma::Iso::Validation::ConverterState.new(document: "spec") }
  let(:rule) { described_class.new }

  def context_with(xml)
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    shared = Metanorma::Iso::Validation::SharedState.new
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: shared)
  end

  describe "#check" do
    it "passes when all ids are unique" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="c1"><title>One</title></clause>
            <clause id="c2"><title>Two</title></clause>
          </sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end

    it "flags ISO_122 for duplicate ids" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="dup"><title>One</title></clause>
            <clause id="dup"><title>Two</title></clause>
          </sections>
        </metanorma>
      XML
      issues = rule.check(context_with(xml))
      expect(issues.size).to eq(1)
      expect(issues.first.code).to eq("ISO_122")
    end

    it "populates SharedState with the id index" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <sections>
            <clause id="c1"><title>One</title></clause>
          </sections>
        </metanorma>
      XML
      context = context_with(xml)
      rule.check(context)
      expect(context.shared.doc_ids).to include("c1")
      expect(context.shared.id_seq).to include("c1")
    end

    it "does not treat repeated docidentifier content as duplicate ids" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata>
            <docidentifier type="ISO">ISO 6707-1</docidentifier>
            <relation type="amends">
              <bibitem>
                <docidentifier type="ISO">ISO 6707-1</docidentifier>
              </bibitem>
            </relation>
          </bibdata>
          <sections>
            <clause id="c1"><title>One</title></clause>
          </sections>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end

    # On the second parse in one process, lutaml-model 0.8.176+ materializes
    # the IsoPreface clause/content render mirror as its own objects: the
    # mirrored subtree's ids are distinct objects carrying the same values.
    # The id walk must skip the mirror subtree, or in-memory-only duplicates
    # (the document XML is clean) abort the compile.
    it "does not flag mirror descendants deep-copied by a later parse" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <preface>
            <clause id="corr_01" type="corrigenda">
              <title>Corrigenda</title>
              <table id="tab_01">
                <name id="tab_01_name">T1</name>
              </table>
            </clause>
          </preface>
        </metanorma>
      XML
      Metanorma::IsoDocument::Root.from_xml(xml)
      root = Metanorma::IsoDocument::Root.from_xml(xml)
      shared = Metanorma::Iso::Validation::SharedState.new
      context = Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                                        state: state, shared: shared)
      expect(rule.check(context)).to eq([])
    end

    it "does not flag IsoPreface clause/content mirror pairs" do
      xml = <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
          <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
          <preface>
            <clause id="toc0_02" anchor="toc0_02" type="publication-history">
              <title>Hist</title>
            </clause>
          </preface>
        </metanorma>
      XML
      expect(rule.check(context_with(xml))).to eq([])
    end
  end

  describe "code" do
    it "declares ISO_122" do
      expect(described_class.new.code).to eq("ISO_122")
    end
  end
end
