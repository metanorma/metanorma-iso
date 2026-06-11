# TODO 018: Fix Section Break Placement — Use Content Paragraph pPr, Not PAGEBREAK Paragraphs

## Status: DONE

## What

The adapter creates standalone `PAGEBREAK` paragraphs for section breaks. The DIS template embeds section breaks (`sectPr`) inside content paragraph `pPr` — no separate `PAGEBREAK` paragraphs exist.

## Why

### Current (Broken) Structure

```xml
<!-- Cover content... -->
<w:p>
  <w:pPr>
    <w:pStyle w:val="PAGEBREAK"/>
    <w:sectPr>...</w:sectPr>       <!-- Cover section break -->
  </w:pPr>
</w:p>
<w:p>
  <w:pPr>
    <w:pStyle w:val="zzContents"/>
  </w:pPr>
  <w:t>Contents</w:t>
</w:p>
<!-- TOC entries... -->
<!-- Foreword, Introduction... -->
<w:p>
  <w:pPr>
    <w:pStyle w:val="PAGEBREAK"/>
    <w:sectPr>...</w:sectPr>       <!-- Front matter section break -->
  </w:pPr>
</w:p>
<w:p>
  <w:pStyle w:val="MainTitle1"/>
  <w:t>Cereals and pulses — ...</w:t>
</w:p>
```

### Expected (DIS Template) Structure

```xml
<!-- Cover content... last cover paragraph has sectPr in its pPr -->
<w:p>
  <w:pPr>
    <w:pStyle w:val="zzCover"/>
    <w:sectPr>                     <!-- Cover section break embedded in content -->
      <w:headerReference ... />
      <w:titlePg/>
      ...
    </w:sectPr>
  </w:pPr>
  <w:t>Représentation standard...</w:t>  <!-- Paragraph has content too -->
</w:p>
<!-- Copyright block starts on new page (zzCopyright has pageBreakBefore) -->
<w:p>
  <w:pStyle w:val="zzCopyright"/>
  <w:pageBreakBefore/>
  <w:t>© ISO 2022</w:t>
</w:p>
<!-- ... more copyright ... -->
<!-- zzContents starts on new page (has pageBreakBefore) -->
<w:p>
  <w:pStyle w:val="zzContents"/>
  <w:t>Contents</w:t>
</w:p>
<!-- TOC entries... -->
<!-- Foreword... Introduction... -->
<!-- Front matter section break embedded in last pre-body paragraph -->
<w:p>
  <w:pPr>
    <w:pStyle w:val="BodyText"/>
    <w:sectPr>                     <!-- Front matter section break -->
      <w:headerReference ... />
      <w:pgNumType w:fmt="lowerRoman"/>
    </w:sectPr>
  </w:pPr>
</w:p>
<!-- zzSTDTitle starts body section -->
<w:p>
  <w:pStyle w:val="zzSTDTitle"/>
  <w:t>...</w:t>
</w:p>
```

### Key Differences

1. **No `PAGEBREAK` paragraphs** — Section breaks are embedded in the `pPr` of content paragraphs
2. **Cover section break** is in the last `zzCover` paragraph (the French title in the template)
3. **Front matter section break** is in the last paragraph before body (a `BodyText` paragraph at the end of the Introduction)
4. **No explicit page break before copyright** — `zzCopyright` style has `pageBreakBefore`
5. **No explicit section break between copyright and TOC** — `zzContents` style has `pageBreakBefore`

### Impact

Having separate `PAGEBREAK` paragraphs with `sectPr` is technically valid OOXML, but the empty paragraph with no content is unusual. More critically, the current approach creates an extra blank paragraph in the output that doesn't exist in the reference.

## Architecture

### Approach: Embed sectPr in existing content paragraphs

1. **Cover section break**: Embed in the last cover paragraph's `pPr`. If the last cover paragraph is the copyright block, use the "Published in Switzerland" paragraph.
2. **Front matter section break**: Embed in the last paragraph before the body. This is the last paragraph of the Introduction section.

### Alternative: Keep PAGEBREAK paragraphs but ensure compatibility

If embedding is too invasive, keep the current approach but fix the other issues (rIds, margins, etc.). The separate paragraph approach is valid OOXML — it's just not what the DIS template does.

### Recommendation: Fix first, refactor later

The PAGEBREAK approach works. The critical fix is the rId references (TODO 014). Refactoring to embed sectPr in content paragraphs can be deferred.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `insert_section_break` and `visit_root` methods

## Depends On

- TODO 014 (fix header/footer rIds)
