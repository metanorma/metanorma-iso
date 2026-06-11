# 010: Adapter Template Seeding — Eliminate Whitelist

## Problem

`adapter.rb` uses `INFRASTRUCTURE_REL_TYPES` whitelist to decide which template relationships to keep:

```ruby
INFRASTRUCTURE_REL_TYPES = %w[
  styles settings fontTable webSettings numbering
  theme footnotes endnotes header footer
].freeze

def clear_stale_template_content(root)
  root.document_rels.relationships.reject! do |r|
    type_str = r.type.to_s
    next false unless type_str.include?("/relationships/")
    INFRASTRUCTURE_REL_TYPES.none? { |t| type_str.end_with?("/#{t}") }
  end
end
```

This is fragile:
- Hyperlinks aren't infrastructure → stripped → but body still references them → broken
- Any new relationship type must be added to the whitelist → maintenance burden
- OLE objects, customXml, embeddings — all stripped, some might be needed

## Approach

### Replace whitelist with allocator-driven approach

1. Load template into Package
2. Call `package.populate_allocator` — seeds ALL rels (including hyperlinks, images, etc.)
3. Builders create new content through the allocator
4. At save time, the allocator produces the complete rels list

The allocator knows exactly what exists because:
- Template rels were seeded into it
- Builder-created rels were allocated through it
- Template rels that are superseded by builder output are naturally replaced (same target → same rId)

### Remove `clear_stale_template_content` entirely

The adapter no longer needs to strip anything. The allocator handles what goes into the final rels.

### How "superseding" works

If the template has `rId5 -> media/image1.png` and the builder creates a new image at `media/image1.png`:
- `alloc_rid(target: "media/image1.png", ...)` returns the existing `rId5`
- The builder's image data replaces the template's image data in `image_parts`
- The rel is preserved with the same rId

If the builder creates `media/photo.png` (new file):
- `alloc_rid(target: "media/photo.png", ...)` allocates a new `rId{N}`
- The rel is new

## Files

- **Modify**: `lib/isodoc/iso/docx/adapter.rb` — remove `clear_stale_template_content`, use allocator
- **Depends on**: `lib/uniword/docx/package.rb` — `populate_allocator` from [[002]]

## Acceptance

- `INFRASTRUCTURE_REL_TYPES` whitelist is removed
- Template hyperlinks are preserved (not stripped)
- Template image rels are preserved or correctly superseded
- No dangling references in document body
- rice_fixed20.docx opens in Word without errors

## Dependencies

- [[001-id-allocator]]
- [[002-populate-first-loading]]
- [[004-image-builder-rids]] — images must use allocator
- [[009-hyperlink-tracking]] — hyperlinks must be tracked
