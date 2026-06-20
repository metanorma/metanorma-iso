# 001 — Re-extract YAML from DIS 15926-100 reference

## Problem

Our `data/iso-dis/styles.yml`, `numbering.yml`, and `doc_defaults.yml`
were extracted from `ISO 6709 ed.3` (Era B / early Typefi). The spec
fixture is `20250530-ISO_DIS_15926-100.docx` (Era C / late Typefi).
Result: `style_mapping.yml` references Era C styles (`Warningtext`,
`Warningtitle`, `InlineCode`, `zzCoverlarge`, `zzCopyrightaddress`,
`TermsAdmitted`) that don't exist in our own data files.

## Approach

Author a one-shot extractor under `lib/isodoc/iso/docx/template_extractor.rb`
(wrapped in an internal CLI: `bundle exec ruby -Ilib -e "..."` or
`rake iso_docx:extract_template`). The extractor:

1. Unzips the reference DOCX.
2. Parses `word/styles.xml`, `word/numbering.xml`,
   `word/settings.xml`, `word/theme/theme1.xml`.
3. Emits four YAML files preserving structure that Uniword can reload:
   - `data/iso-dis/styles.yml` (paragraph, character, table styles)
   - `data/iso-dis/numbering.yml` (abstractNum + num bindings)
   - `data/iso-dis/doc_defaults.yml` (rPrDefault + pPrDefault)
   - `data/iso-dis/theme.yml` (theme color/font references)
4. Records source provenance in each file's header.

### Why a class, not a script

A `TemplateExtractor` class lets us re-run extraction when ISO publishes
a new template revision, without re-engineering. It also makes the
"YAML comes from DOCX" invariant auditable in code. The class is autoloaded
from `lib/isodoc/iso/docx.rb` (registered in the immediate parent
namespace file), and never required via `require_relative`.

## Files affected

- Create: `lib/isodoc/iso/docx/template_extractor.rb`
- Create: `lib/isodoc/iso/docx.rb` entry: `autoload :TemplateExtractor, ...`
- Create: `spec/isodoc/docx/template_extractor_spec.rb`
- Replace: `data/iso-dis/styles.yml`
- Replace: `data/iso-dis/numbering.yml`
- Replace: `data/iso-dis/doc_defaults.yml`
- Create: `data/iso-dis/theme.yml`
- Add: a Thor or Rake task `lib/tasks/iso_docx.rake` exposing the extractor
  for reproducible regeneration.

## Public API

```ruby
module IsoDoc::Iso::Docx
  class TemplateExtractor
    def initialize(reference_docx_path, output_dir)
      # ...
    end

    def extract
      # writes styles.yml, numbering.yml, doc_defaults.yml, theme.yml
    end

    attr_reader :reference_path, :output_dir, :stats
  end
end
```

## Acceptance criteria

- `data/iso-dis/styles.yml` contains all 250 paragraph/character/table
  styles from DIS 15926, including `Warningtext`, `Warningtitle`,
  `InlineCode`, `InlineCodeBold`, `zzCoverlarge`, `zzCopyrightaddress`,
  `TermsAdmitted`, `Box-begin`, `Box-end`, `Box-title`, `KeyText`,
  `KeyTitle`, `Figuredescription`, `Figurenote`, `Figuresubtitle`,
  `Disp-quotep`, `Dimension50/75/100`, `Notice`.
- `data/iso-dis/numbering.yml` has exactly **7 abstractNum** definitions
  matching DIS 15926 (decimal `%1` Heading1 multilevel; `Annex %1` ANNEX
  multilevel; bullet `—` ListContinue1; etc.).
- Each YAML file has a header documenting:
  ```yaml
  template_era: late_typefi
  reference_doc: spec/fixtures/20250530-ISO_DIS_15926-100.docx
  reference_doc_sha256: <hex digest>
  extracted_at: <ISO8601>
  ```

## Required specs (real model instances, no doubles)

- `template_extractor_spec.rb`:
  - Extracts from the DIS 15926 fixture to a tmpdir.
  - Asserts `styles.yml` parses and includes `Warningtext`, `Box-begin`.
  - Asserts `numbering.yml` has 7 abstractNums.
  - Asserts each YAML has the `template_era` header.
  - Asserts SHA256 of source recorded.
