# TODO 046: Remove Tab Separator Between Section Numbers and Heading Text

## Status: DONE

## What

Headings have a `[TAB]` between the section number and the title text (e.g., "1[TAB]Scope"). The reference has no separator (e.g., "1Scope"). The tab comes from the `<fmt-caption-delim><tab/></fmt-caption-delim>` in the presentation XML fmt-title.

## Why

### Reference (rice.docx)
```
  73: Heading1 | 1Scope
  77: Heading1 | 2Normative references
 163: Heading1 | 4Specifications
 164: Heading2 | 4.1General, organoleptic and health characteristics
```

### Our Output
```
  48: Heading1 | 1[TAB]Scope
  52: BiblioTitle | 2[TAB]Normative references
 133: Heading1 | 4[TAB]Specifications
 134: Heading2 | 4.1[TAB]General, organoleptic and health characteristics
```

### Root Cause

The presentation XML fmt-title structure is:
```xml
<fmt-title depth="1">
  <span class="fmt-caption-label"><semx element="autonum">1</semx></span>
  <span class="fmt-caption-delim"><tab/></span>
  <semx element="title">Scope</semx>
</fmt-title>
```

The `<span class="fmt-caption-delim"><tab/></span>` produces a tab between the number and title. The reference (old isodoc) strips this tab, producing "1Scope" directly.

The reference output appears to have NO tab between number and text. But it also doesn't have a space. This is the original isodoc behavior — it concatenates the number directly with the text.

## Architecture

Option A: In `render_heading_title_stripped`, after rendering via the inline renderer, strip the tab run from the built paragraph.

Option B: In the inline renderer, when encountering a `SpanElement` with class "fmt-caption-delim", skip it (don't render the tab).

Option C: In `render_heading_title_stripped`, use custom ordered-element walking that skips `fmt-caption-delim` spans.

Recommendation: Option B is cleanest. Detect `fmt-caption-delim` class spans and skip them when rendering headings. This prevents the tab from appearing.

## Files

- `lib/isodoc/iso/docx/inline.rb` — `render_span` or `render_mixed_inline_fallback`
- `lib/isodoc/iso/docx/adapter.rb` — `render_heading_title_stripped`

## Depends On

- None
