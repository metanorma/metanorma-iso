# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe "composed declarative validation assets" do
  let(:validation) { Metanorma::Iso::Validation }
  let(:rules) { validation::Rules }

  def context_for(body, registry)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="bsi">
        <bibdata><docidentifier>BS 1</docidentifier></bibdata>#{body}
      </metanorma>
    XML
    validation::Context.new(root: Metanorma::Iso::Document::Root.from_xml(xml),
      state: validation::ConverterState.new(document: "spec", amd: false, vocab: false),
      registry: registry, shared: validation::SharedState.new)
  end

  def compose(severity = "warning", cite_as = "BSI style", rulesets: [])
    validation::ComposedRegistry.compose(flavor: "bsi", imports: [
      { "class" => ["ScopePresenceRule", "StylePerCentRule"],
        "severity" => severity, "cite_as" => cite_as },
    ], rulesets: rulesets)
  end

  def asset(text)
    Dir.mktmpdir("iso-rule-asset") do |dir|
      path = File.join(dir, "rules.yml")
      File.write(path, text)
      yield path
    end
  end

  it "declares every concrete ISO class, including code-backed prose" do
    catalog = rules::DeclarativeCatalog
    expect(catalog.registered_classes).to eq(validation::RuleRegistry.new.all)
    entries = catalog.registrations
    expect(entries.size).to eq(100)
    expect(entries.find { |entry| entry["class"] == "StylePerCentRule" })
      .to include("code" => "ISO_109", "implementation" => "code")
    exported = compose.schematron
    expect(exported.code_backed).to include("iso.code.StylePerCentRule")
    expect(exported.xml).to include("iso.scope.presence")
  end

  it "discovers a flavor's own profile imports and E2 assets from its gem layout" do
    Dir.mktmpdir("flavor-gem") do |dir|
      profile_dir = File.join(dir, "lib/metanorma/bsi/validation_profile")
      asset_dir = File.join(dir, "lib/metanorma/bsi/validation/rulesets")
      FileUtils.mkdir_p([profile_dir, asset_dir])
      File.write(File.join(profile_dir, "imports.yml"), <<~YAML)
        schema: metanorma-validation-profile/1
        flavor: bsi
        imports:
          - class: [ScopePresenceRule]
            cite_as: BSI style
            severity: warning
      YAML
      File.write(File.join(asset_dir, "house-style.yml"), <<~YAML)
        schema: metanorma-validation-rules/1
        disable: [iso.scope.presence]
        rules: []
      YAML
      spec = Gem::Specification.new { |gem| gem.name = "metanorma-bsi"; gem.version = "1.0" }
      spec.full_gem_path = dir
      registry = validation::ComposedRegistry.for_gem(flavor: "bsi", spec: spec)
      expect(registry.all).to eq([rules::ScopePresenceRule])
      expect(registry.declarative_rule_set.rules).to eq([])
      expect(registry.execute(context_for("<sections/>", registry), validation::Profile::DEFAULT)).to eq([])
    end
  end

  it "executes code registrations and portable checks through the active composition" do
    registry = compose
    context = context_for('<sections><clause id="c"><p>5 percent</p></clause></sections>', registry)
    issues = registry.execute(context, validation::Profile::DEFAULT)
    expect(issues.map(&:code)).to include("ISO_29", "ISO_109")
    expect(issues.map(&:severity).uniq).to eq(["warning"])
    expect(issues.all? { |issue| issue.message.end_with?("(BSI style)") }).to be(true)
  end

  it "applies asset replacement and disable to actual engine findings" do
    asset(<<~YAML) do |path|
      schema: metanorma-validation-rules/1
      namespaces: {m: https://www.metanorma.org/ns/standoc}
      rules:
        - id: iso.scope.presence
          code: ISO_29
          context: /m:metanorma
          target: ./m:sections/m:clause[@type='scope' and @id='special']
          check: required
    YAML
      registry = compose(rulesets: [path])
      ctx = context_for('<sections><clause id="s" type="scope"><title>Scope</title></clause></sections>', registry)
      expect(registry.execute(ctx, validation::Profile::DEFAULT).map(&:code)).to eq(["ISO_29"])
      expect(rules::ScopePresenceRule.new.send(:legacy_check, ctx)).to eq([])
    end
    asset(<<~YAML) do |path|
      schema: metanorma-validation-rules/1
      disable: [iso.scope.presence]
      rules: []
    YAML
      registry = compose(rulesets: [path])
      expect(registry.execute(context_for("<sections/>", registry), validation::Profile::DEFAULT)).to eq([])
    end
  end

  it "executes additional flavor asset declarations with explicit projection locations" do
    asset(<<~YAML) do |path|
      schema: metanorma-validation-rules/1
      namespaces: {m: https://www.metanorma.org/ns/standoc}
      rules:
        - id: bsi.preface
          code: ISO_57
          context: /m:metanorma
          target: ./m:preface/m:foreword
          check: required
    YAML
      registry = compose(rulesets: [path])
      issues = registry.execute(context_for("<sections/>", registry), validation::Profile::DEFAULT)
      extra = issues.find { |issue| issue.code == "ISO_57" }
      expect(extra.location).to start_with("XML projection ")
    end
  end

  it "keeps severity and citation scoped across compositions and reuse of a real log" do
    log = Metanorma::Utils::Log.new(Metanorma::Iso::Converter::ISO_LOG_MESSAGES.transform_values(&:dup))
    report = validation::Report.new(document: "spec")
    translator = validation::IssueTranslator.new(log: log, report: report)
    [["warning", "BSI style"], ["error", "Second style"]].each do |severity, cite|
      registry = compose(severity, cite)
      issues = registry.execute(context_for("<sections/>", registry), validation::Profile::DEFAULT)
      translator.translate_layer3(issues)
      expect(log.validation_issue).to be_nil
    end
    log.add("ISO_29", nil, display: false)
    expect(log.messages.map { |entry| entry[:severity] }).to eq([1, 2, 2])
    expect(log.messages[0][:error]).to end_with("(BSI style)")
    expect(log.messages[1][:error]).to end_with("(Second style)")
    expect(log.messages[2][:error]).not_to include("style")
    expect(report.issues.map(&:severity)).to eq(%w[warning error])
    expect(report.valid?).to be(false)
  end

  it "preserves the real logger's existing code suppression" do
    registry = compose
    log = Metanorma::Utils::Log.new(Metanorma::Iso::Converter::ISO_LOG_MESSAGES.transform_values(&:dup))
    log.suppress_log[:error_ids] = ["ISO_29"]
    translator = validation::IssueTranslator.new(log: log, report: validation::Report.new)
    translator.translate_layer3(registry.execute(context_for("<sections/>", registry), validation::Profile::DEFAULT))
    expect(log.messages).to eq([])
    expect(log.validation_issue).to be_nil
  end

  it "preserves code opt-outs for additional asset rules" do
    asset(<<~YAML) do |path|
      schema: metanorma-validation-rules/1
      namespaces: {m: https://www.metanorma.org/ns/standoc}
      rules:
        - id: bsi.preface
          code: ISO_57
          context: /m:metanorma
          target: ./m:preface/m:foreword
          check: required
    YAML
      registry = compose(rulesets: [path])
      profile = validation::Profile.new(except_codes: ["ISO_57", "ISO_29"])
      expect(registry.execute(context_for("<sections/>", registry), profile)).to eq([])
    end
  end

  it "rejects an unknown disabled id and invalid severity" do
    asset("schema: metanorma-validation-rules/1\nrules: []\ndisable: [typo]\n") do |path|
      expect { compose(rulesets: [path]).declarative_rule_set }
        .to raise_error(Metanorma::Standoc::Validate::Rules::RuleError, /unknown/)
    end
    expect { compose("banana") }.to raise_error(ArgumentError, /severity/)
  end

  it "fails explicitly for an unsupported model root" do
    registry = compose
    context = context_for("<sections/>", registry)
    context.root = Object.new
    expect { registry.execute(context, validation::Profile::DEFAULT) }
      .to raise_error(rules::DeclarativeCatalog::ProjectionError)
  end
end
