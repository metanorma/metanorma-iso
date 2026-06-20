# 021 — Spec: StyleResolver strict mode

## Goal

Specs that pin StyleResolver (TODO 006) behavior:

1. `paragraph_style(:heading_1)` returns the canonical styleId for
   `Heading1`, never a fallback.
2. `paragraph_style(:unknown)` raises `UnknownStyleError` with the key
   and context in the message.
3. `paragraph_style_or_nil(:unknown)` returns `nil` (for legitimate
   optional callers, e.g., rendering an attributor when none is
   defined).
4. Context-aware dispatch is enum-driven (`zone:`), not boolean-driven.

## File layout

```
spec/isodoc/iso/docx/
  style_resolver_spec.rb
  support/
    resolver_factory.rb
```

## Spec sketch

```ruby
require "spec_helper"
require "isodoc/iso/docx"

module IsoDoc
  module Iso
    module Docx
      RSpec.describe StyleResolver do
        let(:mapping) { DocxStyleMapping.load_default }
        let(:library) { StyleLibrary.load_default }
        let(:context) { Context.new(zone: :body) }
        subject(:resolver) { described_class.new(mapping, library) }

        describe "#paragraph_style" do
          it "returns the canonical Heading1 styleId" do
            expect(resolver.paragraph_style(:heading_1, context: context))
              .to eq("Heading1")
          end

          it "returns the canonical Note styleId in body zone" do
            expect(resolver.paragraph_style(:note, context: context))
              .to eq("Note")
          end

          it "raises UnknownStyleError for an unknown key" do
            expect {
              resolver.paragraph_style(:definitely_unknown, context: context)
            }.to raise_error(UnknownStyleError, /definitely_unknown/)
          end

          it "raises with context info in the message" do
            expect {
              resolver.paragraph_style(:definitely_unknown, context: context)
            }.to raise_error(UnknownStyleError, /zone=:body/)
          end
        end

        describe "#paragraph_style_or_nil" do
          it "returns nil for an unknown key" do
            expect(resolver.paragraph_style_or_nil(:definitely_unknown,
                                                   context: context))
              .to be_nil
          end
        end

        describe "context-aware dispatch" do
          let(:body_ctx)    { Context.new(zone: :body) }
          let(:annex_ctx)   { Context.new(zone: :annex) }
          let(:foreword_ctx){ Context.new(zone: :foreword) }
          let(:biblio_ctx)  { Context.new(zone: :bibliography) }
          let(:note_ctx)    { Context.new(zone: :note) }

          it "in :annex returns AnnexHeading" do
            expect(resolver.paragraph_style(:clause_heading, context: annex_ctx))
              .to eq("ANNEX")
          end

          it "in :foreword returns ForewordHeading" do
            expect(resolver.paragraph_style(:clause_heading, context: foreword_ctx))
              .to eq("IntroHeading1")
          end

          it "in :body returns Heading1" do
            expect(resolver.paragraph_style(:clause_heading, context: body_ctx))
              .to eq("Heading1")
          end

          it "in :note returns Noteindent" do
            expect(resolver.paragraph_style(:note_body, context: note_ctx))
              .to eq("Noteindent")
          end

          it "does not chain fallbacks" do
            # No Zone is permitted to silently fall back to body.
            expect {
              resolver.paragraph_style(:clause_heading, context: biblio_ctx)
            }.to raise_error(UnknownStyleError)
          end
        end

        describe "#character_style" do
          it "returns InlineCode for inline_code key" do
            expect(resolver.character_style(:inline_code))
              .to eq("InlineCode")
          end

          it "raises for unknown character key" do
            expect {
              resolver.character_style(:nope)
            }.to raise_error(UnknownStyleError)
          end
        end

        describe "#numbering_id" do
          it "returns the abstractNumId for body_clause" do
            expect(resolver.numbering_id(:body_clause)).to eq(3)
          end

          it "returns the abstractNumId for annex_clause" do
            expect(resolver.numbering_id(:annex_clause)).to eq(6)
          end

          it "raises for unknown numbering key" do
            expect {
              resolver.numbering_id(:nope)
            }.to raise_error(UnknownStyleError)
          end
        end
      end
    end
  end
end
```

## Required model support

- `Context` value object with `zone:` keyword (TODO 010 prerequisite).
  Zones are an enum: `:body`, `:annex`, `:foreword`, `:bibliography`,
  `:note`, `:example`, `:formula`, `:table`, `:figure`, `:warning`.
- `UnknownStyleError < StandardError` with `attr_reader :key, :context`
  and a `message` that includes both.

## Anti-patterns explicitly rejected by this spec

These patterns must not appear in `StyleResolver`:

```ruby
# FORBIDDEN — fallback chain
def paragraph_style(key)
  mapping[key] || mapping[:default] || "Normal"
end

# FORBIDDEN — boolean dispatch
def paragraph_style(key, in_note:, in_example:)
  ...
end

# FORBIDDEN — string interpolation
def heading_for(level)
  "Heading#{level}"
end

# FORBIDDEN — send on private
def style_via_send(name)
  mapping.send("#{name}_style")
end
```

## Acceptance criteria

- `bundle exec rspec spec/isodoc/iso/docx/style_resolver_spec.rb` passes.
- All zones listed in the spec are defined as enum members; the spec
  will not compile if a zone is missing.
- Spec uses real `DocxStyleMapping` and `StyleLibrary` instances loaded
  from the canonical YAML files — no `double()`.

## Notes

- This spec is the contract for TODO 005/006. Without it, future
  maintainers could re-introduce fallback chains without noticing.
- Run after TODO 006 lands; if running before, the spec will fail with
  clear messages identifying the gap.
