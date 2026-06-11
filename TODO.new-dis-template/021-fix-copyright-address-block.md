# TODO 021: Fix Copyright Address Block — Separate Paragraphs, Not br-Combined

## Status: DONE

## What

The copyright address block uses `<w:br/>` line breaks within a single paragraph. The DIS template uses separate `zzCopyright` paragraphs for each address line.

## Why

### Current (Broken)

```xml
<w:pStyle w:val="zzCopyright"/>
<w:t>ISO copyright office</w:t>
<w:br/>
<w:t xml:space="preserve"> CP 401 • Ch. de Blandonnet 8</w:t>
<w:br/>
<w:t xml:space="preserve"> CH-1214 Vernier, Geneva</w:t>
<w:br/>
<w:t xml:space="preserve"> Phone: +41 22 749 01 11</w:t>
<w:br/>
<w:t xml:space="preserve"> Email:  </w:t>
<!-- hyperlink -->
```

One paragraph with multiple `<w:br/>` breaks.

### Expected (DIS Template)

```xml
<w:pStyle w:val="zzCopyright"/>
<w:t>ISO copyright office</w:t>
</w:p>
<w:pStyle w:val="zzCopyright"/>
<w:t>CP 401 • Ch. de Blandonnet 8</w:t>
</w:p>
<w:pStyle w:val="zzCopyright"/>
<w:t>CH-1214 Vernier, Geneva</w:t>
</w:p>
<w:pStyle w:val="zzCopyright"/>
<w:t>Phone: +41 22 749 01 11</w:t>
</w:p>
<w:pStyle w:val="zzCopyright"/>
<w:t>Email: copyright@iso.org</w:t>
</w:p>
<w:pStyle w:val="zzCopyright"/>
<w:t xml:space="preserve">Website: </w:t>
<!-- hyperlink to www.iso.org -->
</w:p>
```

Each line is a separate `zzCopyright` paragraph with `ind left="102" right="102" firstLine="403"`.

## Architecture

Change the copyright address rendering to output separate paragraphs instead of br-combined text. Each address line becomes its own paragraph with the appropriate indentation.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — copyright rendering method

## Depends On

- None
