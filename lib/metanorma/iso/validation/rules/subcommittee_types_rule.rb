# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_2 / ISO_3: validates the subtype of <Technical committee>
        # and <Subcommittee> subdivisions inside committee contributors.
        #
        # Source: contributor[role/description = 'committee']/organization/
        # subdivision[@type = '...']/@subtype must match the allowed set:
        #   - Technical committee: TC, PC, JTC, JPC (ISO_2)
        #   - Subcommittee:        SC, JSC           (ISO_3)
        class SubcommitteeTypesRule < Base
          TC_SUBTYPES = %w[TC PC JTC JPC].freeze
          SC_SUBTYPES = %w[SC JSC].freeze

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            return [] unless context.root.bibdata

            issues = []
            each_committee_subdivision(context.root.bibdata) do |subdivision, group_type|
              issues << build_issue_for(subdivision, group_type) unless valid?(subdivision, group_type)
            end
            issues
          end

          private

          def each_committee_subdivision(bibdata)
            Array(bibdata.contributor).each do |contributor|
              next unless committee_role?(contributor)
              next unless contributor.organization

              Array(contributor.organization.subdivision).each do |subdivision|
                next unless subdivision.type

                yield(subdivision, subdivision.type)
              end
            end
          end

          def committee_role?(contributor)
            role = contributor.role
            return false unless role

            descriptions = role.description
            descriptions = Array(descriptions)
            descriptions.any? { |d| role_value(d) == "committee" }
          end

          def role_value(desc)
            return desc.to_s unless desc.is_a?(Lutaml::Model::Serializable)

            desc.text.to_s
          rescue NoMethodError
            desc.to_s
          end

          def valid?(subdivision, group_type)
            case group_type
            when "Technical committee" then TC_SUBTYPES.include?(subdivision.subtype.to_s)
            when "Subcommittee"        then SC_SUBTYPES.include?(subdivision.subtype.to_s)
            else true
            end
          end

          def build_issue_for(subdivision, group_type)
            code = case group_type
                   when "Technical committee" then "ISO_2"
                   when "Subcommittee"        then "ISO_3"
                   end
            Metanorma::Iso::Validation::Issue.from_finding(
              code: code || "ISO_2",
              location: nil,
              params: [subdivision.subtype.to_s]
            )
          end
        end
      end
    end
  end
end
