# TODO 008: Implement TOC (Table of Contents)

## Status: COMPLETE

## What

Add Table of Contents rendering: a `zzContents` title paragraph followed by a TOC field (SDT content control).

## Why

The reference DOCX has:
1. `PAGEBREAK` paragraph after cover page
2. `zzContents` paragraph with "Contents" text
3. SDT (structured document tag) containing a TOC field
4. Followed by `ForewordTitle` paragraph

The TOC is a Word field that generates automatically when the document is opened in Word. We need to emit the correct OOXML structure so Word generates the TOC.

## Architecture

### TOC Structure in Reference

```xml
<w:p>  <!-- PAGEBREAK paragraph with sectPr for section 1→2 -->
  <w:pPr>
    <w:pStyle w:val="PAGEBREAK"/>
  </w:pPr>
</w:p>
<w:sdt>  <!-- TOC content control -->
  <w:sdtPr>
    <w:id w:val="-677573393"/>
    <w:docPartObj>
      <w:docPartGallery w:val="Table of Contents"/>
      <w:docPartUnique/>
    </w:docPartObj>
  </w:sdtPr>
  <w:sdtContent>  <!-- empty — Word fills this in -->
  </w:sdtContent>
</w:sdt>
```

### Implementation

The adapter should:
1. Render the `zzContents` title paragraph
2. Create an SDT element with TOC docPartObj properties
3. The SDT content is empty — Word will populate it when the document is opened

The SDT needs to be added to the document body at the right position (after cover section break, before Foreword).

### Uniword SDT Support

Check if Uniword supports SDT elements. If not, we may need to:
1. Add SDT support to the document body model
2. Or use the template's existing SDT and preserve it during body clearing

If the template already has an SDT in its body, the adapter can preserve it (don't clear SDTs from the template body).

## Files

- `lib/isodoc/iso/docx/adapter.rb` — TOC rendering
- `data/iso-dis/template.docx` — optionally include TOC SDT in template

## Depends On

- TODO 004 (section layout for cover/front-matter split)
