# TODO 13: Missing w16cid:durableId on numbering instances (COSMETIC)

## Problem
All `<w:num>` elements in numbering.xml are missing the `w16cid:durableId`
attribute. Word adds random durableId values during repair.

Broken: `<w:num w:numId="1">`
Repaired: `<w:num w16cid:durableId="1411391210" w:numId="1">`

## Status
DONE. Two changes:
1. Added `durable_id` attribute to Num model with w16cid namespace mapping
2. Reconciler generates stable durableId values for instances that lack them

## Fix Location
- **Uniword** `num.rb`: added `durable_id` attribute and XML mapping
- **Uniword reconciler** (`reconciler.rb`): `reconcile_numbering` generates durableId
