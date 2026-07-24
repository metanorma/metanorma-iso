# 05 — Add `Transformer::ModelBuilder`

## Why
Today, `Sts::IsoSts::*` model construction is scattered across every
transformer file. `paragraph_transformer.rb` does:

```ruby
p = ::Sts::IsoSts::Paragraph.new
p.id = ...
yield p
```

…and `section_transformer.rb`, `iso_meta_transformer.rb`, etc. each repeat
the pattern with their own variations. OIML centralizes all of this in a
`ModelBuilder` module-function facade:

```ruby
ModelBuilder.standard(lang:, front:, body:, back:)
ModelBuilder.sec(id:, label:, title:, content:)
ModelBuilder.paragraph(id:)
ModelBuilder.list(list_type:, list_item:)
# ... one factory per sts-ruby class
```

Benefits:
- **DRY**: every `Sts::IsoSts::X.new` lives in one file.
- **MECE**: "how do I construct an X?" has one answer.
- **OCP**: adding a new sts-ruby class mapping is one new method, not a
  scatter of construction sites.
- **Test surface**: factory methods are easily spec'd in isolation.

## Plan
1. Create `lib/metanorma/iso/sts/transformer/model_builder.rb`.
2. Mirror OIML's API (module_function + factory per IsoSts class), adapted
   for `Sts::IsoSts::*` types (Standard, Front, Body, Back, Sec, Title,
   Paragraph, List, ListItem, TableWrap, Table, Thead, Tbody, Tr, Th, Td,
   Figure, Graphic, Caption, DisplayFormula, InlineFormula,
   NonNormativeNote, NonNormativeExample, Label, ExtLink, Xref, Fn,
   IsoMeta, TitleWrap, TitleIntro, TitleMain, TitleCompl, TitleFull,
   DocumentIdentification, StandardIdentification, Permissions,
   CopyrightStatement, CopyrightYear, CopyrightHolder, StdRef, DocRef,
   ReleaseDate, CommRef, Secretariat, Ics, Sdo, etc.).
3. Refactor existing transformers to use `ModelBuilder.xxx` instead of
   direct `::Sts::IsoSts::X.new`. Do this incrementally — file by file —
   with the existing specs as the safety net.
4. Keep `build_ordered` in `base.rb` as the underlying primitive (it just
   yields a new instance — useful when the factory does not apply).

## Acceptance
- New file `lib/metanorma/iso/sts/transformer/model_builder.rb` exists.
- `grep -rn "::Sts::IsoSts::.*\.new" lib/metanorma/iso/sts/transformer` is
  reduced to a small set of escape hatches (e.g. cases where a one-off
  class with very specific construction is clearer inline).
- All existing STS specs pass.
- One new spec covers `ModelBuilder` factories (one example per factory).
