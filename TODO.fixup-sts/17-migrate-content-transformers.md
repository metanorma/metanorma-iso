# 17 — Migrate content transformers to NisoSts

## Why
Mechanical replacement pass — every body/block transformer switches its
`Sts::IsoSts::*` references to the `Sts::NisoSts::*` equivalent per the
mapping in TODO 14.

## Files & changes
- `section_transformer.rb` — `Sec` → `NisoSts::Section`. Section#title=
  still exists (Title model). Section#label= still exists (Label).
- `front_transformer.rb` — passes the MetadataIso instance built by the
  IsoMetaTransformer to `NisoSts::Front#iso_meta=`.
- `body_transformer.rb` — `Body` (NisoSts), `Section` (NisoSts).
- `back_transformer.rb` — `Back`, `AppGroup`, `App`, nested `Section`,
  `FnGroup` (already TbxIsoTml), `RefList`.
- `paragraph_transformer.rb` — `NisoSts::Paragraph` (has same shape:
  content + typed inline children).
- `list_transformer.rb` — `NisoSts::List`, `NisoSts::ListItem`.
- `def_list_transformer.rb` — `NisoSts::DefList`, `DefItem`, `Term`, `Def`.
- `note_transformer.rb` / `example_transformer.rb` — `NisoSts::NonNormativeNote`,
  `NonNormativeExample`. Dispatch `target.paragraph(x)` (Ruby attr, same
  as before).
- `quote_transformer.rb` — already uses `NisoSts::DispQuote`; only the
  `paragraphs` plural setter (already done).
- `table_transformer.rb` — `TbxIsoTml::TableWrapFoot` (unchanged). The
  `NisoSts::TableWrap` may also be needed if `table_wrap` was previously
  IsoSts::TableWrap (check current code).
- `figure_transformer.rb` — `NisoSts::Figure`, `NisoSts::Caption`,
  `NisoSts::Graphic` (Graphic#href is typed `:xlink_href`; setter is
  `g.href =`).
- `formula_transformer.rb` — `NisoSts::DisplayFormula` (was IsoSts::DispFormula).
- `sourcecode_transformer.rb` — `NisoSts::Preformat`.
- `term_transformer.rb` — `NisoSts::TermSection`, dispatch setters
  unchanged (`paragraph`, `list`, `term_entry`).
- `reference_transformer.rb` — `NisoSts::RefList`, `NisoSts::Ref`,
  `NisoSts::MixedCitation`/`ElementCitation`, `NisoSts::ReferenceStandard`
  for `<std>`.
- `footnote_collector.rb` — `TbxIsoTml::FnGroup`, `TbxIsoTml::Fn`,
  `NisoSts::Label` (or TbxIsoTml::Label — match existing).
- `standard.rb` — adapter docstring update (returns NisoSts::Standard).
- `block_dispatcher.rb` — registry's `target_setter:` names verified
  against NisoSts Ruby attribute names (most match; spot-check Section,
  TermSection, App, etc.).

## Acceptance
- No `Sts::IsoSts` references remain in `lib/metanorma/iso/sts/transformer/`
  except in TODO docstring comments.
- `bundle exec rspec spec/sts/transformer_loading_spec.rb` is green
  (the autoload smoke test).
- Each transformer's existing specs (where they exist) still call the
  right methods.
