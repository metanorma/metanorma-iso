# DOCX Rice Content Validation

Validate the DOCX output of `IsoDoc::Iso::Docx::Adapter` against the
reference `spec/examples/rice.docx`. Focus is on CONTENT correctness
(paragraph text, ordering, structure), not styling.

## Reference

- Source XML: `spec/examples/rice.presentation.xml`
- Expected output: `spec/examples/rice.docx` (open in Word to view)
- Actual output: `data/rice-dis-output-latest.docx` (regenerate via
  `bundle exec ruby -e 'require "isodoc/iso/docx"; IsoDoc::Iso::Docx::Adapter.new(template: :dis).convert("spec/examples/rice.presentation.xml", "data/rice-dis-output-latest.docx")'`)

## Issues

1. [Missing "Normative references" section](01-missing-normative-references.md)
2. [Heading section numbers not rendered](02-heading-numbers.md)
3. [Wrong term style names](03-term-style-names.md)
4. [Definition paragraph has no style](04-definition-style.md)
5. [Terms intro uses wrong style](05-terms-intro-style.md)
6. [TOC: wrong section ordering and missing entries](06-toc-ordering.md)
7. [TOC: section numbers in entries are stripped](07-toc-numbers-stripped.md)
8. [Bibliography entries split across lines (stray <w:br/>)](08-biblio-annotations-and-br.md)
9. [Terms intro duplicated in body](09-terms-intro-duplicated.md)
10. [Term designation layout (spacing between preferred/admitted/definition)](10-term-designation-layout.md)
11. [Identical footnotes should be collapsed](11-collapse-identical-footnotes.md)
12. [List item style is wrong](12-list-item-style.md)
13. [NOTE and EXAMPLE rendering](13-note-example-rendering.md)
14. [Table notes rendered within the table](14-table-notes-within-table.md)
15. [Definition lists + math (plurimath / OMML)](15-definition-lists-and-math.md)
16. [Figures not properly sized](16-figure-sizing.md)
