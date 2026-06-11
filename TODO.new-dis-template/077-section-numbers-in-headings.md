# 077: Section numbers duplicated in headings

## Problem
Heading paragraphs contain both the section number AND the title text merged together (e.g. "1Scope" instead of "1 Scope"). The presentation XML's `fmt-title` has the number in a `<span class="fmt-caption-label">` and the title text in a separate `<semx>`. But `render_heading_title_stripped` concatenates them without a space.

## Evidence
Output: `1Scope`, `2Normative references`, `3Terms and definitions`
Reference: `1Scope`, `2 Normative references`, `3 Terms and definitions`

Wait — the reference ALSO has no space: "1Scope". This is because the Heading styles have auto-numbering that provides the number, and the heading text follows without a space. The reference uses the ANNEX style for auto-numbering annex letters.

However, looking at body headings (1-9), the reference text also has no space ("1Scope"). So this may be by design — the heading style's auto-numbering already provides the visual separation in Word.

Actually on closer inspection: the reference has `<w:ind w:left="708"/>` and other formatting that creates visual spacing. The number is styled differently from the text. So the number IS part of the paragraph text in the reference too.

**This is likely NOT a real issue** — the spacing comes from the Word style definition, not from the text content. The heading styles in the template have numbering definitions that handle the visual formatting.

## Status
CLOSED — not a real issue. Both reference and output have merged number+title text. Word's style definitions handle the visual formatting.
