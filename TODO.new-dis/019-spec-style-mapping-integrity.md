# 019 — Spec: Style mapping integrity

## Goal

Specs that lock down the contract that every semantic key in
`data/iso-dis/style_mapping.yml` resolves to a styleId that exists in
`data/iso-dis/styles.yml`. This catches the class of regression where
the mapping references a style that has been renamed or removed (the
root cause of BUG 021 — `Warningtext`, `InlineCode`, `zzCoverlarge`,
`TermsAdmitted` referenced by mapping but absent from `styles.yml`).

## What the spec asserts

Three independent properties, each as a separate `context`:

1. **Paragraph styles**: every value under `paragraph_styles:` resolves
   to a `styleId` defined in `styles.yml` whose `type == :paragraph`.
2. **Character styles**: every value under `character_styles:` resolves
   to a `styleId` defined in `styles.yml` whose `type == :character`.
3. **Auto-numbered styles**: every value under `auto_numbered_styles:`
   resolves to a `styleId` defined in `styles.yml` whose
   `paragraph_properties.numPr` is present.
4. **Numbering references**: every `numbering:` key resolves to an
   `abstractNumId` defined in `data/iso-dis/numbering.yml`.

## File layout

```
spec/isodoc/iso/docx/
  style_mapping_integrity_spec.rb
  support/
    style_library_factory.rb
```

## Spec sketch

```ruby
require "spec_helper"

RSpec.describe "style_mapping integrity" do
  let(:mapping)   { IsoDoc::Iso::Docx::DocxStyleMapping.load_default }
  let(:library)   { IsoDoc::Iso::Docx::StyleLibrary.load_default }

  describe "paragraph_styles" do
    it "every mapped styleId exists as a paragraph style" do
      missing = mapping.paragraph_styles.reject do |key, style_id|
        library.paragraph_style?(style_id)
      end
      expect(missing).to be_empty,
        "paragraph_styles missing from styles.yml: #{missing.inspect}"
    end
  end

  describe "character_styles" do
    it "every mapped styleId exists as a character style" do
      missing = mapping.character_styles.reject do |key, style_id|
        library.character_style?(style_id)
      end
      expect(missing).to be_empty,
        "character_styles missing from styles.yml: #{missing.inspect}"
    end
  end

  describe "auto_numbered_styles" do
    it "every mapped styleId has numPr in styles.yml" do
      missing = mapping.auto_numbered_styles.reject do |key, style_id|
        library.auto_numbered?(style_id)
      end
      expect(missing).to be_empty
    end
  end

  describe "numbering" do
    it "every abstractNumId exists in numbering.yml" do
      missing = mapping.numbering.values.reject do |abstract_id|
        library.numbering_definition?(abstract_id)
      end
      expect(missing).to be_empty
    end
  end

  describe "excluded_styles" do
    it "no excluded styleId appears in the mapping" do
      excluded = mapping.excluded_style_ids
      leaked = mapping.all_mapped_style_ids & excluded
      expect(leaked).to be_empty,
        "mapping references excluded (pollution) styles: #{leaked.inspect}"
    end
  end
end
```

## Required support code

- `IsoDoc::Iso::Docx::DocxStyleMapping#all_mapped_style_ids` — union of
  `paragraph_styles`, `character_styles`, `auto_numbered_styles` values.
- `IsoDoc::Iso::Docx::DocxStyleMapping#excluded_style_ids` — expanded
  glob list from the `excluded_styles` block (TODO 003).
- `IsoDoc::Iso::Docx::StyleLibrary#paragraph_style?(id)`,
  `#character_style?(id)`, `#auto_numbered?(id)`,
  `#numbering_definition?(id)` — see TODO 005.

## Acceptance criteria

- `bundle exec rspec spec/isodoc/iso/docx/style_mapping_integrity_spec.rb`
  passes.
- Manually breaking the mapping (e.g., changing `note: Note` to
  `note: DefinitelyDoesNotExist`) makes the spec fail with a message
  naming the offending key.
- No `double()`, no `instance_variable_set`, no `require_relative`.

## Notes

- This spec is data-driven — it does not load the full adapter. It is
  fast and runs early in the suite.
- It complements `StyleMappingValidator` (TODO 005): the validator is
  the production check; this spec is the regression test.
