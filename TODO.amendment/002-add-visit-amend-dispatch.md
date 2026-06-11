# TODO 002: Add AmendBlock to visit_block Dispatch

## Status: COMPLETE

### What

Add `Metanorma::StandardDocument::Blocks::AmendBlock` to the `visit_block` case/when dispatch so that amendment body content is rendered instead of silently dropped.

### Changes

1. **`lib/isodoc/iso/docx/adapter.rb`** — `visit_block` method (~line 757):
   Add `when Metanorma::StandardDocument::Blocks::AmendBlock` → `visit_amend(block, doc)`

2. **`lib/isodoc/iso/docx/adapter.rb`** — `fallback_walk` method (~line 1068):
   Add `:amend` to `block_attrs` list

3. **`lib/isodoc/iso/docx/adapter.rb`** — new method `visit_amend`:
   - Renders amendment description (instruction text)
   - Renders amendment newcontent (replacement/new text)

### Depends On

- TODO 003 (render_amend_content_block implementation)
