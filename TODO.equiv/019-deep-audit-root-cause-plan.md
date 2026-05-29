# Deep Audit: Uniword Root-Cause Fix Strategy

Date: 2026-05-29
Status: Phase 1 build-phase fixes implemented. Key architectural insight: profile-dependent defaults (styles, settings, fonts) correctly belong in reconciler, not builders.
Goal: Move build-phase fixes to builders. Keep profile-dependent defaults in reconciler. Reconciler stays as assembly + profile defaults.

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

#### Task 020: Table Builder Completeness (A1-A5)

**Root cause**: `TableBuilder` and `TableCellBuilder` don't emit required OOXML properties.

**Fix in `TableBuilder#build`**:
- Always create `tblPr` with `tblW` (w:0, type: auto) and `tblLook` (val: "04A0")
- Always create `tblGrid` with column count matching actual columns
- Calculate `gridAfter` on rows where cell gridSpans sum < grid column count

**Fix in `TableCellBuilder#build`**:
- Always create `tcPr` with `tcW` (w:0, type: auto)
- Ensure `tcPr` is first in element_order

**Files**: `uniword/lib/uniword/builder/table_builder.rb`, `table_cell_builder.rb`

**Verification**: Build a table, verify tblPr/tblW/tblLook/tblGrid present without reconciler.

#### Task 021: Section Builder Completeness (A6)

**Root cause**: Paragraph/section builder doesn't create sectPr with page setup.

**Fix**: `SectionBuilder` always emits `pgSz` (12240x15840 for Letter, or from config),
`pgMar` (1-inch margins), `cols` (single column, space 720), `docGrid` (360 line-pitch).

**Files**: `uniword/lib/uniword/builder/section_builder.rb`

**Verification**: Build a document with section, verify sectPr has all required children.

#### Task 022: Paragraph Tracking at Build Time (A9-A10)

**Root cause**: Paragraph builder doesn't assign rsid/paraId/textId.

**Fix**: In `ParagraphBuilder#build`, generate:
- `rsid_r` and `rsid_r_default` from deterministic hash (SHA-256 of paragraph text)
- `paraId` as unique hex ID (8 chars, deterministic from position + content)
- `textId` as unique hex ID (8 chars, deterministic from content)

Use the `DeterministicId` module already in `builder/deterministic_id.rb`.

**Files**: `uniword/lib/uniword/builder/paragraph_builder.rb`, `deterministic_id.rb`

**Verification**: Build paragraphs, verify all have rsid/paraId/textId without reconciler backfill.

#### Task 023: Empty Run Prevention (A7, A20)

**Root cause**: Builder and inline renderer create runs with no meaningful content.

**Fix in `RunBuilder#build`**: Skip creation if run has no text, break, tab, drawing,
footnote/endnote ref, field char, instrText, delText, sym, separatorChar.

**Fix in adapter `InlineRenderer`**: Don't append empty text runs.

**Files**: `uniword/lib/uniword/builder/run_builder.rb`, adapter inline renderer

**Verification**: Generate document, grep output for `<w:r><w:rPr>.*</w:rPr></w:r>` — should be zero.

#### Task 024: Style Builder Correctness (A14)

**Root cause**: Styles builder doesn't produce required defaults.

**Fix**: When `DocumentBuilder` initializes (without template), create:
- `docDefaults` with rPr (fonts, kerning, size 22/22→11pt, language) and pPr (spacing)
- `latentStyles` from `config/latent_styles.yml`
- Required styles: Normal, DefaultParagraphFont (semiHidden), TableNormal, NoList
- Style property ordering matches CT_Style XSD sequence

**Files**: `uniword/lib/uniword/builder/style_builder.rb`, `document_builder.rb`

**Verification**: Build document without template, verify styles.xml has all four required styles.

#### Task 025: Settings Builder Correctness (A12)

**Root cause**: Settings produced by reconciler, not builder.

**Fix**: `SettingsBuilder` produces minimal correct settings:
- `zoom` w:percent="100" (not "bestFit")
- `defaultTabStop` w:val="720"
- `characterSpacingControl` w:val="compressPunctuation"
- `compat` with required compat elements
- `mathPr` with required entries
- `clrSchemeMapping` with standard mapping
- `w14:docId`, `w15:docId` from deterministic hex ID
- `mc:Ignorable` with all extension prefixes
- NO `doNotDisplayPageBoundaries` (Word strips it)

**Files**: `uniword/lib/uniword/builder/settings_builder.rb` (new or extract from reconciler)

**Verification**: Build document, compare settings.xml with Word-repaired output.

#### Task 026: Font Registry Completeness (A13)

**Root cause**: Font table populated by reconciler, not builder.

**Fix**:
- Font registry always produces complete entries (panose1, charset, family, pitch, sig)
- Unknown fonts use `notTrueType` flag
- Font table sorted alphabetically by name
- East Asian fonts have `altName`
- Profile provides default font set (Latin major/minor, EA, CS)

**Files**: `uniword/lib/uniword/docx/font_registry.rb` (new or extend existing),
`config/font_metadata.yml`

**Verification**: Build document, verify fontTable.xml has complete entries, alphabetical order.

#### Task 027: Note Builder Completeness (A19)

**Root cause**: Footnote/endnote builders don't create structural entries.

**Fix**: When first user footnote/endnote is created, automatically create:
- Separator entry (id="-1") with `<w:separator/>`
- ContinuationSeparator entry (id="0") with `<w:continuationSeparator/>`

Assign sequential IDs starting from 1.

**Files**: `uniword/lib/uniword/builder/footnote_builder.rb`

**Verification**: Build document with footnotes, verify separator entries exist.

#### Task 028: Part-Level mc:Ignorable (A11)

**Root cause**: Builders don't set mc:Ignorable on part root elements.

**Fix**: Each part builder (document, settings, styles, numbering, etc.) sets
`mc_ignorable` to `EXTENSION_PREFIXES` list on the root element.

**Files**: Each builder's `build` method, or a shared mixin.

**Verification**: Build document, verify every XML part has mc:Ignorable attribute.

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

### P0 — Unreadable content fixes (must do)
- 020: Table builder completeness
- 022: Paragraph tracking at build time
- 025: Settings builder correctness
- 028: mc:Ignorable on all parts

### P1 — Structural correctness (should do)
- 021: Section builder completeness
- 023: Empty run prevention
- 024: Style builder correctness
- 026: Font registry completeness
- 027: Note builder completeness

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

---

## How to Verify Convergence

After each task:
1. Generate DOCX from rice-rice-size sample
2. Open in Word, save (produces "repaired" version)
3. `canon diff our-output.docx repaired-output.docx --verbose`
4. Count remaining differences — should decrease monotonically
5. Run `bundle exec rspec` in uniword — no new failures
