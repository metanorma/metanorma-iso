# 15: Definition lists + math (plurimath / OMML) — PARTIALLY FIXED

## Status: PARTIAL (block and inline math are OMML; unit stems still text)

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

## Fixed: inline math (2026-11-18)

StemRenderer now converts MathML `<stem>`/`<fmt-stem>` to inline
`<m:oMath>` (no `<m:oMathPara>`) through the new `MathmlOmml` module,
shared with FormulaRenderer. The oMath keeps its place between the
prose runs. Text stays for: headings, numeric-only stems (only `mn`
tokens), stems with no MathML, and Plurimath conversion errors.
Specs: spec/isodoc/docx/inline_renderers/stem_renderer_spec.rb.

## Still pending

Unit stems (`unitsml(...)` asciimath) still render as text. The
submitted ISO 2533 .doc carries units such as kg·kmol⁻¹ as inline
OMML, so parity needs a unit-to-OMML path (Plurimath unitsml output
was not checked here).

## Verification

Block formula count in output: 4
With `<m:oMathPara>`: 3
With text fallback: 1 (no MathML in source)
