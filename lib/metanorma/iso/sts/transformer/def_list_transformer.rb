# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::DefListTransformer < Transformer::Base
        def transform(source)
          build_ordered(::Sts::NisoSts::DefList) do |dl|
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
          build_ordered(::Sts::NisoSts::DefItem) do |item|
            item.term transform_term(dt) if dt
            item.definition transform_def(dd) if dd
          end
        end

        def transform_term(dt)
          build_ordered(::Sts::NisoSts::Term) do |t|
            t.id = dt.id if dt.id
            inline_transformer.apply_inline_content(dt, t)
          end
        end

        # NISO <def> carries a single <p>; all def-list entry content is
        # merged into one Paragraph, matching the mnconvert emission shape.
        def transform_def(dd)
          build_ordered(::Sts::NisoSts::Def) do |d|
            target = ::Sts::NisoSts::Paragraph.new
            has_content = false
            Array(dd.p).each do |para|
              inline_transformer.apply_inline_content(para, target)
              has_content = true
            end
            Array(dd.ul).each { |ul| target.list list_transformer.transform(ul); has_content = true }
            Array(dd.ol).each { |ol| target.list list_transformer.transform(ol); has_content = true }
            d.paragraph = target if has_content
          end
        end
      end
    end
  end
end
