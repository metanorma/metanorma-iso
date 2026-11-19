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

## Status: DONE (verified at base 6455ca2f, no code change)
Re-measured by converting spec/examples/rice.presentation.xml with Processor#output(..., :docx) and comparing with spec/examples/rice.docx.

- Reference: ONE paragraph, style `zzaddress` (ind left 505), lines separated by `<w:r><w:br/><w:t>line</w:t></w:r>`, email as a hyperlink run, `boilerplate-address` bookmark.
- Output: ONE paragraph, style `zzCopyrightaddress`, lines separated by `<w:r><w:br/></w:r>`, email kept as a hyperlink run, `boilerplate-address` bookmark kept. The five-paragraph split is gone (fixed earlier; spec/isodoc/docx/boilerplate_renderer_spec.rb "with the full ISO address paragraph", 16 examples green).

Remaining differences, deliberately not changed:
- Style id: the DIS template (data/iso-dis/style_mapping.yml `copyright_address`) defines `zzCopyrightaddress` and has no `zzaddress`; matching the reference id would need a new template style.
- Each line after a break keeps the source's leading space (" CP 401 ..."); the reference has none. Cosmetic.
