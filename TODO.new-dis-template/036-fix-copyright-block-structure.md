# TODO 036: Consolidate Copyright Block — Use zzCopyrightaddress for Address Lines

## Status: DONE

## What

The adapter renders 10 `zzCopyright` paragraphs for the copyright block. The repaired output uses 5 `zzCopyright` + 1 `zzCopyrightaddress` paragraph. The address lines should be consolidated and use the appropriate address style.

## Why

### Current (Latest Output)

```
zzCopyright: © ISO 2016
zzCopyright: All rights reserved. Unless otherwise specified...
zzCopyright: ISO copyright office
zzCopyright: Ch. de Blandonnet 8 • CP 401
zzCopyright: CH-1214 Vernier, Geneva, Switzerland
zzCopyright: Tel.  + 41 22 749 01 11
zzCopyright: Fax  + 41 22 749 09 47
zzCopyright: Email: copyright@iso.org
zzCopyright: Website: www.iso.org
zzCopyright: Published in Switzerland
```

### Expected (Repaired Output)

```
zzCopyright: © ISO 2023
zzCopyright: © ISO 2023
zzCopyright: All rights reserved. Unless otherwise specified...
zzCopyright: ISO copyright office CP 401 • Ch. de Blandonnet 8 CH-1214 Vernier, Geneva, Switzerland
zzCopyright: Published in Switzerland
zzCopyrightaddress: Published in Switzerland
```

### Key Differences

1. **Address consolidation**: Multiple address lines (Tel, Fax, Email, Website) should be combined into one or two paragraphs
2. **`zzCopyrightaddress`** style for the "Published in Switzerland" line
3. The repaired output has "© ISO 2023" twice (copyright year appears in both the notice and the boilerplate text)

## Architecture

1. Consolidate address lines (ISO copyright office, address, phone, etc.) into fewer paragraphs
2. Use `zzCopyrightaddress` style for the "Published in Switzerland" line
3. Ensure the copyright year appears only once (no duplication)

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `render_copyright_block` method
- `data/iso-dis/style_mapping.yml` — add copyright_address mapping

## Depends On

- None
