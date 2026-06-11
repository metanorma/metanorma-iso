# TODO 002: Hyperlink text creation bypasses Text.cast

## Status: DONE

## Problem
`Hyperlink#to_model` created `Text` objects via `Text.new(content: text)`, bypassing `Text.cast()` which handles `xml:space="preserve"` detection. This meant hyperlinks with whitespace-prefixed/suffixed text would lose proper whitespace preservation.

## Fix
Changed `hyperlink.rb:64` from `Text.new(content: text)` to `Text.cast(text)`, ensuring all Text objects go through the centralized whitespace-preserving factory method.

## Files Changed
- `uniword/lib/uniword/hyperlink.rb:64`

## Verification
- All 122 uniword docx specs pass
