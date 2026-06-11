# TODO 11: Numbering.xml missing full namespace declarations (LOW PRIORITY)

## Problem
The `<w:numbering>` root element declares only 12 namespaces while repaired
has 33. Word adds the full set during repair.

Broken: `mc, w, w14-w16, w16cex, w16cid, w16du, w16sdtdh, w16sdtfl, w16se, wp14`
Repaired: above PLUS `aink, am3d, cx, cx1-cx8, m, o, oel, r, v, w10, wne, wp, wpc, wpg, wpi, wps`

## Status
DONE. Expanded Numbering model's namespace_scope to match the full 33-entry set
used by Header, Footer, Footnotes, and Endnotes models.

## Fix Location
- **Uniword** `numbering.rb`: replaced limited namespace_scope with full 33-entry set
