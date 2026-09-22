# 14 — Rule ISO_19, ISO_20: Title siblings consistency

## Why
- ISO_19: first-level subclause without title.
- ISO_20: inconsistent titling among sibling clauses.

## Files
- `lib/metanorma/iso/validate_title.rb`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/title_siblings_rule.rb`.
2. Walk `context.root.sections.clause` recursively. For each clause:
   - ISO_19: check first-level subclauses have titles.
   - ISO_20: check siblings all-or-none have titles.
3. Spec covers both cases.
4. Delete `title_first_level_validate` and `title_all_siblings`.

## Acceptance
- Spec green; ISO_19/20 cases still flagged; rice log unchanged.
