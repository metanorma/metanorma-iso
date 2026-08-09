# 36 — Model ownership migration: StandardDocument → metanorma-standoc, IsoDocument ← metanorma-iso

## Why

The document model is currently mis-homed. metanorma-document ships
`Document::Components`, `BasicDocument`, `StandardDocument`, AND
`IsoDocument` (plus other flavor models: ItuDocument, IeeeDocument,
BsiDocument, CsaDocument, IecDocument). The layered ownership should be:

```
metanorma-document  → Metanorma::Document::Components, Metanorma::BasicDocument
metanorma-standoc   → Metanorma::StandardDocument         (this TODO)
metanorma-iso       → Metanorma::IsoDocument (canonical)   (already done)
metanorma-itu       → Metanorma::ItuDocument               (follow-up)
metanorma-ieee      → Metanorma::IeeeDocument              (follow-up)
metanorma-bsi       → Metanorma::BsiDocument               (follow-up)
metanorma-csa       → Metanorma::CsaDocument               (follow-up)
metanorma-iec       → Metanorma::IecDocument               (follow-up)
```

This TODO tracks the **StandardDocument move** (the first and largest).
Once it lands, the other flavor models follow the same recipe, and
metanorma-document shrinks to Document components only.

## Current state (verified 2026-08-09)

### Files in scope (metanorma-document)

- `lib/metanorma/standard_document.rb` — autoload entry point (1 file)
- `lib/metanorma/standard_document/` — 124 files, 4,647 lines total
  - `blocks/` (28 files), `elements/` (10), `lists/` (5),
    `metadata/` (38, of which 27 are `unitsml/`), `refs/` (8),
    `sections/` (22), `terms/` (20)
- `lib/metanorma/document.rb:42` —
  `autoload :StandardDocument, "metanorma/standard_document"`

### Consumers

- metanorma-iso: **22 files** reference `Metanorma::StandardDocument`
  or `metanorma/standard_document` (IsoDocument root, STS transformer,
  DOCX boilerplate/toc, validation rules).
- metanorma-ietf: 3 files.
- metanorma-jis: 1 file.
- metanorma-oiml: 2 files.

### Dependency wiring today

- `metanorma-standoc.gemspec` does NOT declare `metanorma-document` as
  a runtime dep (verified against local + upstream main).
- `metanorma-document` is pulled transitively (via metanorma-core or
  another path) — metanorma-iso's `Gemfile.lock` shows
  `metanorma-standoc (3.4.8)` depending on `metanorma-document (~> 0.4.0)`,
  but this dep is not in the checked-out gemspec.

### Local vs upstream drift

- Local metanorma-standoc checkout is **91 commits behind** upstream
  `origin/main`. Any PR must rebase to current main first.
- Upstream main has bumped isodoc to `~> 3.7.0` and metanorma-core to
  `~> 0.2.0`; local gemspec still says isodoc `~> 3.5.0` /
  metanorma-core `~> 0.1.2`.

## Migration plan

### Phase 1 — Add StandardDocument to metanorma-standoc (1 PR, additive)

**Branch:** `feat/move-standard-document` off current
`origin/main` of metanorma-standoc.

**Changes:**
1. Copy `lib/metanorma/standard_document.rb` and the entire
   `lib/metanorma/standard_document/` tree from metanorma-document
   into metanorma-standoc unchanged (124 files, ~4.6k lines).
2. Add to `metanorma-standoc.gemspec`:
   ```ruby
   spec.add_dependency "metanorma-document", "~> 0.4.0"
   ```
3. Add to `lib/metanorma/standoc.rb` (or a new
   `lib/metanorma/standoc/document.rb` required from `standoc.rb`):
   ```ruby
   require "metanorma/document"
   module Metanorma
     module Standoc
       # StandardDocument is canonical to metanorma-standoc.
       autoload :StandardDocument, "metanorma/standard_document"
     end
   end
   ```
   Wait — StandardDocument is `Metanorma::StandardDocument`, not
   `Metanorma::Standoc::StandardDocument`. The namespace stays
   `Metanorma::StandardDocument`; only the gem home changes. So
   no namespace shim is needed; just ensure
   `require "metanorma/standoc"` makes
   `Metanorma::StandardDocument` resolvable.

**Acceptance:**
- `bundle exec rspec spec/` (single targeted files only — never the
  full suite per CLAUDE.md) passes against the existing test suite.
- A smoke test requiring `metanorma/standoc` then accessing
  `Metanorma::StandardDocument::Root` succeeds.
- The new files are byte-identical to metanorma-document's
  (modulo the gem home move).

### Phase 2 — Switch metanorma-iso to resolve StandardDocument from standoc (1 PR to metanorma-iso)

