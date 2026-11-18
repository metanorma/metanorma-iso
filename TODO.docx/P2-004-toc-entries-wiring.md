---
title: 108-005 - Add TOC entries
priority: P1
status: done
depends_on: [108-001]
---

# 108-005: Add TOC Entries

`6b771179` supplies TOC entries with a tab and a complete PAGEREF field. The DIS regression in `spec/isodoc/docx/toc_entries_spec.rb` checks the packaged fields and heading bookmarks through `Processor#output(..., :docx)`. Untitled clauses such as 4.2.1 and 4.2.2 are deliberately omitted because they have no heading. Foreword, Introduction, Normative references and Bibliography now have heading bookmarks. The Bibliography bookmark is on the `BiblioTitle` paragraph.

Before the bookmark fix, measurement-only conversions of the submitted ISO 5878 (20260429-fdis) and ISO 2533 (20260907, en) presentation XML produced 41 and 30 TOC entries respectively, each with four missing bookmark targets.

## Problem

The latest output has only the "Contents" heading but no TOC entries. The reference has 26 entries:

- 18× TOC1: Foreword, Introduction, Scope, Normative references, Terms, Specifications (4.1, 4.2), Sampling, Test methods (6.1-6.5), Test report, Packaging, Marking, Annex A-E, Bibliography
- 7× TOC2: 6.5.1, 6.5.2
- 2× TOC3: 6.5.2.1, 6.5.2.2, 6.5.2.3

Each TOC entry contains: section number + title + tab + page number

## Reference Structure

```xml
<w:p>
  <w:pPr><w:pStyle w:val="TOC1"/></w:pPr>
  <w:r><w:t>Foreword</w:t></w:r>
  <w:r><w:tab/></w:r>
  <w:r><w:fldChar w:fldCharType="begin"/></w:r>
  <w:r><w:instrText> PAGEREF _Toc... \h </w:instrText></w:r>
  <w:r><w:fldChar w:fldCharType="separate"/></w:r>
  <w:r><w:t>1</w:t></w:r>
  <w:r><w:fldChar w:fldCharType="end"/></w:r>
</w:p>
```

## Options

### Option A: Generate TOC entries from model
Walk the model structure, collect all section titles and their heading levels, render them as TOC1/TOC2/TOC3 paragraphs with PAGEREF fields.

### Option B: Insert a TOC field instruction
Insert a single Word field instruction `{ TOC \o "1-3" }` that Word populates when the document is opened. This is simpler but requires the user to update fields in Word.

### Recommendation

Use Option A for accuracy — generate actual TOC entries matching the reference. Each entry needs:
- Correct TOC style (TOC1/TOC2/TOC3 based on heading depth)
- Section title text
- Tab character
- PAGEREF field pointing to the bookmark

## Files to Change

- `lib/isodoc/iso/docx/toc_builder.rb` — omit entries for clauses without a heading
- `lib/isodoc/iso/docx/preface_renderer.rb` — bookmark the Foreword and Introduction headings
- `lib/isodoc/iso/docx/renderers/references_renderer.rb` — bookmark the Normative references heading
- `lib/isodoc/iso/docx/adapter.rb` — bookmark the Bibliography heading in `visit_references_section`
