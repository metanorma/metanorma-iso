# 02 — Declarative: Preface foreword required (Layer 1)

## Why
`lib/metanorma/iso/validate_section.rb` (foreword_validate) emits ISO_23 when
the foreword has subclauses. The RNG (`lib/metanorma/iso/isostandard.rng`)
makes `<foreword>` a required child of `<preface>`. The model already types
this as `IsoPreface#foreword` (`sections/iso_preface.rb:24`); adding
`required: true` lets Layer 1 enforce presence.

## Current code
- `lib/metanorma/iso/isostandard.rng` preface define (line 110-120) — `foreword`
  is required.
- `lib/metanorma/iso/validate_section.rb` foreword_validate (ISO_23 fires on
  subclauses, not absence — absence is caught by RNG STANDOC_7).

## Plan
1. Edit `lib/metanorma/iso_document/sections/iso_preface.rb`:
   ```ruby
   attribute :foreword, ForewordSection, required: true
   ```
2. Add `RequiredAttributeMissingError → ISO_F_preword_missing` mapping in
   `IssueTranslator#classify_layer1_error`.
3. Add to `ISO_LOG_MESSAGES` (in `lib/metanorma/iso/log.rb`) a new key:
   `ISO_F_preword_missing: { category: "Preface", error: "missing required
   foreword element in preface", severity: 2 }`.
   - Naming convention: `ISO_F_<attribute>` for Layer 1 declaration-driven
     findings; reserve `ISO_<N>` for existing semantic rules.
4. Patch `lib/metanorma/iso/isostandard.rng` preface define: remove the
   `foreword` requirement (Layer 1 now handles it).
5. Verify rice document compiles with no regression.

## Specs
- `spec/metanorma/validation/layer1/foreword_required_spec.rb`: parse a
  `<preface>` without `<foreword>` → `Root.from_xml(xml).validate` returns
  `RequiredAttributeMissingError` for `foreword`.
- Existing `spec/metanorma/validate/validate_section_spec.rb` (or equivalent)
  still passes.

## Acceptance
- Model-level spec green.
- `bundle exec metanorma -t iso spec/examples/rice.adoc` produces the same
  error log.
- RNG no longer encodes `foreword` required.

## RNG counterpart to remove
`lib/metanorma/iso/isostandard.rng` `preface` define: change `foreword`
element from required to optional.
