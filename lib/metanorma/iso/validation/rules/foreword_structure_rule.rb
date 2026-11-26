# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_23: foreword must not contain subclauses.
        # Source: preface/foreword/clause.
        class ForewordStructureRule < Base
          include DeclarativeDispatch

          code "ISO_23"
          declarative_rule "iso.foreword.no-subclauses"

          policy category: "Document structure",
                 rule: "the Foreword must not contain subclauses",
                 source: :directives, directives: "12.4",
                 mn_category: :structure

          def applicable?(context)
            !context.root.nil? && !context.root.preface.nil?
          end

          private

          def declarative_issue(_finding, context)
            build_issue(location: model_location(context.root.preface.foreword),
                        params: [])
          end

          def legacy_check(context)
            foreword = context.root.preface.foreword
            return [] unless foreword

            # IsoForewordSection inherits ContentSection, which maps child
            # <clause> elements to :subsection (not :clause).
            subsections = safe_collection(foreword, :subsection)
            return [] if subsections.empty?

            [build_issue(location: model_location(foreword), params: [])]
          end

          # Read a possibly-absent collection attribute without using
          # respond_to?. Returns [] when the attribute doesn't exist on the
          # model class.
          def safe_collection(node, attr_name)
            return [] unless node.class.method_defined?(attr_name)

            Array(node.public_send(attr_name))
          end
        end
      end
    end
  end
end
