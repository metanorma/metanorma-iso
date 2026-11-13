# 27 — Rule: List punctuation and counts

## Why
`validate_list.rb` enforces:
- No more than one ordered list per clause (style).
- No more than 4 levels of list nesting (style).
- List punctuation rules (colon-prefixed vs. period-prefixed lists).

## Files
- `lib/metanorma/iso/validate_list.rb` — current implementation.

## Plan
1. Create `lib/metanorma/iso/validation/rules/list_punctuation_rule.rb`.
2. Walk every clause, count ordered lists. Walk every list, count nesting
   depth. For each list, use the "preceding sibling text" helper to get the
   character before the list and apply punctuation rules.
3. Spec covers OL count, depth, colon-list, period-list cases.
4. Delete `listcount_validate` and `list_punctuation`.

## Risk
Preceding-sibling text query requires parent navigation. Implement
`preceding_text(node)` helper on Base.

## Acceptance
- Spec green; style warnings still produced; rice log unchanged.
