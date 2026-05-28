# DOCX Architecture: Root-Cause Fixes for Uniword

Date: 2026-05-28
Principle: Build-phase correctness > Reconcile-phase repair > Serialization patches

---

## Current Architecture (3 phases)

```
BUILD       RECONCILE              SERIALIZE
Builder  →  Reconciler (repair) →  Package → XML → ZIP
  ↓           ↓                      ↓
  Creates     Fixes issues that       flatten_xml (CRLF)
  model       should never exist      namespace ordering
  objects     if Builder was correct  run consolidation
```

**Problem**: The Reconciler has 30+ methods doing things the Builder should
have done correctly in the first place. And the Serializer has `flatten_xml`
as a post-processing band-aid.

---

## Target Architecture

```
BUILD                    VALIDATE           SERIALIZE
Builder (correct)   →   Validator (check) → Package (native)
  ↓                       ↓                  ↓
  Native correctness      Reports issues     moxml indent: 0
  Run merging at build    Does NOT transform  CRLF native
  Correct element order                      Namespace order native
```

### What the Builder should do natively (eliminates Reconciler transforms):

1. **Run merging** — When adding text to a paragraph, check if the last run
   has identical formatting. If so, append to it instead of creating a new run.
   Location: `ParagraphBuilder#<<` in `builder/paragraph_builder.rb`.

2. **Attribute ordering** — Paragraph attributes should serialize w14: before w:
   by default. This is already fixed in `paragraph.rb` map_attribute order,
   but should be guaranteed by lutaml-model's attribute serialization.

3. **Sequential rIds** — When adding relationships, use sequential IDs from
   the start. Location: `package_relationships.rb` should assign `rId1, rId2, ...`
   as relationships are added, not rely on renumbering later.

4. **Empty run avoidance** — Don't create runs with no content. The Builder
   currently creates empty runs that the Reconciler strips. Location: All
   builder classes that create runs.

5. **Correct element ordering** — When programmatically creating model objects,
   set `element_order` to match the XSD sequence. Currently, programmatic
   creation uses `map_element` declaration order which may differ from XSD.

### What the Serializer should do natively (eliminates flatten_xml):

1. **Single-line XML** — moxml should support `indent: 0` to disable indentation.
   Fix in moxml gem or lutaml-model's `to_xml` options.

2. **CRLF line endings** — After the XML declaration, use `\r\n` not `\n`.
   Fix in moxml or lutaml-model's serialization output.

3. **Namespace declaration ordering** — lutaml-model should serialize
   namespace declarations in a deterministic order matching Word's convention.

---

## Implementation Tasks

### Phase 1: Builder-level fixes (highest impact, root cause)

- [ ] **B1: Run merging in ParagraphBuilder**
  File: `uniword/builder/paragraph_builder.rb`
  When `<< run`, check if previous run has identical rPr. If so, merge text.
  Eliminates: `consolidate_runs` in reconciler.

- [ ] **B2: Sequential rIds at creation time**
  File: `uniword/ooxml/relationships/package_relationships.rb`
  When adding a relationship, auto-assign the next sequential rId.
  Eliminates: `reconcile_document_rels` renumbering.

- [ ] **B3: No empty runs from builders**
  Files: All builder classes
  Don't create Run objects without content. Check before creating.
  Eliminates: `strip_empty_runs` in reconciler.

### Phase 2: Serialization-level fixes (eliminates flatten_xml)

- [ ] **S1: moxml indent: 0 support**
  File: moxml gem `Moxml::Config` or `Node#to_xml`
  Add option to disable indentation. Pass from lutaml-model's `to_xml`.
  Eliminates: `flatten_xml` regex hack in package_serialization.rb.

- [ ] **S2: CRLF after XML declaration**
  File: lutaml-model or moxml serialization
  Use `\r\n` as the line ending after `<?xml ...?>` declaration.
  Eliminates: CRLF substitution in `flatten_xml`.

- [ ] **S3: Namespace declaration ordering**
  File: lutaml-model `xml_serializer.rb`
  Sort namespace declarations: default ns first, then alphabetical by prefix.
  Or: model classes declare a `namespace_order` preference.
  Eliminates: All 16 parts having namespace ordering differences.

### Phase 3: Document statistics fix

- [ ] **D1: Complete text collection for statistics**
  File: `uniword/docx/document_statistics.rb`
  `collect_text` must walk headers, footers, footnotes, endnotes, all table
  cells, and structured document tags — not just body paragraphs.
  This matches Word's word count.

- [ ] **D2: SimSun font signature update**
  File: `uniword/config/font_metadata.yml`
  Update SimSun usb0 from `00000003` to `00000203`.

### Phase 4: Content-level fixes (lower priority)

- [ ] **C1: Adjacent table merging**
  File: New method in `reconciler/body.rb` or `adapter.rb`
  Detect adjacent tables with matching column count and merge rows.
  This matches Word's table consolidation during save.

- [ ] **C2: Redundant bold stripping**
  File: `reconciler/helpers.rb` — add to run normalization pass
  Remove `<w:b/>` when the parent style already applies bold.
  Or: in the Builder, don't emit bold rPr when the style already has it.

### Phase 5: Validation-only Reconciler (final state)

- [ ] **V1: Refactor Reconciler to Validator**
  After B1-B3 and S1-S3 are complete, the Reconciler should only:
  - Validate cross-part referential integrity (broken references = error)
  - Validate ID uniqueness (duplicate IDs = error)
  - Validate content type coverage (missing content types = error)
  It should NOT transform or repair — only report.

---

## What Word Always Changes (accept the difference)

These differences exist in EVERY DOCX file saved by Word and cannot be
eliminated:

1. **lastRenderedPageBreak** — Word's pagination engine adds these
2. **Zoom percent** — Word recalculates from its layout engine
3. **rsid entries** — Word adds new rsids for each save session
4. **Timestamps** — modified/created dates change on every save
5. **Run consolidation** — Word merges more aggressively than we can
6. **Page/line statistics** — requires a full page layout engine
