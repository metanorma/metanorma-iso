# TODO 015: Fix Term Definition Positioning

## Status: COMPLETED

- Fixed empty `fmt_preferred`/`fmt_admitted`/`fmt_deprecates` arrays being truthy in Ruby
  — now uses `has_fmt_*?` methods that check `Array(x).empty?`
- Added `next_term_number` to Context for synthesizing term numbers (e.g., "3.1", "3.2")
  from section counter + term counter
- Added `with_terms_section` to Context for scoped term counting
- Fixed normative refs from bibliography being inserted between Scope and Terms
  via `visit_root` restructuring
- Added `render_synthesized_term_number` for semantic XML (no `fmt_name`)
- Fixed preferred name style: always uses `:terms` style regardless of `fmt_name` presence
- Added `render_term_source` fallback for semantic XML with `build_term_source_text`
- Fixed `extract_origin_localities` to use `:bib_locality` attribute name
- Added `section_numbered?` to cover both `IsoClauseSection` and `IsoTermsSection`
