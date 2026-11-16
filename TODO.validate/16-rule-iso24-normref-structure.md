# 16 — Rule ISO_24: Normative references subclauses

## Status
BLOCKED on TODO 33. Verified root cause (2026-08-08):

The RNG **does** allow nested `<references>` and `<clause>` children of a
`<references>` element:
- `lib/metanorma/iso/isodoc.rng` references define has `<zeroOrMore><ref
  name="references">` (recursive).
- A `reference-clause` define exists, used in a `<choice>` alongside
  `references` for the bibliography container.

So the pattern ISO_24 flags is **valid XML per RNG** — the rule enforces an
ISO style choice (normative references should be flat prose + bibitems),
not a structural validity constraint.

The metanorma-document `StandardReferencesSection` model declares only
bibitem/p/note/table/passthrough children. Anything else (nested
`<references>`, `<clause>`) is silently dropped during `from_xml`. This is
a model declaration limitation, not invalid input.

## Unblock plan
In TODO 33, add to `StandardReferencesSection` (or its ISO subclass):
```ruby
attribute :subsections, ReferencesSection, collection: true   # nested <references>
attribute :clauses, ClauseSection, collection: true           # nested <clause>
```
with the corresponding `map_element` calls. Then ISO_24's rule can check
`subsections.empty? && clauses.empty?` on the typed model.

## Why
`validate_section.rb:normref_validate` flags normative references sections
that contain subclauses or nested references sections. ISO/IEC DIR 2 15.4.

## Files
- `lib/metanorma/iso/validate_section.rb` — current implementation (retained).
- `lib/metanorma/iso_document/sections/` — bibliography section.

## Plan
1. Wait for TODO 33 model extension.
2. Create `lib/metanorma/iso/validation/rules/normative_references_structure_rule.rb`.
3. Read `context.root.bibliography.references` (collection). For each
   normative section, check `clauses.empty? && subsections.empty?`.
4. Spec covers: flat (skip), with nested clause (flag), with nested refs
   (flag).
5. Delete `normref_validate`.

## Acceptance
- Spec green; ISO_24 still flagged; rice log unchanged.
