# DOCX Remaining Differences: rice_fixed18 vs Word-Repaired

Date: 2026-05-28
Status: rice_fixed18.docx **OPENS IN WORD WITHOUT ERROR**
Remaining differences Word fixes during save — minimize re-repair churn.

---

## Root-Cause Analysis: Uniword Workflow

The Uniword DOCX pipeline has three phases:

```
1. BUILD (Builder → Package model objects)
2. RECONCILE (Reconciler enforces invariants)
3. SERIALIZE (Package → XML → ZIP)
```

**The key insight**: Many remaining differences exist because the BUILD phase
produces suboptimal output that the RECONCILE phase then patches. The correct
approach is to make the BUILD phase produce correct output natively, so the
RECONCILE phase only needs to validate (not transform).

---

## Difference Categories

### N1. Namespace declaration ordering (ALL 16 XML parts)

**What**: Ours puts `xmlns:w` first; Word puts non-main namespaces first.
Example: `xmlns:wpc,xmlns:cx,...,xmlns:w` vs `xmlns:w,xmlns:wpc,...`

**Root cause**: lutaml-model's `XmlElement#hoisted_declarations` hash uses
insertion order from the Ruby Hash, which follows the order namespaces are
declared in the model class's `namespace_scope` declarations. The main
namespace (`xmlns:w`) is declared first in each model class.

**Fix location**: `lutaml-model` `xml_serializer.rb:215-226`
- Sort namespace declarations: default namespace first, then main element
  namespace, then extension namespaces alphabetically by prefix.
- Alternative: add a `namespace_order` class method to model classes that
  specifies the desired serialization order.

**Impact**: Cosmetic — Word accepts any namespace order. But eliminating this
difference makes `canon diff` output cleaner.

### N2. document.xml — Run consolidation gap (762 vs 792 runs)

**What**: Our `consolidate_runs` merges some adjacent runs but not all.
Word reduces to 792 runs; we're at 762 (actually better than before but
different merging strategy).

**Root cause**: Our consolidator compares full rPr XML, which is too strict.
Word merges runs when their *effective* formatting is identical, even if the
rPr serialization differs slightly (e.g., `<w:b/>` vs `<w:b w:val="true"/>`).

**Fix location**: `uniword/reconciler/helpers.rb` — `run_properties_match?`
- Compare effective formatting semantics, not XML serialization.
- Need a `RunProperties#semantic_eq?(other)` method that normalizes defaults.

**Impact**: Cosmetic — same text content, fewer runs = smaller file.

### N3. document.xml — Bold removal (5 vs 0 `<w:b/>` elements)

**What**: Ours has 5 `<w:b/>` elements; Word strips them.
`<w:b/>` is equivalent to `<w:b w:val="true"/>` — Word normalizes to implicit.

**Root cause**: Source document (template) contains `<w:b/>`. We preserve it
verbatim. Word strips the explicit element when it's the default.

**Fix location**: `uniword/reconciler/helpers.rb` — add to `consolidate_runs`
or a new `normalize_run_properties` pass that strips redundant formatting
elements (bold when parent style is already bold, etc.).

**Impact**: Cosmetic — both forms are valid OOXML.

### N4. document.xml — Table merging (2 vs 1 tables)

**What**: Ours outputs 2 adjacent `<w:tbl>` elements (19+10 rows).
Word merges them into 1 table (29 rows).

**Root cause**: The adapter creates separate tables from the source XML.
Adjacent tables with identical structure should be merged.

**Fix location**: `uniword/reconciler/body.rb` — add `merge_adjacent_tables`
pass that detects adjacent tables with matching column structure and merges
their rows. Or fix in `metanorma-iso/adapter.rb` at the BUILD phase.

**Impact**: Functional — merged tables behave differently for formatting.
However, this is a source document issue, not a serialization issue.

### N5. document.xml — lastRenderedPageBreak (0 vs 16)

**What**: Word adds `<w:lastRenderedPageBreak/>` during save as pagination hints.
These are never present in our output.

**Root cause**: This requires a page layout engine. We can't add these.

**Fix location**: N/A — cannot fix without a pagination engine.
Word always adds these during save; they'll always differ.

**Impact**: None — these are caching hints, not structural elements.

### N6. document.xml — Paragraph count (418 vs 419)

**What**: 1 extra paragraph in our output or Word's output.

**Root cause**: Likely a different handling of empty paragraphs or the table
merge affecting paragraph count within cells.

**Fix location**: Investigate after N4 (table merging) is resolved.

### N7. settings.xml — Zoom percent (100 vs 104)

**What**: We set `w:percent="100"`, Word adjusts to 104 during save.

**Root cause**: Word recalculates zoom based on its page layout engine.
`100` is valid; Word changes it during every save.

**Fix location**: N/A — Word always recalculates zoom. No fix needed.

**Impact**: None — zoom is a UI hint.

### N8. settings.xml — rsid count (74 vs 78)

