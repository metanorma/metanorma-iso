---
title: 108-016 - Render boilerplate from model (copyright, license, address)
priority: P0
status: done
depends_on: [108-001, 108-015]
---

# 108-016: Render Boilerplate from Model

## Resolution

`BoilerplateRenderer` renders the model's license statements on the cover.
After the cover section break it renders copyright statements and the
copyright address, followed by legal and feedback statements. The adapter
then inserts the page break before Contents.

`spec/isodoc/docx/boilerplate_renderer_spec.rb` verifies the order in the
saved DOCX and checks the layout when legal and feedback are absent.

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

## Files to Change

- `lib/isodoc/iso/docx/boilerplate_renderer.rb`
- `spec/isodoc/docx/boilerplate_renderer_spec.rb`
