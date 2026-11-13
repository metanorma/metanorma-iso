---
title: 108-016 - Render boilerplate from model (copyright, license, address)
priority: P0
status: open
depends_on: [108-001, 108-015]
---

# 108-016: Render Boilerplate from Model

## Problem

The adapter does not render the boilerplate (copyright-statement, license-statement). The boilerplate is available in `model.boilerplate` but `visit_root` never visits it.

## Model Structure

```ruby
# Metanorma::StandardDocument::Boilerplate
attribute :copyright_statement, ContentSection, collection: true
attribute :license_statement, ContentSection, collection: true
attribute :legal_statement, ContentSection, collection: true
attribute :feedback_statement, ContentSection, collection: true
attribute :clause, ContentSection, collection: true
```

Each `ContentSection` has paragraphs with IDs like:
- `boilerplate-year` → "© ISO 2016"
- `boilerplate-message` → "All rights reserved..."
- `boilerplate-address` → "ISO copyright office CP 401..."
- `boilerplate-place` → "Published in Switzerland"

## Reference Structure

The copyright block uses these styles:
```
Para: [zzCopyrightHdr] "© ISO 2016"         (on copyright page)
Para: [zzCopyright] "All rights reserved..."
Para: [zzCopyrightaddress] "ISO copyright office..."
Para: [zzCopyright] "Published in Switzerland"
```

The license block uses:
```
Para: [zzwarninghdr] "Warning for WDs and CDs"    (on cover page)
Para: [zzWarning] "This document is not..."
Para: [zzWarning] "Recipients of this draft..."
```

## Fix

Add `visit_boilerplate` method:

```ruby
def visit_boilerplate(boilerplate, doc)
  return unless boilerplate

  # License/warning goes on cover page (before sectPr)
  boilerplate.license_statement&.each do |stmt|
    visit_boilerplate_clause(stmt, doc, :license)
  end

  # After cover page sectPr, start copyright page
  doc.section_break  # New page for copyright

  # Copyright block
  boilerplate.copyright_statement&.each do |stmt|
    visit_boilerplate_clause(stmt, doc, :copyright)
  end
end

def visit_boilerplate_clause(clause, doc, type)
  # Render title with appropriate style
  if clause.title
    style = type == :copyright ? :copyright_hdr : :warning_hdr
    para = build_paragraph(style: @resolver.paragraph_style(style))
    @inline_renderer.render(clause.title, para)
    doc << para
  end

  # Render content paragraphs
  walk_mixed_content(clause, doc)
end
```

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — add visit_boilerplate, visit_boilerplate_clause
- `data/iso-dis/style_mapping.yml` — add zzCopyrightHdr, zzWarning, zzwarninghdr mappings
