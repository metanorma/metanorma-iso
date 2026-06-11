# TODO 029: Fix custom.xml Attribute Serialization — custprops: Prefix and Namespace

## Status: DONE

## What

The adapter generates `docProps/custom.xml` with `custprops:` prefixed attributes (`custprops:fmtid`, `custprops:pid`, `custprops:name`) but no `xmlns:custprops` namespace declaration. The DIS template uses unprefixed attributes (`fmtid`, `pid`, `name`).

## Why

### Current (Broken)

```xml
<Properties xmlns="..." xmlns:vt="...">
  <property custprops:fmtid="..." custprops:pid="7" custprops:name="release-version">
    <vt:lpwstr>DIS</vt:lpwstr>
  </property>
</Properties>
```

The `custprops:` prefix is used but never declared. This is invalid XML — a namespace prefix must be declared before use.

### Expected (DIS Template)

```xml
<Properties xmlns="..." xmlns:vt="...">
  <property fmtid="..." pid="2" name="ContentTypeId">
    <vt:lpwstr>0x01010026...</vt:lpwstr>
  </property>
</Properties>
```

No prefix — the attributes are in the default namespace.

### Root Cause

This is likely a Uniword serialization issue where the CustomProperty model maps attributes with a namespace prefix that isn't the default namespace. The OOXML spec for `custom.xml` uses unprefixed attributes on `<property>` elements.

### Impact

Word strips `custom.xml` during repair. While the primary cause is the broken header/footer rIds (TODO 014), the invalid namespace prefix also contributes to the problem.

## Architecture

Fix Uniword's CustomProperty serialization to use unprefixed attributes, or adjust the adapter to output the correct format.

## Files

- Possibly Uniword `CustomProperty` serialization
- `lib/isodoc/iso/docx/document_properties.rb` — if workaround needed

## Depends On

- None
