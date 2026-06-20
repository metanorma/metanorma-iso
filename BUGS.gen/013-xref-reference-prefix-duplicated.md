---
title: BUG 013 - Cross-reference "Reference" prefix duplicated
priority: P1
status: closed
---

# BUG 013: Cross-Reference "Reference" Prefix Duplicated

## Symptom

Bibliography cross-references show "Reference" twice before the
citation:

```
For details on the determination of protein content using the
Kjeldahl method, see References Reference [11] in the Bibliography.
For details concerning the use of the Dumas method, see References
Reference [16] and Reference [17].
```

Also: "Reference Reference" appears with no citation between in some
places:

```
...that is adapted to the type of cereals or pulses Reference
Reference  and to their use.
```

## Root Cause

The presentation XML wraps xref elements with both a semantic `<xref>`
and a formatted `<fmt-xref-label>` (or similar). Both are being
rendered.

Likely source structure:

```xml
For details ... see <fmt-xref-label>Reference</fmt-xref-label>
<xref target="..."><fmt-xref-label>Reference</fmt-xref-label>
  <formatted citation>[11]</formatted>
</xref> in the Bibliography.
```

Or the adapter's xref renderer prepends "Reference" once, then
walk_mixed_content renders the original `<fmt-xref-label>` text
"Reference" again.

## Evidence

```xml
<w:r>
  <w:t xml:space="preserve"> in the Bibliography. For details ... see References </w:t>
</w:r>
<w:r>
  <w:t xml:space="preserve">Reference </w:t>     <!-- 1st "Reference" -->
</w:r>
<w:hyperlink w:anchor="ref10">
  <w:r><w:rPr><w:rStyle w:val="Hyperlink"/></w:rPr><w:t>[11]</w:t></w:r>
</w:hyperlink>
<w:r>
  <w:t>.</w:t>
</w:r>
```

And:

```xml
<w:r>
  <w:t xml:space="preserve"> ... type of cereals or pulses </w:t>
</w:r>
<w:r><w:t xml:space="preserve">Reference </w:t></w:r>     <!-- 1st -->
<w:r><w:t xml:space="preserve">Reference </w:t></w:r>     <!-- 2nd -->
<w:r><w:t xml:space="preserve"> and to their use.</w:t></w:r>
```

In the second case the citation is missing entirely (just two
"Reference" runs back-to-back).

## Fix

The cross-reference renderer should emit EITHER the prefix OR rely on
the source's `<fmt-xref-label>` — not both. And it should not lose
the citation link.

Investigate `lib/isodoc/iso/docx/inline.rb` for the xref renderer and
the inline walker.

## Files to Change

- `lib/isodoc/iso/docx/inline.rb` — xref rendering, format the citation
  label exactly once

## Related

Same family of bugs as BUG 008 / BUG 011: explicit formatter +
walk_mixed_content duplicating content.
