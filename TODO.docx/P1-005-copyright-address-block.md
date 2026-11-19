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

Resolved on lane/1728-cards-batch4 (commit "Trim leading space after line breaks in the copyright address block"):
- Leading space after a break: `BoilerplateRenderer#trim_after_breaks` strips leading whitespace from the run that follows a `w:br`, only in the copyright address paragraph (the source writes `<br/> line`). Other paragraphs keep their spaces. Spec: boilerplate_renderer_spec "starts each line after a break without a leading space".

Remaining difference, deliberately not changed:
- Style id: the DIS template (template.docx and data/iso-dis/styles.yml) defines `zzCopyrightaddress` and has no `zzaddress`. The reference is a CD 2016 document using a CD-era style. Emitting `zzaddress` would reference a style missing from the DIS template, so Word would fall back to Normal. The DIS style is the correct id for this template.
