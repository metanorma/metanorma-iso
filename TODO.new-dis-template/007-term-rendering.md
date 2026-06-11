# TODO 007: Implement Term Rendering with Depth-Aware Numbering

## Status: COMPLETE

## What

Update term rendering to use the new template's depth-aware term numbering styles (`TermNum2`..`TermNum6`) and `Terms0`/`TermsAdmitted` styles.

## Why

The new reference DOCX uses:
- `TermNum2`..`TermNum6` — term numbers at different clause depths (mapped to `p2`..`p6` heading styles)
- `Terms0` — term name (the actual term text)
- `TermsAdmitted` — admitted terms (alternative term names)
- `Definition` — definition text
- `Note` — notes within terms
- `Example` — examples within terms
- `Source` — SOURCE references

The old template had a single `TermNum` style. The new template's `TermNum2`..`TermNum6` correspond to the clause depth (Heading2..Heading6) where the terms section appears. In the reference DOCX, all terms are under `Heading2` subclauses, so `TermNum3` is used (because terms are at level 3 — e.g., "3.1.1").

### Term Structure in Reference

```
Heading1: "Terms and definitions"          → numbered "3" (body clause numbering)
  BodyText: "ISO and IEC maintain..."       → boilerplate
  ListContinue1: "IEC Electropedia:..."     → list
  ListContinue1: "ISO Online browsing..."   → list
  Heading2: "Terms relating to basic..."    → numbered "3.1" (body clause numbering)
    TermNum3: (auto-numbered "3.1.1")       → from Heading3 numbering
    Terms0: "4-Dimensionalism"              → term name
    Definition: "data modelling approach..." → definition
    TermNum3: (auto-numbered "3.1.2")
    Terms0: "asset"
    Definition: "item, thing..."
    Source: "[SOURCE: ISO 55000:2024...]"
    ...
```

### Numbering Observation

`TermNum3` is based on `p3` which is based on `Heading3`. The term numbers are auto-numbered by the Heading3 list numbering (abstractNumId=3, level 2). This means the terms section heading (`Heading2`) establishes the sub-counter, and each `TermNum3` increments within that context.

## Architecture

### Depth Resolution

The term number style depends on the depth of the enclosing clause:
- Terms under `Heading2` subclause → `TermNum3` (depth = heading level + 1)
- Terms under `Heading3` subclause → `TermNum4`
- etc.

The adapter already tracks `section_depth` in Context. We need to map this to the correct `TermNumN` style.

```ruby
def term_num_style
  depth = context.section_depth
  # TermNum style is heading level + 1
  # Heading2 → TermNum3, Heading3 → TermNum4, etc.
  level = depth + 1
  "TermNum#{level}".to_sym
end
```

### Style Resolver Update

Add a context-aware term style resolver:

```ruby
def term_number_style
  level = @context.section_depth + 1
  @mapping.paragraph_style("TermNum#{level}".to_sym)
end
```

## Files

- `lib/isodoc/iso/docx/style_resolver.rb` — term style resolution
- `lib/isodoc/iso/docx/adapter.rb` — term rendering

## Depends On

- TODO 002 (new template with TermNum2..6 styles)
- TODO 005 (style mapping)
