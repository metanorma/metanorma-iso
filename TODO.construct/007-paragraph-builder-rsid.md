# 007: ParagraphBuilder Generates rsid/paraId/textId

## Problem

`ParagraphBuilder.build` creates `Paragraph` objects without rsid, paraId, or textId. The reconciler's `backfill_paragraphs` (helpers.rb:163-171) must add these:

```ruby
para.rsid_r ||= rsid
para.rsid_r_default ||= "00000000"
para.para_id ||= generate_hex_id("#{id_seed}:#{idx}")
para.text_id ||= "77777777"
```

Every paragraph in the document is incomplete until reconciler fixes it. This is the single largest "repair" operation — it touches every paragraph.

## Approach

### ParagraphBuilder takes allocator

```ruby
class ParagraphBuilder
  def initialize(allocator = nil)
    @allocator = allocator
    # ... existing init
  end

  def build
    para = Wordprocessingml::Paragraph.new
    # ... existing build logic ...

    # Assign tracking IDs
    if @allocator
      para.rsid_r ||= generate_rsid
      para.rsid_r_default ||= "00000000"
      para.para_id ||= @allocator.alloc_para_id
      para.text_id ||= "77777777"
    end

    para
  end

  private

  def generate_rsid
    "00#{Digest::SHA256.hexdigest("rsid:#{@allocator.object_id}")[0..5].upcase}"
  end
end
```

### Thread allocator through creation sites

- `DocumentBuilder.paragraph` (line 76-82): pass `@allocator`
- `DocumentBuilder.heading` (line 90-96): pass `@allocator`
- `HeaderFooterBuilder.paragraph` (line 65-69): pass allocator
- `FootnoteBuilder.create_footnote_entry` (line 77-87): pass allocator

## Files

- **Modify**: `lib/uniword/builder/paragraph_builder.rb`
- **Modify**: `lib/uniword/builder/document_builder.rb` — pass allocator to ParagraphBuilder.new
- **Modify**: `lib/uniword/builder/header_footer_builder.rb` — pass allocator
- **Modify**: `lib/uniword/builder/footnote_builder.rb` — pass allocator

## Acceptance

- Every paragraph created via builder has rsid_r, rsid_r_default, paraId, textId
- No reconciler `backfill_paragraphs` needed
- IDs are deterministic for same content (via allocator)
- Template paragraphs loaded via `from_file` keep their existing IDs (populated-first)

## Dependencies

- [[001-id-allocator]]
- [[003-document-builder-allocator]]
