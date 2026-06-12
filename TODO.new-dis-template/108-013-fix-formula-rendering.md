---
title: 108-013 - Fix formula rendering
priority: P3
status: open
---

# 108-013: Fix Formula Rendering

## Problem

The latest output renders formulas as plain text paragraphs with `Formula` style. The reference renders them differently.

### Latest (formula at 6.5.2.2):
```
Index 166: "r = 1 %(1)"    [Formula style, all text merged]
```

### Reference:
```
Index 201: "(1)"            [Formula name/label, separate line?]
Index 202: "where is the repeatability limit."
```

The formulas need:
1. Proper MathML → OMML conversion for the equation
2. Formula name/label rendered separately (e.g., "(1)")
3. "where" clause for formula variables

## Root Cause

The adapter renders formulas as plain text:
```ruby
def visit_formula(formula, doc)
  para = Uniword::Builder::ParagraphBuilder.new
  para.style = @resolver.paragraph_style(:formula)
  stem = formula.fmt_stem || formula.stem
  if stem
    @inline_renderer.render(stem, para)
  else
    @inline_renderer.render(formula, para)
  end
  doc << para
end
```

This doesn't handle:
- MathML to OMML conversion
- Formula name/label (e.g., "(1)", "(A.1)")
- "where" variable definitions

## Fix

1. Check if Uniword has MathML→OMML conversion support
2. Render formula name (fmt_name) on a separate line or in the same paragraph
3. Render formula variables/definitions after the formula

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — visit_formula
- May need Uniword enhancement for OMML support
