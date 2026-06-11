# TODO 023: Remove variant-title-toc Paragraphs

## Status: DONE

## What

The adapter renders `variant-title-toc` paragraphs after each ANNEX heading, containing "Annex A" + tab + title text. These don't exist in the DIS template reference (0 occurrences) and appear to be an internal adapter artifact.

## Why

### Current (Broken)

```xml
<w:pStyle w:val="ANNEX"/>
<w:t>Annex A</w:t>
...
<w:pStyle w:val="variant-title-toc"/>   <!-- SHOULD NOT EXIST -->
<w:t>Annex A</w:t>
<w:tab/>
<w:t>Determination of defects</w:t>
```

The `variant-title-toc` style is defined in the template as a bare style with no formatting (no `basedOn`, minimal properties). It appears to be a placeholder or internal style not intended for visible content.

### Expected (DIS Template)

The DIS template has NO `variant-title-toc` paragraphs after ANNEX headings. The ANNEX paragraph itself contains the title information.

## Architecture

Remove `variant-title-toc` rendering from the adapter. The annex title information is already in the ANNEX paragraph.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — annex rendering

## Depends On

- None
