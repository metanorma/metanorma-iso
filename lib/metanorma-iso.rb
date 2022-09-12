require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "metanorma/iso/converter"
require_relative "metanorma/iso/version"
require_relative "metanorma/requirements/requirements"
require_relative "isodoc/iso/html_convert"
require_relative "isodoc/iso/word_convert"
require_relative "isodoc/iso/pdf_convert"
require_relative "isodoc/iso/sts_convert"
require_relative "isodoc/iso/isosts_convert"
require_relative "isodoc/iso/presentation_xml_convert"
require_relative "html2doc/lists"
require "asciidoctor/extensions"
require "metanorma"

if defined? Metanorma::Registry
  require_relative "metanorma/iso"
  Metanorma::Registry.instance.register(Metanorma::Iso::Processor)
end
