# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Foreword presence check. The RNG historically enforced
        # +<preface><foreword>+ as required; migrating that to the model
        # via Layer 1 declaration on IsoPreface#foreword is blocked by
        # the global Layer 1 gate (TODO 02 / TODO 33). In the meantime,
        # this rule provides the same check via Layer 3.
        #
        # Distinct from ForewordStructureRule (ISO_23), which fires when
        # the foreword has subsections. This rule fires when the foreword
        # is entirely absent.
        class ForewordPresenceRule < Base
          code "STANDOC_7"

          def applicable?(context)
            !context.root.nil? && !context.root.preface.nil?
          end

          def check(context)
            foreword = context.root.preface.foreword
            return [] unless foreword.nil?

            [build_issue(location: "IsoPreface", params: ["foreword element is required in preface"])]
          end
        end
      end
    end
  end
end
