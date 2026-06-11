# 019 — Fix mailto: hyperlink text duplication

## Status: FIXED

The `render_link` method now strips `mailto:` prefix from display text when
the link has no content.

## Fix
`lib/isodoc/iso/docx/inline.rb` line 272: added `text.sub(/\Amailto:/, "")`
when text is derived from the target URL.
