# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Aggregate validation result. Carries every Issue found in a run and
      # rolls up +valid?+ as "no error-severity issues". Serializable to
      # JSON/YAML/XML via lutaml-model.
      class Report < Lutaml::Model::Serializable
        attribute :document, :string
        attribute :generated_at, :string
        attribute :valid, :boolean, default: -> { true }
        attribute :issues, Issue, collection: true, default: -> { [] }

        def add_issue(code:, location:, params: [])
          issue = Issue.from_finding(code: code, location: location, params: params)
          issues << issue
          self.valid = false if issue.error?
          issue
        end

        def valid?
          valid
        end

        def errors
          issues.select(&:error?)
        end

        def warnings
          issues.select(&:warning?)
        end

        def infos
          issues.select(&:info?)
        end

        def summary
          "#{document || '<unknown>'}: " \
            "#{issues.size} findings " \
            "(#{errors.size} errors, #{warnings.size} warnings, " \
            "#{infos.size} info)"
        end
      end
    end
  end
end
