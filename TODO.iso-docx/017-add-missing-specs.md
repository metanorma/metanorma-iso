# 017 — Add missing Context specs and numbering_for_type specs [DONE]

## Problem
Context spec is missing tests for `with_foreword`, `with_introduction`, `with_bibliography`.
The adapter's `numbering_for_type` method has no direct specs.

## Fix
Add specs for:
1. Context: `with_foreword` restores after block
2. Context: `with_introduction` restores after block
3. Context: `with_bibliography` restores after block
4. Adapter: `numbering_for_type` maps type attrs to correct numIds
5. Update integration specs for corrected numId values

## Files
- `spec/isodoc/docx/context_spec.rb` (add missing with_ specs)
- `spec/isodoc/docx/integration_spec.rb` (update numId expectations)
