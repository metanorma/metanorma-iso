# Fix 3: Expand mc:Ignorable to include all declared extension prefixes

## Status: DONE

## Changes
- `uniword/docx/reconciler.rb`: Changed `McIgnorable.new("w14")` to include all extension prefixes

## Specs
- "expands mc:Ignorable to include all extension prefixes" — PASS
