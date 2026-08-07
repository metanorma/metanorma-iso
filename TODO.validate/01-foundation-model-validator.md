# 01 — Foundation: ModelValidator, Context, Report, RuleRegistry

## Why
Today, post-XML validation lives in three places (Ruby XPath validators, the
inherited Standoc validators, and Jing-validated RelaxNG schemas). The
end-state is one model-driven validator pipeline: deserialize the XML to
`Metanorma::IsoDocument::Root`, run Layer 1 declarations + Layer 2 collection
validators + Layer 3 Rule classes against the model, and emit findings via a
single IssueTranslator that writes to both `@log` (existing pipeline) and a
new structured `Report` (serializable to JSON/YAML/XML).

This TODO builds the foundation with **zero behavior change** — the new
pipeline runs alongside the existing one as a no-op. Subsequent TODOs migrate
rules one at a time and delete their predecessors.

## Files to create

### Library code (`lib/metanorma/iso/`)
- `validation.rb` — `module Metanorma::Iso::Validation`; declares autoloads for
  `ModelValidator`, `Context`, `ConverterState`, `SharedState`, `Issue`,
  `Report`, `IssueTranslator`, `RuleRegistry`, `Rules`, `Reporter`.
- `validation/model_validator.rb` — orchestrator.
  Public API: `.run(xml_string, log:, state:, output_format: :log) -> Report`.
- `validation/context.rb` — `Context` struct (root:, log:, state:, shared:).
- `validation/converter_state.rb` — frozen Struct of converter state (lang,
  script, doctype, vocab, amd, i18n, novalid).
- `validation/shared_state.rb` — mutable Struct for cross-rule state (doc_ids,
  doc_anchors, doc_xrefs, id_seq, anchor_seq).
- `validation/issue.rb` — `Issue < Lutaml::Model::Serializable`.
- `validation/report.rb` — `Report < Lutaml::Model::Serializable`.
- `validation/issue_translator.rb` — single sink translating Layer 1 errors
  and Layer 3 Issues into `@log.add` + `Report.add_issue`.
- `validation/rule_registry.rb` — `RuleRegistry#all` discovers Rule classes
  by walking `Rules.constants`.

### Rules namespace
- `validation/rules.rb` — `module Rules`; autoloads `Base` only (empty registry
  at foundation).
- `validation/rules/base.rb` — `Base < Lutaml::Model::Validation::Rule` with
  DSL (`code`, severity/category lookup from `ISO_LOG_MESSAGES`) and shared
  helpers (`descendants`, `extract_text`, `closest_ancestor`, `each_anchored`,
  `build_issue`).

### Reporters
- `validation/reporter.rb` — `module Reporter`; autoloads `Base`, `Text`,
  `Json`, `Yaml`.
- `validation/reporter/base.rb` — abstract `format(report) -> String`.
- `validation/reporter/text.rb` — multi-line text format.
- `validation/reporter/json.rb` — delegates to `report.to_json`.
- `validation/reporter/yaml.rb` — delegates to `report.to_yaml`.

### Specs (`spec/metanorma/validation/`)
- `model_validator_spec.rb` — orchestrator behavior; zero-error pass-through;
  output-format variants.
- `rule_registry_spec.rb` — discovery.
- `issue_spec.rb`, `report_spec.rb` — model behavior + JSON/YAML round-trips.
- `issue_translator_spec.rb` — Layer 1 + Layer 3 translation paths.
- `reporter/text_spec.rb`, `reporter/json_spec.rb`, `reporter/yaml_spec.rb`.

## Files to modify
- `lib/metanorma/iso.rb` — add `autoload :Validation,
  "metanorma/iso/validation"`.
- `lib/metanorma/iso/validate.rb` — call `Metanorma::Iso::ModelValidator.run`
  after `content_validate` and `schema_validate` (foundation: produces a
  Report, but does NOT yet merge findings into `@log`; the orchestrator is a
  no-op for behavior). Existing validators continue to fire unchanged.

## Approach

### Orchestrator

