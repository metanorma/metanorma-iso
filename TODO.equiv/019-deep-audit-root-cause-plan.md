# Deep Audit: Uniword Root-Cause Fix Strategy

Date: 2026-05-29
Status: Phase 1 build-phase fixes + serialization fixes committed. rice_fixed18.docx generates cleanly with single-line XML, CRLF, mc:Ignorable, paragraph tracking, table properties, zero empty runs. PackageDiffer with canon comparison shows structural differences are cosmetic (mc:Ignorable ordering) and content-level (adapter missing elements).
Goal: Verify Word opens without errors. Then address content-level gaps.

---

## Target Architecture

```
BUILD (correct) → ASSEMBLE (cross-part IDs only) → SERIALIZE (native)
```

**BUILD**: Every builder produces a structurally complete, OOXML-valid part.
No empty runs, no missing properties, no incomplete structures.

**ASSEMBLE**: Cross-part concerns only — sequential rId allocation,
content type registration, relationship wiring, header/footer reference mapping.

**SERIALIZE**: Native XML serialization — single-line, CRLF, sorted namespaces.
No regex post-processing.

---

## Current Reconciler Responsibilities (30+ transformations)

The reconciler currently does TWO fundamentally different things:

### A. Single-part structural completeness (SHOULD BE IN BUILD)
These can and should be fixed at the builder level:

| # | Transformation | Module | Why it's needed |
|---|---|---|---|
| A1 | Table tblPr/tblW/tblLook backfill | Tables | Table builder omits required properties |
| A2 | Table grid column count fix | Tables | Grid doesn't match actual column count |
| A3 | Table cell tcPr/tcW backfill | Tables | Cell builder omits required properties |
| A4 | Table cell element_order fix (tcPr before p) | Tables | Parsing preserves wrong order |
| A5 | Table row gridAfter calculation | Tables | Missing gridAfter for short rows |
| A6 | Section properties default (pgSz/pgMar/cols) | Body | Builder omits page setup |
| A7 | Empty run stripping | Helpers | Builder/round-trip produces empty runs |
| A8 | Run consolidation (merge identical rPr) | Helpers | Builder produces unmerged runs |
| A9 | rsid_r/rsid_r_default backfill | Helpers | Builder omits tracking attributes |
| A10 | paraId/textId backfill | Helpers | Builder omits tracking attributes |
| A11 | mc:Ignorable on all parts | Parts | Builder omits extension namespace declarations |
| A12 | Settings population | Parts | Builder produces empty/minimal settings |
| A13 | Font table population | Parts | Builder produces empty font table |
| A14 | docDefaults + required styles | Parts | Builder omits style defaults |
| A15 | Numbering durableId | Parts | Builder omits w16cid durable IDs |
| A16 | Web settings creation | Parts | Builder omits webSettings.xml |
| A17 | App properties + statistics | Parts | Builder omits document metadata |
| A18 | Core properties + timestamps | Parts | Builder omits document timestamps |
| A19 | Note separator/continuation creation | Notes | Builder omits structural note entries |
| A20 | Empty run stripping from notes | Notes | Same as A7 but in note context |

### B. Cross-part referential integrity (LEGITIMATE ASSEMBLY)
These require knowledge of the full package and belong in assembly:

| # | Transformation | Module | Why it's needed |
|---|---|---|---|
| B1 | Sequential rId renumbering | PackageStructure | Adapter strips relationships, leaving gaps |
| B2 | Duplicate rId detection | ReferentialIntegrity | Multiple sources can produce same rId |
| B3 | Content types rebuild | PackageStructure | Must reflect actual parts present |
| B4 | Package relationships rebuild | PackageStructure | Must include all required relationships |
| B5 | Document relationships rebuild | PackageStructure | Must include all part relationships |
| B6 | Header/footer reference wiring | Body | Builder-path H/F not wired into rels |
| B7 | sectPr header/footer rId remapping | PackageStructure | sectPr refs must match rels rIds |
| B8 | Dangling note reference removal | ReferentialIntegrity | Body refs note IDs that don't exist |
| B9 | Dangling style reference removal | ReferentialIntegrity | Style refs IDs not in styles.xml |
| B10 | Dangling numbering reference removal | ReferentialIntegrity | numPr refs numId not in numbering.xml |
| B11 | Dangling hyperlink removal | ReferentialIntegrity | Hyperlink rId not in document rels |
| B12 | Dangling header/footer ref removal | ReferentialIntegrity | sectPr refs header/footer not in rels |
| B13 | paraId uniqueness enforcement | ReferentialIntegrity | Multiple paragraphs share same paraId |
| B14 | Note ordering by body reference | Notes | Notes not in body-reference order |
| B15 | Note ID renumbering | Notes | Note IDs non-sequential or duplicated |
| B16 | Style inheritance cleanup | ReferentialIntegrity | basedOn/link ref missing styles |
| B17 | stylesWithEffects removal | PackageStructure | Legacy Word 2010 transitional artifact |

