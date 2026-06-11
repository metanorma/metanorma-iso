# TODO 017: Fix Duplicate "Published in Switzerland"

## Status: DONE

## What

"Published in Switzerland" appears TWICE at the end of the copyright block — once with `zzCopyright` style and again with `zzCopyrightaddress` style.

## Why

Lines 118–129 in the broken output:
```xml
<w:pStyle w:val="zzCopyright"/>
<w:t>Published in Switzerland</w:t>  <!-- FIRST occurrence -->

<w:pStyle w:val="zzCopyrightaddress"/>
<w:t>Published in Switzerland</w:t>  <!-- SECOND occurrence -->
```

### Expected Structure (DIS Template Reference)

The DIS template has "Published in Switzerland" exactly ONCE, using `zzCopyright` style (not `zzCopyrightaddress`):
```xml
<w:pStyle w:val="zzCopyright"/>
<w:t>Published in Switzerland</w:t>
```

The `zzCopyrightaddress` style is NOT used in the DIS template for this text.

## Architecture

Remove the `zzCopyrightaddress` paragraph. "Published in Switzerland" should appear once as the final `zzCopyright` paragraph.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — copyright rendering method

## Depends On

- None
