---
title: 108-006 - Fix missing image (5th image for Annex C subfigures)
priority: P1
status: open
---

# 108-006: Fix Missing Image

## Problem

Reference has 5 images, latest has 4. The missing image is likely the second subfigure in Annex C.

### Reference images:
- image1.png (2260×1091) — Annex A figure (split-it-right divider)
- image2.png (2937×1180) — Table or figure
- image3.png — Annex C, Figure C.1 (gelatinization curve)
- image4.png — Annex C, Figure C.2a (initial stages)
- image5.png — Annex C, Figure C.2b/c (intermediate/final stages)

### Latest images:
- image1.png (2260×1091) — same as ref image1
- image2.png (2937×1180) — same as ref image2
- img20260611-*.png (2 files) — Annex C images

The reference has 5 separate image files. Latest has 4. One subfigure image is missing.

## Root Cause

The adapter renders `visit_figure` → `visit_image_element` for each figure's image. Subfigures (Figure C.2 with parts a/b/c) may not all have their images rendered. The model might have subfigure elements that aren't being visited.

## Fix

1. Check if the model has subfigure/image elements for all parts of Figure C.2
2. Ensure visit_figure handles subfigures (nested figures with multiple images)
3. Verify all image sources resolve to valid files

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — visit_figure, visit_image_element
