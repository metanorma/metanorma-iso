# frozen_string_literal: true

require "spec_helper"

# Parity between the declarative engine and the retained code path, on real
# Metanorma::Iso::Document::Root models. These examples fail rather than skip
# when the accepted standoc engine is not loaded.
RSpec.describe "declarative ISO rule parity (issues #1732, #1733)" do
  let(:validation) { Metanorma::Iso::Validation }
  let(:catalog) { validation::Rules::DeclarativeCatalog }

  def document(body, flavor: "iso")
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="#{flavor}">
        #{body.include?("<bibdata>") ? "" : "<bibdata><docidentifier>#{flavor.upcase} 1</docidentifier></bibdata>"}
        #{body}
      </metanorma>
    XML
  end

  def context_for(xml, registry: nil, vocab: false, doctype: nil, amd: false)
    root = Metanorma::Iso::Document::Root.from_xml(xml)
    state = validation::ConverterState.new(document: "spec", amd: amd, doctype: doctype,
                                           vocab: vocab)
    validation::Context.new(root: root, log: nil, state: state, shared: nil,
                            registry: registry)
  end

  def signature(issues)
    issues.map { |i| [i.code, i.location, i.message, i.params] }
  end

  def rule_class(name)
    validation::Rules.const_get(name)
  end

  # rule class => [[label, body, expected finding count, options]]
  fixtures = {
    "DoctypeRule" => [
      ["unknown", "<sections/>", 1, { doctype: "pizza" }],
      ["known", "<sections/>", 0, { doctype: "technical-report" }],
      ["empty", "<sections/>", 0, { doctype: "" }],
      ["amendment opt-out", "<sections/>", 0, { doctype: "pizza", amd: true }],
    ],
    "IterationRule" => [
      ["number", '<bibdata><status><iteration>3</iteration></status></bibdata>', 0],
      ["negative", '<bibdata><status><iteration>-1</iteration></status></bibdata>', 1],
    ],
    "LocalityErefsRule" => [
      ["undated", '<sections><clause id="c"><p><eref citeas="ISO 1234"><localityStack><locality type="clause"><referenceFrom>5</referenceFrom></locality></localityStack></eref></p></clause></sections>', 1],
      ["dated", '<sections><clause id="c"><p><eref citeas="ISO 1234:2020"><localityStack><locality type="clause"><referenceFrom>5</referenceFrom></locality></localityStack></eref></p></clause></sections>', 0],
      ["spaced year", '<sections><clause id="c"><p><eref citeas="ISO 1234: 2020"><localityStack><locality type="clause"><referenceFrom>5</referenceFrom></locality></localityStack></eref></p></clause></sections>', 0],
      ["dash", '<sections><clause id="c"><p><eref citeas="ISO 1234:–"><localityStack><locality type="clause"><referenceFrom>5</referenceFrom></locality></localityStack></eref></p></clause></sections>', 0],
    ],
    "NormativeBibitemRule" => [
      ["non ISO publisher", '<bibliography><references normative="true"><bibitem id="b"><contributor><role type="publisher"/><organization><name>Other</name></organization></contributor></bibitem></references></bibliography>', 1],
      ["ISO publisher", '<bibliography><references normative="true"><bibitem id="b"><contributor><role type="publisher"/><organization><abbreviation>ISO</abbreviation></organization></contributor></bibitem></references></bibliography>', 0],
    ],
    "ListDepthRule" => [
      ["deep", '<sections><clause id="c">' + '<ol><li><p>X</p>' * 5 + '</li></ol>' * 5 + '</clause></sections>', 1],
      ["allowed", '<sections><clause id="c">' + '<ol><li><p>X</p>' * 4 + '</li></ol>' * 4 + '</clause></sections>', 0],
    ],
    "ListCountRule" => [
      ["two lists", '<sections><clause id="c"><ol><li><p>A</p></li></ol><ol><li><p>B</p></li></ol></clause></sections>', 1],
      ["one list", '<sections><clause id="c"><ol><li><p>A</p></li></ol></clause></sections>', 0],
    ],
    "StyleMixedListsRule" => [
      ["ordered in unordered", '<sections><clause id="c"><ul id="u"><li><p>A</p><ol><li><p>B</p></li></ol></li></ul></clause></sections>', 1],
      ["same nesting", '<sections><clause id="c"><ol id="u"><li><p>A</p><ol><li><p>B</p></li></ol></li></ol></clause></sections>', 0],
    ],
    "TitleFirstLevelRule" => [
      ["untitled", '<sections><clause id="c"><p>X</p></clause></sections>', 1],
      ["titled", '<sections><clause id="c"><title>X</title></clause></sections>', 0],
      ["untitled annex clause", '<annex id="a"><title>A</title><clause id="c"><p>X</p></clause></annex>', 1],
    ],
    "TitleSiblingsConsistencyRule" => [
      ["mixed", '<sections><clause id="c"><title>X</title><clause id="a"><title>A</title></clause><clause id="b"><p>B</p></clause></clause></sections>', 1],
      ["uniform", '<sections><clause id="a"><title>A</title></clause><clause id="b"><title>B</title></clause></sections>', 0],
    ],
    "StyleEmptyClauseRule" => [
      ["empty sections", '<sections/>', 1],
      ["empty clause", '<sections><clause id="c"><title>C</title></clause></sections>', 1],
      ["note only", '<sections><clause id="c"><title>C</title><note><p>N</p></note></clause></sections>', 1],
      ["content", '<sections><clause id="c"><title>C</title><p>P</p></clause></sections>', 0],
      ["appendix", '<annex id="a"><appendix id="x"><title>X</title></appendix></annex>', 1],
    ],
    "TitlePairingRule" => [
      ["one language", '<bibdata><title type="title-main" language="en">Main</title></bibdata>', 1],
      ["both languages", '<bibdata><title type="title-main" language="en">Main</title><title type="title-main" language="fr">Principal</title></bibdata>', 0],
      ["all unpaired", '<bibdata><title type="title-intro" language="en">Intro</title><title type="title-main" language="en">Main</title><title type="title-part" language="en">Part</title></bibdata>', 3],
    ],
    "StyleNoBoxesRule" => [
      ["box", '<sections><clause id="c"><admonition id="a"><p>X</p></admonition></clause></sections>', 1],
      ["note", '<sections><clause id="c"><admonition type="note" id="a"><p>X</p></admonition></clause></sections>', 0],
    ],
    "TechnicalCommitteeTypeRule" => [
      ["invalid", '<bibdata><contributor><role><description>committee</description></role><organization><subdivision type="Technical committee" subtype="ZZZ"/></organization></contributor></bibdata>', 1],
      ["missing subtype", '<bibdata><contributor><role><description>committee</description></role><organization><subdivision type="Technical committee"/></organization></contributor></bibdata>', 1],
      ["valid", '<bibdata><contributor><role><description>committee</description></role><organization><subdivision type="Technical committee" subtype="TC"/></organization></contributor></bibdata>', 0],
    ],
    "SubcommitteeTypeRule" => [
      ["invalid", '<bibdata><contributor><role><description>committee</description></role><organization><subdivision type="Subcommittee" subtype="ZZZ"/></organization></contributor></bibdata>', 1],
      ["valid", '<bibdata><contributor><role><description>committee</description></role><organization><subdivision type="Subcommittee" subtype="SC"/></organization></contributor></bibdata>', 0],
    ],
    "SymbolsSectionContentRule" => [
      ["paragraph", '<sections><definitions id="d"><title>S</title><p>X</p></definitions></sections>', 1],
      ["definition list", '<sections><definitions id="d"><title>S</title><dl><dt>X</dt><dd><p>Y</p></dd></dl></definitions></sections>', 0],
    ],
    "BrokenXrefRule" => [
      ["bibliographic text is not an anchor", '<sections><clause id="c"><p><xref target="ISO 1">X</xref></p></clause></sections>', 1],
      ["missing", '<sections><clause id="c"><p><xref target="missing">X</xref></p></clause></sections>', 1],
      ["existing", '<sections><clause id="c"><p><xref target="c">X</xref></p></clause></sections>', 0],
      ["empty", '<sections><clause id="c"><p><xref target="">X</xref></p></clause></sections>', 0],
    ],
    "ForewordStructureRule" => [
      ["subclause", '<preface><foreword id="f"><clause id="c"><title>S</title></clause></foreword></preface>', 1],
      ["flat", '<preface><foreword id="f"><p id="p">Text</p></foreword></preface>', 0],
    ],
    "SymbolsSectionCountRule" => [
      ["two sections", '<sections><definitions id="d1"><title>A</title></definitions><definitions id="d2"><title>B</title></definitions></sections>', 1],
      ["section and annex", '<sections><definitions id="d1"><title>A</title></definitions></sections><annex id="a"><definitions id="d2"><title>B</title></definitions></annex>', 1],
      ["one section", '<sections><definitions id="d1"><title>A</title></definitions></sections>', 0],
      ["vocabulary exemption", '<sections><definitions id="d1"><title>A</title></definitions><definitions id="d2"><title>B</title></definitions></sections>', 0, { vocab: true }],
    ],
    "SymbolsInAnnexRule" => [
      ["in sections", '<sections><definitions id="d1"><title>A</title></definitions></sections>', 1, { vocab: true }],
      ["in annex", '<annex id="a"><definitions id="d1"><title>A</title></definitions></annex>', 0, { vocab: true }],
    ],
    "ScopePresenceRule" => [
      ["no scope", '<sections><clause id="c"><title>X</title></clause></sections>', 1],
      ["no sections", "", 1],
      ["nested scope only", '<sections><clause id="c"><title>X</title><clause id="s" type="scope"><title>S</title></clause></clause></sections>', 1],
      ["scope", '<sections><clause id="s" type="scope"><title>S</title></clause></sections>', 0],
    ],
    "NormativeReferencesPresenceRule" => [
      ["informative only", '<bibliography><references id="r" normative="false"><title>B</title></references></bibliography>', 1],
      ["no bibliography", '<sections><clause id="c"><title>X</title></clause></sections>', 0],
      ["normative", '<bibliography><references id="r" normative="true"><title>N</title></references></bibliography>', 0],
    ],
    "TermsPresenceRule" => [
      ["no terms", '<sections><clause id="c"><title>X</title></clause></sections>', 1],
      ["empty sections", "<sections/>", 1],
      ["no sections", "", 0],
      ["terms", '<sections><terms id="t"><title>T</title></terms></sections>', 0],
    ],
    "ScopeSubclausesRule" => [
      ["second scope has subclause", '<sections><clause id="s1" type="scope"><title>A</title></clause><clause id="s2" type="scope"><title>B</title><clause id="x"><title>C</title></clause></clause></sections>', 1],
      ["flat", '<sections><clause id="s" type="scope"><title>S</title></clause></sections>', 0],
    ],
    "OnlyChildClauseRule" => [
      ["in sections", '<sections><clause id="p"><title>P</title><clause id="c"><title>C</title></clause></clause></sections>', 1],
      ["in annex without sections", '<annex id="a"><clause id="p"><title>P</title><clause id="c"><title>C</title></clause></clause></annex>', 0],
      ["nested chain", '<sections><clause id="p"><title>P</title><clause id="c"><title>C</title><clause id="g"><title>G</title></clause></clause></clause></sections>', 2],
      ["top-level only child", '<sections><clause id="p"><title>P</title></clause></sections>', 0],
      ["two children", '<sections><clause id="p"><title>P</title><clause id="a"><title>A</title></clause><clause id="b"><title>B</title></clause></clause></sections>', 0],
    ],
    "ForewordPresenceRule" => [
      ["other preface content", '<preface><introduction id="i"><title>I</title></introduction></preface>', 1],
      ["empty preface", "<preface/>", 1],
      ["foreword", '<preface><foreword id="f"><p id="p">Text</p></foreword></preface>', 0],
    ],
  }

  it "has the accepted engine loaded" do
    expect(catalog.available?).to be(true)
  end

  it "maps every migrated class to a catalog rule with the class's code" do
    classes = validation::ComposedRegistry.for(flavor: nil).declarative_classes
    by_id = catalog.rule_set.rules.to_h { |rule| [rule.id, rule] }
    classes.each do |klass|
      expect(klass.declarative_rule_ids).not_to be_empty
      klass.declarative_rule_ids.each do |id|
        codes = klass.respond_to?(:declarative_codes) ? klass.declarative_codes : [klass.code_value]
        expect(codes).to include(by_id.fetch(id).code)
      end
    end
    expect(classes.flat_map(&:declarative_rule_ids)).to match_array(by_id.keys)
  end

  fixtures.each do |class_name, cases|
    describe class_name do
      cases.each do |label, body, count, options|
        it "matches the retained check: #{label}" do
          klass = rule_class(class_name)
          context = context_for(document(body), **(options || {}))
          rule = klass.new
          expect(catalog.findings_for(klass, context)).not_to be_nil

          issues = rule.applicable?(context) ? rule.check(context) : []
          retained = rule.applicable?(context) ? rule.send(:legacy_check, context) : []
          expect(issues.size).to eq(count)
          expect(signature(issues)).to eq(signature(retained))
        end
      end
    end
  end

  describe "model projection" do
    it "reports the real model and a strict XML node without mutating it" do
      context = context_for(document('<sections><clause id="c"><title>X</title></clause></sections>'))
      before = context.root.to_xml
      finding = catalog.findings_for(rule_class("ScopePresenceRule"), context).first

      expect(finding.source_model).to equal(context.root)
      expect(finding.node).to be_a(Nokogiri::XML::Node)
      expect(finding.code).to eq("ISO_29")
      expect(context.root.to_xml).to eq(before)
    end

    it "projects once per validation run" do
      context = context_for(document("<sections/>"))
      projection = Metanorma::Standoc::Validate::Rules::DocumentProjection
      allow(projection).to receive(:parse_model).and_call_original

      catalog.findings_for(rule_class("ScopePresenceRule"), context)
      catalog.findings_for(rule_class("TermsPresenceRule"), context)
      expect(projection).to have_received(:parse_model).with(context.root).once
    end

    it "fails explicitly when the projection cannot be built" do
      context = context_for(document("<sections/>"))
      allow(Metanorma::Standoc::Validate::Rules::DocumentProjection)
        .to receive(:parse_model).and_raise(StandardError, "projection failure")

      expect { rule_class("ScopePresenceRule").new.check(context) }
        .to raise_error(catalog::ProjectionError, /projection failure/)
    end
  end

  describe "BSI import composition" do
    let(:imports) do
      [{ "profile" => "directives", "cite_as" => "BSI style",
         "except" => ["ISO_43"],
         "severity" => { "ScopePresenceRule" => "warning" } }]
    end
    let(:composed) do
      validation::ComposedRegistry.compose(flavor: "bsi", imports: imports)
    end
    let(:bsi_body) do
      '<preface><introduction id="i"><title>I</title></introduction></preface>' \
        '<sections><clause id="p"><title>P</title>' \
        '<clause id="c"><title>C</title></clause></clause></sections>' \
        '<bibliography><references id="r" normative="false"><title>B</title>' \
        "</references></bibliography>"
    end

    it "applies the import selection and exception to the rule set" do
      ids = composed.declarative_rule_set.rules.map(&:id)
      expect(ids).to include("iso.scope.presence", "iso.foreword.presence")
      expect(ids).not_to include("iso.clause.no-only-child")
      # ISO_27 cites the House Style only, so a directives import omits it.
      expect(ids).not_to include("iso.symbols.annex-only")
    end

    it "keeps severity and citation in composition metadata" do
      metadata = composed.declarative_metadata
      expect(metadata["iso.scope.presence"]).to include(
        code: "ISO_29", severity: "warning", cite_as: "BSI style",
        source: "directives"
      )
      expect(metadata["iso.foreword.presence"]).to include(severity: nil)
      composed.declarative_rule_set.rules.each do |rule|
        expect(rule.code).to eq(metadata.fetch(rule.id)[:code])
      end
    end

    it "emits the same issues as the retained checks for a BSI document" do
      context = context_for(document(bsi_body, flavor: "bsi"),
                            registry: composed)
      rules = composed.declarative_classes.map(&:new)
        .select { |rule| rule.applicable?(context) }
      issues = rules.flat_map { |rule| rule.check(context) }
      retained = rules.flat_map { |rule| rule.send(:legacy_check, context) }

      expect(issues.map(&:code))
        .to include("ISO_29", "ISO_30", "ISO_31", "ISO_57")
      expect(issues.map(&:code)).not_to include("ISO_43")
      expect(signature(issues)).to eq(signature(retained))
    end

    it "drops the imported declarative rule when a flavor shadows its code" do
      stub_const("Metanorma::SpecShadow", Module.new)
      stub_const("Metanorma::SpecShadow::Validation", Module.new)
      stub_const("Metanorma::SpecShadow::Validation::Rules", Module.new)
      stub_const("Metanorma::SpecShadow::Validation::Rules::ScopePresenceRule",
                 Class.new(validation::Rules::Base) { code "ISO_29" })
      shadowed = validation::ComposedRegistry.compose(
        flavor: "spec_shadow", imports: [{ "profile" => "directives" }],
      )

      expect(shadowed.declarative_rule_set.rules.map(&:id))
        .not_to include("iso.scope.presence")
      expect(shadowed.code_backed_classes).to include(
        Metanorma::SpecShadow::Validation::Rules::ScopePresenceRule,
      )
    end

    it "exports the composed rules as portable Schematron" do
      export = Metanorma::Standoc::Validate::Rules::Schematron
        .export(composed.declarative_rule_set)

      expect(export.code_backed).to include("iso.sequence.initial", "iso.asset.referenced")
      expect(export.xml).to include("iso.scope.presence")
      expect(export.xml).not_to include("iso.clause.no-only-child")
    end
  end
end
