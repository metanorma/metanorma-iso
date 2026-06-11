# 01: Architecture & Dependency Setup

## Summary

Wire Uniword into metanorma-iso's gem dependencies and establish the dual-output architecture: DOCX via Uniword (new path) alongside MHT via html2doc (existing path).

## Motivation

metanorma-iso currently depends on isodoc → html2doc for both DOCX and MHT output. The DOCX path goes through an unnecessary HTML intermediate. By adding Uniword as a direct dependency, metanorma-iso can build DOCX from its semantic XML model without the HTML detour.

## Prerequisites

- Uniword >= 1.0.6 (with DocumentBuilder, full builder suite, MHTML support)
- html2doc (kept for MHT output via isodoc)

## Tasks

### 1. Add Uniword dependency to metanorma-iso

- Add `spec.add_dependency "uniword", "~> 1.0"` to `metanorma-iso.gemspec`
- Ensure Gemfile resolves correctly with existing isodoc/html2doc deps

### 2. Understand the current output pipeline

Current flow for DOCX/MHT:
```
metanorma-iso XML → isodoc (XSLT → HTML) → html2doc (HTML → MHT or DOCX)
```

Target flow:
```
metanorma-iso XML ─┬→ isodoc (XSLT → HTML) → html2doc → MHT (unchanged)
                    └→ isodoc + Uniword (XML → DOCX directly)
```

The MHT path remains untouched. The DOCX path gets a new route that bypasses html2doc.

### 3. Identify the integration point in isodoc

Key file: `isodoc/lib/isodoc/word_function/postprocess.rb` — method `toWord()` calls `Html2Doc.new(...).process(result)`.

The new DOCX path should be triggered by an `output_format: :docx` option, branching before the `toWord` call. When `:docx` is selected, isodoc calls a new `IsoDocToDocx` converter instead of `Html2Doc`.

### 4. Decide where the XML→Uniword adapter lives

Options:
- **In isodoc**: `IsoDoc::WordFunction::DocxAdapter` — general for all isodoc flavors
- **In metanorma-iso**: `IsoDoc::Iso::DocxConvert` — ISO-specific mappings only

Recommendation: Put the generic adapter in isodoc, with flavor-specific style/mapping overrides in metanorma-iso. This follows the existing pattern (isodoc provides base, flavors override).

## Acceptance Criteria

- [ ] Uniword listed as dependency in metanorma-iso.gemspec
- [ ] Gem installs cleanly with no version conflicts
- [ ] Existing MHT output still works unchanged
- [ ] New DOCX output path can be triggered (even if it produces a minimal document)

## Open Questions

- Should the adapter live in isodoc or metanorma-iso? (Recommendation: isodoc base, metanorma-iso overrides)
- Should we keep the html2doc DOCX path as a fallback during migration?
