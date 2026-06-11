# TODO 031: Fix Broken Relationships — customXml Items Removed But Relationships Persist

## Status: DONE

## What

The adapter clears customXml items from the template model (`root.custom_xml_items = nil`) but the template's `word/_rels/document.xml.rels` still contains relationships (rId1-4) pointing to `../customXml/item1.xml` through `item4.xml`. These files don't exist in the output ZIP, causing Word to report "unreadable content".

## Why

### Current (Broken)

```xml
<!-- word/_rels/document.xml.rels -->
<Relationship Id="rId1" Type="...customXml" Target="../customXml/item1.xml"/>
<Relationship Id="rId2" Type="...customXml" Target="../customXml/item2.xml"/>
<Relationship Id="rId3" Type="...customXml" Target="../customXml/item3.xml"/>
<Relationship Id="rId4" Type="...customXml" Target="../customXml/item4.xml"/>
```

But the ZIP has no `customXml/` directory at all. Word finds dangling references → "unreadable content" error.

### Fix

Added `remove_broken_rels` post-processing step that:
1. Reads all file paths in the ZIP
2. Parses `word/_rels/document.xml.rels`
3. Removes Relationship nodes whose Target points to non-existent files
4. Skips external URLs (http://, https://, mailto:) and anchors (#)

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `remove_broken_rels` method called from `save_document`

## Depends On

- None
