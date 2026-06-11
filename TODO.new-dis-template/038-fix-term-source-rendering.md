# TODO 038: Fix Term Source Rendering — Use `termsource` Model Attribute

## Status: DONE

## What

Term source citations (`[SOURCE: ISO 7301:2021, clause 3.1]`) were not rendering because `render_term_source` checked `term.source` and `term.fmt_termsource` but the presentation XML uses `<termsource>` which maps to `term.termsource`.

## Why

The `IsoTerm` model has three source-related attributes:
- `source` — from `<source>` elements (rare in presentation XML)
- `termsource` — from `<termsource>` elements (standard in presentation XML)
- `fmt_termsource` — from `<fmt-termsource>` elements

The `render_term_source` method only checked `source` and `fmt_termsource`, missing the `termsource` attribute entirely. Since the rice presentation XML uses `<termsource>` exclusively, no source citations were rendered.

### Fix

Updated `render_term_source` to check `term.termsource` first (the presentation XML standard), then fall back to `term.source`. Now renders 9 Source paragraphs matching the reference output.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `render_term_source` method

## Depends On

- None
