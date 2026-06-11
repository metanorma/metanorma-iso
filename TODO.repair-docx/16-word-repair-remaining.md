# TODO 16: Word still reports "unreadable content" — "Lists 1" invalid

## Problem
Generated DOCX still triggers Word's "unreadable content" repair dialog.
Word says "Lists 1" is invalid.

## Status
CRITICAL. All previous TODO fixes are applied and verified (footnote types,
separator structure, mc:Ignorable, table structure, namespace scopes, durableId,
semiHidden, paraId/textId backfill, footnote ordering). Yet Word still repairs.

## Comprehensive Diff Analysis (broken vs repaired)

### Structural differences found

#### 1. Run count: 1267 (broken) vs 694 (repaired)
Word merges many runs. The adapter creates separate runs for each inline
element (e.g., cross-reference "Annex" + "A" as two runs, each word in a
multi-word element as a separate run). Word merges these into single runs.

This is likely a content accuracy issue, not the cause of "unreadable content".

#### 2. Footnote deduplication: 22 footnotes (broken) vs 10 (repaired)
Word merges duplicate footnote texts (e.g., "Withdrawn." appears as separate
footnotes 1, 13, 16, 17, 20, 21, 22 in broken output, but Word merges them
into a single footnote). The adapter creates a new footnote for each
bibitem reference even when the text is identical.

This is a content accuracy issue. Whether it triggers "unreadable content"
is unclear.

#### 3. Bookmark IDs start at 1 (broken) vs 0 (repaired)
Minor difference. Word renumbers bookmarks to start at 0.

#### 4. mc:Ignorable order difference
Broken: `w14 w15 w16se w16cid w16 w16cex w16du w16sdtdh w16sdtfl wp14`
Repaired: `w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du wp14`

The repaired version has a different order for `w16du` — it's moved to the
end (after w16sdtfl instead of before w16sdtdh).

### What was checked and found identical
- numbering.xml content (excluding cosmetic tplc/durableId)
- abstractNum definitions (15 in both)
- num instances (19 in both)
- nsid values (all unique)
- lvlOverride references (all valid)
- styles.xml (only 1 difference: semiHidden)
- endnotes.xml (only cosmetic differences)
- All XML files pass xmllint validation

### What was NOT checked
- OOXML schema validation (not just XML well-formedness)
- Relationship integrity (are all rIds valid?)
- Style references (do all pStyle/rStyle vals exist?)
- Numbering-style binding (do pStyle vals in abstractNum match real styles?)

## Fix Location
Unknown — need to identify the exact cause of "Lists 1" error.
Possible areas to investigate:
1. Run an OOXML schema validator
2. Check if any `<w:pStyle>` in numbering abstractNum levels references a
   style that doesn't exist
3. Check the footnote deduplication issue
4. Check relationship integrity
