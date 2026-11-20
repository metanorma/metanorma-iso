---
status: done
---

# 07: TOC entries have section numbers stripped

## Symptom

TOC entries in my output are missing their section numbers, OR the
section number appears concatenated with the title without a tab
separator.

## My output

```
[TOC1] 1Scope               ← no space/tab between number and title
[TOC1] 4Specifications       ← same
[TOC2] 4.1General, organoleptic...   ← same
```

Or in some entries:

```
[TOC1] Scope                 ← no number at all
[TOC1] Terms and definitions ← no number
```

## Reference

```
[TOC1] 1 Scope
[TOC1] 4 Specifications
[TOC2] 4.1 General, organoleptic...
```

(with proper tab between number and title — TOC1/TOC2 styles have
tab stops)

## Root cause

Same root cause as [02-heading-numbers.md]: the renderer treats
fmt-caption-delim (the `<span><tab/></span>` between number and
title) as an autonum_carrier and strips it — but in TOC mode the
autonum is NOT being stripped, so we get the number; the tab,
however, is being dropped because of the SpanRenderer's stripping
logic incorrectly including `fmt-caption-delim` even when
`stripping_autonum?` is false.

Wait, actually re-reading: SpanRenderer only strips when
`stripping_autonum?` is true. So in TOC mode the delim should
render. The issue might be:

- The TabRenderer does render a tab run
- But the tab run gets merged with adjacent text runs (TextRun
  merging during serialization)

OR the issue is in TocBuilder#render_toc_heading_text — it calls
`@inline.render(node.fmt_title, para)` which uses normal mode
(not heading mode). Normal mode walks the spans properly. So we
should get "1" + TAB + "Scope". But the output is "1Scope" with
no separator.

## Investigation needed

Trace what `render_toc_heading_text` actually produces. Check if
the tab run gets merged into the previous text run by the
ParagraphBuilder.

## Fix

Ensure the tab between autonum and title is preserved as a distinct
`<w:r><w:tab/></w:r>` run, not merged with adjacent text. If the
ParagraphBuilder's text normalization merges them, that's the bug.

## Resolution

Stale: not reproducible on grind/1609 (19c1878f). A real conversion of
spec/fixtures/iso/is/document-en.dis.presentation.xml gives
`TOC1 "1 " "Scope" <TAB> "1"`, `TOC2 "4" "." "1 " "General, ..." <TAB> "1"`:
numbers present, a space between number and title, one tab (page number).
`6b771179` made the label-to-title separator a space on purpose (a tab there
overshoots the TOC style stop and jumps to the right-hand dot-leader stop,
metanorma-pdfa#119), so a tab between number and title is NOT the target.
Pinned by `spec/isodoc/docx/toc_entries_spec.rb` ("separates each entry's
section number from its title with a space").
