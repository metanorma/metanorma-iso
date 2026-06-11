# 060: Fix Missing TOC (Table of Contents)

## Problem
The reference DOCX has a full TOC with 26 entries using `TOC1`, `TOC2`, `TOC3` styles and `fldChar` field codes. The output has a single "Contents" heading paragraph with no TOC entries.

## Evidence
```
Reference TOC (paras 19-46):
  "Contents" heading
  "Foreword  1"
  "Introduction  1"
  "1 Scope  1"
  "2 Normative references  1"
  ... (26 entries total)
  Uses: TOC1 (18), TOC2 (7), TOC3 (2) pStyles
  Uses: msotoctextspan1 rStyle (177 occurrences)

Output TOC (paras 20-21):
  "Contents" heading
  "" (empty paragraph)
  No TOC entries at all
```

## Impact
- No clickable table of contents
- The TOC page is empty after "Contents"

## Fix
The adapter needs to emit TOC entries. This can be either:
1. Static TOC entries with field codes (like the reference)
2. A TOC field that Word populates on open

The reference uses `w:fldChar` with `w:instrText` containing `TOC \o "1-3" \h \z \u` to generate the TOC.

## Priority
**HIGH** — TOC is expected in ISO documents. Missing it degrades usability significantly.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — TOC rendering
- May need upstream isodoc support for TOC field generation
