warn "Please replace your references to Asciidoctor::ISO with Metanorma::ISO and your instances of require 'asciidoctor/iso' with require 'metanorma/iso'"

exit 127 if ENV['METANORMA_DEPRECATION_FAIL']

Asciidoctor::ISO = Metanorma::ISO unless defined? Asciidoctor::ISO
