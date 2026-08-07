# 06 — Rule ISO_6: Iteration format

## Why
`validate.rb:iteration_validate` checks `//bibdata/status/iteration` against
`/^\d+/`. Single-element, simple regex.

## Files
- `lib/metanorma/iso/validate.rb:61-65` — current implementation.

## Plan
1. Create `lib/metanorma/iso/validation/rules/iteration_rule.rb`:
   ```ruby
   class Metanorma::Iso::Validation::Rules::IterationRule < Base
     code "ISO_6"

     def check(context)
       iteration = context.root&.bibdata&.status&.iteration
       return [] unless iteration
       return [] if /\A\d+/.match?(iteration)
       [build_issue(location: "bibdata/status/iteration", params: [iteration])]
     end
   end
   ```
   (Verify the exact attribute path on IsoBibliographicItem; adjust if
   `status` is named differently in the vendored model.)
2. Add autoload entry.
3. Spec: missing iteration (skip), numeric (pass), non-numeric (fail).
4. Delete `iteration_validate`.
5. No RNG patch.

## Acceptance
- Spec green; existing ISO_6 spec passes; rice log unchanged.
