# 12 - Transformer: Front (Metadata)

## Mapping: Metanorma XML bibdata → Sts::IsoSts::Front

The `front` element contains document metadata. There are three possible metadata blocks:
- `iso-meta`: Used for ISO/IEC documents (default for ISO)
- `nat-meta`: Used for national adoptions (BSI, etc.)
- `reg-meta`: Used for regional adoptions (CEN, CENELEC)

For ISO documents, we always generate `iso-meta`.

## Source: `Metanorma::IsoDocument::Metadata::IsoBibliographicItem`

Key attributes:
- `title` → collection of `IsoLocalizedTitle` (with `title-intro`, `title-main`, `title-part`)
- `language`, `script`
- `status` → stage/substage/iteration
- `docidentifier` → collection of document identifiers
- `copyright` → year, owner
- `contributor` → organizations (publisher, author, authorizer)
- `relation` → adopted-from, obsoletes, etc.
- `ext` → doctype, flavor, stagename, editorial_group, ics

## Target: `Sts::IsoSts::IsoMeta`

### Title Mapping

```
Metanorma::IsoDocument::Metadata::IsoLocalizedTitle → Sts::IsoSts::TitleWrap
  title-intro → title-wrap/intro
  title-main  → title-wrap/main
  title-part  → title-wrap/compl
  (combined)  → title-wrap/full
```

One `title-wrap` per language (en, fr, ru). The `@xml:lang` attribute carries the language.

### Document Identification Mapping

```
bibdata → doc-ident
  copyright/owner/organization/abbreviation → sdo
  structured_identifier/project_number → proj-id (digits only)
  language → language
  stage abbreviation → release-version (e.g., "FDIS", "DIS", "IS")
  docidentifier[type='URN'] → urn
```

### Standard Identification Mapping

```
bibdata → std-ident
  contributor[publisher]/organization/abbreviation → originator
  doctype → doc-type (international-standard → IS, technical-specification → TS, etc.)
  docnumber → doc-number
  part number from structured_identifier → part-number
  edition → edition
  version → version (usually "1")
```

### Doc Type Abbreviations (from mn2xml.xsl)

| Metanorma doctype | STS doc-type |
|--------------------|-------------|
| `international-standard` | `IS` |
| `technical-specification` | `TS` |
| `technical-report` | `TR` |
| `publicly-available-specification` | `PAS` |
| `international-workshop-agreement` | `IWA` |
| `guide` | `GUIDE` |
| `amendment` | `Amd` |
| `technical-corrigendum` | `TCor` |
| `committee-document` | `CD` |

### Standard Reference Mapping

```
bibdata → std-ref
  docidentifier[type='ISO'] → std-ref[@type='dated'] (with year)
  docidentifier (stripped year) → std-ref[@type='undated']
```

### Other Front Elements

```
bibdata → doc-ref        "{originator} {doc-number}(language)"
bibdata/copyright → permissions
  copyright-statement → "All rights reserved" (fixed for ISO)
  copyright/year → copyright-year
  copyright/owner/abbreviation → copyright-holder
bibdata/ext/editorial_group → comm-ref (e.g., "ISO/TC 154")
bibdata/ext/editorial_group/secretariat → secretariat
bibdata/ext/ics → ics (e.g., "01.140.30")
bibdata/date[type='published'] → pub-date
bibdata/date[type='released'] → release-date
bibdata/relation[@type='revises'] → std-xref[@type='revises']/std-ref
```

## Preface → front/sec

Prefatory sections are placed as `<sec>` inside `<front>`:

```
preface/foreword → sec[@sec-type='foreword']
preface/introduction → sec[@sec-type='intro'] (only when not in body)
preface/clause[@type='front_notes'] → sec[@sec-type='front_notes']
preface/abstract → sec[@sec-type='abstract']
preface/clause (other) → sec (generic)
```

## Transformer Class

```ruby
class FrontTransformer < Base
  def transform(source)
    front = Sts::IsoSts::Front.new
    front.iso_meta = IsoMetaTransformer.new(@context).transform(source.bibdata)
    # If adopted-from relation exists, also generate reg-meta
    front.sec = transform_preface_sections(source)
    front
  end

  private

  def transform_preface_sections(source)
    sections = []
    if source.preface
      sections << transform_foreword(source.preface.foreword) if source.preface.foreword
      sections << transform_introduction(source.preface.introduction) if source.preface.introduction
      # ... other preface clauses
    end
    sections.compact
  end
end
```