After Phase 1 merges, metanorma-iso's `lib/metanorma/iso_document.rb`
already does `require "metanorma/document"`. We add
`require "metanorma/standoc"` (which is already loaded by the converter
chain) so `Metanorma::StandardDocument` resolves via standoc's copy.
Because standoc's standard_document/ tree shadows document's (same
relative path, standoc ahead in `$LOAD_PATH`), this is a no-op for
callers. Acceptance: all metanorma-iso specs still green.

### Phase 3 — Remove StandardDocument from metanorma-document (1 PR to metanorma-document)

Once standoc ships StandardDocument and every consumer (iso, ietf,
jis, oiml) resolves it from standoc, delete the tree from
metanorma-document:
- `git rm lib/metanorma/standard_document.rb`
- `git rm -r lib/metanorma/standard_document/`
- Remove the `autoload :StandardDocument` line from `document.rb`.

**Acceptance:**
- metanorma-document's own specs pass.
- Downstream flavor gems still resolve `Metanorma::StandardDocument`
  via standoc (verified by running a single targeted spec in each).

### Phase 4 — Move other flavor models (parallel, 1 PR per flavor)

Same recipe per flavor gem:
- metanorma-itu, metanorma-ieee, metanorma-bsi, metanorma-csa,
  metanorma-iec.
- Each PR: copy the flavor's document tree from metanorma-document
  into the flavor gem, add a `metanorma-standoc` runtime dep (for
  StandardDocument), wire the autoload.

### Phase 5 — metanorma-document shrinks to components (final PR)

After Phase 4, metanorma-document contains only:
- `Metanorma::Document::Components` (inline elements, basic blocks)
- `Metanorma::BasicDocument` (block supertypes)

Rename the gem to `metanorma-document-model` if it improves clarity
(optional, separate decision).

## Risks

1. **$LOAD_PATH ordering.** If both metanorma-document and
   metanorma-standoc ship `lib/metanorma/standard_document.rb`,
   Ruby resolves the first one in `$LOAD_PATH`. During the transition
   window (Phase 1 merged, Phase 3 not yet), both gems ship the file.
   The one earlier in `$LOAD_PATH` wins. Need to ensure standoc's copy
   shadows document's consistently. (Same pattern metanorma-iso
   already uses for IsoDocument.)
2. **91-commit drift in metanorma-standoc main.** Must rebase before
   opening the PR; otherwise conflicts and stale-base review noise.
3. **Other flavor gems (b/oiml, jis, ietf) currently depend on
   metanorma-document for StandardDocument.** If we remove it from
   metanorma-document in Phase 3 before those flavors pin
   metanorma-standoc >= the version that ships StandardDocument,
   they'll break.
4. **Vendored IsoDocument in metanorma-iso** already shadows
   metanorma-document's copy. After Phase 3, the document gem no
   longer ships IsoDocument either — needs a coordinated TODO 37.

## Verification strategy

Per CLAUDE.md spec safety: never run the full suite. Per commit:

```bash
# Single spec file in metanorma-standoc:
bundle exec rspec spec/metanorma/validate/validate_section_spec.rb

# Smoke check the load path:
bundle exec ruby -Ilib -e 'require "metanorma/standoc"; \
  p Metanorma::StandardDocument::Root'
```

In metanorma-iso, after Phase 2:
```bash
bundle exec rspec spec/metanorma/validation/model_validator_spec.rb
bundle exec rspec spec/isodoc/iso/docx/adapter_spec.rb:42
```

## Open questions for the user

1. **Timing.** This is multi-PR work spanning 3+ gems and 4+ flavor
   consumers. Land now, or defer until after TODOs 33 + 34 close?
2. **Backwards compat.** Phase 3 is a breaking change for any consumer
   that hasn't migrated to standoc-pinned versions. Cut a major
   version bump of metanorma-document? Or keep the StandardDocument
   tree in metanorma-document as a re-export for one release cycle?
3. **metanorma-standoc rebase.** Local is 91 commits behind upstream
   main. Land Phase 1 against current upstream main (recommended), or
   against the local stale checkout (will trigger upstream rebase
   pain)?
4. **Other flavors.** Do Phase 4 PRs (itu/ieee/bsi/csa/iec) in
   parallel, or serially after metanorma-iso proves the pattern?

## Execution order

```
Phase 1 (PR to metanorma-standoc)   — additive, safe
   ↓
Phase 2 (PR to metanorma-iso)       — switch load order
   ↓
Phase 3 (PR to metanorma-document)  — remove from old home
   ↓
Phase 4 (parallel PRs per flavor)   — itu, ieee, bsi, csa, iec
   ↓
Phase 5 (PR to metanorma-document)  — final rename/shrink
```

Each phase is independently mergeable; each leaves the ecosystem in a
working state.
