---
title: BUG 011 - Admonitions (CAUTION/WARNING) duplicated
priority: P1
status: closed
---

# BUG 011: Admonitions (CAUTION/WARNING) Duplicated

## Symptom

Every admonition appears twice — once as an empty header and once
with the actual content:

```
CAUTION —
CAUTION — Only use paddy or parboiled rice for the determination
of husked rice yield.

WARNING —
WARNING — Direct contact of iodine with skin can cause lesions...
```

## Root Cause

The presentation XML provides both the semantic `<admonition>` element
and a formatted version (the adapter renders both):

```xml
<admonition type="caution">
  <fmt-name>CAUTION</fmt-name>     <!-- formatted label -->
  <p>Only use paddy or parboiled rice...</p>
</admonition>
```

Or, more likely, the source has both `<fmt-name>` (the label "CAUTION")
and the content `<p>` as siblings inside the admonition. The adapter
is rendering the `fmt-name` once via the dedicated path, then again
via `walk_mixed_content`.

## Evidence

```xml
<!-- First render: no style, no content -->
<w:p>
  <w:pPr/>
  <w:r><w:t>CAUTION</w:t></w:r>
  <w:r><w:t xml:space="preserve"> — </w:t></w:r>
</w:p>

<!-- Second render: Warningtext style with content -->
<w:p>
  <w:pPr><w:pStyle w:val="Warningtext"/></w:pPr>
  <w:r><w:t>CAUTION</w:t></w:r>
  <w:r><w:t xml:space="preserve"> — </w:t></w:r>
  <w:r><w:t>Only use paddy or parboiled rice...</w:t></w:r>
  <w:r><w:br/></w:r>
</w:p>
```

The first paragraph is an orphan — has no style and no body text.

## Fix

The adapter should render each admonition exactly once with its full
content (label + text in one paragraph using the `Warningtext` style).

Two likely paths depending on the exact source structure:

1. If `fmt-name` is being rendered as a separate paragraph by an early
   pass and then `walk_mixed_content` renders the full admonition
   again — remove the early pass and rely on the full admonition
   render.

2. If the issue is that `walk_mixed_content` after `visit_admonition`
   re-walks the admonition's children (label and content separately),
   remove the trailing `walk_mixed_content` call from `visit_admonition`.

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — `visit_admonition` (or wherever
  the duplication originates)

## Related

Same root cause as BUG 008: explicit visitors + final
`walk_mixed_content` causes duplicate rendering of children.
