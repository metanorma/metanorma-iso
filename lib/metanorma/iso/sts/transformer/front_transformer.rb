# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::FrontTransformer < Transformer::Base
        def transform(source)
          iso_meta = Transformer::IsoMetaTransformer.new(@context).transform(source.bibdata)
          preface_sec = source.preface ? transform_preface_sections(source.preface) : []
          Transformer::ModelBuilder.front(iso_meta: iso_meta, sec: preface_sec)
        end

        private

        def transform_preface_sections(preface)
          sections = []

          if preface.foreword
            sections << section_transformer.transform_foreword(preface.foreword)
          end

          if preface.abstract
            sections << section_transformer.transform_abstract(preface.abstract)
          end

          if preface.introduction
            sections << section_transformer.transform_introduction(preface.introduction)
          end

          if preface.clause
            Array(preface.clause).each do |cl|
              sections << section_transformer.transform(cl)
            end
          end

          # metanorma-document 0.4.0's IsoPreface deliberately dropped the
          # acknowledgements/executivesummary mappings (forbidden by the ISO
          # grammar); guard for older preface models.
          if preface.class.attributes.key?(:acknowledgements) &&
              preface.acknowledgements
            sections << section_transformer.transform(preface.acknowledgements)
          end

          if preface.class.attributes.key?(:executivesummary) &&
              preface.executivesummary
            sections << section_transformer.transform(preface.executivesummary)
          end

          sections
        end
      end
    end
  end
end
