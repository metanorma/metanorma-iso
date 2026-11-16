# 18 — Rule ISO_29, ISO_30, ISO_31: Mandatory section presence

## Why
- ISO_29: scope clause missing.
- ISO_30: normative references missing.
- ISO_31: terms section missing.

## Files
- `lib/metanorma/iso/validate_section.rb:sections_presence_validate`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/section_presence_rule.rb`.
2. Check `context.root.sections.scope`, `bibliography.normative`,
   `sections.terms` for presence.
3. Spec covers all three missing cases.
4. Delete `sections_presence_validate`.

## Acceptance
- Spec green; ISO_29/30/31 still flagged; rice log unchanged.
