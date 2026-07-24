# 01 — Replace `require_relative` with autoload

## Why
`lib/metanorma/iso/sts.rb` opens with:
```ruby
require_relative "../iso_document"
require_relative "sts/transformer"
```
Project rule: never use `require_relative` (or `require` with a path inside
this library) — declare autoloads in the immediate parent namespace's file.

## Current sites
- `lib/metanorma/iso/sts.rb:5` — `require_relative "../iso_document"`
- `lib/metanorma/iso/sts.rb:7` — `require_relative "sts/transformer"`

## Plan
1. Delete both `require_relative` lines.
2. Keep the existing `require "sts"` and `require "metanorma/document"` (those
   are gems, not internal code).
3. The `Metanorma::Iso::Sts::Transformer` autoload is already declared in
   `lib/metanorma/iso/sts/transformer.rb`'s `module Transformer` — but the
   parent `Metanorma::Iso::Sts` module also needs to trigger that file.
   Add an autoload for `Transformer` in `lib/metanorma/iso/sts.rb`.
4. The iso_document entry file (`lib/metanorma/iso_document.rb`) is the gem's
   public entry — load it via the gem's own `autoload :IsoDocument` declared
   in `lib/metanorma/iso.rb` (verify it exists; create it if not).

## Acceptance
- `grep -rn "require_relative" lib/metanorma/iso/sts.rb` returns nothing.
- `bundle exec ruby -Ilib -e 'require "metanorma/iso/sts"; Metanorma::Iso::Sts'`
  still loads without error.
- Existing STS specs still pass.
