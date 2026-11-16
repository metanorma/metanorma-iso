# 28 — Rule: Style — numbers, percents, units

## Why
`validate_numeric.rb` and parts of `validate_style.rb` lint:
- Decimal points, number groupings, hyphen vs. minus.
- Percent spacing, bracketed tolerance.
- SI unit spacing, non-standard units, degrees.
- Subscript nesting depth.

## Files
- `lib/metanorma/iso/validate_numeric.rb` — full file.
- `lib/metanorma/iso/validate_style.rb` — partial.

## Plan
1. Create `lib/metanorma/iso/validation/rules/style_numeric_rule.rb` and
   `style_units_rule.rb` (split by topic).
2. Walk paragraphs and inline content; apply regex checks to `.text`.
3. Use `Base#extract_text(node, strip: [:link, :stem, :sourcecode])` for
   text-extraction parity with current implementation.
4. Spec covers each style violation.
5. Delete `style_number`, `style_percent`, `style_units`, `style_subscript`.

## Acceptance
- Spec green; STANDOC_48 style warnings still produced; rice log unchanged.
