# Fix 5: Correct adapter's ensure_table_structure

## Status: DONE

## Changes
- `lib/isodoc/iso/docx/adapter.rb`: Fixed TableWidth kwargs (`w:`/`type:` instead of `value:`/`rule:`)
- Added GridCol widths (evenly distributed from table width)
- Added TableLook default values
