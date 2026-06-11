# TODO 002: Add Normative References Section Dispatch

## Status: COMPLETED

- Added `StandardReferencesSection` case in `visit_block` dispatch
- Fixed ordering: normative refs now render as Section 2 (between Scope and Terms)
- Changed style from `RefNorm` to `normref` to match original DOCX
- Updated `visit_sections` to reorder normative refs after first clause
