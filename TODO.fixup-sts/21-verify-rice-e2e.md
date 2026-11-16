# 21 — Verify rice.xml E2E after migration

## Status (2026-07-25) — RESOLVED

### Root cause was in our code, not sts-ruby or lutaml-model

The STS team's diagnosis was correct. From their investigation:

> There are **two** `Fn` classes in sts-ruby:
>
> | File                        | Class                | Ruby attr    | XML name |
> | --------------------------- | -------------------- | ------------ | -------- |
> | `lib/sts/tbx_iso_tml/fn.rb` | `Sts::TbxIsoTml::Fn` | `:p`         | `p`      |
> | `lib/sts/niso_sts/fn.rb`    | `Sts::NisoSts::Fn`   | `:paragraph` | `p`      |
>
> Same `<fn>` XML element, different Ruby attribute names. Our repro passed
> a `TbxIsoTml::FnGroup` (containing `TbxIsoTml::Fn`) to `NisoSts::Back#fn_group`,
> but `NisoSts::Back` declares `:fn_group` as `Sts::NisoSts::FnGroup`.
>
> When serializing, lutaml-model's `ElementBuilder#create_nested_model_element`
> uses `rule.child_transformation` — which is **`NisoSts::FnGroup`'s
> transformation** (declared type), not `TbxIsoTml::FnGroup`'s (the value's
> actual class). That transformation has the `NisoSts::Fn` rule with
> `:paragraph`, which gets applied to our `TbxIsoTml::Fn` value → boom.

My earlier cache-collision hypothesis was wrong — `transformation_key`
includes `model_class.object_id`, so different classes don't collide.

### Fix in this repo

Use the NisoSts pair (`NisoSts::Fn` + `NisoSts::FnGroup`) consistently:
- `lib/metanorma/iso/sts/transformer/footnote_collector.rb` — switched
  to `NISO::FnGroup` / `NISO::Fn`, uses `fn.paragraph para` setter.
- `lib/metanorma/iso/sts/transformer/model_builder.rb#fn_group` —
  switched to `NISO::FnGroup`.
- `lib/metanorma/iso/sts/transformer/inline_transformer.rb` —
  `TEXT_ATTR_FOR` now uses `NisoSts::Fn => :text` (not TbxIsoTml::Fn).
- `lib/metanorma/iso/sts/html_renderer/ruby.rb#fn` — reads
  `node.paragraph` (not `node.p`).
- `spec/sts/footnote_collector_spec.rb` — expects `NisoSts::FnGroup`.

### Verified ✅
- 72 STS specs green.
- rice.xml E2E: `bundle exec scripts/rice-sts-demo spec/examples/rice.xml`
  produces both artifacts in ~25 s.
  - `spec/examples/rice.sts.xml` — 50 959 bytes, NISO STS v1.2.
  - `spec/examples/rice.sts.html` — 91 039 bytes, branded HTML render.

### Upstream follow-ups (independent, optional)

These would prevent the next person from hitting the same trap. The STS
team proposed two PRs; my recommendation is to do #1 only:

1. **sts-ruby**: delete `TbxIsoTml::Fn` and `TbxIsoTml::FnGroup`,
   repoint the 13+8 call sites to `NisoSts::Fn`/`NisoSts::FnGroup`.
   `<fn>` is a NISO STS element; the TBX namespace shouldn't define its
   own. (Same pattern as the earlier `TbxIsoTml::Math` removal in
   commit `9e977a5`.)
2. **lutaml-model**: harden `ElementBuilder#create_nested_model_element`
   to detect `value.class != declared_type` and either dispatch by
   `value.class` or raise a clear type-mismatch error. This is a real
   robustness win independent of sts-ruby.

I'll defer to the STS team on either — both repos are theirs.

## Acceptance — all met
- The minimal repro from the STS team no longer raises when run against
  this repo's transformer output (rice.xml serializes to 50 KB STS XML).
- rice.sts.xml and rice.sts.html artifacts exist and are well-formed.
- Convert + render combined completes in ~25 s for the 1.2 MB rice.xml.
- No NoMethodError from lutaml-model serialization.
