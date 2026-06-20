# 016 — InlineCode character styles

## Problem

DIS 15926 Era C defines **`InlineCode`** and **`InlineCodeBold`**
character styles for inline code spans (e.g., `<tt>`, `<code>`). The
adapter's `InlineRenderer` currently renders inline code as bold or
plain text, missing the dedicated character style.

## Approach

Extend `InlineRenderer` to recognize inline-code semantic classes and
emit runs with the correct `w:rStyle`.

### Model elements

In metanorma-document, inline code is typically an `Inline::Formatted`
with `type == :monospace` or an `Inline::Symbol` with `script == :code`.
Verify by inspecting the model. Possibly the model has a dedicated
`Inline::Code` class — use the actual class.

### Implementation

```ruby
class InlineRenderer
  def visit_formatted(node, run)
    case node.type
    when :monospace
      run.style = @resolver.character_style(:inline_code)
      add_text(node.content, run)
    when :strong_monospace
      run.style = @resolver.character_style(:inline_code_bold)
      add_text(node.content, run)
    # ... other types
    end
  end
end
```

If the model uses a distinct class:

```ruby
def visit(node, run)
  case node
  when Metanorma::Document::Inline::Code
    run.style = @resolver.character_style(:inline_code)
    add_text(node.content, run)
  when Metanorma::Document::Inline::CodeBold
    run.style = @resolver.character_style(:inline_code_bold)
    add_text(node.content, run)
  # ...
  end
end
```

### YAML

```yaml
character_styles:
  inline_code: InlineCode
  inline_code_bold: InlineCodeBold
```

(`inline_code: InlineCode` is already in the current mapping; just
verify `inline_code_bold` is added.)

## Files affected

- Modify: `data/iso-dis/style_mapping.yml` — add `inline_code_bold`
- Modify: `lib/isodoc/iso/docx/inline.rb` — handle code types in the
  formatted-run visitor

## Acceptance criteria

- `<tt>code</tt>` in input XML → run with `w:rStyle val="InlineCode"`.
- Bold `<tt>` → run with `w:rStyle val="InlineCodeBold"`.
- Plain text outside `<tt>` → no rStyle.

## Required specs

- `inline_renderer_spec.rb` (extend):
  - `<tt>` element → `InlineCode` run.
  - `<strong><tt>` element → `InlineCodeBold` run.
  - Real `Metanorma::Document::Inline::*` instances built from XML.
