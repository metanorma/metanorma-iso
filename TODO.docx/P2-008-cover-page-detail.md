# 074: Cover page structure — wrong paragraphs, missing elements

## Problem
The cover page has wrong paragraph structure compared to reference. Multiple differences:

### Missing from output:
1. **Standalone doc number** "17301" — reference para 1
2. **Full doc ID** "ISO/CD 17301-1 (draft 2016-05-01)" — reference para 2
3. **TC/SC info** "TC 34/SC 4/WG 3" — reference para 3
4. **Stage badge** "CD stage" — reference para 8

### Wrong in output:
1. **Doc ID** — output has "ISO/CD 17301-1:2016" (includes year, reference doesn't)
2. **Edition** — output has "2nd edition" (numeric), reference has "Second edition" (spelled out)
3. **Title split** — output has title in 2 paras (title_main + title_part), reference has in 1 para with em-dash

### Reference cover sequence (19 paras before sectPr):
```
1. "17301 "                         (standalone doc number, no style)
2. "ISO/CD 17301-1 (draft 2016-05-01) " (full ID)
3. "TC 34/SC 4/WG 3 "              (committee info)
4. "Second edition "                (spelled-out edition)
5. "Date: 2016-05-01 "              (date)
6. "Cereals and pulses — Specifications and test methods — Part 1: Rice" (full title)
7. ""                               (blank)
8. "CD stage"                       (stage badge)
9. ""                               (blank)
10. "Warning for WDs and CDs"       (warning title)
11-13. Warning body paragraphs
14. "" (blank)
15. "© ISO 2016"
16. "All rights reserved..."
17. "ISO copyright office CP 401... Published in Switzerland" (ONE consolidated line)
18. "" (blank)
19. "" + [SECTPR]                   (section break)
```

### Output cover sequence:
```
1. "ISO/CD 17301-1:2016"           (wrong format)
2. "2nd edition"                    (numeric instead of spelled-out)
3. ""                               (blank)
4. "Date: 2016-05-01"
5. "Cereals and pulses — Specifications and test methods"  (title part 1 only)
6. "Part 1: Rice"                   (title part 2 only)
7. "" (blank)
8. Warning title/body
9-10. Warning body
11. "© ISO 2016"
12. "All rights reserved..."
13. "ISO copyright office"          (split into 5 lines)
14. "CP 401 • Ch. de Blandonnet 8"
15. "CH-1214 Vernier, Geneva"
16. "Phone: +41 22 749 01 11"
17. "Email:"
18. "Website: www.iso.org"
19. "Published in Switzerland"
20. "" + [SECTPR]
```

## Fix
1. Add standalone doc number paragraph (extract number from doc ID)
2. Add full doc ID paragraph (with "(draft date)" format)
3. Add TC/SC info paragraph (from `extract_committee`)
4. Fix edition to be spelled out ("Second" not "2nd")
5. Add stage badge paragraph
6. Keep title as single paragraph with em-dash
7. Consolidate copyright address into single line

## Location
- `lib/isodoc/iso/docx/adapter.rb` — `render_cover`, `render_copyright_block`, `extract_edition_text`

## Status (2026-11-20): DONE

Measured by converting a stage-30 (CD) presentation XML built from `spec/examples/rice.adoc` with the iso-simple template (the one stages below 40 select).

Cover paragraphs 0-12 (13 paragraphs, then the cover sectPr paragraph at 13) match the reference CD structure: `17301`, `ISO/CD 17301-1 (draft 2016-05-01)`, `TC 34/SC 4/WG 3`, `Second edition`, `Date: 2016-05-01`, one em-dash title paragraph, blank, `CD stage`, blank, `zzwarninghdr` (1), `zzwarning` (2), unstyled U+00A0 spacer. The copyright block (`zzCopyright`) starts after the cover sectPr.

- Compact cover: `CoverRenderer`, spec `cover_renderer_spec.rb` "compact cover for stages before DIS".
- Warning styles: `zzwarninghdr`/`zzwarning` in the iso-simple template (template.dotx, styles.yml, style_mapping.yml `warning_header`/`warning`). The iso-dis template has no such styles; DIS keeps Notice.
- Spacer: `BoilerplateRenderer#render_license` appends one nbsp paragraph after a license statement (none when there is no statement). Spec: boilerplate_renderer_spec.rb "#render_license on the simple (WD/CD) template" (4 examples; removing the spacer line turns the spacer example red).
- Copyright address consolidation is P1-005 (DONE).
