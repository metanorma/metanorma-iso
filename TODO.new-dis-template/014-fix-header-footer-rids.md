# TODO 014: Fix Header/Footer rId References — Word "Unreadable Content" Error

## Status: DONE

## What

The generated DOCX references `rId16`–`rId19` for headers/footers in section breaks (`sectPr`), but these rIds do not exist in the relationships file (`word/_rels/document.xml.rels`). Word treats this as corrupt and strips all header/footer XML files and `docProps/custom.xml` on repair.

## Why

The adapter hardcodes header/footer rId assignments:
- Cover section: no headers/footers (OK)
- Front matter section: `rId16` (header default), `rId17` (header even), `rId18` (footer default), `rId19` (footer even)
- Body section: `rId16`–`rId19` (same rIds)

But the relationships file is populated from the template, and the template uses rIds like `rId11`–`rId14` for headers/footers. When the adapter clears the body and injects new content, the relationships from the original document are preserved, but the adapter's hardcoded rIds (16–19) don't match.

### Evidence

Broken output `document.xml.rels` has rId1–rId15, rId20–rId38 — **no rId16, rId17, rId18, rId19**. These are hyperlinks and images, not header/footer relationships.

The DIS template reference has:
- Cover section: `rId11`–`rId14` (header1-2, footer1-2)
- Front matter section: `rId20`–`rId23` (header3-4, footer3-4)
- Body section: `rId40`–`rId43` (footer5-7, header5)

## Architecture

### Option A: Preserve template header/footer relationships

The adapter should read the relationships from the template's `document.xml.rels` and reuse the correct rIds for each section. The template already has header/footer files — we just need to reference them with the correct rIds.

### Option B: Generate header/footer relationships

When generating the DOCX, create proper relationship entries for the header/footer files and use those rIds in the section properties.

### Recommended: Option A

The template has `header1.xml`–`header4.xml` and `footer1.xml`–`footer4.xml` with correct content. We should:
1. Read the template's `document.xml.rels` to find the header/footer relationship rIds
2. Use those rIds in our section break `sectPr` elements
3. Preserve the header/footer XML files from the template

### Implementation

In `insert_section_break`, instead of hardcoding rId16–rId19:
1. Read the template relationships at initialization
2. Map section types to the correct rIds from the template
3. Use the correct rIds in `headerReference`/`footerReference` elements

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `insert_section_break` method and relationship handling

## Depends On

- None (this is the root cause of Word repair)
