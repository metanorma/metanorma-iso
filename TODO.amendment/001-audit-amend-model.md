# TODO 001: Audit Amendment Model Parsing

## Status: DONE

### Findings

- Model parses amendments correctly: `ClauseSection.amend` is populated as `AmendBlock`
- `AmendBlock` has `change`, `description`, `new_content` attributes
- `AmendContentBlock.content` is raw XML string (installed gem 0.2.6 uses `map_all_content`)
- Local source (`/Users/mulgogi/src/mn/metanorma-document/`) has typed attributes but isn't running
- Must work with raw XML strings, not model attributes like `desc.paragraphs`
- Nokogiri::XML.fragment parses amend content raw XML correctly
- Amendment clauses: 10 clauses in DAMD, all with `change`, `description`, some with `new_content`
- Content types in description: `<p>` elements (simple text with bookmarks)
- Content types in newcontent: `<p>`, `<note>`, `<table>`, `<figure>`, `<clause type="annex">`

### Model Details

- `ClauseSection.amend` — singular, not collection (each clause has one amend)
- `AmendBlock.description` — collection of `AmendContentBlock`
- `AmendBlock.new_content` — collection of `AmendContentBlock`
- `AmendContentBlock.content` — raw XML string (`map_all_content`)
- `IsoAmendmentClause` exists but NOT registered in type substitution table
