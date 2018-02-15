require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/iso/converter"
require_relative "asciidoctor/iso/version"
require "asciidoctor/extensions"

Asciidoctor::Extensions.register do
  inline_macro Asciidoctor::ISO::AltTermInlineMacro
  inline_macro Asciidoctor::ISO::DeprecatedTermInlineMacro
  inline_macro Asciidoctor::ISO::DomainTermInlineMacro
end


