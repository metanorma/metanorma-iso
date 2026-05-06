# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::BodyTransformer < Transformer::Base
        def transform(source)
          build_ordered(::Sts::IsoSts::Body) do |body|
            sections = source.sections
            next unless sections

            dispatcher = block_dispatcher
            sections.each_mixed_content do |node|
              next if node.is_a?(String)

              dispatch_body_node(node, body, dispatcher)
            end
          end
        end

        private

        def dispatch_body_node(node, body, dispatcher)
          case node
          when Metanorma::StandardDocument::Sections::DefinitionSection
            sec = build_ordered(::Sts::IsoSts::Sec) do |s|
              s.id = "sec_symbols"
              s.sec_type = "symbols"
              s.title transform_title(node.title) if node.title
            end
            body.sec sec
          else
            dispatcher.dispatch(node, body)
          end
        end
      end
    end
  end
end
