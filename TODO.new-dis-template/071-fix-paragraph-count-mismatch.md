# 071: Fix Paragraph Count Mismatch (291 vs 349)

## Problem
The output has 291 body paragraphs while the reference has 349. That's 58 fewer paragraphs — a significant content loss. This is a combination of all the other issues.

## Breakdown of missing paragraphs:
| Issue | Missing paras | Notes |
|-------|--------------|-------|
| TOC entries | ~26 | Full TOC with page numbers |
| Annex headings | ~10 | 5 annexes × 2 paragraphs each (label + title) |
| Annex separators | ~5 | Empty paragraphs before annex headings |
| Missing preamble text | ~4 | Terms section preambles |
| Missing figure content | ~5 | Key, NOTE, sub-figure descriptions |
| Missing Annex D table | ~5 | Table rows for interlab test results |
| Extra in cover page | ~-6 | Cover is longer, offsetting some loss |
| **Total** | **~58** | Matches observed delta |

## Fix
Fix each individual issue (059-070) and the paragraph count will naturally match.

## Priority
**SUMMARY** — This is the aggregate metric of all other issues.

## Location
- See individual issues 059-070
