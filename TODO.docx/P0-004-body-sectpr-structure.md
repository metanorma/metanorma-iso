# 066: Fix Body sectPr Differences — Extra Headers and titlePg

## Problem
The body-level sectPr (last section properties) differs between reference and output:
1. Output has `headerReference` elements; reference does not
2. Output has `titlePg`; reference does not
3. Output has `w:code="9"` on pgSz; reference does not

## Evidence
```
Reference body sectPr:
  <w:sectPr w:rsidR="00697CCA">
    <w:footerReference w:type="even" r:id="rId35"/>
    <w:footerReference w:type="default" r:id="rId36"/>
    <w:pgSz w:w="11906" w:h="16838"/>
    <w:pgMar w:top="794" w:right="737" w:bottom="284" w:left="851"
             w:header="709" w:footer="0" w:gutter="567"/>
    <w:pgNumType w:start="1"/>
    <w:cols w:space="720"/>
  </w:sectPr>

Output body sectPr:
  <w:sectPr w:rsidR="00A6056B">
    <w:headerReference w:type="even" r:id="rId25"/>     ← NOT in reference
    <w:headerReference w:type="default" r:id="rId26"/>  ← NOT in reference
    <w:footerReference w:type="even" r:id="rId27"/>
    <w:footerReference w:type="default" r:id="rId28"/>
    <w:pgSz w:w="11906" w:h="16838" w:code="9"/>       ← code="9" NOT in reference
    <w:pgMar w:top="794" w:bottom="284" w:left="851" w:right="737"
             w:header="709" w:footer="0" w:gutter="567"/>
    <w:cols w:space="720"/>
    <w:pgNumType w:start="1"/>
    <w:titlePg/>                                        ← NOT in reference
  </w:sectPr>
```

### Differences:
1. **Extra headerReferences**: Output has even+default headers on body sectPr; reference has NONE
2. **titlePg**: Present in output, absent in reference body sectPr
3. **w:code="9"**: Present in output pgSz, absent in reference
4. **pgMar attribute order**: Different but functionally equivalent

## Fix
1. Remove headerReference from body sectPr (only footer references should exist)
2. Remove `titlePg` from body sectPr (it only belongs on cover/first section)
3. Remove `w:code="9"` from pgSz — it specifies custom paper size and should not be there for standard A4

## Priority
**MEDIUM** — May cause subtle formatting issues but document likely opens.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — body sectPr generation
- `lib/isodoc/iso/docx/document_properties.rb` — pgSz and sectPr property generation

## Status: DONE — premise stale; decided as intended (2026-11-19)
Measured on rice output (base a7b854e7): no `titlePg` and no `w:code="9"` on
any sectPr (cover and front matter never had them; the body sectPr is built
fresh, not copied from the template, whose body pgSz does carry code=9).
Body `headerReference` even/default are kept on purpose: the DIS template body
section carries running headers (rId25/26) and the DIS header text is part of
the output; the 2016 CD reference has none and is not an oracle. The footer
refs match. pgMar order differs only in serialization. Body margins now come
from the template (see P2-012). Pinned by `section_manager_spec.rb`
(cover has no titlePg/pgNumType; sections have header+footer refs).

### Re-measured on batch4 tip 6455ca2f (2026-11-19, no code change)
rice output vs spec/examples/rice.docx, all 3 sectPr: no `titlePg`, no
`w:code` on any pgSz (output and reference). Only remaining body differences:
headerReference even/default (kept on purpose, see above), body pgMar
right/bottom/gutter taken from the DIS template (851/567/0 vs 737/284/567),
pgNumType start=1 present in both. Items 2 and 3 of the problem do not
reproduce; item 1 is the documented decision.
