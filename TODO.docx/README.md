# DOCX Output — Pending Work Items

Priority-based index of remaining TODOs for the ISO DOCX output pipeline.

## P0 — Critical (Word cannot open the file)

These block Word from opening the generated DOCX. Fix before anything else.

| # | Issue | Impact |
|---|-------|--------|
| P0-001 | Missing headerReference/footerReference/titlePg in sectPr | Root cause — Word rejects file |
| P0-002 | Detailed sectPr header/footer ref requirements | Same as P0-001, finer breakdown |
| P0-003 | Body sectPr differences vs reference | Structural mismatch |
| P0-004 | Body sectPr structure incomplete | Depends on P0-001 |
| P0-005 | Word reports unreadable content | Symptom of P0-001 through P0-004 |

## P1 — Major Content Issues

Content is missing or visibly broken in the output.

| # | Issue | Impact |
|---|-------|--------|
| P1-001 | 1 of 5 images missing from output | Figure content gap |
| P1-002 | Figures and images content gaps | Broader image coverage |
| P1-003 | Subfigure descriptions not rendered | Annex C figures incomplete |
| P1-004 | Copyright block appears on cover page | Should be separate page |
| P1-005 | Copyright address consolidation issues | Address block formatting |
| P1-006 | Duplicate terms section boilerplate | "For the purposes of..." duplicated |
| P1-007 | Missing page breaks in key locations | Annex/bibliography flow |
| P1-008 | Bookmarks and hyperlinks missing (~87 gap) | Cross-reference navigation |
| P1-009 | Bookmarks/hyperlinks detail | Supplementary to P1-008 |
| P1-010 | Normative references formatting | Style and structure issues |
| P1-011 | Normative reference footnote markers | Footnote markers in normref |
| P1-012 | Normref style and markers combined | Consolidated normref issue |
| P1-013 | Inline math OMML (partial — text fallback) | Inline formulas render as text |

## P2 — Formatting and Styling

Content is present but styled incorrectly or inconsistently.

| # | Issue | Impact |
|---|-------|--------|
| P2-001 | ~624 character styles (rStyle) missing | Run-level formatting gaps |
| P2-002 | Style alignment gaps | Style resolver coverage |
| P2-003 | Missing rStyles on many runs | Supplementary to P2-001 |
| P2-004 | TOC entries rendered but audit shows 0 | Wiring/data issue |
| P2-005 | TOC tab separator missing | Number/label formatting |
| P2-006 | Cover page should render from model | Cover completeness |
| P2-007 | Cover page structure issues | Cover layout |
| P2-008 | Cover page detail | Supplementary to P2-007 |
| P2-009 | Boilerplate should render from model | Copyright/warning completeness |
| P2-010 | Note/Example count mismatch | Content count vs reference |
| P2-011 | Paragraph count mismatch (~30 gap) | Structural difference |
| P2-012 | Section breaks and per-section headers | Header content varies by section |
| P2-013 | List item style wrong | List formatting |
| P2-014 | Xref text concatenation (presentation XML issue) | Unfixable in adapter alone |
| P2-015 | Eliminate style fallback chains | Architecture cleanup |
| P2-016 | Style exclusion list completeness | Style mapping accuracy |

## P3 — Feature Gaps and Spec Coverage

Missing features or test coverage, but output is usable.

| # | Issue | Impact |
|---|-------|--------|
| P3-001 | STS round-trip gaps | External verification needed |
| P3-002 | STS gap analysis | Detailed gap list |
| P3-003 | STS spec coverage (10 of ~18 specs) | Missing transformer specs |
| P3-004 | STS missing standalone transformers | cross_ref, bib_ref, terms_section, annex, bibliography |
| P3-005 | End-to-end rice output spec (tagged :slow) | Not in default CI |
| P3-006 | Amendment doctype awareness | No amendment-specific rendering |
| P3-007 | Verify Word opens (manual test) | Superseded by P0 fixes |
| P3-008 | Architecture root-cause fixes (Phase 2/3) | Assembly refactoring |

## REF — Reference Documents

Not actionable TODOs; serve as reference for ongoing work.

| # | Document | Purpose |
|---|----------|---------|
| REF-001 | ISO template style audit | Style mapping reference for 8 ISO DOCX files |
