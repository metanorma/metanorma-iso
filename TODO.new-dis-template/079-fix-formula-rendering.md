# 079: Formula rendering — formula names not on separate lines

## Problem
Formula expressions and their labels (e.g. "(1)") are rendered inline as a single paragraph. Reference separates the formula expression from the label.

## Reference:
```
(formula expression in MathML, rendered by Word)
(1)                    ← separate line, right-aligned
```

## Output:
```
r = 1 %(1)            ← formula text + label merged on one line
```

The formula `fmt-name` contains the label "(1)" which should be rendered as a separate run on the right side of the formula paragraph (using right-aligned tab stop or separate paragraph).

Additionally, formulas are rendered as plain text fallback (e.g. "r = 1 %") instead of MathML. The reference uses OOXML math markup (`<m:oMath>` elements) for proper rendering.

## Fix
1. Render formula stem content as MathML→OOXML instead of plain text fallback
2. Render formula `fmt-name` with a right-aligned tab stop before the label

## Location
- `lib/isodoc/iso/docx/inline.rb` — `render_stem`
- `lib/isodoc/iso/docx/adapter.rb` — `visit_formula`
