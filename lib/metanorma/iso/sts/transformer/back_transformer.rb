# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::BackTransformer < Transformer::Base
        def transform(source)
          ::Sts::IsoSts::Back.new do |back|
            transform_annexes(source, back)
            transform_bibliography(source, back)
            transform_fn_group(back)
            transform_index(source, back)
          end
        end

        private

        def transform_annexes(source, back)
          annexes = source.annex
          return unless annexes
          return if annexes.empty?

          app_group = build_ordered(::Sts::IsoSts::AppGroup) do |ag|
            Array(annexes).each do |annex|
              ag.app transform_annex(annex)
            end
          end
          back.app_group app_group
        end

        def transform_annex(annex)
          build_ordered(::Sts::IsoSts::App) do |app|
            app.id = id_for(annex)

            if annex.number && !annex.number.empty?
              label_text = "Annex #{annex.number}"
              label_text += " (#{annex.obligation})" if annex.obligation
              app.label ::Sts::IsoSts::Label.new(content: [label_text])
            end

            app.title transform_title(annex.title) if annex.title

            dispatcher = block_dispatcher
            annex.each_mixed_content do |node|
              next if node.is_a?(String)
              next if node == annex.title
              next if skip_node?(node)

              dispatcher.dispatch(node, app)
            end
          end
        end

        def transform_bibliography(source, back)
          bib = source.bibliography
          return unless bib

          refs = bib.references
          return if refs.nil? || refs.empty?

          Array(refs).each do |ref_section|
            next if ref_section.normative == "true"

            back.ref_list reference_transformer.transform_list(ref_section)
          end
        end

        def transform_index(source, back)
          return unless source.indexsect

          sec = build_ordered(::Sts::IsoSts::Sec) do |s|
            s.id = "sec_index"
            s.sec_type = "index"
          end
          back.sec sec
        end

        def transform_fn_group(back)
          fn_group = @context.footnote_collector.fn_group
          back.fn_group fn_group if fn_group
        end
      end
    end
  end
end
