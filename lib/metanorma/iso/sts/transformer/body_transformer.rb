# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::BodyTransformer < Transformer::Base
        def transform(source)
          sections = source.sections
          return Transformer::ModelBuilder.body(sec: []) unless sections

          body = Transformer::ModelBuilder.body
          idx = 0
          sections.each_mixed_content do |node|
            next if node.is_a?(String)

            idx += 1
            dispatch_body_node(node, body, block_dispatcher)
          end
          body
        end

        private

        def dispatch_body_node(node, body, dispatcher)
          case node
          when Metanorma::Standoc::Document::Sections::DefinitionSection
            sec = Transformer::ModelBuilder.section(
              id: "sec_symbols",
              sec_type: "symbols",
              title: node.title ? transform_title(node.title) : nil,
            )
            body.sec sec
          else
            dispatcher.dispatch(node, body)
          end
        end
      end
    end
  end
end
