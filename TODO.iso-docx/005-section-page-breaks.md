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

## Remaining work
- Multiple section breaks between major sections (cover, body, annex)
- Per-section header/footer content (document ref, page number)
- Preserve template page margins instead of hardcoding

## Files
- `lib/isodoc/iso/docx/adapter.rb` — `apply_final_section`, `apply_header_footer`
- `lib/uniword/docx/reconciler/body.rb` — `wire_parts_to_rels` uses allocator
