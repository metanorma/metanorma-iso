# 34 — Upstream metanorma-standoc: migrate STANDOC_* rules to Layer 3

## Why

metanorma-standoc's `Standoc::Validate` class is the procedural
ancestor of metanorma-iso's new Layer 3 architecture. Migrating it
brings every STANDOC_* key under the same model-driven, OCP,autoloaded
rule pattern — and lets us delete the override hacks in
`Iso::Validate` (currently no-op'ing standoc duplicate detection so
both code paths don't fire).

This is a substantial refactor — bigger than metanorma-iso's
migration because standoc has more validators and they're shared
across every flavor. Land incrementally; one rule family per PR.

## Architecture

Mirror metanorma-iso's layout in metanorma-standoc:

```
lib/metanorma/standoc/validation.rb              # namespace + autoloads
lib/metanorma/standoc/validation/
  model_validator.rb
  context.rb
  report.rb
  issue.rb
  issue_translator.rb
  rule_registry.rb
  rules.rb
  rules/
    base.rb
    tree_traversal.rb
    empty_table_rule.rb          # STANDOC_2
    table_rowspan_rule.rb        # STANDOC_4
    table_max_columns_rule.rb    # STANDOC_5
    concept_xref_rule.rb         # STANDOC_23
    duplicate_preferred_rule.rb  # STANDOC_24
    designation_markup_rule.rb   # STANDOC_25
    invalid_mathml_rule.rb       # STANDOC_33
    nested_asset_rule.rb         # STANDOC_34/35
    duplicate_id_rule.rb         # STANDOC_36
    undefined_xref_rule.rb       # STANDOC_38
    empty_block_rule.rb          # STANDOC_39
    ...
```

Each flavor gem (metanorma-iso, metanorma-csa, ...) inherits the
standoc rules via the RuleRegistry — flavor-specific rules layer on
top. The ModelValidator in each flavor runs BOTH standoc rules and
its own flavor rules in one pass.

## Migration order (by difficulty)

### Phase A — Foundation (1 PR)
Mirror metanorma-iso's foundation: ModelValidator, Context, Report,
Issue, IssueTranslator, RuleRegistry, Base, TreeTraversal. Wire as
no-op alongside existing `Standoc::Validate`. Zero behavior change.

### Phase B — All rules in the same PR
- STANDOC_2 (empty tables)
- STANDOC_4 (table rowspan)
- STANDOC_5 (table max columns)
- STANDOC_23 (concept xref errors)
- STANDOC_24 (duplicate preferred designations)
- STANDOC_25 (designation markup outside terms clause)
- STANDOC_33 (invalid MathML)
- STANDOC_34, STANDOC_35 (nested asset xrefs)
- STANDOC_36 (duplicate ids — replaces the current Iso::Validate override)
- STANDOC_38 (undefined xref)
- STANDOC_39 (empty blocks)

### Phase C — Image / SVG rules
- STANDOC_44, STANDOC_45 (image not found / corrupt PNG)
- STANDOC_55, STANDOC_56, STANDOC_57, STANDOC_58, STANDOC_59 (SVG validation)

### Phase D — Bibliography rules
- STANDOC_49 (numeric reference in normative refs)
- STANDOC_60 (unrecognised bibliographic style)

### Phase E — Standoc retirement
Once every STANDOC_* key has a Layer 3 equivalent, delete
`Standoc::Validate` (the procedural class). Each flavor's
`Flavor::Validate < Standoc::Validate` becomes
`Flavor::Validate` standalone.

## What this enables

- Remove the `repeat_id_validate1` / `repeat_anchor_validate1`
  overrides in `Iso::Validate` (they exist only to prevent
  double-reporting with standoc's now-Layer-3 UniqueIdRule).
- Remove `Metanorma::Iso::Validate#validate` override that skips
  `schema_validate` — there's no schema_validate to skip.
- Eliminate the last Nokogiri dependency from the validation pipeline.
- One unified RuleRegistry across all flavors.

## Verification

Each rule-migration PR:
1. Add the new rule class + spec in standoc.
2. Verify existing standoc specs still pass.
3. Delete the corresponding Ruby method from `Standoc::Validate`.
4. Confirm flavor gems still work (run their smoke specs).

## Estimating

1 PR to standoc (all rules + foundation + retire Validate class).
Flavor gems pick up the new wiring automatically — no per-flavor PRs
needed since they inherit Standoc::Validate.
