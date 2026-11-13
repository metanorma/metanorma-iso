# 22 — Rule ISO_44, ISO_45: Vocabulary terms titles

## Why
Vocabulary documents have specific term-heading rules.
- ISO_44: vocab term heading style.
- ISO_45: vocab term entry heading.

## Files
- `lib/metanorma/iso/validate_section.rb:vocab_terms_titles_validate`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/vocab_terms_titles_rule.rb`.
2. Guard on `context.state.vocab` (only runs for vocab docs).
3. Walk `sections.terms`. Check each term's preferred designation against
   vocab title rules.
4. Spec covers vocab=true flag case, vocab=false skip case.
5. Delete `vocab_terms_titles_validate`.

## Acceptance
- Spec green; ISO_44/45 still flagged when applicable; rice log unchanged.
