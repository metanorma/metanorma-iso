# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::DefListTransformer < Transformer::Base
        def transform(source)
          build_ordered(::Sts::IsoSts::DefList) do |dl|
            dl.id = source.id if source.id && !source.id.start_with?("_")
            dl.list_type = source.key if source.key

            source.each_mixed_content do |node|
              next if node.is_a?(String)

              case node
              when Metanorma::Document::Components::Lists::DtElement
                @current_dt = node
              when Metanorma::Document::Components::Lists::DdElement
                dl.def_item transform_def_item(@current_dt, node)
                @current_dt = nil
              end
            end
          end
        end

        private

        def transform_def_item(dt, dd)
          build_ordered(::Sts::IsoSts::DefItem) do |item|
            item.term transform_term(dt) if dt
            item.def transform_def(dd) if dd
          end
        end

        def transform_term(dt)
          build_ordered(::Sts::IsoSts::Term) do |t|
            t.id = dt.id if dt.id
            inline_transformer.apply_inline_content(dt, t)
          end
        end

        def transform_def(dd)
          build_ordered(::Sts::IsoSts::Def) do |d|
            if dd.p && !dd.p.empty?
              dd.p.each do |para|
                d.p paragraph_transformer.transform(para)
              end
            end

            dd.ul&.each { |ul| d.p build_list_paragraph(ul) }
            dd.ol&.each { |ol| d.p build_list_paragraph(ol) }
          end
        end
      end
    end
  end
end
