# TODO 040: Use `normref` Style for Normative Reference Entries

## Status: DONE

## What

Normative reference entries use `BodyText` style but should use `normref` style. The reference output uses `normref` for each ISO reference entry.

## Why

### Current

```
BodyText: ISO 712 (all parts)
BodyText: ISO 6646 (all parts)
```

### Expected (Reference)

```
normref: ISO 712:2009) , Cereals and cereal products — Determination of moisture...
normref: ISO 6646:2011, Rice — Determination of the potential milling yield...
```

### Key Differences

1. **Style**: `normref` not `BodyText`
2. **Full bibliographic text**: Reference includes full title, not just the identifier
3. **Formatting**: includes closing parenthesis, full title text

## Architecture

When `@context.in_normative` is true and we're rendering normative reference entries, use `normref` style. The reference entries should include the full formatted reference text (identifier + title).

## Files

- `lib/isodoc/iso/docx/adapter.rb` — normative references rendering

## Depends On

- None
