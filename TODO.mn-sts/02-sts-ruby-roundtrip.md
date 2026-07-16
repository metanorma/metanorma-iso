# 02 - Phase 1: Round-trip ISO NISO STS XML in sts-ruby

## Objective

Make `Sts::IsoSts::Standard` parse and re-serialize every reference STS file in `mn-samples-iso-private/reference-docs/` without data loss.

## Reference Files

```
ISO_8601-1_2019/C070907e.xml          — ISO 8601-1:2019 (Date and time, ~38pp)
ISO_8601-2_2019/C070908e.xml          — ISO 8601-2:2019
ISO_34000_2023/iso_std_iso_34000_...  — ISO 34000:2023
ISO_10303-14_2005/...                 — ISO 10303-14:2005
ISO_10303-22_1998/...                 — ISO 10303-22:1998
ISO_10303-23_2000/...                 — ISO 10303-23:2000
ISO_10303-24_2001/...                 — ISO 10303-24:2001
ISO_10303-28_2007/...                 — ISO 10303-28:2007
ISO_10303-31_1994/...                 — ISO 10303-31:1994
ISO_10303-32_1998/...                 — ISO 10303-32:1998
ISO_10303-34_2001/...                 — ISO 10303-34:2001
ISO_TS_10303-15_2021/...             — ISO/TS 10303-15:2021
ISO_TS_10303-16_2021/...             — ISO/TS 10303-16:2021
ISO_TS_10303-17_2022/...             — ISO/TS 10303-17:2022
ISO_TS_10303-18_2021/...             — ISO/TS 10303-18:2021
ISO_TS_10303-27_2000/...             — ISO/TS 10303-27:2000
ISO_TS_10303-35_2003/...             — ISO/TS 10303-35:2003
```

## Approach

### Step 1: Set up round-trip test harness
- Copy reference XML files into `sts-ruby/spec/fixtures/reference_docs/`
- Create a shared spec that iterates over all reference files
- Each test: parse → serialize → compare with `be_xml_equivalent_to`

### Step 2: Run round-trips, catalog failures
- Run all reference files through the round-trip test
- Catalog which elements/attributes cause parse or serialization failures
- Classify failures by model class (IsoMeta, Sec, TermSec, Paragraph, Table, etc.)

### Step 3: Fix model gaps iteratively
For each failure category, fix the sts-ruby model:

**Known likely gaps** (based on analysis of `C070907e.xml`):
1. **Front/iso-meta**: `custom-meta-group/custom-meta`, `meta-date[@type]`, `std-xref[@type]`, `pub-date` — verify all are mapped
2. **Body/sec**: `sec[@sec-type]`, nested `sec` elements, mixed content ordering — verify `ordered` attribute for document-order preservation
3. **Term sections**: `tbx:termEntry`, `tbx:langSet`, `tbx:tig`, `tbx:term`, `tbx:definition`, `tbx:note`, `tbx:example`, `tbx:source`, `tbx:see`, `tbx:entailedTerm`, `tbx:subjectField`, `tbx:partOfSpeech`, `tbx:termType`, `tbx:normativeAuthorization`, `tbx:usageNote`
4. **Tables**: `table-wrap`, `table`, `thead`, `tbody`, `tfoot`, `tr`, `th`, `td`, `col`, `colgroup` — verify CALS table model attributes (`cols`, `align`, `valign`, `char`, `charoff`, `content-type`, etc.)
5. **Figures**: `fig`, `graphic[@xlink:href]`, `fig-group`
6. **Formulas**: `disp-formula`, `inline-formula` with `mml:math`
7. **Lists**: `list[@list-type]`, `list-item`, nested lists, `def-list`, `def-item`, `term`, `def`
8. **Inline**: `bold`, `italic`, `sc` (small caps), `sub`, `sup`, `monospace`, `underline`, `ext-link[@xlink:href]`, `xref[@rid/@ref-type]`, `std`, `styled-content[@style-type]`, `break`
9. **Footnotes**: `fn-group`, `fn[@id]`, `fn/label`, `fn/p`
10. **References**: `ref-list[@content-type]`, `ref[@id]`, `ref/label`, `ref/mixed-citation`, `ref/std`, `ref/std-ref`, `ref/note`
11. **Back matter**: `app-group`, `app[@id/@content-type]`, `app/label`, `app/title`, annex nested structures
12. **Namespaces**: Ensure `mml`, `tbx`, `xlink` namespace declarations round-trip on `<standard>` root
13. **Comments/PIs**: `<?foreward metadata-error?>` processing instructions — verify they survive round-trip
14. **Mixed content ordering**: Many elements have interleaved text + child elements. Verify `ordered` or `mixed_content` is used where needed in the model

### Step 4: Fix ordering issues
- Lutaml::Model `ordered` attribute preserves child element order
- Ensure all elements that allow interleaved children use `ordered: true` where needed
- This is the #1 cause of round-trip failures in mixed-content XML

## Success Criteria

```ruby
# For every reference file:
doc = File.read(reference_file)
parsed = Sts::IsoSts::Standard.from_xml(doc)
generated = parsed.to_xml(pretty: true, declaration: true, encoding: "utf-8")
expect(generated).to be_xml_equivalent_to(doc)
```

All 17+ reference files pass this test.
