# 17 - Transformer: Back Matter (Annexes, Bibliography, Index)

## Mapping: annex + bibliography → Sts::IsoSts::Back

### Back Structure

```xml
<back>
  <app-group>
    <app id="sec_A">
      <label>Annex A</label>
      <title>(normative/informative) Title</title>
      <!-- same content model as sec -->
    </app>
    <app id="sec_B">...</app>
  </app-group>

  <ref-list content-type="bibl">
    <title>Bibliography</title>
    <ref id="biblref_1">
      <label>[1]</label>
      <mixed-citation>...</mixed-citation>
      <std>...</std>
    </ref>
  </ref-list>

  <sec sec-type="index" id="sec_index">
    <!-- index entries -->
  </sec>
</back>
```

## Annex Transformer

### Source → Target
```
IsoAnnexSection → Sts::IsoSts::App
```

### Mapping

```
annex.id       → App.id = "sec_{annex_letter}" (e.g., "sec_A")
annex.number   → App.label content (e.g., "Annex A")
annex.obligation → reflected in label: "Annex A" (normative) or "Annex A (informative)"
annex.title    → App.title
annex.clause   → App.sec (nested, via SectionTransformer)
annex.paragraphs → App.paragraph
annex.tables   → App.table_wrap
annex.figures  → App.fig
annex.lists    → App.list
annex.examples → App.non_normative_example
annex.notes    → App.non_normative_note
annex.formulas → App.disp_formula
annex.appendix → App.sec (appendix within annex)
```

### Annex ID Scheme
```
App.id = "sec_{section}" where section = A, B, C...
Nested sec.id = "sec_{section}.{n}" (e.g., "sec_A.1")
```

### Annex Content Model
App has the same content model as Sec — all block-level elements are valid children.

## Bibliography Transformer

### Source → Target
```
bibliography/references[not(@normative)] → Sts::IsoSts::RefList
```

### Mapping

```
references.id  → RefList.id = "sec_bibl"
references/@normative=false → RefList.content_type = "bibl"
references.title → RefList.title
bibitem       → Ref (each)
  bibitem.@anchor → Ref.id = "biblref_{section}"
  bibitem formatted ref → Ref.mixed_citation
  bibitem docidentifier → Ref.std / Ref.std-ref
```

### Bibliography Item (ref)

```xml
<ref id="biblref_1">
  <label>[1]</label>
  <mixed-citation>ISO 8601-1:2019, <italic>Date and time</italic></mixed-citation>
  <std>
    <std-ref>ISO 8601-1:2019</std-ref>
  </std>
</ref>
```

### mixed-citation Construction

The `mixed-citation` contains the formatted bibliographic reference with inline markup:
- Title in `<italic>`
- Document identifier in `<std-ref>` wrapped in `<std>`
- For standards: `<std>@type` = "dated" or "undated"
- For non-standard references: plain `<mixed-citation>` without `<std>`

### Bibliography in Annexes

References within annexes also appear as `ref-list` inside the annex `app` element, not in the back `ref-list`.

## Index Transformer

### Source → Target
```
indexsect → Sts::IsoSts::Sec[@sec-type='index']
```

Index sections map to a simple sec with sec-type="index":
```xml
<sec sec-type="index" id="sec_index">
  <title>Index</title>
  <!-- index terms -->
</sec>
```

## Footnote Groups in Back

Collected footnotes may appear in `<fn-group>` in back matter:
```xml
<fn-group>
  <fn id="fn_1">
    <label><sup>1)</sup></label>
    <p>Footnote text</p>
  </fn>
</fn-group>
```

See `18-transformer-footnotes.md` for the footnote collection/deduplication algorithm.
