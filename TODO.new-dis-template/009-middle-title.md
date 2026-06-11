# TODO 009: Implement Middle Title (Repeated Full Title)

## Status: COMPLETE

## What

Render the "middle title" — the full document title repeated between front matter and body clauses, using `MainTitle1` and `MainTitle2` styles.

## Why

The reference DOCX repeats the full document title between the Introduction and Scope, using:
- `MainTitle1` — intro title + main title (e.g., "Industrial automation systems and integration — Integration of life-cycle data...")
- `MainTitle2` — complement (e.g., "Part 100: Vocabulary")

This is a standard ISO layout requirement — the title appears on the first body page.

## Architecture

After rendering the Introduction (end of front matter), before rendering Scope (start of body), insert:

```ruby
def render_middle_title(model, doc)
  para1 = doc.create_paragraph
  para1.style = @resolver.paragraph_style(:main_title1)
  para1 << full_intro_main_title(model)
  doc << para1

  para2 = doc.create_paragraph
  para2.style = @resolver.paragraph_style(:main_title2)
  para2 << complement_title(model)
  doc << para2
end
```

### Section Break

The middle title should be the first content in Section 3 (body). This means the section break between front matter and body goes right before the middle title paragraphs.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — middle title rendering

## Depends On

- TODO 004 (section layout — section break before middle title)
- TODO 005 (style mapping for MainTitle1/MainTitle2)
