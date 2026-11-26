# frozen_string_literal: true

require "spec_helper"

RSpec.describe "declarative section sequence on real ISO models" do
  let(:validation) { Metanorma::Iso::Validation }
  let(:klass) { validation::Rules::SectionSequenceRule }

  def context_for(body, vocab: false, adapter: :leptris)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>#{body}
      </metanorma>
    XML
    root = Lutaml::Model::AdapterScope.with(xml: adapter) do
      Metanorma::Iso::Document::Root.from_xml(xml)
    end
    validation::Context.new(root: root,
      state: validation::ConverterState.new(document: "spec", vocab: vocab),
      registry: validation::ComposedRegistry.for(flavor: nil))
  end

  def signature(issues)
    issues.map { |issue| [issue.code, issue.location, issue.message, issue.params] }
  end

  foreword = '<preface><foreword id="f"><p>F</p></foreword></preface>'
  intro = '<preface><foreword id="f"><p>F</p></foreword><introduction id="i"><title>I</title></introduction></preface>'
  scope = '<clause id="s" type="scope"><title>S</title></clause>'
  terms = '<terms id="t"><title>T</title></terms>'
  body = '<clause id="b"><title>B</title></clause>'
  annex = '<annex id="a"><title>A</title></annex>'
  references = '<bibliography><references id="r" normative="true"><title>R</title></references><references id="bib" normative="false"><title>Bib</title></references></bibliography>'

  cases = {
    "empty document" => "",
    "scope without preface" => "<sections>#{scope}#{terms}#{body}</sections>",
    "normal document" => "#{foreword}<sections>#{scope}#{terms}#{body}</sections>#{annex}#{references}",
    "introduction" => "#{intro}<sections>#{scope}#{terms}#{body}</sections>#{references}",
    "missing terms" => "#{foreword}<sections>#{scope}#{body}</sections>#{annex}",
    "missing body" => "#{foreword}<sections>#{scope}#{terms}</sections>#{references}",
    "extra scopes" => "#{foreword}<sections>#{scope}#{terms}#{scope.sub('id="s"', 'id="s2"')}#{body}#{scope.sub('id="s"', 'id="s3"')}</sections>#{annex}",
    "definitions" => %Q{#{foreword}<sections>#{scope}#{terms}<definitions id="d"><title>D</title></definitions>#{body}</sections>#{annex}},
    "annex only" => annex,
    "bibliography only" => references,
    "misordered preface" => '<preface><introduction id="i"><title>I</title></introduction><foreword id="f"><p>F</p></foreword></preface>',
  }

  cases.each do |label, source|
    [false, true].each do |vocab|
      [:leptris, :nokogiri].each do |adapter|
        it "preserves #{label}, vocab=#{vocab}, adapter=#{adapter}" do
          context = context_for(source, vocab: vocab, adapter: adapter)
          before = context.root.to_xml
          rule = klass.new
          findings = validation::Rules::DeclarativeCatalog.findings_for(klass, context)
          expect(findings).not_to be_nil
          expect(findings.all? { |finding| finding.source_model.equal?(context.root) }).to be(true)
          expect(signature(rule.check(context))).to eq(signature(rule.send(:legacy_check, context)))
          expect(context.root.to_xml).to eq(before)
        end
      end
    end
  end

  it "preserves repeated singular definitions as repeated model sequence facts" do
    context = context_for('<preface><foreword id="f"><p>F</p></foreword></preface><sections><clause id="s" type="scope"><title>S</title></clause><terms id="t"><title>T</title></terms><definitions id="a"><title>A</title></definitions><definitions id="b"><title>B</title></definitions><clause id="c"><title>C</title></clause></sections>')
    before = context.root.to_xml
    catalog = validation::Rules::DeclarativeCatalog
    projection = catalog.model_projection_for(context)
    records = projection.xml.xpath("/m:metanorma/v:sequence/v:item[@kind='definitions']", catalog::PROJECTION_NAMESPACES)
    expect(records.size).to eq(2)
    expect(signature(klass.new.check(context))).to eq(signature(klass.new.send(:legacy_check, context)))
    expect(context.root.to_xml).to eq(before)
  end

  it "distinguishes genuinely recorded bibliography order from absent order" do
    source = '<preface><foreword id="f"><p>F</p></foreword></preface><sections><clause id="s" type="scope"><title>S</title></clause><terms id="t"><title>T</title></terms><clause id="c"><title>C</title></clause></sections><bibliography><references id="r" normative="true"><title>R</title></references></bibliography>'
    [nil, [Lutaml::Xml::Element.new("Element", "references")]].each do |order|
      context = context_for(source)
      context.root.bibliography.element_order = order
      before = context.root.to_xml
      catalog = validation::Rules::DeclarativeCatalog
      records = catalog.model_projection_for(context).xml.xpath("/m:metanorma/v:sequence/v:item[@kind='normative_references']", catalog::PROJECTION_NAMESPACES)
      expect(records.size).to eq(order.nil? ? 0 : 1)
      expect(signature(klass.new.check(context))).to eq(signature(klass.new.send(:legacy_check, context)))
      expect(context.root.to_xml).to eq(before)
    end
  end

  it "fails clearly when a projection binds the reserved validation prefix differently" do
    context = context_for("<sections/>")
    api = Metanorma::Standoc::Validate::Rules
    xml = Nokogiri::XML(context.root.to_xml)
    xml.root.add_namespace_definition("v", "urn:another-vocabulary")
    allow(api::DocumentProjection).to receive(:parse_model).with(context.root).and_return(xml)
    expect { validation::Rules::ScopePresenceRule.new.check(context) }
      .to raise_error(validation::Rules::DeclarativeCatalog::ProjectionError, /namespace collision/)
  end

  it "marks order checks as requiring model preprocessing in Schematron export" do
    export = validation::ComposedRegistry.for(flavor: nil).schematron
    expect(export.code_backed).to include(*klass.declarative_rule_ids)
    expect(export.xml).not_to include('id="iso.sequence.initial"')
  end
end
