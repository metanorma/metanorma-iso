# 082: Sourcecode formatting — callout annotation `(1)` not rendered correctly

## Problem
Sourcecode block has incorrect callout annotation format.

## Reference:
```
puts "Hello, world."
%w{a b c}.each do |x|
  <1>  puts x
end
```

## Output:
```
puts "Hello, world."%w{a b c}.each do |x| (1) puts x
end
```

Issues:
1. Callout `<1>` is rendered as `(1)` inline instead of on its own line
2. Whitespace is not preserved (newlines lost)
3. Lines are merged

## Root cause
The `render_stem` / `render_stem` fallback renders the sourcecode body as plain text, collapsing whitespace. The `apply_callout_format` method converts `<callout>` to `()` but doesn't handle line breaks properly. Sourcecode should use `xml:space="preserve"` and preserve newlines as `<w:br/>` elements.

## Fix
1. Convert newlines in sourcecode body to `<w:br/>` runs
2. Keep callout annotations as superscript references
3. Preserve all whitespace when `@preserve_whitespace` is true

## Location
- `lib/isodoc/iso/docx/adapter.rb` — `visit_sourcecode`, `apply_callout_format`
- `lib/isodoc/iso/docx/inline.rb` — `add_text` with preserve_whitespace
