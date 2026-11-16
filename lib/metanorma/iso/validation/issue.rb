# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # A single validation finding, modeled as a lutaml Serializable so it
      # serializes to JSON/YAML/XML for free.
      #
      # +code+ is the ISO_N (or STANDOC_N) log key. Severity/category/message
      # template are sourced from the converter's LOG_MESSAGES hash by code,
      # keeping a single source of truth (DRY).
      class Issue < Lutaml::Model::Serializable
        SEVERITY_BY_LOG_VALUE = {
          0 => "info",
          1 => "warning",
          2 => "error",
          3 => "info"
        }.freeze

        attribute :code, :string
        attribute :severity, :string
        attribute :category, :string
        attribute :message, :string
        attribute :location, :string
        attribute :params, :string, collection: true

        def self.from_finding(code:, location:, params: [])
          spec = log_messages.fetch(code.to_sym) { default_spec }
          new(
            code: code.to_s,
            severity: SEVERITY_BY_LOG_VALUE.fetch(spec[:severity], "error"),
            category: spec[:category].to_s,
            message: format_message(spec[:error], params),
            location: location,
            params: Array(params).map(&:to_s)
          )
        end

        def self.log_messages
          Metanorma::Iso::Converter::ISO_LOG_MESSAGES
        end
        private_class_method :log_messages

        def self.default_spec
          { category: "Unknown", severity: 2, error: "%s" }
        end
        private_class_method :default_spec

        def self.format_message(template, params)
          return template if params.empty?
          return template unless template.include?("%")

          template % Array(params)
        rescue ArgumentError
          template
        end
        private_class_method :format_message

        def error?
          severity == "error"
        end

        def warning?
          severity == "warning"
        end

        def info?
          severity == "info"
        end
      end
    end
  end
end
