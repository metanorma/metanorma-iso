# 20 — Update STS specs for NisoSts output shapes

## Why
Several existing specs assert IsoSts-specific shapes that change after
the migration.

## Files & expected changes

### `spec/sts/iso_meta_transformer_spec.rb`
- All `m.title_wrap` returns a typed TitleWrap with `intro`/`main` STRINGS,
  not TitleIntro/TitleMain models. The mock-based assertions check for
  specific attribute accessors — most should still work because the
  transformer's helper methods (`extract_text_value`, etc.) are unchanged.
- The "transforms minimal bibdata" example builds an IsoMeta — switch
  the assertion to expect a `NisoSts::MetadataIso`.
- The "transforms bibdata with copyright" example asserts Permissions
  children — now they're string fields on Permissions, not typed wrappers.

### `spec/sts/block_dispatcher_spec.rb`
- `target = Sts::IsoSts::Sec.new` → `Sts::NisoSts::Section.new`.
- Registry entries' target_setter names verified (mostly unchanged).

### `spec/sts/document_transformer_spec.rb`
- Uses `transformer.send(:apply_nbsp_to_text, xml)` — change to
  `public_send` per the global rule. Or test through the public
  `Metanorma::Iso::Sts.convert` API instead.

### `spec/sts/paragraph_transformer_spec.rb`
- Builds `Sts::IsoSts::Paragraph` directly? If so, switch to
  `NisoSts::Paragraph`. Spec text content assertions unchanged.

### `spec/sts/inline_transformer_spec.rb`
- Same — any IsoSts class construction switches to NisoSts/TbxIsoTml.

### `spec/sts/term_transformer_spec.rb`
- `Sts::IsoSts::TermSec` → `NisoSts::TermSection`.

### `spec/sts/reference_transformer_spec.rb`
- Verify RefList / Ref type references.

### `spec/sts/table_transformer_spec.rb`
- TableWrap is already TbxIsoTml; verify no IsoSts leak.

### `spec/sts/public_api_spec.rb` (new)
- Assertions on `Metanorma::Iso::Sts.convert(xml)` output — search for
  `<iso-meta` (still present), `<standard` (still present).
- `convert_to_model` returns `Sts::NisoSts::Standard` (not IsoSts).

### `spec/sts/html_renderer_spec.rb` (new)
- Test XML strings use `<standard>` root — these work for both namespaces.
- The `uses the iso-meta title-wrap main as the hero title` example:
  ensure `<main>` element text is read correctly as STRING (not as
  TitleMain#content).

### `spec/sts/transformer_loading_spec.rb`
- The autoload smoke test stays the same.
- The "no send/private/ivar" lints stay the same.

## Acceptance
- All STS specs (`spec/sts/*_spec.rb`) green.
- New `public_api_spec.rb` and `html_renderer_spec.rb` continue to pass
  after namespace migration.
