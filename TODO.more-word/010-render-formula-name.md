# TODO 010: Render Formula Name and "where" Paragraphs

## Status: COMPLETED

- `visit_formula` now renders `fmt_name` (formula number "(1)") after stem content
- Child `p` elements ("where...") are now rendered as separate paragraphs
- Formula element_order: fmt-name, stem, fmt-stem, p
- All 4 formulas now show their numbers and "where" clauses
