---
title: 108-014 - Fix sourcecode formatting
priority: P3
status: open
---

# 108-014: Fix Sourcecode Formatting

## Problem

Sourcecode blocks need proper formatting — newlines preserved, callouts handled, and potentially different font/size.

### Latest (Annex E, sourcecode example):
```
"puts "Hello, world."%w{a b c}.each do |x| (1)  puts xend     "
```

### Reference:
```
"puts "Hello, world."%w{a b c}.each do |x| <1>   puts xend"
```

The text is all merged into one run with no line breaks. The reference preserves some structure with `<1>` callout markers.

## Root Cause

1. Newlines in sourcecode content are not being converted to `<w:br/>` elements
2. Callout markers may not be rendered properly
3. The `xml:space="preserve"` attribute may not be set

## Fix

1. When rendering sourcecode content, split on `\n` and insert `<w:br/>` between lines
2. Ensure each line is in its own run or properly broken
3. Handle callout markers (e.g., `<1>` → annotation reference or highlighted text)
4. Set `xml:space="preserve"` on runs containing sourcecode

## Files to Change

- `lib/isodoc/iso/docx/inline.rb` — sourcecode rendering
- `lib/isodoc/iso/docx/adapter.rb` — visit_sourcecode
