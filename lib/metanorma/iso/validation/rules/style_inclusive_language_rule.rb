# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for non-inclusive terms (ISO House Style):
        # each flagged term is paired with its suggested inclusive
        # alternative in the message. The blacklist is closed and
        # documented: only the well-known published pairs are flagged.
        #
        #   manpower → personnel, staff      chairman → chair
        #   salesman → salesperson           businessman → businessperson
        #   workman → worker                 foreman → supervisor
        #   manned → crewed, operated        master/slave → primary/
        #                                    secondary, main/replica
        #   whitelist → allowlist            blacklist → denylist
        #   dummy → placeholder
        #
        # "master" alone is not flagged ("master copy", "master data"
        # and academic usage are legitimate): only the "master/slave"
        # pairing is. Inflected forms of whitelist/blacklist are
        # covered ("whitelisted", "blacklisting").
        class StyleInclusiveLanguageRule < StyleRule
          policy category: "Spelling and wording > Inclusive language",
                 rule: "use inclusive terminology; replace non-inclusive terms with the published alternatives",
                 source: %i[house_style directives], directives: "8.6",
                 mn_category: :style

          NON_INCLUSIVE = {
            /\bmanpower\b/i => %w[personnel staff],
            /\bchairman\b/i => %w[chair],
            /\bsalesman\b/i => %w[salesperson],
            /\bbusinessman\b/i => %w[businessperson],
            /\bworkman\b/i => %w[worker],
            /\bforeman\b/i => %w[supervisor],
            /\bmanned\b/i => %w[crewed operated],
            %r{\bmaster/slave\b}i => ["primary/secondary", "main/replica"],
            /\bwhitelist(?:s|ed|ing)?\b/i => %w[allowlist],
            /\bblacklist(?:s|ed|ing)?\b/i => %w[denylist],
            /\bdummy\b/i => %w[placeholder]
          }.freeze

          def scan_text(node, text)
            findings = []
            NON_INCLUSIVE.each do |regex, alternatives|
              match = text.match(regex)
              next unless match

              findings << build_warning(node, message_for(match[0], alternatives))
            end
            findings
          end

          private

          def message_for(term, alternatives)
            "non-inclusive term '#{term}' (use " \
              "#{alternatives.map { |a| "'#{a}'" }.join(' or ')})"
          end
        end
      end
    end
  end
end
