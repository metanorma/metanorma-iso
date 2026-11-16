# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Standardized citation suffix appended to every validation message
      # that carries policy metadata (metanorma/metanorma-iso#1709).
      #
      # Format, frozen:
      # - House Style only: "(ISO House Style (2026), <category path>)" —
      #   the House Style is section-addressed, so the policy-tree category
      #   path IS the citation;
      # - DIR 2 only: "(ISO/IEC DIR 2:2021, <directives clause>)";
      # - both: "(ISO House Style (2026), <category path>; " \
      #   "ISO/IEC DIR 2:2021, <directives clause>)".
      #
      # The diagnostic wording already states the requirement, so the
      # suffix never repeats the rule wording. Rules and checks without
      # metadata emit uncited (the coverage specs enforce metadata
      # completeness); the suffix is nil rather than an error.
      module Citation
        HOUSE_STYLE_LABEL = "ISO House Style (2026)".freeze
        DIRECTIVES_LABEL = "ISO/IEC DIR 2:2021".freeze

        module_function

        # The parenthesized citation suffix for a policy-metadata hash
        # (+source+, +category+, +directives+ — the shape shared by
        # Rules::Base#policy_metadata and LEGACY_POLICY entries), or nil
        # when nothing citable is declared.
        def suffix(metadata)
          return nil if metadata.nil?

          sources = Array(metadata[:source])
          parts = []
          if sources.include?(:house_style) && metadata[:category]
            paths = Array(metadata[:category]).join("; ")
            parts << "#{HOUSE_STYLE_LABEL}, #{paths}"
          end
          if sources.include?(:directives) && metadata[:directives]
            parts << "#{DIRECTIVES_LABEL}, #{metadata[:directives]}"
          end
          return nil if parts.empty?

          "(#{parts.join('; ')})"
        end
      end
    end
  end
end
