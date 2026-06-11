# 014 — Fix numbering numId values in DIS style_mapping.yml [DONE]

## Problem
The numbering section of `data/iso-dis/style_mapping.yml` has incorrect numId values
that map to wrong abstract numbering definitions in the template.

From the template's numbering.xml:
- numId 3 → abstractNumId 11 (a) b) c) format — lowerLetter multilevel)
- numId 5 → abstractNumId 13 (— dash bullet multilevel)
- numId 10 → abstractNumId 6 (· single bullet — Symbol font)
- numId 1 → abstractNumId 10 (Annex %1 heading format)

Current (wrong) mapping:
```yaml
alpha_list: 6     # numId 6 → abstractNumId 13 (dash bullets, NOT alpha!)
dash_list: 10     # numId 10 → abstractNumId 6 (dot bullets, NOT dashes!)
decimal_list: 1   # numId 1 → abstractNumId 10 (Annex heading, NOT decimal!)
```

## Fix
Correct the numId values:
```yaml
alpha_list: 3     # numId 3 → abstractNumId 11 (a) b) c) multilevel)
dash_list: 5      # numId 5 → abstractNumId 13 (— dash multilevel)
decimal_list: 8   # numId 8 → abstractNumId 9 (single decimal %1.)
```

Also add `bibliography: 18` (numId 18 → abstractNumId 14 [1] format).

## Files
- `data/iso-dis/style_mapping.yml` (fix numId values)
- `spec/isodoc/docx/integration_spec.rb` (update expected numId in specs)
