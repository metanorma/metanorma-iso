# frozen_string_literal: true

require "nokogiri"
require "set"

module Metanorma
  module Iso
    module Sts
      # Validates that the STS-rendered HTML contains 100% of the
      # semantic content present in the Metanorma HTML output.
      module ParityValidator
        autoload :Report, "metanorma/iso/sts/parity_validator/report"
        autoload :Normaliser, "metanorma/iso/sts/parity_validator/normaliser"

        module_function

        def validate(mn_html:, sts_html:)
          Report.new(mn_html: mn_html, sts_html: sts_html)
        end
      end
    end
  end
end
