# 24 — Rule ISO_46, ISO_47, ISO_48: "see" cross-references

## Why
- ISO_46: "see" xref pointing to a normative section.
- ISO_47: broken eref.
- ISO_48: "see" pointing to a normative reference.

## Files
- `lib/metanorma/iso/validate_xref.rb:see_xrefs_validate`,
  `see_erefs_validate`.

## Plan
1. Create `lib/metanorma/iso/validation/rules/see_xrefs_rule.rb`.
2. Walk inline content for "see" + xref/eref patterns.
3. For each, look up the target. If normative section → ISO_46. If broken
   eref → ISO_47. If normative ref → ISO_48.
4. Spec covers all three cases.
5. Delete `see_xrefs_validate` and `see_erefs_validate`.

## Risk
Requires `each_anchored` results in SharedState. Sequence after TODO 30.

## Acceptance
- Spec green; ISO_46/47/48 still flagged; rice log unchanged.
