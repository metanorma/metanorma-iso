# 003 — Note/example rendering with fmt-name label

## Problem
Notes and examples in presentation XML have `<fmt-name>` with structured content like:
```xml
<note>
  <fmt-name><span class="fmt-caption-label"><span class="fmt-element-name">NOTE</span></span>...<tab/></fmt-name>
  <p>content</p>
</note>
```

Currently `visit_note` renders the entire note element into a single paragraph with
Note0 style, which puts the label and content together — correct for DOCX since
the Note0 style includes the "NOTE" prefix in its definition.

But the inline renderer tries to render `<fmt-name>` as text, which may produce
duplicate "NOTE" labels or extra whitespace.

## Fix
- Notes: render fmt-name content into the same paragraph as the note body.
  The Note0 style in the ISO template handles numbering and formatting.
- Examples: same pattern — fmt-name + body content in Example0 style.
- Term notes (termnote): use Note0 style, same pattern.

## Files
- `lib/isodoc/iso/docx/adapter.rb` — `visit_note`, `visit_example`
