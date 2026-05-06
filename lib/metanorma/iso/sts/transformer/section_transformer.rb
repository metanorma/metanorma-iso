# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::SectionTransformer < Transformer::Base
        SEC_TYPE_MAP = {
          "intro" => "intro",
          "scope" => "scope",
          "overview" => "scope",
        }.freeze

        def transform(clause)
          build_ordered(::Sts::IsoSts::Sec) do |sec|
            sec.id = id_for(clause)
            sec.sec_type = sec_type_for(clause)

            label_text = label_for(clause)
            sec.label = ::Sts::IsoSts::Label.new(content: [label_text]) if label_text

            if title_for(clause)
              sec.title transform_title(title_for(clause))
            end

            dispatch_content(clause, sec)
          end
        end

        def transform_foreword(foreword)
          build_ordered(::Sts::IsoSts::Sec) do |sec|
            sec.id = "sec_foreword"
            sec.sec_type = "foreword"
            sec.title transform_title(foreword.title) if foreword.title

            dispatch_content(foreword, sec, skip_title: true)
          end
        end

        def transform_abstract(abstract)
          build_ordered(::Sts::IsoSts::Sec) do |sec|
            sec.id = "sec_abstract"
            sec.sec_type = "abstract"
            sec.title transform_title(abstract.title) if abstract.title

            dispatch_content(abstract, sec)
          end
        end

        def transform_introduction(intro)
          build_ordered(::Sts::IsoSts::Sec) do |sec|
            sec.id = "sec_intro"
            sec.sec_type = "intro"
            sec.title transform_title(intro.title) if intro.title

            dispatch_content(intro, sec, skip_title: true)
          end
        end

        def transform_annex(annex)
          build_ordered(::Sts::IsoSts::Sec) do |sec|
            sec.id = id_for(annex)

            if annex.number && !annex.number.empty?
              sec.label = ::Sts::IsoSts::Label.new(content: ["Annex #{annex.number}"])
            end

            sec.title transform_title(annex.title) if annex.title

            dispatch_content(annex, sec, skip_title: true)
          end
        end

        private

        def dispatch_content(source, target, skip_title: false)
          dispatcher = block_dispatcher
          title_node = skip_title ? source.title : nil

          source.each_mixed_content do |node|
            next if node.is_a?(String)
            next if node == title_node
            next if skip_node?(node)

            dispatcher.dispatch(node, target)
          end
        end

        def sec_type_for(clause)
          SEC_TYPE_MAP[clause.type]
        end

        def label_for(clause)
          clause.number if clause.number && !clause.number.empty?
        end

        def title_for(clause)
          clause.title
        end
      end
    end
  end
end
