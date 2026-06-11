# TODO 039: Fix Empty Paragraphs Between Term Elements

## Status: DONE

## What

Empty paragraphs appear between TermNum and Terms0 styles, and between Terms0/TermsAdmitted and the next element. The reference has no empty paragraphs between term elements.

## Why

### Current (Broken)

```
  59 TermNum: 3.1
  60 (none)       ← empty paragraph
  61 Terms0: paddy
  62 (none)       ← empty paragraph
  63 TermsAdmitted: paddy rice
```

### Expected (Reference)

```
  95 TermNum: 3.1
  96 Terms: paddy
  97 AltTerms: paddy rice
  98 AltTerms: rough rice
  99 Definition: rice retaining its husk...
```

The empty paragraphs are likely from the model's `walk_mixed_content` yielding text nodes or whitespace elements that get rendered as empty paragraphs.

## Architecture

In `visit_term`, filter out empty paragraphs. Check the `walk_mixed_content` calls within term rendering to identify where empty paragraphs come from. The empty `(none)` paragraphs are likely from `<p>` elements in the model that have no text content (e.g., definition containers that are empty wrappers).

## Files

- `lib/isodoc/iso/docx/adapter.rb` — term rendering, `walk_mixed_content`

## Depends On

- None
