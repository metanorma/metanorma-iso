# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Tools

- Use `canon diff FILE1 FILE2` for semantic XML diffs. NEVER use `xmldiff` (it is broken — produces false structural diffs).
  Canon is at `/Users/mulgogi/.local/share/mise/installs/ruby/3.4.8/bin/canon`. See `~/src/lutaml/canon/README.adoc` for full options.
  Key flags: `--verbose` (detailed output), `--show-diffs normative` (only equivalence-affecting diffs),
  `--diff-algorithm semantic`, `--text-content normalize`, `--structural-whitespace ignore`.
- **NEVER use Python.** Use Ruby for all scripting, analysis, and validation tasks.

## Overview

metanorma-iso is a Ruby gem that processes Metanorma AsciiDoc documents following ISO International Standard templates. It generates XML, HTML (standard + alt), Word (.doc), PDF, and STS output formats. It builds on top of metanorma-standoc and isodoc.

## Spec Safety Rules

- **NEVER run `bundle exec rake` or `bundle exec rspec` (full suite).** The full test suite causes memory leaks that crash the machine (Killed: 9). No exceptions.
- **NEVER run multiple spec files in one session.** Run ONE targeted spec file at a time, then wait for the process to fully exit before running another.
- **ALWAYS run a single spec file with a specific line number when possible.** Example: `bundle exec rspec spec/isodoc/docx/adapter_spec.rb:42`
- **NEVER run specs in parallel or in background tasks.** No `&` backgrounding, no multiple shell invocations.
- **If a spec process hangs or uses excessive memory, kill it immediately.** Do not let it run to completion.
- **For verification, prefer reading code over running specs.** Specs are for confirming a specific change works, not for broad exploration.

## Build and Test Commands

```bash
bundle install          # install dependencies
# ONLY run individual spec files — NEVER the full suite:
bundle exec rspec spec/isodoc/docx/adapter_spec.rb:42     # single test by line number
bundle exec rspec spec/isodoc/docx/adapter_spec.rb         # single file
bundle exec rubocop     # lint
```

Tests use VCR cassettes (in `spec/vcr_cassettes/`) for external HTTP interactions.

## Architecture

### Two-layer design: AsciiDoc parsing → Document rendering

**Layer 1: AsciiDoc → ISO XML** (`lib/metanorma/iso/`)
- `converter.rb` — Entry point. `Metanorma::Iso::Converter` extends `Standoc::Converter`, registered as the `:iso` backend
- `base.rb` — Output pipeline: generates `.xml`, then chains to presentation XML, HTML, Word, PDF converters
- `front.rb`, `front_id.rb`, `front_contributor.rb` — Metadata/bibliographic data extraction from AsciiDoc attributes (titles, stage, document ID via `pubid` gem)
- `cleanup.rb`, `cleanup_biblio.rb` — Post-processing of generated XML (footnote renumbering, ordered list cleanup, editorial group defaults, unpublished reference footnotes)
- `section.rb` — ISO-specific section parsing (scope, terms, patent notice)
- `validate.rb` + `validate_*.rb` — ISO-specific document validation (doctype, titles, section sequencing, cross-references, list formatting, style rules). Errors are logged via `log.rb` using keyed messages (ISO_1 through ISO_52)
- `processor.rb` — `Metanorma::Processor` subclass registering output formats (html, html_alt, doc, pdf, sts, isosts, presentation)

**Layer 2: ISO XML → Rendered output** (`lib/isodoc/iso/`)
- `base_convert.rb` — Shared rendering mixins (examples, tables, figures, admonitions) used by HTML and Word converters
- `html_convert.rb` — HTML output
- `word_convert.rb` — Word (.doc) output; `word_dis_convert.rb` handles distributed Word format
- `pdf_convert.rb` — PDF output
- `sts_convert.rb`, `isosts_convert.rb` — STS (ISO Standards Tag Set) XML output
- `presentation_xml_convert.rb` — Presentation XML (intermediate format); delegates to `presentation_*.rb` modules for bibdata, sections, terms, xrefs
- `xref.rb`, `xref_section.rb`, `xref_figure.rb` — Cross-reference generation
- `metadata.rb` — Document metadata extraction for rendering
- `i18n.rb` + `i18n-*.yaml` — Internationalization (en, fr, ru, de, ja, zh-Hans)
- `init.rb` — Factory methods for metadata, xref, i18n, and bib renderer instances

### Supporting modules
- `lib/metanorma/requirements/` — Requirements processing (modspec type)
- `lib/relaton/render/` — Bibliographic reference rendering with ISO-specific formatting and selective capitalization
- `lib/html2doc/lists.rb` — HTML-to-Word list conversion helper

### RNG Schemas
`lib/metanorma/iso/*.rng` — RelaxNG schemas for validating ISO XML. `isostandard-compile.rng` is the main schema; `isostandard-amd.rng` is used for amendments/technical corrigenda.

### Templates
- `lib/metanorma/iso/boilerplate*.adoc` — Boilerplate text (en, fr, ru) injected into documents
- `lib/isodoc/iso/html/` — HTML/SCSS templates and stylesheets for rendering

## DOCX Debugging Rules

- **The ZIP packaging is NEVER the problem.** The rubyzip output is proven correct (resaving a working DOCX through rubyzip produces a working DOCX). NEVER debug, investigate, or modify ZIP format code (zip_packager.rb, compression methods, ZIP version, Zip64, entry ordering). The bug is ALWAYS in the XML content.
- **NEVER use "shell swapping" or "part swapping" tests.** Replacing one DOCX file's XML parts with another's never fixes anything — the supporting files (styles, numbering, settings) are cross-referenced and must be consistent. Instead, audit and fix the actual XML content that the adapter generates.
- When a DOCX won't open, the bug is in the XML content, not the ZIP packaging. Audit the XML schemas, cross-references, and structural validity.
- Use `canon diff` or `uniword diff compare` to compare against the Word-repaired output (`*-repaired.docx`). The repaired file shows what Word considers correct.
- Compare against the known-working output (`data/iso-rice-sample-output.docx`) to find regressions.
- **NEVER run `bundle exec ruby` scripts that load the rice presentation XML model in background tasks.** Parsing the large XML causes memory exhaustion and process kills (Killed: 9). Use small targeted scripts or read the XML file directly instead.

## Key Patterns

- The converter class hierarchy is: `Standoc::Converter` → `Metanorma::Iso::Converter` (in `converter.rb` + `base.rb`). Validation and cleanup are in separate subclass modules (`Validate`, `Cleanup`) that extend their Standoc counterparts.
- ISO XML root tag is `iso-standard` with namespace `https://www.metanorma.org/ns/iso`.
- Document types: `international-standard`, `technical-specification`, `technical-report`, `publicly-available-specification`, `international-workshop-agreement`, `guide`, `amendment`, `technical-corrigendum`, `committee-document`, `addendum`, `recommendation`.
- Document schemes (1951, 1972, 1979, 1987, 1989, 2012, 2013, 2024) affect rendering rules; default is 2024.
- Amendments and technical corrigenda (`@amd`) skip many validations and have different processing paths.
- Vocabulary documents (`@vocab`, set via `docsubtype == "vocabulary"`) also have special handling.
- The `Gemfile.devel` file can override gem sources for local development (e.g., pointing to a local branch of isodoc).
