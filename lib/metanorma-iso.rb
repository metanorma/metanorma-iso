require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/iso/converter"
require_relative "metanorma/iso/version"
require_relative "isodoc/iso/html_convert"
require_relative "isodoc/iso/word_convert"
require "asciidoctor/extensions"

if defined? Metanorma
  require_relative "metanorma/iso"
  Metanorma::Registry.instance.register(Metanorma::Iso::Processor)
end
