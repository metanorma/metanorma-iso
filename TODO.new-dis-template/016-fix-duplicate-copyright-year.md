# TODO 016: Fix Duplicate Copyright Year

## Status: DONE

## What

The copyright block has "© ISO 2023" appearing TWICE — once as a separate `zzCopyright` paragraph and once again immediately after.

## Why

The adapter renders two copyright paragraphs:
1. Line 59: `<w:t>© ISO 2023</w:t>` — the copyright notice
2. Line 67: `<w:t>© ISO 2023</w:t>` — a duplicate

### Expected Structure (DIS Template Reference)

The DIS template has ONE copyright notice paragraph using `zzCopyright` style with `pageBreakBefore`:
```xml
<w:pStyle w:val="zzCopyright"/>
<w:pageBreakBefore/>
<w:t xml:space="preserve">© </w:t>
<w:rStyle w:val="stdpublisher"/><w:t>ISO</w:t>
<w:t xml:space="preserve"> </w:t>
<w:rStyle w:val="stddocNumber"/><w:t>2022</w:t>
```

Note: The DIS template uses `stdpublisher` and `stddocNumber` character styles for "ISO" and the year. Our simpler approach (plain text "© ISO 2023") is acceptable but should appear only ONCE.

## Architecture

The adapter's `render_copyright_block` (or equivalent) should output exactly ONE copyright notice paragraph, followed by the rights statement, address, and "Published in Switzerland".

## Files

- `lib/isodoc/iso/docx/adapter.rb` — copyright rendering method

## Depends On

- None
