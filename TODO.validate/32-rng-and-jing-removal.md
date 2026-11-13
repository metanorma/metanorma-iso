# 32 — RNG and Jing removal

## Why
Final step: delete all `.rng` files under `lib/metanorma/iso/`, remove the
Jing invocation from the validator pipeline, and remove
`Metanorma::Iso::Validate#schema_file`.

## Files to delete
- `lib/metanorma/iso/isostandard-compile.rng`
- `lib/metanorma/iso/isostandard.rng`
- `lib/metanorma/iso/isostandard-amd.rng`
- `lib/metanorma/iso/relaton-iso.rng`
- `lib/metanorma/iso/isodoc.rng`
- `lib/metanorma/iso/basicdoc.rng`
- `lib/metanorma/iso/biblio.rng`
- `lib/metanorma/iso/biblio-standoc.rng`
- `lib/metanorma/iso/reqt.rng`
- `lib/metanorma/iso/mathml3*.rng`
- `lib/metanorma/iso/metanorma-mathml.rng`

## Files to modify
- `lib/metanorma/iso/validate.rb` — override `#validate(doc)` to:
  ```ruby
  def validate(doc)
    @log.add_error_ranges(doc)
    Metanorma::Iso::ModelValidator.run(doc.to_xml, log: @log,
                                       state: converter_state)
  end
  ```
  Remove `schema_file`. Remove `content_validate` body (its checks have all
  migrated). Ensure `super` is not called into standoc's
  `content_validate`/`schema_validate`.
- `metanorma-iso.gemspec` — drop `jing` runtime dependency.

## Acceptance
- `find lib/metanorma/iso -name "*.rng"` returns nothing.
- `grep -rn "jing" lib/metanorma/iso/` returns nothing.
- `grep -rn "Jing" lib/metanorma/iso/` returns nothing.
- `bundle exec metanorma -t iso spec/examples/rice.adoc` error log unchanged
  from pre-migration baseline.
- All migrated-rule specs green.

## Risk
Highest-risk PR. Sequence AFTER TODO 31 is verified.

## Pre-merge verification
Run the full migration validation suite (each rule spec file, one at a time)
before merging. Confirm rice + 17 ISO reference files produce identical
error logs.
