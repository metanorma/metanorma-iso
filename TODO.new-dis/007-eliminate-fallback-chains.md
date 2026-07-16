# 007 — Eliminate fallback chains

## Problem

Style resolution fallback chains silently mask missing mappings and
violate MECE. Current offenders:

| File | Line | Pattern |
|------|------|---------|
| `adapter.rb` | 408 | `paragraph_style(:ref_norm) || paragraph_style(:normref)` |
| `adapter.rb` | 411 | `paragraph_style(:biblio_entry) || paragraph_style(:list_paragraph)` |
| `style_resolver.rb` | 48 | `paragraph_style(:normref) || paragraph_style(:body_text)` |
| `style_resolver.rb` | 66 | `paragraph_style(:figure_title_annex) || paragraph_style(:figure_title)` |
| `style_resolver.rb` | 74 | `paragraph_style(:table_title_annex) || paragraph_style(:table_title)` |
| `toc_builder.rb` | 249 | `paragraph_style(key) || "TOC#{level}"` |

## Approach

Every `a || b` style fallback is either:

1. **A genuine single canonical style** — replace with one lookup,
   add the canonical key to `style_mapping.yml`.
2. **A semantic difference being papered over** — model it explicitly
   (e.g., normref in normative-section context vs. bibliography context
   is two distinct semantic concepts; have two keys, never chain).

### Per-fallback fix

**`adapter.rb:408` (normref in normative bib context):**

The fallback was needed because `:ref_norm` and `:normref` were two
mappings for the same concept. In Era C the correct style is just one —
DIS 15926 uses `RefNorm` for normative references and `BiblioEntry` for
bibliography. Fix:

```yaml
# style_mapping.yml — collapse to single canonical
normative_reference: RefNorm       # was :ref_norm and :normref
bibliography_entry: BiblioEntry    # was :biblio_entry
```

Adapter call site becomes:
```ruby
def bib_item_style
  @context.in_normative ? @resolver.paragraph_style(:normative_reference)
                        : @resolver.paragraph_style(:bibliography_entry)
end
```

**`adapter.rb:411` (biblio_entry fallback to list_paragraph):**

`list_paragraph` is from the 8601 era and shouldn't be in our mapping.
Era C always has `BiblioEntry`. Drop the fallback.

**`style_resolver.rb:48` (normative body fallback):**

If `:normref` isn't mapped, that's a YAML defect — strict mode raises.
The fallback was hiding a real missing mapping.

**`style_resolver.rb:66, :74` (annex figure/table title fallback):**

These encode the semantic "in annex context, use annex-specific title
style". DIS 15926 doesn't have `AnnexFigureTitle`/`AnnexTableTitle` as
distinct styles — figures and tables in annexes use the same
`FigureGraphic`/`figuretitle` styles (the "Annex X." prefix comes from
numbering, not style). Fix:

```yaml
# style_mapping.yml — single canonical
figure_title: FigureGraphic       # was figure_title + figure_title_annex
table_title: tabletitle           # was table_title + table_title_annex
```

StyleResolver methods simplify:
```ruby
def figure_title_style
  paragraph_style(:figure_title)
end
```

The `in_annex` check moves into the numbering layer (TODO 018), not the
style layer.

**`toc_builder.rb:249` (TOC literal fallback):**

```ruby
@resolver.paragraph_style(key) || "TOC#{level}"
```

The `"TOC#{level}"` string literal is a hardcoded style. Strict mode
will raise; we replace with `paragraph_style(:"toc#{level}")`. Era C
has TOC1..TOC9, so all level lookups succeed.

## Files affected

- Modify: `data/iso-dis/style_mapping.yml` (consolidate keys)
- Modify: `lib/isodoc/iso/docx/adapter.rb` (drop `||`)
- Modify: `lib/isodoc/iso/docx/style_resolver.rb` (drop `||`)
- Modify: `lib/isodoc/iso/docx/toc_builder.rb` (drop `||`)

## Acceptance criteria

- `grep -E 'paragraph_style\([^)]+\)\s*\|\|' lib/isodoc/iso/docx/` returns
  zero matches.
- `bundle exec rspec spec/isodoc/docx/adapter_spec.rb` still passes.
- Bibliography rendering uses `RefNorm` for normative, `BiblioEntry`
  for non-normative — confirmed by adapter spec assertions.

## Required specs

- `adapter_spec.rb` (extend):
  - Bibliography entry in normative section: paragraph has `RefNorm` style.
  - Bibliography entry in informative section: paragraph has `BiblioEntry`
    style.
  - Figure title in body: paragraph has `figuretitle` style.
  - Figure title in annex: paragraph has same `figuretitle` style
    (annex number comes from numbering, not style).
- `style_resolver_spec.rb` (extend):
  - `figure_title_style` returns `figuretitle` regardless of annex context.
  - `context_body_style` for normative returns `RefNorm`.
  - `context_body_style` for bibliography returns `BiblioText` (or
    `BiblioEntry` if at entry level).
- `toc_builder_spec.rb` (extend):
  - TOC level 1 uses `TOC1` from YAML, no string fallback.
