# 33 — Upstream PR: metanorma-document declarative

## Why
Layer 1 declarations added to the vendored IsoDocument tree in TODOs 02-03
should be PR'd upstream to `/Users/mulgogi/src/mn/metanorma-document/` so
other flavors benefit. Re-vendor after merge.

## Plan
1. Identify each Layer 1 declaration added in TODOs 02-03.
2. Open a single PR (or one per logical group) to metanorma-document with
   the same declarations.
3. Add the corresponding declarative constraints to the upstream
   `lib/metanorma/iso_document/**/*.rb`.
4. After merge, re-vendor: `cp -r ../metanorma-document/lib/metanorma/iso_document/*
   lib/metanorma/iso_document/`.
5. Confirm no behavior change after re-vendor.

## Acceptance
- PRs merged upstream.
- Vendored copy matches upstream.
- Rice document error log unchanged.

## Priority
P2 — does not block migration PR merge.
