# 14 - Transformer: Terminology (Terms)

## Mapping: IsoTerm → tbx:termEntry (inside term-sec)

This is the most complex transformation. ISO terminology uses the TBX (Terminology Markup Exchange) format embedded within `term-sec` elements.

## Structure Mapping

```
IsoTerm
├── IsoTerm → <term-sec id="sec_{section}">
│   ├── label (section number)
│   └── <tbx:termEntry id="term_{section}">
│       └── <tbx:langSet xml:lang="{language}">
│           ├── <tbx:subjectField> (from domain)
│           ├── <tbx:definition> (from definition)
│           ├── <tbx:example> (from termexample, each)
│           ├── <tbx:note> (from termnote, each)
│           ├── <tbx:source> (from termsource)
│           ├── <tbx:tig> (from preferred, each)
│           ├── <tbx:tig> (from admitted, each)
│           └── <tbx:tig> (from deprecates, each)
```

## Term Section ID Scheme

```
term-sec/@id       → "sec_{section}"  (e.g., "sec_3.1")
termEntry/@id      → "term_{section}" (e.g., "term_3.1")
```

## tbx:definition

The definition content is transformed inline. Lists following the definition are pulled in:

```xml
<!-- Source -->
<definition><verbal-definition><p>...text...</p></verbal-definition></definition>
<ul><li>...</li></ul>

<!-- Target -->
<tbx:definition>...text...<list ...>...</list></tbx:definition>
```

## tbx:tig (Term Information Group)

Each `preferred`, `admitted`, or `deprecates` element maps to a `tbx:tig`:

```
preferred/admitted/deprecates
├── name/expression[1] → <tbx:term>text content</tbx:term>
├── grammar attributes → <tbx:partOfSpeech value="noun|adj|verb|adv"/>
├── normative status    → <tbx:normativeAuthorization value="preferredTerm|admittedTerm|deprecatedTerm"/>
├── type/letter-symbol  → <tbx:termType value="acronym|abbreviation|fullForm|symbol|formula|equation"/>
└── field-of-application → <tbx:usageNote>text</tbx:usageNote>
```

### partOfSpeech Rules

| Grammar attribute | Value |
|-------------------|-------|
| `isAdjective=true` | `adj` |
| `isAdverb=true` | `adv` |
| `isNoun=true` | `noun` |
| `isVerb=true` | `verb` |
| (default) | `noun` |

### termType Rules

| Source condition | Value |
|-----------------|-------|
| `letter-symbol = 'symbol'` | `symbol` |
| `letter-symbol = 'formula'` | `formula` |
| `abbreviation-type = 'acronym'` | `acronym` |
| `expression/@type = 'abbreviation'` | `abbreviation` |
| `expression/@type = 'full'` (for ISO/IEC) | `fullForm` |
| `@type = 'full'` | `variant` |
| (other) | value of `@type` |

### normativeAuthorization Rules

For ISO: omit `normativeAuthorization` when the term is `preferred` and has no `admitted` or `deprecates` siblings. Otherwise:
- `preferred` → `preferredTerm`
- `admitted` → `admittedTerm`
- `deprecates` → `deprecatedTerm`

## tbx:see (See References)

When a `termnote` matches the pattern "See X for more information.", it is converted to `<tbx:see>`:
- If content is a single xref: `<tbx:see target="{xref/@rid}"/>`
- Otherwise: `<tbx:see>content</tbx:see>` (with prefix/suffix stripped)

## tbx:source (Term Sources)

For ISO: `<tbx:source>` contains just text (no nested `std` element).
For IEC: `<tbx:source>` can contain nested elements.

## tbx:entailedTerm

Cross-references to other terms within term entries use `<tbx:entailedTerm>`:
```xml
<!-- Pattern: <em>term name</em> (<xref target="term_3.8">3.8</xref>) -->
<tbx:entailedTerm target="term_3.8">term name (3.8)</tbx:entailedTerm>
```

Also from `<concept>` elements with `<eref>`:
```xml
<concept><eref bibitemid="..."/><renderterm>...</renderterm></concept>
→ <tbx:entailedTerm xtarget="...">renderterm text</tbx:entailedTerm>
```

## Nested Terms

Terms can contain sub-terms (`term` within `term`). These become nested `term-sec` within the parent `term-sec`.

## Transformer Class

```ruby
class TermsSectionTransformer < Base
  def transform(terms_section)
    terms_section.term.map do |term|
      transform_term(term, terms_section)
    end
  end

  private

  def transform_term(term, parent_section)
    section = section_number_for(term)
    term_sec = Sts::IsoSts::TermSec.new
    term_sec.id = "sec_#{section}"

    term_sec.label = Sts::IsoSts::Label.new(content: section)

    term_sec.term_entry = build_term_entry(term, section)

    # Nested sub-terms
    term_sec.term_sec = term.term.map { |t| transform_term(t, parent_section) } if term.term.any?

    term_sec
  end

  def build_term_entry(term, section)
    entry = Sts::TbxIsoTml::TermEntry.new(id: "term_#{section}")
    lang_set = build_lang_set(term)
    entry.lang_set = lang_set  # or collection if multi-language
    entry
  end
end
```
