---
title: BUG 019 - Footnote id=1 reused across many bibitems
priority: P2
status: closed
---

# BUG 019: Footnote id=1 Reused Across Many Bibitems

## Symptom

The same footnote id=1 ("Withdrawn.") is referenced from multiple
bibliography items that have different withdrawal/explanation
footnotes:

```
[1]    ISO 2146:1988,[fn 1: Withdrawn.]
[3]    ISO 5725-1:1994,[fn 1: Withdrawn.]
[4]    ISO 5725-2:1994,[fn 1: Withdrawn.]
```

The reference DOCX has each footnote applied to a DIFFERENT
explanation, but here they all collapse to footnote 1.

## Root Cause

In the source presentation XML, each `<bibitem>` has a `<fn>` element
with a unique `id` and a `<p>` describing the specific status. Example:

```xml
<bibitem id="ISO2146">
  <biblio-tag>[1]<fn id="..." reference="7" target="...">
    <p>Withdrawn.</p>
  </fn>...</biblio-tag>
</bibitem>

<bibitem id="ISO5725-1">
  <biblio-tag>[3]<fn id="..." reference="9" target="...">
    <p>Withdrawn.</p>
  </fn>...</biblio-tag>
</bibitem>
```

Each `<fn>` is a separate footnote with potentially unique content.
The adapter is allocating them all to id=1 (the first footnote) or
failing to allocate new ids and reusing the first.

## Evidence

```bash
$ grep -o 'footnoteReference w:id="[0-9]*"' word/document.xml | sort | uniq -c
   8 footnoteReference w:id="1"
   1 footnoteReference w:id="2"
   1 footnoteReference w:id="3"
   1 footnoteReference w:id="4"
   7 footnoteReference w:id="5"
   2 footnoteReference w:id="6"
   1 footnoteReference w:id="7"
   1 footnoteReference w:id="8"
```

22 footnote references, but only 8 footnote definitions. The same
footnote id is reused 8 times for id=1 and 7 times for id=5.

## Impact

Word reports "Footnote locations are invalid" during repair. Even
though OOXML technically allows the same footnote to be referenced
multiple times, Word's validator rejects this when the references
appear across different bibitems with different status — Word may
expect each unique footnote to have its own id.

## Fix

Each `<fn>` in the source should produce a unique `<w:footnote>` in
`footnotes.xml` with its own id, and a unique `<w:footnoteReference>`
in the document. The adapter should use a `FootnoteRegistry` that
maps source fn ids to OOXML footnote ids and ensures one-to-one
mapping.

For "same content" footnotes (e.g., multiple "Withdrawn." entries),
the registry CAN deduplicate to share an id — but only if the source
marks them as the same footnote (via the `target` attribute pointing
to the same definition).

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — `visit_bibliographic_item` and
  footnote reference emission
- Possibly new `lib/isodoc/iso/docx/footnote_registry.rb` to track
  unique footnote definitions
- `lib/isodoc/iso/docx/context.rb` — already has a footnote_counter,
  but it may not be properly incremented per unique source footnote

## Verification

After fix, the count of unique `footnoteReference w:id` values should
match the count of `<w:footnote>` definitions in footnotes.xml (minus
the separator/continuation separator at id -1 and 0).
