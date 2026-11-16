# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::BackTransformer < Transformer::Base
        def transform(source)
          ::Sts::NisoSts::Back.new do |back|
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

          app_group = build_ordered(::Sts::NisoSts::AppGroup) do |ag|
            Array(annexes).each do |annex|
              ag.app transform_annex(annex)
            end
          end
          back.app_group app_group
        end

        def transform_annex(annex)
          sts_id = id_for(annex)

          Transformer::ModelBuilder.app(id: sts_id) do |app|
            label_text = annex_label_text(annex, sts_id)
            app.label = ::Sts::NisoSts::Label.new(content: [label_text]) if label_text
            app.annex_type = "(#{annex.obligation})" if annex.obligation
            app.title = transform_title(annex.title) if annex.title

            # Dispatch the annex body straight into the App: the app-model
            # carries the block setters the annex content needs, and the
            # schema's app content model wants label/annex-type/title then
            # para-level content then child secs — the shape mnconvert
            # emits. A wrapper <sec> would need its own label/title to be
            # schema-valid, which the annex structure never provides.
            dispatcher = block_dispatcher
            target = Transformer::AppContentAdapter.new(app)
            annex.each_mixed_content do |node|
              next if node.is_a?(String)
              next if node == annex.title
              next if skip_node?(node)

              dispatcher.dispatch(node, target)
            end
          end
        end

        # "Annex A" — from the source number when present, else from the
        # generated annex letter (sec_B → B), keeping label and id
        # consistent.
        def annex_label_text(annex, sts_id)
          return "Annex #{annex.number}" if annex.number && !annex.number.empty?

          letter = sts_id.to_s.delete_prefix("sec_")
          letter.empty? ? nil : "Annex #{letter}"
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

          sec = build_ordered(::Sts::NisoSts::Section) do |s|
            s.id = "sec_index"
            s.type = "index"
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
