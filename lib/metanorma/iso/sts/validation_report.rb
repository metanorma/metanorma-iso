# frozen_string_literal: true

require "nokogiri"

module Metanorma
  module Iso
    module Sts
      # Immutable value object holding the result of validating an OIML STS
      # XML document. `errors` is an array of {Finding} structs.
      class ValidationReport
        Finding = Struct.new(:rule_id, :message, :xpath, keyword_init: true)

        attr_reader :errors

        def initialize(errors: [])
          @errors = errors
        end

        def valid?
          errors.empty?
        end

        def add(rule_id:, message:, xpath: nil)
          @errors << Finding.new(rule_id: rule_id, message: message, xpath: xpath)
        end

        def freeze
          @errors.freeze
          super
        end

        def to_s
          if valid?
            "OIML STS validation passed (0 errors)"
          else
            "OIML STS validation FAILED (#{errors.size} errors):\n" \
              "#{errors.map { |e| "  [#{e.rule_id}] #{e.message}#{' at ' + e.xpath if e.xpath}" }.join("\n")}"
          end
        end
      end
    end
  end
end
