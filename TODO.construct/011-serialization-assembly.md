# 011: Serialization Assembly — Replace inject_* with Allocator-Driven Assembly

## Problem

`package_serialization.rb` has 11 `inject_*` methods (lines 191-394) that:
1. Append relationships to `document_rels.relationships` using `next_rid()`
2. Append content type overrides
3. Wire sectPr header/footer references via `wire_header_reference` / `wire_footer_reference`

This is the "repair at serialization time" pattern. It duplicates what builders should have done:
- `inject_image_parts` — creates rels for images that ImageBuilder already registered
- `inject_headers` / `inject_footers` — creates rels and wires sectPr for headers/footers
- `inject_header_footer_parts` — same for template-loaded headers/footers
- `inject_notes` / `inject_theme` / `inject_numbering` — creates rels for infrastructure parts

These 11 methods generate rIds independently from the reconciler and from each other. They are the reason the reconciler must renumber everything.

## Approach

### Replace `inject_part_relationships` with allocator-driven assembly

The allocator already knows about all relationships (seeded from template + allocated by builders). At serialization time:

1. Read `allocator.all_rels` to build the complete document.xml.rels
2. Build content types from present parts (this is already correct in `content_type_overrides_for_present_parts`)
3. Serialize

```ruby
def assemble_package(content, content_types, package_rels, document_rels, allocator)
  # Build document_rels from allocator
  if document_rels && allocator
    document_rels.relationships = allocator.all_rels.map do |entry|
      Ooxml::Relationships::Relationship.new(
        id: entry[:id],
        type: entry[:type],
        target: entry[:target],
        target_mode: entry[:target_mode],
      )
    end
  end

  # Content types: use existing logic (already correct)
  reconcile_content_types  # keep this — it reads from present parts

  # Serialize (keep existing serialization logic)
  serialize_package_parts(content, content_types, package_rels, document_rels)
end
```

### Remove these methods entirely

- `inject_part_relationships` and all 11 sub-methods
- `next_rid` — allocator handles ID generation
- `ensure_part_registered` — allocator + content_types logic handles this
- `wire_header_reference` / `wire_footer_reference` — builders wire during construction

### Keep these serialization methods

- `serialize_package_parts` — serializes model objects to XML (pure output, no ID generation)
- `serialize_part` / `serialize_infrastructure` — XML serialization helpers
- `serialize_headers` / `serialize_footers` / `serialize_header_footer_parts` — pure serialization

## Files

- **Modify**: `lib/uniword/docx/package_serialization.rb` — remove inject_* methods, add assemble_package
- **Modify**: `lib/uniword/docx/package.rb` — call assemble_package instead of inject_part_relationships

## Acceptance

- All `inject_*` methods removed
- `next_rid` removed
- Document rels built from allocator
- Content types built from present parts
- Image parts, headers, footers, hyperlinks all have correct rels
- No rId renumbering needed
- `bundle exec rspec` passes

## Dependencies

- [[001-id-allocator]]
- [[004-image-builder-rids]]
- [[005-footnote-builder-complete]]
- [[006-header-footer-complete]]
- [[009-hyperlink-tracking]]
- [[010-adapter-template-seeding]]
