# 19 — Migrate HTML renderer to NisoSts

## Why
The renderer's `DISPATCH` table keys off class names
(`node.class.name.split("::").last`). Many IsoSts class names change
or disappear in the migration. The `INLINE_TAGS` hash keys on actual
class identity. The `meta_info` extractor walks the typed tree assuming
IseoSts shapes.

## Plan
In `lib/metanorma/iso/sts/html_renderer/ruby.rb`:

1. `ISO = ::Sts::IsoSts` → `NISO = ::Sts::NisoSts`. Drop the `ISO` alias.
2. `INLINE_TAGS` keys: replace `ISO::Bold` → `TBX::Bold`, `ISO::Italic`
   → `TBX::Italic`, `ISO::Sub/Sup/Monospace/Sc/Strike/Underline` →
   `NISO::*`. The HTML tag values stay the same.
3. `DISPATCH` table:
   - `"IsoMeta"` → `"MetadataIso"` (and `MetadataStd`, `RegMeta`,
     `NatMeta` for completeness).
   - `"Sec"` → `"Section"`.
   - `"TermSec"` → `"TermSection"`.
   - `"DispFormula"` → `"DisplayFormula"`.
   - Other entries (Paragraph, List, ListItem, TableWrap, Table, etc.)
     stay — class names are unchanged.
   - `"Std"` → `"ReferenceStandard"`. `"StdRef"` → `"StandardRef"`.
   - Drop entries for IsoSts-only types (`TitleIntro`, `TitleMain`,
     `DocRef`, `CommRef`, `ReleaseDate`, `Secretariat`,
     `CopyrightStatement`, `CopyrightYear`, `CopyrightHolder` — these
     are now bare strings on MetadataIso / Permissions, not separate
     elements).
4. `coerce_model`: `ISO::Standard.from_xml` → `NISO::Standard.from_xml`.
5. `meta_node?`: `ISO::IsoMeta` → `NISO::MetadataIso` (+ `MetadataStd`,
   `RegMeta`, `NatMeta`).
6. `title_text(meta_node)`: TitleWrap in NisoSts has `intro`/`main` as
   STRINGS, not typed TitleIntro/TitleMain. Use `wrap.main` directly
   (string); fall back to `wrap.full.content`.
7. `doc_id(meta_node)`: DocRef is no longer a typed model — it's a string
   on MetadataIso. Read `meta_node.doc_ref` (string) directly. Fall back
   to StandardIdentification's string fields.
8. `find_text` walk: ensure `class.attributes.each_value` traversal works
   for the simpler NisoSts models (most attrs are strings, so the
   recursive descent terminates fast).
9. `std(node)` handler: walk `ReferenceStandard` for `StandardRef` child.
10. Handler method `disp_formula` stays; the dispatch key changes.

## Acceptance
- Renderer accepts a NisoSts::Standard model.
- HTML output for `iso.xml` smoke test still starts with `<!DOCTYPE html>`
  and contains "ISO" branding.
- The full-document render of `iso-demo.sts.xml` still works after the
  STS XML is regenerated.
