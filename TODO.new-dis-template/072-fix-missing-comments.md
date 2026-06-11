# 072: Fix Missing Comments Support

## Problem
The reference DOCX has comment files (comments.xml, commentsExtended.xml, commentsExtensible.xml, commentsIds.xml) and 2 CommentReference rStyle entries. The output has no comment files at all.

## Evidence
```
Reference: 4 comment-related XML files + 2 CommentReference rStyles
Output:    0 comment files
```

## Fix
Either:
1. Render comments from the presentation XML into OOXML comment parts
2. Or skip comments (if the ISO presentation XML doesn't contain them for this document)

This may be lower priority since the reference rice.docx may have editor comments rather than document content.

## Priority
**LOW** — Comments are typically editorial, not content.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — comment rendering
