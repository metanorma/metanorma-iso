# 13 — Rule ISO_17, ISO_18: Title text names document type

## Why
`validate_title.rb:title_names_type_validate` flags main/Intro title text
that names the document type (e.g. "Technical Specification" in title-main).

## Files
- `lib/metanorma/iso/validate_title.rb`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/title_names_doctype_rule.rb`.
2. For each title (main, intro) in each language, check text against a regex
   of doctype words.
3. Spec covers ISO_17 (main), ISO_18 (intro).
4. Delete `title_names_type_validate`.

## Acceptance
- Spec green; ISO_17/18 cases still flagged; rice log unchanged.
