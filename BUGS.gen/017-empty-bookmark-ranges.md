---
title: BUG 017 - Empty bookmark start/end pairs (hyperlinks won't resolve)
priority: P2
status: closed
---

# BUG 017: Empty Bookmark Start/End Pairs (Hyperlinks Won't Resolve)

## Symptom

Most hyperlinks in the document jump to nothing because their target
bookmarks are collapsed to a single point with no content between
them.

## Root Cause

The adapter emits bookmark pairs immediately adjacent:

```xml
<w:p>
  <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
  <w:bookmarkStart w:id="1" w:name="_baa7c358-..."/>
  <w:bookmarkEnd w:id="1"/>
  <w:r><w:t>1</w:t></w:r>
  <w:r><w:t>Scope</w:t></w:r>
</w:p>
```

The `<w:bookmarkStart>` and `<w:bookmarkEnd>` should WRAP the heading
text (so the bookmark has a range that Word can scroll to). The current
output collapses them to zero width.

## Evidence

```bash
$ grep -c 'w:bookmarkStart' word/document.xml
103

$ grep -c 'w:bookmarkEnd' word/document.xml
103
# Balanced, but every pair is adjacent — no content between them.
```

## Impact

- TOC PAGEREF fields use these bookmark names; with empty ranges,
  the page reference computation may produce wrong results.
- Hyperlinks to these bookmarks may not scroll to the right position.
- Word may flag these as warnings during repair.

## Fix

The `insert_bookmark` helper should:
1. Emit `<w:bookmarkStart>` BEFORE the heading text runs
2. Emit `<w:bookmarkEnd>` AFTER the heading text runs

In Uniword terms, the bookmark needs to be inserted into the
paragraph's run list at the right position, not as a prefix pair.

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — `insert_bookmark` helper
- Possibly the bookmark APIs in `uniword/lib/uniword/builder/paragraph_builder.rb`

## Verification

After fix, a heading bookmark should look like:

```xml
<w:p>
  <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
  <w:bookmarkStart w:id="1" w:name="_baa7c358-..."/>
  <w:r><w:t>Scope</w:t></w:r>
  <w:bookmarkEnd w:id="1"/>
</w:p>
```

The text run sits BETWEEN the bookmark start and end.
