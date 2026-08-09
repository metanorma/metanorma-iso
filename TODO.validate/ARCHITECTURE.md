# Validation Architecture

## Layered design

Validation is organized as four layers, each with a single
responsibility (MECE) and a well-defined dependency direction
(depend only on lower layers). Each layer is open for extension
(OCP): adding a rule, declaration, or reporter is purely additive.

```
┌─────────────────────────────────────────────────────────────────┐
│  Layer 4 — Public API                                           │
│    Metanorma::Iso.validate(xml)  → Report                       │
│    exe/metanorma-iso-validate FILE --format json                │
│    Profiles: :default, :strict, :publication                    │
│    Reporters: text, json, yaml                                  │
├─────────────────────────────────────────────────────────────────┤
│  Layer 3 — Semantic Rules (this repo + siblings)                │
│    37 rule classes, one per ISO_N / STANDOC_N key               │
│    StyleRule < Base (abstract — text-linting rules)            │
│    TreeTraversal mixin (~15 shared walkers)                     │
│    RuleRegistry discovers via Rules.constants (OCP)            │
│    Operates ONLY on the typed model                             │
├─────────────────────────────────────────────────────────────────┤
│  Layer 2 — Collection Validators                                │
│    validates_uniqueness_of, validates_min_count                 │
│    Lutaml::Model::Collection subclasses                         │
├─────────────────────────────────────────────────────────────────┤
│  Layer 1 — Document Model (metanorma-document)                  │
│    Typed Serializables + declarative validations                │
│    (required:, values:, pattern:, collection: N..M)             │
│    Owns STRUCTURAL validity via from_xml + validate             │
└─────────────────────────────────────────────────────────────────┘
```

## How to add a new validation rule

1. **Decide: structural or semantic?**
   - Structural (shape, presence, type) → Layer 1 declaration on
     the metanorma-document model class. PR to metanorma-document.
   - Semantic (meaning, convention, style) → Layer 3 rule class.
     PR here.

2. **For a semantic rule**, create one file:

```ruby
# lib/metanorma/iso/validation/rules/my_new_rule.rb
module Metanorma
  module Iso
    module Validation
      module Rules
        class MyNewRule < Base          # or < StyleRule for text linting
          code "ISO_99"                  # the ISO_LOG_MESSAGES key

          def applicable?(context)
            !context.root.nil?           # gate: skip if model failed to parse
          end

          def check(context)
            # Walk the typed model. Use TreeTraversal helpers.
            # Return Array of Lutaml::Model::Validation::Issue.
            []
          end
        end
      end
    end
  end
end
```

3. **Add one autoload line** to `rules.rb`:
```ruby
autoload :MyNewRule, "metanorma/iso/validation/rules/my_new_rule"
```

4. **Add a spec**:
```ruby
# spec/metanorma/validation/rules/my_new_rule_spec.rb
RSpec.describe Metanorma::Iso::Validation::Rules::MyNewRule do
  # ... test with real model instances, never doubles ...
end
```

5. **Delete the old Ruby method** (if migrating) in the same commit.

That's it. No switch statement to edit. No central hash to maintain.
The RuleRegistry discovers the new class automatically via
`Rules.constants`.

## Key components

| Component | File | Responsibility |
|-----------|------|----------------|
| ModelValidator | validation/model_validator.rb | Orchestrator: deserialize → Layer 1 → Layer 3 → translate |
| StateExtractor | validation/state_extractor.rb | Auto-detects doctype/lang/script/vocab/amd from the model |
| Profile | validation/profile.rb | Filters which rules run; configures strict-warning behavior |
| RuleRegistry | validation/rule_registry.rb | Discovers concrete (non-abstract) rule classes |
| IssueTranslator | validation/issue_translator.rb | Single sink: Layer 1 + Layer 3 → @log + Report |
| Report | validation/report.rb | Lutaml::Model::Serializable; serializes to JSON/YAML/XML |
| TreeTraversal | validation/rules/tree_traversal.rb | ~15 shared model walkers (each_term, each_clause, etc.) |
| StyleRule | validation/rules/style_rule.rb | Abstract base for text-linting rules; provides scan_text hook |
| Base | validation/rules/base.rb | Abstract base for all rules; code DSL, model_location, build_issue |

## Built-in profiles

| Profile | Rules run | Warnings | Use case |
|---------|-----------|----------|----------|
| `:default` | All | Non-fatal | Development, CI |
| `:strict` | All | Fatal (exit 1) | Pre-release gate |
| `:publication` | All except STANDOC_48 | Non-fatal | Final manuscript review |

Custom: `Profile.new(name: "ci", only_codes: ["ISO_5", "ISO_29"])`

