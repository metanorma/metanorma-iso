# 001: Create IdAllocator — Single Owner of All IDs

## Problem

ID assignment is scattered across 7+ independent locations:
- `ImageBuilder.register_image` — `rIdImg{N}` (non-standard format)
- `FootnoteBuilder` — local `@footnote_counter`
- `HeaderFooterBuilder` — no ID tracking at all
- `DocumentBuilder` — local `@bookmark_counter`, `@comment_counter`
- `package_serialization.rb` — `next_rid()` via `PackageRelationships.next_available_rid`
- `reconciler/body.rb` — `find_or_create_rel` generates rIds
- `reconciler/package_structure.rb` — `reconcile_document_rels` fully renumbers all rIds

No single point of truth means IDs collide, get renumbered, or go out of sync.

## Approach

Create `Uniword::Docx::IdAllocator` in `lib/uniword/docx/id_allocator.rb`.

```ruby
module Uniword
  module Docx
    class IdAllocator
      IMAGE_REL_TYPE = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image"
      HEADER_REL_TYPE = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header"
      FOOTER_REL_TYPE = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer"
      HYPERLINK_REL_TYPE = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink"

      def initialize
        @rid_counter = 0
        @rid_map = {}          # target -> rId (prevents duplicates)
        @footnote_counter = 1  # 0 and -1 are separators
        @endnote_counter = 1
        @bookmark_counter = 0
        @comment_counter = 0
        @para_counter = 0
      end

      def alloc_rid(target:, type:)
        @rid_map[[target, type]] ||= begin
          @rid_counter += 1
          "rId#{@rid_counter}"
        end
      end

      def alloc_footnote_id
        id = @footnote_counter
        @footnote_counter += 1
        id
      end

      def alloc_endnote_id
        id = @endnote_counter
        @endnote_counter += 1
        id
      end

      def alloc_bookmark_id
        @bookmark_counter += 1
        @bookmark_counter.to_s
      end

      def alloc_comment_id
        @comment_counter += 1
        @comment_counter.to_s
      end

      def alloc_para_id(seed = nil)
        @para_counter += 1
        # Generate 8-hex-char paraId (Word uses random hex)
        Digest::SHA256.hexdigest("para:#{@para_counter}:#{seed}")[0..7].upcase
      end

      # Seed from template/package relationships — preserves existing rIds
      def seed_from_rels(relationships)
        relationships.each do |r|
          key = [r.target, r.type.to_s]
          @rid_map[key] = r.id
          num = r.id[/\d+/]&.to_i || 0
          @rid_counter = [@rid_counter, num].max
        end
      end

      # Seed footnote/endnote counters from existing note entries
      def seed_from_notes(footnote_entries, endnote_entries)
        footnote_entries&.each do |e|
          id = e.id.to_i
          @footnote_counter = [@footnote_counter, id + 1].max if id > 0
        end
        endnote_entries&.each do |e|
          id = e.id.to_i
          @endnote_counter = [@endnote_counter, id + 1].max if id > 0
        end
      end

      # Seed bookmark/comment counters from document body
      def seed_from_body(body)
        # Walk all paragraphs to find max bookmark/comment IDs
        # Implementation depends on how body traversal works
      end

      # Produce the final ordered list of all allocated relationships
      def all_rels
        @rid_map.map { |(target, type), id|
          { id: id, type: type, target: target }
        }.sort_by { |r| r[:id][/\d+/]&.to_i || 0 }
      end
    end
  end
end
```

## Files

- **New**: `lib/uniword/docx/id_allocator.rb`
- **Modify**: `lib/uniword/docx.rb` or `lib/uniword.rb` — autoload IdAllocator

## Acceptance

- `IdAllocator.new` starts all counters at 0/1
- `alloc_rid` returns deterministic `rId{N}` format
- `seed_from_rels` preserves existing rIds and bumps counter past max
- `all_rels` returns sorted relationship list
- `bundle exec rspec` passes (no existing code changed yet)

## Dependencies

None — pure new code.
