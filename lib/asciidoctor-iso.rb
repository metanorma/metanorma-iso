require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/iso/converter"
require_relative "asciidoctor/iso/version"
require "asciidoctor/extensions"

if defined? Metanorma
  require_relative "metanorma/iso"
  Metanorma::Registry.instance.register(Metanorma::Iso::Processor)
end
