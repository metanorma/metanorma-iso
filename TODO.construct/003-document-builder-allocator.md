# 003: DocumentBuilder Owns Allocator — Distribution Point

## Problem

`DocumentBuilder` (line 36-41) creates local counters:
```ruby
@bookmark_counter = 0
@footnote_builder = FootnoteBuilder.new(self)
@comment_counter = 0
```

These are independent from the package's allocator. When editing a template, these counters start at 0, colliding with existing IDs.

## Approach

DocumentBuilder receives or creates the `IdAllocator` and distributes it to all child builders.

### Changes to `document_builder.rb`

```ruby
class DocumentBuilder < BaseBuilder
  attr_reader :allocator

  def initialize(model = nil, allocator: nil)
    super(model)
    @allocator = allocator || IdAllocator.new
    @footnote_builder = FootnoteBuilder.new(self, allocator: @allocator)
  end

  # When loading from file, use the package's seeded allocator
  def self.from_file(path)
    package = Uniword.load(path)
    doc = new(package, allocator: package.allocator)
    doc
  end
```

### Update methods that use local counters

- `bookmark` (line 200-210): replace `@bookmark_counter += 1` with `@allocator.alloc_bookmark_id`
- `comment` (line 389-402): replace `@comment_counter += 1` with `@allocator.alloc_comment_id`
- Remove `@bookmark_counter` and `@comment_counter` instance variables

## Files

- **Modify**: `lib/uniword/builder/document_builder.rb`

## Acceptance

- `DocumentBuilder.new` creates its own allocator
- `DocumentBuilder.from_file("template.docx")` uses the package's seeded allocator
- `doc.allocator` is accessible for child builders
- Bookmark and comment IDs come from allocator

## Dependencies

- [[001-id-allocator]]
- [[002-populate-first-loading]] (for `from_file` path)
