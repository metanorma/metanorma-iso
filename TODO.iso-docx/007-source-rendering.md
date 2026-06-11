# 007 — Source rendering

## Problem
Source elements in the rice XML reference standards:
```xml
<source><eref ...>ISO 7301:2011</eref>, Table 1</source>
```

These appear below tables/figures and should use the `Source` paragraph style.

## Fix
Add `visit_source` method that applies `Source` style.

## Files
- `lib/isodoc/iso/docx/adapter.rb` — add source visitor
