# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Reporter
        # Multi-line text format suitable for CLI output.
        # Example:
        #   rice.adoc: 3 findings (1 errors, 2 warnings, 0 info)
        #   [error] ISO_5 (Document Attributes): pizza is not a recognised document type
        #   [warning] ISO_21 (Style): annex A has not been cross-referenced within document
        class Text < Base
          SEVERITY_TAG = { "error" => "error", "warning" => "warning",
                           "info" => "info" }.freeze

          def format(report)
            lines = [report.summary]
            report.issues.each do |issue|
              lines << format_issue(issue)
            end
            lines.join("\n") + "\n"
          end

          private

          def format_issue(issue)
            tag = SEVERITY_TAG.fetch(issue.severity, issue.severity)
            location = issue.location ? " @ #{issue.location}" : ""
            "[#{tag}] #{issue.code} (#{issue.category})#{location}: #{issue.message}"
          end
        end
      end
    end
  end
end
