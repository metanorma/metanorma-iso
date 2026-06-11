# TODO 001: Fix Table Ordering — Tables Interleaved with Paragraphs

## Status: COMPLETED

Fixed in uniword: `DocumentBuilder#<<` now calls `append_to_element_order` for each
paragraph and table insertion. Tables appear inline where `doc << tbl` is called,
not dumped after all paragraphs.
