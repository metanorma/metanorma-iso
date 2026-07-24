# 18 — Migrate InlineTransformer to NisoSts

## Why
The inline transformer constructs every phrase-level element. Switching
to NisoSts/TbxIsoTml is mechanical but high-touch (many factories).

## Mapping
| Current (IsoSts)            | New                                   |
|-----------------------------|---------------------------------------|
| `IsoSts::Bold`              | `TbxIsoTml::Bold`                     |
| `IsoSts::Italic`            | `TbxIsoTml::Italic`                   |
| `IsoSts::Sub`               | `NisoSts::Sub`                        |
| `IsoSts::Sup`               | `NisoSts::Sup`                        |
| `IsoSts::Monospace`         | `NisoSts::Monospace`                  |
| `IsoSts::Sc`                | `NisoSts::Sc`                         |
| `IsoSts::ExtLink`           | `NisoSts::ExtLink` (`href` is typed `:xlink_href`; setter `link.href =`) |
| `IsoSts::Break`             | `NisoSts::Break`                      |
| `IsoSts::StyledContent`     | `NisoSts::StyledContent`              |
| `IsoSts::Std`               | `NisoSts::ReferenceStandard`          |
| `IsoSts::StdRef`            | `NisoSts::StandardRef` (type + value strings) |
| `IsoSts::Paragraph`         | `NisoSts::Paragraph`                  |
| `TbxIsoTml::Xref`           | unchanged                             |
| `TbxIsoTml::Fn`             | unchanged                             |

## Plan
- Update every `::Sts::IsoSts::X.new` in `inline_transformer.rb` to the
  new namespace.
- For Sub/Sup, drop the old `s.content node.content` fallback (the bug
  from TODO 13 fix is now unnecessary — `StemInlineElement` won't reach
  `transform_sub`).
- For ExtLink, use `link.href = node.target` (typed `:xlink_href`).
- For transform_stem, restore `::Sts::NisoSts::InlineFormula.new` —
  NisoSts::InlineFormula should serialize cleanly now (no more missing
  `sub`/`named_content`).
- For Std inside paragraphs, use `NisoSts::ReferenceStandard` and
  `NisoSts::StandardRef`.
- The Paragraph target attribute names may need a check: NisoSts::Paragraph
  uses `:paragraphs` (plural) for its collection? Or `:paragraph`?
  Verify against the model file.

## Acceptance
- No `Sts::IsoSts` references in `inline_transformer.rb`.
- `transform_stem` returns a real InlineFormula (not nil).
- Inline phrase rendering (`<bold>`, `<italic>`, `<sub>`, `<sup>`,
  `<ext-link>`) still works in the HTML renderer.
