# 009: Hyperlink rId Tracking Through Allocator

## Problem

Hyperlinks are the bug that caused rice_fixed19.docx to be completely broken. The chain of failure:

1. Template has hyperlink relationships in document.xml.rels
2. `clear_stale_template_content` strips non-infrastructure rels (hyperlinks are not infrastructure)
3. But the document body still has `<w:hyperlink r:id="rId5">` elements
4. rId5 no longer exists in rels → dangling reference → Word can't open the file

Hyperlinks are created by the adapter when converting HTML anchor elements, but the rId assignment is disconnected from the rels file. The hyperlink rIds exist in the document body but have no corresponding entries in document.xml.rels.

## Approach

### When the adapter creates hyperlink elements, register the target URL with the allocator

In the adapter (or wherever `<w:hyperlink>` elements are built):

```ruby
# When building a hyperlink:
r_id = allocator.alloc_rid(
  target: url,
  type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink"
)
hyperlink = Wordprocessingml::Hyperlink.new(r_id: r_id)
```

### At serialization time, the allocator's `all_rels` includes hyperlink entries

The allocator tracks both internal parts (images, headers, footers) AND external hyperlinks. The `target_mode` for hyperlinks is "External".

### External rels need targetMode

Extend `alloc_rid` or `all_rels` to track `target_mode`:

```ruby
def alloc_rid(target:, type:, target_mode: nil)
  @rid_map[[target, type.to_s]] ||= begin
    @rid_counter += 1
    entry = { id: "rId#{@rid_counter}", type: type.to_s, target: target }
    entry[:target_mode] = target_mode if target_mode
    @rid_entries << entry
    entry[:id]
  end
end
```

## Files

- **Modify**: `lib/uniword/docx/id_allocator.rb` — support target_mode
- **Modify**: `lib/isodoc/iso/docx/adapter.rb` — register hyperlinks with allocator
- **Modify**: `lib/uniword/docx/package_serialization.rb` — include hyperlink rels from allocator

## Acceptance

- Every `<w:hyperlink r:id="...">` in document.xml has a matching Relationship in document.xml.rels
- Hyperlink rels have `TargetMode="External"`
- No hyperlinks are stripped by mistake
- No dangling rId references

## Dependencies

- [[001-id-allocator]]
- [[010-adapter-template-seeding]] — adapter must have access to allocator