**What**: Word adds 4 rsid entries during save for its own tracking.

**Root cause**: Word tracks all edit sessions with rsids. Each save adds new
rsids for the changes Word detects.

**Fix location**: N/A — Word always adds rsids. Our count is correct at
generation time.

**Impact**: None — revision tracking metadata.

### N9. fontTable.xml — SimSun sig usb0 (00000003 vs 00000202)

**What**: Different font signature metadata for SimSun.

**Root cause**: `font_metadata.yml` has hardcoded font signatures. These may
not match the actual font installed on the machine. Word updates them based
on the installed font's actual OS/2 table.

**Fix location**: `uniword/config/font_metadata.yml` — update SimSun usb0
from `00000003` to `00000203` to match Word's value.

**Impact**: Very low — font signatures are used for font substitution
fallback. Only matters if SimSun is not installed.

### N10. app.xml — Statistics values differ

| Metric | Ours | Word |
|---|---|---|
| Pages | 4 | 18 |
| Words | 489 | 3286 |
| Characters | 2738 | 18731 |
| Paragraphs | 46 | 43 |
| Lines | 94 | 156 |
| CharactersWithSpaces | 3181 | 21974 |

**Root cause**:
1. **Pages**: Our estimate (4 pages) uses a simple heuristic (45 paras/page).
   Word counts 18 pages using its layout engine. We can't match this.
2. **Words**: Our word counter (489) only counts body paragraphs. Word counts
   ALL text including footnotes, endnotes, headers, footers, and table cells.
3. **Characters**: Same scope issue — we only count body text.
4. **Paragraphs**: Our count (46) differs from Word's (43). Word may exclude
   certain empty paragraphs or paragraphs in special contexts.
5. **Lines**: We use paragraph count; Word uses actual rendered line count.

**Fix location**: `uniword/docx/document_statistics.rb`
- `collect_text` needs to walk ALL text sources: headers, footers, footnotes,
  endnotes, table cells, and structured document tags.
- Pages/lines cannot be fixed without a layout engine — accept the difference.
- Update heuristic to produce closer values for words/characters.

**Impact**: Low — statistics are metadata only, not structural. Word
recalculates on save anyway.

### N11. core.xml — Timestamps

**What**: Different creation/modification timestamps.

**Root cause**: We set `modified` to `Time.now.utc` during reconciliation.
Word overwrites it during save.

**Fix location**: N/A — timestamps will always differ. Our behavior is correct.

**Impact**: None.

### N12. numbering.xml — Size difference (19933 vs 21433)

**What**: 1500-byte difference in numbering XML.

**Root cause**: Likely namespace ordering (N1) plus potential element ordering
within abstractNum definitions. Need to diff content specifically.

**Fix location**: Investigate after N1 is fixed to isolate content vs. format.

### N13. styles.xml — Size difference (129454 vs 129338, +116)

**What**: 116 bytes larger.

**Root cause**: Likely namespace ordering (N1) only, since style count is
identical (312/312) and all individual styles match semantically.

**Fix location**: Will be fixed by N1.

### N14. theme/theme1.xml — Size difference (8473 vs 8333, +140)

**What**: 140 bytes larger.

**Root cause**: Likely namespace ordering (N1). Theme content is semantically
identical per previous audit.

**Fix location**: Will be fixed by N1.

---

## Action Items (Priority Order)

### High Priority (eliminates largest differences)

- [ ] **N1**: Fix namespace declaration ordering in lutaml-model serialization
- [ ] **N2+N3**: Improve run consolidation to match Word's merging strategy
- [ ] **N10**: Expand document statistics to count all text sources

### Medium Priority (eliminates remaining structural differences)

- [ ] **N4**: Merge adjacent tables with matching structure
- [ ] **N9**: Update SimSun font signature in font_metadata.yml
- [ ] **N6**: Investigate paragraph count difference

### Low Priority (Word always recalculates)

- [ ] **N5**: lastRenderedPageBreak — cannot fix (need layout engine)
- [ ] **N7**: Zoom percent — Word recalculates
- [ ] **N8**: rsid count — Word adds during save
- [ ] **N11**: Timestamps — always differ
- [ ] **N12**: numbering.xml — investigate after N1

---

## Architecture Improvement: Build-Phase Correctness

The current workflow relies too heavily on the RECONCILE phase to fix issues
that should be correct from the start. Future work should:

1. **Builder classes should produce correct output natively**:
   - RunBuilders should merge text with the previous run if formatting matches
   - ParagraphBuilders should produce correct attribute ordering from the start
   - TableBuilders should detect and merge adjacent tables

2. **Reconciler should validate, not transform**:
   - Currently transforms: renumbers rIds, merges runs, fixes element order
   - Should only: validate consistency and report warnings

3. **Serialization should be format-correct by default**:
   - Single-line XML with CRLF should be the default, not a post-processing step
   - Namespace ordering should follow Word's convention by default
   - `flatten_xml` is a workaround; moxml should support `indent: 0` natively
