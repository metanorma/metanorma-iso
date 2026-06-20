# 008 — Eliminate hardcoded style strings

## Problem

The DOCX adapter still has string literals naming styleIds directly.
These bypass the YAML single-source-of-truth:

| File | Line | Literal |
|------|------|---------|
| `adapter.rb` | 942 | `"ANNEX"` (default for annex heading) |
| `style_resolver.rb` | 84 | `"Heading#{level}"` (default if mapping missing) |
| `style_resolver.rb` | 89 | `heading_style(level)` fallback |
| `docx_style_mapping.rb` | 84 | `"Heading#{level}"` literal in `heading_style` |

## Approach

Every string literal styleId in Ruby code is replaced by a YAML lookup.
Two patterns:

### Pattern 1: `heading_style(level)` default literals

In `DocxStyleMapping#heading_style`:
```ruby
def heading_style(level)
  @paragraph_styles[:"heading#{level}"] || "Heading#{level}"  # OLD
end
```

Strict-mode fix (TODO 006 makes `paragraph_style` raise):
```ruby
def heading_style(level)
  paragraph_style(:"heading#{level}")
end
```

The mapping YAML must define `heading1..6` (it does). For `heading7..9`
(Era C defines them), add to YAML:
```yaml
heading7: Heading7
heading8: Heading8
heading9: Heading9
```

### Pattern 2: `adapter.rb:942` "ANNEX" literal

Find the call site:
```ruby
def render_annex_title(annex, doc)
  # ...
  para.style = "ANNEX"  # ← literal
  # ...
end
```

Fix:
```ruby
def render_annex_title(annex, doc)
  para.style = @resolver.paragraph_style(:annex)
end
```

`style_mapping.yml` already has `annex: ANNEX`. The literal was a
defensive fallback; strict mode + YAML completeness removes the need.

### Pattern 3: TocBuilder `TOC#{level}` literal

Already covered by TODO 007. Era C has `TOC1..TOC9`; YAML must have
matching `toc1..toc9` keys.

## Implementation rules

- After this change, `grep -nE '"[A-Z][A-Za-z0-9_-]+"' lib/isodoc/iso/docx/`
  should return **zero matches** that look like style IDs (case-sensitive
  CamelCase OR lowercase single-word).
- An automated spec (TODO 020) greps the codebase and fails on any
  hardcoded style string.

## Files affected

- Modify: `lib/isodoc/iso/docx/adapter.rb`
- Modify: `lib/isodoc/iso/docx/style_resolver.rb`
- Modify: `lib/isodoc/iso/docx_style_mapping.rb`
- Modify: `lib/isodoc/iso/docx/toc_builder.rb`
- Modify: `data/iso-dis/style_mapping.yml` (add heading7..9, toc4..9)

## Acceptance criteria

- `grep -E '"(ANNEX|Heading[1-9]|TOC[1-9]|Body[A-Za-z]+|Main|Foreword|Intro|Note|Example|Figure[A-Za-z]*|Table[A-Za-z]*|Biblio[A-Za-z]*|Warning[A-Za-z]*|Box-[A-Za-z]+|Key[A-Za-z]+|Code|Formula|Source|Hyperlink|Footnote[A-Za-z]*|Comment[A-Za-z]*|Normref|RefNorm|Cover[A-Za-z]*|zz[A-Za-z]+|a[1-9])"' lib/isodoc/iso/docx/`
  returns zero matches.
- `bundle exec rspec spec/isodoc/docx/adapter_purity_spec.rb` passes
  (TODO 020).

## Required specs

- `adapter_purity_spec.rb` (TODO 020) — scans lib/ for hardcoded style
  literals and fails if found.
