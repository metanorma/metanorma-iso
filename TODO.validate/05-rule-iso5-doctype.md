# 05 — Rule ISO_5: Doctype enum

## Why
`validate.rb:doctype_validate` checks `@doctype` against 13 allowed values.
Because `IsoDocumentType` model enum uses camelCase STS vocabulary (mismatch
per Plan finding #5), this stays a Layer 3 rule, not a Layer 1 `values:`
declaration.

## Files
- `lib/metanorma/iso/validate.rb:52-59` — current implementation.
- `lib/metanorma/iso/log.rb` ISO_5: `"%s is not a recognised document type"`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/doctype_rule.rb`:
   ```ruby
   class Metanorma::Iso::Validation::Rules::DoctypeRule < Base
     code "ISO_5"
     ALLOWED = %w[international-standard technical-specification technical-report
                  publicly-available-specification international-workshop-agreement
                  guide amendment technical-corrigendum committee-document
                  addendum supplement extract recommendation].freeze

     def applicable?(context)
       context.root && !context.state.amd
     end

     def check(context)
       doctype = context.state.doctype
       return [] if ALLOWED.include?(doctype)
       [build_issue(location: nil, params: [doctype])]
     end
   end
   ```
2. Add autoload entry to `rules.rb`.
3. Spec: `spec/metanorma/validation/rules/doctype_rule_spec.rb` — three cases
   (valid, invalid, amendment-skipped).
4. Delete `doctype_validate` from `validate.rb`.
5. No RNG patch needed (RNG only validates doctype enum in `relaton-iso.rng`
   DocumentType — that's a different vocabulary and stays until TODO 33
   realigns the model).

## Acceptance
- New spec green.
- `spec/metanorma/validate/validate_spec.rb` ISO_5 case still passes.
- Rice document error log unchanged.
