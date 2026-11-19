# 005 — Section page breaks and sectPr

## Problem
ISO documents have distinct page sections with different headers/footers:
- Cover page → no header/footer
- Body → header with document ref, footer with page number
- Annexes may have different headers

Currently `apply_final_section` creates a single section with hardcoded margins
and strips all template headers/footers.

## Fix
- Preserve template page margins (from template's sectPr) instead of hardcoding
- Create section breaks between major sections
- Add header/footer with document reference text and page numbers

## Status: DONE — headerReference/footerReference now appear in sectPr output

Root cause: `wire_builder_headers_footers` in the reconciler generated new rIds
via `next_available_rid`, but `reconcile_document_rels_from_allocator` assembled
rels from the allocator (which had seeded template rIds). The sectPr refs used
rId32/rId33 while the document_rels used rId12/rId13 — mismatch caused
`reconcile_sect_pr_references` to strip them as "dangling".

Fix: `wire_parts_to_rels` now calls `allocator.alloc_rid` when allocator is
present, so the rIds match the allocator's records and survive integrity checks.

## Remaining work — DONE (2026-11-19)
- Section breaks: already present (cover, front matter, body) via
  `SectionManager`; measured on rice output: 3 sectPr, cover/front in pPr,
  body final. Annexes stay in the body section, as in the 2016 reference
  (no annex break; annex headers are not a DIS requirement).
- Per-section header/footer: already wired (cover blank parts, front and body
  template parts rewritten with document ref and PAGE field).
- Template margins: front matter and body sectPr now take pgMar from the DIS
  template's own section 2 and 3 (left/right 851, bottom 567, footer 283)
  instead of the hardcoded 1077/720. The cover keeps the reference-style
  layout (851/737, gutter 567); the template's cover sectPr is a plain page.
  Falls back to the old constants when a template has no such section.
- Proof: `section_manager_spec.rb` DIS example expects template margins; with
  the template lookup replaced by the constants it fails (got 1077/720/720).

## Files
- `lib/isodoc/iso/docx/adapter.rb` — `apply_final_section`, `apply_header_footer`
- `lib/uniword/docx/reconciler/body.rb` — `wire_parts_to_rels` uses allocator
