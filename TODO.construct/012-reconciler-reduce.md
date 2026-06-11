# 012: Reduce Reconciler to Profile + Validation Only

## Problem

The reconciler currently does three categories of work:

1. **Repair** (must eliminate): renumbering rIds, backfilling paragraph IDs, adding missing note separators, creating missing table properties, wiring headers/footers
2. **Profile defaults** (legitimate): setting ISO fonts, styles, settings, theme
3. **Validation** (legitimate): checking referential integrity

Repair operations become unnecessary once builders produce complete output and the allocator manages IDs.

## Approach

### Keep — Profile defaults

These set ISO-specific values. They're not fixing bugs — they're applying a profile:
- `reconcile_settings` — zoom, default tab stop, track changes
- `reconcile_fonts` — ISO font table (Cambria, Calibri, SimSun, etc.)
- `reconcile_styles` — ISO style definitions
- `reconcile_theme` — ISO theme colors
- `reconcile_app_properties` — application metadata

### Keep — Validation (convert to checks)

- `referential_integrity.rb` — keep but change from silent fixes to raises/warnings:
  ```ruby
  # OLD: remove dangling refs silently
  # NEW: raise error listing dangling refs
  def validate_referential_integrity
    dangling = find_dangling_references
    unless dangling.empty?
      raise IntegrityError, "Dangling references: #{dangling.inspect}"
    end
  end
  ```

### Remove — Repair operations

These are all superseded by correct-by-construction builders + allocator:

| Method | File | Superseded by |
|---|---|---|
| `reconcile_document_rels` (rId renumbering) | `package_structure.rb:75-119` | [[011-serialization-assembly]] |
| `wire_builder_headers_footers` | `body.rb:94-136` | [[006-header-footer-complete]] |
| `backfill_paragraphs` | `helpers.rb:163-171` | [[007-paragraph-builder-rsid]] |
| `ensure_separators` | `notes.rb:125-139` | [[005-footnote-builder-complete]] |
| `reconcile_single_table` (property creation) | `tables.rb:34-122` | [[008-table-builder-defaults]] |
| `renumber_notes` | `notes.rb:191-217` | [[005-footnote-builder-complete]] |

### Simplify `reconcile_document_rels`

Instead of rebuilding all rIds, just read from allocator:

```ruby
def reconcile_document_rels
  # Already handled by allocator-driven assembly in serialization
  # Only validate that all referenced parts exist
end
```

## Files

- **Simplify**: `lib/uniword/docx/reconciler/package_structure.rb` — remove rId renumbering
- **Simplify**: `lib/uniword/docx/reconciler/body.rb` — remove wire_builder_headers_footers, backfill
- **Simplify**: `lib/uniword/docx/reconciler/notes.rb` — remove ensure_separators, renumber_notes
- **Simplify**: `lib/uniword/docx/reconciler/tables.rb` — remove property creation (keep gridAfter)
- **Simplify**: `lib/uniword/docx/reconciler/helpers.rb` — remove backfill_paragraphs
- **Convert**: `lib/uniword/docx/reconciler/referential_integrity.rb` — raise instead of fix

## Acceptance

- Reconciler only does profile defaults and validation
- No rId renumbering
- No paragraph backfilling
- No note separator creation
- No table property creation
- Referential integrity check raises on errors (doesn't silently fix)
- `bundle exec rspec` passes

## Dependencies

- All previous TODOs (004-011) must be done first
