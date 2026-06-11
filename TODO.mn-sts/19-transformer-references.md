# 19 - Transformer: References (Bibliographic Items)

## Mapping: bibitem → ref (inside ref-list)

References appear in two contexts:
1. **Normative references** — in `<body>` as `<ref-list content-type="norm-refs">`
2. **Informative references** (Bibliography) — in `<back>` as `<ref-list content-type="bibl">`

## Normative References

### Source
```xml
<bibliography/references[@normative='true']>
  <bibitem id="ISO8601-1" type="standard">
    <docidentifier type="ISO">ISO 8601-1:2019</docidentifier>
    <title>...</title>
    <contributor>...</contributor>
  </bibitem>
</references>
```

### Target
```xml
<ref-list content-type="norm-refs">
  <title>Normative references</title>
  <p>The following documents are referred to in the text in such a way that some or all of their content
  constitutes requirements of this document. For dated references, only the edition cited applies.
  For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
  <ref id="biblref_1">
    <label>[1]</label>
    <mixed-citation>ISO 8601-1:2019, <italic>Date and time — Representations for information interchange — Part 1: Basic rules</italic></mixed-citation>
    <std>
      <std-ref type="dated">ISO 8601-1:2019</std-ref>
    </std>
  </ref>
</ref-list>
```

### Boilerplate Text
The first normative reference section includes boilerplate text about dated/undated references. This text varies by language:
- EN: "The following documents are referred to in the text..."
- FR: "Les documents suivants sont cités dans le texte..."
- RU: "Следующие документы цитируются в тексте..."

This boilerplate comes from the Metanorma XML `boilerplate` section.

## Bibliographic Item (ref) Construction

### mixed-citation Content

The `mixed-citation` contains the formatted reference with inline markup:

```
{docidentifier}, {title in italic}, {edition info}, {other info}
```

For standard references:
```xml
<mixed-citation>ISO 8601-1:2019, <italic>Date and time</italic></mixed-citation>
<std>
  <std-ref type="dated">ISO 8601-1:2019</std-ref>
  <std-ref type="undated">ISO 8601-1</std-ref>
</std>
```

For non-standard references:
```xml
<mixed-citation>Author, <italic>Title</italic>, Publisher, Year</mixed-citation>
```

### std-ref Construction

From `bibitem`:
```
docidentifier[@type='ISO'] → std-ref[@type='dated']  (e.g., "ISO 8601-1:2019")
docidentifier (strip year) → std-ref[@type='undated'] (e.g., "ISO 8601-1")
```

### Fields Omitted in STS

The following `bibitem` children are NOT output in STS (from mn2xml.xsl):
- `docidentifier` (handled via std-ref)
- `docnumber` (handled via std-ref)
- `language` (not needed)
- `script` (not needed)
- `edition` (for standard-type bibitems)
- `copyright` (not needed)
- `relation` (not needed)

## Reference ID Scheme

```
ref/@id = "biblref_{section}" (e.g., "biblref_1", "biblref_2")
label = "[{section}]" (e.g., "[1]", "[2]")
```

## Reference Numbering

References are numbered sequentially starting from 1. The numbering must match the order they appear in the source.

## References Within Annexes

Annexes can contain their own bibliographic references. These appear as `ref-list` inside the `app` element, not in the back matter:

```xml
<app id="sec_A">
  ...
  <ref-list content-type="bibl">
    <ref id="biblref_A1">...</ref>
  </ref-list>
</app>
```

## Unpublished References

References marked as unpublished get a special footnote:
```xml
<ref id="biblref_3">
  <mixed-citation>...</mixed-citation>
  <note type="Unpublished-Status">...</note>
</ref>
```

In the body, the `eref` pointing to this reference gets a footnote marker appended.

## Non-ISO/IEC Normative References

When a normative reference is not from ISO or IEC, a warning note is generated:
```xml
<std originator="ANSI" std-id="ANSI T1.102" type="dated">
  <std-ref>ANSI T1.102</std-ref>
</std>
```
