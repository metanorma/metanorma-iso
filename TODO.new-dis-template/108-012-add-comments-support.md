---
title: 108-012 - Add comments support
priority: P3
status: open
---

# 108-012: Add Comments Support

## Problem

The reference document has annotation/comment support (4 extra parts):
- `word/comments.xml` — Comment definitions
- `word/commentsExtended.xml` — Extended comment data
- `word/commentsIds.xml` — Comment IDs
- `word/commentsExtensible.xml` — Extensible comment data

The latest output has none of these. The reference has at least 1 annotation ("This is an annotation" visible at index 354 "1This is an annotation" in Annex E).

## Root Cause

The adapter has no code to render annotations/comments. The model has an `annotation_container` attribute on Root and the IsoDocument model includes `AnnotationContainer`, but the adapter never visits it.

## Fix

1. Add `visit_annotations` to the adapter that creates comments.xml entries
2. When rendering inline content, check for annotation references
3. Create the 4 comment-related parts in the DOCX package
4. Add Content_Types overrides for the 4 parts
5. Add document.xml.rels entries for the 4 parts

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — visit_annotations
- `lib/isodoc/iso/docx/inline.rb` — handle annotation inline elements