---

## Root-Cause Fix Plan

### Phase 1: Build-Phase Correctness (eliminates A1-A20)

Each builder must produce OOXML-valid output without requiring reconciler fixes.

#### ~~Task 020: Table Builder Completeness (A1-A5)~~ ✅ DONE

Committed in uniword `9f9630c`. TableBuilder always creates tblPr/tblW/tblLook.
TableCellBuilder always creates tcPr/tcW. Table grid auto-created from rows.

#### ~~Task 021: Section Builder Completeness (A6)~~ ✅ DONE

Committed in uniword `9f9630c`. SectionBuilder emits pgSz/pgMar/cols/docGrid defaults.

#### ~~Task 022: Paragraph Tracking at Build Time (A9-A10)~~ ✅ DONE

Committed in uniword `a4f57e5`. ParagraphBuilder assigns rsid_r/rsid_r_default/paraId/textId
using SHA-256 hash + mutex-protected sequence counter.

#### ~~Task 023: Empty Run Prevention (A7, A20)~~ ✅ DONE

Committed in uniword `a4f57e5`. ParagraphBuilder.append_run skips empty runs.
Verified: 0 empty runs in rice_fixed18.docx output.

#### Task 024: Style Builder Correctness (A14) — DEFERRED

Profile-dependent defaults (docDefaults, latentStyles, required styles) correctly
belong in the reconciler, not builders. The reconciler has profile context that
builders lack. Only relevant when building without a template.

#### Task 025: Settings Builder Correctness (A12) — DEFERRED

Same rationale as Task 024. Settings depend on profile (ISO DIS vs simple template).
Reconciler correctly handles this.

#### Task 026: Font Registry Completeness (A13) — DEFERRED

Font table depends on template fonts. Reconciler correctly populates from profile.

#### Task 027: Note Builder Completeness (A19) — TODO

Still needed: automatic separator/continuationSeparator entries when first user note is created.

#### ~~Task 028: Part-Level mc:Ignorable (A11)~~ ✅ DONE

All XML parts have mc:Ignorable with full extension prefix lists. Verified in rice_fixed18.docx.

### Serialization Fixes (cross-cutting)

#### ~~Single-line XML serialization~~ ✅ DONE

Committed in moxml `3905b34`. indent=0 produces single-line output.

#### ~~CRLF line endings~~ ✅ DONE

Committed in moxml `3905b34` (config), lutaml-model `33393b3` (passthrough).
All XML parts use CRLF.

#### ~~Namespace declaration sorting~~ ✅ DONE

Committed in lutaml-model `33393b3`. Alphabetical by prefix.

#### ~~Double line break between declaration and root~~ ✅ DONE

Committed in lutaml-model `91351387`. Removed hardcoded `\n` from generate_declaration.

#### ~~FrozenError on element_order.clear~~ ✅ DONE

Committed in metanorma-iso `b9de1a69`. Use `= []` instead of `.clear` for frozen arrays.

### Phase 2: Assembly-Phase Refactoring (simplifies B1-B17)

Replace the reconciler with a lean `Assembler` that only handles cross-part concerns.

#### Task 029: Sequential rId Allocator (B1-B2, B5, B7)

**Root cause**: Adapter strips template relationships, leaving rId gaps.
Reconciler renumbers as a fix.

**Fix**: Create `IdAllocator` class:
- Maintains a counter starting from 1
- `allocate_id` returns "rId1", "rId2", etc.
- Package uses allocator during assembly to assign all rIds
- Removes need for reconciler renumbering

