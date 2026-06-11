# 001 — Context-aware paragraph style resolution

## Problem
`resolve_paragraph_style` only checks `class_attr` and `type_attr` on `<p>` elements.
ISO paragraphs get their style from **structural context** — e.g., paragraphs inside
`<foreword>` get `ForewordText`, paragraphs inside `<note>` get `Note0`, body text
gets `BodyText`.

## Root cause
The adapter renders section titles with correct styles (ForewordTitle, IntroTitle, etc.)
but their *child paragraphs* have no class/type attribute, so `resolve_paragraph_style`
returns nil. Result: all paragraphs get the default style (no formatting).

## Fix

### 1. Extend `Context` to track section type
Add `in_foreword`, `in_introduction`, `in_bibliography` flags and `with_*` methods.
Already has `in_note`, `in_example`, `in_annex`, `in_normative`.

### 2. Rewrite `resolve_paragraph_style` with context fallback
```
1. Check class_attr → explicit style (e.g., zzSTDTitle1)
2. Check type_attr → floating-title heading
3. Context fallback:
   - in_note → Note0
   - in_example → Example0
   - in_foreword → ForewordText
   - in_introduction → (body text in intro, already has IntroTitle for title)
   - in_annex → (body text in annex)
   - in_normative → RefNorm
   - in_bibliography → BiblioText
   - default → BodyText
```

### 3. Wrap section visitors with context
- `visit_foreword` → `context.with_foreword { walk_mixed_content }`
- `visit_introduction` → `context.with_introduction { walk_mixed_content }`
- `visit_bibliography` → `context.with_bibliography { walk }`

## Files
- `lib/isodoc/iso/docx/context.rb` — add foreword/introduction/bibliography flags
- `lib/isodoc/iso/docx/adapter.rb` — rewrite `resolve_paragraph_style`, wrap visitors
- `lib/isodoc/iso/docx/style_resolver.rb` — add `body_style` context-aware method
