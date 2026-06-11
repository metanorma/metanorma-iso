# 002: Populate-First Loading — Parse All IDs Before Modification

## Problem

When loading a template DOCX for editing, the system must parse and preserve ALL existing IDs before any builder runs. If we don't:

- New rIds collide with template rIds (e.g., builder assigns `rId1` but template already has `rId1` → styles)
- Bookmark IDs collide with template bookmarks
- Footnote IDs don't account for separator entries (id=0, id=-1)
- paraId/textId counters produce values that already exist in template paragraphs

Currently `Package.from_file` / `Package.from_zip` load the template into model objects but never extract ID ranges. The reconciler then renumbers everything, breaking references.

## Approach

Add a `populate_from_template` step to `Package` that seeds the `IdAllocator` from all loaded template data. This is called **before** any builder runs.

### Where to add

In `lib/uniword/docx/package.rb`, after loading template:

```ruby
def self.from_file(path)
  package = from_zip(Zip::File.open(path))
  package.populate_allocator
  package
end

def populate_allocator
  @allocator = IdAllocator.new
  @allocator.seed_from_rels(document_rels.relationships) if document_rels&.relationships
  @allocator.seed_from_rels(package_rels.relationships) if package_rels&.relationships
  @allocator.seed_from_notes(
    footnotes&.footnote_entries,
    endnotes&.endnote_entries
  )
  # Walk body paragraphs to seed bookmark/paraId counters
  # Walk headers/footers to seed their paraId counters
end

attr_reader :allocator
```

### The principle

**Creating from scratch**: allocator starts empty. All IDs are fresh.

**Editing a template**: allocator is populated FIRST from template. New IDs are guaranteed not to collide.

This is the fundamental difference. Without populate-first, editing always breaks the template's ID space.

## Files

- **Modify**: `lib/uniword/docx/package.rb` — add `populate_allocator`, `allocator` accessor
- **Modify**: `lib/uniword/docx/package.rb` — `from_file` calls `populate_allocator`

## Acceptance

- `Package.from_file("template.docx")` produces a package with a seeded allocator
- `package.allocator.all_rels` includes all template relationships
- `package.allocator.alloc_rid(...)` returns IDs that don't collide with template IDs
- Template that has `rId1` through `rId10`: allocator returns `rId11` for next allocation

## Dependencies

- [[001-id-allocator]] must exist first