This also means the adapter's `clear_stale_template_content` should NOT strip
relationships — instead, the assembly phase rebuilds relationships from scratch.

**Files**: `uniword/lib/uniword/docx/id_allocator.rb` (new),
`adapter.rb` (remove relationship stripping)

**Verification**: Generate DOCX, verify rIds are sequential in document.xml.rels.

#### Task 030: Numbering ID Management (B15 analog)

**Root cause**: Numbering IDs may be non-sequential or duplicated.

**Fix**: Numbering builder uses sequential abstractNum IDs (0, 1, 2...)
and sequential num IDs (1, 2, 3...). Assign at build time, not reconciler.

**Files**: `uniword/lib/uniword/builder/numbering_builder.rb`

**Verification**: Build document with lists, verify numbering.xml IDs are sequential.

#### Task 031: Content Type and Relationship Assembly (B3-B4, B6)

**Root cause**: Content types and relationships rebuilt by reconciler from scratch.

**Fix**: Assembly phase:
1. Walk all parts present in package
2. Register content type for each part
3. Create relationship for each part with sequential rId
4. Wire header/footer references into sectPr
5. Update sectPr header/footer rIds to match allocated rIds

**Files**: `uniword/lib/uniword/docx/assembler.rb` (new, replaces reconciler modules)

**Verification**: Generate DOCX, verify content types and rels match actual parts.

#### Task 032: Referential Integrity Validator (B8-B13, B16-B17)

**Root cause**: Dangling references from partial document assembly.

**Fix**: Convert referential integrity checks from mutations to validations.
If any check fails, log a warning (not an error). Do NOT silently remove references.

In a fully correct build pipeline, dangling references should not occur.
If they do, it's a builder bug that should be fixed, not papered over.

**Files**: `uniword/lib/uniword/docx/validator.rb` (new)

**Verification**: Build document, verify validator passes without warnings.

### Phase 3: Semantic Correctness

#### Task 033: Bold Redundancy Removal

**Root cause**: Adapter adds bold to run rPr even when paragraph style already provides bold.

**Fix**: `InlineRenderer` (in metanorma-iso adapter) checks the target paragraph style's
rPr before adding bold to run properties. If style already has `<w:b/>`, skip it.

**Files**: `metanorma-iso/lib/isodoc/iso/docx/inline.rb`

**Verification**: Generate document with bold headings, verify no redundant `<w:b/>` in runs.

#### Task 034: Adjacent Table Merging

**Root cause**: Adapter renders each table separately, producing adjacent `<w:tbl>` elements
that Word merges into one.

**Fix**: In adapter body rendering, when two consecutive tables have identical column
structure, merge rows from the second into the first.

**Files**: `metanorma-iso/lib/isodoc/iso/docx/adapter.rb`

**Verification**: Generate document with adjacent same-structure tables, verify single `<w:tbl>`.

---

## What Word Always Changes (ACCEPT)

These differences are inherent. No amount of pipeline fixes will eliminate them.

| # | Difference | Why Word changes it | Can we minimize? |
|---|---|---|---|
| W1 | rsid values | Word rewrites for change tracking | No — use deterministic rsids, accept difference |
| W2 | `modified` timestamp | Word overwrites on save | Set to current time, accept difference |
| W3 | Theme expansion | Word writes full DrawingML theme | No — use minimal theme, accept expansion |
| W4 | ZIP timestamps | Word resets to DOS epoch (1980-01-01) | No — ZIP library controls timestamps |
| W5 | ZIP internal attributes | Word sets binary flag | No — ZIP library controls attributes |
| W6 | lastRenderedPageBreak | Requires layout/pagination engine | No — would need full Word layout engine |
| W7 | Page count in app.xml | Requires layout engine | Use estimation formula, accept difference |
| W8 | Zoom percent | Word recalculates from window size | Set to 100%, accept Word's recalculation |
| W9 | docDefaults empty element stripping | Word removes empty kern/sz/szCs | Produce complete defaults, accept Word's cleanup |

---

## Execution Priority

