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
          Transformer::ModelBuilder.section(
            id: id_for(clause),
            sec_type: sec_type_for(clause),
            label: label_for(clause),
            title: title_for(clause) ? transform_title(title_for(clause)) : nil,
          ) { |sec| dispatch_content(clause, sec) }
        end

        def transform_foreword(foreword)
          Transformer::ModelBuilder.section(
            id: "sec_foreword",
            sec_type: "foreword",
            title: foreword.title ? transform_title(foreword.title) : nil,
          ) { |sec| dispatch_content(foreword, sec, skip_title: true) }
        end

        def transform_abstract(abstract)
          Transformer::ModelBuilder.section(
            id: "sec_abstract",
            sec_type: "abstract",
            title: abstract.title ? transform_title(abstract.title) : nil,
          ) { |sec| dispatch_content(abstract, sec) }
        end

        def transform_introduction(intro)
          Transformer::ModelBuilder.section(
            id: "sec_intro",
            sec_type: "intro",
            title: intro.title ? transform_title(intro.title) : nil,
          ) { |sec| dispatch_content(intro, sec, skip_title: true) }
        end

        def transform_annex(annex)
          label = (annex.number && !annex.number.empty?) ? "Annex #{annex.number}" : nil
          Transformer::ModelBuilder.section(
            id: id_for(annex),
            label: label,
            title: annex.title ? transform_title(annex.title) : nil,
          ) { |sec| dispatch_content(annex, sec, skip_title: true) }
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
