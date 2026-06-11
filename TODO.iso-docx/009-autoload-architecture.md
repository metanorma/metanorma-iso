# 009 — Replace require_relative with autoload

## Problem
Files in `lib/isodoc/iso/docx/` use `require_relative` to load each other:
- `adapter.rb` requires model_utils, context, inline, style_resolver, ../docx_style_mapping
- `inline.rb` requires model_utils

This violates the project coding standard: "Never use require_relative for internal library code.
Use Ruby autoload instead."

## Fix
1. Create `lib/isodoc/iso/docx.rb` — namespace file with autoload entries for all Docx components
2. Register autoloads for `DocxStyleMapping` and `DocxTemplates` on `IsoDoc::Iso` (parent namespace)
3. Remove all `require_relative` from files in `docx/`
4. Update `metanorma-iso.rb` entry point to `require "isodoc/iso/docx"`

## Files
- `lib/isodoc/iso/docx.rb` (new)
- `lib/isodoc/iso/docx/adapter.rb` (remove require_relative)
- `lib/isodoc/iso/docx/inline.rb` (remove require_relative)
- `lib/metanorma-iso.rb` (update require)
