# 075: Copyright address block — split into multiple lines

## Problem
Output splits the copyright address into 5 separate paragraphs. Reference has a single consolidated paragraph with all address info joined.

## Reference (1 paragraph):
```
ISO copyright officeCP 401 • Ch. de Blandonnet 8CH-1214 Vernier, GenevaPhone: +41 22 749 01 11Email: copyright@iso.orgWebsite: www.iso.org
```

## Output (5 paragraphs):
```
ISO copyright office
CP 401 • Ch. de Blandonnet 8
CH-1214 Vernier, Geneva
Phone: +41 22 749 01 11
Email:
Website: www.iso.org
```

## Analysis
The reference uses `zzCopyright` style for "© ISO 2016" and `zzaddress` style for the address. Both use the same style but the address is a single consolidated paragraph with tab separators between lines. The output creates separate paragraphs from the `<br/>` tags in the boilerplate XML.

## Fix
In `render_copyright_block`, consolidate all address lines into a single paragraph with tab characters between lines, matching the reference. Use `zzCopyright` for the © line and `zzaddress` for the address line.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — `render_copyright_block`
