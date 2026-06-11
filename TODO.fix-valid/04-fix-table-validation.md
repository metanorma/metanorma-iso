# Fix 4: Add table structure validation to Uniword reconciler

## Status: DONE

## Changes
- `uniword/docx/reconciler.rb`: Added `reconcile_tables`, `reconcile_single_table`, `DEFAULT_TABLE_LOOK`
- Ensures tblPr, tblW, tblLook, tblGrid defaults on every table
- Warns about missing gridCol widths via Uniword.logger

## Specs (7 new)
- "adds tblPr when missing" — PASS
- "adds tblW with defaults when missing" — PASS
- "adds tblLook with defaults when missing" — PASS
- "creates tblGrid with correct column count" — PASS
- "adjusts tblGrid when column count mismatches" — PASS
- "fills missing tblLook attributes on existing table" — PASS
- "does not overwrite existing valid table structure" — PASS
