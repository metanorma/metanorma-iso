---
title: BUG 003 - Images rendered as base64 text instead of drawings
priority: P0
status: closed
---

# BUG 003: Images Rendered as Base64 Text Instead of Drawings

## Symptom

Figures in the document show literal base64 image data instead of the
actual image. The user sees:

```
[Image: wUZlqg3RIwRgAAAAABJRU5ErkJggg==]
Figure A.1 — Split-it-right sample divider
```

## Root Cause

The adapter is outputting the base64-encoded image data as paragraph
text instead of constructing a proper `<w:drawing>` element with an
`<a:blip r:embed="rId...">` reference.

Three concurrent defects:

1. **No `<w:drawing>` elements emitted.** `grep -c 'w:drawing' word/document.xml`
   returns 0. Every image becomes a text run with the base64 payload.

2. **Image part names are the base64 payload itself.** The rels file
   contains entries like:
   ```xml
   <Relationship Id="rId35" Type=".../image"
     Target="media/wUZlqg3RIwRgAAAAABJRU5ErkJggg=="/>
   ```
   These are not valid filenames and no such parts exist in the package.

3. **No `word/media/` directory in the package at all.** Even the
   well-named entries (`media/image1.png`, `media/image2.png`) have no
   actual image files because the media directory doesn't exist.

## Evidence

```bash
$ ls word/media/
ls: No such file or directory

$ grep -o 'Target="media/[^"]*"' word/_rels/document.xml.rels | head
Target="media/image1.png"
Target="media/image2.png"
Target="media/wUZlqg3RIwRgAAAAABJRU5ErkJggg=="      # broken
Target="media/h6mWeAAAAAElFTkSuQmCC"                # broken
Target="media/QSBIBAEgkAQCAJBIA..."                  # broken (very long)
```

## Source of Bug

The image rendering path in the adapter (likely `visit_figure` or
`visit_image` in `lib/isodoc/iso/docx/adapter.rb`) is taking the
image's `src` attribute (which is a `data:image/png;base64,...` URI)
and using the base64 portion as both:
- The text content of a run in the paragraph
- The `Target` value for the relationship

What it should do instead:

1. Decode the base64 data URI into raw bytes
2. Write those bytes to `word/media/imageN.png` in the package
3. Allocate an rId via `IdAllocator`
4. Emit `<Relationship Id="rId..." Type=".../image" Target="media/imageN.png"/>`
5. Emit a `<w:drawing>` containing `<wp:inline>` with `<a:blip r:embed="rId...">`

## Fix

Implement a proper `ImageRenderer` that:
- Detects data-URI vs external src
- Decodes base64 → raw bytes
- Delegates to a `MediaRegistry` that assigns stable imageN.png names
  and writes the bytes to the package
- Allocates an rId via `IdAllocator#alloc_rid`
- Builds a `<w:drawing>` with correct wp:inline wrapper, pic:pic element,
  and a:blip reference

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — `visit_figure` / image handling
- New file: `lib/isodoc/iso/docx/image_renderer.rb`
- New file: `lib/isodoc/iso/docx/media_registry.rb` (or extend
  `Uniword::Docx::Package` to manage media)
- `lib/isodoc/iso/docx/zip_packager.rb` — ensure media directory is
  written
