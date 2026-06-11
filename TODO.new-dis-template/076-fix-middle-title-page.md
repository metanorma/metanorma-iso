# 076: Middle title page missing

## Problem
The reference has a "middle title" page after the front matter sectPr — a separate section that repeats the full document title before the body starts. Output is missing this entirely.

## Reference structure (after front matter sectPr, before "1 Scope"):
```
45. para: "" (blank after sectPr)
46. para: "Cereals and pulses — Specifications and test methods — Part 1:Rice" (style=zzSTDTitle)
47. para bm=: "1Scope" (Heading1)
```

The reference has the title repeated as `zzSTDTitle` style paragraph between the front matter section break and the first clause heading. This is the "middle title" page.

## Output structure:
```
44. para [SECTPR]: (front matter section break)  
45. para: "Cereals and pulses — Specifications and test methods — Part 1:Rice" (style=zzSTDTitle)
46. para bm=: "1Scope" (Heading1)
```

Actually the output DOES have the middle title at para 45. But it's not on a separate page — it runs directly into the body. The reference likely has the title on its own page.

## Fix
Call `render_middle_title` in `visit_root` after `insert_section_break(doc, :front_matter)` and before `visit_sections`. The code already exists but may not be called, or the title may need a page break after it.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — `visit_root`, `render_middle_title`
