# 018 — Numbering YAML realignment to Era C canonical scheme

## Problem

Our `data/iso-dis/numbering.yml` has dozens of abstractNum definitions
matching the ISO 6709 ed.3 (Era B) scheme. DIS 15926 (Era C) has only
**7 abstractNum** definitions. Misalignment causes:

- Wrong numId references in generated numbering.xml
- Heading1 numbered differently than reference
- Annex headings don't get `Annex A`, `Annex B` auto-prefix

## Canonical Era C scheme (from DIS 15926 numbering.xml)

| abstractNumId | format | lvlText | bound style | numId |
|---------------|--------|---------|-------------|-------|
| 0 | decimal | `%1` (multilevel 0-8) | `IntroHeading1..9` | 8 |
| 1 | bullet | `—` | `ListContinue1` | 3 |
| 2 | bullet | (empty) | (none) | — |
| 3 | decimal | `%1` (multilevel 0-8) | `Heading1..9` | 4 |
| 4 | decimal | `%1.` | basic ordered list | 1 |
| 5 | bullet | (empty) | (none) | — |
| 6 | upperLetter | `Annex %1` (multilevel 0-5) | `ANNEX`, `a2..a6` | 7 |

**Note**: Heading2..6 have `numId=""` (empty) in the style — they
inherit numbering from Heading1 via the multilevel abstractNum.

## Approach

After TODO 001 re-extracts `numbering.yml` from DIS 15926, the file
should already match the canonical scheme. This task ensures
`style_mapping.yml` numbering keys map to the right abstractNum IDs:

```yaml
numbering:
  intro_clause: 0           # IntroHeading1..9 multilevel
  list_continue_dash: 1     # ListContinue1 bullet —
  body_clause: 3            # Heading1..9 multilevel (numId 4)
  decimal_ordered_list: 4   # 1. 2. 3. single-level
  annex_clause: 6           # ANNEX, a2..a6 multilevel (numId 7)
```

### Adapter usage

```ruby
class ClauseRenderer < Base
  def render(clause, doc)
    if @context.in_annex
      render_with_numbering(clause, doc, :annex_clause)
    elsif @context.in_intro
      render_with_numbering(clause, doc, :intro_clause)
    else
      render_with_numbering(clause, doc, :body_clause)
    end
  end

  private

  def render_with_numbering(clause, doc, num_key)
    abstract_id = @resolver.numbering_id(num_key)
    para = build_paragraph_with_numbering(clause, abstract_id)
    # ...
  end
end
```

### Heading numbering inheritance

For Heading2..6 (which inherit from Heading1's numId), the adapter does
**not** set explicit numPr on those paragraphs. The style's numPr
provides the linkage; only Heading1 paragraphs get an explicit numId.

```ruby
def heading_numbering_for(level, in_annex)
  return nil unless level == 1   # only Heading1 / ANNEX get explicit numId
  in_annex ? :annex_clause : :body_clause
end
```

## Files affected

- Modify: `data/iso-dis/numbering.yml` (via TODO 001 extraction)
- Modify: `data/iso-dis/style_mapping.yml` — renumber keys to match
  Era C abstractNum IDs
- Modify: `lib/isodoc/iso/docx/renderers/clause_renderer.rb`
- Modify: `lib/isodoc/iso/docx/section_manager.rb`

## Acceptance criteria

- `bundle exec ruby -e 'puts YAML.load_file("data/iso-dis/numbering.yml")["definitions"].size'`
  returns 7 (or whatever DIS 15926 has — must match exactly).
- `Heading1` paragraph in body has `<w:numPr><w:ilvl w:val="0"/><w:numId w:val="4"/></w:numPr>`.
- `Heading2` paragraph has no `<w:numPr>` (inherits via style).
- `ANNEX` paragraph has `<w:numId w:val="7"/>`.
- Heading1 in body section auto-numbers as "1", "2", "3"...
- Heading2 auto-numbers as "1.1", "1.2", "2.1", ...
- ANNEX heading auto-numbers as "Annex A", "Annex B", ...

## Required specs

- `numbering_canonical_spec.rb`:
  - 7 abstractNums in YAML.
  - abstractNum 3 (Heading1) has 9 levels.
  - abstractNum 6 (ANNEX) has 6 levels.
- `clause_renderer_spec.rb`:
  - Heading1 paragraph has numId=4, ilvl=0.
  - Heading2 paragraph has no numPr.
  - ANNEX paragraph has numId=7, ilvl=0.
  - a2 paragraph (annex subclause) has no numPr (inherits).
