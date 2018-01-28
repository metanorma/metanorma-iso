require "uuidtools"
require "asciidoctor/iso/isoxml/utils"

module Asciidoctor
  module ISO
    module Word
      module Utils
        def ns(xpath)
          xpath.gsub(%r{/([a-zA-z])}, "/xmlns:\\1").
            gsub(%r{::([a-zA-z])}, "::xmlns:\\1").
            gsub(%r{\[([a-zA-z]+ ?=)}, "[xmlns:\\1").
            gsub(%r{\[([a-zA-z]+\])}, "[xmlns:\\1")
        end

        def insert_tab(out, n)
          out.span **attr_code(style: "mso-tab-count:#{n}") do |span|
            [1..n].each { |i| span << "&#xA0; " }
          end
        end
      end
    end
  end
end
