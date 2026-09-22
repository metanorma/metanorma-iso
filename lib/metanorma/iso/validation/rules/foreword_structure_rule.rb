# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_23: foreword must not contain subclauses.
        # Source: preface/foreword/clause.
        class ForewordStructureRule < Base
          code "ISO_23"

          def applicable?(context)
            !context.root.nil? && !context.root.preface.nil?
          end

          def check(context)
            foreword = context.root.preface.foreword
            return [] unless foreword

            # IsoForewordSection inherits ContentSection, which maps child
            # <clause> elements to :subsection (not :clause).
            subsections = safe_collection(foreword, :subsection)
            return [] if subsections.empty?

            [build_issue(location: model_location(foreword), params: [])]
          end

          private

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
