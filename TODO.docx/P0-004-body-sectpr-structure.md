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
