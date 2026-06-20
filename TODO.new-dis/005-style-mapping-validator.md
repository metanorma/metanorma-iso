# 005 — StyleMappingValidator

## Problem

Nothing checks that `style_mapping.yml` references styles that actually
exist in `styles.yml`. Mismatches silently produce broken DOCX output
(Word either ignores unknown styleIds, or invents a `Normal`-derived
default). We currently have ~20 such mismatches (per TODO 002).

## Approach

Introduce `IsoDoc::Iso::Docx::StyleMappingValidator` — pure value
inspector with no side effects. It loads the `DocxStyleMapping` (semantic
side) and the `styles.yml` StyleLibrary (definition side), then reports
defects:

```ruby
module IsoDoc::Iso::Docx
  class StyleMappingValidator
    Defect = Struct.new(:kind, :key, :value, :message)

    def initialize(style_mapping, style_library)
      @mapping = style_mapping
      @library = style_library
    end

    def valid?; defects.empty?; end
    def defects; @defects ||= compute_defects; end

    def unknown_paragraph_styles; end  # values not in library
    def unknown_character_styles;end
    def unknown_auto_numbered; end
    def unknown_numbering_refs; end
    def excluded_paragraph_styles;end  # matches excluded_styles globs
    def excluded_character_styles;end
    def orphaned_library_styles; end   # in library, never referenced (informational)

    private

    def compute_defects
      [].tap do |out|
        out.concat check_unknown(:paragraph_styles, :paragraph_style?)
        out.concat check_unknown(:character_styles, :character_style?)
        out.concat check_excluded(:paragraph_styles)
        out.concat check_excluded(:character_styles)
        out.concat check_auto_numbered
        out.concat check_numbering
      end
    end
  end
end
```

A `StyleLibrary` wrapper around the parsed `styles.yml` exposes
`paragraph_style?(id)`, `character_style?(id)`, `auto_numbered?(id)` —
single source of truth for "what is in styles.xml".

```ruby
module IsoDoc::Iso::Docx
  class StyleLibrary
    def self.load(config_dir); end
    def paragraph_style?(style_id); end
    def character_style?(style_id); end
    def paragraph_style(style_id); end  # returns definition hash
    def auto_numbered?(style_id); end
    def num_id_for(style_id); end
  end
end
```

## Files affected

- Create: `lib/isodoc/iso/docx/style_library.rb`
- Create: `lib/isodoc/iso/docx/style_mapping_validator.rb`
- Modify: `lib/isodoc/iso/docx.rb` — autoload both new classes
- Create: `spec/isodoc/docx/style_library_spec.rb`
- Create: `spec/isodoc/docx/style_mapping_validator_spec.rb`

## Acceptance criteria

- `StyleMappingValidator.new(mapping, library).valid?` returns true for
  the corrected `style_mapping.yml` (post-TODO 001, 002, 003).
- `StyleMappingValidator` returns Defect records for each broken entry
  when run against a deliberately corrupted mapping fixture.
- CI runs the validator as part of the standard DOCX spec suite.
- Validator never mutates the mapping or library; it only inspects.

## Required specs (real instances, no doubles)

- `style_library_spec.rb`:
  - Loads `data/iso-dis/styles.yml` and answers `paragraph_style?`.
  - Returns `true` for `Warningtext`, `Box-begin`, `Heading1`, `KeyText`.
  - Returns `false` for `Note`, `Example`, `Figuretitle`, `bibyear`.
- `style_mapping_validator_spec.rb`:
  - For a clean mapping: `valid?` is true, `defects` empty.
  - For a mapping with a typo (`HeadingXYZ`): `unknown_paragraph_styles`
    returns one Defect, `valid?` is false.
  - For a mapping with `bibyear` value: `excluded_paragraph_styles`
    returns one Defect.
  - For a mapping with `Heading1` in `auto_numbered_styles` but `Heading1`
    lacks `numPr` in the library: returns a Defect.
