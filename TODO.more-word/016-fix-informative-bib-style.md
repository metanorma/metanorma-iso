# TODO 016: Fix Informative Bibliography Style

## Status: COMPLETED

- BiblioEntry style correctly applied to informative bibliography entries
- Added `build_bib_item_text` to extract docidentifier text for semantic XML
  where `biblio_tag` and `formatted_ref` are nil
- Falls back to primary docidentifier.id, then to first available title
- Normative refs use `ref_norm` style with docidentifier text
- Full citation formatting (docidentifier + title + date assembly) deferred to
  presentation XML path — semantic XML path produces identifier-only entries
