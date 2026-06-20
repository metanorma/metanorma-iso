---
title: BUG 012 - Sourcecode callouts rendered as raw XML text
priority: P1
status: closed
---

# BUG 012: Sourcecode Callouts Rendered as Raw XML Text

## Symptom

Source code listings show literal XML elements as text inside the
code block:

```
puts "Hello, world."
%w{a b c}.each do |x| <callout target="_dd539892-1cff-4065-b879-c3da1ac76aa3">1</callout>
  puts x
end
```

The `<callout>...</callout>` is being escaped and inserted as text.

## Root Cause

The adapter's sourcecode rendering treats the callout elements as
literal text instead of converting them to proper OOXML annotation
references.

## Evidence

```xml
<w:p>
  <w:pPr><w:pStyle w:val="Code"/></w:pPr>
  <w:r><w:t>puts "Hello, world."</w:t></w:r>
  <w:r><w:br/></w:r>
  <w:r>
    <w:t>%w{a b c}.each do |x| &lt;callout target="_dd539892-..."&gt;1&lt;/callout&gt;</w:t>
  </w:r>
  ...
</w:p>
```

The callout XML is HTML-escaped and embedded in the code text. Word
shows the escaped markup as plain text.

## Fix

In `visit_sourcecode`:

1. Detect `<callout>` elements within the sourcecode content.
2. For each callout:
   - Emit the preceding code text up to the callout position
   - Emit an annotation reference (e.g., a superscript "(1)" with the
     callout number styled distinctly)
3. Continue with the code text after the callout.

Alternatively, if callouts should map to OOXML sub-document references
(`w:commentReference` or a footnote-style marker), use the appropriate
Uniword builder.

For a simpler first cut: render the callout number as a styled
superscript run (`<w:r><w:rPr><w:vertAlign w:val="superscript"/></w:rPr><w:t>(1)</w:t></w:r>`)
and drop the `<callout>` XML wrapper.

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — `visit_sourcecode`
- Possibly new helper `lib/isodoc/iso/docx/sourcecode_renderer.rb`
  to handle callouts, annotations, and code highlighting cleanly

## Also Note

The line breaks are being emitted as `<w:br/>` runs inside a single
paragraph. The `Code` style should ideally use a different paragraph
per line for proper Word behavior, but a single paragraph with breaks
is acceptable if the style sets `w:wordWrap` correctly.
