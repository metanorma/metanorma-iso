# 02: ISO DOCX Template

## Summary

Ship a canonical ISO DOCX template containing all required styles, numbering definitions, font table, theme, and settings. This template is the single source of truth for ISO document styling.

## Motivation

Currently, ISO styling is scattered across:
- `html2doc/spec/fixtures/iso-damd-fdis-sample.docx` (hardcoded in StyleLoader)
- `html2doc/data/iso_*.xml` (extracted files, never read at runtime)
- CSS class → styleId mappings in `StyleLoader.class_to_style`

This coupling means html2doc owns ISO-specific assets it shouldn't. The template belongs in metanorma-iso.

## Prerequisites

- Uniword >= 1.0.6 (DocxPackage.from_file, StylesConfiguration)

## Tasks

### 1. Create the canonical ISO template

Use the existing `iso-damd-fdis-sample.docx` as the starting point. Run it through Uniword's round-trip to validate it produces zero DOC-100..DOC-109 errors.

```ruby
pkg = Uniword::DocxPackage.from_file("iso-damd-fdis-sample.docx")
pkg.to_file("iso-template.docx")
# Validate with Uniword::Validation::Rules::Registry
```

Fix any validation errors in the template.

### 2. Audit the template's style inventory

List all styles defined in the template:
```ruby
pkg = Uniword::DocxPackage.from_file("iso-template.docx")
pkg.styles.styles.each do |s|
  puts "#{s.id}\t#{s.name.val}\t#{s.type}"
end
```

Verify these cover all ISO document elements (headings, annexes, notes, examples, sourcecode, footnotes, endnotes, TOC, headers, footers, bibliography, formula, table/figure titles, admonitions).

### 3. Ship template in metanorma-iso gem

- Place at `lib/isodoc/iso/iso-template.docx` or `data/iso-template.docx`
- Include in gemspec files: `Dir.glob("data/**/*.docx")`
- Provide a method to locate the template:
  ```ruby
  module IsoDoc::Iso
    def self.default_docx_template
      File.expand_path("../../data/iso-template.docx", __dir__)
    end
  end
  ```

### 4. Document the Finnish locale mapping

The template uses Finnish locale names:
- Normaali = Normal
- Otsikko1 = Heading 1
- Alaviitteenteksti = Footnote Text

Create a `style_mapping.yml` in metanorma-iso that maps semantic element names to styleIds in the template. This replaces the hardcoded aliases in `StyleLoader`.

```yaml
# Maps semantic element → template styleId
title: zzSTDTitle
heading1: Otsikko1  # or the actual styleId from template
heading2: Otsikko2
annex: ANNEX
note: note
example: example
sourcecode: sourcecode
footnote_text: FootnoteText
footnote_reference: FootnoteReference
```

### 5. Remove ISO template from html2doc

After shipping in metanorma-iso, delete from html2doc:
- `spec/fixtures/iso-damd-fdis-sample.docx`
- `data/iso_*.{xml,yml}` (6 files)
- `lib/html2doc/iso_style_extractor.rb`
- `lib/html2doc/style_loader.rb` (or refactor to accept template parameter)

## Acceptance Criteria

- [ ] ISO DOCX template passes all DOC-100..DOC-109 validation rules
- [ ] Template included in metanorma-iso gem
- [ ] `IsoDoc::Iso.default_docx_template` returns a valid path
- [ ] style_mapping.yml documents all semantic → styleId mappings
- [ ] html2doc no longer ships ISO-specific template data

## Open Questions

- Should we use the existing Finnish-locale template or create a clean English-locale one?
- Should the template also include the ISO theme, or keep the default Office theme?
