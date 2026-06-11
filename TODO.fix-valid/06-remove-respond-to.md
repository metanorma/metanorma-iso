# Fix 6: Remove respond_to? and defined? checks from adapter

## Status: DONE

## Changes
- `lib/isodoc/iso/docx/adapter.rb`: Removed `respond_to?(:custom_style_block=)`, `defined?(YamlCssGenerator)`, `respond_to?(:embeddings=)`
- Removed dead `mhtml_css` method and `YamlCssGenerator` integration code
- Updated class comment to reflect type-driven dispatch
