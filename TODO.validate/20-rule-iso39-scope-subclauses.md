# 20 — Rule ISO_39: Scope with subclauses

## Why
`validate_section.rb:section_style` flags scope clause containing subclauses
(scope should be flat prose per ISO/IEC DIR 2 12.4).

## Files
- `lib/metanorma/iso/validate_section.rb:section_style`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/scope_subclauses_rule.rb`.
2. Read `context.root.sections.scope`. Check `clause` collection empty.
3. Spec covers flat scope (skip), scope with subclauses (flag).
4. Delete `section_style` if no other ISO_N keys use it.

## Acceptance
- Spec green; ISO_39 still flagged; rice log unchanged.
