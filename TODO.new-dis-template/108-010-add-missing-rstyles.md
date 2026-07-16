---
title: 108-010 - Add missing run styles (rStyles)
priority: P2
status: open
---

# 108-010: Add Missing Run Styles (rStyles)

## Problem

The reference document has ~810 rStyle uses across runs. The latest output has only 186. This affects formatting precision — bold, italic, superscript, and other character-level formatting.

### Key missing rStyles (from reference):

| rStyle | Usage | Purpose |
|--------|-------|---------|
| a2 | ~15 uses | Standard text formatting |
| a3 | ~1 use | Different text formatting |
| ForewordText | ~9 uses | Foreword body text |
| zzCover | ~8 uses | Cover page text |
| normref | ~7-8 uses | Normative reference text |
| Source | ~9 uses | Term source text |
| Hyperlink | ~many | Hyperlink character style |
| FootnoteReference | ~10+ | Footnote markers |
| EndnoteReference | ~few | Endnote markers |
| rptBold | | Bold text |
| rptItalic | | Italic text |

### Current state

The latest output applies some rStyles (186 total) but is missing many, especially:
1. No Hyperlink rStyle on hyperlinks
2. No FootnoteReference rStyle on footnote markers
3. Missing bold/italic rStyles where needed
4. Missing stem/math formatting rStyles

## Fix

### Step 1: Add Hyperlink rStyle
All `<w:hyperlink>` content runs should have `rStyle="Hyperlink"` (or `rStyle="a3"` per ISO convention).

### Step 2: Add FootnoteReference rStyle
Footnote reference runs should have appropriate rStyle.

### Step 3: Apply character formatting from model
The model's inline elements carry formatting attributes (bold, italic, superscript, etc.) that need to be translated into rStyle or direct run properties.

### Step 4: Add stem rStyle
Math/stem elements need a dedicated rStyle.

## Files to Change

- `lib/isodoc/iso/docx/inline.rb` — apply rStyles in render methods
- `lib/isodoc/iso/docx/style_resolver.rb` — add run style resolution
- `data/iso-dis/style_mapping.yml` — add run style mappings
