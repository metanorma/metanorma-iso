# 15 — Migrate ModelBuilder to NisoSts

## Why
First migration target — every transformer calls into ModelBuilder, so
switching the factory layer first means downstream changes are mechanical
(NisoSts class lookup) rather than semantic (factory signature changes).

## Plan
Rewrite `lib/metanorma/iso/sts/transformer/model_builder.rb` to:

1. Change `ISO = ::Sts::IsoSts` to `NISO = ::Sts::NisoSts`; drop `ISO`.
2. Every factory that returned an IsoSts type now returns the NisoSts
   equivalent per the mapping table in TODO 14.
3. Adapt factories where the NisoSts type takes string attributes
   directly instead of typed wrappers:
   - `document_identification(sdo:, proj_id:, language:, release_version:, urn:)`
     → all strings, set directly on the model.
   - `standard_identification(originator:, doc_type:, doc_number:, edition:, version:, part_number:)`
     → all strings.
   - `permissions(copyright_statement:, copyright_year:, copyright_holder:)`
     → all strings.
   - `std_ref(type:, value:)` → returns `StandardRef` with two strings.
   - `title_wrap(intro:, main:, compl:, full:, lang:)` → intro/main are
     strings; compl/full are `NisoSts::TitleCompl` / `TitleFull`.
4. Drop factories for types that no longer exist:
   `title_intro`, `title_main`, `sdo`, `originator`, `doc_type`,
   `doc_number`, `part_number`, `proj_id`, `release_version`, `version`,
   `edition`, `language`, `copyright_statement`, `copyright_year`,
   `copyright_holder`, `doc_ref`, `comm_ref`, `release_date`,
   `secretariat`, `ics` (typed IcsCode) — these collapse into string
   fields on their parent.
5. Add new factories for what's left:
   - `metadata_iso` — top-level `<iso-meta>` container.
   - `title_compl(content:)` / `title_full(content:)` — typed children
     of TitleWrap.
6. `bold` / `italic` → `TbxIsoTml::Bold` / `TbxIsoTml::Italic` (matches
   OIML convention; tbx namespace is the canonical home for phrase-level
   Bold/Italic in NISO STS v1.2).

## Acceptance
- `bundle exec ruby -Ilib -e 'require "metanorma/iso/sts"; Metanorma::Iso::Sts::Transformer::ModelBuilder'`
  loads without error.
- No `Sts::IsoSts` references remain in `model_builder.rb`.
- Existing factory callers (`sec`, `paragraph`, `list`, etc.) still work
  — they'll be migrated in TODO 16/17.
