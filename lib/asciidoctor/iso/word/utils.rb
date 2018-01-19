require "uuidtools"
require "asciidoctor/iso/isoxml/utils"

module Asciidoctor
  module ISO
    module Word
      module Utils
        def ns(xpath)
          xpath.gsub(%r{/([a-zA-z])}, "/xmlns:\\1")
        end
      end
    end
  end
end