### P0 — Unreadable content fixes (must do) — ALL DONE ✅
- ~~020: Table builder completeness~~ ✅
- ~~022: Paragraph tracking at build time~~ ✅
- ~~025: Settings builder correctness~~ — Deferred (profile-dependent, reconciler handles)
- ~~028: mc:Ignorable on all parts~~ ✅
- ~~Single-line XML~~ ✅
- ~~CRLF line endings~~ ✅
- ~~Namespace sorting~~ ✅

### P1 — Structural correctness (should do) — PARTIALLY DONE
- ~~021: Section builder completeness~~ ✅
- ~~023: Empty run prevention~~ ✅
- 024: Style builder correctness — Deferred (profile-dependent)
- 026: Font registry completeness — Deferred (profile-dependent)
- 027: Note builder completeness — TODO

### P2 — Pipeline simplification (nice to have)
- 029: Sequential rId allocator
- 030: Numbering ID management
- 031: Content type and relationship assembly
- 032: Referential integrity validator

### P3 — Semantic quality
- 033: Bold redundancy removal
- 034: Adjacent table merging

---

## Completed Fixes (reference)

| Fix | What | Where | Date |
|---|---|---|---|
| R1 | Single-line XML (indent=0) | moxml Builder::Base | 2026-05-28 |
| R2 | CRLF line ending | moxml Config + XmlSerializer | 2026-05-28 |
| R3 | Namespace declaration sorting | lutaml-model XmlSerializer | 2026-05-28 |
| R4 | Run merging in ParagraphBuilder | uniword ParagraphBuilder | 2026-05-28 |
| R6 | Document statistics refactor | uniword DocumentStatistics | 2026-05-28 |
| R7 | East Asian font signatures | uniword font_metadata.yml | 2026-05-28 |
| R8 | Table builder completeness | uniword TableBuilder/TableCellBuilder | 2026-05-29 |
| R9 | Paragraph tracking (rsid/paraId/textId) | uniword ParagraphBuilder | 2026-05-29 |
| R10 | Empty run prevention | uniword ParagraphBuilder.append_run | 2026-05-29 |
| R11 | Section builder defaults | uniword SectionBuilder | 2026-05-29 |
| R12 | Double line break fix (declaration) | lutaml-model declaration_handler | 2026-05-29 |
| R13 | FrozenError fix (element_order) | metanorma-iso adapter | 2026-05-29 |
| R14 | Local gem path overrides | metanorma-iso Gemfile | 2026-05-29 |

---

## How to Verify Convergence

After each task:
1. Generate DOCX from rice-rice-size sample
2. Open in Word, save (produces "repaired" version)
3. Compare using Uniword::Diff::PackageDiffer with canon:
   ```ruby
   differ = Uniword::Diff::PackageDiffer.new("ours.docx", "repaired.docx", canon: true)
   result = differ.diff
   puts result.summary
   ```
4. Count remaining differences — should decrease monotonically
5. Run `bundle exec rspec` in uniword — no new failures

---

## rice_fixed18 Comparison Results (2026-05-29)

Compared rice_fixed18.docx (ours) vs rice_fixed16-repaired.docx (Word-repaired).

### Structural Quality (all passing)

- Single-line XML (no indentation between tags)
- CRLF line endings
- mc:Ignorable on all parts
- Paragraph tracking (rsidR, rsidRDefault, paraId, textId)
- Zero empty runs
- Tables have tblW, tblLook, tblGrid

### Remaining Differences by Category

| Category | Count | Impact | Action |
|---|---|---|---|
| mc:Ignorable prefix ordering | All parts | Cosmetic (attribute value order) | Accept |
| Content gaps (document.xml) | 37KB smaller | Missing footnote refs, terms, biblio | Adapter issue, not uniword |
| Styles expansion | +75KB | Word writes full styles | Accept (W3) |
| Theme expansion | +1.4KB | Word writes full DrawingML | Accept (W3) |
| webSettings expansion | +27KB | Word adds div/frame structure | Accept |
| Numbering simplification | -12KB | Word removes unused numbering | Accept |
| ZIP metadata | Multiple | Timestamps, internal attrs | Accept (W4, W5) |
| Settings differences | 13 elements | Minor (bordersDoNotSurround, etc.) | Low priority |

### What to Verify Next

Open rice_fixed18.docx in Word. If no "unreadable content" error appears,
the structural OOXML fixes are complete. Remaining work is content-level
(adapter rendering improvements) and cosmetic convergence.
