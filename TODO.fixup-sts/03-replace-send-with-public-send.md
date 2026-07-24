# 03 — Replace `.send(...)` with `.public_send(...)`

## Why
Global rule: never use `send` to call methods dynamically. The current STS
code uses `send` in 5 places to dispatch to **public** transformer methods
and setters. That does not violate the rule's letter (the rule is about
private-method access), but it violates its spirit (dynamic dispatch through
`send` is a code smell — readers can't tell at a glance whether the call
targets a public or private API).

`public_send` makes the intent explicit: "I am intentionally calling a
public method whose name is data-driven." It also enforces the contract —
if someone refactors a target into a private method, `public_send` will
fail loudly instead of silently bypassing encapsulation.

## Current sites
- `lib/metanorma/iso/sts/transformer/content_text.rb:32` —
  `val = obj.send(attr_name)` — `attr_name` is an attribute name from the
  model's `class.attributes`, so it is public by definition.
- `lib/metanorma/iso/sts/transformer/inline_transformer.rb:55,74,76` —
  `target.send(type, value)` and `target.send(text_attr, value)` — `target`
  is an sts-ruby model; setters are public.
- `lib/metanorma/iso/sts/transformer/block_dispatcher.rb:20,21` —
  `transformer.send(entry.transform_method, node)` and
  `target.send(entry.target_setter, result)` — both call public methods
  identified by the dispatch table.

## Plan
1. Replace each `.send(` with `.public_send(` at the 5 sites above.
2. No semantic change — every target method is already public.

## Acceptance
- `grep -rn "\.send(" lib/metanorma/iso/sts` returns nothing.
- All existing STS specs still pass.
