---
title: 108-003 - Add page breaks before Contents, Foreword, Introduction
priority: P1
status: open
depends_on: [108-001]
---

# 108-003: Add Page Breaks Before Contents, Foreword, Introduction

## Problem

The reference DOCX has 9 page breaks. The latest only has 6. Three are missing:

| Location | Before | After | Present? |
|----------|--------|-------|----------|
| Before Contents | "Published in Switzerland" | "Contents" | ❌ MISSING |
| Before Foreword | (after TOC) | "Foreword" | ❌ MISSING |
| Before Introduction | (after Foreword) | "Introduction" | ❌ MISSING |
| Before Annex A | (clause 9 end) | "(normative)..." | ✅ |
| Before Annex B | (Annex A end) | "(informative)..." | ✅ |
| Before Annex C | (Annex B end) | "(informative)..." | ✅ |
| Before Annex D | (Annex C end) | "(informative)..." | ✅ |
| Before Annex E | (Annex D end) | "(informative)..." | ✅ |
| Before Bibliography | (Annex E end) | "Bibliography" | ✅ |

## Root Cause

The adapter renders content in sequence without page breaks between major preface sections:
1. visit_preface → renders Foreword + Introduction back-to-back
2. No page break between them

The reference has separate pages for:
- Copyright page (after cover)
- TOC page
- Foreword page
- Introduction page
- Then body content

## Fix

In `visit_root`, insert page breaks between major sections:

```ruby
def visit_root(model, doc)
  visit_cover_page(model, doc)
  visit_boilerplate(model.boilerplate, doc)
  
  doc.page_break  # Before Contents
  visit_toc(model, doc)
  
  doc.page_break  # Before Foreword
  visit_preface(model.preface, doc)  # Need to add break between Foreword and Introduction
  
  visit_sections(model.sections, doc) if model.sections
  model.annex&.each { |a| visit_annex(a, doc) }  # Already has page_break
  visit_bibliography(model.bibliography, doc)
  apply_final_section(doc)
end
```

And in `visit_preface`, add a page break between Foreword and Introduction:

```ruby
def visit_preface(preface, doc)
  if preface.foreword
    visit_foreword(preface.foreword, doc)
    doc.page_break if preface.introduction  # Before Introduction
  end
  visit_introduction(preface.introduction, doc) if preface.introduction
  preface.clause&.each { |c| visit_clause(c, doc) }
end
```

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — visit_root, visit_preface
