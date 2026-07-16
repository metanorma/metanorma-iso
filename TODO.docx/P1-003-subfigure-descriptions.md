# 081: Missing sub-figure descriptions for Figure C.2 a/b/c

## Problem
Reference has detailed descriptions for Figure C.2's sub-figures (a/b/c). Output is missing these paragraphs.

## Reference (after Figure C.2 image):
```
a)  Initial stages: No grains are fully gelatinized (ungelatinized starch granules are visible inside the kernel)
b)  Intermediate stages: Some fully gelatinized kernels are visible
c)  Final stages: All kernels are fully gelatinized
```

## Output:
Missing entirely.

## Root cause
The figure element in the presentation XML likely contains sub-figure elements or `<key>` children with these descriptions. The `visit_figure` method processes the image and name but doesn't walk the figure's mixed content children.

The fix in 068 added `walk_mixed_content(figure, doc)` to `visit_figure`, but sub-figure descriptions may be in a different element type (e.g., `<figure>` children that are not yet dispatched).

## Fix
Verify that `walk_mixed_content` in `visit_figure` processes all children including sub-figures and their descriptions. Check the model's element_order for the Figure C.2 element.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — `visit_figure`
