# 004 — Document template era in YAML header

## Problem

`data/iso-dis/styles.yml` declares `description: ISO DIS/FDIS template
styles extracted from ISO 6709 ed.3`, but `style_mapping.yml` and the
spec fixture reference DIS 15926-100. Three files, two eras, no
machine-readable provenance.

## Approach

Standardize a YAML header convention for all `data/iso-dis/*.yml`:

```yaml
---
template_era: late_typefi        # one of: pre_typefi | early_typefi | late_typefi
reference_doc: spec/fixtures/20250530-ISO_DIS_15926-100.docx
reference_doc_sha256: <64-hex>
extracted_at: 2026-06-18T00:00:00Z
extractor_version: 1.0.0         # TemplateExtractor VERSION constant
notes: |
  Era C (late Typefi) canonical reference. See
  BUGS.gen/021-iso-template-style-audit.md for era definitions.
---
```

Add a spec asserting the four canonical data files have this header
and that SHA256 of the referenced fixture matches the recorded value.

## Files affected

- Modify: `data/iso-dis/styles.yml` (header added by TemplateExtractor)
- Modify: `data/iso-dis/numbering.yml` (same)
- Modify: `data/iso-dis/doc_defaults.yml` (same)
- Modify: `data/iso-dis/style_mapping.yml` (manually authored header)
- Create: `lib/isodoc/iso/docx/template_provenance.rb` — small value
  object representing the header, autoloaded in `lib/isodoc/iso/docx.rb`.
- Create: `spec/isodoc/docx/template_provenance_spec.rb`

## Public API

```ruby
module IsoDoc::Iso::Docx
  class TemplateProvenance
    EROCHI = %i[pre_typefi early_typefi late_typefi].freeze

    attr_reader :era, :reference_doc, :reference_doc_sha256,
                :extracted_at, :extractor_version

    def self.from_yaml(path); end
    def self.record_for(reference_docx_path); end

    def matches_reference?(actual_sha256); end
  end
end
```

## Acceptance criteria

- All 4 data YAMLs have the header.
- `TemplateProvenance.from_yaml(path)` parses successfully for each.
- `TemplateProvenance.record_for(fixture_path)` produces a header whose
  SHA256 matches `Digest::SHA256.file(fixture_path).hexdigest`.
- Spec verifies SHA in CI; fails with a clear message if fixture is
  replaced without re-extraction.

## Required specs

- `template_provenance_spec.rb`:
  - All 4 data files parse.
  - SHA matches.
  - Era is `:late_typefi`.
