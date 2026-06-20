---
title: BUG 020 - Section title concatenated with first paragraph
priority: P2
status: closed
---

# BUG 020: Section Title Concatenated With First Paragraph

## Symptom

Some section headings have the title text run directly together with
the first body paragraph's text, with no paragraph break:

```
3.2.1    4.2.1
The mass fraction of moisture, determined in accordance with ISO 712:2009,
```

Notice "4.2.1" with no title text and the body paragraph immediately
following. The title text appears to be empty in these cases.

## Root Cause

For sub-clauses whose source `<fmt-title>` only contains a section
number (no title text), the adapter still emits a heading paragraph
but with no title text. The next paragraph then runs immediately
after.

The actual case here: the source has a clause whose title is empty
(an untitled sub-clause, common in some test method specs):

```xml
<clause id="...">
  <fmt-title depth="3">
    <span class="fmt-caption-label"><semx>3</semx>.<semx>2</semx>.<semx>1</semx></span>
    <span class="fmt-caption-delim"><tab/></span>
    <!-- No <semx element="title"> here -->
  </fmt-title>
  <p>The mass fraction of moisture...</p>
</clause>
```

## Fix

Two options:

1. **Skip empty headings.** If the title has no text content (only
   autonum + delim), don't emit a heading paragraph at all. The body
   paragraph follows directly. This is the typical ISO behavior for
   untitled sub-clauses.

2. **Render the number alone.** If the style auto-numbers, an empty
   heading is fine — Word will render the number from the style. The
   paragraph break still happens. But the user sees "3.2.1" alone
   which may not be what's wanted.

Recommended: option 1 (skip empty headings entirely), matching the
reference DOCX behavior.

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` `render_section_title` — return
  without emitting if title has no text content after stripping
  autonum + delim

## Verification

After fix, untitled sub-clauses should produce just the body
paragraphs with the heading numbering visible via the parent clause's
structure.
