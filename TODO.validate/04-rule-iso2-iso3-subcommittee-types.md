# 04 — Rule ISO_2, ISO_3: Subcommittee types

## Why
`validate.rb:isosubgroup_validate` walks
`//contributor[role/description='committee']/organization/subdivision[@type='...']`
and checks `@subtype` against allowed lists. ISO_2 = invalid TC subtype
(allowed: TC, PC, JTC, JPC). ISO_3 = invalid SC subtype (allowed: SC, JSC).

## Files
- `lib/metanorma/iso/validate.rb:23-34` — current implementation.
- `lib/metanorma/iso_document/metadata/iso_project_group.rb` — IsoProjectGroup
  / IsoSubGroup models.
- `lib/metanorma/iso_document/metadata/iso_bibliographic_item.rb` — container.

## Plan
1. Create `lib/metanorma/iso/validation/rules/subcommittee_types_rule.rb`:
   ```ruby
   class Metanorma::Iso::Validation::Rules::SubcommitteeTypesRule < Base
     TC_TYPES = %w[TC PC JTC JPC].freeze
     SC_TYPES = %w[SC JSC].freeze

     def check(context)
       return [] unless context.root
       issues = []
       each_subgroup(context.root) do |subgroup, group_type|
         allowed = group_type == "Technical committee" ? TC_TYPES : SC_TYPES
         next if allowed.include?(subgroup.subtype)
         code = group_type == "Technical committee" ? "ISO_2" : "ISO_3"
         issues << build_issue(location: subgroup_id(subgroup),
                               params: [subgroup.subtype].compact)
       end
       issues
     end
     # ... each_subgroup walks the bibdata editorial-group tree
   end
   ```
2. Add `autoload :SubcommitteeTypesRule,
   "metanorma/iso/validation/rules/subcommittee_types_rule"` to
   `lib/metanorma/iso/validation/rules.rb`.
3. Spec at `spec/metanorma/validation/rules/subcommittee_types_rule_spec.rb`
   with two fixtures (one invalid TC, one invalid SC) — real IsoBibliographicItem
   instances, no doubles.
4. Delete `isosubgroup_validate` and its caller from `validate.rb:content_validate`.
5. No RNG patch needed (this is a value check, not structure).

## Acceptance
- New rule spec green.
- Existing `spec/metanorma/validate/validate_spec.rb` (or equivalent) still
  passes for ISO_2/ISO_3 cases.
- `grep -n "isosubgroup_validate" lib/metanorma/iso/` returns nothing.
- Rice document error log unchanged.
