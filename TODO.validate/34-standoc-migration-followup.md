# 34 — Followup: Standoc migration

## Why
Out of scope for this branch. Document the standoc-side migration as a
follow-up so the work isn't forgotten.

## Scope
- Migrate `Standoc::Validate` STANDOC_* rules to lutaml-model Rule classes.
- Remove `metanorma-standoc/lib/metanorma/validate/*.rb` Ruby validators.
- Remove `metanorma-standoc/lib/metanorma/validate/schema.rb` Jing invocation.
- Remove the parent RNG schemas.

## Approach
Same architecture as the ISO migration: Layer 1 declarations on the
StandardDocument base classes, Layer 2 collection validators where useful,
Layer 3 Rule classes for semantic rules.

## Acceptance
- All STANDOC_* rules migrated to Rule classes.
- Jing and RNG removed from metanorma-standoc.

## Priority
P2 — future work, not in this branch.
