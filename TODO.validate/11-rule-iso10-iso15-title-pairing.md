# 11 — Rule ISO_10..ISO_15: Title bilingual pairing

## Why
`validate_title.rb` enforces title presence and pairing rules across EN/FR:
- ISO_10/ISO_11: missing EN/FR title-intro
- ISO_12/ISO_13: missing EN/FR title-main
- ISO_14/ISO_15: missing EN/FR title-part

## Files
- `lib/metanorma/iso/validate_title.rb` — current implementation.
- `lib/metanorma/iso_document/metadata/title_*.rb` — title models.

## Plan
1. Create `lib/metanorma/iso/validation/rules/title_pairing_rule.rb`.
2. Read `context.root.bibdata.title` — verify the typed structure: title is
   a TitleCollection with Main/Intro/Part components per language.
3. For each component × language, check presence; build issue per missing.
4. Spec covers all 6 missing combinations.
5. Delete the corresponding methods from `validate_title.rb`.

## Acceptance
- Spec green; existing ISO_10..15 specs pass; rice log unchanged.

## RNG counterpart
`relaton-iso.rng` title structure — leave for now (vocabulary realignment in
TODO 33).
