# 30 — Layer 2: Unique IDs and anchors (STANDOC_36)

## Why
`Standoc::Validate#repeat_id_validate` flags duplicate `@id` and `@anchor`
attributes. This is a natural Layer 2 collection validator
(`validates_uniqueness_of`). Migrating here also populates the `SharedState`
needed by TODOs 23-26.

## Files
- `/Users/mulgogi/src/mn/metanorma-standoc/lib/metanorma/validate/validate.rb:146-190`
  — current standoc implementation (NOT modified; we add an ISO-side
  Layer 2 validator that runs first, and disable the standoc method via
  override in `Metanorma::Iso::Validate`).
- `lib/lutaml/model/collection.rb` — `Lutaml::Model::Collection` base.

## Plan
1. Create `lib/metanorma/iso/validation/id_collection.rb`:
   ```ruby
   class Metanorma::Iso::Validation::IdCollection < Lutaml::Model::Collection
     items AnchoredNode  # small model wrapping id + anchor + element ref

     validates_uniqueness_of :id, message: "STANDOC_36"
     validates_uniqueness_of :anchor, message: "STANDOC_36"
   end
   ```
2. `AnchoredNode` is a small lutaml-model with `:id`, `:anchor`, `:element`
   (the source model node).
3. `Base#each_anchored(root)` walks the model tree and produces an
   `IdCollection`.
4. Validate the collection; emit STANDOC_36 on duplicates. Populate
   `context.shared.doc_ids`, `doc_anchors`, `id_seq`, `anchor_seq` for later
   rules.
5. Spec covers unique (skip), duplicate id (flag), duplicate anchor (flag).
6. Override `Standoc::Validate#repeat_id_validate` in `Iso::Validate` to no-op
   (now handled by Layer 2).

## Risk
This rule populates `SharedState` consumed by TODOs 23-26. Sequence BEFORE
those.

## Acceptance
- Spec green; STANDOC_36 still flagged; rice log unchanged.
- `SharedState` populated and accessible to subsequent rules.
