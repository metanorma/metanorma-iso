# 35 — Public API: standalone validation entry points

## Why

The layered architecture (see ARCHITECTURE.md) makes validation a
first-class, independently invokable operation. Today's pipeline
welds validation to compile; the public API below exposes it
directly. This is a **pure addition** — no migration required,
builds entirely on the foundation already in place.

## Programmatic API

```ruby
# Validate an XML string
report = Metanorma::Iso.validate(xml_string)
report.valid?              # => true / false
report.errors              # => [#<Issue code: "ISO_5", ...>]
report.warnings
report.infos
report.summary             # => "rice.adoc: 3 findings (1 errors, 2 warnings, 0 info)"
report.to_json             # => JSON for tooling integration
report.to_yaml             # => YAML for diff-friendly output
report.to_xml              # => XML (machine-readable)

# With options
report = Metanorma::Iso.validate(
  xml_string,
  lang: "en",
  script: "Latn",
  doctype: "international-standard",
  output_format: :json          # returns [report, json_string]
)

# Pre-rendered text output (CLI-style)
text = Metanorma::Iso::Validation::Reporter::Text.new.format(report)
puts text
```

### Files (new)

- `lib/metanorma/iso/api.rb` — public API module
  ```ruby
  module Metanorma
    module Iso
      module API
        def self.validate(xml, **opts)
          state = build_state(**opts)
          Metanorma::Iso::Validation::ModelValidator.run(
            xml, log: nil, state: state,
            output_format: opts.fetch(:output_format, :log)
          )
        end
      end
    end
  end
  ```
- `lib/metanorma/iso.rb` — add `autoload :API, "metanorma/iso/api"`

### Backward compatibility

The existing `Metanorma::Iso::Converter` continues to validate via
its internal `model_validate(doc)` call. The public API is a new
entry point — same engine, separate caller.

## CLI

```bash
$ metanorma-iso validate document.xml
$ metanorma-iso validate document.xml --format json
$ metanorma-iso validate document.xml --format yaml
$ metanorma-iso validate document.xml --format text --output errors.txt
$ metanorma-iso validate document.xml --strict   # treat warnings as errors
```

### Files (new)

- `exe/metanorma-iso` — Thor-based CLI
  ```ruby
  class MetanormaIsoCLI < Thor
    desc "validate FILE", "Validate a metanorma-iso XML document"
    option :format, default: :text, enum: [:text, :json, :yaml]
    option :output, type: :string
    option :strict, type: :boolean, default: false
    def validate(file)
      xml = File.read(file)
      report, output = Metanorma::Iso::API.validate(
        xml, output_format: options[:format].to_sym
      )
      write_output(options, output || render_text(report))
      exit(report.valid? && (!options[:strict] || report.errors.empty?) ? 0 : 1)
    end
  end
  ```

## Why this matters

| Use case                           | Procedural pipeline | This architecture |
|------------------------------------|---------------------|-------------------|
| CI check on PR                     | full compile + scrape .err.html | `metanorma-iso validate --format json` |
| Editor integration                 | not possible        | LSP server reads JSON report |
| Diff validation results across runs| parse HTML          | `report.to_yaml`, diff |
| Programmatic rule selection        | hack @log           | Lutaml::Model::Validation::Profile |
| Skip structural checks             | not possible        | skip Layer 1 (don't call `validate`) |
| Skip style warnings                | grep STANDOC_48     | Profile excludes :style rules |

## Specs

- `spec/metanorma/api_spec.rb` — programmatic API contract
- `spec/exe/metanorma_iso_spec.rb` — CLI smoke tests (text/json/yaml output)

## Acceptance

- `Metanorma::Iso.validate(xml)` returns a Report for a valid document
  with no issues.
- The same call returns a Report with the expected findings for
  invalid input (smoke-tested against the pizza-doctype fixture).
- `metanorma-iso validate FILE --format json` outputs valid JSON.
- Exit code is 0 for valid, 1 for findings under `--strict`.
- Existing `Metanorma::Iso::Converter` path unchanged.

## Estimating

~1-2 PRs. Pure addition — no migration debt.
