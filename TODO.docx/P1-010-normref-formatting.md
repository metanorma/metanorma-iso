---
status: done
---

> **Proof (2026-11-19):** Reproduced on the real fixture `spec/fixtures/iso/is/document-en.presentation.xml`
> (7 RefNorm paragraphs). All card items are already satisfied or are not defects:
> - `)` footnote marker and ` , ` separator: present on the two flagged entries (ISO 712 and ISO 16634:—),
>   fixed by #1781 (P1-011/P1-012) and now pinned against the real fixture in
>   `spec/isodoc/docx/renderers/bibliography_renderer_spec.rb`.
> - `RefNorm` vs `normref`: not a defect. `normref` is the legacy Word-HTML style name of the reference
>   rice.docx; `data/iso-dis/style_mapping.yml` maps `normref: RefNorm`, `RefNorm` is defined in the output
>   styles.xml, and `word_dis_styles.rb` uses the same name.
> - "ISO 712:2009" vs output "ISO 712": comes from the fixture's biblio-tag (no year), not the renderer.
> - Reference count 7 vs 8 RefNorm in the card: current output has 7 (also pinned by
>   rice_docx_structural_fixes_spec).

# 069: Fix Normative Reference Formatting

## Problem
Normative references in the output are missing footnote indicators that appear in the reference. Also, the reference shows trailing `)` before the comma for some entries (indicating withdrawn/under-preparation status), which the output doesn't have.

## Evidence

### Reference normref entries (with special markers):
```
Para 79: "ISO 712:2009) , Cereals and cereal products..."     ← trailing ")" + space
Para 83: "ISO 16634:—) , Cereals, pulses..."                  ← trailing ")" + space
```
These entries have footnote markers (footnote #1 = "Withdrawn", footnote #2 = "Under preparation")

### Output normref entries (same entries):
```
Para 51: "ISO 712:2009, Cereals and cereal products..."       ← no ")" marker
Para 55: "ISO 16634:—, Cereals, pulses..."                    ← no ")" marker
```

### Style differences:
```
Reference uses: "normref" pStyle (7 occurrences)
Output uses:    "RefNorm" pStyle (8 occurrences)
```

### Other differences:
- Reference has explicit footnote `)` markers for withdrawn/under-preparation references
- Output has footnotes but no visible `)` markers in the text
- Reference uses `normref` style; output uses `RefNorm` style

## Fix
1. Verify `RefNorm` style in output template matches `normref` from reference template
2. Ensure footnote reference markers appear in the correct position within the normref text
3. The `)` marker before the comma indicates a footnote — ensure the adapter renders this

## Priority
**MEDIUM** — Normref content is present but formatting/footnotes differ.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — normative reference rendering
- `lib/isodoc/iso/docx/style_resolver.rb` — style name mapping
- `data/iso-dis/style_mapping.yml` — normref style mapping