```ruby
class Metanorma::Iso::Validation::ModelValidator
  def self.run(xml_string, log:, state:, output_format: :log)
    root = deserialize(xml_string)
    context = Context.new(root: root, log: log, state: state, shared: SharedState.new)
    report = Report.new(document: state.document, generated_at: Time.now.utc.iso8601)
    translator = IssueTranslator.new(log: log, report: report)

    translator.translate_layer1(root&.validate || [])
    # Layer 2 collection validators go here in a later TODO.
    translator.translate_layer3(run_rules(context))

    output = format_report(report, output_format) unless output_format == :log
    output ? [report, output] : report
  end

  class << self
    private

    def deserialize(xml_string)
      Metanorma::IsoDocument::Root.from_xml(xml_string)
    rescue StandardError
      nil
    end

    def run_rules(context)
      registry = Lutaml::Model::Validation::Registry.new
      RuleRegistry.new.all.each { |klass| registry.register(klass.new) }
      Lutaml::Model::Validation.validate(context, registry)
    end

    def format_report(report, format)
      klass = { text: Reporter::Text, json: Reporter::Json,
                yaml: Reporter::Yaml }.fetch(format)
      klass.new.format(report)
    end
  end
end
```

### Context / State structs

```ruby
Metanorma::Iso::Validation::ConverterState = Struct.new(
  :lang, :script, :doctype, :vocab, :amd, :i18n, :novalid, :document,
  keyword_init: true
) do
  def self.from_converter(conv)
    new(lang: conv.lang, script: conv.script, doctype: conv.doctype,
        vocab: conv.vocab, amd: conv.amd, i18n: conv.i18n,
        novalid: conv.novalid, document: conv.localdir)
  end
end

Metanorma::Iso::Validation::SharedState = Struct.new(
  :doc_ids, :doc_anchors, :doc_xrefs, :id_seq, :anchor_seq,
  keyword_init: true
) do
  def initialize(*)
    super
    self.doc_ids ||= {}
    self.doc_anchors ||= {}
    self.doc_xrefs ||= {}
    self.id_seq ||= []
    self.anchor_seq ||= []
  end
end

Metanorma::Iso::Validation::Context = Struct.new(
  :root, :log, :state, :shared, keyword_init: true
)
```

### Issue / Report (lutaml-model)

```ruby
class Metanorma::Iso::Validation::Issue < Lutaml::Model::Serializable
  SEVERITY_BY_CODE_VALUE = { 0 => "info", 1 => "warning", 2 => "error" }.freeze

  attribute :code, :string
  attribute :severity, :string
  attribute :category, :string
  attribute :message, :string
  attribute :location, :string
  attribute :params, :string, collection: true

  def self.from_finding(code:, location:, params:)
    spec = Metanorma::Iso::LOG_MESSAGES[code.to_sym] ||
           { error: "%s", severity: 2, category: "Unknown" }
    new(code: code.to_s, severity: SEVERITY_BY_CODE_VALUE.fetch(spec[:severity], "error"),
        category: spec[:category], message: spec[:error] % Array(params),
        location: location, params: Array(params).map(&:to_s))
  end

  def error?   = severity == "error"
  def warning? = severity == "warning"
  def info?    = severity == "info"
end

class Metanorma::Iso::Validation::Report < Lutaml::Model::Serializable
  attribute :document, :string
  attribute :generated_at, :string
  attribute :valid, :boolean, default: -> { true }
  attribute :issues, Metanorma::Iso::Validation::Issue, collection: true, default: -> { [] }

  def add_issue(code:, location:, params:)
    issue = Issue.from_finding(code: code, location: location, params: params)
    issues << issue
    self.valid = false if issue.error?
    issue
  end

  def errors   = issues.select(&:error?)
  def warnings = issues.select(&:warning?)
  def infos    = issues.select(&:info?)
end
```

### IssueTranslator (DRY seam)

