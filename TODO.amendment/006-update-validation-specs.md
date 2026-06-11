# TODO 006: Update Amendment Validation Specs

## Status: COMPLETE

### What

Update sample validation specs to properly test amendment body content rendering.

### Changes

**`spec/isodoc/docx/sample_validation_spec.rb`**:

1. DAMD content test — add checks for amendment body text:
   ```ruby
   expect_content_present(texts, [
     "Foreword",
     "AMENDMENT",
     "All rights reserved",
     "Replace",
     "Add the following",
   ])
   ```

2. DAMD paragraph count — increase ratio from 0.4 to 0.7:
   ```ruby
   expect(ratio).to be >= 0.7,
   ```

3. Add amendment-specific content tests for newcontent:
   - Check that replacement text appears (e.g., "The marking and labelling")
   - Check that added annex title appears

4. Update amendment final and WD tests similarly.

### Depends On

- TODO 002 (visit_amend dispatch)
- TODO 003 (render_amend_content_block)
