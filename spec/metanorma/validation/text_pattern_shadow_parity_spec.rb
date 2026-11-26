# frozen_string_literal: true

require "spec_helper"

# Shadow parity (issue #1732): the text_pattern rules in iso-style-text.yml run
# beside the retained StyleXxxRule classes, which stay the runtime
# implementation. Same code, same paragraphs, same messages. The declarative
# finding is on the paragraph and the legacy one on its container, so the
# container is read from the paragraph's parent in the projection.
RSpec.describe "text_pattern shadow parity (issue #1732)" do
  let(:validation) { Metanorma::Iso::Validation }
  let(:catalog) { validation::Rules::DeclarativeCatalog }

  def document(body)
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata><docidentifier>ISO 1</docidentifier></bibdata>
        #{body}
      </metanorma>
    XML
  end

  def context_for(xml)
    root = Metanorma::Iso::Document::Root.from_xml(xml)
    state = validation::ConverterState.new(document: "spec", amd: false, doctype: nil, vocab: false)
    validation::Context.new(root: root, log: nil, state: state, shared: nil, registry: nil)
  end

  clause = lambda do |*paragraphs|
    paragraphs
  end

  # [code, class] => [[label, body, expected finding count]]
  fixtures = {
    ["ISO_62", "StyleAOrAnRule"] => [
      ["a before silent h", clause.call("It is a hour long."), 1],
      ["an before y sound", clause.call("An user and an unique case, an union."), 3],
      ["repeated match once", clause.call("a hour, a hour"), 1],
      ["correct", clause.call("an hour and a user"), 0],
    ],
    ["ISO_64", "StyleAbbrevPluralRule"] => [
      ["MSSs", clause.call("Several MSSs."), 1],
      ["twice reports once", clause.call("MSSs and MSSs"), 1],
      ["lower case is not matched", clause.call("msss"), 0],
    ],
    ["ISO_65", "StyleAbbrevTablesOnlyRule"] => [
      ["min and max", clause.call("The min. and max. values and the lab. test."), 3],
      ["written in full", clause.call("The minimum value."), 0],
    ],
    ["ISO_76", "StyleComplianceRule"] => [
      ["variants", clause.call("Compliance with non-compliant and Noncompliance."), 3],
      ["conformity", clause.call("Conformity."), 0],
    ],
    ["ISO_89", "StyleFamilySuiteRule"] => [
      ["family and suite", clause.call("A family of standards or a Suite of standards."), 2],
      ["none", clause.call("A set of documents."), 0],
    ],
    ["ISO_91", "StyleFormulaeRule"] => [
      ["formulas", clause.call("Two Formulas apply, formulas."), 1],
      ["formulae", clause.call("Two formulae."), 0],
    ],
    ["ISO_94", "StyleImpreciseRefsRule"] => [
      ["following clause", clause.call("See the following clause and the table below."), 2],
      ["precise", clause.call("See Clause 5."), 0],
    ],
    ["ISO_97", "StyleInformativeNormativeRule"] => [
      ["normative annex", clause.call("See normative Annex A and Informative Table 2."), 2],
      ["plain", clause.call("See Annex A."), 0],
    ],
    ["ISO_98", "StyleInterlabRule"] => [
      ["round robin", clause.call("A round robin and ring tests."), 2],
      ["none", clause.call("An interlaboratory comparison."), 0],
    ],
    ["ISO_104", "StyleNoNosRule"] => [
      ["nos.", clause.call("Nos. 1 and 2, Nos. 3."), 1],
      ["nos", clause.call("Nos 1 and 2."), 0],
    ],
    ["ISO_106", "StyleOrdinalsRule"] => [
      ["firstly", clause.call("Firstly this, secondly that."), 2],
      ["first", clause.call("First this."), 0],
    ],
    ["ISO_109", "StylePerCentRule"] => [
      ["percent", clause.call("Ten percent and Percent."), 2],
      ["per cent", clause.call("Ten per cent."), 0],
    ],
    ["ISO_110", "StylePluralSTermRule"] => [
      ["(s)", clause.call("The value(s) and item( s )."), 2],
      ["lone parenthesis", clause.call("Text (s) only."), 0],
    ],
    ["ISO_113", "StyleSelfReferenceRule"] => [
      ["self reference", clause.call("This International Standard and this standard and this part of ISO 1."), 3],
      ["this document", clause.call("This document."), 0],
    ],
    ["ISO_116", "StyleUnitsRule"] => [
      ["no space", clause.call("5% and 10%."), 2],
      ["space", clause.call("5 %"), 0],
    ],
  }

  # Containers the retained rules reach: the findings must be identical.
  covered = {
    "clause" => ->(p) { %(<sections><clause id="x"><title>T</title>#{p}</clause></sections>) },
    "annex" => ->(p) { %(<annex id="x"><title>A</title>#{p}</annex>) },
    "appendix" => ->(p) { %(<annex id="a"><title>A</title><appendix id="x"><title>T</title>#{p}</appendix></annex>) },
    "list item" => ->(p) { %(<sections><clause id="c"><ul id="u"><li id="x">#{p}</li></ul></clause></sections>) },
    "admonition" => ->(p) { %(<sections><clause id="c"><admonition id="x" type="warning">#{p}</admonition></clause></sections>) },
    "example" => ->(p) { %(<sections><clause id="c"><example id="x">#{p}</example></clause></sections>) },
    "quote" => ->(p) { %(<sections><clause id="c"><quote id="x">#{p}</quote></clause></sections>) },
    "definitions" => ->(p) { %(<sections><definitions id="x"><title>S</title>#{p}</definitions></sections>) },
    "foreword" => ->(p) { %(<preface><foreword id="x">#{p}</foreword></preface>) },
    "introduction" => ->(p) { %(<preface><introduction id="x">#{p}</introduction></preface>) },
    "abstract" => ->(p) { %(<preface><abstract id="x">#{p}</abstract></preface>) },
    "no paragraphs" => ->(_) { "<sections/>" },
  }

  # Containers whose paragraphs the retained rules never reach (they walk
  # only model nodes that declare +paragraphs+). The declarative rule scans
  # every paragraph, so it also reports here: a coverage gain to be accepted
  # before the retained classes are retired. Pinned so a change is noticed.
  gaps = {
    "note" => ->(p) { %(<sections><clause id="c"><note id="x">#{p}</note></clause></sections>) },
    "table cell" => ->(p) { %(<sections><clause id="c"><table id="t"><tbody><tr><td id="x">#{p}</td></tr></tbody></table></clause></sections>) },
    "definition list" => ->(p) { %(<sections><clause id="c"><dl id="d"><dt>A</dt><dd id="x">#{p}</dd></dl></clause></sections>) },
    "term note" => ->(p) { %(<sections><terms id="t"><term id="x"><preferred><expression><name>a</name></expression></preferred><termnote id="n">#{p}</termnote></term></terms></sections>) },
    "figure note" => ->(p) { %(<sections><clause id="c"><figure id="f"><note id="x">#{p}</note></figure></clause></sections>) },
    "references" => ->(p) { %(<bibliography><references id="x" normative="true"><title>N</title>#{p}</references></bibliography>) },
  }

  stem_paragraph = '<p>Text <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>min.</mi></math><asciimath>min.</asciimath></stem> done.</p>'

  def container_id(location)
    location.to_s.split("#", 2)[1]
  end

  def legacy(klass, context)
    rule = klass.new
    rule.applicable?(context) ? rule.check(context) : []
  end

  # Findings of the shadow rules, with each message decorated by the retained
  # class (build_issue adds the rule's citation), and the paragraph's parent id.
  def shadow(klass, context)
    rule = klass.new
    catalog.shadow_findings_for(klass.code_value, context).map do |finding|
      issue = rule.send(:build_issue, location: "X", params: finding.params)
      [issue.code, finding.node.parent["id"], issue.params]
    end
  end

  def legacy_signature(issues)
    issues.map { |i| [i.code, container_id(i.location), i.params] }
  end

  def normalized(list)
    list.sort_by(&:inspect)
  end

  it "has the accepted engine loaded" do
    expect(catalog.available?).to be(true)
  end

  it "loads every shadow rule with a retained class of the same code" do
    codes = fixtures.keys.map(&:first)
    expect(catalog.shadow_rule_set.rules.map(&:code).uniq).to match_array(codes)
    fixtures.each_key do |code, name|
      expect(validation::Rules.const_get(name).code_value).to eq(code)
    end
  end

  it "keeps shadow rules out of the registered catalog" do
    shadow_ids = catalog.shadow_rule_set.rules.map(&:id)
    expect(shadow_ids & catalog.rule_set.rules.map(&:id)).to be_empty
    expect(catalog.registrations.map { |e| e["implementation"] }).not_to include("shadow")
  end

  fixtures.each do |(_code, name), cases|
    describe name do
      let(:klass) { validation::Rules.const_get(name) }

      cases.each do |label, paragraphs, count|
        body = paragraphs.map { |text| "<p>#{text}</p>" }.join

        it "has the retained findings in a clause: #{label}" do
          context = context_for(document(covered["clause"].call(body)))
          retained = legacy(klass, context)
          expect(retained.size).to eq(count)
          expect(normalized(shadow(klass, context))).to eq(normalized(legacy_signature(retained)))
        end

        covered.each do |container, wrap|
          next if container == "clause"

          it "matches the retained check in #{container}: #{label}" do
            context = context_for(document(wrap.call(body)))
            expect(normalized(shadow(klass, context)))
              .to eq(normalized(legacy_signature(legacy(klass, context))))
          end
        end

        gaps.each do |container, wrap|
          it "also reports in #{container}, which the retained rule skips: #{label}" do
            context = context_for(document(wrap.call(body)))
            expect(legacy(klass, context)).to be_empty
            expect(shadow(klass, context).size).to eq(count)
          end
        end
      end

      it "reads no formula source as prose" do
        context = context_for(document(covered["clause"].call(stem_paragraph)))
        expect(legacy(klass, context)).to be_empty
        expect(shadow(klass, context)).to be_empty
      end
    end
  end
end
