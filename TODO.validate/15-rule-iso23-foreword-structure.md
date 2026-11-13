# 15 — Rule ISO_23: Foreword subclauses

## Why
`validate_section.rb:foreword_validate` flags foreword containing subclauses
(should be flat prose).

## Files
- `lib/metanorma/iso/validate_section.rb`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/foreword_structure_rule.rb`.
2. Read `context.root.preface.foreword`. Check `clause` collection empty.
3. Spec covers flat foreword (skip), foreword with subclauses (flag).
4. Delete `foreword_validate`.

## Acceptance
- Spec green; ISO_23 case still flagged; rice log unchanged.

## Note
ISO_23 fires on subclause presence; absence is handled by Layer 1 in TODO 02.
