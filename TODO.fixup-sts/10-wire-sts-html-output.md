# 10 — Wire `:sts_html` output format

## Why
The new HTML renderer should be reachable from the standard metanorma
pipeline (`metanorma -t iso -f sts_html input.xml`), not just via ad-hoc
Ruby. That requires registering a new output format in the processor.

## Plan
1. In `lib/metanorma/iso/processor.rb`:
   - Add `sts_html: "sts.html"` to `output_formats`.
   - In `use_presentation_xml(ext)`, return `false` for `:sts_html` — it
     consumes STS XML (semantic), not presentation XML. Match the `:isosts`
     native-transformer routing.
   - In `output(...)`, add a `:sts_html` branch that calls
     `Metanorma::Iso::Sts.render_html(...)` on the input.
2. Document the format in `CLAUDE.md`'s processor section (output format
   list).
3. Keep the QA gate (`Metanorma::Iso::Sts.enabled?`) governing only
   `:isosts` — `:sts_html` is always available because the renderer does
   not have a mnconvert fallback.

## Acceptance
- `metanorma -t iso -f sts_html spec/examples/rice.sts.xml` writes a
  `rice.sts.html` artifact.
- `output_formats` includes `:sts_html`.
- Existing `:sts` and `:isosts` outputs are unchanged.
