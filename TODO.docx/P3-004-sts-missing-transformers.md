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
