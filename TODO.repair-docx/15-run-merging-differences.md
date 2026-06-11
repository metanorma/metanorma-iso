# TODO 15: Run merging differences in document.xml (NOT NEEDED)

## Problem
Word merges adjacent runs with identical formatting into single runs. Our
output has more runs (1365) than repaired (694). For example:
- Broken: `<w:t>Annex</w:t>` + `<w:t>A</w:t>` as separate runs
- Repaired: `<w:t>AnnexA</w:t>` as one run

## Status
This is cosmetic run consolidation by Word. It does NOT trigger "unreadable
content" — Word does this optimization during any save/open cycle regardless
of the input. The runs are semantically identical.

No fix needed. This is standard Word behavior.