## Public API

```ruby
# Auto-detect state from the model
report = Metanorma::Iso.validate(xml)
report.valid?       # => true / false
report.errors       # => [#<Issue code: "ISO_5", ...>]
report.to_json      # => structured JSON for tooling

# With profile
report = Metanorma::Iso.validate(xml, profile: :publication)

# With explicit state overrides
report = Metanorma::Iso.validate(xml, doctype: "international-standard")
```

```bash
$ metanorma-iso-validate document.xml
$ metanorma-iso-validate document.xml --format json
$ metanorma-iso-validate document.xml --profile strict
$ metanorma-iso-validate document.xml --profile publication
```

## Current rule inventory (37 classes)

### Document metadata (6 rules)
DoctypeRule (ISO_5), IterationRule (ISO_6), TechnicalCommitteeTypeRule
(ISO_2), SubcommitteeTypeRule (ISO_3), SubpartIecRule (ISO_16),
ForewordPresenceRule (STANDOC_7).

### Title rules (5 rules)
TitlePairingRule (ISO_10–15), TitleNamesDoctypeRule (ISO_17/18),
TitleFirstLevelRule (ISO_19), TitleSiblingsConsistencyRule (ISO_20).

### Section rules (8 rules)
ScopePresenceRule (ISO_29), NormativeReferencesPresenceRule (ISO_30),
TermsPresenceRule (ISO_31), ForewordStructureRule (ISO_23),
ScopeSubclausesRule (ISO_39), OnlyChildClauseRule (ISO_43),
SectionSequenceRule (ISO_28/32/33/34/36/37/38/40/41),
VocabTermsTitlesRule (ISO_44/45).

### Bibliography rules (2 rules)
NormativeBibitemRule (ISO_42), SymbolsSectionCountRule (ISO_25),
SymbolsSectionContentRule (ISO_26), SymbolsInAnnexRule (ISO_27).

### Cross-reference rules (5 rules)
UnreferencedAssetsRule (ISO_21/22), LocalityErefsRule (ISO_49),
SeeXrefsRule (ISO_46/47/48), TermXrefsRule (ISO_50/51),
BrokenXrefRule (STANDOC_38).

### Style rules (6 rules)
StyleNumberRule, StyleUnitsRule, StyleAmbigWordsRule,
ModalInClauseRule (all STANDOC_48), ListCountRule, ListDepthRule,
ListPunctuationRule.

### Term rules (1 rule)
TermdefStyleRule (ISO_4/35).

### Identity rules (1 rule)
UniqueIdRule (STANDOC_36, populates SharedState).

## Converter integration

The converter calls `validate_processor.validate(doc)` during
compilation. The Validate class:

1. Calls `super` (standoc's content_validate) for table/image/math/
   concept/preferred/termsect/block checks not yet migrated.
2. Calls LegacyChecks methods (ISO-specific Nokogiri style checks
   not yet migrated — pending TODO 34).
3. Calls `model_validate(doc)` which deserializes XML to
   IsoDocument::Root and runs every Layer 3 rule.

Five targeted overrides prevent duplicate findings for checks that
exist in BOTH standoc and Layer 3 (section_validate, xref_validate_
exists, norm_ref_validate, repeat_id_validate1, repeat_anchor_
validate1). These overrides go away when TODO 34 lands.

## Cross-repo work

### metanorma-document (TODO 33)
1 PR adding Layer 1 declarations and model extensions.
See TODO.validate/33-*.md.

### metanorma-standoc (TODO 34)
1 PR migrating all STANDOC_* rules to Layer 3 classes. After this,
the LegacyChecks module and all override hacks are deleted in one
edit. See TODO.validate/34-*.md.

## Why this is better than the procedural original

| Procedural (legacy)                    | Layered (this branch)                |
|----------------------------------------|--------------------------------------|
| One 270-line `Validate` class          | 37 single-responsibility rule classes |
| XPath strings hardcoded in Ruby        | Model-driven navigation              |
| RNG + Jing separate (Java JVM)         | Layer 1 owns structure (no Jing)     |
| Validation welded to compile           | Public API + CLI + profiles          |
| Adding a rule = editing switch case    | Adding a rule = new file + autoload  |
| Output only via .err.html              | Report serializes to JSON/YAML/text  |
| Specs require end-to-end compile       | Rule specs run on isolated fixtures  |
| Duplicate warnings from dual paths     | Targeted overrides eliminate dupes   |
| @novalid guards scattered everywhere   | validate() never called when disabled |

The architectural win is *locality of change*: a new rule touches one
file; a new output format touches one reporter; a new model attribute
touches one declaration. Maintenance cost is proportional to the
change, not to the size of the codebase.
