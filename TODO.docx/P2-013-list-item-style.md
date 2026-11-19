# 12: List item style is wrong

## Status: DONE

## Symptom

Bulleted list items (e.g. in foreword, terms intro) use a style
that doesn't match the reference. The bullets appear with wrong
indentation / wrong bullet character / wrong paragraph style.

## Fix

Investigate UnorderedListRenderer and the style it assigns to list
item paragraphs. Check the style mapping YAML for `:list_paragraph`
and `:list_continue_1` to ensure they map to the correct DIS
template style.

## Proof (2026-11-19)

Already fixed by #1798 (ListContinue1..4 / ListNumber1..4 by depth) and
#1808 (ordered list numbering). On origin/grind/1609 (19c1878f), converting
`spec/examples/rice.presentation.xml` yields 12 top-level bullet paragraphs,
all `ListContinue1`, numId 3 (dash), ilvl 0, matching REF-001 row
"bullet / — / ListContinue1 / 3". `list_paragraph` maps to BodyText but no
list item uses it. Pinned by the rice example in
`spec/isodoc/docx/renderers/unordered_list_renderer_spec.rb`.
