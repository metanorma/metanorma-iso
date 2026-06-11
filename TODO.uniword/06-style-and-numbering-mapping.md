# 06: Style & Numbering Mapping

## Summary

Define and implement the complete mapping from isodoc semantic elements to ISO DOCX template style IDs and numbering definitions.

## Motivation

The ISO template has ~80+ styles with Finnish locale names and specific styleId conventions. Every semantic element in isodoc's presentation XML must map to the correct template style for the DOCX to render correctly in Word.

## Prerequisites

- 02: ISO DOCX Template
- 03: XML-to-DOCX Adapter

## Tasks

### 1. Audit the template's full style inventory

```ruby
pkg = Uniword::DocxPackage.from_file("iso-template.docx")
pkg.styles.styles.each do |s|
  puts "#{s.id}\t#{s.name.val}\t#{s.type}\t#{s.based_on&.val}"
end
```

Document every style, its purpose, and which isodoc elements use it.

### 2. Create the complete style mapping

In `data/style_mapping.yml`:

```yaml
# Paragraph styles
title: zzSTDTitle
subtitle: zzSTDTitle
heading1: <styleId from template>
heading2: <styleId from template>
heading3: <styleId from template>
heading4: <styleId from template>
heading5: <styleId from template>
heading6: <styleId from template>
annex: ANNEX
h2annex: h2annex
h3annex: h3annex
h4annex: h4annex
h5annex: h5annex
note: note
example: example
sourcecode: sourcecode
figuretitle: figuretitle
tabletitle: tabletitle
formula: Formula
biblio: biblio
admonition: admonition
footnote_text: FootnoteText
footnote_reference: FootnoteReference
endnote_text: EndnoteText
endnote_reference: EndnoteReference
toc1: TOC1
toc2: TOC2
toc3: TOC3

# Character styles
hyperlink: Hyperlink
tablefootnoteref: tablefootnoteref
section3: section3
```

### 3. Map numbering definitions

The template's `numbering.xml` defines list numbering formats. Map:

| ISO Element | Numbering Format | Notes |
|---|---|---|
| Ordered list (decimal) | `1, 2, 3` | Arabic numbering |
| Ordered list (alpha) | `a), b), c)` | Letter with parenthesis |
| Annex clauses | `A.1, A.2` | Letter prefix |
| Bibliography | `[1], [2]` | Square bracket |
| References | `1, 2, 3` | Simple numeric |

Extract numbering definitions from template:
```ruby
pkg.numbering.numbering_definitions.each do |nd|
  puts "NumId: #{nd.id}"
  nd.levels.each do |lvl|
    puts "  Level #{lvl.ilvl}: #{lvl.number_format} '#{lvl.level_text}'"
  end
end
```

### 4. Implement the StyleResolver

A lookup class that maps XML element + context → styleId:

```ruby
module IsoDoc::Iso
  class StyleResolver
    def initialize(mapping:, template_styles:)
      @mapping = mapping
      @template_styles = template_styles
    end

    def style_for(element)
      # Check element attributes (class, type)
      # Fall back to element name mapping
      # Validate styleId exists in template
    end

    def numbering_for(element)
      # Map list type + level to numbering definition
    end
  end
end
```

### 5. Handle Finnish locale style names

The template uses Finnish names internally (Normaali, Otsikko1, etc.). The styleId is the stable identifier used in OOXML. Always use styleId for mapping, never the display name.

Verify that the template's styleIds match expectations:
```ruby
pkg.styles.styles.each do |s|
  next unless s.name.val =~ /otsikko|normaali|alaviite/i
  puts "#{s.id} (#{s.name.val})"
end
```

### 6. Test all style mappings

```ruby
describe IsoDoc::Iso::StyleResolver do
  it "maps all heading levels" do
    (1..6).each do |i|
      expect(resolver.style_for("heading#{i}")).not_to be_nil
    end
  end

  it "maps all container styles" do
    %w[note example sourcecode annex biblio].each do |el|
      expect(resolver.style_for(el)).not_to be_nil
    end
  end

  it "raises for unknown styles" do
    expect { resolver.style_for("nonexistent") }.to raise_error(/unknown style/)
  end
end
```

## Acceptance Criteria

- [ ] Complete style inventory documented
- [ ] `style_mapping.yml` covers all isodoc semantic elements
- [ ] StyleResolver maps elements to template styleIds
- [ ] Numbering definitions extracted and mapped
- [ ] All mappings validated against template (no missing styleIds)
- [ ] Test coverage for all style mappings

## Open Questions

- Should style_mapping.yml be per-flavor or shared across isodoc flavors?
- How to handle custom styles that users may add to the template?
