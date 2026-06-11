# TODO 022: Remove Explicit Page Breaks Before Annexes — ANNEX Style Has pageBreakBefore

## Status: DONE

## What

The adapter renders explicit `<w:br w:type="page"/>` page breaks before each ANNEX paragraph. The ANNEX style already has `pageBreakBefore`, so the explicit break causes a double page break or unnecessary empty paragraph.

## Why

### Current (Broken)

```xml
<w:p>
  <w:r>
    <w:br w:type="page"/>    <!-- Explicit page break paragraph -->
  </w:r>
</w:p>
<w:p>
  <w:pStyle w:val="ANNEX"/>  <!-- Style already has pageBreakBefore -->
  <w:t>Annex A</w:t>
  ...
</w:p>
```

### Expected

```xml
<w:p>
  <w:pStyle w:val="ANNEX"/>  <!-- pageBreakBefore in style definition handles it -->
  <w:t>(normative)</w:t>
  ...
</w:p>
```

The ANNEX style has `<w:pageBreakBefore/>` in its definition, so each ANNEX paragraph automatically starts on a new page. No explicit page break is needed.

## Architecture

Remove the explicit `<w:br w:type="page"/>` paragraph before ANNEX paragraphs. The style's `pageBreakBefore` handles page breaks automatically.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — annex rendering

## Depends On

- None
