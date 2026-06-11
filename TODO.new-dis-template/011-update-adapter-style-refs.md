# TODO 011: Update Adapter for New Style Names

## Status: COMPLETE

## What

Update all adapter code that references old-style IDs to use the new template's style names.

## Why

Several style IDs changed between the old and new templates. The adapter code has hardcoded style references that will break with the new template.

## Specific Changes Needed

### adapter.rb

Search for all direct style ID references and update:

| Old Reference | New Reference | Where |
|--------------|---------------|-------|
| `"Note0"` or style key `:note` → resolves to `Note0` | Resolves to `Note` | visit_note, style_resolver |
| `"Example0"` or style key `:example` → resolves to `Example0` | Resolves to `Example` | visit_example |
| `"Figuretitle0"` → resolves via `:figure_title` | Resolves to `Figuretitle` | visit_figure |
| `"Tabletitle0"` → resolves via `:table_title` | Resolves to `Tabletitle` | visit_table |
| `"Terms"` → resolves via `:terms` | Resolves to `Terms0` | visit_term |
| `"TermNum"` → resolves via `:term_num` | Resolves to `TermNum3` (depth-aware) | visit_term |
| `"AdmittedTerm"` → resolves via `:admitted_term` | Resolves to `TermsAdmitted` | visit_term |
| `"boilerplate-copyright"` → resolves via `:colophon` | Resolves to `zzCopyright` | visit_copyright |
| `"BlockText"` → resolves via `:quote` | Resolves to `Disp-quotep` | visit_quote |

### style_resolver.rb

- Update `CLASS_ALIASES` if needed
- Add `term_number_style` method (see TODO 007)
- Update `context_body_style` if old style names are used

### inline_renderer.rb

- Check for any hardcoded character style references
- Update `Hyperlink` if needed (unchanged)
- Remove references to old semantic markup styles (`bib*`, `std*`, `au*`, `cite*`)

## Files

- `lib/isodoc/iso/docx/adapter.rb` — update all style references
- `lib/isodoc/iso/docx/style_resolver.rb` — update style resolution
- `lib/isodoc/iso/docx/inline.rb` — update inline rendering
- `lib/isodoc/iso/docx/model_utils.rb` — update any style references

## Depends On

- TODO 002 (new template)
- TODO 005 (updated style mapping)
