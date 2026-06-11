# TODO 03: Missing numbering.xml attributes (tplc) (DONE)

## Problem
Word adds `tplc` (template list code) attributes to `<w:lvl>` elements during
repair. Our output was missing these because the Level model didn't map `tplc`.

From diff: 55 `lvl` elements missing `tplc` attribute.

Note: `durableId` on `<w:num>` was already mapped in NumberingInstance.

## Fix
- **Level model** (`uniword/wordprocessingml/level.rb`): Added `tplc` attribute
  and `map_attribute "tplc", to: :tplc, render_nil: false`. Template `tplc`
  values are now preserved through parse/serialize round-trip.

## Verification
- Template numbering levels with `tplc` are preserved in output
- `durableId` on numbering instances was already working
