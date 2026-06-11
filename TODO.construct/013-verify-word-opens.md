# 013: Verify — Generate DOCX, Open in Word, Canon Diff

## Problem

After all architectural changes, we need end-to-end verification that:
1. The generated DOCX opens in Word without "unreadable content" errors
2. Structural differences from Word's own output are minimal
3. Both uniword and metanorma-iso test suites pass

## Approach

### Step 1: Run uniword test suite

```bash
cd /Users/mulgogi/src/mn/uniword && bundle exec rspec
```

All specs must pass. Any failures indicate regressions from the refactoring.

### Step 2: Run metanorma-iso test suite

```bash
cd /Users/mulgogi/src/mn/metanorma-iso && bundle exec rspec
```

### Step 3: Generate rice.docx from adapter

Use the adapter's `convert` method to generate a DOCX from a test document:

```bash
cd /Users/mulgogi/src/mn/metanorma-iso
# Generate via the adapter
bundle exec ruby -e "
  require 'isodoc/iso/docx/adapter'
  IsoDoc::Iso::Docx::Adapter.new({}).convert('rice', File.read('spec/examples/rice.adoc'), 'rice.docx')
"
```

### Step 4: Open in Word

Open the generated `rice.docx` in Microsoft Word. Must:
- Open without "unreadable content" warning
- Display content correctly (headings, tables, footnotes, images)
- Have proper headers and footers

### Step 5: Canon diff against Word-repaired output

```bash
canon diff rice.docx data/rice_fixed16-repaired.docx --verbose
```

Differences should be:
- Profile-level only (zoom value, font defaults)
- NOT structural (rId differences, missing rels, wrong element order)

### Step 6: Repeat with template-editing path

Test the `from_file` path specifically:
1. Load a template DOCX
2. Modify it (add paragraphs, images, footnotes)
3. Save
4. Open in Word
5. Verify no "unreadable content"

## Acceptance

- All specs pass (uniword + metanorma-iso)
- DOCX opens in Word without any warnings
- Canon diff shows only cosmetic/profile differences
- Template-editing path produces valid DOCX
- No dangling references in any output

## Dependencies

- All previous TODOs (001-012) must be complete
