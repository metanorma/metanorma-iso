# 16 — Migrate IsoMetaTransformer to NisoSts::MetadataIso

## Why
The biggest semantic delta. `Sts::IsoSts::IsoMeta` wraps every metadata
child in a typed model with `content: [...]`. `Sts::NisoSts::MetadataIso`
stores most children as bare strings. The transformer needs to:

- Emit strings directly instead of `X.new(content: [text])`.
- Drop the typed-wrapper factories that no longer exist.
- Use the simpler `TitleWrap` (intro/main are strings, only full/compl
  are typed).
- Use `StandardRef` (type + value strings) instead of `StdRef` (content
  collection).
- `Permissions` becomes a single model with string fields.

## Plan
Rewrite `lib/metanorma/iso/sts/transformer/iso_meta_transformer.rb`:

1. `transform(bibdata)` builds a `NisoSts::MetadataIso` (not IsoSts::IsoMeta).
2. `title_wraps_for(bibdata)`:
   - For each language, create `NisoSts::TitleWrap` directly.
   - `tw.intro = intro_text` (string).
   - `tw.main = main_text` (string).
   - `tw.compl = NisoSts::TitleCompl.new(content: [compl_text])` (typed).
   - `tw.full = NisoSts::TitleFull.new(content: [full_text])` (typed).
   - `tw.lang = lang`.
3. `doc_ident_for(bibdata)` returns a `NisoSts::DocumentIdentification`
   with `sdo:`, `proj_id:`, `language:`, `release_version:` — all strings.
4. `std_ident_for(bibdata)` returns a `NisoSts::StandardIdentification`
   with `originator:`, `doc_type:`, `doc_number:`, `part_number:`,
   `edition:`, `version:` — all strings.
5. `std_refs_for(bibdata)` returns `[NisoSts::StandardRef.new(type:, value:)]`.
6. `doc_ref_for(bibdata)` returns a STRING (not a DocRef model) — set
   `m.doc_ref = "ISO 9999 (en)"` directly.
7. `release_dates_for(bibdata)` returns STRINGS — `m.release_date = "2026-01-01"`.
8. `comm_ref_for(bibdata)` returns a STRING — `m.comm_ref = "ISO/TC 1"`.
9. `secretariat_for(bibdata)` returns a STRING — `m.secretariat = "GB"`.
10. `ics_codes_for(bibdata)` returns `NisoSts::Ics` instances with
    `content: [code]` (the Ics model has a content string collection).
11. `permissions_for(bibdata)` returns ONE `NisoSts::Permissions` with
    `copyright_statement:`, `copyright_year:`, `copyright_holder:` set
    as strings.

## Acceptance
- No `Sts::IsoSts` references in `iso_meta_transformer.rb`.
- Output `<iso-meta>` block uses bare strings for doc-ref, comm-ref,
  release-date, secretariat, copyright-statement, copyright-year,
  copyright-holder.
- Output `<title-wrap>` has intro/main as element text, not as
  `<intro><content>…</content></intro>` wrapper.
- Existing `iso_meta_transformer_spec.rb` examples (with mock_bibdata)
  continue to pass after assertions are updated in TODO 20.
