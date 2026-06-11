# TODO 14: Missing semiHidden on one style (COSMETIC)

## Problem
One style in styles.xml is missing `<w:semiHidden/>` compared to the repaired
output. Word adds this during repair.

## Status
DONE. Reconciler's `ensure_default_styles` now checks for and adds semiHidden
on DefaultParagraphFont even when the style comes from a template.

## Fix Location
- **Uniword reconciler** (`reconciler.rb`): `ensure_default_styles` adds semiHidden
