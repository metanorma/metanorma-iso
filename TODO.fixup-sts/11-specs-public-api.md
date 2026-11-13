# 11 — Specs for the public API

## Why
The public API (`Metanorma::Iso::Sts.convert`, `.convert_to_model`,
`.render_html`) is the stable surface callers depend on. It needs RSpec
coverage so refactors underneath do not silently break it.

## Plan
1. Create `spec/sts/public_api_spec.rb`.
2. Load `spec/examples/rice.xml` once (let block).
3. Examples:
   - `convert_to_model(xml)` returns a `Sts::IsoSts::Standard`.
   - `convert_to_model(xml)` builds an `IsoMeta`-bearing `Front`.
   - `convert(xml)` returns a String starting with `<?xml` and containing
     `<standard` and `<iso-meta`.
   - `convert(xml)` includes `xml:lang="en"` on `<standard`.
   - `convert(xml)` post-processes NBSP (`ISO 8601` → `ISO 8601`) —
     only in text content, not attributes.
   - `render_html(xml)` returns HTML starting with `<!DOCTYPE html>`.
   - `render_html(xml)` contains the document title (extracted from
     `<title-wrap>`).

## Acceptance
- `bundle exec rspec spec/sts/public_api_spec.rb` is green.
- Uses a real fixture (`rice.xml`), not doubles.
