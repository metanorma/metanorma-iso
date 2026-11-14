# MHTML parity harness

Run from the gem checkout (the main Rakefile does not import `lib/tasks`):

```sh
DOCX_PARITY_CASES='[{"submitted":"/private/iso-2533.doc","source":"/private/iso-2533.presentation.xml"}]' \
  bundle exec rake -f lib/tasks/docx_parity.rake docx:parity
```

`DOCX_PARITY_CASES` is a nonempty JSON array of pairs. Each pair has `submitted`
(the submitted isodoc MHTML) and exactly one of:

- `source`: Metanorma **presentation XML**, as consumed by the ISO Word processor.
  The task generates Uniword output in a temporary directory and removes it after
  reporting. Optional `format` is `docx` (default) or `doc`; optional `template`
  is the processor's `dis` or `simple` override. Without an override, the existing
  processor selects the template. Compile AsciiDoc to presentation XML first.
- `output`: an existing Uniword `.doc` (MHTML) or `.docx`, avoiding regeneration.

Paths may contain spaces. All private inputs stay external to the repository.
The task prints every report, including differences, and exits successfully;
invalid inputs or conversion failures raise an error. It is a diagnostic task,
not an acceptance gate with an assumed baseline. `MhtmlParity#match?` is available
to callers that need a gate.

The report aligns an ordered body structure/style sequence. `-` is submitted,
`+` is generated, and numbers are one-based token positions. Paragraphs include
their named style; headings include outline level; notes/examples are identified
by their named styles. Tables, rows and cells include closing tokens to preserve
nesting, and images produce figure tokens. Captions retain their paragraph style.
DOCX style IDs resolve through `word/styles.xml`, including the default paragraph
style and inherited outline levels. HTML uses Word's tag/class `mso-style-name`
and `mso-outline-level` rules, inline overrides, then class/tag defaults.
Style comparison ignores case and whitespace and treats `MsoNormal` as `Normal`.

This does not compare prose, numbering values, image pixels, direct formatting,
page layout, metadata, headers/footers, or separate footnote/endnote parts. It is
not a full CSS cascade or visual conformance check. Binary Word `.doc` is not
MHTML and is unsupported. Empty paragraphs are retained because named blank
paragraphs such as `Box-begin` and `Box-end` are meaningful.

All fixtures here are synthetic. `submitted.mhtml` is a small quoted-printable
multipart document with a separate header and image attachment. `document.xml`
and `styles.xml` describe its matching body; the spec packages those XML parts
into a temporary ZIP rather than storing an opaque generated DOCX. The spec also
creates base64 MHTML and differing outputs in temporary directories.
`source.presentation.xml` exercises the real processor and Uniword writer.
