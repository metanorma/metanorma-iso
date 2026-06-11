# TODO 013: Update Spec Fixtures and Expectations

## Status: COMPLETE

## What

Update all DOCX specs to use the new template's style IDs and validate against the new structure.

## Why

After switching templates, all existing spec expectations that reference old style IDs will fail. Specs need to be updated to expect the new style names and document structure.

## Changes

### adapter_spec.rb

- Update any hardcoded style name expectations
- Verify adapter creates paragraphs with correct new styles
- Update mock data to match new model attributes

### sample_validation_spec.rb

- Update content expectations for new cover page structure
- Update style name assertions
- Update paragraph count expectations (new template may produce different counts)
- Update section structure expectations

### style_mapping_spec.rb

- Update to test new style mapping values
- Test new numbering IDs
- Remove tests for old styles that no longer exist

### style_resolver_spec.rb

- Update style resolution expectations
- Test depth-aware term number style resolution
- Test new context body style resolution

### inline_renderer_spec.rb

- Update character style expectations
- Remove tests for old semantic markup styles

### integration_spec.rb

- Update full pipeline expectations
- Test document properties generation
- Test section break rendering
- Test cover page structure

## Files

- `spec/isodoc/docx/adapter_spec.rb`
- `spec/isodoc/docx/sample_validation_spec.rb`
- `spec/isodoc/docx/style_mapping_spec.rb`
- `spec/isodoc/docx/style_resolver_spec.rb`
- `spec/isodoc/docx/inline_renderer_spec.rb`
- `spec/isodoc/docx/integration_spec.rb`
- `spec/isodoc/docx/context_spec.rb`

## Depends On

- TODO 011 (adapter updated with new styles)
- TODO 012 (end-to-end validation complete)
