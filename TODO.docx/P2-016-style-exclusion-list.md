# 003 — Add excluded_styles block to style_mapping.yml

## Problem

`BUGS.gen/021-iso-template-style-audit.md` identified 154 styles that
exist only in the 8601-era (pre-Typefi) template, plus 500 single-doc-only
pollution styles (Word auto-injected, OGC pipeline, German-locale Word,
Chinese-Word, etc.). Without an explicit exclusion list, future edits to
`style_mapping.yml` could accidentally re-introduce these.

## Approach

Add an `excluded_styles` block to `style_mapping.yml`:

```yaml
excluded_styles:
  # 8601-era (pre-Typefi) semantic families — lowercase prefixed IDs
  era_8601_lower:
    - bib*            # 50 bib* styles (bibyear, bibarticle, ...)
    - au*             # 12 au* styles (aufname, ausurname, ...)
    - cite*           # 14 cite* styles (citefig, citetbl, ...)
    - std*            # 10 std* styles (stdpublisher, stdyear, ...)
    - coverpage-*     # 10 coverpage-* styles
    - boilerplate-*   # 2 boilerplate-* styles
    # bare lowercase content styles
    - note
    - example
    - figuretitle
    - tabletitle
    - sourcecode
    - stem
    - stem1
    - normref
    - pseudocode
    - sourcetitle
    - sourcecode1
    - zzwarning
    - zzwarninghdr

  # 8601-era CamelCase extras (only in 8601 docs, never in Era C)
  era_8601_camel:
    - AdmittedTerm
    - AltTerms
    - DeprecatedTerms
    - AMENDHeading1Unnumbered
    - BlockText
    - CommentSubject
    - CommentSubjectChar
    - CommentText
    - CommentTextChar
    - FollowedHyperlink
    - HTMLPreformatted
    - HTMLPreformattedChar
    - ListParagraph
    - NormalIndent
    - NormalWeb
    - PlaceholderText
    - TableGrid
    - TableISO
    - UnresolvedMention

  # Word built-in table-style zoo — auto-injected
  word_builtin_tables:
    - GridTable*
    - ColorfulGrid*
    - ColorfulList*
    - ColorfulShading*
    - DarkList*
    - LightGrid*
    - LightList*
    - LightShading*
    - ListTable*
    - MediumGrid*
    - MediumList*
    - MediumShading*
    - PlainTable*
    - Table3Deffects*
    - TableClassic*
    - TableColorful*
    - TableColumns*
    - TableGrid*
    - TableGridLight*
    - TableList*
    - TableSimple*
    - TableSubtle*
    - TableWeb*
    - TableContemporary
    - TableElegant
    - TableProfessional
    - TableTheme
    - TableContents
    - TableFormula
    - "*-Accent[1-6]"
    - "*Char"        # auto-linked character styles
    - "*Char[0-9]+"  # numeric-suffixed character dupes

  # Locale-specific auto-styles (German/Chinese Word)
  locale_pollution:
    - Code-einrck
    - HTMLSchreibmaschine*
    - HTMLZitat
    - Listennummer*
    - StdAbsatz-*
    # Chinese Word numeric IDs
    - "[0-9]+"       # bare numeric styleId (e.g. 21103, 24341, 26631)
    # Chinese Word *1 collision suffixes
    - Heading[1-6]1
    - Heading[1-6]Char1
    - h[2-5]annex1
    - h[2-5]annexChar
    - BodyTextIndent[0-9]+
    - BodyTextindent[0-9]+

  # Word co-authoring / Yammer noise
  collaboration:
    - Hashtag*
    - Mention*
    - SmartHyperlink*
    - UnresolvedMention*
    - BalloonText*
```

The list is matched by glob (using `File.fnmatch?` with `FNM_PATHNAME`
disabled, `FNM_EXTGLOB` enabled where available). The patterns are
intentionally simple globs, not regexes, to keep review easy.

## Files affected

- Modify: `data/iso-dis/style_mapping.yml`
- Modify: `lib/isodoc/iso/docx_style_mapping.rb` (load `excluded_styles`)
- Modify: `lib/isodoc/iso/docx/style_resolver.rb` (no behavior change,
  just awareness)
- Create: `lib/isodoc/iso/docx/style_mapping_validator.rb` (TODO 005 uses it)

## Public API

```ruby
class DocxStyleMapping
  def excluded_styles  # array of glob patterns
  end

  def excluded?(style_id)  # boolean — matches against globs
  end
end

class StyleMappingValidator
  def excluded_styles_in_mapping  # array of mapped styles that match exclusion
  end
end
```

## Acceptance criteria

- `DocxStyleMapping#excluded?` returns `true` for at least one example
  from each category (e.g., `bibyear`, `AdmittedTerm`, `GridTable1Light`,
  `Code-einrck`, `21103`, `Mention1`).
- `StyleMappingValidator#excluded_styles_in_mapping` returns empty array
  for the corrected `style_mapping.yml`.
- `style_mapping.yml` header gains:
  ```yaml
  excluded_styles_ref: BUGS.gen/021-iso-template-style-audit.md
  ```

## Required specs

- `style_mapping_validator_spec.rb`:
  - Each pattern matches expected sample.
  - No value in `paragraph_styles` / `character_styles` matches an
    excluded pattern.
