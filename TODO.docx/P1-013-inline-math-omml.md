# 15: Definition lists + math (plurimath / OMML) — PARTIALLY FIXED

## Status: PARTIAL (block formulas work, inline math still text)

## Fixed

Block formulas (inside `<formula>` elements) now render as proper
OOXML OMML via plurimath. FormulaRenderer was extracting MathML
from the wrong attribute path — it tried `fmt_stem` first which
has no `:math` attribute in metanorma-document 0.2.6. New
`extract_mathml_from_stem` checks both shapes:
- Direct `:math` attribute (Mml::V3::Math object or array)
- `:semx` children with `:math` inside

3 of 4 rice formulas render as `<m:oMathPara>` (proper OMML); the
4th falls back to text because it lacks MathML.

DefinitionListRenderer renders definition lists with context-aware
styles (KeyTitle/KeyText in formula/figure zones, Definition
elsewhere). The "where" clause + symbol list pattern works.

## Still pending

Inline math (inside `<stem>` elements in `<dt>`/`<dd>`/body text)
still renders as text via StemRenderer.stem_fallback_text. To
properly render inline OMML, StemRenderer needs to call plurimath
and emit `<m:oMath>` runs.

## Verification

Block formula count in output: 4
With `<m:oMathPara>`: 3
With text fallback: 1 (no MathML in source)
