# TODO 052: Fix Term Definition Whitespace — Double Space from space_before_if_needed

## Status: DONE

## What

The `space_before_if_needed` fix introduced in TODO 042 adds an unwanted extra space in term definitions. For example, `<rice>  organic...` has a double space where the reference has `<rice> organic...` (single space).

## Why

### Reference (rice.docx)
```
 121: Definition | <rice> organic and inorganic components other than whole or broken kernels
```

### Our Output
```
  92: Definition | <rice>  organic and inorganic components other than whole and broken kernels
```

Note the double space after `<rice>`.

### Root Cause

The `space_before_if_needed` method adds a space before a ParagraphBlock that's rendered inline when the preceding text doesn't end with space, tab, or colon. But the definition already has proper spacing in the presentation XML — the extra space is being injected incorrectly.

The issue is in `render_inline_element` for `ParagraphBlock`:
```ruby
when Metanorma::Document::Components::Paragraphs::ParagraphBlock
  space_before_if_needed(para)
  render_mixed_inline_fallback(element, para)
```

The ParagraphBlock in a definition has content like "organic and inorganic components..." which is preceded by inline elements like `<rice>`. The definition's mixed content model has the text after the `<rice>` element. When the ParagraphBlock (the "organic..." text) is rendered, `space_before_if_needed` sees the last run as "<rice>" (doesn't end with space/tab/colon) and adds an extra space.

But the actual presentation XML has proper spacing. The space is being added on top of existing spacing.

## Architecture

1. The `space_before_if_needed` fix is too aggressive. It should only add a space when there's genuinely no separator between label and body text (e.g., "EXAMPLE" + "Foreign seeds...").
2. Better approach: Check if the ParagraphBlock's content STARTS with a space. If so, don't add one.
3. Or: Remove `space_before_if_needed` and instead handle the specific case of note/example labels by checking if the fmt-name has a trailing delimiter.

## Files

- `lib/isodoc/iso/docx/inline.rb` — `space_before_if_needed`, `render_inline_element`

## Depends On

- None
