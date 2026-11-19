# 15: Definition lists + math (plurimath / OMML) — DONE

## Status: DONE (block and inline math both render as OMML)

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

## Still pending (HISTORICAL — resolved by inline OMML, #1800)

Inline math (inside `<stem>` elements in `<dt>`/`<dd>`/body text)
still renders as text via StemRenderer.stem_fallback_text. To
properly render inline OMML, StemRenderer needs to call plurimath
and emit `<m:oMath>` runs.

## Verification (superseded, see Measurement 2026-11-19)

Block formula count in output: 4
With `<m:oMathPara>`: 3
With text fallback: 1 (no MathML in source)

## Measurement 2026-11-19 (rice, base 2e463195)

Rice converted with `Metanorma::Iso::Processor#output(..., :docx)`:

- source `fmt-stem` elements: 32 = 4 block (`formula/fmt-stem`) + 28 other;
  of the 28, 2 live in `fn` / `fmt-fn-body` copies rendered in
  footnotes.xml, leaving **26 inline stems in the body**.
- document.xml: **4 `m:oMathPara`** (= 4 block formulas; the card's
  "3 of 4" is stale) and **26 `m:oMath` that are not inside an
  `m:oMathPara`** (= 26 inline stems), every one a child of a `w:p`.
- 18 of the 26 sit in a paragraph that also has text runs (the other 8 are
  paragraphs holding only math); e.g. "time necessary for 90 % ... ( t90 )".
- The distinct math strings match the source (t90 x5 in the body, m1/m2,
  s_r/s_R, w_max, ...); the two missing t90 are the footnote copies.

Locked by `spec/isodoc/docx/rice_docx_e2e_spec.rb` ("math (OMML)").
