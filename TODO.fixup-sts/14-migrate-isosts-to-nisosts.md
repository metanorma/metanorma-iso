# 14 — Inventory & migration plan: IsoSts → NisoSts

## Why
The IEC/ISO STS Coding Guidelines ed. 2.1
(`~/src/mn/sts-specs/sources/iso-sts-coding-changes-2-1/`) target
**NISO STS v1.2** (harmonised ISO/IEC tagset). The legacy `Sts::IsoSts`
namespace models the predecessor ISO-STS tagset — every metadata child
is a typed wrapper with a `content` collection, and several inline models
are missing the attributes the lutaml-model serializer expects (root
cause of the `InlineFormula#sub` / `ExtLink#named_content` failures in
TODO 13).

`Sts::NisoSts` is the maintained, spec-aligned set. `metanorma-oiml`
already uses it.

## Type mapping

| IsoSts (old)                       | NisoSts (new)                                |
|------------------------------------|----------------------------------------------|
| `IsoSts::Standard`                 | `NisoSts::Standard`                          |
| `IsoSts::Front`                    | `NisoSts::Front`                             |
| `IsoSts::Body`                     | `NisoSts::Body`                              |
| `IsoSts::Back`                     | `NisoSts::Back`                              |
| `IsoSts::AppGroup`                 | `NisoSts::AppGroup`                          |
| `IsoSts::App`                      | `NisoSts::App`                               |
| `IsoSts::Sec`                      | `NisoSts::Section`                           |
| `IsoSts::TermSec`                  | `NisoSts::TermSection`                       |
| `IsoSts::IsoMeta`                  | `NisoSts::MetadataIso`                       |
| `IsoSts::TitleWrap` (typed parts)  | `NisoSts::TitleWrap` (`intro`, `main` = STRINGS; `full`, `compl` typed) |
| `IsoSts::TitleIntro` / `TitleMain` | bare String on TitleWrap                     |
| `IsoSts::TitleCompl` / `TitleFull` | `NisoSts::TitleCompl` / `TitleFull`          |
| `IsoSts::DocumentIdentification` (typed children) | `NisoSts::DocumentIdentification` (all STRINGS: sdo, proj_id, language, release_version, urn) |
| `IsoSts::StandardIdentification` (typed) | `NisoSts::StandardIdentification` (all STRINGS: originator, doc_type, doc_number, edition, version, part_number) |
| `IsoSts::StdRef` (content collection) | `NisoSts::StandardRef` (type + value strings) |
| `IsoSts::DocRef` / `CommRef` / `Secretariat` / `ReleaseDate` (typed) | bare STRINGS on MetadataIso |
| `IsoSts::Ics` (typed IcsCode)      | `NisoSts::Ics` (content string + optional IcsDesc) |
| `IsoSts::Permissions` (typed children) | `NisoSts::Permissions` (copyright_statement, copyright_year = STRINGS; copyright_holder = string collection; license typed) |
| `IsoSts::CopyrightStatement/Year/Holder` | bare STRINGS on Permissions             |
| `IsoSts::Sdo` / `Originator` / `DocType` / `DocNumber` / `PartNumber` / `ProjId` / `ReleaseVersion` / `Version` / `Edition` / `Language` (typed, content-collection) | STRINGS on the parent (`DocumentIdentification` / `StandardIdentification`) directly |
| `IsoSts::Paragraph`                | `NisoSts::Paragraph`                         |
| `IsoSts::List` / `ListItem`        | `NisoSts::List` / `NisoSts::ListItem`        |
| `IsoSts::DefList` / `DefItem` / `Term` / `Def` | `NisoSts::DefList` / `DefItem` / `Term` / `Def` |
| `IsoSts::Figure` / `Caption` / `Graphic` | `NisoSts::Figure` / `NisoSts::Caption` / `NisoSts::Graphic` (Graphic#href is a typed `:xlink_href`) |
| `IsoSts::DisplayFormula` / `InlineFormula` | `NisoSts::DisplayFormula` / `NisoSts::InlineFormula` |
| `IsoSts::Preformat`                | `NisoSts::Preformat`                         |
| `IsoSts::NonNormativeNote` / `NonNormativeExample` | `NisoSts::NonNormativeNote` / `NisoSts::NonNormativeExample` |
| `IsoSts::Label` / `Title`          | `NisoSts::Label` / `NisoSts::Title`          |
| `IsoSts::Bold` / `Italic`          | `TbxIsoTml::Bold` / `TbxIsoTml::Italic` (terminology namespace, like OIML) |
| `IsoSts::Sub` / `Sup` / `Monospace` / `Sc` / `Strike` / `Underline` | `NisoSts::Sub` / `Sup` / `Monospace` / `Sc` / `Strike` / `Underline` |
| `IsoSts::ExtLink`                  | `NisoSts::ExtLink` (`href` is typed `:xlink_href`) |
| `IsoSts::Break`                    | `NisoSts::Break`                             |
| `IsoSts::StyledContent`            | `NisoSts::StyledContent`                     |
| `IsoSts::FnGroup`                  | `TbxIsoTml::FnGroup` (matches existing TbxIsoTml::Fn usage) |
| `TbxIsoTml::TableWrap` / `Table` / `Thead` / `Tbody` / `Tr` / `Th` / `Td` / `TableWrapFoot` | unchanged (already TbxIsoTml) |
| `TbxIsoTml::Xref` / `Fn`           | unchanged                                    |

## Files affected (18 total)

```
lib/metanorma/iso/sts/transformer/
  model_builder.rb              (heavy rewrite)
  iso_meta_transformer.rb       (heavy rewrite — typed wrappers → strings)
  back_transformer.rb           (App, AppGroup, Back types)
  body_transformer.rb           (Body, Section, DefinitionSection)
  front_transformer.rb          (Front, IsoMeta → MetadataIso)
  section_transformer.rb        (Sec → Section)
  paragraph_transformer.rb      (Paragraph)
  list_transformer.rb           (List, ListItem)
  def_list_transformer.rb       (DefList, DefItem, Term, Def)
  table_transformer.rb          (TableWrapFoot — already TbxIsoTml)
  figure_transformer.rb         (Figure, Caption, Graphic)
  formula_transformer.rb        (DisplayFormula)
  sourcecode_transformer.rb     (Preformat)
  note_transformer.rb           (NonNormativeNote)
  example_transformer.rb        (NonNormativeExample)
  quote_transformer.rb          (DispQuote — already NisoSts)
  inline_transformer.rb         (Bold, Italic, Sub, Sup, etc., ExtLink, Xref, Fn)
  footnote_collector.rb         (FnGroup, Fn, Label)
  standard.rb                   (adapter — return type changes)
  block_dispatcher.rb           (target_setter names may change)

lib/metanorma/iso/sts/
  sts.rb                        (public API docstring)

lib/metanorma/iso/sts/html_renderer/
  ruby.rb                       (DISPATCH table keys; INLINE_TAGS keys; meta_info extractor)
```

## Sequencing

1. TODO 15 — Migrate `model_builder.rb` (factory layer; everything depends on it).
2. TODO 16 — Migrate `iso_meta_transformer.rb` (biggest delta; typed → string).
3. TODO 17 — Migrate the rest of `transformer/` (mechanical replacements).
4. TODO 18 — Migrate `inline_transformer.rb` (Bold/Italic → TbxIsoTml).
5. TODO 19 — Migrate `html_renderer/ruby.rb` (dispatch table + meta_info).
6. TODO 20 — Update specs (output shapes change; some assertions rewrite).
7. TODO 21 — Verify rice.xml end-to-end (the original target).
