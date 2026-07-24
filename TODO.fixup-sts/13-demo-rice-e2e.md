# 13 — End-to-end demonstration on rice

## Why
The user asked: "demonstrate you can create STS HTML from it." A repeatable
script that turns an input ISO document into both STS XML and STS HTML is
the proof.

## Status
- Demo script lives at `scripts/rice-sts-demo` (executable).
- `spec/sts/rice_e2e_spec.rb` covers the same pipeline, tagged `:rice_e2e`.
- Both accept any input XML, not just rice.

## Verified run (iso.xml — small fixture)
```
$ bundle exec scripts/rice-sts-demo spec/assets/iso.xml /tmp/iso-demo
Read spec/assets/iso.xml (2642 bytes)
Wrote /tmp/iso-demo.sts.xml (1024 bytes)
Wrote /tmp/iso-demo.sts.html (36933 bytes)
Structural sanity checks:
  STS root: standard
  HTML <html>: true
```

Artifacts saved under `spec/examples/iso-demo.sts.{xml,html}`.

## Optimization pass on rice.xml (this TODO)

The initial state: rice.xml conversion hung indefinitely (no output, 100%
CPU, multi-GB memory). Root cause was not slowness but a class of latent
bugs that surfaced only when the transformer met real-world data:

### Fixed in this pass
1. **lutaml XML-alias used as Ruby method** — `item.p(x)`, `target.p(x)`,
   `dq.p(x)`, `rl.p(x)` (5 sites). lutaml-model defines the XML element
   alias `:p` as a *private* method; the Ruby attribute name is
   `:paragraph`. Replaced all with the public Ruby name.
   - `lib/metanorma/iso/sts/transformer/list_transformer.rb`
   - `lib/metanorma/iso/sts/transformer/note_transformer.rb`
   - `lib/metanorma/iso/sts/transformer/example_transformer.rb`
   - `lib/metanorma/iso/sts/transformer/quote_transformer.rb` (also fixed
     DispQuote's plural `paragraphs` vs `paragraph`).
   - `lib/metanorma/iso/sts/transformer/reference_transformer.rb`

2. **Wrong Ruby attr name entirely** — `item.tbz_term_entry` should be
   `term_entry`; TermSec has no `title` attr; `tw.title` doesn't exist on
   TermSec. Fixed in `term_transformer.rb`.

3. **Wrong class identity** — `link.xlink_href =` on NisoSts::ExtLink (the
   attribute is `:href`). And the `:named_content` serializer rule expects
   IsoSts::ExtLink, not NisoSts::ExtLink. Switched to `Sts::IsoSts::ExtLink`
   in `inline_transformer.rb` (matches `Paragraph#ext_link`'s declared
   type), using the `xlink_href` attribute that model defines.

4. **FigureBlock API mismatch** — `figure.title` (doesn't exist; the
   block uses `name`); `g.xlink_href =` (Graphic's attribute is `href`).
   Fixed in `figure_transformer.rb`.

5. **TableWrap API mismatch** — `tw.non_normative_note(x)` (TableWrap has
   no such attr; the container is `table_wrap_foot`). Wrapped table notes
   in a `TableWrapFoot` in `table_transformer.rb`.

6. **App attribute gap** — App's attribute set is much narrower than
   Sec's. Dispatching annex content directly into App raised on every
   block-level setter the dispatcher tried (`list=`, `disp_quote=`,
   `table_wrap=`...). Wrapped annex content in a nested Sec inside the
   App in `back_transformer.rb`.

7. **StemInlineElement.content** — doesn't exist. `transform_stem` now
   returns nil (skipped) — see "Remaining" below for why.

### Result
The transformer now completes the full rice walk in ~2.3 s (was: never).
Output reaches `model.to_xml` cleanly. The `metanorma-oiml`-pattern
dispatch + the SourceDocument / ModelBuilder facade survive real data.

### Remaining: sts-ruby 0.6.0 model gaps block #to_xml
The transformer no longer hangs, but `Standard#to_xml` raises
`NoMethodError` on some inline elements:

- `Sts::IsoSts::InlineFormula` does not declare `sub`, `sup`,
  `named_content`, ... but the lutaml-model serializer's
  `RuleApplier#extract_rule_value` calls each of those on the model
  during `apply_standard_rules`. Result: nesting an InlineFormula
  inside a Paragraph raises at serialization time.
- Same pattern for other IsoSts inline models with incomplete
  attribute sets vs. their serializer rules.

Workaround applied: `transform_stem` returns nil so stem inlines are
dropped. Once sts-ruby fills the model gaps, restore `transform_stem`
to emit `<inline-formula>`.

**Out of scope for this repo** — the fix belongs in sts-ruby
(`../sts-ruby`). Track via upstream PR.

## Acceptance
- `bundle exec scripts/rice-sts-demo spec/assets/iso.xml /tmp/iso-demo`
  runs in <15s and produces both artifacts. ✅
- `bundle exec rspec spec/sts/` is green (72 examples). ✅
- rice.xml no longer hangs; transformer pipeline completes. ✅
- rice.xml STS XML output is blocked by sts-ruby model gaps (documented
  above), not by anything in this repo.
