# 21 - Implementation Order

## Execution Sequence

Tasks are ordered by dependency. Each task should result in passing tests before moving on.

### Phase 1: sts-ruby Round-trip (in sts-ruby repo)

| # | Task | Depends on | Est. Complexity |
|---|------|------------|-----------------|
| 1.1 | Copy reference XML files to `spec/fixtures/reference_docs/` | — | Low |
| 1.2 | Create round-trip spec harness | 1.1 | Low |
| 1.3 | Run round-trips, catalog all failures | 1.2 | Medium |
| 1.4 | Fix model: iso-meta gaps (missing attributes/elements) | 1.3 | Medium |
| 1.5 | Fix model: sec/body ordering (mixed content, ordered) | 1.3 | High |
| 1.6 | Fix model: term-sec / tbx elements | 1.3 | High |
| 1.7 | Fix model: table elements (table-wrap, col, colgroup attrs) | 1.3 | Medium |
| 1.8 | Fix model: inline elements (sc, monospace, strike, etc.) | 1.3 | Low |
| 1.9 | Fix model: namespace handling (mml, tbx, xlink) | 1.3 | Medium |
| 1.10 | Fix model: fn-group, fn in back matter | 1.3 | Low |
| 1.11 | Re-run all round-trips until green | 1.4–1.10 | — |

### Phase 2: Transformer (in metanorma-iso repo)

| # | Task | Depends on | Est. Complexity |
|---|------|------------|-----------------|
| 2.1 | Create transformer module skeleton + base/registry/context | — | Low |
| 2.2 | IdGenerator with ISO ID scheme rules | 2.1 | Medium |
| 2.3 | FrontTransformer + IsoMetaTransformer | 2.1 | Medium |
| 2.4 | ParagraphTransformer (basic text) | 2.1 | Low |
| 2.5 | InlineTransformer (bold, italic, sub, sup, monospace, sc) | 2.4 | Medium |
| 2.6 | SectionTransformer (clause → sec, recursive) | 2.2, 2.4 | Medium |
| 2.7 | BodyTransformer (ordering: intro, scope, normrefs, terms, clauses) | 2.6 | Medium |
| 2.8 | ListTransformer (ul, ol → list) | 2.5 | Low |
| 2.9 | DefListTransformer (dl → def-list) | 2.5 | Low |
| 2.10 | TableTransformer (table → table-wrap) | 2.5, 2.2 | High |
| 2.11 | FigureTransformer (figure → fig + graphic) | 2.5, 2.2 | Medium |
| 2.12 | FormulaTransformer (formula → disp-formula) | 2.5, 2.2 | Medium |
| 2.13 | NoteTransformer + ExampleTransformer | 2.4 | Low |
| 2.14 | SourcecodeTransformer (sourcecode → preformat) | 2.4 | Low |
| 2.15 | CrossRefTransformer (xref → xref with ID remapping) | 2.2, 2.5 | Medium |
| 2.16 | BibRefTransformer (eref → std/std-ref) | 2.5 | Medium |
| 2.17 | TermsSectionTransformer + TerminologyTransformer | 2.5, 2.6, 2.2 | High |
| 2.18 | AnnexTransformer (annex → app) | 2.6 | Medium |
| 2.19 | BibliographyTransformer + ReferenceTransformer (bibitem → ref) | 2.5, 2.2 | Medium |
| 2.20 | BackTransformer (orchestrates annex, bib, index) | 2.18, 2.19 | Low |
| 2.21 | DocumentTransformer (orchestrates front, body, back) | 2.3, 2.7, 2.20 | Low |
| 2.22 | FootnoteCollector (dedup + fn-group assembly) | 2.4 | Medium |
| 2.23 | NbspProcessor (text post-processing) | 2.21 | Medium |
| 2.24 | End-to-end integration tests | 2.21 | High |
| 2.25 | Final validation against all reference documents | 2.24 | — |

## Parallelization Opportunities

These task groups can be worked on in parallel:
- **1.4–1.10**: All model fixes are independent of each other
- **2.4 + 2.8 + 2.9 + 2.13 + 2.14**: Simple block transformers can be built in parallel
- **2.3 + 2.17**: Front and terms transformers are independent
- **2.10 + 2.11 + 2.12**: Table, figure, formula transformers are independent

## Key Risk Areas

1. **Mixed content ordering** — The #1 source of round-trip and transformation bugs. Lutaml::Model's handling of ordered mixed content must be thoroughly tested.

2. **Term transformation** — The most complex single transformer. The TBX terminology model is deeply nested with many conditional rules.

3. **ID generation and cross-reference remapping** — If IDs are wrong, all cross-references break. Must be correct before testing anything else.

4. **MathML passthrough** — Formula content contains `mml:math` which should pass through unchanged. Verify namespace handling doesn't corrupt it.

5. **Footnote deduplication** — The mnconvert XSLT has ~300 lines just for footnote processing. The Ruby implementation must faithfully reproduce the same deduplication logic.

## Status (2026-11-20)

Phase 1 (tasks 1.1-1.11) DONE: 17 of 17 reference files round-trip in sts-ruby main. Phase 2: the transformer module is present (30 files in lib/metanorma/iso/sts/transformer) and covers every listed task by file or class: id_generator, front/iso_meta, paragraph, inline, section, body, list, dl, table, figure, formula, note, cross-ref and bib-ref handling (inline_transformer / reference_transformer), term, back, document, footnote_collector, nbsp_processor. Annex and bibliography are not separate classes; they sit in back_transformer and reference_transformer. Per-file spec coverage and end-to-end tests are in P3-003.

Task 2.25 (validate the transformer output against all 17 reference documents): PARTIAL, left open.

- Done, public inputs: spec/sts/sts_schema_validation_spec.rb validates the converter's output for the two public end-to-end inputs against the NISO STS extended 1.0 (MathML 3) XSD shipped in the sts gem (reference-docs/NISO-STS-extended-1-MathML3-XSD). Both outputs validate with 0 errors once `<processing-meta>` is set aside; with it, each has exactly 1 error, that element, because the XSD predates it (Guidelines ed 2.1, 4.3.2). The sts gem's own isosts-example/feature_doc.xml validates against the same XSD with 0 errors, so the XSD is a usable oracle. Spec run: 6 examples, 0 failures.
- Guidelines check (`Metanorma::Iso::Sts::Validator`, schematron-equivalent rules) on the same two outputs: 9 findings each, not clean (calendar: iso-gdg-4.4.2-1/-2/-3/-5, 6.2.2-1, 7.1-2, A.3.2-2 x3; amendment: 4.3.3-1, 4.4.2-1/-2/-3, 5.7-4 x2, 6.2.2-1, 8.1-2 x2). Some come from the invented fixtures lacking a foreword, scope or normative references; which are converter defects was not separated. Not asserted in any spec.
- NOT done, the 17 reference documents: sts-ruby's spec/fixtures/mn-samples-iso-private/reference-docs holds the STS XML (the expected output) for 17 documents. None of the 17 has a Metanorma XML input in these checkouts (the one source tree under sources/ has a PDF, not STS XML, as its reference). So the transformer cannot be run on any of the 17 and 2.25 stays open until their Metanorma sources are supplied; the same schema and Guidelines checks can then be run on each output.
