# TODO 048: Fix Copyright Block — Address Lines Not Consolidated

## Status: TODO

## What

The copyright block renders address lines as separate paragraphs (ISO copyright office, CP 401, CH-1214, etc.) instead of consolidated into one `zzaddress` paragraph. The reference uses `zzaddress` for the combined address.

## Why

### Reference (rice.docx)
```
  14: zzCopyright   | © ISO 2016
  15: zzCopyright   | All rights reserved. Unless otherwise specified...
  16: zzaddress     | ISO copyright officeCP 401 • Ch. de Blandonnet 8CH-1214 Vernier, GenevaPhone: +41 22 749 01 11Email: copyright@iso.orgWebsite: www.iso.org
  17: zzCopyright   | Published in Switzerland
```

### Our Output
```
   7: zzCopyright      | © ISO 2016
   8: zzCopyright      | All rights reserved. Unless otherwise specified...
   9: zzCopyright      | ISO copyright office
  10: zzCopyright      | CP 401 • Ch. de Blandonnet 8
  11: zzCopyright      | CH-1214 Vernier, Geneva
  12: zzCopyright      | Phone: +41 22 749 01 11
  13: zzCopyright      | Email:
  14: zzCopyright      | Website: www.iso.org
  15: zzCopyrightaddress | Published in Switzerland
```

### Key Issues
1. **Separate lines**: Address lines (ISO copyright office, address, phone, email, website) should be consolidated into ONE `zzaddress` paragraph
2. **Wrong style**: `zzCopyrightaddress` is used for "Published in Switzerland" but the reference uses `zzCopyright` for that line and `zzaddress` for the address block
3. **Missing style**: `zzaddress` style not in our style mapping

### Note on the Reference

The reference is from the OLD isodoc pipeline which renders the address block differently. The OLD pipeline combines all address lines into one paragraph with `zzaddress` style. Lines within the address paragraph are separated by `<w:br/>` line breaks, not separate paragraphs.

## Architecture

1. Add `zzaddress` to style mapping
2. In `render_copyright_block`, consolidate address lines (starting from "ISO copyright office" through "Website:...") into one paragraph using `<w:br/>` between lines
3. Use `zzaddress` style for the consolidated paragraph
4. Use `zzCopyright` (not `zzCopyrightaddress`) for "Published in Switzerland"

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `render_copyright_block`
- `data/iso-dis/style_mapping.yml` — add `address: zzaddress`

## Depends On

- None
