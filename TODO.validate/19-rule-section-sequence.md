# 19 — Rule ISO_28, ISO_32, ISO_33, ISO_34, ISO_36, ISO_37, ISO_38, ISO_40, ISO_41: Section sequencing

## Why
`validate_section.rb:sections_sequence_validate` enforces the ordering of
sections (foreword → introduction → scope → terms → definitions → clauses →
annexes → norm refs → bibliography). Multiple ISO keys fire on specific
ordering violations. This is the hardest single piece of the migration — a
faithful port of the existing state machine.

## Files
- `lib/metanorma/iso/validate_section.rb:88-155` — state machine.

## Plan
1. Create `lib/metanorma/iso/validation/rules/section_sequence_rule.rb`.
2. Build an ordered list of (section_type, model_node) by walking
   `context.root.preface` then `context.root.sections` then
   `context.root.annex` then `context.root.bibliography`.
3. Run the same state-machine transitions as the current implementation,
   emitting the matching ISO_N key on each violation.
4. Spec covers every ISO_N case (one fixture per transition).
5. Delete `sections_sequence_validate`.

## Risk
State machines are easy to subtly break. The spec must be exhaustive. Allow
~1-2 days for this TODO.

## Acceptance
- Spec green; all listed ISO_N cases still flagged identically; rice log
  unchanged.
