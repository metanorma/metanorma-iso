# TODO 02: Empty runs in styles.xml (NOT NEEDED)

## Problem
Word adds `semiHidden` element to certain styles between `uiPriority` and
`unhideWhenUsed`. Our output was reported as missing these.

## Status
Already working — template styles include `semiHidden` (191 occurrences in
generated output, matching the repaired count). This is a cosmetic Word
normalization that does NOT trigger "unreadable content" errors.

## Verification
- `grep -c 'semiHidden' word/styles.xml` matches between broken and repaired
