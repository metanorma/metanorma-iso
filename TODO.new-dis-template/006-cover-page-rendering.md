# TODO 006: Update Cover Page Rendering

## Status: COMPLETE

## What

Update the cover page rendering to match the new reference DOCX structure: `zzCoverlarge` → `zzCover` lines → `CoverTitleA1/A2` → `zzCopyright` block.

## Why

The reference DOCX cover page has a specific paragraph structure that differs from the old template:
1. `zzCoverlarge` — document identifier (e.g., "ISO/DIS 15926-100(en)")
2. `zzCover` — "First edition"
3. `zzCover` — blank line
4. `zzCover` — "Date: 2025-05-30"
5. `CoverTitleA1` — intro title + main title
6. `CoverTitleA2` — "Part 100: Vocabulary" (complement)
7. (blank)
8. `zzCopyright` — "© ISO 2025"
9. `zzCopyright` — copyright notice text
10. `zzCopyrightaddress` — ISO office address lines
11. `zzCopyright` — "Published in Switzerland"

The old template used `coverpage-*` styles that don't exist in the new template.

## Architecture

The cover page should be rendered by the adapter from document model metadata, not from the template. The template provides the styles; the adapter provides the content.

### Cover Page Builder

Add a dedicated method that renders the complete cover page from bibdata:

```ruby
def render_cover_page(model, doc)
  # Document identifier line
  render_cover_text(doc, model_doc_id(model), style: :cover_large)
  # Edition + date
  render_cover_text(doc, edition_text(model), style: :cover_meta)
  render_cover_text(doc, "", style: :cover_meta)
  render_cover_text(doc, "Date: #{publication_date(model)}", style: :cover_meta)
  # Title
  render_cover_text(doc, full_intro_main_title(model), style: :cover_title)
  render_cover_text(doc, complement_title(model), style: :cover_subtitle)
  # Blank
  render_cover_text(doc, "", style: :cover_meta)
  # Copyright block
  render_copyright_block(model, doc)
end
```

### Data Sources

All cover page data comes from the document model's bibdata:
- Document ID: `bibdata.docidentifier` — formatted as "ISO/DIS 15926-100(en)"
- Edition: `bibdata.edition` — formatted as "First edition"
- Date: `bibdata.date` — formatted as "Date: YYYY-MM-DD"
- Title intro + main: `bibdata.titles` — combined into CoverTitleA1
- Title complement: `bibdata.titles` — "Part N: Title"
- Copyright year: `bibdata.copyright.from`
- Copyright holder: `bibdata.copyright.holder`

## Files

- `lib/isodoc/iso/docx/adapter.rb` — cover page rendering methods
- `lib/isodoc/iso/docx/context.rb` — cover section state

## Depends On

- TODO 002 (new template with correct styles)
- TODO 005 (style mapping for cover styles)
