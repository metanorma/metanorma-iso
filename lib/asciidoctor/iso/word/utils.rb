require "uuidtools"
  
module Asciidoctor
  module ISO::Word
    module Utils
      class << self
                def ns(xpath)
          xpath.gsub(%r{/([a-zA-z])}, "/xmlns:\\1")
        end
      end
    end
  end
end
