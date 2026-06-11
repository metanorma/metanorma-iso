# TODO 027: Fix Image Naming and Cleanup

## Status: WONTFIX

## What

The adapter generates temp-style image filenames (e.g., `img20260607-484-pet63n.png`) instead of clean names (`image3.png`, `image4.png`). Word strips these temp images during repair.

## Why

### Current State

Broken output has 4 images:
- `image1.png` (43KB) — template image
- `image2.png` (49KB) — template image
- `img20260607-484-pet63n.png` (8KB) — adapter-generated (temp name)
- `img20260607-484-qzqj1o.png` (22KB) — adapter-generated (temp name)

After repair, Word keeps only 2 images (the temp ones, renamed):
- `image1.png` (22KB) — was `img20260607-484-qzqj1o.png`
- `image2.png` (8KB) — was `img20260607-484-pet63n.png`

The template images (ISO logo, etc.) are removed because their rIds are broken after the repair strips header/footer references.

### Expected

Images should use sequential naming (`image1.png`, `image2.png`, etc.) starting after the template's existing images. The relationships should be properly created and referenced.

## Architecture

1. Preserve template images and their relationships
2. Name new images sequentially (image3.png, image4.png, etc.)
3. Create proper relationship entries for each image
4. Ensure rIds are correctly assigned and don't collide with existing ones

## Files

- `lib/isodoc/iso/docx/adapter.rb` — image handling

## Depends On

- TODO 014 (header/footer rIds — rId collision is related)
