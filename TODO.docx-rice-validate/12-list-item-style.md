# 12: List item style is wrong

## Status: PENDING

## Symptom

Bulleted list items (e.g. in foreword, terms intro) use a style
that doesn't match the reference. The bullets appear with wrong
indentation / wrong bullet character / wrong paragraph style.

## Fix

Investigate UnorderedListRenderer and the style it assigns to list
item paragraphs. Check the style mapping YAML for `:list_paragraph`
and `:list_continue_1` to ensure they map to the correct DIS
template style.
