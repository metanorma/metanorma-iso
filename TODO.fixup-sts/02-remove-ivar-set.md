# 02 — Remove `instance_variable_set(:@__order_tracking__, true)`

## Why
Global rule: never use `instance_variable_set`. The current STS code sets
`@__order_tracking__ = true` on sts-ruby model instances in four places, but
nothing in this codebase or in sts-ruby ever reads that variable. It is
vestigial — probably left over from an early lutaml-model ordering experiment.

## Current sites
- `lib/metanorma/iso/sts/transformer/base.rb:85` — `build_ordered` helper
- `lib/metanorma/iso/sts/transformer/term_transformer.rb:97`
- `lib/metanorma/iso/sts/transformer/footnote_collector.rb:69`
- `lib/metanorma/iso/sts/transformer/footnote_collector.rb:76`
- `spec/sts/block_dispatcher_spec.rb:14` (test fixture line)

Verification grep: `grep -rn "@__order_tracking__" lib spec` — only writers,
no readers. sts-ruby also has no reader: `grep -rn "order_tracking" /Users/mulgogi/src/mn/sts-ruby/lib` is empty.

## Plan
1. Remove `instance.instance_variable_set(:@__order_tracking__, true)` from
   `build_ordered` in `base.rb`. Keep the method (it still yields and returns
   the instance — it is a convenient `klass.new.tap { yield _1 }` analogue).
2. Remove the three other call sites. For `term_transformer.rb:97` and the
   two in `footnote_collector.rb:69,76`, drop the line and rely on the
   framework's default behavior (which is what they were running with anyway).
3. Drop the matching line in `spec/sts/block_dispatcher_spec.rb:14`.

## Acceptance
- `grep -rn "instance_variable_set" lib/metanorma/iso/sts` returns nothing.
- `bundle exec rspec spec/sts/document_transformer_spec.rb` still passes.
- `bundle exec rspec spec/sts/block_dispatcher_spec.rb` still passes.
