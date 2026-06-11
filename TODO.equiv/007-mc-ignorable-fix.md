# TODO 007: Fix stale mc:Ignorable causing Word "unreadable content"

## Status: DONE

## Problem
Template DOCX was created with an older Word version that used:
```
mc:Ignorable="w14 w15 w16se w16cid w16 w16cex w16sdtdh"
```
Current OOXML spec also requires `w16du` and `w16sdtfl`. The reconciler
used `||=` for mc_ignorable assignments, so the template's stale value
was never updated. Word's strict validation saw declared-but-not-ignored
extension namespaces and triggered "unreadable content" repair.

10 of 10 XML parts had incomplete mc:Ignorable. The repaired version
showed Word adding `w16sdtfl` and `w16du` to every part.

## Root Cause
1. Reconciler used `||=` (set-if-nil) for `mc_ignorable`, preserving
   stale template values instead of overwriting with the canonical set.
2. `reconcile_numbering` did not set mc_ignorable at all.
3. Numbering.xml needed FULL_IGNORABLE (with wp14), not EXTENSION_PREFIXES.

## Fix
Changed all `mc_ignorable ||=` to `mc_ignorable =` in:
- `uniword/lib/uniword/docx/reconciler/parts.rb` — settings, font_table (x2),
  styles, web_settings, document_body, and added numbering handling
- `uniword/lib/uniword/docx/reconciler/notes.rb` — footnotes, endnotes
- `uniword/lib/uniword/docx/reconciler/body.rb` — headers, footers

Numbering uses FULL_IGNORABLE (includes wp14) matching Word's repaired output.

## Files Changed
- `uniword/lib/uniword/docx/reconciler/parts.rb` — 8 changes (6 `||=` → `=`, 1 new mc_ignorable for numbering, 1 EXTENSION_PREFIXES → FULL_IGNORABLE for numbering)
- `uniword/lib/uniword/docx/reconciler/notes.rb` — 1 change
- `uniword/lib/uniword/docx/reconciler/body.rb` — 1 change

## Verification
- 66 reconciler specs pass with 0 failures
- rice_fixed10.docx mc:Ignorable matches repaired version for all 10 XML parts
- Sorted prefix comparison: identical sets for document, styles, numbering,
  settings, fontTable, webSettings, footnotes, endnotes, header1, footer1
