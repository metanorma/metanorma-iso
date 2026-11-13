# 29 — Rule: Style — requirements language, ambiguous words, misspellings

## Why
`validate_requirements.rb` and parts of `validate_style.rb` check:
- Modal verbs (shall, should, may, can) outside appropriate contexts.
- Ambiguous words ("need to", "might", "could", "family of standards").
- Misspellings ("on-line", "cyber_security", "cyber-security").
- Abbreviation formatting, ampersand, and/or.

## Files
- `lib/metanorma/iso/validate_requirements.rb` — full file.
- `lib/metanorma/iso/validate_style.rb` — partial.

## Plan
1. Create `lib/metanorma/iso/validation/rules/requirements_rule.rb` and
   `style_ambig_rule.rb`.
2. Walk inline content; apply regex/word-boundary checks.
3. Spec covers each category.
4. Delete `requirement_check`, `ambig_words_check`, `misspelled_words_check`,
   and related style helpers.

## Acceptance
- Spec green; STANDOC_48 warnings still produced; rice log unchanged.
