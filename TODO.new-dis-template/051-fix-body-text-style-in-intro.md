# TODO 051: Fix Body Text Style in Introduction — Use (none) Not BodyText

## Status: DONE

## What

Body text paragraphs in the Introduction use `BodyText` style instead of `(none)` style (Normal). The reference uses Normal style (no explicit pStyle) for introduction paragraphs.

## Why

### Reference (rice.docx)
```
  61: IntroTitle  | Introduction
  62: (none)      | This document was developed in response...
  63: (none)      | Rice is a permanent host...
  64: (none)      | Storage losses have been estimated...
```

### Our Output
```
  34: IntroTitle  | Introduction
  35: BodyText    | This document was developed in response...
  36: BodyText    | Rice is a permanent host...
  37: BodyText    | Storage losses have been estimated...
```

### Root Cause

The `resolve_paragraph_style` method resolves to `@resolver.context_body_style` for paragraphs without a class or special type. The `context_body_style` method returns `body_text` (= `BodyText`) when not in a note/example/foreword/normative context.

In the reference output, introduction body paragraphs have no explicit style (they use the document's default Normal style). The old isodoc pipeline didn't apply `BodyText` style to these paragraphs.

However, the Foreword uses `ForewordText` style correctly (because `@context.in_foreword` is true). The Introduction doesn't have a context flag, so it falls through to `BodyText`.

## Architecture

Option A: Add `in_introduction` context flag and check in `context_body_style` to return nil (Normal) when in introduction.

Option B: Don't apply any style to body paragraphs in preface sections (foreword, introduction). Only apply `BodyText` to body paragraphs in the main body (sections, clauses).

Option C: The reference uses Normal style for all body text outside of specific contexts (foreword text, notes, examples). Make `context_body_style` return nil by default, only return specific styles for specific contexts.

Recommendation: Option C is most aligned with the reference. Body paragraphs should use Normal (no pStyle) unless in a specific context that requires a style (foreword → ForewordText, note → Note, example → Example, etc.).

## Files

- `lib/isodoc/iso/docx/style_resolver.rb` — `context_body_style`
- `data/iso-dis/style_mapping.yml` — may need adjustment

## Depends On

- None
