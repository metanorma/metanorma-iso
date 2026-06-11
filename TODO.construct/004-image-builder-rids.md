# 004: ImageBuilder Uses Allocator for rIds

## Problem

`ImageBuilder.register_image` (line 40) generates `rIdImg{N}` format:
```ruby
r_id = "rIdImg#{root.image_parts.size + 1}"
```

This is non-standard. The reconciler's `reconcile_document_rels` in `package_structure.rb` (line 96-105) renumbers ALL rIds to `rId{N}` format. But it only updates sectPr header/footer references — NOT the `r:embed` attribute in Blip elements inside the document body. So the Blip still references `rIdImg1` while the rels file has `rId3`. Word sees a dangling reference → "unreadable content".

## Approach

### Change `register_image` to accept and use the allocator

```ruby
def self.register_image(document, path)
  root = document.is_a?(DocumentBuilder) ? document.model : document
  allocator = document.is_a?(DocumentBuilder) ? document.allocator : nil

  target = "media/#{File.basename(path)}"
  r_id = if allocator
           allocator.alloc_rid(
             target: target,
             type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image"
           )
         elsif root
           # Fallback for non-allocator path
           "rId#{root.image_parts.size + 1}"
         else
           "rIdImg#{deterministic_id("img_rid", path)}"
         end
  # ... rest unchanged
end
```

### Key invariant

The rId returned by `register_image` is the SAME rId used in `Blip.new(embed: r_id)` (line 308) AND in the image_parts hash AND in the final document rels. No renumbering anywhere.

## Files

- **Modify**: `lib/uniword/builder/image_builder.rb` — `register_image` method (line 36-65)

## Acceptance

- Images get standard `rId{N}` format rIds
- The rId in the Blip element matches the rId in document.xml.rels
- No reconciler renumbering needed for image rIds
- Works with both allocator path (editing) and fallback (standalone)

## Dependencies

- [[001-id-allocator]] — allocator class must exist
- [[003-document-builder-allocator]] — DocumentBuilder must expose allocator
