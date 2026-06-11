# 006: HeaderFooterBuilder Creates Complete Paragraphs with IDs

## Problem

`HeaderFooterBuilder` creates paragraphs two ways:

1. **String path** (line 36-37): Creates bare `Paragraph.new` with no rsid, paraId, textId:
   ```ruby
   para = Wordprocessingml::Paragraph.new
   para.runs << Wordprocessingml::Run.new(text: element)
   ```

2. **ParagraphBuilder path** (line 65-69): Uses ParagraphBuilder but that also doesn't generate rsid/paraId yet.

The reconciler's `backfill_paragraphs` in `helpers.rb` (line 163-171) must add these attributes. This means header/footer paragraphs are always incomplete until reconciler fixes them.

## Approach

### Option A: Use ParagraphBuilder for string path too

```ruby
def <<(element)
  case element
  when String
    para = ParagraphBuilder.new
    para << element
    @model.paragraphs << para.build  # ParagraphBuilder will assign IDs via allocator
  # ... rest unchanged
  end
end
```

### Option B: HeaderFooterBuilder takes allocator, assigns IDs directly

This depends on [[007-paragraph-builder-rsid]] being done first, since ParagraphBuilder needs to be the one generating IDs.

### Also: wire headers/footers to sectPr during building

Currently `wire_header_reference` / `wire_footer_reference` in `package_serialization.rb` (line 396-422) wire sectPr references during serialization. This should happen during building instead.

```ruby
def paragraph(text = nil, &block)
  para = ParagraphBuilder.new(@allocator)
  para << text if text
  yield(para) if block
  @model.paragraphs << para.build
  para
end
```

## Files

- **Modify**: `lib/uniword/builder/header_footer_builder.rb`

## Acceptance

- All paragraphs in headers/footers have rsid, paraId, textId from creation
- No reconciler `backfill_paragraphs` needed for header/footer content
- String content path uses ParagraphBuilder internally

## Dependencies

- [[001-id-allocator]]
- [[003-document-builder-allocator]]
- [[007-paragraph-builder-rsid]] (ParagraphBuilder must generate IDs first)
