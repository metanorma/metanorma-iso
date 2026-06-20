# 006 — StyleResolver strict mode

## Problem

`StyleResolver#paragraph_style` returns `nil` when the YAML doesn't have
a key. This invites fallback chains at every call site
(`adapter.rb:408`, `:411`, `style_resolver.rb:48`, `:66`, `:74`,
`toc_builder.rb:249`). Fallback chains:

1. Hide data errors (typo in YAML key silently falls through).
2. Couple Ruby code to YAML structure (the adapter knows which YAML keys
   exist as fallbacks).
3. Violate MECE — every semantic concept should have exactly one
   canonical style mapping.

## Approach

Change `StyleResolver` to be strict by default. Add a typed exception
that callers can rescue if they genuinely want optional behavior:

```ruby
module IsoDoc::Iso::Docx
  class UnknownStyleError < StandardError
    attr_reader :key, :context

    def initialize(key, context = nil)
      @key = key
      @context = context
      super("No DOCX style mapping for #{key.inspect}#{context_desc}")
    end

    private

    def context_desc
      @context ? " (in #{@context})" : ""
    end
  end

  class StyleResolver
    def paragraph_style(key)
      @mapping.paragraph_style(key) or
        raise UnknownStyleError.new(key, current_context_desc)
    end

    def character_style(key)
      @mapping.character_style(key) or
        raise UnknownStyleError.new(key, current_context_desc)
    end

    # ... all other methods follow the same pattern
  end
end
```

The `current_context_desc` is a private helper that returns a string
like `"annex note, depth=3"` from `@context`, so the error message tells
the developer exactly which dispatch failed.

### Optional styles (true opt-in)

For the rare cases where a style is genuinely optional (e.g., some
templates lack `figure_title_annex`), provide an explicit opt-in:

```ruby
def paragraph_style_or_nil(key)
  @mapping.paragraph_style(key)
end
```

Callers using `paragraph_style_or_nil` must explicitly opt in — no
silent nil return from the default method.

## Files affected

- Create: `lib/isodoc/iso/docx/errors.rb` — defines `UnknownStyleError`
- Modify: `lib/isodoc/iso/docx/style_resolver.rb` — strict by default,
  add `*_or_nil` variants
- Modify: `lib/isodoc/iso/docx.rb` — autoload `:Errors`

## Acceptance criteria

- `StyleResolver#paragraph_style(:unknown)` raises `UnknownStyleError`.
- `StyleResolver#paragraph_style_or_nil(:unknown)` returns `nil`.
- Existing fallback chains in adapter/style_resolver/toc_builder break
  loudly — TODO 007 fixes them.
- Error message includes the context (e.g., "in annex note, depth=3").

## Required specs

- `style_resolver_spec.rb`:
  - `paragraph_style(:heading1)` returns "Heading1".
  - `paragraph_style(:nonexistent)` raises `UnknownStyleError` with
    matching message.
  - `paragraph_style_or_nil(:nonexistent)` returns nil.
  - Context appears in error message when context zone is set.
  - No use of `respond_to?`, `send`, or instance_variable_get in code.
