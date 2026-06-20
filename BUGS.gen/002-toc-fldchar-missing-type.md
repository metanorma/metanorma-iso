---
title: BUG 002 - TOC fields missing fldCharType attribute
priority: P0
status: closed
---

# BUG 002: TOC Fields Missing fldCharType Attribute

## Symptom

The table of contents shows raw field instructions as visible text:

```
Contents
 TOC \o "1-3" \h \z \u
     PAGEREF _653a90c4-1107-5ffe-6939-73eac3f09925 \h
     PAGEREF _3b6f3bab-4044-67cb-ef16-fa6625efb0d9 \h
Contents     PAGEREF _13d7055e-30fc-845a-c60e-8972faf092d9 \h
```

## Root Cause

OOXML requires every `<w:fldChar>` element to have a `w:fldCharType`
attribute with one of: `begin`, `separate`, or `end`.

The generated document.xml has bare `<w:fldChar/>` elements with no
attribute. These are invalid field delimiters that Word cannot interpret
as field boundaries, so the field instructions inside `<w:instrText>`
leak out as literal text.

## Evidence

```xml
<w:p>
  <w:r><w:fldChar/></w:r>                                  <!-- INVALID -->
  <w:r><w:instrText> TOC \o "1-3" \h \z \u </w:instrText></w:r>
  <w:r><w:fldChar/></w:r>                                  <!-- INVALID -->
  <w:r><w:fldChar/></w:r>                                  <!-- INVALID -->
</w:p>
```

Should be:

```xml
<w:p>
  <w:r><w:fldChar w:fldCharType="begin"/></w:r>
  <w:r><w:instrText> TOC \o "1-3" \h \z \u </w:instrText></w:r>
  <w:r><w:fldChar w:fldCharType="separate"/></w:r>
  <w:r><w:t>...cached result text...</w:t></w:r>
  <w:r><w:fldChar w:fldCharType="end"/></w:r>
</w:p>
```

Same defect appears in every `PAGEREF` field in the TOC entries.

## Source of Bug

`Uniword::Builder` likely has a `field_character` helper or the
`page_number_field` builder that constructs these elements without
setting `w:fldCharType`. Search uniword for `FieldChar` or
`fldChar` constructors.

## Fix

Every `w:fldChar` must carry an explicit `w:fldCharType` of `begin`,
`separate`, or `end`. The sequence for a complete field is:

```
begin -> instrText -> separate -> (cached result) -> end
```

For TOC and PAGEREF fields, the cached result can be empty (Word will
populate on first open with "Update Field").

## Files to Change

- `uniword/lib/uniword/builder/paragraph_builder.rb` or wherever
  `field_character` / `page_number_field` is built
- `uniword/lib/uniword/wordprocessingml/field_char.rb` (likely missing
  required attribute)

## Verification

```bash
unzip -p output.docx word/document.xml | grep -o 'fldChar[^/]*'
# Should show: fldChar w:fldCharType="begin" etc.
```
