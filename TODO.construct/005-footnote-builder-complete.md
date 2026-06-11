# 005: FootnoteBuilder Uses Allocator + Creates Separators at Init

## Problem

Two issues in `FootnoteBuilder`:

1. **Local counter** (line 63-68): `@footnote_counter` starts at 1, independent from allocator. When editing a template with existing footnotes, new IDs collide.

2. **Missing separators**: FootnoteBuilder never creates the required separator (id=-1) and continuationSeparator (id=0) entries. The reconciler's `ensure_separators` in `notes.rb` (line 125-139) always adds these. This means footnotes.xml is ALWAYS incomplete until reconciler fixes it.

## Approach

### 1. Accept allocator in constructor

```ruby
class FootnoteBuilder
  def initialize(document, allocator: nil)
    @document = document
    @allocator = allocator
    ensure_notes_parts_exist
  end

  def next_footnote_id
    @allocator&.alloc_footnote_id || begin
      @footnote_counter ||= 1
      id = @footnote_counter
      @footnote_counter += 1
      id
    end
  end
```

### 2. Create separators when footnotes part is first created

```ruby
private

def ensure_notes_parts_exist
  # Only add separators when creating a fresh footnotes collection
  # (not when loading from template — those already have separators)
  return if footnotes.footnote_entries.any?

  footnotes.footnote_entries.unshift(
    Wordprocessingml::Footnote.new(
      id: "-1", type: "separator",
      paragraphs: [separator_paragraph(:separator)]
    ),
    Wordprocessingml::Footnote.new(
      id: "0", type: "continuationSeparator",
      paragraphs: [separator_paragraph(:continuation)]
    )
  )
end

def separator_paragraph(kind)
  sep_attr = kind == :separator ? :separator_char : :continuation_separator_char
  sep_class = kind == :separator ? Wordprocessingml::SeparatorChar : Wordprocessingml::ContinuationSeparatorChar
  sep_run = Wordprocessingml::Run.new(sep_attr => sep_class.new)
  Wordprocessingml::Paragraph.new(runs: [sep_run])
end
```

### 3. Same pattern for endnotes

Mirror the approach for `endnotes` / `next_endnote_id`.

## Files

- **Modify**: `lib/uniword/builder/footnote_builder.rb`

## Acceptance

- First footnote in a new document gets id=1 (after separators at id=-1 and id=0)
- Separators are present from the start — no reconciler fix needed
- Editing a template with existing footnotes: new IDs continue from template max
- `bundle exec rspec` passes

## Dependencies

- [[001-id-allocator]]
- [[003-document-builder-allocator]]