```ruby
class Metanorma::Iso::Validation::IssueTranslator
  def initialize(log:, report:)
    @log = log
    @report = report
  end

  # Layer 1 errors: Lutaml::Model::InvalidValueError, RequiredAttributeMissingError, etc.
  def translate_layer1(errors)
    errors.each do |err|
      code, params = classify_layer1_error(err)
      add(code, location: err.respond_to?(:attribute_name) ? err.attribute_name : nil,
          params: params)
    end
  end

  # Layer 3 Issues: Lutaml::Model::Validation::Issue
  def translate_layer3(issues)
    issues.each do |issue|
      add(issue.code, location: issue.location, params: issue.params)
    end
  end

  private

  def add(code, location:, params:)
    @log.add(code, nil, params: params) if @log
    @report.add_issue(code: code, location: location, params: params)
  end

  def classify_layer1_error(err)
    # Maps Layer 1 error classes to ISO_N codes; extended as Layer 1
    # declarations are added in TODOs 02-03.
    [err.class.name.split("::").last, []]
  end
end
```

### RuleRegistry (OCP)

```ruby
class Metanorma::Iso::Validation::RuleRegistry
  def all
    Metanorma::Iso::Validation::Rules.constants.sort
      .map { |c| Metanorma::Iso::Validation::Rules.const_get(c) }
      .select { |c| c.is_a?(Class) && c < Metanorma::Iso::Validation::Rules::Base }
  end
end
```

### Base rule

```ruby
class Metanorma::Iso::Validation::Rules::Base < Lutaml::Model::Validation::Rule
  class << self
    attr_reader :code_value

    def code(value)
      @code_value = value.to_s
    end
  end

  def code
    self.class.code_value || raise(NotImplementedError,
      "#{self.class} must declare `code \"ISO_N\"`")
  end

  def category
    spec[:category]
  end

  def severity
    value = spec[:severity]
    return "warning" if value == 1
    return "info" if value.zero?
    "error"
  end

  def applicable?(_context)
    true
  end

  private

  def spec
    Metanorma::Iso::LOG_MESSAGES.fetch(code_value_sym, default_spec)
  end

  def code_value_sym
    code.to_sym
  end

  def default_spec
    { category: "Unknown", severity: 2, error: "%s" }
  end

  def build_issue(location:, params:)
    Lutaml::Model::Validation::Issue.new(
      code: code, severity: severity, category: category,
      message: spec[:error] % Array(params),
      location: location, params: Array(params).map(&:to_s)
    )
  end
end
```

### Shared helpers (TreeTraversal concern)

Add `descendants`, `extract_text`, `closest_ancestor`, `each_anchored` to Base
as needed for later TODOs. Foundation ships minimal versions; rules add
specialized helpers as they need them.

## Specs
Each new file gets a focused spec:
- `model_validator_spec.rb`: empty XML → Report with no issues; valid rice XML
  → Report with no issues and `valid: true`; `output_format: :json` → returns
  `[Report, String]` where String parses as JSON.
- `report_spec.rb`: `report.to_json` round-trips through `Report.from_json`;
  same for YAML.
- `issue_translator_spec.rb`: feeds a real `Lutaml::Model::InvalidValueError`
  → translator calls `@log.add` with mapped code AND adds an Issue.
- `rule_registry_spec.rb`: defines a stub Rule class in the Rules namespace,
  asserts `RuleRegistry#all` includes it.

All specs use real `Lutaml::Model::Serializable` instances — never `double()`.

## Acceptance
- `bundle exec rspec spec/metanorma/validation/model_validator_spec.rb` green.
- `bundle exec rspec spec/metanorma/validation/` (single file at a time) green.
- Existing validator specs unchanged.
- `bundle exec metanorma -t iso spec/examples/rice.adoc` produces the SAME
  error log as before (no new findings, no removed findings).
- `grep -rn "require_relative" lib/metanorma/iso/validation/` returns nothing.
- `grep -rn "Nokogiri" lib/metanorma/iso/validation/` returns nothing.
- `grep -rn "double(" spec/metanorma/validation/` returns nothing.

## RNG counterpart to remove
None at foundation. Each rule-migration TODO identifies its RNG counterpart.
