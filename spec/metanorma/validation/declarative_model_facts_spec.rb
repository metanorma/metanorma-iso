# frozen_string_literal: true

require "spec_helper"

RSpec.describe "typed identity, asset and reference declaration parity" do
  let(:validation) { Metanorma::Iso::Validation }

  def context_for(body)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>#{body}
      </metanorma>
    XML
    validation::Context.new(root: Metanorma::Iso::Document::Root.from_xml(xml),
      state: validation::ConverterState.new(document: "spec", amd: false, vocab: false),
      shared: validation::SharedState.new)
  end

  def signature(issues)
    issues.map { |issue| [issue.code, issue.location, issue.message, issue.params] }
  end

  cases = {
    "duplicate identities and mirror" => '<preface><clause id="f"><title>F</title><p id="p">P</p></clause></preface><sections><clause id="c"><p id="duplicate">A</p><p id="duplicate">B</p></clause></sections>',
    "asset cited afterwards" => '<sections><clause id="c"><table id="a"><name>A</name></table><p>See <xref target="a">A</xref></p></clause></sections>',
    "asset cited beforehand" => '<sections><clause id="c"><p>See <xref target="a">A</xref></p><table id="a"><name>A</name></table></clause></sections>',
    "uncited and unnumbered" => '<sections><clause id="c"><table id="a"><name>A</name></table><table id="b" unnumbered="true"><name>B</name></table></clause></sections><annex id="an"><title>Annex</title></annex>',
    "term sources with distinct and repeated incomplete citations" => '<sections><clause id="c"><terms id="ts"><term id="t"><preferred><expression><name>Example</name></expression></preferred><termsource><origin bibitemid="missing"/></termsource><termsource/><termsource><origin/></termsource><termsource><origin bibitemid="missing"/></termsource></term></terms></clause></sections>',
    "term source in bibliography" => '<sections><clause id="c"><terms id="ts"><term id="t"><preferred><expression><name>Example</name></expression></preferred><termsource><origin bibitemid="listed"/></termsource></term></terms></clause></sections><bibliography><references normative="false"><bibitem id="listed"><docidentifier>Other</docidentifier></bibitem></references></bibliography>',
    "term cross references" => '<sections><terms id="t"><title>T</title><p>See <xref target="c">C</xref></p></terms><clause id="c"><title>C</title><p>See <xref target="t">T</xref></p></clause></sections>',
  }

  %w[UniqueIdRule UnreferencedAssetsRule AssetCitedFirstRule TermSourceCompleteRule TermXrefsRule].each do |name|
    cases.each do |label, body|
      it "preserves #{name}: #{label}" do
        klass = validation::Rules.const_get(name)
        context = context_for(body)
        before = context.root.to_xml
        findings = validation::Rules::DeclarativeCatalog.findings_for(klass, context)
        expect(findings).not_to be_nil
        expect(findings.all? { |finding| finding.source_model.equal?(context.root) }).to be(true)
        expect(findings.all? { |finding| finding.node.namespace.href == validation::Rules::DeclarativeCatalog::PROJECTION_NAMESPACE }).to be(true)
        rule = klass.new
        expect(signature(rule.check(context))).to eq(signature(rule.send(:legacy_check, context)))
        expect(context.root.to_xml).to eq(before)
      end
    end
  end
end
